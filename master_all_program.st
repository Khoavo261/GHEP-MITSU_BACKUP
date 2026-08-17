(* ============================================================================ *)
(* BỘ MÃ NGUỒN GỘP HOÀN CHỈNH TẤT CẢ CHƯƠNG TRÌNH & FUNCTION BLOCK MÁY GHÉP     *)
(* DỰ ÁN: GHEP-MITSU_BACKUP (PLC MITSUBISHI Q02UCPU + CC-LINK)                   *)
(* TÍCH HỢP ĐẦY ĐỦ PHẦN CỨNG THỰC TẾ:                                            *)
(*   1. 5 INPUT SERVO READY (X40..X44) -> NẾU 1 TRỤC NO READY NGẮT DỪNG KHẨN MÁY *)
(*   2. 5 OUTPUT SERVO ON (Y47..Y4B TRÊN QY40)                                  *)
(*   3. CÔNG TẮC GIỮ TORQUE THẮNG M (X45) & XẢ U (X46) CHỐNG TRÙNG MÀNG          *)
(*   4. CÔNG TẮC BÒ CHẬM RỬA MÁY MS (X47) & S (X48) KHI DỪNG MÁY                 *)
(*   5. 2 PEN ÉP MÀNG (Y66, Y67) ĐIỀU KHIỂN TOGGLE (X52, X53) & TỰ NHẢ KHI TỐC CHẬM*)
(*   6. TÍNH ĐƯỜNG KÍNH T THEO ENCODER T & GEAR RATIO T                          *)
(*   7. TÍNH ĐƯỜNG KÍNH M VÀ U THEO 2 CẢM BIẾN TIỆM CẬN X50 & X51                *)
(*   8. NÚT NHẤN VẬT LÝ X49 (START), X4A (STOP), X4B (INC), X4C (DEC)            *)
(*   9. THỜI GIAN GIỮ PHÍM INC/DEC TĂNG/GIẢM TỐC LŨY TIẾN LÊN MAX SPEED         *)
(*  10. CÔN LỰC TAPER TENSION THU T CHỐNG MÓP CUỘN MÀNG                         *)
(* ============================================================================ *)

(******************************************************************************)
(* PHẦN 1: FUNCTION BLOCK 1 - FB_TENSION_PID                                  *)
(* (TẠO TRONG NHÁNH FB/FUN -> ĐẶT TÊN "FB_TENSION_PID")                       *)
(******************************************************************************)

(* --- MÃ ST CHÍNH DÁN VÀO CỬA SỔ FB_TENSION_PID --- *)
IF NOT Enable THEN
    PID_Output := 0;
    I_Term     := 0;
    Error_Prev := 0;
    RETURN;
END_IF;

IF Reset THEN
    I_Term     := 0;
    Error_Prev := 0;
    PID_Output := 0;
    RETURN;
END_IF;

(* 1. Tính độ lệch Error *)
Error := Setpoint - Feedback;

(* 2. Bộ lọc vùng chết Deadband *)
IF ABS(Error) <= Deadband THEN
    Error := 0;
END_IF;

(* 3. Proportional (P) *)
P_Term := (Error * Kp) / 100;

(* 4. Integral (I) có Anti-Windup *)
I_Term := I_Term + ((Error * Ki) / 100);

IF I_Term > Out_Max THEN
    I_Term := Out_Max;
ELSIF I_Term < Out_Min THEN
    I_Term := Out_Min;
END_IF;

(* 5. Derivative (D) *)
D_Term := ((Error - Error_Prev) * Kd) / 100;
Error_Prev := Error;

(* 6. Tổng hợp PID Output *)
PID_Output := P_Term + I_Term + D_Term;

IF PID_Output > Out_Max THEN
    PID_Output := Out_Max;
ELSIF PID_Output < Out_Min THEN
    PID_Output := Out_Min;
END_IF;


(******************************************************************************)
(* PHẦN 2: FUNCTION BLOCK 2 - FFB_METALIZE_CONTROL (FFB_CCLINK_CONTROL)       *)
(* (TẠO TRONG NHÁNH FB/FUN -> ĐẶT TÊN "FFB_CCLINK_CONTROL")                   *)
(******************************************************************************)

(* --- MÃ ST CỦA FFB_CCLINK_CONTROL --- *)
IF Enable THEN
    (* 1. KIỂM TRA TRẠNG THÁI MẠNG CC-LINK (SB0020=0 và SB0049=0 là bình thường) *)
    CCLink_OK := (NOT SB0020) AND (NOT SB0049);
    HasError  := SB0020 OR SB0049 OR M1032 OR M1066;

    M1208 := CCLink_OK;  (* RY8: AD Conversion Enable *)
    M1240 := CCLink_OK;  (* RY28: DA Conversion Enable *)

    (* 2. ĐỌC 4 KÊNH ANALOG INPUT (AJ65SBT-64AD - TRẠM 1) *)
    IF M1016 THEN (* RX8: AD Conversion Completed *)
        ADC_CH1_Raw := D500;
        ADC_CH2_Raw := D501;
        ADC_CH3_Raw := D502;
        ADC_CH4_Raw := D503;

        (* Quy đổi sang 0..1000 (0.0% .. 100.0%) *)
        ADC_CH1_Val := INT_TO_WORD(WORD_TO_INT(D500) * 1000 / 4000);
        ADC_CH2_Val := INT_TO_WORD(WORD_TO_INT(D501) * 1000 / 4000);
        ADC_CH3_Val := INT_TO_WORD(WORD_TO_INT(D502) * 1000 / 4000);
        ADC_CH4_Val := INT_TO_WORD(WORD_TO_INT(D503) * 1000 / 4000);
    END_IF;

    (* 3. GHI 8 KÊNH ANALOG OUTPUT (AJ65VBTCU-68DAVN - TRẠM 2 & 3) *)
    (* QUY ĐỔI LỆNH 0..1000 RA DẢI DAC 0..4000 *)
    D524 := INT_TO_WORD(WORD_TO_INT(Set_Speed_T)  * 4000 / 1000);
    D525 := INT_TO_WORD(WORD_TO_INT(Set_Torque_T) * 4000 / 1000);
    D526 := INT_TO_WORD(WORD_TO_INT(Set_Speed_X1) * 4000 / 1000);
    D527 := INT_TO_WORD(WORD_TO_INT(Set_Speed_X2) * 4000 / 1000);
    D528 := INT_TO_WORD(WORD_TO_INT(Set_Speed_Ms) * 4000 / 1000);
    D529 := INT_TO_WORD(WORD_TO_INT(Set_Torque_M) * 4000 / 1000);
    D530 := INT_TO_WORD(WORD_TO_INT(Set_Speed_S)  * 4000 / 1000);
    D531 := INT_TO_WORD(WORD_TO_INT(Set_Speed_U)  * 4000 / 1000);

    (* 4. XỬ LÝ DIGITAL REMOTE I/O (AJ65SBTB1-16DT: X0..X7 = M1104..M1111 | Y8..YF = M1304..M1311) *)
    DI_X0_State := M1104;
    DI_X1_State := M1105;

    (* Ngõ ra Y8..YF (M1304..M1311) để HMI / User tự set ON/OFF trực tiếp *)

    (* 5. RESET LỖI *)
    M1226 := ResetErr OR M1111; (* RY1A: Reset lỗi trạm 1 *)
    M1258 := ResetErr OR M1111; (* RY3A: Reset lỗi trạm 2 *)
END_IF;


(******************************************************************************)
(* PHẦN 3: PROGRAM CHÍNH - POU_01 (POU_MAIN_METALIZE)                         *)
(* (DÁN VÀO CỬA SỔ POU -> Program -> POU_01)                                   *)
(******************************************************************************)

(* 0. KHỐI KHAI BÁO TỶ SỐ TRUYỀN HỘP SỐ GEAR RATIO ĐỂ RIÊNG ĐỂ DỄ CHỈNH *)
IF Gear_Ratio_T  <= 0 THEN Gear_Ratio_T  := 10100; END_IF; (* Tỷ số truyền 10.1:1 cuộn Thu T *)
IF Gear_Ratio_X1 <= 0 THEN Gear_Ratio_X1 := 8000;  END_IF; (* Tỷ số truyền 8.0:1 kéo X1 *)
IF Gear_Ratio_X2 <= 0 THEN Gear_Ratio_X2 := 8000;  END_IF; (* Tỷ số truyền 8.0:1 Master X2 *)
IF Gear_Ratio_Ms <= 0 THEN Gear_Ratio_Ms := 10000; END_IF; (* Tỷ số truyền 10.0:1 Ghép Ms *)
IF Gear_Ratio_S  <= 0 THEN Gear_Ratio_S  := 10000; END_IF; (* Tỷ số truyền 10.0:1 Dầu S *)
IF Gear_Ratio_U  <= 0 THEN Gear_Ratio_U  := 1000;  END_IF; (* Tỷ số truyền 1.0:1 Xả U *)

(* BẢO VỆ CHỐNG LỖI CHIA CHO 0 & KHỞI TẠO MẶC ĐỊNH *)
IF Max_Speed_MPM <= 0 THEN Max_Speed_MPM := 1000; END_IF;
IF Core_Dia_T_mm <= 0 THEN Core_Dia_T_mm := 76; END_IF;
IF Core_Dia_M_mm <= 0 THEN Core_Dia_M_mm := 76; END_IF;
IF Core_Dia_U_mm <= 0 THEN Core_Dia_U_mm := 76; END_IF;
IF Max_Dia_M_mm  <= 0 THEN Max_Dia_M_mm  := 600; END_IF;
IF Max_Dia_U_mm  <= 0 THEN Max_Dia_U_mm  := 800; END_IF;

IF Speed_Ratio_Ms   <= 0 THEN Speed_Ratio_Ms   := 1000; END_IF; (* Mặc định 100.0% *)
IF Dia_Ms_Roller_mm <= 0 THEN Dia_Ms_Roller_mm := 2000; END_IF; (* Mặc định lô Ms 200.0 mm *)
IF Dia_X2_Roller_mm <= 0 THEN Dia_X2_Roller_mm := 3005; END_IF; (* Mặc định lô X2 300.5 mm *)
IF Decel_Distance_Meters <= 0 THEN Decel_Distance_Meters := 50; END_IF; (* Báo giảm tốc trước 50m *)

IF Ramp_Accel_Rate <= 0 THEN Ramp_Accel_Rate := 5; END_IF;  (* Tăng tốc 5 m/phút mỗi giây *)
IF Ramp_Decel_Rate <= 0 THEN Ramp_Decel_Rate := 10; END_IF; (* Giảm tốc 10 m/phút mỗi giây *)
IF Release_Pen_Speed_MPM <= 0 THEN Release_Pen_Speed_MPM := 20; END_IF; (* 2.0 m/p tự nhả 2 pen *)

(* 1. KIỂM TRA BẢO VỆ 5 TRỤC SERVO READY TRÊN MODULE 16DT (X0..X4 = M1104..M1108) *)
Servo_Not_Ready_Fault := NOT(Servo_Ready_T) OR NOT(Servo_Ready_X1) OR NOT(Servo_Ready_X2) OR NOT(Servo_Ready_Ms) OR NOT(Servo_Ready_S);

IF Servo_Not_Ready_Fault THEN
    State_Machine := 0; (* Ngắt về trạng thái STOPPED khẩn cấp *)
END_IF;

(* 2. ĐIỀU KHIỂN CÔNG TẮC GIỮ TORQUE VÀ CÔNG TẮC BÒ CHẬM RỬA MÁY TRÊN QX40 (X58..X5B) *)
Hold_Torque_Stop_M := Switch_Hold_M;   (* X58 trên QX40 *)
Hold_Torque_Stop_U := Switch_Hold_U;   (* X59 trên QX40 *)
Anti_Dry_Rotate_Ms := Switch_Wash_Ms;  (* X5A trên QX40 *)
Anti_Dry_Rotate_S  := Switch_Wash_S;   (* X5B trên QX40 *)

(* 3. NẠP LẠI ĐƯỜNG KÍNH KHI NẠP CUỘN MỚI *)
IF HMI_Reset_Roll_T THEN Real_Dia_T_mm := Core_Dia_T_mm; HMI_Reset_Roll_T := FALSE; END_IF;
IF HMI_Reset_Roll_M THEN Real_Dia_M_mm := Max_Dia_M_mm;  HMI_Reset_Roll_M := FALSE; END_IF;
IF HMI_Reset_Roll_U THEN Real_Dia_U_mm := Max_Dia_U_mm;  HMI_Reset_Roll_U := FALSE; END_IF;

(* 4. TỔNG HỢP NÚT NHẤN HMI & NÚT NHẤN VẬT LÝ (X49, X4A, X4B, X4C) *)
Cmd_Start := HMI_Start OR Physical_Start_PB;
Cmd_Stop  := HMI_Stop OR Physical_Stop_PB OR Servo_Not_Ready_Fault;
Cmd_Inc   := HMI_Inc_Hold OR Physical_Inc_PB;
Cmd_Dec   := HMI_Dec_Hold OR Physical_Dec_PB;

(* 5. ĐIỀU KHIỂN TOGGLE 2 PEN ÉP MÀNG (Y66, Y67) & TỰ NHẢ KHI TỐC CHẬM *)
Trig_Pen1 := (Pen1_Toggle_PB AND NOT(Prev_Pen1_PB)) OR HMI_Pen1_Cmd;
Prev_Pen1_PB := Pen1_Toggle_PB;
IF HMI_Pen1_Cmd THEN HMI_Pen1_Cmd := FALSE; END_IF;
IF Trig_Pen1 THEN Pen1_State := NOT(Pen1_State); END_IF;

Trig_Pen2 := (Pen2_Toggle_PB AND NOT(Prev_Pen2_PB)) OR HMI_Pen2_Cmd;
Prev_Pen2_PB := Pen2_Toggle_PB;
IF HMI_Pen2_Cmd THEN HMI_Pen2_Cmd := FALSE; END_IF;
IF Trig_Pen2 THEN Pen2_State := NOT(Pen2_State); END_IF;

(* TỰ ĐỘNG NHẢ 2 PEN KHI MÁY GIẢM VỀ TỐC ĐỘ CHẬM HOẶC DỪNG MÁY *)
IF Current_Line_MPM <= Release_Pen_Speed_MPM OR State_Machine = 0 THEN
    Pen1_State := FALSE;
    Pen2_State := FALSE;
END_IF;

(* XUẤT 2 ĐẦU RA PEN ÉP MÀNG RA MODULE 16DT CC-LINK (YD=M1309, YE=M1310) *)
M1309 := Pen1_State; (* Ngõ ra Pen 1 -> Cọc YD (Cọc 6) trên Module 16DT *)
M1310 := Pen2_State; (* Ngõ ra Pen 2 -> Cọc YE (Cọc 7) trên Module 16DT *)

(* 6. TĂNG GIẢM TỐC LŨY TIẾN THEO THỜI GIAN GIỮ PHÍM INC / DEC *)
IF Cmd_Inc THEN
    Inc_Hold_Timer := Inc_Hold_Timer + 1;
    IF Inc_Hold_Timer < 50 THEN
        Dynamic_Accel_Step := Ramp_Accel_Rate;
    ELSIF Inc_Hold_Timer < 150 THEN
        Dynamic_Accel_Step := Ramp_Accel_Rate * 2;
    ELSE
        Dynamic_Accel_Step := Ramp_Accel_Rate * 5; (* Bấm giữ lâu tăng tốc vọt lên *)
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
        Dynamic_Accel_Step := Ramp_Decel_Rate * 5; (* Bấm giữ lâu giảm tốc vọt xuống *)
    END_IF;
    Target_Line_MPM := Target_Line_MPM - Dynamic_Accel_Step;
    IF Target_Line_MPM < Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
ELSE
    Dec_Hold_Timer := 0;
END_IF;

(* Ramping tốc độ hiện tại tiến dần đến tốc độ mục tiêu *)
IF Current_Line_MPM < Target_Line_MPM THEN
    Current_Line_MPM := Current_Line_MPM + Ramp_Accel_Rate;
    IF Current_Line_MPM > Target_Line_MPM THEN Current_Line_MPM := Target_Line_MPM; END_IF;
ELSIF Current_Line_MPM > Target_Line_MPM THEN
    Current_Line_MPM := Current_Line_MPM - Ramp_Decel_Rate;
    IF Current_Line_MPM < Target_Line_MPM THEN Current_Line_MPM := Target_Line_MPM; END_IF;
END_IF;

(* 7. TÍNH ĐƯỜNG KÍNH THỰC TẾ 3 CUỘN T, M, U *)
(* --- 7A. Tính đường kính cuộn Thu T theo Encoder T & Gear_Ratio_T --- *)
Curr_Pulse_T  := INT_TO_DINT(D5000); (* Đọc từ High-speed Counter QD62 Module *)
Curr_Pulse_X2 := INT_TO_DINT(D5002); (* Đọc xung Master X2 Encoder *)

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

(* --- 7B. Tính đường kính cuộn M theo cảm biến tiệm cận X50 --- *)
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

(* --- 7C. Tính đường kính cuộn U theo cảm biến tiệm cận X51 --- *)
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

(* TẬP TRUNG TÍN HIỆU 5 TRỤC SERVO ON XUẤT RA MODULE 16DT CC-LINK (Y8..YC = M1304..M1308) *)
M1304 := (State_Machine = 1);                                                (* Y8 (Cọc 1): Servo ON Thu T *)
M1305 := (State_Machine = 1);                                                (* Y9 (Cọc 2): Servo ON Xả X1 *)
M1306 := (State_Machine = 1);                                                (* YA (Cọc 3): Servo ON Master X2 *)
M1307 := (State_Machine = 1) OR (State_Machine = 0 AND Anti_Dry_Rotate_Ms);  (* YB (Cọc 4): Servo ON Ghép Ms *)
M1308 := (State_Machine = 1) OR (State_Machine = 0 AND Anti_Dry_Rotate_S);   (* YC (Cọc 5): Servo ON Tráng Dầu S *)

Servo_ON_T  := M1304;
Servo_ON_X1 := M1305;
Servo_ON_X2 := M1306;
Servo_ON_Ms := M1307;
Servo_ON_S  := M1308;

(* 9. TÍNH CÔN LỰC TAPER TENSION CHO CUỘN THU T *)
IF (Max_Dia_T_mm - Core_Dia_T_mm) > 0 AND Taper_Percent_T > 0 THEN
    Effective_SP_T := SP_Tension_T - (((Real_Dia_T_mm - Core_Dia_T_mm) * SP_Tension_T * Taper_Percent_T) / ((Max_Dia_T_mm - Core_Dia_T_mm) * 100));
ELSE
    Effective_SP_T := SP_Tension_T;
END_IF;

IF Effective_SP_T < 0 THEN Effective_SP_T := 0; END_IF;

(* 9B. TÍNH TỐC ĐỘ MỤC TIÊU CHO TRỤC TRÁNG DẦU S (TỐC ĐỘ ĐẶT = MASTER X TỶ LỆ + BÙ TỐC) *)
SP_Speed_S := ((Calc_Speed_X2 * Speed_Ratio_S) / 1000) + Speed_Offset_S;

(* TẠO XUNG KÍCH HOẠT PID CHUẨN 10MS TỪ SM409 (0.01s CLOCK) *)
Trig_PID_10ms := SM409 AND NOT(Prev_SM409);
Prev_SM409 := SM409;

(* 10. GỌI RUN 5 INSTANCE PID MỖI CHU KỲ 10MS (4 PID LỰC CĂNG + 1 PID TỐC ĐỘ TRỤC S) *)
IF Trig_PID_10ms THEN
    (* 4 Khối PID Lực căng Loadcell (T, X1, M, U) *)
    pid_T(Enable := HMI_PID_Enable, Setpoint := Effective_SP_T, Feedback := Weight_Net_T, Kp := Kp_T, Ki := Ki_T, Kd := Kd_T);
    pid_X1(Enable := HMI_PID_Enable, Setpoint := SP_Tension_X1, Feedback := Weight_Net_X1, Kp := Kp_X1, Ki := Ki_X1, Kd := Kd_X1);
    pid_M(Enable := HMI_PID_Enable, Setpoint := SP_Tension_M, Feedback := Weight_Net_M, Kp := Kp_M, Ki := Ki_M, Kd := Kd_M);
    pid_U(Enable := HMI_PID_Enable, Setpoint := SP_Tension_U, Feedback := Weight_Net_U, Kp := Kp_U, Ki := Ki_U, Kd := Kd_U);

    (* 1 Khối PID Tốc độ chuyên dụng cho Trục Tráng Dầu S *)
    pid_S(Enable := HMI_PID_Enable, Setpoint := SP_Speed_S, Feedback := Feedback_Speed_S, Kp := Kp_S, Ki := Ki_S, Kd := Kd_S);

    PID_Out_T  := pid_T.PID_Output;
    PID_Out_X1 := pid_X1.PID_Output;
    PID_Out_M  := pid_M.PID_Output;
    PID_Out_U  := pid_U.PID_Output;
    PID_Out_S  := pid_S.PID_Output;
END_IF;

(* 11. TÍNH TOÁN CÁC GIÁ TRỊ TỐC ĐỘ VÀ TORQUE TỪ BIẾN LOCAL PID *)
IF State_Machine = 0 THEN
    Calc_Speed_T  := 0;
    Calc_Speed_X1 := 0;

    IF Anti_Dry_Rotate_Ms THEN
        Calc_Speed_Ms := (Anti_Dry_Crawl_Speed * 4000) / Max_Speed_MPM;
    ELSE
        Calc_Speed_Ms := 0;
    END_IF;

    IF Anti_Dry_Rotate_S THEN
        Calc_Speed_S := (Anti_Dry_Crawl_Speed * 4000) / Max_Speed_MPM;
    ELSE
        Calc_Speed_S := 0;
    END_IF;

    IF Hold_Torque_Stop_M THEN
        Calc_Torque_M := Base_Torque_M;
    ELSE
        Calc_Torque_M := 0;
    END_IF;

    IF Hold_Torque_Stop_U THEN
        Calc_Speed_U := Init_Holding_Torque_U;
    ELSE
        Calc_Speed_U := 0;
    END_IF;
ELSE
    (* CHẠY TỰ ĐỘNG *)
    IF Dia_X2_Roller_mm > 0 THEN 
        Calc_Speed_Ms := (((Calc_Speed_X2 * Dia_Ms_Roller_mm) / Dia_X2_Roller_mm) * Speed_Ratio_Ms) / 1000;
    ELSE 
        Calc_Speed_Ms := Calc_Speed_X2; 
    END_IF;

    IF Real_Dia_T_mm > 0 THEN 
        Calc_Speed_T := ((Calc_Speed_X2 * Real_Dia_T_mm) / Core_Dia_T_mm) + PID_Out_T; 
    ELSE 
        Calc_Speed_T := Calc_Speed_X2 + PID_Out_T; 
    END_IF;

    Calc_Speed_X1 := Calc_Speed_X2 + PID_Out_X1;
    
    (* TRỤC TRÁNG DẦU S: TỐC ĐỘ NỀN (RATIO + OFFSET) + BÙ VI SAI TỪ PID TỐC ĐỘ (PID_OUT_S) *)
    Calc_Speed_S := SP_Speed_S + PID_Out_S;
    IF Calc_Speed_S < 0 THEN Calc_Speed_S := 0; END_IF;
    IF Calc_Speed_S > 4000 THEN Calc_Speed_S := 4000; END_IF;

    IF Real_Dia_U_mm > 0 THEN 
        Calc_Speed_U := ((Calc_Speed_X2 * Max_Dia_U_mm) / Real_Dia_U_mm) + PID_Out_U; 
    ELSE 
        Calc_Speed_U := Calc_Speed_X2 + PID_Out_U; 
    END_IF;

    Calc_Torque_M := Base_Torque_M + PID_Out_M;
END_IF;

(* 12. Thực thi FB CC-Link Master với Ép kiểu DINT_TO_WORD *)
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

(* 13. TỰ ĐỘNG BÁO GIẢM TỐC KHI GẦN ĐẠT CHIỀU DÀI MÉT CÀI ĐẶT *)
IF Set_Target_Length > 0 AND Decel_Distance_Meters > 0 THEN
    IF Total_Length_Meters >= (Set_Target_Length - Decel_Distance_Meters) THEN
        Auto_Decel_Flag := TRUE;
        IF Target_Line_MPM > Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
    ELSE
        Auto_Decel_Flag := FALSE;
    END_IF;
END_IF;

(* 14. TÍNH TỐC ĐỘ MASTER X2 *)
Calc_Speed_X2 := (Current_Line_MPM * 4000) / Max_Speed_MPM;
