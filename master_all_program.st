(* ============================================================================ *)
(* MÃ NGUỒN TỔNG HỢP TOÀN DIỆN (MASTER BACKUP) - DỰ ÁN MÁY GHÉP MÀNG METALIZE  *)
(* PLC MITSUBISHI Q02U CPU - 100% STRUCTURED TEXT (POU_01)                      *)
(* ĐỒNG BỘ VẬN TỐC DÀI THEO TRỤC MASTER X2 + SPEED_RATIO CHO TỪNG TRỤC          *)
(* MAX RPM: X2=1000, X1=1000, Ms=3000, S=3000, T=1500                          *)
(* TÍCH HỢP CHẾ ĐỘ TEST RIÊNG BIỆT CHO TỪNG TRỤC (M170..M176 / D800..D812)     *)
(* ============================================================================ *)

(* 0. KHỞI TẠO TỐC ĐỘ MAX RPM VÀ TỶ SỐ TRUYỀN HỘP SỐ *)
IF Max_RPM_X2 <= 0 THEN Max_RPM_X2 := 1000; END_IF; (* Trục Master X2: Max 1000 RPM *)
IF Max_RPM_X1 <= 0 THEN Max_RPM_X1 := 1000; END_IF; (* Trục Kéo X1:    Max 1000 RPM *)
IF Max_RPM_Ms <= 0 THEN Max_RPM_Ms := 3000; END_IF; (* Trục Ghép Ms:   Max 3000 RPM *)
IF Max_RPM_S  <= 0 THEN Max_RPM_S  := 3000; END_IF; (* Trục Dầu S:     Max 3000 RPM *)
IF Max_RPM_T  <= 0 THEN Max_RPM_T  := 1500; END_IF; (* Trục Thu T:     Max 1500 RPM *)

IF Gear_Ratio_T  <= 0 THEN Gear_Ratio_T  := 10100; END_IF; (* 10.1:1 *)
IF Gear_Ratio_X1 <= 0 THEN Gear_Ratio_X1 := 8000;  END_IF; (* 8.0:1 *)
IF Gear_Ratio_X2 <= 0 THEN Gear_Ratio_X2 := 8000;  END_IF; (* 8.0:1 *)
IF Gear_Ratio_Ms <= 0 THEN Gear_Ratio_Ms := 10000; END_IF; (* 10.0:1 *)
IF Gear_Ratio_S  <= 0 THEN Gear_Ratio_S  := 10000; END_IF; (* 10.0:1 *)
IF Gear_Ratio_U  <= 0 THEN Gear_Ratio_U  := 1000;  END_IF; (* 1.0:1 *)

(* KHỞI TẠO HỆ SỐ TỶ LỆ TỐC ĐỘ (1000 = 100.0%, >1000 NHANH HƠN, <1000 CHẬM HƠN) *)
IF Speed_Ratio_T  <= 0 THEN Speed_Ratio_T  := 1050; END_IF; (* Mặc định chạy nhanh hơn 5% để giữ Torque *)
IF Speed_Ratio_X1 <= 0 THEN Speed_Ratio_X1 := 1000; END_IF; (* 100.0% *)
IF Speed_Ratio_Ms <= 0 THEN Speed_Ratio_Ms := 1000; END_IF; (* 100.0% *)
IF Speed_Ratio_S  <= 0 THEN Speed_Ratio_S  := 1000; END_IF; (* 100.0% *)

(* BẢO VỆ CHỐNG LỖI CHIA CHO 0 & KHỞI TẠO ĐƯỜNG KÍNH *)
IF Max_Speed_MPM <= 0 THEN Max_Speed_MPM := 1000; END_IF; (* 100.0 m/p *)
IF Min_Speed_MPM <= 0 THEN Min_Speed_MPM := 20;   END_IF; (* 2.0 m/p *)
IF Core_Dia_T_mm <= 0 THEN Core_Dia_T_mm := 76;   END_IF;
IF Core_Dia_M_mm <= 0 THEN Core_Dia_M_mm := 76;   END_IF;
IF Core_Dia_U_mm <= 0 THEN Core_Dia_U_mm := 76;   END_IF;
IF Max_Dia_T_mm  <= 0 THEN Max_Dia_T_mm  := 600;  END_IF;
IF Max_Dia_M_mm  <= 0 THEN Max_Dia_M_mm  := 600;  END_IF;
IF Max_Dia_U_mm  <= 0 THEN Max_Dia_U_mm  := 800;  END_IF;

IF Dia_Ms_Roller_mm <= 0 THEN Dia_Ms_Roller_mm := 2000; END_IF; (* 200.0 mm *)
IF Dia_X2_Roller_mm <= 0 THEN Dia_X2_Roller_mm := 3005; END_IF; (* 300.5 mm *)
IF Decel_Distance_Meters <= 0 THEN Decel_Distance_Meters := 50; END_IF;
IF Ramp_Accel_Rate <= 0 THEN Ramp_Accel_Rate := 5; END_IF;
IF Ramp_Decel_Rate <= 0 THEN Ramp_Decel_Rate := 10; END_IF;
IF Release_Pen_Speed_MPM <= 0 THEN Release_Pen_Speed_MPM := 20; END_IF;

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

(* TỰ ĐỘNG NHẢ 2 PEN KHI MÁY DỪNG HOẶC TỐC ĐỘ DƯỚI 2.0 m/p *)
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
    IF Target_Line_MPM < Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
ELSE
    Dec_Hold_Timer := 0;
END_IF;

(* RAMPING TỐC ĐỘ HIỆN TẠI *)
IF Current_Line_MPM < Target_Line_MPM THEN
    Current_Line_MPM := Current_Line_MPM + Ramp_Accel_Rate;
    IF Current_Line_MPM > Target_Line_MPM THEN Current_Line_MPM := Target_Line_MPM; END_IF;
ELSIF Current_Line_MPM > Target_Line_MPM THEN
    Current_Line_MPM := Current_Line_MPM - Ramp_Decel_Rate;
    IF Current_Line_MPM < Target_Line_MPM THEN Current_Line_MPM := Target_Line_MPM; END_IF;
END_IF;

(* 7. TÍNH ĐƯỜNG KÍNH 3 CUỘN T, M, U *)
Curr_Pulse_T  := INT_TO_DINT(D5000);
Curr_Pulse_X2 := INT_TO_DINT(D5002);

IF (Curr_Pulse_T - Last_Pulse_T) >= ((8000 * Gear_Ratio_T) / 1000) THEN
    Rev_Count_T := Rev_Count_T + 1;
    IF (Curr_Pulse_X2 - Last_Pulse_X2_T) > 0 THEN
        Raw_Dia_T_mm := ((Curr_Pulse_X2 - Last_Pulse_X2_T) * Dia_X2_Roller_mm) / 320000;
        IF Raw_Dia_T_mm < Core_Dia_T_mm THEN Raw_Dia_T_mm := Core_Dia_T_mm; END_IF;
        IF Raw_Dia_T_mm > Max_Dia_T_mm THEN Raw_Dia_T_mm := Max_Dia_T_mm; END_IF;
        Real_Dia_T_mm := Real_Dia_T_mm + ((Raw_Dia_T_mm - Real_Dia_T_mm) / 5);
    END_IF;
    Last_Pulse_X2_T := Curr_Pulse_X2;
    Last_Pulse_T    := Curr_Pulse_T;
END_IF;

Trig_X50 := Sensor_Rev_M AND NOT(Prev_X50);
Prev_X50 := Sensor_Rev_M;
IF Trig_X50 THEN
    Rev_Count_M := Rev_Count_M + 1;
    IF (Curr_Pulse_X2 - Last_Pulse_X2_M) > 0 THEN
        Raw_Dia_M_mm := ((Curr_Pulse_X2 - Last_Pulse_X2_M) * Dia_X2_Roller_mm) / 320000;
        IF Raw_Dia_M_mm < Core_Dia_M_mm THEN Raw_Dia_M_mm := Core_Dia_M_mm; END_IF;
        IF Raw_Dia_M_mm > Max_Dia_M_mm THEN Raw_Dia_M_mm := Max_Dia_M_mm; END_IF;
        Real_Dia_M_mm := Real_Dia_M_mm + ((Raw_Dia_M_mm - Real_Dia_M_mm) / 5);
    END_IF;
    Last_Pulse_X2_M := Curr_Pulse_X2;
END_IF;

Trig_X51 := Sensor_Rev_U AND NOT(Prev_X51);
Prev_X51 := Sensor_Rev_U;
IF Trig_X51 THEN
    Rev_Count_U := Rev_Count_U + 1;
    IF (Curr_Pulse_X2 - Last_Pulse_X2_U) > 0 THEN
        Raw_Dia_U_mm := ((Curr_Pulse_X2 - Last_Pulse_X2_U) * Dia_X2_Roller_mm) / 320000;
        IF Raw_Dia_U_mm < Core_Dia_U_mm THEN Raw_Dia_U_mm := Core_Dia_U_mm; END_IF;
        IF Raw_Dia_U_mm > Max_Dia_U_mm THEN Raw_Dia_U_mm := Max_Dia_U_mm; END_IF;
        Real_Dia_U_mm := Real_Dia_U_mm + ((Raw_Dia_U_mm - Real_Dia_U_mm) / 5);
    END_IF;
    Last_Pulse_X2_U := Curr_Pulse_X2;
END_IF;

(* 8. STATE MACHINE VẬN HÀNH DÂY CHUYỀN *)
CASE State_Machine OF
    0: (* STATE_STOPPED *)
        Current_Line_MPM := 0;
        Target_Line_MPM  := 0;
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
(* Tự động ON khi máy chạy HOẶC khi bật cờ TEST trục tương ứng *)
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

(* 9. TÍNH CÔN LỰC TAPER TENSION CUỘN THU T *)
IF (Max_Dia_T_mm - Core_Dia_T_mm) > 0 AND Taper_Percent_T > 0 THEN
    Effective_SP_T := SP_Tension_T - (((Real_Dia_T_mm - Core_Dia_T_mm) * SP_Tension_T * Taper_Percent_T) / ((Max_Dia_T_mm - Core_Dia_T_mm) * 100));
ELSE
    Effective_SP_T := SP_Tension_T;
END_IF;
IF Effective_SP_T < 0 THEN Effective_SP_T := 0; END_IF;

(* TÍNH TOÁN TỐC ĐỘ ĐẶT SETPOINT CHO CÁC TRỤC ĐỒNG BỘ THEO MASTER X2 *)
Base_Speed_X2 := (Current_Line_MPM * 4000) / Max_Speed_MPM;

SP_Speed_X2 := Base_Speed_X2;
SP_Speed_X1 := ((Base_Speed_X2 * Speed_Ratio_X1) / 1000) + Speed_Offset_X1;
SP_Speed_Ms := (((Base_Speed_X2 * Dia_Ms_Roller_mm) / Dia_X2_Roller_mm) * Speed_Ratio_Ms) / 1000 + Speed_Offset_Ms;
SP_Speed_S  := ((Base_Speed_X2 * Speed_Ratio_S)  / 1000) + Speed_Offset_S;

IF Real_Dia_T_mm > 0 THEN
    SP_Speed_T := (((Base_Speed_X2 * Real_Dia_T_mm) / Core_Dia_T_mm) * Speed_Ratio_T) / 1000;
ELSE
    SP_Speed_T := (Base_Speed_X2 * Speed_Ratio_T) / 1000;
END_IF;

(* TẠO XUNG KÍCH HOẠT PID CHUẨN 10MS TỪ SM409 *)
Trig_PID_10ms := SM409 AND NOT(Prev_SM409);
Prev_SM409 := SM409;

(* 10. GỌI RUN CÁC KHỐI PID THEO NHỊP 10MS *)
IF Trig_PID_10ms THEN
    (* PID Tốc độ Trục chính Master X2 *)
    pid_X2(Enable := (HMI_PID_Enable AND State_Machine = 1), Setpoint := SP_Speed_X2, Feedback := Feedback_Speed_X2, Kp := Kp_X2, Ki := Ki_X2, Kd := Kd_X2);
    PID_Out_X2 := pid_X2.PID_Output;

    (* PID Tốc độ Trục Ghép Ms *)
    pid_Ms(Enable := (HMI_PID_Enable AND State_Machine = 1), Setpoint := SP_Speed_Ms, Feedback := Feedback_Speed_Ms, Kp := Kp_Ms, Ki := Ki_Ms, Kd := Kd_Ms);
    PID_Out_Ms := pid_Ms.PID_Output;

    (* PID Tốc độ Trục Tráng Dầu S *)
    pid_S(Enable := (HMI_PID_Enable AND State_Machine = 1), Setpoint := SP_Speed_S, Feedback := Feedback_Speed_S, Kp := Kp_S, Ki := Ki_S, Kd := Kd_S);
    PID_Out_S := pid_S.PID_Output;

    (* PID Lực căng Loadcell Trục Kéo Giấy X1 *)
    pid_X1(Enable := (HMI_PID_Enable AND State_Machine = 1), Setpoint := SP_Tension_X1, Feedback := Weight_Net_X1, Kp := Kp_X1, Ki := Ki_X1, Kd := Kd_X1);
    PID_Out_X1 := pid_X1.PID_Output;

    (* PID Lực căng Loadcell Cuộn Thu T *)
    pid_T(Enable := (HMI_PID_Enable AND State_Machine = 1), Setpoint := Effective_SP_T, Feedback := Weight_Net_T, Kp := Kp_T, Ki := Ki_T, Kd := Kd_T);
    PID_Out_T := pid_T.PID_Output;

    (* PID Lực căng Thắng Từ Xả M *)
    pid_M(Enable := (HMI_PID_Enable AND State_Machine = 1), Setpoint := SP_Tension_M, Feedback := Weight_Net_M, Kp := Kp_M, Ki := Ki_M, Kd := Kd_M);
    PID_Out_M := pid_M.PID_Output;

    (* PID Lực căng Trục Xả Metalize U *)
    pid_U(Enable := (HMI_PID_Enable AND State_Machine = 1), Setpoint := SP_Tension_U, Feedback := Weight_Net_U, Kp := Kp_U, Ki := Ki_U, Kd := Kd_U);
    PID_Out_U := pid_U.PID_Output;
END_IF;

(* 11. TÍNH TOÁN XUẤT ÁP TỐC ĐỘ VÀ TORQUE CHO TỪNG TRỤC *)
IF State_Machine = 0 THEN
    (* KHI MÁY DỪNG: KIỂM TRA CHẾ ĐỘ TEST RIÊNG BIỆT TỪNG TRỤC HOẶC BÒ CHẬM RỬA MÁY *)
    
    (* Trục Master X2 *)
    IF HMI_Test_X2 THEN Calc_Speed_X2 := Test_Speed_X2; ELSE Calc_Speed_X2 := 0; END_IF;
    
    (* Trục Kéo X1 *)
    IF HMI_Test_X1 THEN Calc_Speed_X1 := Test_Speed_X1; ELSE Calc_Speed_X1 := 0; END_IF;

    (* Trục Ghép Ms *)
    IF HMI_Test_Ms THEN
        Calc_Speed_Ms := Test_Speed_Ms;
    ELSIF Anti_Dry_Rotate_Ms THEN
        Calc_Speed_Ms := (Anti_Dry_Crawl_Speed * 4000) / Max_Speed_MPM;
    ELSE
        Calc_Speed_Ms := 0;
    END_IF;

    (* Trục Dầu S *)
    IF HMI_Test_S THEN
        Calc_Speed_S := Test_Speed_S;
    ELSIF Anti_Dry_Rotate_S THEN
        Calc_Speed_S := (Anti_Dry_Crawl_Speed * 4000) / Max_Speed_MPM;
    ELSE
        Calc_Speed_S := 0;
    END_IF;

    (* Trục Thu T (Tốc độ & Torque) *)
    IF HMI_Test_T THEN
        Calc_Speed_T  := Test_Speed_T;
        Calc_Torque_T := Test_Torque_T;
    ELSE
        Calc_Speed_T  := 0;
        Calc_Torque_T := 0;
    END_IF;

    (* Thắng Từ M *)
    IF HMI_Test_M THEN
        Calc_Torque_M := Test_Torque_M;
    ELSIF Hold_Torque_Stop_M THEN
        Calc_Torque_M := Base_Torque_M;
    ELSE
        Calc_Torque_M := 0;
    END_IF;

    (* Trục Xả U *)
    IF HMI_Test_U THEN
        Calc_Speed_U := Test_Speed_U;
    ELSIF Hold_Torque_Stop_U THEN
        Calc_Speed_U := Init_Holding_Torque_U;
    ELSE
        Calc_Speed_U := 0;
    END_IF;

ELSE
    (* KHI MÁY CHẠY TỰ ĐỘNG *)
    Calc_Speed_X2 := SP_Speed_X2 + PID_Out_X2;
    Calc_Speed_X1 := SP_Speed_X1 + PID_Out_X1;
    Calc_Speed_Ms := SP_Speed_Ms + PID_Out_Ms;
    Calc_Speed_S  := SP_Speed_S  + PID_Out_S;
    Calc_Speed_T  := SP_Speed_T;
    Calc_Torque_T := SP_Tension_T + PID_Out_T; (* Trục T kéo nhanh hơn để giữ Torque *)

    IF Real_Dia_U_mm > 0 THEN
        Calc_Speed_U := ((Calc_Speed_X2 * Max_Dia_U_mm) / Real_Dia_U_mm) + PID_Out_U;
    ELSE
        Calc_Speed_U := Calc_Speed_X2 + PID_Out_U;
    END_IF;

    (* 3 Pha Torque Thắng M *)
    IF Rev_Count_M <= 5 THEN
        Base_Torque_M := Init_Holding_Torque_M;
    ELSE
        Base_Torque_M := Min_Torque_M + (((Max_Torque_M - Min_Torque_M) * (Real_Dia_M_mm - Core_Dia_M_mm)) / (Max_Dia_M_mm - Core_Dia_M_mm));
    END_IF;
    Calc_Torque_M := Base_Torque_M + PID_Out_M;
END_IF;

(* KHỐNG CHẾ BIÊN AN TOÀN 0..4000 CHO TOÀN BỘ 8 KÊNH DAC *)
IF Calc_Speed_T  < 0 THEN Calc_Speed_T  := 0; ELSIF Calc_Speed_T  > 4000 THEN Calc_Speed_T  := 4000; END_IF;
IF Calc_Torque_T < 0 THEN Calc_Torque_T := 0; ELSIF Calc_Torque_T > 4000 THEN Calc_Torque_T := 4000; END_IF;
IF Calc_Speed_X1 < 0 THEN Calc_Speed_X1 := 0; ELSIF Calc_Speed_X1 > 4000 THEN Calc_Speed_X1 := 4000; END_IF;
IF Calc_Speed_X2 < 0 THEN Calc_Speed_X2 := 0; ELSIF Calc_Speed_X2 > 4000 THEN Calc_Speed_X2 := 4000; END_IF;
IF Calc_Speed_Ms < 0 THEN Calc_Speed_Ms := 0; ELSIF Calc_Speed_Ms > 4000 THEN Calc_Speed_Ms := 4000; END_IF;
IF Calc_Torque_M < 0 THEN Calc_Torque_M := 0; ELSIF Calc_Torque_M > 4000 THEN Calc_Torque_M := 4000; END_IF;
IF Calc_Speed_S  < 0 THEN Calc_Speed_S  := 0; ELSIF Calc_Speed_S  > 4000 THEN Calc_Speed_S  := 4000; END_IF;
IF Calc_Speed_U  < 0 THEN Calc_Speed_U  := 0; ELSIF Calc_Speed_U  > 4000 THEN Calc_Speed_U  := 4000; END_IF;

(* 12. THỰC THI FB CC-LINK XUẤT ÁP 8 KÊNH DAC *)
fbCCLink(
    Enable          := TRUE,
    ResetErr        := HMI_Reset_Error,
    Auto_Mode       := HMI_Auto_Mode,
    Set_Speed_T     := DINT_TO_WORD(Calc_Speed_T),
    Set_Torque_T    := DINT_TO_WORD(Calc_Torque_T),
    Set_Speed_X1    := DINT_TO_WORD(Calc_Speed_X1),
    Set_Speed_X2    := DINT_TO_WORD(Calc_Speed_X2),
    Set_Speed_Ms    := DINT_TO_WORD(Calc_Speed_Ms),
    Set_Torque_M    := DINT_TO_WORD(Calc_Torque_M),
    Set_Speed_S     := DINT_TO_WORD(Calc_Speed_S),
    Set_Speed_U     := DINT_TO_WORD(Calc_Speed_U)
);

(* 13. TỰ ĐỘNG BÁO GIẢM TỐC KHI GẦN ĐẠT CHIỀU DÀI MÉT CÀI ĐẶT *)
IF Set_Target_Length > 0 AND Decel_Distance_Meters > 0 THEN
    IF Total_Length_Meters >= (Set_Target_Length - Decel_Distance_Meters) THEN
        Auto_Decel_Flag := TRUE;
        IF Target_Line_MPM > Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
    ELSE
        Auto_Decel_Flag := FALSE;
    END_IF;
END_IF;
