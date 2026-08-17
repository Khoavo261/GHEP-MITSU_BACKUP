(******************************************************************************)
(* CHƯƠNG TRÌNH 2: POU_ST_MATH (PHẦN ST CHUYÊN TRÁCH GIẢI THUẬT TOÁN HỌC & PID) *)
(* (DÁN VÀO CỬA SỔ POU -> Program -> POU_01)                                   *)
(******************************************************************************)

(* 0. KHỞI TẠO MẶC ĐỊNH & BẢO VỆ CHỐNG CHIA CHO 0 *)
IF Max_Speed_MPM <= 0 THEN Max_Speed_MPM := 1000; END_IF;
IF Core_Dia_T_mm <= 0 THEN Core_Dia_T_mm := 76; END_IF;
IF Core_Dia_M_mm <= 0 THEN Core_Dia_M_mm := 76; END_IF;
IF Core_Dia_U_mm <= 0 THEN Core_Dia_U_mm := 76; END_IF;
IF Max_Dia_M_mm  <= 0 THEN Max_Dia_M_mm  := 600; END_IF;
IF Max_Dia_U_mm  <= 0 THEN Max_Dia_U_mm  := 800; END_IF;

IF Speed_Ratio_Ms   <= 0 THEN Speed_Ratio_Ms   := 1000; END_IF; (* 100.0% *)
IF Dia_Ms_Roller_mm <= 0 THEN Dia_Ms_Roller_mm := 2000; END_IF; (* 200.0 mm *)
IF Dia_X2_Roller_mm <= 0 THEN Dia_X2_Roller_mm := 3005; END_IF; (* 300.5 mm *)
IF Decel_Distance_Meters <= 0 THEN Decel_Distance_Meters := 50; END_IF;

IF Ramp_Accel_Rate <= 0 THEN Ramp_Accel_Rate := 5; END_IF;
IF Ramp_Decel_Rate <= 0 THEN Ramp_Decel_Rate := 10; END_IF;
IF Release_Pen_Speed_MPM <= 0 THEN Release_Pen_Speed_MPM := 20; END_IF;

(* 1. NẠP LẠI ĐƯỜNG KÍNH KHI NẠP CUỘN MỚI TỪ HMI *)
IF HMI_Reset_Roll_T THEN Real_Dia_T_mm := Core_Dia_T_mm; HMI_Reset_Roll_T := FALSE; END_IF;
IF HMI_Reset_Roll_M THEN Real_Dia_M_mm := Max_Dia_M_mm;  HMI_Reset_Roll_M := FALSE; END_IF;
IF HMI_Reset_Roll_U THEN Real_Dia_U_mm := Max_Dia_U_mm;  HMI_Reset_Roll_U := FALSE; END_IF;

(* 2. TĂNG GIẢM TỐC LŨY TIẾN THEO THỜI GIAN GIỮ PHÍM INC (X54) / DEC (X55) *)
Cmd_Inc := HMI_Inc_Hold OR Physical_Inc_PB; (* Physical_Inc_PB = X54 trên QX40 *)
Cmd_Dec := HMI_Dec_Hold OR Physical_Dec_PB; (* Physical_Dec_PB = X55 trên QX40 *)

IF Cmd_Inc THEN
    Inc_Hold_Timer := Inc_Hold_Timer + 1;
    IF Inc_Hold_Timer < 50 THEN
        Dynamic_Accel_Step := Ramp_Accel_Rate;
    ELSIF Inc_Hold_Timer < 150 THEN
        Dynamic_Accel_Step := Ramp_Accel_Rate * 2;
    ELSE
        Dynamic_Accel_Step := Ramp_Accel_Rate * 5;
    END_IF;
    Target_Line_MPM := Target_Line_MPM + Dynamic_Accel_Step;
    IF Target_Line_MPM > Max_Speed_MPM THEN Target_Line_MPM := Max_Speed_MPM; END_IF;
ELSE
    Inc_Hold_Timer := 0;
END_IF;

IF Cmd_Dec THEN
    Dec_Hold_Timer := Dec_Hold_Timer + 1;
    IF Dec_Hold_Timer < 50 THEN
        Dynamic_Accel_Step := Ramp_Decel_Rate;
    ELSIF Dec_Hold_Timer < 150 THEN
        Dynamic_Accel_Step := Ramp_Decel_Rate * 2;
    ELSE
        Dynamic_Accel_Step := Ramp_Decel_Rate * 5;
    END_IF;
    Target_Line_MPM := Target_Line_MPM - Dynamic_Accel_Step;
    IF Target_Line_MPM < 0 THEN Target_Line_MPM := 0; END_IF;
ELSE
    Dec_Hold_Timer := 0;
END_IF;

(* 3. ĐIỀU KHIỂN TỐC ĐỘ THEO TRẠNG THÁI MÁY (M100 TỪ PHẦN LADDER) *)
IF HMI_Auto_Mode THEN
    IF M100 THEN (* M100: Máy đang chạy do mạch tự giữ Ladder điều khiển *)
        IF Current_Line_MPM < Target_Line_MPM THEN
            Current_Line_MPM := Current_Line_MPM + Ramp_Accel_Rate;
            IF Current_Line_MPM > Target_Line_MPM THEN Current_Line_MPM := Target_Line_MPM; END_IF;
        ELSIF Current_Line_MPM > Target_Line_MPM THEN
            Current_Line_MPM := Current_Line_MPM - Ramp_Decel_Rate;
            IF Current_Line_MPM < Target_Line_MPM THEN Current_Line_MPM := Target_Line_MPM; END_IF;
        END_IF;
    ELSE
        (* Khi máy dừng *)
        IF Current_Line_MPM > 0 THEN
            Current_Line_MPM := Current_Line_MPM - Ramp_Decel_Rate;
            IF Current_Line_MPM < 0 THEN Current_Line_MPM := 0; END_IF;
        END_IF;
    END_IF;
END_IF;

(* 4. ĐO ĐƯỜNG KÍNH CUỘN THU T THEO TỶ SỐ XUNG ENCODER QD62 *)
Curr_Pulse_T  := D500;
Curr_Pulse_X2 := D502;

IF Curr_Pulse_T < Last_Pulse_T THEN
    Last_Pulse_T := Curr_Pulse_T;
    Last_Pulse_X2_T := Curr_Pulse_X2;
END_IF;

IF (Curr_Pulse_T - Last_Pulse_T) >= 1000 THEN
    IF (Curr_Pulse_X2 - Last_Pulse_X2_T) > 0 THEN
        Raw_Dia_T_mm := (Dia_X2_Roller_mm * (Curr_Pulse_T - Last_Pulse_T)) / (Curr_Pulse_X2 - Last_Pulse_X2_T);
        IF Raw_Dia_T_mm >= Core_Dia_T_mm AND Raw_Dia_T_mm <= Max_Dia_T_mm THEN
            Real_Dia_T_mm := Real_Dia_T_mm + (Raw_Dia_T_mm - Real_Dia_T_mm) / 5;
        END_IF;
    END_IF;
    Last_Pulse_T := Curr_Pulse_T;
    Last_Pulse_X2_T := Curr_Pulse_X2;
END_IF;

(* 5. ĐO ĐƯỜNG KÍNH CUỘN XẢ M VÀ XẢ U BẰNG XUNG CẢM BIẾN TỪ LADDER (M160, M161) *)
IF M160 THEN (* Xung cảm biến X50 cuộn M từ phần Ladder *)
    Rev_Count_M := Rev_Count_M + 1;
    IF Rev_Count_M > 5 THEN
        IF (Curr_Pulse_X2 - Last_Pulse_X2_M) > 0 THEN
            Raw_Dia_M_mm := (Dia_X2_Roller_mm * 1000) / (Curr_Pulse_X2 - Last_Pulse_X2_M);
            IF Raw_Dia_M_mm >= Core_Dia_M_mm AND Raw_Dia_M_mm <= Max_Dia_M_mm THEN
                Real_Dia_M_mm := Real_Dia_M_mm + (Raw_Dia_M_mm - Real_Dia_M_mm) / 5;
            END_IF;
        END_IF;
    END_IF;
    Last_Pulse_X2_M := Curr_Pulse_X2;
END_IF;

IF M161 THEN (* Xung cảm biến X51 cuộn U từ phần Ladder *)
    Rev_Count_U := Rev_Count_U + 1;
    IF Rev_Count_U > 5 THEN
        IF (Curr_Pulse_X2 - Last_Pulse_X2_U) > 0 THEN
            Raw_Dia_U_mm := (Dia_X2_Roller_mm * 1000) / (Curr_Pulse_X2 - Last_Pulse_X2_U);
            IF Raw_Dia_U_mm >= Core_Dia_U_mm AND Raw_Dia_U_mm <= Max_Dia_U_mm THEN
                Real_Dia_U_mm := Real_Dia_U_mm + (Raw_Dia_U_mm - Real_Dia_U_mm) / 5;
            END_IF;
        END_IF;
    END_IF;
    Last_Pulse_X2_U := Curr_Pulse_X2;
END_IF;

(* 6. TÍNH TOÁN CÔN LỰC TAPER TENSION CUỘN THU T *)
IF (Max_Dia_T_mm - Core_Dia_T_mm) > 0 AND Taper_Percent_T > 0 THEN
    Effective_SP_T := SP_Tension_T - (((Real_Dia_T_mm - Core_Dia_T_mm) * SP_Tension_T * Taper_Percent_T) / ((Max_Dia_T_mm - Core_Dia_T_mm) * 100));
ELSE
    Effective_SP_T := SP_Tension_T;
END_IF;
IF Effective_SP_T < 0 THEN Effective_SP_T := 0; END_IF;

(* 7. THỰC THI 4 KHỐI PID LỰC CĂNG MỖI CHU KỲ 10MS (SM409) *)
Trig_PID_10ms := SM409 AND NOT(Prev_SM409);
Prev_SM409 := SM409;

IF Trig_PID_10ms THEN
    pid_T(Enable := HMI_PID_Enable, Setpoint := Effective_SP_T, Feedback := Weight_Net_T, Kp := Kp_T, Ki := Ki_T, Kd := Kd_T);
    pid_X1(Enable := HMI_PID_Enable, Setpoint := SP_Tension_X1, Feedback := Weight_Net_X1, Kp := Kp_X1, Ki := Ki_X1, Kd := Kd_X1);
    pid_M(Enable := HMI_PID_Enable, Setpoint := SP_Tension_M, Feedback := Weight_Net_M, Kp := Kp_M, Ki := Ki_M, Kd := Kd_M);
    pid_U(Enable := HMI_PID_Enable, Setpoint := SP_Tension_U, Feedback := Weight_Net_U, Kp := Kp_U, Ki := Ki_U, Kd := Kd_U);

    PID_Out_T  := pid_T.PID_Output;
    PID_Out_X1 := pid_X1.PID_Output;
    PID_Out_M  := pid_M.PID_Output;
    PID_Out_U  := pid_U.PID_Output;
END_IF;

(* 8. TÍNH TOÁN CÁC GIÁ TRỊ TỐC ĐỘ VÀ TORQUE TRỤC *)
Calc_Speed_X2 := (Current_Line_MPM * 4000) / Max_Speed_MPM;

IF NOT M100 THEN
    Calc_Speed_T  := 0;
    Calc_Speed_X1 := 0;
    IF Switch_Wash_Ms THEN Calc_Speed_Ms := (Anti_Dry_Crawl_Speed * 4000) / Max_Speed_MPM; ELSE Calc_Speed_Ms := 0; END_IF; (* X5A trên QX40 *)
    IF Switch_Wash_S  THEN Calc_Speed_S  := (Anti_Dry_Crawl_Speed * 4000) / Max_Speed_MPM; ELSE Calc_Speed_S  := 0; END_IF; (* X5B trên QX40 *)
    Calc_Speed_U  := 0;
    IF Switch_Hold_M  THEN Calc_Torque_M := Init_Holding_Torque_M; ELSE Calc_Torque_M := 0; END_IF;                        (* X58 trên QX40 *)
ELSE
    (* Khi máy đang chạy *)
    Calc_Speed_T  := (Calc_Speed_X2 * Real_Dia_T_mm) / Core_Dia_T_mm;
    Calc_Speed_X1 := Calc_Speed_X2 + PID_Out_X1;
    Calc_Speed_Ms := (Calc_Speed_X2 * Speed_Ratio_Ms) / 1000;
    Calc_Speed_S  := (Calc_Speed_X2 * Speed_Ratio_S)  / 1000 + Speed_Offset_S;
    Calc_Speed_U  := (Calc_Speed_X2 * Max_Dia_U_mm)  / Real_Dia_U_mm + PID_Out_U;

    (* 3 Pha Torque thắng M *)
    IF Rev_Count_M <= 5 THEN
        Base_Torque_M := Init_Holding_Torque_M;
    ELSE
        Base_Torque_M := Min_Torque_M + ((Max_Torque_M - Min_Torque_M) * (Real_Dia_M_mm - Core_Dia_M_mm)) / (Max_Dia_M_mm - Core_Dia_M_mm);
    END_IF;
    Calc_Torque_M := Base_Torque_M + PID_Out_M;
END_IF;

(* 9. THỰC THI FB CC-LINK MASTER XUẤT ÁP DAC *)
fbCCLink(
    Enable          := TRUE,
    ResetErr        := HMI_Reset_Error,
    Auto_Mode       := HMI_Auto_Mode,
    Set_Speed_T     := DINT_TO_WORD(Calc_Speed_T),
    Set_Torque_T    := DINT_TO_WORD(PID_Out_T),
    Set_Speed_X1    := DINT_TO_WORD(Calc_Speed_X1),
    Set_Speed_X2    := DINT_TO_WORD(Calc_Speed_X2),
    Set_Speed_Ms    := DINT_TO_WORD(Calc_Speed_Ms),
    Set_Torque_M    := DINT_TO_WORD(Calc_Torque_M),
    Set_Speed_S     := DINT_TO_WORD(Calc_Speed_S),
    Set_Speed_U     := DINT_TO_WORD(Calc_Speed_U)
);
