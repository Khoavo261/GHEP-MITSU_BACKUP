(* ============================================================================ *)
(* MÃ NGUỒN POU_01: HỆ THỐNG MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - MITSUBISHI Q02U  *)
(* ĐỒNG BỘ VẬN TỐC DÀI THEO TRỤC CHÍNH X2 + SPEED_RATIO CHO TỪNG TRỤC           *)
(* TOÀN BỘ TÍNH TOÁN DÙNG CHUẨN SỐ THỰC FLOAT / REAL (FLOAT [Single Precision]) *)
(* ============================================================================ *)

(* 1. BẢO VỆ 5 TRỤC SERVO READY TRÊN MODULE 16DT (X0..X4 = M1104..M1108) *)
Servo_Not_Ready_Fault := NOT(Servo_Ready_T) OR NOT(Servo_Ready_X1) OR NOT(Servo_Ready_X2) OR NOT(Servo_Ready_Ms) OR NOT(Servo_Ready_S);

IF Servo_Not_Ready_Fault AND State_Machine = 1 THEN
    State_Machine := 0; (* Dừng khẩn cấp nếu đang chạy tự động *)
END_IF;

(* 2. ĐIỀU KHIỂN CÔNG TẮC GIỮ TORQUE & BÒ CHẬM RỬA MÁY TRÊN QX40 (X58..X5B) *)
Hold_Torque_Stop_M := Switch_Hold_M;   (* X58 *)
Hold_Torque_Stop_U := Switch_Hold_U;   (* X59 *)
Anti_Dry_Rotate_Ms := Switch_Wash_Ms;  (* X5A *)
Anti_Dry_Rotate_S  := Switch_Wash_S;   (* X5B *)

(* 3. NẠP LẠI ĐƯỜNG KÍNH CUỘN TỪ HMI *)
IF HMI_Reset_Roll_T THEN Real_Dia_T_mm := Core_Dia_T_mm; HMI_Reset_Roll_T := FALSE; END_IF;
IF HMI_Reset_Roll_M THEN Real_Dia_M_mm := Max_Dia_M_mm;  HMI_Reset_Roll_M := FALSE; END_IF;
IF HMI_Reset_Roll_U THEN Real_Dia_U_mm := Max_Dia_U_mm;  HMI_Reset_Roll_U := FALSE; END_IF;

(* 4. TỔNG HỢP NÚT NHẤN HMI & NÚT NHẤN VẬT LÝ TRÊN QX40 (X52..X55) *)
Cmd_Start := HMI_Start OR Physical_Start_PB;
Cmd_Stop  := HMI_Stop OR Physical_Stop_PB OR Servo_Not_Ready_Fault;
Cmd_Inc   := HMI_Inc_Hold OR Physical_Inc_PB;
Cmd_Dec   := HMI_Dec_Hold OR Physical_Dec_PB;

(* 5. ĐIỀU KHIỂN TOGGLE 2 PEN ÉP MÀNG (QX40 X56/X57 HOẶC 16DT X5/X6) *)
Trig_Pen1 := (Pen1_Toggle_PB AND NOT(Prev_Pen1_PB)) OR (Pen1_Input_16DT AND NOT(Prev_Pen1_16DT)) OR HMI_Pen1_Cmd;
Prev_Pen1_PB := Pen1_Toggle_PB;
Prev_Pen1_16DT := Pen1_Input_16DT;
IF HMI_Pen1_Cmd THEN HMI_Pen1_Cmd := FALSE; END_IF;
IF Trig_Pen1 THEN Pen1_State := NOT(Pen1_State); END_IF;

Trig_Pen2 := (Pen2_Toggle_PB AND NOT(Prev_Pen2_PB)) OR (Pen2_Input_16DT AND NOT(Prev_Pen2_16DT)) OR HMI_Pen2_Cmd;
Prev_Pen2_PB := Pen2_Toggle_PB;
Prev_Pen2_16DT := Pen2_Input_16DT;
IF HMI_Pen2_Cmd THEN HMI_Pen2_Cmd := FALSE; END_IF;
IF Trig_Pen2 THEN Pen2_State := NOT(Pen2_State); END_IF;

(* TỰ ĐỘNG NHẢ 2 PEN KHI MÁY DỪNG HOẶC TỐC ĐỘ DƯỚI RELEASE SPEED *)
IF Current_Line_MPM <= Release_Pen_Speed_MPM OR State_Machine = 0 THEN
    Pen1_State := FALSE;
    Pen2_State := FALSE;
END_IF;

M1309 := Pen1_State; (* YD trên 16DT: Van Solenoid Pen 1 *)
M1310 := Pen2_State; (* YE trên 16DT: Van Solenoid Pen 2 *)

(* 6. TĂNG GIẢM TỐC LŨY TIẾN THEO THỜI GIAN GIỮ PHÍM INC / DEC *)
IF Cmd_Inc THEN
    Inc_Hold_Timer := Inc_Hold_Timer + 1;
    IF Inc_Hold_Timer < 50 THEN
        Dynamic_Accel_Step := Ramp_Accel_Rate;
    ELSIF Inc_Hold_Timer < 150 THEN
        Dynamic_Accel_Step := Ramp_Accel_Rate * 2.0;
    ELSE
        Dynamic_Accel_Step := Ramp_Accel_Rate * 5.0;
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
        Dynamic_Accel_Step := Ramp_Decel_Rate * 2.0;
    ELSE
        Dynamic_Accel_Step := Ramp_Decel_Rate * 5.0;
    END_IF;
    Target_Line_MPM := Target_Line_MPM - Dynamic_Accel_Step;
    IF Target_Line_MPM < Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
ELSE
    Dec_Hold_Timer := 0;
END_IF;

(* RAMPING TỐC ĐỘ HIỆN TẠI (FLOAT) *)
IF Current_Line_MPM < Target_Line_MPM THEN
    Current_Line_MPM := Current_Line_MPM + Ramp_Accel_Rate;
    IF Current_Line_MPM > Target_Line_MPM THEN Current_Line_MPM := Target_Line_MPM; END_IF;
ELSIF Current_Line_MPM > Target_Line_MPM THEN
    Current_Line_MPM := Current_Line_MPM - Ramp_Decel_Rate;
    IF Current_Line_MPM < Target_Line_MPM THEN Current_Line_MPM := Target_Line_MPM; END_IF;
END_IF;

(* 7. TÍNH ĐƯỜNG KÍNH 3 CUỘN T, M, U VÀ ĐO CHIỀU DÀI MÀNG CHẠY *)
Curr_Pulse_T  := INT_TO_DINT(WORD_TO_INT(D5000));
Curr_Pulse_X2 := INT_TO_DINT(WORD_TO_INT(D5002));

(* TÍNH TOÁN CHIỀU DÀI MÀNG CHẠY TÍCH LŨY TỪ XUNG ENCODER MASTER X2 *)
IF Curr_Pulse_X2 >= Last_Pulse_X2_Len THEN
    Delta_Pulse_X2 := Curr_Pulse_X2 - Last_Pulse_X2_Len;
ELSE
    Delta_Pulse_X2 := (Curr_Pulse_X2 + 65536) - Last_Pulse_X2_Len;
END_IF;

IF Delta_Pulse_X2 > 0 AND State_Machine = 1 AND Gear_Ratio_X2 > 0.0 THEN
    (* Chu vi Lô X2 = PI * Dia_X2_Roller_mm *)
    (* Delta_Length = Delta_Pulse_X2 * (PI * Dia_X2_Roller_mm) / (8000.0 * Gear_Ratio_X2) *)
    Delta_Length_mm := (DINT_TO_REAL(Delta_Pulse_X2) * 3.14159265 * Dia_X2_Roller_mm) / (8000.0 * Gear_Ratio_X2);
    Accum_Length_mm := Accum_Length_mm + Delta_Length_mm;
    
    (* Chuyển đổi mm sang mét *)
    IF Accum_Length_mm >= 1000.0 THEN
        Total_Length_Meters := Total_Length_Meters + (Accum_Length_mm / 1000.0);
        Accum_Length_mm     := 0.0;
    END_IF;
END_IF;
Last_Pulse_X2_Len := Curr_Pulse_X2;

(* NÚT RESET TỔNG CHIỀU DÀI MÉT TỪ HMI (M104) *)
IF HMI_Reset_Length THEN
    Total_Length_Meters := 0.0;
    Accum_Length_mm     := 0.0;
    HMI_Reset_Length    := FALSE;
END_IF;

(* TÍNH ĐƯỜNG KÍNH CUỘN THU T THEO XUNG MASTER X2 (1 VÒNG THU T = 8000 * Gear_Ratio_T) *)
IF Gear_Ratio_T > 0.0 AND (Curr_Pulse_T - Last_Pulse_T) >= REAL_TO_DINT(8000.0 * Gear_Ratio_T) THEN
    Rev_Count_T := Rev_Count_T + 1;
    IF (Curr_Pulse_X2 - Last_Pulse_X2_T) > 0 AND Gear_Ratio_X2 > 0.0 THEN
        Raw_Dia_T_mm := (DINT_TO_REAL(Curr_Pulse_X2 - Last_Pulse_X2_T) * Dia_X2_Roller_mm) / (8000.0 * Gear_Ratio_X2);
        IF Raw_Dia_T_mm < Core_Dia_T_mm THEN Raw_Dia_T_mm := Core_Dia_T_mm; END_IF;
        IF Raw_Dia_T_mm > Max_Dia_T_mm THEN Raw_Dia_T_mm := Max_Dia_T_mm; END_IF;
        Real_Dia_T_mm := Real_Dia_T_mm + ((Raw_Dia_T_mm - Real_Dia_T_mm) * 0.2);
    END_IF;
    Last_Pulse_X2_T := Curr_Pulse_X2;
    Last_Pulse_T    := Curr_Pulse_T;
END_IF;

(* TÍNH ĐƯỜNG KÍNH CUỘN XẢ M THEO CẢM BIẾN TIỆM CẬN X50 *)
Trig_X50 := Sensor_Rev_M AND NOT(Prev_X50);
Prev_X50 := Sensor_Rev_M;
IF Trig_X50 THEN
    Rev_Count_M := Rev_Count_M + 1;
    IF (Curr_Pulse_X2 - Last_Pulse_X2_M) > 0 AND Gear_Ratio_X2 > 0.0 THEN
        Raw_Dia_M_mm := (DINT_TO_REAL(Curr_Pulse_X2 - Last_Pulse_X2_M) * Dia_X2_Roller_mm) / (8000.0 * Gear_Ratio_X2);
        IF Raw_Dia_M_mm < Core_Dia_M_mm THEN Raw_Dia_M_mm := Core_Dia_M_mm; END_IF;
        IF Raw_Dia_M_mm > Max_Dia_M_mm THEN Raw_Dia_M_mm := Max_Dia_M_mm; END_IF;
        Real_Dia_M_mm := Real_Dia_M_mm + ((Raw_Dia_M_mm - Real_Dia_M_mm) * 0.2);
    END_IF;
    Last_Pulse_X2_M := Curr_Pulse_X2;
END_IF;

(* TÍNH ĐƯỜNG KÍNH CUỘN XẢ U THEO CẢM BIẾN TIỆM CẬN X51 *)
Trig_X51 := Sensor_Rev_U AND NOT(Prev_X51);
Prev_X51 := Sensor_Rev_U;
IF Trig_X51 THEN
    Rev_Count_U := Rev_Count_U + 1;
    IF (Curr_Pulse_X2 - Last_Pulse_X2_U) > 0 AND Gear_Ratio_X2 > 0.0 THEN
        Raw_Dia_U_mm := (DINT_TO_REAL(Curr_Pulse_X2 - Last_Pulse_X2_U) * Dia_X2_Roller_mm) / (8000.0 * Gear_Ratio_X2);
        IF Raw_Dia_U_mm < Core_Dia_U_mm THEN Raw_Dia_U_mm := Core_Dia_U_mm; END_IF;
        IF Raw_Dia_U_mm > Max_Dia_U_mm THEN Raw_Dia_U_mm := Max_Dia_U_mm; END_IF;
        Real_Dia_U_mm := Real_Dia_U_mm + ((Raw_Dia_U_mm - Real_Dia_U_mm) * 0.2);
    END_IF;
    Last_Pulse_X2_U := Curr_Pulse_X2;
END_IF;

(* 8. STATE MACHINE VẬN HÀNH DÂY CHUYỀN *)
CASE State_Machine OF
    0: (* STATE_STOPPED *)
        Current_Line_MPM := 0.0;
        Target_Line_MPM  := 0.0;
        IF Cmd_Start AND NOT(Servo_Not_Ready_Fault) THEN
            State_Machine := 1;
            HMI_Start := FALSE;
        END_IF;
    1: (* STATE_RUNNING *)
        IF Cmd_Stop THEN
            State_Machine := 0;
            HMI_Stop := FALSE;
        END_IF;
END_CASE;

(* ĐIỀU KHIỂN 5 TRỤC SERVO ON XUẤT RA MODULE 16DT (Y8..YC = M1304..M1308) *)
M1304 := (State_Machine = 1) OR HMI_Test_T;
M1305 := (State_Machine = 1) OR HMI_Test_X1;
M1306 := (State_Machine = 1) OR HMI_Test_X2;
M1307 := (State_Machine = 1) OR HMI_Test_Ms OR (State_Machine = 0 AND Anti_Dry_Rotate_Ms);
M1308 := (State_Machine = 1) OR HMI_Test_S  OR (State_Machine = 0 AND Anti_Dry_Rotate_S);

Servo_ON_T  := M1304;
Servo_ON_X1 := M1305;
Servo_ON_X2 := M1306;
Servo_ON_Ms := M1307;
Servo_ON_S  := M1308;

(* 9. TÍNH CÔN LỰC TAPER TENSION CUỘN THU T (FLOAT) *)
IF (Max_Dia_T_mm - Core_Dia_T_mm) > 0.0 AND Taper_Percent_T > 0.0 THEN
    Effective_SP_T := SP_Tension_T - (((Real_Dia_T_mm - Core_Dia_T_mm) * SP_Tension_T * (Taper_Percent_T / 100.0)) / (Max_Dia_T_mm - Core_Dia_T_mm));
ELSE
    Effective_SP_T := SP_Tension_T;
END_IF;
IF Effective_SP_T < 0.0 THEN Effective_SP_T := 0.0; END_IF;

(* TÍNH TOÁN TỐC ĐỘ ĐẶT SETPOINT CHO CÁC TRỤC ĐỒNG BỘ THEO MASTER X2 (HIGH RESOLUTION 0..16000) *)
IF Max_Speed_MPM > 0.0 THEN
    Base_Speed_X2 := (Current_Line_MPM * 16000.0) / Max_Speed_MPM;
ELSE
    Base_Speed_X2 := 0.0;
END_IF;

SP_Speed_X2 := Base_Speed_X2;
SP_Speed_X1 := (Base_Speed_X2 * Speed_Ratio_X1) + Speed_Offset_X1;

IF Dia_X2_Roller_mm > 0.0 THEN
    SP_Speed_Ms := (((Base_Speed_X2 * Dia_Ms_Roller_mm) / Dia_X2_Roller_mm) * Speed_Ratio_Ms) + Speed_Offset_Ms;
ELSE
    SP_Speed_Ms := Base_Speed_X2 + Speed_Offset_Ms;
END_IF;

SP_Speed_S := (Base_Speed_X2 * Speed_Ratio_S) + Speed_Offset_S;

IF Core_Dia_T_mm > 0.0 THEN
    SP_Speed_T := ((Base_Speed_X2 * Real_Dia_T_mm) / Core_Dia_T_mm) * Speed_Ratio_T;
ELSE
    SP_Speed_T := Base_Speed_X2 * Speed_Ratio_T;
END_IF;

(* ============================================================================ *)
(* 9.1 BỘ CHUYỂN MẠCH INDEX-REGISTER CHO HMI CHỈNH PID, CALIB VÀ ZERO ĐA TRỤC  *)
(* HMI_Axis_Select (D610): 1=Thu T, 2=Xả X1, 3=Master X2, 4=Ghép Ms, 5=Dầu S, 6=Thắng M, 7=Xả U *)
(* ============================================================================ *)
IF HMI_Axis_Select <= 0 OR HMI_Axis_Select > 7 THEN
    HMI_Axis_Select := 1; (* Mặc định chọn Trục 1: Thu T *)
END_IF;

(* GHI CÀI ĐẶT TỪ HMI VÀO TRỤC ĐANG CHỌN KHI CÓ LỆNH HOẶC THAY ĐỔI *)
IF HMI_Cmd_Save_PID THEN
    CASE HMI_Axis_Select OF
        1: (* Trục Thu T *)
            Kp_T := HMI_Disp_Kp; Ki_T := HMI_Disp_Ki; Kd_T := HMI_Disp_Kd; Calib_Gain_T := HMI_Disp_Calib_Gain;
        2: (* Trục Xả X1 *)
            Kp_X1 := HMI_Disp_Kp; Ki_X1 := HMI_Disp_Ki; Kd_X1 := HMI_Disp_Kd; Calib_Gain_X1 := HMI_Disp_Calib_Gain;
        3: (* Trục Master X2 *)
            Kp_X2 := HMI_Disp_Kp; Ki_X2 := HMI_Disp_Ki; Kd_X2 := HMI_Disp_Kd;
        4: (* Trục Ghép Ms *)
            Kp_Ms := HMI_Disp_Kp; Ki_Ms := HMI_Disp_Ki; Kd_Ms := HMI_Disp_Kd;
        5: (* Trục Dầu S *)
            Kp_S := HMI_Disp_Kp; Ki_S := HMI_Disp_Ki; Kd_S := HMI_Disp_Kd;
        6: (* Trục Thắng M *)
            Kp_M := HMI_Disp_Kp; Ki_M := HMI_Disp_Ki; Kd_M := HMI_Disp_Kd; Calib_Gain_M := HMI_Disp_Calib_Gain;
        7: (* Trục Xả U *)
            Kp_U := HMI_Disp_Kp; Ki_U := HMI_Disp_Ki; Kd_U := HMI_Disp_Kd; Calib_Gain_U := HMI_Disp_Calib_Gain;
    END_CASE;
    HMI_Cmd_Save_PID := FALSE;
ELSE
    (* ĐỌC THAM SỐ CỦA TRỤC ĐANG CHỌN XUẤT RA Ô HIỂN THỊ TRÊN HMI *)
    CASE HMI_Axis_Select OF
        1: (* Trục Thu T *)
            HMI_Disp_Kp := Kp_T; HMI_Disp_Ki := Ki_T; HMI_Disp_Kd := Kd_T; HMI_Disp_Calib_Gain := Calib_Gain_T;
        2: (* Trục Xả X1 *)
            HMI_Disp_Kp := Kp_X1; HMI_Disp_Ki := Ki_X1; HMI_Disp_Kd := Kd_X1; HMI_Disp_Calib_Gain := Calib_Gain_X1;
        3: (* Trục Master X2 *)
            HMI_Disp_Kp := Kp_X2; HMI_Disp_Ki := Ki_X2; HMI_Disp_Kd := Kd_X2; HMI_Disp_Calib_Gain := 1.0;
        4: (* Trục Ghép Ms *)
            HMI_Disp_Kp := Kp_Ms; HMI_Disp_Ki := Ki_Ms; HMI_Disp_Kd := Kd_Ms; HMI_Disp_Calib_Gain := 1.0;
        5: (* Trục Dầu S *)
            HMI_Disp_Kp := Kp_S; HMI_Disp_Ki := Ki_S; HMI_Disp_Kd := Kd_S; HMI_Disp_Calib_Gain := 1.0;
        6: (* Trục Thắng M *)
            HMI_Disp_Kp := Kp_M; HMI_Disp_Ki := Ki_M; HMI_Disp_Kd := Kd_M; HMI_Disp_Calib_Gain := Calib_Gain_M;
        7: (* Trục Xả U *)
            HMI_Disp_Kp := Kp_U; HMI_Disp_Ki := Ki_U; HMI_Disp_Kd := Kd_U; HMI_Disp_Calib_Gain := Calib_Gain_U;
    END_CASE;
END_IF;

(* XỬ LÝ NÚT BẤM ZERO VÀ CALIB THEO TRỤC ĐANG CHỌN TRÊN HMI *)
IF HMI_Cmd_Zero_Set THEN
    CASE HMI_Axis_Select OF
        1: Zero_Set_T  := TRUE;
        2: Zero_Set_X1 := TRUE;
        6: Zero_Set_M  := TRUE;
        7: Zero_Set_U  := TRUE;
    END_CASE;
    HMI_Cmd_Zero_Set := FALSE;
END_IF;

IF HMI_Cmd_Calib_Set THEN
    CASE HMI_Axis_Select OF
        1: Calib_Set_T  := TRUE;
        2: Calib_Set_X1 := TRUE;
        6: Calib_Set_M  := TRUE;
        7: Calib_Set_U  := TRUE;
    END_CASE;
    HMI_Cmd_Calib_Set := FALSE;
END_IF;

(* TẠO XUNG KÍCH HOẠT PID CHUẨN 10MS TỪ SM409 *)
Trig_PID_10ms := SM409 AND NOT(Prev_SM409);
Prev_SM409 := SM409;

(* 10. GỌI RUN CÁC KHỐI PID THEO NHỊP 10MS (TÍCH HỢP AUTO-TUNING TỰ ĐỘNG) *)
IF Trig_PID_10ms THEN
    (* PID Tốc độ Trục chính Master X2 *)
    pid_X2(
        Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 3),
        Setpoint    := SP_Speed_X2,
        Feedback    := Feedback_Speed_X2,
        Kp          := Kp_X2, Ki := Ki_X2, Kd := Kd_X2,
        AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 3)
    );
    PID_Out_X2 := pid_X2.PID_Output;

    (* PID Tốc độ Trục Ghép Ms *)
    pid_Ms(
        Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 4),
        Setpoint    := SP_Speed_Ms,
        Feedback    := Feedback_Speed_Ms,
        Kp          := Kp_Ms, Ki := Ki_Ms, Kd := Kd_Ms,
        AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 4)
    );
    PID_Out_Ms := pid_Ms.PID_Output;

    (* PID Tốc độ Trục Tráng Dầu S *)
    pid_S(
        Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 5),
        Setpoint    := SP_Speed_S,
        Feedback    := Feedback_Speed_S,
        Kp          := Kp_S, Ki := Ki_S, Kd := Kd_S,
        AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 5)
    );
    PID_Out_S := pid_S.PID_Output;

    (* PID Lực căng Loadcell Trục Kéo Giấy X1 *)
    pid_X1(
        Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 2),
        Setpoint    := SP_Tension_X1,
        Feedback    := Weight_Net_X1,
        Kp          := Kp_X1, Ki := Ki_X1, Kd := Kd_X1,
        AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 2)
    );
    PID_Out_X1 := pid_X1.PID_Output;

    (* PID Lực căng Loadcell Cuộn Thu T *)
    pid_T(
        Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 1),
        Setpoint    := Effective_SP_T,
        Feedback    := Weight_Net_T,
        Kp          := Kp_T, Ki := Ki_T, Kd := Kd_T,
        AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 1)
    );
    PID_Out_T := pid_T.PID_Output;

    (* PID Lực căng Thắng Từ Xả M *)
    pid_M(
        Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 6),
        Setpoint    := SP_Tension_M,
        Feedback    := Weight_Net_M,
        Kp          := Kp_M, Ki := Ki_M, Kd := Kd_M,
        AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 6)
    );
    PID_Out_M := pid_M.PID_Output;

    (* PID Lực căng Trục Xả Metalize U *)
    pid_U(
        Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 7),
        Setpoint    := SP_Tension_U,
        Feedback    := Weight_Net_U,
        Kp          := Kp_U, Ki := Ki_U, Kd := Kd_U,
        AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 7)
    );
    PID_Out_U := pid_U.PID_Output;

    (* TỰ ĐỘNG CẬP NHẬT KẾT QUẢ KHI AUTO-TUNE HOÀN THÀNH *)
    IF pid_X2.AT_Done THEN
        Kp_X2 := pid_X2.Tuned_Kp; Ki_X2 := pid_X2.Tuned_Ki; Kd_X2 := pid_X2.Tuned_Kd;
        HMI_Disp_Kp := Kp_X2; HMI_Disp_Ki := Ki_X2; HMI_Disp_Kd := Kd_X2;
    ELSIF pid_Ms.AT_Done THEN
        Kp_Ms := pid_Ms.Tuned_Kp; Ki_Ms := pid_Ms.Tuned_Ki; Kd_Ms := pid_Ms.Tuned_Kd;
        HMI_Disp_Kp := Kp_Ms; HMI_Disp_Ki := Ki_Ms; HMI_Disp_Kd := Kd_Ms;
    ELSIF pid_S.AT_Done THEN
        Kp_S := pid_S.Tuned_Kp; Ki_S := pid_S.Tuned_Ki; Kd_S := pid_S.Tuned_Kd;
        HMI_Disp_Kp := Kp_S; HMI_Disp_Ki := Ki_S; HMI_Disp_Kd := Kd_S;
    ELSIF pid_X1.AT_Done THEN
        Kp_X1 := pid_X1.Tuned_Kp; Ki_X1 := pid_X1.Tuned_Ki; Kd_X1 := pid_X1.Tuned_Kd;
        HMI_Disp_Kp := Kp_X1; HMI_Disp_Ki := Ki_X1; HMI_Disp_Kd := Kd_X1;
    ELSIF pid_T.AT_Done THEN
        Kp_T := pid_T.Tuned_Kp; Ki_T := pid_T.Tuned_Ki; Kd_T := pid_T.Tuned_Kd;
        HMI_Disp_Kp := Kp_T; HMI_Disp_Ki := Ki_T; HMI_Disp_Kd := Kd_T;
    ELSIF pid_M.AT_Done THEN
        Kp_M := pid_M.Tuned_Kp; Ki_M := pid_M.Tuned_Ki; Kd_M := pid_M.Tuned_Kd;
        HMI_Disp_Kp := Kp_M; HMI_Disp_Ki := Ki_M; HMI_Disp_Kd := Kd_M;
    ELSIF pid_U.AT_Done THEN
        Kp_U := pid_U.Tuned_Kp; Ki_U := pid_U.Tuned_Ki; Kd_U := pid_U.Tuned_Kd;
        HMI_Disp_Kp := Kp_U; HMI_Disp_Ki := Ki_U; HMI_Disp_Kd := Kd_U;
    END_IF;

    (* TẮT CỜ AUTO-TUNE DUY NHẤT TẠI 1 ĐIỂM CHỐNG CẢNH BÁO DOUBLE-COIL C9300 *)
    IF pid_X2.AT_Done OR pid_Ms.AT_Done OR pid_S.AT_Done OR pid_X1.AT_Done OR pid_T.AT_Done OR pid_M.AT_Done OR pid_U.AT_Done THEN
        HMI_Cmd_AutoTune   := FALSE;
        HMI_Status_AT_Done := TRUE;
    END_IF;
    
    (* Cập nhật cờ báo bận Auto-Tune *)
    HMI_Status_AT_Busy := pid_T.AT_Busy OR pid_X1.AT_Busy OR pid_X2.AT_Busy OR pid_Ms.AT_Busy OR pid_S.AT_Busy OR pid_M.AT_Busy OR pid_U.AT_Busy;
END_IF;

(* 11. TÍNH TOÁN XUẤT ÁP TỐC ĐỘ VÀ TORQUE CHO TỪNG TRỤC (FLOAT) *)
IF State_Machine = 0 THEN
    (* KHI MÁY DỪNG: KIỂM TRA CHẾ ĐỘ TEST RIÊNG BIỆT TỪNG TRỤC HOẶC BÒ CHẬM RỬA MÁY *)
    IF HMI_Test_X2 THEN Calc_Speed_X2 := Test_Speed_X2; ELSE Calc_Speed_X2 := 0.0; END_IF;
    IF HMI_Test_X1 THEN Calc_Speed_X1 := Test_Speed_X1; ELSE Calc_Speed_X1 := 0.0; END_IF;

    IF HMI_Test_Ms THEN
        Calc_Speed_Ms := Test_Speed_Ms;
    ELSIF Anti_Dry_Rotate_Ms AND Max_Speed_MPM > 0.0 THEN
        Calc_Speed_Ms := (Anti_Dry_Crawl_Speed * 16000.0) / Max_Speed_MPM;
    ELSE
        Calc_Speed_Ms := 0.0;
    END_IF;

    IF HMI_Test_S THEN
        Calc_Speed_S := Test_Speed_S;
    ELSIF Anti_Dry_Rotate_S AND Max_Speed_MPM > 0.0 THEN
        Calc_Speed_S := (Anti_Dry_Crawl_Speed * 16000.0) / Max_Speed_MPM;
    ELSE
        Calc_Speed_S := 0.0;
    END_IF;

    IF HMI_Test_T THEN
        Calc_Speed_T  := Test_Speed_T;
        Calc_Torque_T := Test_Torque_T;
    ELSE
        Calc_Speed_T  := 0.0;
        Calc_Torque_T := 0.0;
    END_IF;

    IF HMI_Test_M THEN
        Calc_Torque_M := Test_Torque_M;
    ELSIF Hold_Torque_Stop_M THEN
        Calc_Torque_M := (Base_Torque_M * 160.0);
    ELSE
        Calc_Torque_M := 0.0;
    END_IF;

    IF HMI_Test_U THEN
        Calc_Speed_U := Test_Speed_U;
    ELSIF Hold_Torque_Stop_U THEN
        Calc_Speed_U := (Init_Holding_Torque_U * 160.0);
    ELSE
        Calc_Speed_U := 0.0;
    END_IF;

ELSE
    (* KHI MÁY CHẠY TỰ ĐỘNG *)
    Calc_Speed_X2 := SP_Speed_X2 + PID_Out_X2;
    Calc_Speed_X1 := SP_Speed_X1 + PID_Out_X1;
    Calc_Speed_Ms := SP_Speed_Ms + PID_Out_Ms;
    Calc_Speed_S  := SP_Speed_S  + PID_Out_S;
    Calc_Speed_T  := SP_Speed_T;
    Calc_Torque_T := (Effective_SP_T * 160.0) + PID_Out_T;

    IF Real_Dia_U_mm > 0.0 THEN
        Calc_Speed_U := ((Calc_Speed_X2 * Max_Dia_U_mm) / Real_Dia_U_mm) + PID_Out_U;
    ELSE
        Calc_Speed_U := Calc_Speed_X2 + PID_Out_U;
    END_IF;

    (* 3 Pha Torque Thắng M (0..100% quy đổi ra 0..16000) *)
    IF Rev_Count_M <= 5 THEN
        Base_Torque_M := Init_Holding_Torque_M;
    ELSIF (Max_Dia_M_mm - Core_Dia_M_mm) > 0.0 THEN
        Base_Torque_M := Min_Torque_M + (((Max_Torque_M - Min_Torque_M) * (Real_Dia_M_mm - Core_Dia_M_mm)) / (Max_Dia_M_mm - Core_Dia_M_mm));
    ELSE
        Base_Torque_M := Min_Torque_M;
    END_IF;
    Calc_Torque_M := (Base_Torque_M * 160.0) + PID_Out_M;
END_IF;

(* KHỐNG CHẾ BIÊN AN TOÀN 0..16000 CHO TOÀN BỘ 8 KÊNH DAC (HIGH RESOLUTION) *)
IF Calc_Speed_T  < 0.0 THEN Calc_Speed_T  := 0.0; ELSIF Calc_Speed_T  > 16000.0 THEN Calc_Speed_T  := 16000.0; END_IF;
IF Calc_Torque_T < 0.0 THEN Calc_Torque_T := 0.0; ELSIF Calc_Torque_T > 16000.0 THEN Calc_Torque_T := 16000.0; END_IF;
IF Calc_Speed_X1 < 0.0 THEN Calc_Speed_X1 := 0.0; ELSIF Calc_Speed_X1 > 16000.0 THEN Calc_Speed_X1 := 16000.0; END_IF;
IF Calc_Speed_X2 < 0.0 THEN Calc_Speed_X2 := 0.0; ELSIF Calc_Speed_X2 > 16000.0 THEN Calc_Speed_X2 := 16000.0; END_IF;
IF Calc_Speed_Ms < 0.0 THEN Calc_Speed_Ms := 0.0; ELSIF Calc_Speed_Ms > 16000.0 THEN Calc_Speed_Ms := 16000.0; END_IF;
IF Calc_Torque_M < 0.0 THEN Calc_Torque_M := 0.0; ELSIF Calc_Torque_M > 16000.0 THEN Calc_Torque_M := 16000.0; END_IF;
IF Calc_Speed_S  < 0.0 THEN Calc_Speed_S  := 0.0; ELSIF Calc_Speed_S  > 16000.0 THEN Calc_Speed_S  := 16000.0; END_IF;
IF Calc_Speed_U  < 0.0 THEN Calc_Speed_U  := 0.0; ELSIF Calc_Speed_U  > 16000.0 THEN Calc_Speed_U  := 16000.0; END_IF;

(* 12. THỰC THI FB CC-LINK XUẤT ÁP 8 KÊNH DAC (TRUYỀN TRỰC TIẾP BIẾN FLOAT) *)
fbCCLink(
    Enable          := TRUE,
    ResetErr        := HMI_Reset_Error,
    Auto_Mode       := HMI_Auto_Mode,
    Set_Speed_T     := Calc_Speed_T,
    Set_Torque_T    := Calc_Torque_T,
    Set_Speed_X1    := Calc_Speed_X1,
    Set_Speed_X2    := Calc_Speed_X2,
    Set_Speed_Ms    := Calc_Speed_Ms,
    Set_Torque_M    := Calc_Torque_M,
    Set_Speed_S     := Calc_Speed_S,
    Set_Speed_U     := Calc_Speed_U
);

(* 13. TỰ ĐỘNG BÁO GIẢM TỐC VÀ DỪNG MÁY KHI ĐẠT CHIỀU DÀI MÉT CÀI ĐẶT *)
IF Set_Target_Length > 0.0 AND State_Machine = 1 THEN
    (* Pha 1: Giảm tốc về Min_Speed khi còn cách đích khoảng cách Decel_Distance_Meters *)
    IF Decel_Distance_Meters > 0.0 AND Total_Length_Meters >= (Set_Target_Length - Decel_Distance_Meters) THEN
        Auto_Decel_Flag := TRUE;
        IF Target_Line_MPM > Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
    ELSE
        Auto_Decel_Flag := FALSE;
    END_IF;

    (* Pha 2: Dừng máy hoàn toàn khi đã đủ tổng mét màng cài đặt *)
    IF Total_Length_Meters >= Set_Target_Length THEN
        State_Machine    := 0;
        Target_Line_MPM  := 0.0;
        Current_Line_MPM := 0.0;
        Auto_Decel_Flag  := FALSE;
    END_IF;
END_IF;
