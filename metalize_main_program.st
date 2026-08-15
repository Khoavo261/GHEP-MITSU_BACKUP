(* ============================================================================ *)
(* MAIN PROGRAM: POU_MAIN_METALIZE (BỔ SUNG CHỐNG TRÙNG MÀNG & CHỐNG KHÔ KEO/DẦU S, Ms) *)
(* PLC: Q02UCPU | Base Rack Slot 0..6                                           *)
(* CỜ M130/M131: BẬT/TẮT TORQUE HÃM M & U KHI DỪNG MÁY CHỐNG TRÙNG MÀNG          *)
(* CỜ M132/M133: QUAY BÒ CHẬM TRỤC S & TRỤC Ms KHI DỪNG MÁY CHỐNG KHÔ KEO/DẦU  *)
(* ============================================================================ *)

VAR_GLOBAL
    (* --- BẢNG ĐIỀU KHIỂN HMI WEINTEK --- *)
    HMI_Auto_Mode       : BOOL := TRUE;
    HMI_Reset_Error     : BOOL := FALSE;
    HMI_Start           : BOOL := FALSE;
    HMI_Stop            : BOOL := FALSE;
    HMI_Inc_Hold        : BOOL := FALSE;
    HMI_Dec_Hold        : BOOL := FALSE;
    HMI_PID_Enable      : BOOL := TRUE;

    (* --- CỜ CHỐNG TRÙNG MÀNG KHI DỪNG MÁY (HOLD TORQUE WHEN STOPPED) --- *)
    Hold_Torque_Stop_M  : BOOL := TRUE;  (* ON: Giữ Torque Thắng M khi dừng chống trùng màng *)
    Hold_Torque_Stop_U  : BOOL := TRUE;  (* ON: Giữ Torque Xả U khi dừng chống trùng màng *)

    (* --- CỜ QUAY BÒ CHẬM CHỐNG KHÔ KEO / DẦU CHO TRỤC S & Ms KHI DỪNG MÁY --- *)
    Anti_Dry_Rotate_S   : BOOL := TRUE;  (* ON: Cho Trục Dầu S quay bò chậm khi dừng máy *)
    Anti_Dry_Rotate_Ms  : BOOL := TRUE;  (* ON: Cho Trục Ghép Ms quay bò chậm khi dừng máy *)
    Anti_Dry_Crawl_Speed: DINT := 10;    (* Tốc độ bò chậm chống khô keo (1.0 m/phút) *)

    (* --- LỆNH BEN NÂNG/HẠ CUỘN MÀNG --- *)
    Lift_Up_T           : BOOL := FALSE;
    Lift_Down_T         : BOOL := FALSE;
    Lift_Up_M           : BOOL := FALSE;
    Lift_Down_M         : BOOL := FALSE;
    Lift_Up_U           : BOOL := FALSE;
    Lift_Down_U         : BOOL := FALSE;

    (* --- ĐIỀU KHIỂN 2 PEN ÉP MÀNG QY40 (Y66, Y67) VÀ NÚT BẤM QX40 (X52, X53) --- *)
    Release_Pen_Speed_MPM: DINT := 20;   (* Tốc độ cài đặt nhả 2 pen khi dừng máy (2.0 m/phút) *)
    Pen1_Cmd            : BOOL := FALSE; (* Trạng thái ON/OFF Pen 1 (Y66) *)
    Pen2_Cmd            : BOOL := FALSE; (* Trạng thái ON/OFF Pen 2 (Y67) *)

    (* --- CÀI ĐẶT TORQUE HÃM MIN / MAX --- *)
    Min_Torque_M        : DINT := 400;
    Max_Torque_M        : DINT := 2000;
    Init_Holding_Torque_M : DINT := 800;

    Min_Torque_U        : DINT := 500;
    Max_Torque_U        : DINT := 2500;
    Init_Holding_Torque_U : DINT := 1000;

    (* --- ĐƯỜNG KÍNH LÕI CORE DIA VÀ MAX DIA (MM) --- *)
    Core_Dia_T_mm       : DINT := 76;
    Core_Dia_M_mm       : DINT := 76;
    Core_Dia_U_mm       : DINT := 76;

    Max_Dia_T_mm        : DINT := 1000;
    Max_Dia_M_mm        : DINT := 600;
    Max_Dia_U_mm        : DINT := 800;

    (* --- TỈ LỆ TỐC ĐỘ VÀ BÙ TỐC TRỤC S --- *)
    Speed_Ratio_S       : DINT := 1000;
    Speed_Offset_S      : DINT := 0;

    (* --- TỐC ĐỘ CÀI ĐẶT DÂY CHUYỀN --- *)
    Max_Speed_MPM       : DINT := 1000;
    Min_Speed_MPM       : DINT := 20;
    Current_Line_MPM    : DINT := 0;
    Target_Line_MPM     : DINT := 0;

    (* --- TỶ SỐ TRUYỀN GEAR RATIO --- *)
    Gear_Ratio_T        : DINT := 10100;
    Gear_Ratio_X1       : DINT := 8000;
    Gear_Ratio_X2       : DINT := 8000;
    Gear_Ratio_Ms       : DINT := 10000;
    Gear_Ratio_S        : DINT := 10000;
    Gear_Ratio_U        : DINT := 1000;

    (* --- ĐƯỜNG KÍNH LÔ CƠ CẤU (MM x10) --- *)
    Dia_X1_Roller_mm    : DINT := 3005;
    Dia_X2_Roller_mm    : DINT := 3005;
    Dia_Ms_Roller_mm    : DINT := 2000;
    Dia_S_Roller_mm     : DINT := 1000;

    (* --- ĐƯỜNG KÍNH THỰC TẾ ĐÃ ĐƯỢC LỌC THÔNG THẤP (MM) --- *)
    Real_Dia_T_mm       : DINT := 76;
    Real_Dia_M_mm       : DINT := 600;
    Real_Dia_U_mm       : DINT := 800;

    (* --- ĐỘ DÀY MÀNG (MICRON) --- *)
    Thick_Paper_U_um    : DINT := 60;
    Thick_Metalize_M_um : DINT := 20;

    (* --- MÉT HÀNG ĐÃ GHÉP VÀ MÉT CÀI ĐẶT TỰ DỪNG --- *)
    Set_Target_Length   : DINT := 1000;
    Total_Length_Meters : DINT := 0;
    HMI_Reset_Length    : BOOL := FALSE;
    HMI_Reset_Roll_M    : BOOL := FALSE;
    HMI_Reset_Roll_U    : BOOL := FALSE;
    HMI_Reset_Roll_T    : BOOL := FALSE;

    (* --- LỰC CĂNG SP VÀ CALIB --- *)
    SP_Tension_T        : DINT := 1500;
    SP_Tension_X1       : DINT := 1200;
    SP_Tension_M        : DINT := 1000;
    SP_Tension_U        : DINT := 1000;

    Kp_T : DINT := 150; Ki_T : DINT := 20; Kd_T : DINT := 10;
    Kp_X1: DINT := 120; Ki_X1: DINT := 15; Kd_X1: DINT := 8;
    Kp_M : DINT := 100; Ki_M : DINT := 10; Kd_M : DINT := 5;
    Kp_U : DINT := 100; Ki_U : DINT := 10; Kd_U : DINT := 5;

    Zero_Set_T          : BOOL := FALSE;
    Zero_Set_X1         : BOOL := FALSE;
    Zero_Set_M          : BOOL := FALSE;
    Zero_Set_U          : BOOL := FALSE;

    Calib_Gain_T        : DINT := 1000;
    Calib_Gain_X1       : DINT := 1000;
    Calib_Gain_M        : DINT := 1000;
    Calib_Gain_U        : DINT := 1000;
END_VAR

VAR
    State_Machine       : INT := 0;
    Tension_Stable      : BOOL := FALSE;
    Stable_Timer        : INT := 0;
    Stop_Delay_Timer    : INT := 0;

    Trig_X50            : BOOL := FALSE;
    Trig_X51            : BOOL := FALSE;
    Mem_X50             : BOOL := FALSE;
    Mem_X51             : BOOL := FALSE;

    Trig_X52            : BOOL := FALSE; (* Sườn nút bấm Pen 1 X52 *)
    Mem_X52             : BOOL := FALSE;
    Trig_X53            : BOOL := FALSE; (* Sườn nút bấm Pen 2 X53 *)
    Mem_X53             : BOOL := FALSE;

    Curr_Pulse_X2       : DINT := 0;
    Prev_Pulse_X2       : DINT := 0;
    Accum_Pulse_X2      : DINT := 0;

    Curr_Pulse_T        : DINT := 0;
    Prev_Pulse_T        : DINT := 0;
    Accum_Pulse_T       : DINT := 0;
    Rev_Count_T         : DINT := 0;
    Rev_Count_M         : DINT := 0;
    Rev_Count_U         : DINT := 0;

    (* BIẾN LƯU XUNG ĐỂ TÍNH ĐƯỜNG KÍNH THEO TỶ SỐ XUNG KHI MÁY CHẠY (KHÔNG DÙNG ĐỘ DÀY) *)
    Last_Pulse_X2_M     : DINT := 0;
    Last_Pulse_X2_U     : DINT := 0;
    Last_Pulse_X2_T     : DINT := 0;
    Last_Pulse_T        : DINT := 0;
    Delta_Pulse_M       : DINT := 0;
    Delta_Pulse_U       : DINT := 0;
    Delta_Pulse_T_Master: DINT := 0;

    Raw_Dia_M_mm        : DINT := 600;
    Raw_Dia_U_mm        : DINT := 800;
    Raw_Dia_T_mm        : DINT := 76;

    Calc_Speed_T        : DINT := 0;
    Calc_Speed_X1       : DINT := 0;
    Calc_Speed_X2       : DINT := 0;
    Calc_Speed_Ms       : DINT := 0;
    Calc_Torque_M       : DINT := 0;
    Calc_Speed_S        : DINT := 0;
    Calc_Speed_U        : DINT := 0;

    Base_Torque_M       : DINT := 0;

    pid_T               : FB_TENSION_PID;
    pid_X1              : FB_TENSION_PID;
    pid_M               : FB_TENSION_PID;
    pid_U               : FB_TENSION_PID;

    fbCCLink            : FFB_METALIZE_CONTROL;
END_VAR

(* ============================================================================ *)
(* MAIN LOGIC                                                                   *)
(* ============================================================================ *)

(* 1. ĐIỀU KHIỂN BEN NÂNG / HẠ CUỘN MÀNG T, M, U (QY40P SLOT 5 Y60..Y65) *)
Y60 := Lift_Up_T   AND NOT(Lift_Down_T);
Y61 := Lift_Down_T AND NOT(Lift_Up_T);

Y62 := Lift_Up_M   AND NOT(Lift_Down_M);
Y63 := Lift_Down_M AND NOT(Lift_Up_M);

Y64 := Lift_Up_U   AND NOT(Lift_Down_U);
Y65 := Lift_Down_U AND NOT(Lift_Up_U);

(* 1.1 ĐIỀU KHIỂN 2 PEN ÉP MÀNG QY40 (Y66, Y67) BẰNG 2 NÚT BẤM TOGGLE QX40 (X52, X53) *)
(* Bắt sườn lên sút nhấn X52 (Pen 1) và X53 (Pen 2) trên QX40 *)
Trig_X52 := X52 AND NOT(Mem_X52);
Mem_X52  := X52;

Trig_X53 := X53 AND NOT(Mem_X53);
Mem_X53  := X53;

(* Khi bấm nút X52: Đảo trạng thái Pen 1 (ON -> OFF / OFF -> ON) *)
IF Trig_X52 THEN
    Pen1_Cmd := NOT Pen1_Cmd;
END_IF;

(* Khi bấm nút X53: Đảo trạng thái Pen 2 (ON -> OFF / OFF -> ON) *)
IF Trig_X53 THEN
    Pen2_Cmd := NOT Pen2_Cmd;
END_IF;

(* TỰ ĐỘNG NHẢ 2 PEN KHI MÁY DỪNG ĐẾN TỐC ĐỘ CÀI ĐẶT (Release_Pen_Speed_MPM) *)
(* Khi dừng máy (State 3 Stopping hoặc State 0 Stopped) và tốc độ giảm xuống <= tốc độ cài đặt *)
IF (State_Machine = 3 OR State_Machine = 0) AND (Current_Line_MPM <= Release_Pen_Speed_MPM) THEN
    Pen1_Cmd := FALSE;
    Pen2_Cmd := FALSE;
END_IF;

(* Xuất ngõ ra QY40 *)
Y66 := Pen1_Cmd; (* Ngõ ra Pen 1 trên QY40 *)
Y67 := Pen2_Cmd; (* Ngõ ra Pen 2 trên QY40 *)

(* 2. BẮT SƯỜN LÊN CẢM BIẾN TIỆM CẬN ĐO VÒNG QUAY QX40 *)
Trig_X50 := X50 AND NOT(Mem_X50); (* X50: Cuộn Metalize M *)
Mem_X50  := X50;

Trig_X51 := X51 AND NOT(Mem_X51); (* X51: Cuộn Xả Giấy U *)
Mem_X51  := X51;

(* 3. TÍNH ĐƯỜNG KÍNH THỰC TẾ KHÔNG DÙNG ĐỘ DÀY CHO CUỘN METALIZE M (QX40 X50) *)
IF HMI_Reset_Roll_M THEN
    Rev_Count_M        := 0;
    Raw_Dia_M_mm       := Max_Dia_M_mm;
    Real_Dia_M_mm      := Max_Dia_M_mm;
    Last_Pulse_X2_M    := Curr_Pulse_X2;
    HMI_Reset_Roll_M   := FALSE;
ELSIF Trig_X50 THEN
    Rev_Count_M := Rev_Count_M + 1;
    Delta_Pulse_M := Curr_Pulse_X2 - Last_Pulse_X2_M;
    Last_Pulse_X2_M := Curr_Pulse_X2;

    IF Delta_Pulse_M > 0 THEN
        (* Công thức tỷ số xung Master X2 trong 1 vòng quay cuộn M *)
        Raw_Dia_M_mm := (Delta_Pulse_M * Dia_X2_Roller_mm) / 320000;
        IF Raw_Dia_M_mm < Core_Dia_M_mm THEN Raw_Dia_M_mm := Core_Dia_M_mm; END_IF;
        IF Raw_Dia_M_mm > Max_Dia_M_mm THEN Raw_Dia_M_mm := Max_Dia_M_mm; END_IF;
    END_IF;

    IF Rev_Count_M >= 3 THEN
        Real_Dia_M_mm := Real_Dia_M_mm + ((Raw_Dia_M_mm - Real_Dia_M_mm) / 5);
    ELSE
        Real_Dia_M_mm := Max_Dia_M_mm;
    END_IF;
END_IF;

(* 4. TÍNH ĐƯỜNG KÍNH THỰC TẾ KHÔNG DÙNG ĐỘ DÀY CHO CUỘN XẢ GIẤY U (QX40 X51) *)
IF HMI_Reset_Roll_U THEN
    Rev_Count_U        := 0;
    Raw_Dia_U_mm       := Max_Dia_U_mm;
    Real_Dia_U_mm      := Max_Dia_U_mm;
    Last_Pulse_X2_U    := Curr_Pulse_X2;
    HMI_Reset_Roll_U   := FALSE;
ELSIF Trig_X51 THEN
    Rev_Count_U := Rev_Count_U + 1;
    Delta_Pulse_U := Curr_Pulse_X2 - Last_Pulse_X2_U;
    Last_Pulse_X2_U := Curr_Pulse_X2;

    IF Delta_Pulse_U > 0 THEN
        (* Công thức tỷ số xung Master X2 trong 1 vòng quay cuộn U *)
        Raw_Dia_U_mm := (Delta_Pulse_U * Dia_X2_Roller_mm) / 320000;
        IF Raw_Dia_U_mm < Core_Dia_U_mm THEN Raw_Dia_U_mm := Core_Dia_U_mm; END_IF;
        IF Raw_Dia_U_mm > Max_Dia_U_mm THEN Raw_Dia_U_mm := Max_Dia_U_mm; END_IF;
    END_IF;

    IF Rev_Count_U >= 3 THEN
        Real_Dia_U_mm := Real_Dia_U_mm + ((Raw_Dia_U_mm - Real_Dia_U_mm) / 5);
    ELSE
        Real_Dia_U_mm := Max_Dia_U_mm;
    END_IF;
END_IF;

(* 5. TÍNH ĐƯỜNG KÍNH THỰC TẾ KHÔNG DÙNG ĐỘ DÀY CHO CUỘN THU T (ENCODER THU T / MASTER X2) *)
DMOV(TRUE, U1\G2, Curr_Pulse_T);

IF HMI_Reset_Roll_T THEN
    Accum_Pulse_T    := 0;
    Rev_Count_T      := 0;
    Raw_Dia_T_mm     := Core_Dia_T_mm;
    Real_Dia_T_mm    := Core_Dia_T_mm;
    Last_Pulse_X2_T  := Curr_Pulse_X2;
    Last_Pulse_T     := Curr_Pulse_T;
    HMI_Reset_Roll_T := FALSE;
ELSE
    (* Đếm khi cuộn Thu T quay đủ 1 vòng shaft (8000 ppr x 10.1 gear = 80,800 xung T) *)
    IF (Curr_Pulse_T - Last_Pulse_T) >= ((8000 * Gear_Ratio_T) / 1000) THEN
        Rev_Count_T := Rev_Count_T + 1;
        Delta_Pulse_T_Master := Curr_Pulse_X2 - Last_Pulse_X2_T;
        Last_Pulse_X2_T := Curr_Pulse_X2;
        Last_Pulse_T    := Curr_Pulse_T;

        IF Delta_Pulse_T_Master > 0 THEN
            Raw_Dia_T_mm := (Delta_Pulse_T_Master * Dia_X2_Roller_mm) / 320000;
            IF Raw_Dia_T_mm < Core_Dia_T_mm THEN Raw_Dia_T_mm := Core_Dia_T_mm; END_IF;
            IF Raw_Dia_T_mm > Max_Dia_T_mm THEN Raw_Dia_T_mm := Max_Dia_T_mm; END_IF;
        END_IF;

        IF Rev_Count_T >= 3 THEN
            Real_Dia_T_mm := Real_Dia_T_mm + ((Raw_Dia_T_mm - Real_Dia_T_mm) / 5);
        ELSE
            Real_Dia_T_mm := Core_Dia_T_mm;
        END_IF;
    END_IF;
END_IF;

(* 6. ĐO TỔNG CHIỀU DÀI MÉT HÀNG VÀ TỰ ĐỘNG DỪNG KHI ĐẠT TARGET *)
DMOV(TRUE, U2\G2, Curr_Pulse_X2);

IF HMI_Reset_Length THEN
    Accum_Pulse_X2      := 0;
    Total_Length_Meters := 0;
    HMI_Reset_Length    := FALSE;
ELSE
    IF Curr_Pulse_X2 >= Prev_Pulse_X2 THEN Accum_Pulse_X2 := Accum_Pulse_X2 + (Curr_Pulse_X2 - Prev_Pulse_X2); END_IF;
    Prev_Pulse_X2 := Curr_Pulse_X2;
    Total_Length_Meters := (Accum_Pulse_X2 * 944) / 8000000;
END_IF;

(* 7. STATE MACHINE VẬN HÀNH DÂY CHUYỀN (START / STOP / INC / DEC) *)
CASE State_Machine OF
    0: (* STATE_STOPPED *)
        Current_Line_MPM := 0;
        Target_Line_MPM  := 0;
        Tension_Stable   := FALSE;
        Stable_Timer     := 0;
        Stop_Delay_Timer := 0;

        (* CHẾ ĐỘ XỬ LÝ KHI DỪNG MÁY: CHỐNG TRÙNG MÀNG VÀ CHỐNG KHÔ KEO/DẦU S, Ms *)
        M200 := FALSE; (* Servo OFF Thu T *)
        M201 := FALSE; (* Servo OFF X1 *)
        M202 := FALSE; (* Servo OFF Master X2 *)

        (* BẬT SERVO BÒ CHẬM KHI DỪNG MÁY CHO S VÀ Ms NẾU CỜ M132 / M133 BẬT *)
        M203 := Anti_Dry_Rotate_Ms; (* Servo ON Ms quay bò chậm chống khô keo *)
        M204 := Anti_Dry_Rotate_S;  (* Servo ON S quay bò chậm chống khô dầu *)

        IF HMI_Start THEN
            State_Machine := 1;
            HMI_Start     := FALSE;
        END_IF;

    1: (* STATE_STARTUP_MIN *)
        M200 := TRUE; M201 := TRUE; M202 := TRUE; M203 := TRUE; M204 := TRUE;
        Target_Line_MPM := Min_Speed_MPM;

        IF Current_Line_MPM < Target_Line_MPM THEN Current_Line_MPM := Current_Line_MPM + 2; END_IF;

        Stable_Timer := Stable_Timer + 1;
        IF Stable_Timer >= 200 THEN
            Tension_Stable := TRUE;
            State_Machine  := 2;
        END_IF;

        IF HMI_Stop THEN State_Machine := 3; HMI_Stop := FALSE; END_IF;

    2: (* STATE_RUNNING *)
        M200 := TRUE; M201 := TRUE; M202 := TRUE; M203 := TRUE; M204 := TRUE;

        IF HMI_Inc_Hold THEN
            Target_Line_MPM := Target_Line_MPM + 5;
            IF Target_Line_MPM > Max_Speed_MPM THEN Target_Line_MPM := Max_Speed_MPM; END_IF;
        ELSIF HMI_Dec_Hold THEN
            Target_Line_MPM := Target_Line_MPM - 5;
            IF Target_Line_MPM < Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
        END_IF;

        IF Current_Line_MPM < Target_Line_MPM THEN Current_Line_MPM := Current_Line_MPM + 3;
        ELSIF Current_Line_MPM > Target_Line_MPM THEN Current_Line_MPM := Current_Line_MPM - 3; END_IF;

        IF (Set_Target_Length > 0 AND Total_Length_Meters >= Set_Target_Length) OR HMI_Stop THEN
            State_Machine := 3;
            HMI_Stop      := FALSE;
        END_IF;

    3: (* STATE_STOPPING *)
        Target_Line_MPM := Min_Speed_MPM;

        IF Current_Line_MPM > Min_Speed_MPM THEN
            Current_Line_MPM := Current_Line_MPM - 4;
            IF Current_Line_MPM < Min_Speed_MPM THEN Current_Line_MPM := Min_Speed_MPM; END_IF;
        ELSE
            Stop_Delay_Timer := Stop_Delay_Timer + 1;
            IF Stop_Delay_Timer >= 200 THEN
                State_Machine := 0;
            END_IF;
        END_IF;
END_CASE;

(* 8. TÍNH BỘ PID LỰC CĂNG CHO T, X1, M (Thắng Từ) VÀ U *)
pid_T(Enable := HMI_PID_Enable, Setpoint := SP_Tension_T, Feedback := fbCCLink.Weight_Net_T, Kp := Kp_T, Ki := Ki_T, Kd := Kd_T);
pid_X1(Enable := HMI_PID_Enable, Setpoint := SP_Tension_X1, Feedback := fbCCLink.Weight_Net_X1, Kp := Kp_X1, Ki := Ki_X1, Kd := Kd_X1);
pid_M(Enable := HMI_PID_Enable, Setpoint := SP_Tension_M, Feedback := fbCCLink.Weight_Net_M, Kp := Kp_M, Ki := Ki_M, Kd := Kd_M);
pid_U(Enable := HMI_PID_Enable, Setpoint := SP_Tension_U, Feedback := fbCCLink.Weight_Net_U, Kp := Kp_U, Ki := Ki_U, Kd := Kd_U);

(* Quy đổi Tốc độ m/phút sang dải 0..4000 DAC *)
Calc_Speed_X2 := (Current_Line_MPM * 4000) / Max_Speed_MPM;

IF State_Machine = 0 THEN
    (* XỬ LÝ TỐC ĐỘ VÀ TORQUE KHI DỪNG MÁY (STATE_MACHINE = 0) *)
    Calc_Speed_T  := 0;
    Calc_Speed_X1 := 0;

    (* BÒ CHẬM TRỤC Ms NẾU BẬT CỜ M133 *)
    IF Anti_Dry_Rotate_Ms THEN
        Calc_Speed_Ms := (Anti_Dry_Crawl_Speed * 4000) / Max_Speed_MPM; (* Chạy bò chậm (1.0 m/p) *)
    ELSE
        Calc_Speed_Ms := 0;
    END_IF;

    (* BÒ CHẬM TRỤC S NẾU BẬT CỜ M132 *)
    IF Anti_Dry_Rotate_S THEN
        Calc_Speed_S := (Anti_Dry_Crawl_Speed * 4000) / Max_Speed_MPM; (* Chạy bò chậm (1.0 m/p) *)
    ELSE
        Calc_Speed_S := 0;
    END_IF;

    (* GIỮ TORQUE HÃM THẮNG M KHI DỪNG CHỐNG TRÙNG MÀNG NẾU BẬT CỜ M130 *)
    IF Hold_Torque_Stop_M THEN
        Calc_Torque_M := Base_Torque_M;
    ELSE
        Calc_Torque_M := 0;
    END_IF;

    (* GIỮ TORQUE XẢ U KHI DỪNG CHỐNG TRÙNG MÀNG NẾU BẬT CỜ M131 *)
    IF Hold_Torque_Stop_U THEN
        Calc_Speed_U := Init_Holding_Torque_U;
    ELSE
        Calc_Speed_U := 0;
    END_IF;
ELSE
    (* CHẠY TỰ ĐỘNG BÌNH THƯỜNG KHI MÁY ĐANG CHẠY *)
    IF Real_Dia_T_mm > 0 THEN Calc_Speed_T := ((Calc_Speed_X2 * Real_Dia_T_mm) / Core_Dia_T_mm) + pid_T.PID_Output; ELSE Calc_Speed_T := Calc_Speed_X2 + pid_T.PID_Output; END_IF;
    Calc_Speed_X1 := Calc_Speed_X2 + pid_X1.PID_Output;
    Calc_Speed_Ms := Calc_Speed_X2;
    Calc_Speed_S  := ((Calc_Speed_X2 * Speed_Ratio_S) / 1000) + Speed_Offset_S;
    IF Real_Dia_U_mm > 0 THEN Calc_Speed_U := ((Calc_Speed_X2 * Max_Dia_U_mm) / Real_Dia_U_mm) + pid_U.PID_Output; ELSE Calc_Speed_U := Calc_Speed_X2 + pid_U.PID_Output; END_IF;

    IF Rev_Count_M < 5 THEN
        Base_Torque_M := Init_Holding_Torque_M;
    ELSE
        IF (Max_Dia_M_mm - Core_Dia_M_mm) > 0 THEN
            Base_Torque_M := Min_Torque_M + (((Real_Dia_M_mm - Core_Dia_M_mm) * (Max_Torque_M - Min_Torque_M)) / (Max_Dia_M_mm - Core_Dia_M_mm));
        ELSE
            Base_Torque_M := Min_Torque_M;
        END_IF;
    END_IF;

    Calc_Torque_M := Base_Torque_M + pid_M.PID_Output;
END_IF;

(* Ép biên an toàn *)
IF Calc_Speed_T  < 0 THEN Calc_Speed_T  := 0; ELSIF Calc_Speed_T  > 4000 THEN Calc_Speed_T  := 4000; END_IF;
IF Calc_Speed_X1 < 0 THEN Calc_Speed_X1 := 0; ELSIF Calc_Speed_X1 > 4000 THEN Calc_Speed_X1 := 4000; END_IF;
IF Calc_Speed_Ms < 0 THEN Calc_Speed_Ms := 0; ELSIF Calc_Speed_Ms > 4000 THEN Calc_Speed_Ms := 4000; END_IF;
IF Calc_Torque_M < 0 THEN Calc_Torque_M := 0; ELSIF Calc_Torque_M > 4000 THEN Calc_Torque_M := 4000; END_IF;
IF Calc_Speed_S  < 0 THEN Calc_Speed_S  := 0; ELSIF Calc_Speed_S  > 4000 THEN Calc_Speed_S  := 4000; END_IF;
IF Calc_Speed_U  < 0 THEN Calc_Speed_U  := 0; ELSIF Calc_Speed_U  > 4000 THEN Calc_Speed_U  := 4000; END_IF;

D600 := INT_TO_WORD(Calc_Speed_T);
D601 := INT_TO_WORD(pid_T.PID_Output);
D602 := INT_TO_WORD(Calc_Speed_X1);
D603 := INT_TO_WORD(Calc_Speed_X2);
D604 := INT_TO_WORD(Calc_Speed_Ms);
D605 := INT_TO_WORD(Calc_Torque_M);
D606 := INT_TO_WORD(Calc_Speed_S);
D607 := INT_TO_WORD(Calc_Speed_U);

fbCCLink(
    Enable          := TRUE,
    ResetErr        := HMI_Reset_Error,
    Auto_Mode       := HMI_Auto_Mode,

    Zero_Set_T      := Zero_Set_T,
    Zero_Set_X1     := Zero_Set_X1,
    Zero_Set_M      := Zero_Set_M,
    Zero_Set_U      := Zero_Set_U,

    Calib_Gain_T    := Calib_Gain_T,
    Calib_Gain_X1   := Calib_Gain_X1,
    Calib_Gain_M    := Calib_Gain_M,
    Calib_Gain_U    := Calib_Gain_U,

    Set_Speed_T     := D600,
    Set_Torque_T    := D601,
    Set_Speed_X1    := D602,
    Set_Speed_X2    := D603,
    Set_Speed_Ms    := D604,
    Set_Torque_M    := D605,
    Set_Speed_S     := D606,
    Set_Speed_U     := D607,

    Auto_Son_T      := M200,
    Auto_Son_X1     := M201,
    Auto_Son_X2     := M202,
    Auto_Son_M      := M203,
    Auto_Son_S      := M204,

    Test_Son_T      := M210,
    Test_Son_X1     := M211,
    Test_Son_X2     := M212,
    Test_Son_M      := M213,
    Test_Son_S      := M214,

    Test_Speed_T    := D610,
    Test_Speed_X1   := D611,
    Test_Speed_X2   := D612,
    Test_Speed_Ms   := D613,
    Test_Torque_M   := D614,
    Test_Speed_S    := D615,
    Test_Speed_U    := D616
);
