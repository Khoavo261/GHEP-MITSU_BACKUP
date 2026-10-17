(* ==============================================================================
   POU CORE: FB_UV_AlarmManager (CHUẨN STRUCTURED DATA TYPES)
   GX Works2: Dán vào cửa sổ Program [ST] của FB_UV_AlarmManager
   Biến sử dụng: stSensors (ST_UV_Sensors), stCmd (ST_UV_Commands), stAlarms (ST_UV_Alarms)
   ============================================================================== *)

(* --- 1. ĐỊNH THỜI LỌC NHIỄU SỰ CỐ (IEC TON TIMERS) --- *)

(* Lỗi 1: Chấn lưu Ballast T1 (5s)
   Xảy ra khi: Quá áp (X002) lúc đang bật đèn 80W HOẶC Sụt áp (X001) sau khi đèn đã ổn định 30s *)
tonBallast(
    IN := (stSensors.di_LampVoltageHigh AND bLamp80WActive)
          OR (stSensors.di_LampVoltageLow AND bLampStabilized),
    PT := tBallastFaultDelay
);

(* Lỗi 2: Áp suất gió buồng sấy T11 (5s)
   Xảy ra khi: Đèn đang bật 80W và đã qua thời gian ổn định 30s mà áp gió mất *)
tonAirPressure(
    IN := stSensors.di_AirPressureSw AND bLamp80WActive AND bLampStabilized,
    PT := tAirPressureDelay
);

(* Lỗi 6: Kẹt hành trình Shutter T21 (5s)
   Xảy ra khi: Đèn đang sáng, phát lệnh mở nhưng sensor báo mở không tác động
   HOẶC Lệnh đóng nhưng sensor báo đóng không tác động *)
bShutterConditionError := (stSensors.di_ShutterOpenLimit AND bShutterSolenoid AND bLamp80WActive)
                          OR (stSensors.di_ShutterClosedLimit AND NOT bShutterSolenoid);
tonShutter(
    IN := bShutterConditionError,
    PT := tShutterFaultDelay
);

(* Lỗi 5: Lưu lượng nước làm mát T41 (15s): Khi đèn UV đang sáng *)
tonWaterFlow(
    IN := stSensors.di_WaterFlowSw AND bLamp80WActive,
    PT := tWaterFlowDelay
);

(* Lỗi 7: Trễ khởi động giám sát Chiller T101 (10s) *)
tonChillerStart(
    IN := bLampIgnited,
    PT := tChillerFaultDelay
);

(* Cảnh báo 9: Hết tuổi thọ bóng đèn UV T120 (5s) *)
tonLampLife(
    IN := bLampHourMeterExpired,
    PT := tLampLifeDelay
);


(* --- 2. CHỐT CỜ SỰ CỐ TỰ GIỮ (SET LATCH FAULTS 1..9) --- *)

(* Reset toàn bộ cờ sự cố khi nhấn Reset từ HMI *)
IF stCmd.bResetFault THEN
    stAlarms.bBallastFault      := FALSE;
    stAlarms.bAirPressureFault  := FALSE;
    stAlarms.bDoorOpenFault     := FALSE;
    stAlarms.bAirFlowFault      := FALSE;
    stAlarms.bWaterFlowFault    := FALSE;
    stAlarms.bShutterFault      := FALSE;
    stAlarms.bChillerFault      := FALSE;
    stAlarms.bOverTempFault     := FALSE;
    stAlarms.bLampLifeExpired   := FALSE;
    bBuzzerMuted                := FALSE;
ELSE
    (* Chốt lỗi 1: Ballast *)
    IF tonBallast.Q THEN
        stAlarms.bBallastFault := TRUE;
    END_IF;

    (* Chốt lỗi 2: Áp suất gió buồng sấy *)
    IF tonAirPressure.Q THEN
        stAlarms.bAirPressureFault := TRUE;
    END_IF;

    (* Chốt lỗi 3: Mở cửa tủ điện an toàn (X004 mở mạch) *)
    IF NOT stSensors.di_PowerCabinetDoorClosed THEN
        stAlarms.bDoorOpenFault := TRUE;
    END_IF;

    (* Chốt lỗi 4: Lưu lượng gió hút (X011 tác động) *)
    IF stSensors.di_AirFlowSw THEN
        stAlarms.bAirFlowFault := TRUE;
    END_IF;

    (* Chốt lỗi 5: Lưu lượng nước làm mát (T41) *)
    IF tonWaterFlow.Q THEN
        stAlarms.bWaterFlowFault := TRUE;
    END_IF;

    (* Chốt lỗi 6: Kẹt hành trình Shutter (T21) *)
    IF tonShutter.Q THEN
        stAlarms.bShutterFault := TRUE;
    END_IF;

    (* Chốt lỗi 7: Trip Chiller (X016 tác động sau trễ 10s T101) *)
    IF stSensors.di_ChillerTrip AND tonChillerStart.Q THEN
        stAlarms.bChillerFault := TRUE;
    END_IF;

    (* Chốt lỗi 8: Quá nhiệt buồng sấy (X003 tác động tức thời) *)
    IF stSensors.di_OverTempTrip THEN
        stAlarms.bOverTempFault := TRUE;
    END_IF;

    (* Chốt cảnh báo 9: Tuổi thọ bóng UV (T120) *)
    IF tonLampLife.Q THEN
        stAlarms.bLampLifeExpired := TRUE;
    END_IF;
END_IF;


(* --- 3. TỔNG HỢP SỰ CỐ HỆ THỐNG & ĐIỀU KHIỂN CÒI BÁO (BUZZER) --- *)

(* M180: Cờ tổng sự cố (Bất kỳ lỗi nào trong 9 lỗi xuất hiện) *)
stAlarms.bSystemAlarm := stAlarms.bBallastFault
                         OR stAlarms.bAirPressureFault
                         OR stAlarms.bDoorOpenFault
                         OR stAlarms.bAirFlowFault
                         OR stAlarms.bWaterFlowFault
                         OR stAlarms.bShutterFault
                         OR stAlarms.bChillerFault
                         OR stAlarms.bOverTempFault
                         OR stAlarms.bLampLifeExpired;

(* Quản lý tắt còi (Buzzer Mute): X026 / stCmd.bBuzzerStop *)
IF stCmd.bBuzzerStop THEN
    bBuzzerMuted := TRUE;
ELSIF NOT stAlarms.bSystemAlarm THEN
    bBuzzerMuted := FALSE;
END_IF;

(* Xuất còi Y023: Kêu khi có sự cố và chưa bị ấn tắt còi *)
q_Buzzer := stAlarms.bSystemAlarm AND (NOT bBuzzerMuted);


(* --- 4. BỘ QUÉT MÃ LỖI TUẦN TỰ (SMART ALARM SEQUENCER 1..9) --- *)

(* Timer chu kỳ luân chuyển 2.0s *)
tonScanTimer(
    IN := stAlarms.bSystemAlarm AND (NOT tonScanTimer.Q),
    PT := tScanStepDuration
);

(* Chuyển bước quét khi hết chu kỳ 2s *)
IF NOT stAlarms.bSystemAlarm THEN
    iScanPointer                := 1;
    stAlarms.iActiveAlarmCode   := 0;
    stOutputs_AlarmBits         := 0;
ELSIF tonScanTimer.Q THEN
    iScanPointer := iScanPointer + 1;
    IF iScanPointer > 9 THEN
        iScanPointer := 1;
    END_IF;
END_IF;

(* Tìm kiếm sự cố tích cực tiếp theo *)
IF stAlarms.bSystemAlarm THEN
    bFoundActive := FALSE;
    iSearchCount := 0;

    WHILE (NOT bFoundActive) AND (iSearchCount < 9) DO
        CASE iScanPointer OF
            1: IF stAlarms.bBallastFault THEN bFoundActive := TRUE; END_IF;
            2: IF stAlarms.bAirPressureFault THEN bFoundActive := TRUE; END_IF;
            3: IF stAlarms.bDoorOpenFault THEN bFoundActive := TRUE; END_IF;
            4: IF stAlarms.bAirFlowFault THEN bFoundActive := TRUE; END_IF;
            5: IF stAlarms.bWaterFlowFault THEN bFoundActive := TRUE; END_IF;
            6: IF stAlarms.bShutterFault THEN bFoundActive := TRUE; END_IF;
            7: IF stAlarms.bChillerFault THEN bFoundActive := TRUE; END_IF;
            8: IF stAlarms.bOverTempFault THEN bFoundActive := TRUE; END_IF;
            9: IF stAlarms.bLampLifeExpired THEN bFoundActive := TRUE; END_IF;
        END_CASE;

        IF NOT bFoundActive THEN
            iScanPointer := iScanPointer + 1;
            IF iScanPointer > 9 THEN
                iScanPointer := 1;
            END_IF;
            iSearchCount := iSearchCount + 1;
        END_IF;
    END_WHILE;

    IF bFoundActive THEN
        stAlarms.iActiveAlarmCode := iScanPointer;
    ELSE
        stAlarms.iActiveAlarmCode := 0;
    END_IF;
END_IF;

(* Xuất mã 4-bit (K1Y024) *)
stOutputs_AlarmBits := stAlarms.iActiveAlarmCode;
