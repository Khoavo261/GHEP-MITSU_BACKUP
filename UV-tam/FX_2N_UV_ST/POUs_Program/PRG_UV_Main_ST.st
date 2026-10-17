(* ==============================================================================
   PROGRAM MAIN: PRG_UV_Main (CHUẨN STRUCTURED DATA TYPES)
   GX Works2: Dán vào cửa sổ Program [ST] của PRG_UV_Main
   Khớp 100% với Global_Labels.tsv đã nạp (Có chú thích đầy đủ mã X, Y, D từng dòng)
   ============================================================================== *)

(* ==============================================================================
   BƯỚC 1: HARDWARE INGRESS (ÁNH XẠ PHẦN CỨNG X VÀO CÁC STRUCT)
   ============================================================================== *)

(* 1.1 Cảm biến & liên động phần cứng (stSensors) *)
stSensors.di_LampVoltageLow         := di_LampVoltageLow;           (* X001: Ap thap chan luu Ballast *)
stSensors.di_LampVoltageHigh        := di_LampVoltageHigh;          (* X002: Ap cao chan luu Ballast *)
stSensors.di_OverTempTrip           := di_EStop;                    (* X003: Su co qua nhiet buong say / E-Stop *)

(* X004: Thuong dong an toan cua tu dien (Cua dong = Tiep diem dong) *)
IF di_CabinetDoorOpen THEN
    stSensors.di_PowerCabinetDoorClosed := FALSE;                   (* X004: Cua tu dien dang bi mo *)
ELSE
    stSensors.di_PowerCabinetDoorClosed := TRUE;                    (* X004: Cua tu dien da dong an toan *)
END_IF;

stSensors.di_SafetyDoorClosed       := di_InfeedDoorClosed;         (* X005: Cam bien cua nap phoi da dong kin *)
stSensors.di_MainLineRunning        := di_MainMachineRunning;       (* X006: Tin hieu may chinh / bang tai dang chay *)
stSensors.di_AirPressureSw          := di_AirPressureSw;            (* X010: Cong tac ap suat gio buong say *)
stSensors.di_AirFlowSw              := di_ChamberLTS;               (* X011: Limit switch luu luong gio buong say *)
stSensors.di_ShutterOpenLimit       := di_ShutterOpenLimit;         (* X012: Cam bien Shutter da mo het *)
stSensors.di_ShutterClosedLimit     := di_ShutterClosedLimit;       (* X013: Cam bien Shutter da dong kin *)
stSensors.di_DamperPos1Sw           := di_ChamberPos1;              (* X014: Cam bien vi tri 1 mo Damper 1 *)
stSensors.di_DamperPos2Sw           := di_ChamberPos2;              (* X015: Cam bien vi tri 2 mo Damper 2 *)
stSensors.di_WaterFlowSw            := di_WaterFlowSw;              (* X016: Cam bien luu luong nuoc lam mat *)
stSensors.di_ChillerTrip            := di_ChillerFaultSig;          (* X031: Tin hieu bao loi / trip may Chiller *)

(* 1.2 Nút nhấn vật lý & Lệnh HMI (stCommands) *)
stCommands.bStart                   := di_BtnLampOn;                (* X020: Nut nhan bat den UV PB ON *)
stCommands.bStop                    := di_BtnLampOff;               (* X021: Nut nhan tat den UV PB OFF *)
stCommands.bBuzzerStop              := di_BtnBuzzerStop;            (* X022: Nut tat coi bao dong Buzzer Stop *)
stCommands.bResetFault              := di_BtnFaultReset;            (* X023: Nut Reset giai tru loi he thong *)
stCommands.bSelect160W              := di_SwPower160W;              (* X024: Cong tac chon cong suat 160W Turbo *)
stCommands.bSelect80W               := di_SwPower80W;               (* X027: Cong tac chon cong suat 80W Standby *)

(* Mac dinh 120W khi khong gat 80W va khong gat 160W *)
IF di_SwPower80W OR di_SwPower160W THEN
    stCommands.bSelect120W := FALSE;
ELSE
    stCommands.bSelect120W := TRUE;                                 (* Che do cong suat tieu chuan 120W *)
END_IF;


(* ==============================================================================
   BƯỚC 2: THỰC THI FB ĐIỀU KHIỂN CHU TRÌNH ĐÈN UV, QUẠT, CHILLER
   ============================================================================== *)
fbCuringUnit(
    stCmd                 := stCommands,                            (* Nhanh lenh dieu khien *)
    stSensors             := stSensors,                             (* Nhanh cam bien an toan *)
    bSystemAlarm          := stAlarms.bSystemAlarm,                 (* Co ngat su co toan he thong *)
    stOutputs             := stOutputs,                             (* Nhanh xuat chap hanh den, quat *)
    stStatus              := stStatus                               (* Nhanh phan hoi trang thai va giay *)
);


(* ==============================================================================
   BƯỚC 3: THỰC THI FB QUẢN LÝ 9 SỰ CỐ & QUÉT MÃ LỖI (ALARM MANAGER)
   ============================================================================== *)
fbAlarmManager(
    stSensors             := stSensors,                             (* Cam bien phan cung *)
    stCmd                 := stCommands,                            (* Nut nhan reset va tat coi *)
    bLamp80WActive        := stOutputs.q_Lamp80W,                   (* Trang thai den dang sang 80W *)
    bLampStabilized       := stStatus.bLampStabilized,              (* Den da on dinh sau say nong 30s *)
    bShutterSolenoid      := stOutputs.q_ShutterSolenoid,           (* Cuon hut mo Shutter dang cap dien *)
    bLampIgnited          := stOutputs.q_Lamp80W,                   (* Den da moi sang bat ky cap nao *)
    bLampHourMeterExpired := FALSE,                                 (* Canh bao het gio chay bong UV *)
    stAlarms              := stAlarms,                              (* Nhanh 9 co su co he thong *)
    q_Buzzer              := stOutputs.q_Buzzer,                    (* Lenh xuat coi bao dong Y001 *)
    stOutputs_AlarmBits   := stOutputs.q_AlarmCodeBits              (* Ma loi 4-bit xuat ra Y024..Y027 *)
);


(* ==============================================================================
   BƯỚC 4: HARDWARE EGRESS (XUẤT RA GLOBAL LABELS VẬT LÝ Y)
   ============================================================================== *)
do_MasterAlarm            := stAlarms.bSystemAlarm;                 (* Y000: Den bao tong hop su co he thong *)
do_Buzzer                 := stOutputs.q_Buzzer;                    (* Y001: Coi bao dong su co Buzzer *)
do_LampPower80W           := stOutputs.q_Lamp80W;                   (* Y002: Khoi dong tu bat den UV 80W / Warmup *)
do_LampPower120W          := stOutputs.q_Lamp120W;                  (* Y003: Khoi dong tu kich cong suat 120W *)
do_LampPower160W          := stOutputs.q_Lamp160W;                  (* Y004: Khoi dong tu kich cong suat 160W Turbo *)
do_ExhaustDamper1         := stOutputs.q_Damper1;                   (* Y005: Van xa khi buong chieu Damper 1 *)
do_ExhaustDamper2         := stOutputs.q_Damper2;                   (* Y006: Van xa khi buong chieu Damper 2 *)
do_ShutterValve           := stOutputs.q_ShutterSolenoid;           (* Y007: Van khi mo cua chan Shutter UV *)
do_ExhaustFan             := stOutputs.q_FanMain;                   (* Y010: Dong co quat hut chinh hoat dong *)
do_FanSpeedStage1         := stOutputs.q_FanSpeed1;                 (* Y011: Quat cap cap toc do 1 (Low) *)
do_FanSpeedStage2         := stOutputs.q_FanSpeed2;                 (* Y012: Quat cap cap toc do 2 (Mid) *)
do_FanSpeedStage3         := stOutputs.q_FanSpeed3;                 (* Y013: Quat cap cap toc do 3 (Turbo) *)
do_ChillerCommand         := stOutputs.q_Chiller;                   (* Y030: Khoi dong tu may lam lanh Chiller *)

(* Xuất mã lỗi 4-bit nhị phân ra Y024..Y027 (Single-Coil Paradigm) *)
do_ErrorCodeBit0          := (stOutputs.q_AlarmCodeBits = 1) OR (stOutputs.q_AlarmCodeBits = 3) 
                             OR (stOutputs.q_AlarmCodeBits = 5) OR (stOutputs.q_AlarmCodeBits = 7) 
                             OR (stOutputs.q_AlarmCodeBits = 9);    (* Y024: Bit 0 LED 7 doan / Den bao loi *)

do_ErrorCodeBit1          := (stOutputs.q_AlarmCodeBits = 2) OR (stOutputs.q_AlarmCodeBits = 3) 
                             OR (stOutputs.q_AlarmCodeBits = 6) OR (stOutputs.q_AlarmCodeBits = 7); (* Y025: Bit 1 LED 7 doan / Den bao loi *)

do_ErrorCodeBit2          := (stOutputs.q_AlarmCodeBits = 4) OR (stOutputs.q_AlarmCodeBits = 5) 
                             OR (stOutputs.q_AlarmCodeBits = 6) OR (stOutputs.q_AlarmCodeBits = 7); (* Y026: Bit 2 LED 7 doan / Den bao loi *)

do_ErrorCodeBit3          := (stOutputs.q_AlarmCodeBits = 8) OR (stOutputs.q_AlarmCodeBits = 9);  (* Y027: Bit 3 LED 7 doan / Den bao loi *)


(* ==============================================================================
   BƯỚC 5: XUẤT TELEMETRY RA CÁC THANH GHI D CHO HMI WEINTEK (D100..D105)
   ============================================================================== *)
hmi_MachineState          := INT_TO_WORD(stStatus.iStateCode);      (* D100: Trang thai van hanh den UV 0..5 *)
hmi_ActiveAlarmCode       := INT_TO_WORD(stAlarms.iActiveAlarmCode);(* D101: Ma so loi dang quet hien tai 1..9 *)
hmi_RemainingAfterCoolSec := stStatus.iAfterCoolRemainSec;          (* D105: So giay dem lui lam mat sau 180s *)

IF stOutputs.q_Lamp160W THEN
    hmi_PowerWatt := 160;                                           (* D103: Hien thi cong suat 160W *)
ELSIF stOutputs.q_Lamp120W THEN
    hmi_PowerWatt := 120;                                           (* D103: Hien thi cong suat 120W *)
ELSIF stOutputs.q_Lamp80W THEN
    hmi_PowerWatt := 80;                                            (* D103: Hien thi cong suat 80W *)
ELSE
    hmi_PowerWatt := 0;                                             (* D103: Den UV dang tat 0W *)
END_IF;

IF stOutputs.q_FanSpeed3 THEN
    hmi_FanSpeedStage := 3;                                         (* D104: Quat hut dang chay cap 3 (Turbo) *)
ELSIF stOutputs.q_FanSpeed2 THEN
    hmi_FanSpeedStage := 2;                                         (* D104: Quat hut dang chay cap 2 (Mid) *)
ELSIF stOutputs.q_FanSpeed1 THEN
    hmi_FanSpeedStage := 1;                                         (* D104: Quat hut dang chay cap 1 (Low) *)
ELSE
    hmi_FanSpeedStage := 0;                                         (* D104: Quat hut dang dung *)
END_IF;
