(* ============================================================================ *)
(* DỰ ÁN: MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - PLC MITSUBISHI Q02U                *)
(* THƯ MỤC: ST_LATCH_GHEP                                                      *)
(* FILE: 01_POU_INIT.st                                                         *)
(* LOẠI CHƯƠNG TRÌNH: INITIAL EXECUTION (Chạy 1 lần duy nhất khi khởi động CPU)  *)
(* NGÔN NGỮ: STRUCTURED TEXT (ST)                                              *)
(* ============================================================================ *)

(* ============================================================================ *)
(* 1. KHỞI TẠO ĐỘ PHÂN GIẢI ENCODER & THÔNG SỐ CƠ CẤU 5 TRỤC                   *)
(* ============================================================================ *)
IF PPR_Encoder <= 0 THEN PPR_Encoder := 2000; END_IF; (* Gốc Yaskawa Pn212 = 2000 PPR *)

(* Khởi tạo số xung danh định 1 vòng (Nhân 4 vi sai: 2000 x 4 = 8000 xung/vòng) *)
IF Real_PPR_T  <= 0 THEN Real_PPR_T  := 8000; END_IF; (* Trục Thu T (D830) *)
IF Real_PPR_X1 <= 0 THEN Real_PPR_X1 := 8000; END_IF; (* Trục Kéo X1 (D832) *)
IF Real_PPR_X2 <= 0 THEN Real_PPR_X2 := 8000; END_IF; (* Trục Master X2 (D834) *)
IF Real_PPR_Ms <= 0 THEN Real_PPR_Ms := 8000; END_IF; (* Trục Ghép Ms (D836) *)
IF Real_PPR_S  <= 0 THEN Real_PPR_S  := 8000; END_IF; (* Trục Lô Dầu S (D838) *)

(* Tốc độ định mức tối đa của Motor (RPM - REAL) *)
IF Max_RPM_X2 <= 0.0 THEN Max_RPM_X2 := 1000.0; END_IF;
IF Max_RPM_X1 <= 0.0 THEN Max_RPM_X1 := 1000.0; END_IF;
IF Max_RPM_Ms <= 0.0 THEN Max_RPM_Ms := 3000.0; END_IF;
IF Max_RPM_S  <= 0.0 THEN Max_RPM_S  := 3000.0; END_IF;
IF Max_RPM_T  <= 0.0 THEN Max_RPM_T  := 1500.0; END_IF;

(* Tỷ số truyền hộp số cơ cấu (Gear Ratio - REAL) *)
IF Gear_Ratio_T  <= 0.0 THEN Gear_Ratio_T  := 10.1; END_IF;
IF Gear_Ratio_X1 <= 0.0 THEN Gear_Ratio_X1 := 8.0;  END_IF;
IF Gear_Ratio_X2 <= 0.0 THEN Gear_Ratio_X2 := 8.0;  END_IF;
IF Gear_Ratio_Ms <= 0.0 THEN Gear_Ratio_Ms := 10.0; END_IF;
IF Gear_Ratio_S  <= 0.0 THEN Gear_Ratio_S  := 10.0; END_IF;
IF Gear_Ratio_U  <= 0.0 THEN Gear_Ratio_U  := 1.0;  END_IF;
IF Gear_Ratio_M  <= 0.0 THEN Gear_Ratio_M  := 1.03125; END_IF; (* Nhông 33/32 *)

(* Đường kính các lô cơ cấu (Roller Diameter - mm - REAL) *)
IF Dia_X1_Roller_mm <= 0.0 THEN Dia_X1_Roller_mm := 300.5; END_IF;
IF Dia_X2_Roller_mm <= 0.0 THEN Dia_X2_Roller_mm := 300.5; END_IF;
IF Dia_Ms_Roller_mm <= 0.0 THEN Dia_Ms_Roller_mm := 200.0; END_IF;
IF Dia_S_Roller_mm  <= 0.0 THEN Dia_S_Roller_mm  := 100.0; END_IF;

(* Đường kính lõi cuộn (Core) và đường kính cuộn ban đầu (mm - REAL) *)
IF Core_Dia_T_mm <= 0.0 THEN Core_Dia_T_mm := 76.0;   END_IF;
IF Core_Dia_M_mm <= 0.0 THEN Core_Dia_M_mm := 76.0;   END_IF;
IF Core_Dia_U_mm <= 0.0 THEN Core_Dia_U_mm := 76.0;   END_IF;
IF Max_Dia_T_mm  <= 0.0 THEN Max_Dia_T_mm  := 600.0;  END_IF;
IF Max_Dia_M_mm  <= 0.0 THEN Max_Dia_M_mm  := 600.0;  END_IF;
IF Max_Dia_U_mm  <= 0.0 THEN Max_Dia_U_mm  := 600.0;  END_IF;

(* Khởi tạo đường kính thực tế ban đầu *)
IF Real_Dia_T_mm <= 0.0 THEN Real_Dia_T_mm := Core_Dia_T_mm; END_IF;
IF Real_Dia_M_mm <= 0.0 THEN Real_Dia_M_mm := 350.0; END_IF; (* Giá trị cuộn xả đầy mẫu *)
IF Real_Dia_U_mm <= 0.0 THEN Real_Dia_U_mm := 350.0; END_IF;

(* ============================================================================ *)
(* 2. KHỞI TẠO THÔNG SỐ TỐC ĐỘ DÂY CHUYỀN (SPEED PARAMETERS - REAL)             *)
(* ============================================================================ *)
IF Set_Line_Speed_MPM <= 0.0 THEN Set_Line_Speed_MPM := 60.0;  END_IF; (* Tốc độ cài đặt: 60 m/phút *)
IF Jog_Speed_MPM      <= 0.0 THEN Jog_Speed_MPM      := 5.0;   END_IF; (* Tốc độ bò luồn màng: 5 m/phút *)
IF Min_Speed_MPM      <= 0.0 THEN Min_Speed_MPM      := 3.0;   END_IF;
IF Accel_Time_Sec     <= 0.0 THEN Accel_Time_Sec     := 15.0;  END_IF; (* Thời gian tăng tốc: 15 giây *)
IF Decel_Time_Sec     <= 0.0 THEN Decel_Time_Sec     := 10.0;  END_IF; (* Thời gian giảm tốc: 10 giây *)

(* ============================================================================ *)
(* 3. KHỞI TẠO LỰC CĂNG VÀ THÔNG SỐ PID CHO 4 VÙNG LỰC CĂNG (REAL)              *)
(* ============================================================================ *)
IF Set_Tension_T  <= 0.0 THEN Set_Tension_T  := 15.0; END_IF; (* Lực căng Thu T: 15 kg *)
IF Set_Tension_X1 <= 0.0 THEN Set_Tension_X1 := 12.0; END_IF; (* Lực căng Kéo X1: 12 kg *)
IF Set_Tension_M  <= 0.0 THEN Set_Tension_M  := 10.0; END_IF; (* Lực căng Thắng M: 10 kg *)
IF Set_Tension_U  <= 0.0 THEN Set_Tension_U  := 8.0;  END_IF; (* Lực căng Xả U: 8 kg *)

(* Hệ số PID cuộn Thu T *)
IF Kp_T <= 0.0 THEN Kp_T := 1.2;  END_IF;
IF Ki_T <= 0.0 THEN Ki_T := 0.08; END_IF;
IF Kd_T <= 0.0 THEN Kd_T := 0.02; END_IF;

(* Hệ số PID trục Kéo X1 *)
IF Kp_X1 <= 0.0 THEN Kp_X1 := 1.0;  END_IF;
IF Ki_X1 <= 0.0 THEN Ki_X1 := 0.05; END_IF;
IF Kd_X1 <= 0.0 THEN Kd_X1 := 0.01; END_IF;

(* Hệ số PID thắng từ cuộn Xả M *)
IF Kp_M <= 0.0 THEN Kp_M := 1.0;  END_IF;
IF Ki_M <= 0.0 THEN Ki_M := 0.1;  END_IF;
IF Kd_M <= 0.0 THEN Kd_M := 0.05; END_IF;

(* Hệ số PID cuộn Xả Màng U *)
IF Kp_U <= 0.0 THEN Kp_U := 1.0;  END_IF;
IF Ki_U <= 0.0 THEN Ki_U := 0.1;  END_IF;
IF Kd_U <= 0.0 THEN Kd_U := 0.05; END_IF;

(* Torque hãm cuộn Xả M & U (% - REAL) *)
IF Min_Torque_M          <= 0.0 THEN Min_Torque_M          := 4.0;  END_IF;
IF Max_Torque_M          <= 0.0 THEN Max_Torque_M          := 25.0; END_IF;
IF Init_Holding_Torque_M <= 0.0 THEN Init_Holding_Torque_M := 8.0;  END_IF;

IF Min_Torque_U          <= 0.0 THEN Min_Torque_U          := 5.0;  END_IF;
IF Max_Torque_U          <= 0.0 THEN Max_Torque_U          := 30.0; END_IF;
IF Init_Holding_Torque_U <= 0.0 THEN Init_Holding_Torque_U := 10.0; END_IF;

(* Gain hiệu chuẩn Loadcell *)
IF Calib_Gain_T  <= 0.0 THEN Calib_Gain_T  := 1.0; END_IF;
IF Calib_Gain_X1 <= 0.0 THEN Calib_Gain_X1 := 1.0; END_IF;
IF Calib_Gain_M  <= 0.0 THEN Calib_Gain_M  := 1.0; END_IF;
IF Calib_Gain_U  <= 0.0 THEN Calib_Gain_U  := 1.0; END_IF;

(* ============================================================================ *)
(* 4. KHỞI TẠO CẤU HÌNH CC-LINK ADC TRẠM 2 (AJ65VBTCU-68ADVN - ĐỌC LOADCELL)   *)
(* ============================================================================ *)
W210 := 16#00FF; (* Cho phép chuyển đổi A/D cả 8 kênh CH1..CH8 *)
W211 := 16#0000; (* Range CH1..CH4: 0..10V (tương ứng 0..4000) *)
W212 := 16#0000; (* Range CH5..CH8: 0..10V *)
W213 := 16#2222; (* CH1..CH4 chọn Mode 2H = Lọc trung bình phần cứng *)
W214 := 16;      (* CH1 (Thu T): Lấy trung bình 16 mẫu chống rung loadcell *)
W215 := 16;      (* CH2 (Kéo X1): Lấy trung bình 16 mẫu *)
W216 := 16;      (* CH3 (Thắng M): Lấy trung bình 16 mẫu *)
W217 := 16;      (* CH4 (Xả U): Lấy trung bình 16 mẫu *)

(* Bật cờ cho phép chuyển đổi A/D của 8 kênh trên CC-Link Trạm 2 *)
Y1020 := TRUE; (* Cho phép CH1 (Loadcell Thu T) *)
Y1021 := TRUE; (* Cho phép CH2 (Loadcell Kéo X1) *)
Y1022 := TRUE; (* Cho phép CH3 (Loadcell Thắng M) *)
Y1023 := TRUE; (* Cho phép CH4 (Loadcell Xả U) *)
Y1024 := TRUE; (* Cho phép CH5 *)
Y1025 := TRUE; (* Cho phép CH6 *)
Y1026 := TRUE; (* Cho phép CH7 *)
Y1027 := TRUE; (* Cho phép CH8 *)

(* ============================================================================ *)
(* 5. KHỞI TẠO CẤU HÌNH CC-LINK DAC TRẠM 1 (AJ65VBTCU-68DAVN - XUẤT ÁP SERVO) *)
(* ============================================================================ *)
W208 := 16#0000; (* Cho phép xuất D/A cả 8 kênh (0 = ENABLE) *)
W209 := 16#1111; (* Range CH1..CH4: 0..5V (0..4000 = 0.0V..5.0V) *)
W20A := 16#1111; (* Range CH5..CH8: 0..5V *)
W20B := 16#0000; (* HOLD/CLEAR: 0 = CLEAR điện áp về 0V khi STOP *)

(* Mở cờ cho phép xuất áp ra cọc domino 8 kênh của CC-Link Trạm 1 *)
Y1000 := TRUE; (* CH1: Tốc độ Thu T *)
Y1001 := TRUE; (* CH2: Torque Thu T *)
Y1002 := TRUE; (* CH3: Tốc độ Kéo X1 *)
Y1003 := TRUE; (* CH4: Tốc độ Master X2 *)
Y1004 := TRUE; (* CH5: Tốc độ Ghép Ms *)
Y1005 := TRUE; (* CH6: Torque Thắng M *)
Y1006 := TRUE; (* CH7: Tốc độ Tráng Dầu S *)
Y1007 := TRUE; (* CH8: Tốc độ Xả U *)

(* ============================================================================ *)
(* 6. KHỞI TẠO CHUẨN XÁC CHẾ ĐỘ CHỐT PHA Z (LATCH COUNTER) QD62 / QD62D         *)
(* ============================================================================ *)
(* 6.1. Bật cho phép đếm xung (Count Enable) trên tất cả các kênh *)
Y14 := TRUE; (* QD62 Slot 1 (H10) CH1 Count Enable: Trục Lô Dầu S *)
Y24 := TRUE; (* QD62D Slot 2 (H20) CH1 Count Enable: Trục Thu T *)
Y2C := TRUE; (* QD62D Slot 2 (H20) CH2 Count Enable: Trục Kéo X1 *)
Y34 := TRUE; (* QD62D Slot 3 (H30) CH1 Count Enable: Trục Master X2 *)
Y3C := TRUE; (* QD62D Slot 3 (H30) CH2 Count Enable: Trục Ghép Ms *)

(* 6.2. Cài đặt Chế độ 1 (Latch Counter Function) vào Buffer Memory (GHI 1 LẦN DUY NHẤT) *)
U1\G9  := 1; (* Slot 1 CH1: Trục Lô Dầu S (Chọn Latch Counter theo manual SH-080036) *)
U2\G9  := 1; (* Slot 2 CH1: Trục Thu T (Chọn Latch Counter) *)
U2\G41 := 1; (* Slot 2 CH2: Trục Kéo X1 (Chọn Latch Counter) *)
U3\G9  := 1; (* Slot 3 CH1: Trục Master X2 (Chọn Latch Counter) *)
U3\G41 := 1; (* Slot 3 CH2: Trục Ghép Ms (Chọn Latch Counter) *)

(* 6.3. BẮT BUỘC ĐỂ CỜ LỆNH CHỐT MỀM (Yx6/YxE) Ở MỨC FALSE *)
(* Để nhường toàn bộ quyền chốt cho chân phần cứng 1FUNC / 2FUNC đón xung Pha Z *)
Y16 := FALSE; (* Slot 1 CH1: Trục Lô Dầu S *)
Y26 := FALSE; (* Slot 2 CH1: Trục Thu T *)
Y2E := FALSE; (* Slot 2 CH2: Trục Kéo X1 *)
Y36 := FALSE; (* Slot 3 CH1: Trục Master X2 *)
Y3E := FALSE; (* Slot 3 CH2: Trục Ghép Ms *)

EI(TRUE); (* Cho phép ngắt toàn CPU *)
