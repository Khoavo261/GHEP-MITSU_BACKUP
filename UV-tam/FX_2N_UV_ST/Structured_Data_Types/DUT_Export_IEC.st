(* ==============================================================================
   CHUẨN IEC 61131-3 STRUCTURED DATA TYPES (DUT / STRUCT)
   Dùng cho: Mitsubishi GX Works2 (Structured Data Types), ABB Automation Builder,
             CoDeSys V2.3/V3.5, Schneider EcoStruxure, Beckhoff TwinCAT, Siemens TIA Portal
   ============================================================================== *)

(* 1. Cấu trúc tín hiệu điều khiển từ nút nhấn / HMI *)
TYPE ST_UV_Commands :
STRUCT
    bStart          : BOOL; (* Lenh khoi dong chu trinh UV (X020 / HMI) *)
    bStop           : BOOL; (* Lenh dung he thong (X021 / HMI) - vao chu trinh 180s lam mat *)
    bSelect80W      : BOOL; (* Che do cong suat 80W (X027 / HMI) *)
    bSelect120W     : BOOL; (* Che do cong suat 120W (X023 / HMI) *)
    bSelect160W     : BOOL; (* Che do cong suat 160W Turbo (X024 / HMI) *)
    bBuzzerStop     : BOOL; (* Lenh tat chuong bao dong (X026 / HMI) *)
    bResetFault     : BOOL; (* Lenh xoa loi / Reset he thong (HMI) *)
END_STRUCT
END_TYPE

(* 2. Cấu trúc cảm biến vật lý & liên động an toàn phần cứng *)
TYPE ST_UV_Sensors :
STRUCT
    di_LampVoltageLow       : BOOL; (* X001: Ap thap chan luu Ballast (T1 filter) *)
    di_LampVoltageHigh      : BOOL; (* X002: Ap cao chan luu Ballast *)
    di_OverTempTrip         : BOOL; (* X003: Su co qua nhiet buong say UV *)
    di_PowerCabinetDoorClosed: BOOL; (* X004: Cua tu dien dong an toan *)
    di_SafetyDoorClosed     : BOOL; (* X005: Cua buong say / cap phoi dong *)
    di_MainLineRunning      : BOOL; (* X006: Tin hieu may in / bang tai chinh dang chay *)
    di_AirFlowSw            : BOOL; (* X011: Cong tac luu luong gio hut *)
    di_ShutterOpenLimit     : BOOL; (* X012: Cong tac hanh trinh Shutter Mo *)
    di_ShutterClosedLimit   : BOOL; (* X013: Cong tac hanh trinh Shutter Dong *)
    di_DamperPos1Sw         : BOOL; (* X014: Sensor vi tri 1 kich hoat Mo Damper 1 *)
    di_DamperPos2Sw         : BOOL; (* X015: Sensor vi tri 2 kich hoat Mo Damper 2 *)
    di_ChillerTrip          : BOOL; (* X016: Su co Chiller nuoc lam mat *)
    di_WaterFlowSw          : BOOL; (* X017: Cong tac luu luong nuoc lam mat *)
    di_AirPressureSw        : BOOL; (* X022: Cong tac ap suat gio buong say *)
END_STRUCT
END_TYPE

(* 3. Cấu trúc trạng thái vận hành & giám sát hệ thống *)
TYPE ST_UV_Status :
STRUCT
    bWarmupActive       : BOOL; (* Dang trong giai doan say nong 30s ban dau *)
    bLampStabilized     : BOOL; (* Den da say nong on dinh (M540) *)
    bAfterCoolActive    : BOOL; (* Dang trong chu trinh lam mat sau khi tat 180s (M560) *)
    bSystemReady        : BOOL; (* He thong san sang hoat dong (khong co loi, du dieu kien) *)
    iStateCode          : INT;  (* 0:OFF, 1:WARMUP_80W, 2:RUN_80W, 3:RUN_120W, 4:RUN_160W, 5:AFTER_COOL *)
    iWarmupRemainSec    : INT;  (* Thoi gian con lai say nong 30s (dem nguoc ve 0) *)
    iAfterCoolRemainSec : INT;  (* Thoi gian con lai lam mat 180s (dem nguoc ve 0) *)
END_STRUCT
END_TYPE

(* 4. Cấu trúc 9 sự cố và mã quét lỗi cảnh báo *)
TYPE ST_UV_Alarms :
STRUCT
    bBallastFault       : BOOL; (* Loi 1: Dien ap chan luu Ballast T1 (5s) *)
    bAirPressureFault   : BOOL; (* Loi 2: Ap suat gio buong say T11 (5s) *)
    bDoorOpenFault      : BOOL; (* Loi 3: Mo cua an toan tu say X004 *)
    bAirFlowFault       : BOOL; (* Loi 4: Luu luong gio hut buong say X011 *)
    bWaterFlowFault     : BOOL; (* Loi 5: Dong chay nuoc lam mat T41 (15s) *)
    bShutterFault       : BOOL; (* Loi 6: Ket hanh trinh Shutter T21 (5s) *)
    bChillerFault       : BOOL; (* Loi 7: Qua tai / Trip may Chiller T101 (10s) *)
    bOverTempFault      : BOOL; (* Loi 8: Qua nhiet buong say X003 *)
    bLampLifeExpired    : BOOL; (* Canh bao 9: Het tuoi tho bong den UV T120 (5s) *)
    bSystemAlarm        : BOOL; (* Tong hop co su co toan he thong (M180) *)
    iActiveAlarmCode    : INT;  (* Ma loi dang quet hien tai (1..9) gui HMI / 4-bit Output *)
END_STRUCT
END_TYPE

(* 5. Cấu trúc xuất tín hiệu chấp hành (Actuators / Coils) *)
TYPE ST_UV_Outputs :
STRUCT
    q_Lamp80W           : BOOL; (* Y002: Khoi dong tu bat den 80W / Warmup *)
    q_Lamp120W          : BOOL; (* Y003: Khoi dong tu tang ap 120W *)
    q_Lamp160W          : BOOL; (* Y004: Khoi dong tu Turbo 160W *)
    q_Damper1           : BOOL; (* Y005: Mo van gio hut buong say 1 *)
    q_Damper2           : BOOL; (* Y006: Mo van gio hut buong say 2 *)
    q_ShutterSolenoid   : BOOL; (* Y007: Mo Shutter che UV cho tia chieu xuong vat *)
    q_FanMain           : BOOL; (* Y010: Quat hut tong buong say *)
    q_FanSpeed1         : BOOL; (* Y011: Quat hut cap toc do 1 (Low) *)
    q_FanSpeed2         : BOOL; (* Y012: Quat hut cap toc do 2 (Mid) *)
    q_FanSpeed3         : BOOL; (* Y013: Quat hut cap toc do 3 (High / Turbo) *)
    q_Chiller           : BOOL; (* Y030: May lam lanh nuoc tuan hoan *)
    q_Buzzer            : BOOL; (* Y023: Coi bao dong su co *)
    q_AlarmCodeBits     : INT;  (* K1Y024: 4-bit ma loi (0..9) xuat ra den/PLC ngoai *)
END_STRUCT
END_TYPE
