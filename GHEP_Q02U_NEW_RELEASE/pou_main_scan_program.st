(* ============================================================================ *)
(* POU_MAIN_SCAN: CHƯƠNG TRÌNH CHÍNH QUÉT BÌNH THƯỜNG (SCAN EXECUTION < 1MS)    *)
(* CẤU HÌNH TRONG GX WORKS2:                                                    *)
(*   - PLC Parameter -> Program Setting -> Program Name: POU_MAIN (hoặc POU_01) *)
(*   - Execution Type: SCAN                                                     *)
(* TÁC VỤ:                                                                      *)
(*   - Đọc xung đếm tức thời QD62D (D520..D526)                                 *)
(*   - Đọc & Lọc tín hiệu Analog CC-Link ADC (Loadcell T, X1, M, U)              *)
(*   - Giám sát 5 trục Servo Ready, Nút nhấn, Cảm biến, Recipe                  *)
(*   - Đo chiều dài mét màng, Điều khiển Pen ép, State Machine Run/Stop         *)
(*   - Xử lý mượt mà, thời gian quét cực nhẹ < 0.5ms                            *)
(* ============================================================================ *)

(* ============================================================================ *)
(* 1. KÍCH HOẠT VÀ ĐỌC 5 KÊNH ENCODER QD62 & QD62D (SLOT 1, 2, 3) MỖI SCAN      *)
(* ============================================================================ *)
Y14 := TRUE; (* QD62 Slot 1 (H10) CH1 Count Enable: Trục Lô Dầu S *)
Y24 := TRUE; (* QD62D Slot 2 (H20) CH1 Count Enable: Trục Thu T *)
Y2C := TRUE; (* QD62D Slot 2 (H20) CH2 Count Enable: Trục Kéo X1 *)
Y34 := TRUE; (* QD62D Slot 3 (H30) CH1 Count Enable: Trục Master X2 *)
Y3C := TRUE; (* QD62D Slot 3 (H30) CH2 Count Enable: Trục Ghép Ms *)

(* Cờ Yx6/YxE là lệnh chốt mềm (Software trigger), PHẢI ĐỂ FALSE để nhường quyền cho chân phần cứng FUNC *)
Y16 := FALSE; (* Slot 1 CH1: Trục Lô Dầu S *)
Y26 := FALSE; (* Slot 2 CH1: Trục Thu T *)
Y2E := FALSE; (* Slot 2 CH2: Trục Kéo X1 *)
Y36 := FALSE; (* Slot 3 CH1: Trục Master X2 *)
Y3E := FALSE; (* Slot 3 CH2: Trục Ghép Ms *)

(* Đọc xung 32-bit từ Buffer Memory QD62 & QD62D: Ghi trực tiếp vào Curr_Pulse (D520..D528) *)
DMOV(TRUE, U1\G2,  Curr_Pulse_S);  (* Slot 1 CH1: Trục Lô Dầu S (D528 - DINT 32-bit) *)
DMOV(TRUE, U2\G2,  Curr_Pulse_T);  (* Slot 2 CH1: Trục Thu T (D520 - DINT 32-bit) *)
DMOV(TRUE, U2\G34, Curr_Pulse_X1); (* Slot 2 CH2: Trục Kéo X1 (D522 - DINT 32-bit) *)
DMOV(TRUE, U3\G2,  Curr_Pulse_X2); (* Slot 3 CH1: Trục Master X2 (D524 - DINT 32-bit) *)
DMOV(TRUE, U3\G34, Curr_Pulse_Ms); (* Slot 3 CH2: Trục Ghép Ms (D526 - DINT 32-bit) *)

Total_PPR := 8000;

(* ============================================================================ *)
(* 1.1. CHỐT XUNG PHA Z VÀ ĐẾM 1 XUNG/VÒNG CHO 5 TRỤC (LATCH COUNTER FUNCTION)  *)
(* ============================================================================ *)

(* --- TRỤC 1: THU T (SLOT 2 CH1 - BUFFER LATCH G12..G13 - DINT 32-BIT) --- *)
DMOV(TRUE, U2\G12, Latched_Pulse_T);
IF (Latched_Pulse_T <> Prev_Latch_T) AND (Latched_Pulse_T <> 0) THEN
    Real_PPR_T   := ABS(Latched_Pulse_T - Prev_Latch_T);
    Rev_Count_T  := Rev_Count_T + 1;
    Prev_Latch_T := Latched_Pulse_T;
ELSIF Total_PPR > 0 AND (Curr_Pulse_T / Total_PPR) > Rev_Count_T THEN
    (* Dự phòng nếu chưa kích chốt Pha Z *)
    Rev_Count_T := Curr_Pulse_T / Total_PPR;
END_IF;

(* --- TRỤC 2: KÉO X1 (SLOT 2 CH2 - BUFFER LATCH G44..G45 - DINT 32-BIT) --- *)
DMOV(TRUE, U2\G44, Latched_Pulse_X1);
IF (Latched_Pulse_X1 <> Prev_Latch_X1) AND (Latched_Pulse_X1 <> 0) THEN
    Real_PPR_X1   := ABS(Latched_Pulse_X1 - Prev_Latch_X1);
    Rev_Count_X1  := Rev_Count_X1 + 1;
    Prev_Latch_X1 := Latched_Pulse_X1;
ELSIF Total_PPR > 0 AND (Curr_Pulse_X1 / Total_PPR) > Rev_Count_X1 THEN
    Rev_Count_X1 := Curr_Pulse_X1 / Total_PPR;
END_IF;

(* --- TRỤC 3: MASTER X2 (SLOT 3 CH1 - BUFFER LATCH G12..G13 - DINT 32-BIT) --- *)
DMOV(TRUE, U3\G12, Latched_Pulse_X2);
IF (Latched_Pulse_X2 <> Prev_Latch_X2) AND (Latched_Pulse_X2 <> 0) THEN
    Real_PPR_X2   := ABS(Latched_Pulse_X2 - Prev_Latch_X2);
    Rev_Count_X2  := Rev_Count_X2 + 1;
    Prev_Latch_X2 := Latched_Pulse_X2;
ELSIF Total_PPR > 0 AND (Curr_Pulse_X2 / Total_PPR) > Rev_Count_X2 THEN
    Rev_Count_X2 := Curr_Pulse_X2 / Total_PPR;
END_IF;

(* --- TRỤC 4: GHÉP MS (SLOT 3 CH2 - BUFFER LATCH G44..G45 - DINT 32-BIT) --- *)
DMOV(TRUE, U3\G44, Latched_Pulse_Ms);
IF (Latched_Pulse_Ms <> Prev_Latch_Ms) AND (Latched_Pulse_Ms <> 0) THEN
    Real_PPR_Ms   := ABS(Latched_Pulse_Ms - Prev_Latch_Ms);
    Rev_Count_Ms  := Rev_Count_Ms + 1;
    Prev_Latch_Ms := Latched_Pulse_Ms;
ELSIF Total_PPR > 0 AND (Curr_Pulse_Ms / Total_PPR) > Rev_Count_Ms THEN
    Rev_Count_Ms := Curr_Pulse_Ms / Total_PPR;
END_IF;

(* --- TRỤC 5: LÔ DẦU S (SLOT 1 CH1 - BUFFER LATCH G12..G13 - DINT 32-BIT) --- *)
DMOV(TRUE, U1\G12, Latched_Pulse_S);
IF (Latched_Pulse_S <> Prev_Latch_S) AND (Latched_Pulse_S <> 0) THEN
    Real_PPR_S   := ABS(Latched_Pulse_S - Prev_Latch_S);
    Rev_Count_S  := Rev_Count_S + 1;
    Prev_Latch_S := Latched_Pulse_S;
ELSIF Total_PPR > 0 AND (Curr_Pulse_S / Total_PPR) > Rev_Count_S THEN
    Rev_Count_S := Curr_Pulse_S / Total_PPR;
END_IF;

(* ============================================================================ *)
(* 2. ĐỌC VÀ LỌC 8 KÊNH ANALOG INPUT TỪ TRẠM 2 CC-LINK ADC (AJ65VBTCU-68ADVN)   *)
(* ============================================================================ *)
W210 := 16#00FF; (* Bật chuyển đổi A/D cả 8 kênh CH1..CH8 *)
W211 := 16#0000; (* Range CH1..CH4: 0..10V *)
W212 := 16#0000; (* Range CH5..CH8: 0..10V *)
W213 := 16#2222; (* CH1..CH4: Chế độ 2H = Count Averaging 16 mẫu *)
W214 := 16;      (* CH1 (Thu T): Lấy trung bình 16 mẫu liên tục *)
W215 := 16;      (* CH2 (Kéo X1): Lấy trung bình 16 mẫu *)
W216 := 16;      (* CH3 (Thắng M): Lấy trung bình 16 mẫu *)
W217 := 16;      (* CH4 (Xả U): Lấy trung bình 16 mẫu *)

Y1038 := X1038;
IF NOT X1039 THEN Y1039 := FALSE; END_IF;

Y1020 := TRUE; Y1021 := TRUE; Y1022 := TRUE; Y1023 := TRUE;
Y1024 := TRUE; Y1025 := TRUE; Y1026 := TRUE; Y1027 := TRUE;

ADC_CH1_Raw := W110 * 4; (* Loadcell Lực căng Thu T *)
ADC_CH2_Raw := W111 * 4; (* Loadcell Lực căng Kéo X1 *)
ADC_CH3_Raw := W112 * 4; (* Loadcell Lực căng Thắng M *)
ADC_CH4_Raw := W113 * 4; (* Loadcell Lực căng Xả U *)
ADC_CH5_Raw := W114 * 4; (* Analog Out Tốc độ Servo Trục S *)
ADC_CH6_Raw := W115 * 4;
ADC_CH7_Raw := W116 * 4;
ADC_CH8_Raw := W117 * 4;

D500 := INT_TO_WORD(ADC_CH1_Raw);
D501 := INT_TO_WORD(ADC_CH2_Raw);
D502 := INT_TO_WORD(ADC_CH3_Raw);
D503 := INT_TO_WORD(ADC_CH4_Raw);
D504 := INT_TO_WORD(ADC_CH5_Raw);
D505 := INT_TO_WORD(ADC_CH6_Raw);
D506 := INT_TO_WORD(ADC_CH7_Raw);
D507 := INT_TO_WORD(ADC_CH8_Raw);

(* Lọc số EMA Alpha=0.15 *)
IF Calib_Gain_T <= 0.0 THEN Calib_Gain_T := 1.0; END_IF;
Weight_Net_T := Weight_Net_T + (0.15 * ((((INT_TO_REAL(ADC_CH1_Raw) - Zero_Offset_T) * Calib_Gain_T * 50.0) / 16000.0) - Weight_Net_T));
IF Weight_Net_T < 0.0 THEN Weight_Net_T := 0.0; END_IF;

IF Calib_Gain_X1 <= 0.0 THEN Calib_Gain_X1 := 1.0; END_IF;
Weight_Net_X1 := Weight_Net_X1 + (0.15 * ((((INT_TO_REAL(ADC_CH2_Raw) - Zero_Offset_X1) * Calib_Gain_X1 * 50.0) / 16000.0) - Weight_Net_X1));
IF Weight_Net_X1 < 0.0 THEN Weight_Net_X1 := 0.0; END_IF;

IF Calib_Gain_M <= 0.0 THEN Calib_Gain_M := 1.0; END_IF;
Weight_Net_M := Weight_Net_M + (0.15 * ((((INT_TO_REAL(ADC_CH3_Raw) - Zero_Offset_M) * Calib_Gain_M * 50.0) / 16000.0) - Weight_Net_M));
IF Weight_Net_M < 0.0 THEN Weight_Net_M := 0.0; END_IF;

IF Calib_Gain_U <= 0.0 THEN Calib_Gain_U := 1.0; END_IF;
Weight_Net_U := Weight_Net_U + (0.15 * ((((INT_TO_REAL(ADC_CH4_Raw) - Zero_Offset_U) * Calib_Gain_U * 50.0) / 16000.0) - Weight_Net_U));
IF Weight_Net_U < 0.0 THEN Weight_Net_U := 0.0; END_IF;

(* Xử lý Nút Set Zero Lực căng *)
IF Zero_Set_T OR (HMI_Cmd_Zero_Set AND HMI_Axis_Select = 1) THEN Zero_Offset_T := INT_TO_REAL(ADC_CH1_Raw); Zero_Set_T := FALSE; END_IF;
IF Zero_Set_X1 OR (HMI_Cmd_Zero_Set AND HMI_Axis_Select = 2) THEN Zero_Offset_X1 := INT_TO_REAL(ADC_CH2_Raw); Zero_Set_X1 := FALSE; END_IF;
IF Zero_Set_M OR (HMI_Cmd_Zero_Set AND HMI_Axis_Select = 6) THEN Zero_Offset_M := INT_TO_REAL(ADC_CH3_Raw); Zero_Set_M := FALSE; END_IF;
IF Zero_Set_U OR (HMI_Cmd_Zero_Set AND HMI_Axis_Select = 7) THEN Zero_Offset_U := INT_TO_REAL(ADC_CH4_Raw); Zero_Set_U := FALSE; END_IF;
IF HMI_Cmd_Zero_Set THEN HMI_Cmd_Zero_Set := FALSE; END_IF;

(* ============================================================================ *)
(* 3. BẢO VỆ 5 TRỤC SERVO READY TRÊN MODULE QX40 (SLOT 4 - X40..X44)            *)
(* ============================================================================ *)
Servo_Ready_T  := X40;
Servo_Ready_X1 := X41;
Servo_Ready_X2 := X42;
Servo_Ready_Ms := X43;
Servo_Ready_S  := X44;

Servo_Not_Ready_Fault := NOT(Servo_Ready_T) OR NOT(Servo_Ready_X1) OR NOT(Servo_Ready_X2) OR NOT(Servo_Ready_Ms) OR NOT(Servo_Ready_S);
IF Servo_Not_Ready_Fault AND State_Machine = 1 THEN State_Machine := 0; END_IF;

(* ============================================================================ *)
(* 4. ĐỌC NÚT NHẤN, CẢM BIẾN VÀ CÔNG TẮC GẠT TRÊN MODULE QX40                   *)
(* ============================================================================ *)
Physical_Start_PB := X45;
Physical_Stop_PB  := X46;
Physical_Inc_PB   := X47;
Physical_Dec_PB   := X48;
Physical_Jog_PB   := X49;
Pen1_Toggle_PB    := X4C;
Pen2_Toggle_PB    := X4D;
Switch_Hold_M     := X4E;
Switch_Hold_U     := X4F;

Hold_Torque_Stop_M := Switch_Hold_M;
Hold_Torque_Stop_U := Switch_Hold_U;

(* ============================================================================ *)
(* 5. QUẢN LÝ CÔNG THỨC ĐƠN HÀNG (RECIPE)                                       *)
(* ============================================================================ *)
IF HMI_Recipe_Select <= 0 OR HMI_Recipe_Select > 5 THEN HMI_Recipe_Select := 2; END_IF;

IF (HMI_Recipe_Select <> Prev_Recipe_Select) OR HMI_Cmd_Apply_Recipe THEN
    CASE HMI_Recipe_Select OF
        1: Target_Line_MPM := 45.0; SP_Tension_T := 12.0; SP_Tension_X1 := 10.0; SP_Tension_M := 4.0; SP_Tension_U := 8.0; Taper_Percent_T := 15.0; Ramp_Accel_Rate := 0.05; Ramp_Decel_Rate := 0.08;
        2: Target_Line_MPM := 50.0; SP_Tension_T := 14.0; SP_Tension_X1 := 12.0; SP_Tension_M := 5.0; SP_Tension_U := 10.0; Taper_Percent_T := 20.0; Ramp_Accel_Rate := 0.08; Ramp_Decel_Rate := 0.10;
        3: Target_Line_MPM := 40.0; SP_Tension_T := 18.0; SP_Tension_X1 := 15.0; SP_Tension_M := 7.0; SP_Tension_U := 14.0; Taper_Percent_T := 25.0; Ramp_Accel_Rate := 0.05; Ramp_Decel_Rate := 0.08;
        4: Target_Line_MPM := 60.0; SP_Tension_T := 20.0; SP_Tension_X1 := 16.0; SP_Tension_M := 8.0; SP_Tension_U := 15.0; Taper_Percent_T := 20.0; Ramp_Accel_Rate := 0.10; Ramp_Decel_Rate := 0.12;
        5: Target_Line_MPM := 35.0; SP_Tension_T := 10.0; SP_Tension_X1 := 8.0;  SP_Tension_M := 3.0; SP_Tension_U := 6.0;  Taper_Percent_T := 10.0; Ramp_Accel_Rate := 0.03; Ramp_Decel_Rate := 0.05;
    END_CASE;
    Prev_Recipe_Select  := HMI_Recipe_Select;
    HMI_Cmd_Apply_Recipe := FALSE;
END_IF;

(* ============================================================================ *)
(* 6. RESET ĐƯỜNG KÍNH VÀ CHIỀU DÀI MÀNG KHI THAY CUỘN MỚI                       *)
(* ============================================================================ *)
IF HMI_Reset_All_Rolls THEN
    Real_Dia_T_mm       := Core_Dia_T_mm;
    Real_Dia_M_mm       := Max_Dia_M_mm;
    Real_Dia_U_mm       := Max_Dia_U_mm;
    Total_Length_Meters := 0.0;
    Accum_Length_mm     := 0.0;
    HMI_Reset_All_Rolls := FALSE;
END_IF;
IF HMI_Reset_Roll_T THEN Real_Dia_T_mm := Core_Dia_T_mm; HMI_Reset_Roll_T := FALSE; END_IF;
IF HMI_Reset_Roll_M THEN Real_Dia_M_mm := Max_Dia_M_mm;  HMI_Reset_Roll_M := FALSE; END_IF;
IF HMI_Reset_Roll_U THEN Real_Dia_U_mm := Max_Dia_U_mm;  HMI_Reset_Roll_U := FALSE; END_IF;

(* ============================================================================ *)
(* 7. TỔNG HỢP NÚT NHẤN                                                         *)
(* ============================================================================ *)
Cmd_Start     := HMI_Start OR Physical_Start_PB;
Cmd_Stop      := HMI_Stop OR Physical_Stop_PB OR Servo_Not_Ready_Fault;
Cmd_Inc       := HMI_Inc_Hold OR Physical_Inc_PB;
Cmd_Dec       := HMI_Dec_Hold OR Physical_Dec_PB;
Cmd_Jog_Crawl := HMI_Jog_Crawl_Cmd OR Physical_Jog_PB;

(* ============================================================================ *)
(* 8. ĐIỀU KHIỂN 2 PEN ÉP MÀNG (ĐỒNG BỘ 100% CẢ 2 PEN - CHỐNG KẸT LỆCH PHA)   *)
(* ============================================================================ *)
(* Bắt sườn lên nút nhấn cơ tủ điện X4C/X4D hoặc nút chạm HMI M12/M13 *)
Trig_Pen1 := (Pen1_Toggle_PB AND NOT(Prev_Pen1_PB)) OR HMI_Pen1_Cmd;
Prev_Pen1_PB := Pen1_Toggle_PB;
IF HMI_Pen1_Cmd THEN HMI_Pen1_Cmd := FALSE; END_IF;

Trig_Pen2 := (Pen2_Toggle_PB AND NOT(Prev_Pen2_PB)) OR HMI_Pen2_Cmd;
Prev_Pen2_PB := Pen2_Toggle_PB;
IF HMI_Pen2_Cmd THEN HMI_Pen2_Cmd := FALSE; END_IF;

(* 8.1. Khi máy đang chạy tải (State_Machine = 1 và tốc độ >= 5.0 m/p): CƯỠNG CHẾ CẢ 2 PEN = 1 *)
IF (State_Machine = 1) AND (Command_Speed_MPM >= 5.0) THEN
    Pen1_State := TRUE;
    Pen2_State := TRUE;
    Pen_Auto_Engaged := TRUE;

(* 8.2. Khi máy dừng (State_Machine = 0) hoặc tốc độ giảm về <= Release_Pen_Speed_MPM *)
ELSIF (State_Machine = 0) OR (Command_Speed_MPM <= Release_Pen_Speed_MPM) THEN
    (* Nếu vừa giảm tốc từ trên cao xuống: Tự động nhả cả 2 Pen về 0 *)
    IF Pen_Auto_Engaged THEN
        Pen1_State := FALSE;
        Pen2_State := FALSE;
        Pen_Auto_Engaged := FALSE;
    END_IF;

    (* Khi dừng máy: Cho phép bấm nút cơ hoặc HMI để đóng/mở cân chỉnh Pen *)
    IF Trig_Pen1 THEN Pen1_State := NOT(Pen1_State); END_IF;
    IF Trig_Pen2 THEN Pen2_State := NOT(Pen2_State); END_IF;

(* 8.3. Trong dải tốc độ chuyển tiếp (2.0 ~ 5.0 m/p) *)
ELSE
    IF Trig_Pen1 THEN Pen1_State := NOT(Pen1_State); END_IF;
    IF Trig_Pen2 THEN Pen2_State := NOT(Pen2_State); END_IF;
END_IF;

(* ============================================================================ *)
(* 9. TĂNG GIẢM TỐC ĐỘ VÀ RAMP LỆNH TỐC ĐỘ                                      *)
(* ============================================================================ *)
IF Cmd_Inc AND State_Machine = 1 THEN
    Inc_Hold_Timer := Inc_Hold_Timer + 1;
    IF Inc_Hold_Timer > 50 THEN Dynamic_Accel_Step := Ramp_Accel_Rate * 5.0; ELSE Dynamic_Accel_Step := Ramp_Accel_Rate; END_IF;
    Target_Line_MPM := Target_Line_MPM + Dynamic_Accel_Step;
    IF Target_Line_MPM > Max_Speed_MPM THEN Target_Line_MPM := Max_Speed_MPM; END_IF;
ELSE
    Inc_Hold_Timer := 0;
END_IF;

IF Cmd_Dec AND State_Machine = 1 THEN
    Dec_Hold_Timer := Dec_Hold_Timer + 1;
    IF Dec_Hold_Timer > 50 THEN Dynamic_Accel_Step := Ramp_Decel_Rate * 5.0; ELSE Dynamic_Accel_Step := Ramp_Decel_Rate; END_IF;
    Target_Line_MPM := Target_Line_MPM - Dynamic_Accel_Step;
    IF Target_Line_MPM < Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
ELSE
    Dec_Hold_Timer := 0;
END_IF;

IF State_Machine = 1 THEN
    IF Command_Speed_MPM < Target_Line_MPM THEN
        Command_Speed_MPM := Command_Speed_MPM + Ramp_Accel_Rate;
        IF Command_Speed_MPM > Target_Line_MPM THEN Command_Speed_MPM := Target_Line_MPM; END_IF;
    ELSIF Command_Speed_MPM > Target_Line_MPM THEN
        Command_Speed_MPM := Command_Speed_MPM - Ramp_Decel_Rate;
        IF Command_Speed_MPM < Target_Line_MPM THEN Command_Speed_MPM := Target_Line_MPM; END_IF;
    END_IF;
ELSIF Cmd_Jog_Crawl AND NOT(Servo_Not_Ready_Fault) THEN
    IF Command_Speed_MPM < Min_Speed_MPM THEN
        Command_Speed_MPM := Command_Speed_MPM + Ramp_Accel_Rate;
        IF Command_Speed_MPM > Min_Speed_MPM THEN Command_Speed_MPM := Min_Speed_MPM; END_IF;
    ELSE
        Command_Speed_MPM := Min_Speed_MPM;
    END_IF;
ELSE
    Command_Speed_MPM := 0.0;
END_IF;

(* ============================================================================ *)
(* 10. ĐO CHIỀU DÀI MÀNG & TÍNH ĐƯỜNG KÍNH CUỘN                                 *)
(* ============================================================================ *)
Delta_Pulse_X2 := ABS(Curr_Pulse_X2 - Last_Pulse_X2_Len);
IF Delta_Pulse_X2 > 0 AND State_Machine = 1 AND Total_PPR > 0 THEN
    Delta_Length_mm := (DINT_TO_REAL(Delta_Pulse_X2) * 3.1415 * Dia_X2_Roller_mm) / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);
    Accum_Length_mm := Accum_Length_mm + Delta_Length_mm;
    IF Accum_Length_mm >= 1000.0 THEN
        Total_Length_Meters := Total_Length_Meters + (Accum_Length_mm / 1000.0);
        Accum_Length_mm     := 0.0;
    END_IF;
END_IF;
Last_Pulse_X2_Len := Curr_Pulse_X2;

IF HMI_Reset_Length THEN Total_Length_Meters := 0.0; Accum_Length_mm := 0.0; HMI_Reset_Length := FALSE; END_IF;

(* Đường kính cuộn Thu T *)
IF Total_PPR > 0 AND (Curr_Pulse_T - Last_Pulse_T) >= REAL_TO_DINT(DINT_TO_REAL(Total_PPR) * Gear_Ratio_T) THEN
    IF (Curr_Pulse_X2 - Last_Pulse_X2_T) > 0 THEN
        Raw_Dia_T_mm := (DINT_TO_REAL(Curr_Pulse_X2 - Last_Pulse_X2_T) * Dia_X2_Roller_mm) / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);
        IF Raw_Dia_T_mm < Core_Dia_T_mm THEN Raw_Dia_T_mm := Core_Dia_T_mm; END_IF;
        IF Raw_Dia_T_mm > Max_Dia_T_mm THEN Raw_Dia_T_mm := Max_Dia_T_mm; END_IF;
        Real_Dia_T_mm := Real_Dia_T_mm + ((Raw_Dia_T_mm - Real_Dia_T_mm) * 0.2);
    END_IF;
    Last_Pulse_X2_T := Curr_Pulse_X2;
    Last_Pulse_T    := Curr_Pulse_T;
END_IF;

(* ============================================================================ *)
(* 10.1. TÍNH ĐƯỜNG KÍNH CUỘN XẢ METALIZE M (SƯỜN LÊN CẢM BIẾN X4A)             *)
(* ============================================================================ *)
IF (Sensor_Rev_M AND NOT M_Sensor_Rev_M_Last) THEN
    Rev_Count_M := Rev_Count_M + 1;
    Curr_Pulse_X2_Now := Curr_Pulse_X2; (* Dùng giá trị xung Master X2 hiện tại *)
    Delta_Pulse_M := Curr_Pulse_X2_Now - Last_Pulse_X2_M;

    IF (State_Machine = 1) AND (Delta_Pulse_M > 0) AND (Total_PPR > 0) AND (Gear_Ratio_X2 > 0.0) THEN
        Raw_Dia_M_mm := (DINT_TO_REAL(Delta_Pulse_M) * Dia_X2_Roller_mm * Gear_Ratio_M) 
                        / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);

        IF Raw_Dia_M_mm < Core_Dia_M_mm THEN 
            Raw_Dia_M_mm := Core_Dia_M_mm; 
        END_IF;
        IF Raw_Dia_M_mm > Max_Dia_M_mm THEN 
            Raw_Dia_M_mm := Max_Dia_M_mm; 
        END_IF;

        (* Bộ lọc quán tính 80/20 giúp ổn định lực căng PID thắng từ M *)
        Real_Dia_M_mm := Real_Dia_M_mm + ((Raw_Dia_M_mm - Real_Dia_M_mm) * 0.2);
    END_IF;

    Last_Pulse_X2_M := Curr_Pulse_X2_Now;
END_IF;
M_Sensor_Rev_M_Last := Sensor_Rev_M;

(* ============================================================================ *)
(* 10.2. TÍNH ĐƯỜNG KÍNH CUỘN XẢ GIẤY U (SƯỜN LÊN CẢM BIẾN X4B)                 *)
(* ============================================================================ *)
IF (Sensor_Rev_U AND NOT M_Sensor_Rev_U_Last) THEN
    Rev_Count_U := Rev_Count_U + 1;
    Curr_Pulse_X2_Now := Curr_Pulse_X2;
    Delta_Pulse_U := Curr_Pulse_X2_Now - Last_Pulse_X2_U;

    IF (State_Machine = 1) AND (Delta_Pulse_U > 0) AND (Total_PPR > 0) AND (Gear_Ratio_X2 > 0.0) THEN
        Raw_Dia_U_mm := (DINT_TO_REAL(Delta_Pulse_U) * Dia_X2_Roller_mm * Gear_Ratio_U) 
                        / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);

        IF Raw_Dia_U_mm < Core_Dia_U_mm THEN 
            Raw_Dia_U_mm := Core_Dia_U_mm; 
        END_IF;
        IF Raw_Dia_U_mm > Max_Dia_U_mm THEN 
            Raw_Dia_U_mm := Max_Dia_U_mm; 
        END_IF;

        (* Bộ lọc quán tính 80/20 cấp điều khiển thắng từ cuộn U *)
        Real_Dia_U_mm := Real_Dia_U_mm + ((Raw_Dia_U_mm - Real_Dia_U_mm) * 0.2);
    END_IF;

    Last_Pulse_X2_U := Curr_Pulse_X2_Now;
END_IF;
M_Sensor_Rev_U_Last := Sensor_Rev_U;

(* ============================================================================ *)
(* 11. STATE MACHINE VẬN HÀNH DÂY CHUYỀN                                        *)
(* ============================================================================ *)
CASE State_Machine OF
    0:
        IF Cmd_Jog_Crawl AND NOT(Servo_Not_Ready_Fault) THEN
            Target_Line_MPM := Min_Speed_MPM;
            IF Target_Line_MPM <= 0.0 THEN Target_Line_MPM := 2.0; END_IF;
        ELSE
            Command_Speed_MPM := 0.0;
            Target_Line_MPM   := 0.0;
        END_IF;
        IF Cmd_Start AND NOT(Servo_Not_Ready_Fault) THEN
            State_Machine  := 1;
            HMI_PID_Enable := TRUE;
            HMI_Start      := FALSE;
            IF Target_Line_MPM < Min_Speed_MPM THEN Target_Line_MPM := 20.0; END_IF;
        END_IF;
    1:
        IF Cmd_Stop THEN
            State_Machine := 0;
            HMI_Stop      := FALSE;
        END_IF;
END_CASE;

(* ============================================================================ *)
(* 12. SERVO ON OUTPUTS (MODULE QY40 SLOT 5 - Y50..Y54)                         *)
(* ============================================================================ *)
Servo_ON_T  := (State_Machine = 1) OR HMI_Test_T;
Servo_ON_X1 := (State_Machine = 1) OR HMI_Test_X1;
Servo_ON_X2 := (State_Machine = 1) OR HMI_Test_X2;
Servo_ON_Ms := (State_Machine = 1) OR HMI_Test_Ms;
Servo_ON_S  := (State_Machine = 1) OR HMI_Test_S;

Y50 := Servo_ON_T;
Y51 := Servo_ON_X1;
Y52 := Servo_ON_X2;
Y53 := Servo_ON_Ms;
Y54 := Servo_ON_S;

DO_Pen1 := Pen1_State;
DO_Pen2 := Pen2_State;
Y55 := DO_Pen1;
Y56 := DO_Pen2;

DO_Alarm_Horn      := Servo_Not_Ready_Fault;
Tower_Light_Green  := (State_Machine = 1);
Tower_Light_Yellow := (State_Machine = 0) AND (Cmd_Jog_Crawl OR NOT(Servo_Not_Ready_Fault));
Tower_Light_Red    := Servo_Not_Ready_Fault;

Y57 := DO_Alarm_Horn;
Y58 := Tower_Light_Green;
Y59 := Tower_Light_Yellow;
Y5A := Tower_Light_Red;

(* ============================================================================ *)
(* 13. TÍNH CÔN LỰC TAPER TENSION CUỘN THU T                                    *)
(* ============================================================================ *)
IF Real_Dia_T_mm > Core_Dia_T_mm AND (Max_Dia_T_mm - Core_Dia_T_mm) > 0.0 THEN
    Effective_SP_T := SP_Tension_T * (1.0 - ((Taper_Percent_T / 100.0) * ((Real_Dia_T_mm - Core_Dia_T_mm) / (Max_Dia_T_mm - Core_Dia_T_mm))));
ELSE
    Effective_SP_T := SP_Tension_T;
END_IF;
IF Effective_SP_T < (SP_Tension_T * 0.3) THEN Effective_SP_T := SP_Tension_T * 0.3; END_IF;

(* ============================================================================ *)
(* 14. BẬT CỜ CHO PHÉP XUẤT ÁP CC-LINK DAC TRẠM 1                               *)
(* ============================================================================ *)
Y1000 := TRUE; Y1001 := TRUE; Y1002 := TRUE; Y1003 := TRUE;
Y1004 := TRUE; Y1005 := TRUE; Y1006 := TRUE; Y1007 := TRUE;

(* ============================================================================ *)
(* 15. TỰ ĐỘNG BÁO GIẢM TỐC VÀ DỪNG MÁY THEO CHIỀU DÀI MÉT                      *)
(* ============================================================================ *)
IF Set_Target_Length > 0.0 AND State_Machine = 1 THEN
    IF Total_Length_Meters >= Set_Target_Length THEN
        State_Machine     := 0;
        Target_Line_MPM   := 0.0;
        Command_Speed_MPM := 0.0;
    ELSIF Decel_Distance_Meters > 0.0 AND Total_Length_Meters >= (Set_Target_Length - Decel_Distance_Meters) THEN
        IF Target_Line_MPM > Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
    END_IF;
END_IF;

Auto_Decel_Flag := (Set_Target_Length > 0.0) AND (State_Machine = 1) AND (Decel_Distance_Meters > 0.0) AND (Total_Length_Meters >= (Set_Target_Length - Decel_Distance_Meters)) AND (Total_Length_Meters < Set_Target_Length);

(* ============================================================================ *)
(* 16. MÃ TRẠNG THÁI HIỂN THỊ HMI                                               *)
(* ============================================================================ *)
IF Servo_Not_Ready_Fault THEN HMI_Status_Text_Code := 1;
ELSIF State_Machine = 1  THEN HMI_Status_Text_Code := 2;
ELSIF Cmd_Jog_Crawl      THEN HMI_Status_Text_Code := 3;
ELSIF Auto_Decel_Flag OR (Set_Target_Length > 0.0 AND Total_Length_Meters >= Set_Target_Length) THEN HMI_Status_Text_Code := 4;
ELSE HMI_Status_Text_Code := 0;
END_IF;




