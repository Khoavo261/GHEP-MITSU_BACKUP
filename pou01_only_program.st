(* ============================================================================ *)
(* MÃ NGUỒN POU_01: HỆ THỐNG MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - MITSUBISHI Q02U  *)
(* BẢO VỆ TOÀN DIỆN CHỐNG LỖI 4140 OPERATION ERROR (CHIA CHO 0 & TRÀN SỐ DINT)  *)
(* CẤU HÌNH PHẦN CỨNG:                                                          *)
(*   - Slot 0 (H00): Q68ADV (8CH Analog In: Loadcell T, X1, M, U & Analog S)    *)
(*   - Slot 1 (H10): Q68DAV (8CH Analog Out: Speed/Torque T, X1, X2, Ms, S, M, U) *)
(*   - Slot 2 (H20): QD62D  (2CH High Speed Counter: CH1=Trục T, CH2=Trục X1)  *)
(*   - Slot 3 (H30): QD62D  (2CH High Speed Counter: CH1=Trục X2, CH2=Trục Ms) *)
(*   - Slot 4 (H40): QX40   (16CH Digital Input: X40..X4F)                     *)
(*   - Slot 5 (H50): QY40   (16CH Digital Output: Y50..Y5F)                    *)
(*   - Slot 6 (H60): QJ71C24N (RS232/RS485 Serial)                             *)
(* ============================================================================ *)

(* ============================================================================ *)
(* 0. KIỂM TRA & GÁN GIÁ TRỊ AN TOÀN TRÁNH CHIA CHO 0 (ZERO DIV PROTECTION)    *)
(* ============================================================================ *)
IF PPR_Encoder      <= 0     THEN PPR_Encoder      := 2000;  END_IF;
IF Max_RPM_X2       <= 0.0   THEN Max_RPM_X2       := 1000.0; END_IF;
IF Max_RPM_X1       <= 0.0   THEN Max_RPM_X1       := 1000.0; END_IF;
IF Max_RPM_Ms       <= 0.0   THEN Max_RPM_Ms       := 3000.0; END_IF;
IF Max_RPM_S        <= 0.0   THEN Max_RPM_S        := 3000.0; END_IF;
IF Max_RPM_T        <= 0.0   THEN Max_RPM_T        := 1500.0; END_IF;

IF Gear_Ratio_T     <= 0.0   THEN Gear_Ratio_T     := 10.1;  END_IF;
IF Gear_Ratio_X1    <= 0.0   THEN Gear_Ratio_X1    := 8.0;   END_IF;
IF Gear_Ratio_X2    <= 0.0   THEN Gear_Ratio_X2    := 8.0;   END_IF;
IF Gear_Ratio_Ms    <= 0.0   THEN Gear_Ratio_Ms    := 10.0;  END_IF;
IF Gear_Ratio_S     <= 0.0   THEN Gear_Ratio_S     := 10.0;  END_IF;
IF Gear_Ratio_U     <= 0.0   THEN Gear_Ratio_U     := 1.0;     END_IF; (* Xả U: 1.0 : 1 *)
IF Gear_Ratio_M     <= 0.0   THEN Gear_Ratio_M     := 1.03125; END_IF; (* Trục Xả Metalize M: Gear = 33/32 = 1.03125 *)

IF Dia_X1_Roller_mm <= 0.0   THEN Dia_X1_Roller_mm := 300.5; END_IF;
IF Dia_X2_Roller_mm <= 0.0   THEN Dia_X2_Roller_mm := 300.5; END_IF;
IF Dia_Ms_Roller_mm <= 0.0   THEN Dia_Ms_Roller_mm := 200.0; END_IF;
IF Dia_S_Roller_mm  <= 0.0   THEN Dia_S_Roller_mm  := 100.0; END_IF;

IF Core_Dia_T_mm    <= 0.0   THEN Core_Dia_T_mm    := 76.0;   END_IF;
IF Core_Dia_M_mm    <= 0.0   THEN Core_Dia_M_mm    := 76.0;   END_IF;
IF Core_Dia_U_mm    <= 0.0   THEN Core_Dia_U_mm    := 76.0;   END_IF;

IF Max_Dia_T_mm     <= 0.0   THEN Max_Dia_T_mm     := 1000.0; END_IF;
IF Max_Dia_M_mm     <= 0.0   THEN Max_Dia_M_mm     := 600.0;  END_IF;
IF Max_Dia_U_mm     <= 0.0   THEN Max_Dia_U_mm     := 800.0;  END_IF;

IF Real_Dia_T_mm    < Core_Dia_T_mm THEN Real_Dia_T_mm := Core_Dia_T_mm; END_IF;
IF Real_Dia_M_mm    < Core_Dia_M_mm THEN Real_Dia_M_mm := Max_Dia_M_mm;  END_IF;
IF Real_Dia_U_mm    < Core_Dia_U_mm THEN Real_Dia_U_mm := Max_Dia_U_mm;  END_IF;

IF Max_Speed_MPM    <= 0.0   THEN Max_Speed_MPM    := 100.0;  END_IF;
IF Min_Speed_MPM    <= 0.0   THEN Min_Speed_MPM    := 2.0;    END_IF;
IF Ramp_Accel_Rate  <= 0.0   THEN Ramp_Accel_Rate  := 0.5;    END_IF;
IF Ramp_Decel_Rate  <= 0.0   THEN Ramp_Decel_Rate  := 1.0;    END_IF;

(* ============================================================================ *)
(* 1. KÍCH HOẠT VÀ ĐỌC 4 KÊNH ENCODER QD62D (SLOT 2 & 3) MỖI SCAN               *)
(* ============================================================================ *)
(* Kích hoạt cờ đếm xung cho 2 module QD62D *)
Y21 := TRUE; (* QD62D #1 (Slot 2 H20) CH1: Enable Trục Thu T *)
Y22 := TRUE; (* QD62D #1 (Slot 2 H20) CH2: Enable Trục Kéo X1 *)
Y31 := TRUE; (* QD62D #2 (Slot 3 H30) CH1: Enable Trục Master X2 *)
Y32 := TRUE; (* QD62D #2 (Slot 3 H30) CH2: Enable Trục Ghép Ms *)

(* Đọc xung 32-bit từ Buffer Memory QD62D liên tục mỗi scan *)
DMOV(TRUE, U2\G2,  Curr_Pulse_T);  (* Slot 2 CH1: Trục Thu T *)
DMOV(TRUE, U2\G10, Curr_Pulse_X1); (* Slot 2 CH2: Trục Kéo X1 *)
DMOV(TRUE, U3\G2,  Curr_Pulse_X2); (* Slot 3 CH1: Trục Master X2 *)
DMOV(TRUE, U3\G10, Curr_Pulse_Ms); (* Slot 3 CH2: Trục Ghép Ms *)

(* ============================================================================ *)
(* 2. ĐỌC VÀ LỌC 8 KÊNH ANALOG INPUT TỪ TRẠM 2 CC-LINK ADC (AJ65VBTCU-68ADVN)   *)
(* (ĐÃ THAY THẾ MODULE Q68ADV Ở SLOT 0 ĐỂ GIẢI PHÓNG SLOT 0 CHO MỤC ĐÍCH KHÁC)   *)
(* ============================================================================ *)
(* 2.1. Cấu hình Lọc Trung Bình Phần Cứng (Hardware Count Averaging 16 mẫu)     *)
W210 := 16#00FF; (* Bật chuyển đổi A/D cả 8 kênh CH1..CH8 *)
W211 := 16#0000; (* Range CH1..CH4: 0..10V *)
W212 := 16#0000; (* Range CH5..CH8: 0..10V *)
W213 := 16#2222; (* CH1..CH4: Chế độ 2H = Count Averaging (Lấy trung bình số lần) *)
W214 := 16;      (* CH1 (Thu T): Lấy trung bình 16 mẫu liên tục *)
W215 := 16;      (* CH2 (Kéo X1): Lấy trung bình 16 mẫu *)
W216 := 16;      (* CH3 (Thắng M): Lấy trung bình 16 mẫu *)
W217 := 16;      (* CH4 (Xả U): Lấy trung bình 16 mẫu *)

(* Bắt tay yêu cầu chốt tham số Trạm 2 ADC *)
Y1038 := X1038;
IF NOT X1039 THEN Y1039 := FALSE; END_IF;

(* Bật cờ cho phép chuyển đổi A/D cả 8 kênh Trạm 2 *)
Y1020 := TRUE; Y1021 := TRUE; Y1022 := TRUE; Y1023 := TRUE;
Y1024 := TRUE; Y1025 := TRUE; Y1026 := TRUE; Y1027 := TRUE;

(* Đọc dữ liệu từ RWr Trạm 2 (W110..W117: dải 0..4000) và scale x4 lên dải 0..16000 *)
ADC_CH1_Raw := W110 * 4; (* Loadcell Lực căng Thu T *)
ADC_CH2_Raw := W111 * 4; (* Loadcell Lực căng Kéo X1 *)
ADC_CH3_Raw := W112 * 4; (* Loadcell Lực căng Thắng M *)
ADC_CH4_Raw := W113 * 4; (* Loadcell Lực căng Xả U *)
ADC_CH5_Raw := W114 * 4; (* Tín hiệu Analog Out Tốc độ Servo Trục S *)
ADC_CH6_Raw := W115 * 4; (* Dự phòng CH6 *)
ADC_CH7_Raw := W116 * 4; (* Dự phòng CH7 *)
ADC_CH8_Raw := W117 * 4; (* Dự phòng CH8 *)

(* Chuyển sang thanh ghi hiển thị D500..D507 *)
D500 := INT_TO_WORD(ADC_CH1_Raw);
D501 := INT_TO_WORD(ADC_CH2_Raw);
D502 := INT_TO_WORD(ADC_CH3_Raw);
D503 := INT_TO_WORD(ADC_CH4_Raw);
D504 := INT_TO_WORD(ADC_CH5_Raw);
D505 := INT_TO_WORD(ADC_CH6_Raw);
D506 := INT_TO_WORD(ADC_CH7_Raw);
D507 := INT_TO_WORD(ADC_CH8_Raw);

(* 2.2. Tính Lực căng thực tế (kg) kết hợp BỘ LỌC SỐ EMA (Exponential Moving Average) *)
(* Tầng 1: Lọc phần cứng 16 mẫu trong chip 68ADV -> Tầng 2: Lọc số EMA Alpha=0.15 trong PLC *)
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
IF Zero_Set_T OR (HMI_Cmd_Zero_Set AND HMI_Axis_Select = 1) THEN
    Zero_Offset_T := INT_TO_REAL(ADC_CH1_Raw);
    Zero_Set_T    := FALSE;
END_IF;
IF Zero_Set_X1 OR (HMI_Cmd_Zero_Set AND HMI_Axis_Select = 2) THEN
    Zero_Offset_X1 := INT_TO_REAL(ADC_CH2_Raw);
    Zero_Set_X1    := FALSE;
END_IF;
IF Zero_Set_M OR (HMI_Cmd_Zero_Set AND HMI_Axis_Select = 6) THEN
    Zero_Offset_M := INT_TO_REAL(ADC_CH3_Raw);
    Zero_Set_M    := FALSE;
END_IF;
IF Zero_Set_U OR (HMI_Cmd_Zero_Set AND HMI_Axis_Select = 7) THEN
    Zero_Offset_U := INT_TO_REAL(ADC_CH4_Raw);
    Zero_Set_U    := FALSE;
END_IF;
IF HMI_Cmd_Zero_Set THEN
    HMI_Cmd_Zero_Set := FALSE;
END_IF;

(* ============================================================================ *)
(* 3. BẢO VỆ 5 TRỤC SERVO READY TRÊN MODULE QX40 (SLOT 4 - X40..X44)            *)
(* ============================================================================ *)
Servo_Ready_T  := X40; (* Sẵn sàng Servo Thu T *)
Servo_Ready_X1 := X41; (* Sẵn sàng Servo Kéo X1 *)
Servo_Ready_X2 := X42; (* Sẵn sàng Servo Master X2 *)
Servo_Ready_Ms := X43; (* Sẵn sàng Servo Ghép Ms *)
Servo_Ready_S  := X44; (* Sẵn sàng Servo Dầu S *)

Servo_Not_Ready_Fault := NOT(Servo_Ready_T) OR NOT(Servo_Ready_X1) OR NOT(Servo_Ready_X2) OR NOT(Servo_Ready_Ms) OR NOT(Servo_Ready_S);

IF Servo_Not_Ready_Fault AND State_Machine = 1 THEN
    State_Machine := 0; (* Dừng khẩn cấp nếu đang chạy tự động *)
END_IF;

(* ============================================================================ *)
(* 4. ĐỌC NÚT NHẤN, CẢM BIẾN VÀ CÔNG TẮC GẠT TRÊN MODULE QX40 (SLOT 4 - X45..X4F) *)
(* ============================================================================ *)
Physical_Start_PB := X45; (* Nút Start vật lý *)
Physical_Stop_PB  := X46; (* Nút Stop vật lý *)
Physical_Inc_PB   := X47; (* Nút Tăng tốc vật lý *)
Physical_Dec_PB   := X48; (* Nút Giảm tốc vật lý *)
Physical_Jog_PB   := X49; (* Nút Bò chậm luồn màng vật lý *)
Sensor_Rev_M      := X4A; (* Cảm biến tiệm cận đếm vòng cuộn M *)
Sensor_Rev_U      := X4B; (* Cảm biến tiệm cận đếm vòng cuộn U *)
Pen1_Toggle_PB    := X4C; (* Nút nhấn Pen 1 ngoài tủ *)
Pen2_Toggle_PB    := X4D; (* Nút nhấn Pen 2 ngoài tủ *)
Switch_Hold_M     := X4E; (* Công tắc gạt giữ Torque M khi dừng *)
Switch_Hold_U     := X4F; (* Công tắc gạt giữ Torque U khi dừng *)

Hold_Torque_Stop_M := Switch_Hold_M;
Hold_Torque_Stop_U := Switch_Hold_U;

(* ============================================================================ *)
(* 5. QUẢN LÝ CÔNG THỨC ĐƠN HÀNG (RECIPE MANAGEMENT CHO CÔNG NHÂN)             *)
(* ============================================================================ *)
IF HMI_Recipe_Select <= 0 OR HMI_Recipe_Select > 5 THEN
    HMI_Recipe_Select := 2; (* Mặc định chọn Recipe 2: Hàng Tiêu Chuẩn *)
END_IF;

IF (HMI_Recipe_Select <> Prev_Recipe_Select) OR HMI_Cmd_Apply_Recipe THEN
    CASE HMI_Recipe_Select OF
        1: (* 1. HÀNG MÀNG MỎNG (BOPP 12~15 mic - Bao bì bánh kẹo) *)
            Target_Line_MPM  := 45.0;  (* Tốc độ chuẩn 45 m/p *)
            SP_Tension_T     := 12.0;  (* Lực căng Thu T: 12 kg *)
            SP_Tension_X1    := 10.0;  (* Lực căng Kéo X1: 10 kg *)
            SP_Tension_M     := 4.0;   (* Lực căng Thắng Metalize M: 4 kg *)
            SP_Tension_U     := 8.0;   (* Lực căng Xả U: 8 kg *)
            Taper_Percent_T  := 15.0;  (* Giảm côn lực 15% *)
            Ramp_Accel_Rate  := 0.05;  (* Gia tốc êm ái *)
            Ramp_Decel_Rate  := 0.08;

        2: (* 2. HÀNG TIÊU CHUẨN (BOPP 18~20 mic + Giấy 100~150g - Hộp thông dụng) *)
            Target_Line_MPM  := 60.0;  (* Tốc độ chuẩn 60 m/p *)
            SP_Tension_T     := 16.0;  (* Lực căng Thu T: 16 kg *)
            SP_Tension_X1    := 14.0;  (* Lực căng Kéo X1: 14 kg *)
            SP_Tension_M     := 6.0;   (* Lực căng Thắng Metalize M: 6 kg *)
            SP_Tension_U     := 12.0;  (* Lực căng Xả U: 12 kg *)
            Taper_Percent_T  := 20.0;  (* Giảm côn lực 20% *)
            Ramp_Accel_Rate  := 0.08;  (* Gia tốc tiêu chuẩn *)
            Ramp_Decel_Rate  := 0.10;

        3: (* 3. HÀNG GIẤY DÀY / BÌA CỨNG (Duplex / Ivory 250~350g + Metalize) *)
            Target_Line_MPM  := 50.0;  (* Tốc độ chuẩn 50 m/p *)
            SP_Tension_T     := 25.0;  (* Lực căng Thu T: 25 kg *)
            SP_Tension_X1    := 22.0;  (* Lực căng Kéo X1: 22 kg *)
            SP_Tension_M     := 8.0;   (* Lực căng Thắng Metalize M: 8 kg *)
            SP_Tension_U     := 18.0;  (* Lực căng Xả U: 18 kg *)
            Taper_Percent_T  := 25.0;  (* Giảm côn lực 25% *)
            Ramp_Accel_Rate  := 0.06;
            Ramp_Decel_Rate  := 0.10;

        4: (* 4. HÀNG MÀNG NHÔM / FOIL DẺO CAO CẤP (Alu Foil 9~12 mic / PET) *)
            Target_Line_MPM  := 40.0;  (* Tốc độ chuẩn 40 m/p *)
            SP_Tension_T     := 10.0;  (* Lực căng Thu T: 10 kg *)
            SP_Tension_X1    := 8.0;   (* Lực căng Kéo X1: 8 kg *)
            SP_Tension_M     := 3.5;   (* Lực căng Thắng Metalize M: 3.5 kg *)
            SP_Tension_U     := 7.0;   (* Lực căng Xả U: 7 kg *)
            Taper_Percent_T  := 15.0;
            Ramp_Accel_Rate  := 0.04;  (* Gia tốc siêu êm chống đứt foil *)
            Ramp_Decel_Rate  := 0.06;

        5: (* 5. CHẾ ĐỘ TÙY CHỈNH (CUSTOM) *)
            Target_Line_MPM := Target_Line_MPM;
    END_CASE;
    Prev_Recipe_Select   := HMI_Recipe_Select;
    HMI_Cmd_Apply_Recipe := FALSE;
END_IF;

IF HMI_Cmd_Save_Recipe THEN
    HMI_Recipe_Select    := 5;
    Prev_Recipe_Select   := 5;
    HMI_Cmd_Save_Recipe  := FALSE;
END_IF;

(* ============================================================================ *)
(* 6. NẠP LẠI ĐƯỜNG KÍNH CUỘN TỪ HMI & NÚT THAY CUỘN MỚI TOÀN BỘ 1-CLICK        *)
(* ============================================================================ *)
IF HMI_Reset_All_Rolls THEN
    Real_Dia_T_mm       := Core_Dia_T_mm; (* Thu T về lõi *)
    Real_Dia_M_mm       := Max_Dia_M_mm;  (* Thắng M về cuộn đầy *)
    Real_Dia_U_mm       := Max_Dia_U_mm;  (* Xả U về cuộn đầy *)
    Total_Length_Meters := 0.0;           (* Xóa mét về 0 *)
    Accum_Length_mm     := 0.0;
    HMI_Reset_All_Rolls := FALSE;
END_IF;
IF HMI_Reset_Roll_T THEN Real_Dia_T_mm := Core_Dia_T_mm; HMI_Reset_Roll_T := FALSE; END_IF;
IF HMI_Reset_Roll_M THEN Real_Dia_M_mm := Max_Dia_M_mm;  HMI_Reset_Roll_M := FALSE; END_IF;
IF HMI_Reset_Roll_U THEN Real_Dia_U_mm := Max_Dia_U_mm;  HMI_Reset_Roll_U := FALSE; END_IF;

(* ============================================================================ *)
(* 7. TỔNG HỢP NÚT NHẤN HMI & NÚT NHẤN VẬT LÝ                                  *)
(* ============================================================================ *)
Cmd_Start     := HMI_Start OR Physical_Start_PB;
Cmd_Stop      := HMI_Stop OR Physical_Stop_PB OR Servo_Not_Ready_Fault;
Cmd_Inc       := HMI_Inc_Hold OR Physical_Inc_PB;
Cmd_Dec       := HMI_Dec_Hold OR Physical_Dec_PB;
Cmd_Jog_Crawl := HMI_Jog_Crawl_Cmd OR Physical_Jog_PB;

(* ============================================================================ *)
(* 8. ĐIỀU KHIỂN 2 PEN ÉP MÀNG (SINGLE-COIL LOGIC)                             *)
(* ============================================================================ *)
Trig_Pen1 := (Pen1_Toggle_PB AND NOT(Prev_Pen1_PB)) OR HMI_Pen1_Cmd;
Prev_Pen1_PB := Pen1_Toggle_PB;
IF HMI_Pen1_Cmd THEN HMI_Pen1_Cmd := FALSE; END_IF;

Trig_Pen2 := (Pen2_Toggle_PB AND NOT(Prev_Pen2_PB)) OR HMI_Pen2_Cmd;
Prev_Pen2_PB := Pen2_Toggle_PB;
IF HMI_Pen2_Cmd THEN HMI_Pen2_Cmd := FALSE; END_IF;

IF State_Machine = 1 AND Current_Line_MPM >= 5.0 AND NOT Pen_Auto_Engaged THEN
    Pen1_Next_State := TRUE;
    Pen2_Next_State := TRUE;
ELSIF (State_Machine = 0 OR Current_Line_MPM <= Release_Pen_Speed_MPM) AND NOT (Trig_Pen1 OR Trig_Pen2) THEN
    Pen1_Next_State := FALSE;
    Pen2_Next_State := FALSE;
ELSE
    IF Trig_Pen1 THEN Pen1_Next_State := NOT Pen1_State; ELSE Pen1_Next_State := Pen1_State; END_IF;
    IF Trig_Pen2 THEN Pen2_Next_State := NOT Pen2_State; ELSE Pen2_Next_State := Pen2_State; END_IF;
END_IF;

Pen1_State := Pen1_Next_State;
Pen2_State := Pen2_Next_State;
Pen_Auto_Engaged := (State_Machine = 1 AND Current_Line_MPM >= 5.0);

(* ============================================================================ *)
(* 9. TĂNG GIẢM TỐC LŨY TIẾN THEO THỜI GIAN GIỮ PHÍM INC / DEC                 *)
(* ============================================================================ *)
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

(* Ramping tốc độ hiện tại *)
IF Current_Line_MPM < Target_Line_MPM THEN
    Current_Line_MPM := Current_Line_MPM + Ramp_Accel_Rate;
    IF Current_Line_MPM > Target_Line_MPM THEN Current_Line_MPM := Target_Line_MPM; END_IF;
ELSIF Current_Line_MPM > Target_Line_MPM THEN
    Current_Line_MPM := Current_Line_MPM - Ramp_Decel_Rate;
    IF Current_Line_MPM < Target_Line_MPM THEN Current_Line_MPM := Target_Line_MPM; END_IF;
END_IF;

(* ============================================================================ *)
(* 10. TÍNH ĐƯỜNG KÍNH 3 CUỘN T, M, U VÀ ĐO CHIỀU DÀI MÀNG CHẠY TỪ ENCODER X2   *)
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

IF HMI_Reset_Length THEN
    Total_Length_Meters := 0.0;
    Accum_Length_mm     := 0.0;
    HMI_Reset_Length    := FALSE;
END_IF;

(* Đường kính cuộn Thu T theo xung Master X2 *)
IF Total_PPR > 0 AND (Curr_Pulse_T - Last_Pulse_T) >= REAL_TO_DINT(DINT_TO_REAL(Total_PPR) * Gear_Ratio_T) THEN
    Rev_Count_T := Rev_Count_T + 1;
    IF (Curr_Pulse_X2 - Last_Pulse_X2_T) > 0 THEN
        Raw_Dia_T_mm := (DINT_TO_REAL(Curr_Pulse_X2 - Last_Pulse_X2_T) * Dia_X2_Roller_mm) / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);
        IF Raw_Dia_T_mm < Core_Dia_T_mm THEN Raw_Dia_T_mm := Core_Dia_T_mm; END_IF;
        IF Raw_Dia_T_mm > Max_Dia_T_mm THEN Raw_Dia_T_mm := Max_Dia_T_mm; END_IF;
        Real_Dia_T_mm := Real_Dia_T_mm + ((Raw_Dia_T_mm - Real_Dia_T_mm) * 0.2);
    END_IF;
    Last_Pulse_X2_T := Curr_Pulse_X2;
    Last_Pulse_T    := Curr_Pulse_T;
END_IF;

(* Đường kính cuộn Xả Metalize M theo cảm biến tiệm cận X4A & Tỷ số truyền Gear_Ratio_M (33/32) *)
Trig_X50 := Sensor_Rev_M AND NOT(Prev_X50);
Prev_X50 := Sensor_Rev_M;
IF Trig_X50 THEN
    Rev_Count_M := Rev_Count_M + 1;
    IF Total_PPR > 0 AND (Curr_Pulse_X2 - Last_Pulse_X2_M) > 0 THEN
        Raw_Dia_M_mm := (DINT_TO_REAL(Curr_Pulse_X2 - Last_Pulse_X2_M) * Dia_X2_Roller_mm * Gear_Ratio_M) / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);
        IF Raw_Dia_M_mm < Core_Dia_M_mm THEN Raw_Dia_M_mm := Core_Dia_M_mm; END_IF;
        IF Raw_Dia_M_mm > Max_Dia_M_mm THEN Raw_Dia_M_mm := Max_Dia_M_mm; END_IF;
        Real_Dia_M_mm := Real_Dia_M_mm + ((Raw_Dia_M_mm - Real_Dia_M_mm) * 0.2);
    END_IF;
    Last_Pulse_X2_M := Curr_Pulse_X2;
END_IF;

(* Đường kính cuộn Xả U theo cảm biến tiệm cận X4B *)
Trig_X51 := Sensor_Rev_U AND NOT(Prev_X51);
Prev_X51 := Sensor_Rev_U;
IF Trig_X51 THEN
    Rev_Count_U := Rev_Count_U + 1;
    IF Total_PPR > 0 AND (Curr_Pulse_X2 - Last_Pulse_X2_U) > 0 THEN
        Raw_Dia_U_mm := (DINT_TO_REAL(Curr_Pulse_X2 - Last_Pulse_X2_U) * Dia_X2_Roller_mm) / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);
        IF Raw_Dia_U_mm < Core_Dia_U_mm THEN Raw_Dia_U_mm := Core_Dia_U_mm; END_IF;
        IF Raw_Dia_U_mm > Max_Dia_U_mm THEN Raw_Dia_U_mm := Max_Dia_U_mm; END_IF;
        Real_Dia_U_mm := Real_Dia_U_mm + ((Raw_Dia_U_mm - Real_Dia_U_mm) * 0.2);
    END_IF;
    Last_Pulse_X2_U := Curr_Pulse_X2;
END_IF;

(* ============================================================================ *)
(* 11. STATE MACHINE VẬN HÀNH DÂY CHUYỀN & BÒ CHẬM NỐI MÀNG                     *)
(* ============================================================================ *)
CASE State_Machine OF
    0: (* STATE_STOPPED *)
        IF Cmd_Jog_Crawl AND NOT(Servo_Not_Ready_Fault) THEN
            Target_Line_MPM := Min_Speed_MPM;
            IF Target_Line_MPM <= 0.0 THEN Target_Line_MPM := 2.0; END_IF;
        ELSE
            Current_Line_MPM := 0.0;
            Target_Line_MPM  := 0.0;
        END_IF;

        IF Cmd_Start AND NOT(Servo_Not_Ready_Fault) THEN
            State_Machine   := 1;
            HMI_PID_Enable  := TRUE;
            HMI_Start       := FALSE;
            IF Target_Line_MPM < Min_Speed_MPM THEN Target_Line_MPM := 20.0; END_IF;
        END_IF;

    1: (* STATE_RUNNING *)
        IF Cmd_Stop THEN
            State_Machine := 0;
            HMI_Stop := FALSE;
        END_IF;
END_CASE;

(* ============================================================================ *)
(* 12. ĐIỀU KHIỂN 5 TRỤC SERVO ON XUẤT RA MODULE QY40 (SLOT 5 - Y50..Y54)        *)
(* ============================================================================ *)
Servo_ON_T  := (State_Machine = 1) OR HMI_Test_T;
Servo_ON_X1 := (State_Machine = 1) OR HMI_Test_X1;
Servo_ON_X2 := (State_Machine = 1) OR HMI_Test_X2;
Servo_ON_Ms := (State_Machine = 1) OR HMI_Test_Ms;
Servo_ON_S  := (State_Machine = 1) OR HMI_Test_S;

Y50 := Servo_ON_T;  (* Servo ON Trục Thu T *)
Y51 := Servo_ON_X1; (* Servo ON Trục Kéo X1 *)
Y52 := Servo_ON_X2; (* Servo ON Trục Master X2 *)
Y53 := Servo_ON_Ms; (* Servo ON Trục Ghép Ms *)
Y54 := Servo_ON_S;  (* Servo ON Trục Dầu S *)

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
(* 13. TÍNH CÔN LỰC TAPER TENSION CUỘN THU T (FLOAT)                            *)
(* ============================================================================ *)
IF (Max_Dia_T_mm - Core_Dia_T_mm) > 0.0 AND Taper_Percent_T > 0.0 THEN
    Effective_SP_T := SP_Tension_T - (((Real_Dia_T_mm - Core_Dia_T_mm) * SP_Tension_T * (Taper_Percent_T / 100.0)) / (Max_Dia_T_mm - Core_Dia_T_mm));
ELSE
    Effective_SP_T := SP_Tension_T;
END_IF;
IF Effective_SP_T < 0.0 THEN Effective_SP_T := 0.0; END_IF;

(* Tốc độ đặt Setpoint đồng bộ Master X2 (0..16000) *)
Base_Speed_X2 := (Current_Line_MPM * 16000.0) / Max_Speed_MPM;

SP_Speed_X2 := Base_Speed_X2;
SP_Speed_X1 := (Base_Speed_X2 * Speed_Ratio_X1) + Speed_Offset_X1;
SP_Speed_Ms := (((Base_Speed_X2 * Dia_Ms_Roller_mm) / Dia_X2_Roller_mm) * Speed_Ratio_Ms) + Speed_Offset_Ms;
SP_Speed_S  := (Base_Speed_X2 * Speed_Ratio_S) + Speed_Offset_S;
SP_Speed_T  := ((Base_Speed_X2 * Real_Dia_T_mm) / Core_Dia_T_mm) * Speed_Ratio_T;

(* ============================================================================ *)
(* 14. BỘ CHUYỂN MẠCH INDEX-REGISTER CHO HMI CHỈNH PID, CALIB VÀ ZERO ĐA TRỤC   *)
(* ============================================================================ *)
IF HMI_Axis_Select <= 0 OR HMI_Axis_Select > 7 THEN
    HMI_Axis_Select := 1;
END_IF;

IF HMI_Cmd_Save_PID THEN
    CASE HMI_Axis_Select OF
        1: Kp_T := HMI_Disp_Kp; Ki_T := HMI_Disp_Ki; Kd_T := HMI_Disp_Kd; Calib_Gain_T := HMI_Disp_Calib_Gain; Zero_Offset_T := HMI_Disp_Zero_Offset;
        2: Kp_X1 := HMI_Disp_Kp; Ki_X1 := HMI_Disp_Ki; Kd_X1 := HMI_Disp_Kd; Calib_Gain_X1 := HMI_Disp_Calib_Gain; Zero_Offset_X1 := HMI_Disp_Zero_Offset;
        3: Kp_X2 := HMI_Disp_Kp; Ki_X2 := HMI_Disp_Ki; Kd_X2 := HMI_Disp_Kd;
        4: Kp_Ms := HMI_Disp_Kp; Ki_Ms := HMI_Disp_Ki; Kd_Ms := HMI_Disp_Kd;
        5: Kp_S := HMI_Disp_Kp; Ki_S := HMI_Disp_Ki; Kd_S := HMI_Disp_Kd;
        6: Kp_M := HMI_Disp_Kp; Ki_M := HMI_Disp_Ki; Kd_M := HMI_Disp_Kd; Calib_Gain_M := HMI_Disp_Calib_Gain; Zero_Offset_M := HMI_Disp_Zero_Offset;
        7: Kp_U := HMI_Disp_Kp; Ki_U := HMI_Disp_Ki; Kd_U := HMI_Disp_Kd; Calib_Gain_U := HMI_Disp_Calib_Gain; Zero_Offset_U := HMI_Disp_Zero_Offset;
    END_CASE;
    HMI_Cmd_Save_PID := FALSE;
ELSE
    CASE HMI_Axis_Select OF
        1: HMI_Disp_Kp := Kp_T; HMI_Disp_Ki := Ki_T; HMI_Disp_Kd := Kd_T; HMI_Disp_Calib_Gain := Calib_Gain_T; HMI_Disp_Zero_Offset := Zero_Offset_T;
        2: HMI_Disp_Kp := Kp_X1; HMI_Disp_Ki := Ki_X1; HMI_Disp_Kd := Kd_X1; HMI_Disp_Calib_Gain := Calib_Gain_X1; HMI_Disp_Zero_Offset := Zero_Offset_X1;
        3: HMI_Disp_Kp := Kp_X2; HMI_Disp_Ki := Ki_X2; HMI_Disp_Kd := Kd_X2; HMI_Disp_Calib_Gain := 1.0; HMI_Disp_Zero_Offset := 0.0;
        4: HMI_Disp_Kp := Kp_Ms; HMI_Disp_Ki := Ki_Ms; HMI_Disp_Kd := Kd_Ms; HMI_Disp_Calib_Gain := 1.0; HMI_Disp_Zero_Offset := 0.0;
        5: HMI_Disp_Kp := Kp_S; HMI_Disp_Ki := Ki_S; HMI_Disp_Kd := Kd_S; HMI_Disp_Calib_Gain := 1.0; HMI_Disp_Zero_Offset := 0.0;
        6: HMI_Disp_Kp := Kp_M; HMI_Disp_Ki := Ki_M; HMI_Disp_Kd := Kd_M; HMI_Disp_Calib_Gain := Calib_Gain_M; HMI_Disp_Zero_Offset := Zero_Offset_M;
        7: HMI_Disp_Kp := Kp_U; HMI_Disp_Ki := Ki_U; HMI_Disp_Kd := Kd_U; HMI_Disp_Calib_Gain := Calib_Gain_U; HMI_Disp_Zero_Offset := Zero_Offset_U;
    END_CASE;
END_IF;

IF Calib_Set_T OR (HMI_Cmd_Calib_Set AND HMI_Axis_Select = 1) THEN
    Calib_Gain_T := HMI_Disp_Calib_Gain; Calib_Set_T := FALSE;
END_IF;
IF Calib_Set_X1 OR (HMI_Cmd_Calib_Set AND HMI_Axis_Select = 2) THEN
    Calib_Gain_X1 := HMI_Disp_Calib_Gain; Calib_Set_X1 := FALSE;
END_IF;
IF Calib_Set_M OR (HMI_Cmd_Calib_Set AND HMI_Axis_Select = 6) THEN
    Calib_Gain_M := HMI_Disp_Calib_Gain; Calib_Set_M := FALSE;
END_IF;
IF Calib_Set_U OR (HMI_Cmd_Calib_Set AND HMI_Axis_Select = 7) THEN
    Calib_Gain_U := HMI_Disp_Calib_Gain; Calib_Set_U := FALSE;
END_IF;
IF HMI_Cmd_Calib_Set THEN
    HMI_Cmd_Calib_Set := FALSE;
END_IF;

(* ============================================================================ *)
(* 15. TÍNH TỐC ĐỘ RPM/MPM VÀ GỌI RUN CÁC KHỐI PID THEO NHỊP 10MS TỪ SM409      *)
(* ============================================================================ *)
Trig_PID_10ms := SM409 AND NOT(Prev_SM409);
Prev_SM409 := SM409;

IF Trig_PID_10ms THEN
    (* 15.1. Tính Delta xung trong chu kỳ 10ms *)
    Delta_T   := ABS(Curr_Pulse_T  - Prev_Pulse_T);
    Delta_X1  := ABS(Curr_Pulse_X1 - Prev_Pulse_X1);
    Delta_X2  := ABS(Curr_Pulse_X2 - Prev_Pulse_X2);
    Delta_Ms  := ABS(Curr_Pulse_Ms - Prev_Pulse_Ms);

    Prev_Pulse_T  := Curr_Pulse_T;
    Prev_Pulse_X1 := Curr_Pulse_X1;
    Prev_Pulse_X2 := Curr_Pulse_X2;
    Prev_Pulse_Ms := Curr_Pulse_Ms;

    Total_PPR := PPR_Encoder * 4; (* 2000 x 4 = 8000 *)

    (* 15.2. TÍNH TOÁN TỐC ĐỘ RPM THÔ (Chu kỳ 10ms: Delta * 6000.0 / Total_PPR) *)
    IF Total_PPR > 0 THEN
        Raw_RPM_T  := (DINT_TO_REAL(Delta_T)  * 6000.0) / DINT_TO_REAL(Total_PPR);
        Raw_RPM_X1 := (DINT_TO_REAL(Delta_X1) * 6000.0) / DINT_TO_REAL(Total_PPR);
        Raw_RPM_X2 := (DINT_TO_REAL(Delta_X2) * 6000.0) / DINT_TO_REAL(Total_PPR);
        Raw_RPM_Ms := (DINT_TO_REAL(Delta_Ms) * 6000.0) / DINT_TO_REAL(Total_PPR);
    END_IF;

    (* TÍNH TỐC ĐỘ TRỤC S THÔ TỪ ANALOG OUT SERVO (Q68ADV CH5 - U0\G5: 0..16000 = 0..Max_RPM_S) *)
    Raw_Analog_S := INT_TO_REAL(ADC_CH5_Raw);
    IF Raw_Analog_S < 0.0 THEN Raw_Analog_S := 0.0; ELSIF Raw_Analog_S > 16000.0 THEN Raw_Analog_S := 16000.0; END_IF;

    IF Max_RPM_S > 0.0 THEN
        Raw_RPM_S := (Raw_Analog_S * Max_RPM_S) / 16000.0;
    ELSE
        Raw_RPM_S := 0.0;
    END_IF;

    (* 15.3. BỘ LỌC TRUNG BÌNH TRƯỢT 4 MẪU (MOVING AVERAGE GIỐNG MODULE ADC Q68ADV) *)
    RPM_T  := (Raw_RPM_T  + Buf_RPM_T_1  + Buf_RPM_T_2  + Buf_RPM_T_3)  / 4.0;
    RPM_X1 := (Raw_RPM_X1 + Buf_RPM_X1_1 + Buf_RPM_X1_2 + Buf_RPM_X1_3) / 4.0;
    RPM_X2 := (Raw_RPM_X2 + Buf_RPM_X2_1 + Buf_RPM_X2_2 + Buf_RPM_X2_3) / 4.0;
    RPM_Ms := (Raw_RPM_Ms + Buf_RPM_Ms_1 + Buf_RPM_Ms_2 + Buf_RPM_Ms_3) / 4.0;
    RPM_S  := (Raw_RPM_S  + Buf_RPM_S_1  + Buf_RPM_S_2  + Buf_RPM_S_3)  / 4.0;

    (* Dịch chuyển bộ nhớ đệm mẫu trượt *)
    Buf_RPM_T_3  := Buf_RPM_T_2;   Buf_RPM_T_2  := Buf_RPM_T_1;   Buf_RPM_T_1  := Raw_RPM_T;
    Buf_RPM_X1_3 := Buf_RPM_X1_2;  Buf_RPM_X1_2 := Buf_RPM_X1_1;  Buf_RPM_X1_1 := Raw_RPM_X1;
    Buf_RPM_X2_3 := Buf_RPM_X2_2;  Buf_RPM_X2_2 := Buf_RPM_X2_1;  Buf_RPM_X2_1 := Raw_RPM_X2;
    Buf_RPM_Ms_3 := Buf_RPM_Ms_2;  Buf_RPM_Ms_2 := Buf_RPM_Ms_1;  Buf_RPM_Ms_1 := Raw_RPM_Ms;
    Buf_RPM_S_3  := Buf_RPM_S_2;   Buf_RPM_S_2  := Buf_RPM_S_1;   Buf_RPM_S_1  := Raw_RPM_S;

    (* 15.4. TÍNH VẬN TỐC DÂY MPM (PI = 3.1415) *)
    IF Gear_Ratio_T > 0.0 THEN
        MPM_T  := (RPM_T  * 3.1415 * Real_Dia_T_mm)    / (1000.0 * Gear_Ratio_T);
    END_IF;
    IF Gear_Ratio_X1 > 0.0 THEN
        MPM_X1 := (RPM_X1 * 3.1415 * Dia_X1_Roller_mm) / (1000.0 * Gear_Ratio_X1);
    END_IF;
    IF Gear_Ratio_X2 > 0.0 THEN
        MPM_X2 := (RPM_X2 * 3.1415 * Dia_X2_Roller_mm) / (1000.0 * Gear_Ratio_X2);
    END_IF;
    IF Gear_Ratio_Ms > 0.0 THEN
        MPM_Ms := (RPM_Ms * 3.1415 * Dia_Ms_Roller_mm) / (1000.0 * Gear_Ratio_Ms);
    END_IF;
    IF Gear_Ratio_S > 0.0 THEN
        MPM_S  := (RPM_S  * 3.1415 * Dia_S_Roller_mm)  / (1000.0 * Gear_Ratio_S);
    END_IF;

    (* 15.5. GÁN BIẾN FEEDBACK CHO CÁC VÒNG PID TỐC ĐỘ (0..16000 DAC) *)
    IF Max_RPM_X2 > 0.0 THEN
        Feedback_Speed_X2 := (RPM_X2 * 16000.0) / Max_RPM_X2;
    END_IF;
    IF Max_RPM_Ms > 0.0 THEN
        Feedback_Speed_Ms := (RPM_Ms * 16000.0) / Max_RPM_Ms;
    END_IF;
    Feedback_Speed_S := Raw_Analog_S;

    (* 15.6. GỌI CÁC KHỐI PID *)
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

    (* PID Tốc độ Trục Tráng Dầu S (Feedback từ Analog Out Servo đấu vào Q68ADV CH5) *)
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

    IF pid_X2.AT_Done OR pid_Ms.AT_Done OR pid_S.AT_Done OR pid_X1.AT_Done OR pid_T.AT_Done OR pid_M.AT_Done OR pid_U.AT_Done THEN
        HMI_Cmd_AutoTune   := FALSE;
        HMI_Status_AT_Done := TRUE;
    END_IF;
    
    HMI_Status_AT_Busy := pid_T.AT_Busy OR pid_X1.AT_Busy OR pid_X2.AT_Busy OR pid_Ms.AT_Busy OR pid_S.AT_Busy OR pid_M.AT_Busy OR pid_U.AT_Busy;
END_IF;

(* ============================================================================ *)
(* 16. TÍNH TOÁN XUẤT ÁP TỐC ĐỘ VÀ TORQUE CHO TỪNG TRỤC (FLOAT)                  *)
(* ============================================================================ *)
IF State_Machine = 0 THEN
    IF HMI_Test_X2 THEN Calc_Speed_X2 := Test_Speed_X2; ELSE Calc_Speed_X2 := 0.0; END_IF;
    IF HMI_Test_X1 THEN Calc_Speed_X1 := Test_Speed_X1; ELSE Calc_Speed_X1 := 0.0; END_IF;
    IF HMI_Test_Ms THEN Calc_Speed_Ms := Test_Speed_Ms; ELSE Calc_Speed_Ms := 0.0; END_IF;
    IF HMI_Test_S  THEN Calc_Speed_S  := Test_Speed_S;  ELSE Calc_Speed_S  := 0.0; END_IF;

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
        Calc_Torque_M := (Base_Torque_M * 80.0);
    ELSE
        Calc_Torque_M := 0.0;
    END_IF;

    IF HMI_Test_U THEN
        Calc_Speed_U := Test_Speed_U;
    ELSIF Hold_Torque_Stop_U THEN
        Calc_Speed_U := (Init_Holding_Torque_U * 80.0);
    ELSE
        Calc_Speed_U := 0.0;
    END_IF;

ELSE
    Calc_Speed_X2 := SP_Speed_X2 + PID_Out_X2;
    Calc_Speed_X1 := SP_Speed_X1 + PID_Out_X1;
    Calc_Speed_Ms := SP_Speed_Ms + PID_Out_Ms;
    Calc_Speed_S  := SP_Speed_S  + PID_Out_S;
    Calc_Speed_T  := SP_Speed_T;
    Calc_Torque_T := (Effective_SP_T * 160.0) + PID_Out_T;

    (* Xả U: Giới hạn ngõ ra max 5V (tương đương 0..8000 trên dải 0..10V) *)
    IF Real_Dia_U_mm > 0.0 THEN
        Calc_Speed_U := (((Calc_Speed_X2 * Max_Dia_U_mm) / Real_Dia_U_mm) * 0.5) + PID_Out_U;
    ELSE
        Calc_Speed_U := (Calc_Speed_X2 * 0.5) + PID_Out_U;
    END_IF;

    IF Rev_Count_M <= 5 THEN
        Base_Torque_M := Init_Holding_Torque_M;
    ELSIF (Max_Dia_M_mm - Core_Dia_M_mm) > 0.0 THEN
        Base_Torque_M := Min_Torque_M + (((Max_Torque_M - Min_Torque_M) * (Real_Dia_M_mm - Core_Dia_M_mm)) / (Max_Dia_M_mm - Core_Dia_M_mm));
    ELSE
        Base_Torque_M := Min_Torque_M;
    END_IF;
    (* Thắng Từ M: Giới hạn ngõ ra max 5V (0..100% ứng với 0..8000) *)
    Calc_Torque_M := (Base_Torque_M * 80.0) + PID_Out_M;
END_IF;

(* Khống chế biên an toàn ngõ ra Analog: Các trục Servo xuất 0..16000 (0..10V), riêng Thắng M và Xả U xuất 0..8000 (0..5V) *)
IF Calc_Speed_T  < 0.0 THEN Calc_Speed_T  := 0.0; ELSIF Calc_Speed_T  > 16000.0 THEN Calc_Speed_T  := 16000.0; END_IF;
IF Calc_Torque_T < 0.0 THEN Calc_Torque_T := 0.0; ELSIF Calc_Torque_T > 16000.0 THEN Calc_Torque_T := 16000.0; END_IF;
IF Calc_Speed_X1 < 0.0 THEN Calc_Speed_X1 := 0.0; ELSIF Calc_Speed_X1 > 16000.0 THEN Calc_Speed_X1 := 16000.0; END_IF;
IF Calc_Speed_X2 < 0.0 THEN Calc_Speed_X2 := 0.0; ELSIF Calc_Speed_X2 > 16000.0 THEN Calc_Speed_X2 := 16000.0; END_IF;
IF Calc_Speed_Ms < 0.0 THEN Calc_Speed_Ms := 0.0; ELSIF Calc_Speed_Ms > 16000.0 THEN Calc_Speed_Ms := 16000.0; END_IF;
IF Calc_Torque_M < 0.0 THEN Calc_Torque_M := 0.0; ELSIF Calc_Torque_M > 8000.0  THEN Calc_Torque_M := 8000.0;  END_IF;
IF Calc_Speed_S  < 0.0 THEN Calc_Speed_S  := 0.0; ELSIF Calc_Speed_S  > 16000.0 THEN Calc_Speed_S  := 16000.0; END_IF;
IF Calc_Speed_U  < 0.0 THEN Calc_Speed_U  := 0.0; ELSIF Calc_Speed_U  > 8000.0  THEN Calc_Speed_U  := 8000.0;  END_IF;

(* ============================================================================ *)
(* 17. XUẤT ÁP RA TRẠM 1 CC-LINK DAC (AJ65VBTCU-68DAVN: RWw0..RWw7 = W200..W207) *)
(* (ĐÃ THAY THẾ MODULE Q68DAV Ở SLOT 1 ĐỂ GIẢI PHÓNG SLOT 1 CHO MỤC ĐÍCH KHÁC)   *)
(* ============================================================================ *)
(* 17.1. Cấu hình duy trì & Mở khóa cổng xuất áp cả 8 kênh *)
W208 := 16#0000; (* Enable D/A cả 8 kênh (0 = ENABLE) *)
W209 := 16#1111; (* Range 0..5V (0..4000 = 0.0V..5.0V) *)
W20A := 16#1111; (* Range 0..5V (0..4000 = 0.0V..5.0V) *)
W20B := 16#0000; (* HOLD/CLEAR: 0 = CLEAR khi PLC STOP *)
Y1018 := X1018;  (* Bắt tay yêu cầu ban đầu *)
IF NOT X1019 THEN Y1019 := FALSE; END_IF;

(* Mở cờ cho phép xuất áp ra cọc domino CH1..CH8 *)
Y1000 := TRUE; (* CH1: Speed Thu T *)
Y1001 := TRUE; (* CH2: Torque Thu T *)
Y1002 := TRUE; (* CH3: Speed Kéo X1 *)
Y1003 := TRUE; (* CH4: Speed Master X2 *)
Y1004 := TRUE; (* CH5: Speed Ghép Ms *)
Y1005 := TRUE; (* CH6: Torque Thắng M *)
Y1006 := TRUE; (* CH7: Speed Tráng Dầu S *)
Y1007 := TRUE; (* CH8: Speed Xả U *)

(* 17.2. Quy đổi dải tính toán 0..16000 sang dải phần cứng DAC 0..4000 (0..10.0V) *)
W200 := REAL_TO_INT(Calc_Speed_T  / 4.0);
W201 := REAL_TO_INT(Calc_Torque_T / 4.0);
W202 := REAL_TO_INT(Calc_Speed_X1 / 4.0);
W203 := REAL_TO_INT(Calc_Speed_X2 / 4.0);
W204 := REAL_TO_INT(Calc_Speed_Ms / 4.0);
W205 := REAL_TO_INT(Calc_Torque_M / 4.0);
W206 := REAL_TO_INT(Calc_Speed_S  / 4.0);
W207 := REAL_TO_INT(Calc_Speed_U  / 4.0);

(* Cập nhật thanh ghi giám sát HMI D510..D517 *)
D510 := INT_TO_WORD(W200 * 4);
D511 := INT_TO_WORD(W201 * 4);
D512 := INT_TO_WORD(W202 * 4);
D513 := INT_TO_WORD(W203 * 4);
D514 := INT_TO_WORD(W204 * 4);
D515 := INT_TO_WORD(W205 * 4);
D516 := INT_TO_WORD(W206 * 4);
D517 := INT_TO_WORD(W207 * 4);

(* ============================================================================ *)
(* 18. TỰ ĐỘNG BÁO GIẢM TỐC VÀ DỪNG MÁY KHI ĐẠT CHIỀU DÀI MÉT CÀI ĐẶT           *)
(* ============================================================================ *)
IF Set_Target_Length > 0.0 AND State_Machine = 1 THEN
    IF Total_Length_Meters >= Set_Target_Length THEN
        State_Machine    := 0;
        Target_Line_MPM  := 0.0;
        Current_Line_MPM := 0.0;
    ELSIF Decel_Distance_Meters > 0.0 AND Total_Length_Meters >= (Set_Target_Length - Decel_Distance_Meters) THEN
        IF Target_Line_MPM > Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
    END_IF;
END_IF;

Auto_Decel_Flag := (Set_Target_Length > 0.0) AND (State_Machine = 1) AND (Decel_Distance_Meters > 0.0) AND (Total_Length_Meters >= (Set_Target_Length - Decel_Distance_Meters)) AND (Total_Length_Meters < Set_Target_Length);

(* ============================================================================ *)
(* 19. CẬP NHẬT MÃ TRẠNG THÁI HIỂN THỊ TIẾNG VIỆT TRÊN HMI CHO CÔNG NHÂN        *)
(* ============================================================================ *)
IF Servo_Not_Ready_Fault THEN
    HMI_Status_Text_Code := 1; (* Báo lỗi 5 Servo *)
ELSIF State_Machine = 1 THEN
    HMI_Status_Text_Code := 2; (* Đang chạy tự động *)
ELSIF Cmd_Jog_Crawl THEN
    HMI_Status_Text_Code := 3; (* Đang bò chậm nối màng *)
ELSIF Auto_Decel_Flag OR (Set_Target_Length > 0.0 AND Total_Length_Meters >= Set_Target_Length) THEN
    HMI_Status_Text_Code := 4; (* Đã hoàn thành đơn hàng *)
ELSE
    HMI_Status_Text_Code := 0; (* Máy dừng - Sẵn sàng chạy *)
END_IF;
