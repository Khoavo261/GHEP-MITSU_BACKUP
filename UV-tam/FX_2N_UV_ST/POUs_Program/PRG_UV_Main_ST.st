(* ==============================================================================
   PROGRAM MAIN: PRG_UV_Main (CHUẨN STRUCTURED DATA TYPES)
   GX Works2: Dán vào cửa sổ Program [ST] của PRG_UV_Main
   Khớp 100% với các biến trong Global_Labels.tsv đã nạp
   (Chuẩn Function Block Macrocode của Mitsubishi GX Works2: dùng ':=' cho cả Input và Output)
   ============================================================================== *)

(* ==============================================================================
   BƯỚC 1: HARDWARE INGRESS (ÁNH XẠ GLOBAL LABELS VÀO CÁC STRUCT)
   ============================================================================== *)

(* 1.1 Cảm biến & liên động phần cứng (stSensors) *)
stSensors.di_LampVoltageLow        := di_LampVoltageLow;           (* X001 *)
stSensors.di_LampVoltageHigh       := di_LampVoltageHigh;          (* X002 *)
stSensors.di_OverTempTrip          := di_EStop;                    (* X003 *)

(* X004: Thuong dong an toan cua tu dien *)
IF di_CabinetDoorOpen THEN
    stSensors.di_PowerCabinetDoorClosed := FALSE;
ELSE
    stSensors.di_PowerCabinetDoorClosed := TRUE;
END_IF;

stSensors.di_SafetyDoorClosed      := di_InfeedDoorClosed;         (* X005 *)
stSensors.di_MainLineRunning       := di_MainMachineRunning;       (* X006 *)
stSensors.di_AirFlowSw             := di_ChamberLTS;               (* X011 *)
stSensors.di_ShutterOpenLimit      := di_ShutterOpenLimit;         (* X012 *)
stSensors.di_ShutterClosedLimit    := di_ShutterClosedLimit;       (* X013 *)
stSensors.di_DamperPos1Sw          := di_ChamberPos1;              (* X014 *)
stSensors.di_DamperPos2Sw          := di_ChamberPos2;              (* X015 *)
stSensors.di_ChillerTrip           := di_ChillerFaultSig;          (* X031 *)
stSensors.di_WaterFlowSw           := di_WaterFlowSw;              (* X016 *)
stSensors.di_AirPressureSw         := di_AirPressureSw;            (* X010 *)

(* 1.2 Nút nhấn vật lý & Lệnh HMI (stCommands) *)
stCommands.bStart      := di_BtnLampOn;                            (* X020 *)
stCommands.bStop       := di_BtnLampOff;                           (* X021 *)
stCommands.bSelect80W  := di_SwPower80W;                           (* X027 *)

(* Mac dinh 120W khi khong gat 80W va khong gat 160W *)
IF di_SwPower80W OR di_SwPower160W THEN
    stCommands.bSelect120W := FALSE;
ELSE
    stCommands.bSelect120W := TRUE;
END_IF;

stCommands.bSelect160W := di_SwPower160W;                          (* X024 *)
stCommands.bBuzzerStop := di_BtnBuzzerStop;                        (* X022 *)
stCommands.bResetFault := di_BtnFaultReset;                        (* X023 *)


(* ==============================================================================
   BƯỚC 2: THỰC THI FB ĐIỀU KHIỂN CHU TRÌNH ĐÈN UV, QUẠT, CHILLER
   (Macrocode FB: truyền cả biến Input và biến Output vào qua toán tử ':=')
   ============================================================================== *)
fbCuringUnit(
    stCmd                 := stCommands,
    stSensors             := stSensors,
    bSystemAlarm          := stAlarms.bSystemAlarm,
    stOutputs             := stOutputs,
    stStatus              := stStatus
);


(* ==============================================================================
   BƯỚC 3: THỰC THI FB QUẢN LÝ 9 SỰ CỐ & QUÉT MÃ LỖI (ALARM MANAGER)
   ============================================================================== *)
fbAlarmManager(
    stSensors             := stSensors,
    stCmd                 := stCommands,
    bLamp80WActive        := stOutputs.q_Lamp80W,
    bLampStabilized       := stStatus.bLampStabilized,
    bShutterSolenoid      := stOutputs.q_ShutterSolenoid,
    bLampIgnited          := stOutputs.q_Lamp80W,
    bLampHourMeterExpired := FALSE,
    stAlarms              := stAlarms,
    q_Buzzer              := stOutputs.q_Buzzer,
    stOutputs_AlarmBits   := stOutputs.q_AlarmCodeBits
);


(* ==============================================================================
   BƯỚC 4: HARDWARE EGRESS (XUẤT RA GLOBAL LABELS VẬT LÝ Y)
   ============================================================================== *)
do_MasterAlarm       := stAlarms.bSystemAlarm;          (* Y000 *)
do_Buzzer            := stOutputs.q_Buzzer;             (* Y001 *)
do_LampPower80W      := stOutputs.q_Lamp80W;            (* Y002 *)
do_LampPower120W     := stOutputs.q_Lamp120W;           (* Y003 *)
do_LampPower160W     := stOutputs.q_Lamp160W;           (* Y004 *)
do_ExhaustDamper1    := stOutputs.q_Damper1;            (* Y005 *)
do_ExhaustDamper2    := stOutputs.q_Damper2;            (* Y006 *)
do_ShutterValve      := stOutputs.q_ShutterSolenoid;    (* Y007 *)
do_ExhaustFan        := stOutputs.q_FanMain;            (* Y010 *)
do_FanSpeedStage1    := stOutputs.q_FanSpeed1;          (* Y011 *)
do_FanSpeedStage2    := stOutputs.q_FanSpeed2;          (* Y012 *)
do_FanSpeedStage3    := stOutputs.q_FanSpeed3;          (* Y013 *)
do_ChillerCommand    := stOutputs.q_Chiller;            (* Y030 *)

(* Xuất mã lỗi 4-bit nhị phân ra Y024..Y027 (Single-Coil Paradigm triệt tiêu cảnh báo double-coil) *)
do_ErrorCodeBit0 := (stOutputs.q_AlarmCodeBits = 1) OR (stOutputs.q_AlarmCodeBits = 3) 
                    OR (stOutputs.q_AlarmCodeBits = 5) OR (stOutputs.q_AlarmCodeBits = 7) 
                    OR (stOutputs.q_AlarmCodeBits = 9);

do_ErrorCodeBit1 := (stOutputs.q_AlarmCodeBits = 2) OR (stOutputs.q_AlarmCodeBits = 3) 
                    OR (stOutputs.q_AlarmCodeBits = 6) OR (stOutputs.q_AlarmCodeBits = 7);

do_ErrorCodeBit2 := (stOutputs.q_AlarmCodeBits = 4) OR (stOutputs.q_AlarmCodeBits = 5) 
                    OR (stOutputs.q_AlarmCodeBits = 6) OR (stOutputs.q_AlarmCodeBits = 7);

do_ErrorCodeBit3 := (stOutputs.q_AlarmCodeBits = 8) OR (stOutputs.q_AlarmCodeBits = 9);


(* ==============================================================================
   BƯỚC 5: XUẤT TELEMETRY RA CÁC THANH GHI D CHO HMI WEINTEK (D100..D105)
   ============================================================================== *)
hmi_MachineState          := INT_TO_WORD(stStatus.iStateCode);
hmi_ActiveAlarmCode       := INT_TO_WORD(stAlarms.iActiveAlarmCode);
hmi_RemainingAfterCoolSec := stStatus.iAfterCoolRemainSec;

IF stOutputs.q_Lamp160W THEN
    hmi_PowerWatt := 160;
ELSIF stOutputs.q_Lamp120W THEN
    hmi_PowerWatt := 120;
ELSIF stOutputs.q_Lamp80W THEN
    hmi_PowerWatt := 80;
ELSE
    hmi_PowerWatt := 0;
END_IF;

IF stOutputs.q_FanSpeed3 THEN
    hmi_FanSpeedStage := 3;
ELSIF stOutputs.q_FanSpeed2 THEN
    hmi_FanSpeedStage := 2;
ELSIF stOutputs.q_FanSpeed1 THEN
    hmi_FanSpeedStage := 1;
ELSE
    hmi_FanSpeedStage := 0;
END_IF;
