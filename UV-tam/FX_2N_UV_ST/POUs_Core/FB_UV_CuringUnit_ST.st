(* ==============================================================================
   POU CORE: FB_UV_CuringUnit (CHUẨN STRUCTURED DATA TYPES)
   GX Works2: Dán vào cửa sổ Program [ST] của FB_UV_CuringUnit
   Biến sử dụng: stCmd (ST_UV_Commands), stSensors (ST_UV_Sensors),
                 stOutputs (ST_UV_Outputs), stStatus (ST_UV_Status)
   ============================================================================== *)

(* --- 1. LỌC NHIỄU KHỞI ĐỘNG NGUỒN PLC (2.0s POWER-ON DEBOUNCE) --- *)
tonPowerOnInit(
    IN := TRUE,
    PT := tPowerOnInitDelay
);
bPowerOnDebounceDone := tonPowerOnInit.Q;


(* --- 2. QUẢN LÝ CHỐT VẬN HÀNH (SYSTEM RUN LATCH) --- *)

(* Phát hiện cạnh xuống của nút Stop hoặc ngắt vận hành để kích hoạt After-Cool *)
bStopTrigger := stCmd.bStop OR bSystemAlarm OR (NOT stSensors.di_PowerCabinetDoorClosed);

(* Khởi động: Nhấn Start khi không có lỗi, nguồn ổn định, và không trong chu kỳ After-Cool *)
IF stCmd.bStart AND (NOT bSystemAlarm) AND bPowerOnDebounceDone AND (NOT stStatus.bAfterCoolActive) THEN
    bRunLatch := TRUE;
ELSIF bStopTrigger THEN
    IF bRunLatch THEN
        bTriggerAfterCool := TRUE; (* Kích hoạt chu trình làm mát sau 180s *)
    END_IF;
    bRunLatch := FALSE;
END_IF;


(* --- 3. GIAI ĐOẠN SẤY NÓNG 80W (WARM-UP 30s) --- *)
tonWarmup(
    IN := bRunLatch,
    PT := tWarmupDuration
);

(* Cờ trạng thái sấy nóng và ổn định áp bóng UV *)
stStatus.bWarmupActive   := bRunLatch AND (NOT tonWarmup.Q);
stStatus.bLampStabilized := bRunLatch AND tonWarmup.Q;


(* --- 4. LIÊN ĐỘNG MỞ SHUTTER & TĂNG CẤP CÔNG SUẤT (120W / 160W) --- *)

(* Điều kiện cho phép mở Shutter và tăng công suất:
   - Đã qua thời gian sấy nóng 30s
   - Cửa buồng sấy đóng an toàn (X005)
   - Băng tải/máy in đang chạy (X006)
   - Không bị công tắc cưỡng bức chế độ 80W (X027) *)
bPermitHighPower := bRunLatch
                    AND stStatus.bLampStabilized
                    AND stSensors.di_SafetyDoorClosed
                    AND stSensors.di_MainLineRunning
                    AND (NOT stCmd.bSelect80W);

(* Điều khiển cuộn hút mở Shutter che UV (Y007):
   Mở khi đủ điều kiện và chọn công suất 120W hoặc 160W *)
stOutputs.q_ShutterSolenoid := bPermitHighPower AND (stCmd.bSelect120W OR stCmd.bSelect160W);

(* ĐIỀU KHIỂN CÁC KHỞI ĐỘNG TỪ BÓNG ĐÈN UV:
   - Cấp 80W (Y002): Luôn sáng khi hệ thống đang chạy (bRunLatch)
   - Cấp 120W (Y003): Bật khi mở Shutter thành công
   - Cấp 160W Turbo (Y004): Bật khi đang ở 120W và có công tắc chọn 160W (X024) *)
stOutputs.q_Lamp80W  := bRunLatch;
stOutputs.q_Lamp120W := bPermitHighPower AND stOutputs.q_ShutterSolenoid;
stOutputs.q_Lamp160W := stOutputs.q_Lamp120W AND stCmd.bSelect160W;


(* --- 5. ĐIỀU KHIỂN HỆ THỐNG QUẠT HÚT, VAN GIÓ & CHILLER --- *)

(* Quạt hút chính (Y010): Chạy khi hệ thống đang bật HOẶC trong chu kỳ làm mát sau *)
stOutputs.q_FanMain := bRunLatch OR stStatus.bAfterCoolActive;

(* Quạt cấp gió 3 cấp tốc độ:
   - Cấp 1 (Y011): Khi đang sấy nóng 80W hoặc Shutter đóng (tránh làm nguội hồ quang)
   - Cấp 2 (Y012): Khi Shutter mở và chạy công suất tiêu chuẩn 120W
   - Cấp 3 (Y013): Khi chạy công suất cao 160W HOẶC trong chu trình làm mát sau (After-Cool 180s) *)
stOutputs.q_FanSpeed1 := bRunLatch AND (NOT stOutputs.q_ShutterSolenoid OR (NOT stOutputs.q_Lamp120W AND NOT stOutputs.q_Lamp160W));
stOutputs.q_FanSpeed2 := bRunLatch AND stOutputs.q_Lamp120W AND (NOT stOutputs.q_Lamp160W);
stOutputs.q_FanSpeed3 := (bRunLatch AND stOutputs.q_Lamp160W) OR stStatus.bAfterCoolActive;

(* Máy làm lạnh Chiller nước tuần hoàn (Y030) *)
stOutputs.q_Chiller := bRunLatch OR stStatus.bAfterCoolActive;

(* Van gió tập trung buồng sấy Damper 1 & 2 (Y005 & Y006):
   Tự động mở theo cảm biến vị trí phôi (X014, X015) *)
stOutputs.q_Damper1 := bRunLatch AND stSensors.di_DamperPos1Sw;
stOutputs.q_Damper2 := bRunLatch AND stSensors.di_DamperPos2Sw;


(* --- 6. CHU TRÌNH LÀM MÁT SAU KHI TẮT ĐÈN (AFTER-COOLING 180s) --- *)
IF bTriggerAfterCool THEN
    stStatus.bAfterCoolActive := TRUE;
    bTriggerAfterCool         := FALSE;
END_IF;

tonAfterCool(
    IN := stStatus.bAfterCoolActive,
    PT := tAfterCoolDuration
);

IF tonAfterCool.Q THEN
    stStatus.bAfterCoolActive := FALSE;
END_IF;


(* --- 7. TÍNH TOÁN TELEMETRY TRẠNG THÁI & THỜI GIAN ĐẾM NGƯỢC --- *)

(* Trạng thái sẵn sàng *)
stStatus.bSystemReady := (NOT bSystemAlarm) AND bPowerOnDebounceDone AND (NOT stStatus.bAfterCoolActive);

(* Mã trạng thái vận hành xuất HMI *)
IF stStatus.bAfterCoolActive THEN
    stStatus.iStateCode := 5; (* AFTER_COOL *)
ELSIF NOT bRunLatch THEN
    stStatus.iStateCode := 0; (* STOP / STANDBY *)
ELSIF stStatus.bWarmupActive THEN
    stStatus.iStateCode := 1; (* WARMUP_80W *)
ELSIF stOutputs.q_Lamp160W THEN
    stStatus.iStateCode := 4; (* RUN_160W *)
ELSIF stOutputs.q_Lamp120W THEN
    stStatus.iStateCode := 3; (* RUN_120W *)
ELSE
    stStatus.iStateCode := 2; (* RUN_80W *)
END_IF;

(* Thời gian đếm ngược sấy nóng 30s *)
IF stStatus.bWarmupActive THEN
    stStatus.iWarmupRemainSec := 30 - TIME_TO_INT(tonWarmup.ET) / 1000;
ELSE
    stStatus.iWarmupRemainSec := 0;
END_IF;

(* Thời gian đếm ngược làm mát 180s *)
IF stStatus.bAfterCoolActive THEN
    stStatus.iAfterCoolRemainSec := 180 - TIME_TO_INT(tonAfterCool.ET) / 1000;
ELSE
    stStatus.iAfterCoolRemainSec := 0;
END_IF;
