(* ============================================================================ *)
(* TÊN CHƯƠNG TRÌNH : POU_INIT (KHỞI TẠO HỆ THỐNG - INITIAL EXECUTION POU)        *)
(* HỆ THỐNG        : MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - MITSUBISHI Q02U PLC       *)
(* KIỂU DỮ LIỆU    : CHUẨN IEC 61131-3 SỐ THỰC REAL & SỐ NGUYÊN DINT             *)
(* CẤU TRÚC PHẦN CỨNG HỆ THỐNG:                                                 *)
(*   - Base Rack Slot 1 (H10): Module đếm xung QD62 (CH1: Lô Dầu S, CH2: Ngắt M & U) *)
(*   - Base Rack Slot 2 (H20): Module đếm xung QD62D (CH1: Thu T, CH2: Kéo X1)   *)
(*   - Base Rack Slot 3 (H30): Module đếm xung QD62D (CH1: Master X2, CH2: Ghép Ms)*)
(*   - Base Rack Slot 4 (H40): Module Digital In QX40 (16 ngõ vào X40..X4F)     *)
(*   - Base Rack Slot 5 (H50): Module Digital Out QY40 (16 ngõ ra Y50..Y5F)    *)
(*   - Base Rack Slot 6 (H60): Module truyền thông Serial QJ71C24N              *)
(*   - CC-Link Trạm 1: Module DAC AJ65VBTCU-68DAVN (Xuất áp tốc độ & Torque)    *)
(*   - CC-Link Trạm 2: Module ADC AJ65VBTCU-68ADVN (Đọc Loadcell lực căng 4 trục)*)
(* ============================================================================ *)

(* ============================================================================ *)
(* 1. KHỞI TẠO ĐỘ PHÂN GIẢI ENCODER 2000 PPR (NHÂN 4 VI SAI = 8000 XUNG/VÒNG)   *)
(* ============================================================================ *)
IF PPR_Encoder <= 0 THEN 
    PPR_Encoder := 2000; (* Độ phân giải gốc Yaskawa Pn212 = 2000 PPR (D290) *)
END_IF;
IF Real_PPR_T  <= 0 THEN Real_PPR_T  := 8000; END_IF; (* Khởi tạo 8000 xung/vòng Trục Thu T (D830) *)
IF Real_PPR_X1 <= 0 THEN Real_PPR_X1 := 8000; END_IF; (* Khởi tạo 8000 xung/vòng Trục Kéo X1 (D832) *)
IF Real_PPR_X2 <= 0 THEN Real_PPR_X2 := 8000; END_IF; (* Khởi tạo 8000 xung/vòng Trục Master X2 (D834) *)
IF Real_PPR_Ms <= 0 THEN Real_PPR_Ms := 8000; END_IF; (* Khởi tạo 8000 xung/vòng Trục Ghép Ms (D836) *)
IF Real_PPR_S  <= 0 THEN Real_PPR_S  := 8000; END_IF; (* Khởi tạo 8000 xung/vòng Trục Lô Dầu S (D838) *)

(* ============================================================================ *)
(* 2. KHỞI TẠO TỐC ĐỘ ĐỊNH MỨC TỐI ĐA CỦA MOTOR (MAX MOTOR RPM - REAL)          *)
(* ============================================================================ *)
IF Max_RPM_X2 <= 0.0 THEN Max_RPM_X2 := 1000.0; END_IF; (* Trục Master X2: Max 1000 RPM (Động cơ truyền động chính) *)
IF Max_RPM_X1 <= 0.0 THEN Max_RPM_X1 := 1000.0; END_IF; (* Trục Kéo Giấy X1: Max 1000 RPM *)
IF Max_RPM_Ms <= 0.0 THEN Max_RPM_Ms := 3000.0; END_IF; (* Trục Ghép Màng Ms: Max 3000 RPM (Motor tốc độ cao) *)
IF Max_RPM_S  <= 0.0 THEN Max_RPM_S  := 3000.0; END_IF; (* Trục Lô Dầu S: Max 3000 RPM (Servo bôi dầu keo) *)
IF Max_RPM_T  <= 0.0 THEN Max_RPM_T  := 1500.0; END_IF; (* Trục Cuộn Thu T: Max 1500 RPM *)

(* ============================================================================ *)
(* 2. KHỞI TẠO TỶ SỐ TRUYỀN HỘP SỐ CƠ CẤU (GEAR RATIO - REAL, D620..D628)       *)
(* ============================================================================ *)
IF Gear_Ratio_T  <= 0.0 THEN Gear_Ratio_T  := 10.1; END_IF; (* Hộp số cuộn Thu T: 10.1 : 1 (Thanh ghi D620) *)
IF Gear_Ratio_X1 <= 0.0 THEN Gear_Ratio_X1 := 8.0;  END_IF; (* Hộp số trục Kéo X1: 8.0 : 1 (Thanh ghi D622) *)
IF Gear_Ratio_X2 <= 0.0 THEN Gear_Ratio_X2 := 8.0;  END_IF; (* Hộp số trục Master X2: 8.0 : 1 (Thanh ghi D624) *)
IF Gear_Ratio_Ms <= 0.0 THEN Gear_Ratio_Ms := 10.0; END_IF; (* Hộp số trục Ghép Ms: 10.0 : 1 (Thanh ghi D626) *)
IF Gear_Ratio_S  <= 0.0 THEN Gear_Ratio_S  := 10.0; END_IF; (* Hộp số trục Lô Dầu S: 10.0 : 1 (Thanh ghi D628) *)
IF Gear_Ratio_U  <= 0.0 THEN Gear_Ratio_U  := 1.0;  END_IF; (* Trục Xả U: 1.0 : 1 (Thanh ghi D210) *)
IF Gear_Ratio_M  <= 0.0 THEN Gear_Ratio_M  := 1.03125; END_IF; (* Trục Xả Metalize M: Nhông 33/32 = 1.03125 (D282) *)

(* ============================================================================ *)
(* 3. KHỞI TẠO ĐƯỜNG KÍNH CÁC LÔ CƠ CẤU (ROLLER DIAMETER - mm - REAL)           *)
(* ============================================================================ *)
IF Dia_X1_Roller_mm <= 0.0 THEN Dia_X1_Roller_mm := 300.5; END_IF; (* Lô Kéo X1: Đường kính 300.5 mm (Thanh ghi D638) *)
IF Dia_X2_Roller_mm <= 0.0 THEN Dia_X2_Roller_mm := 300.5; END_IF; (* Lô Master X2: Đường kính 300.5 mm (Thanh ghi D642) *)
IF Dia_Ms_Roller_mm <= 0.0 THEN Dia_Ms_Roller_mm := 200.0; END_IF; (* Lô Ghép Ms: Đường kính 200.0 mm (Thanh ghi D640) *)
IF Dia_S_Roller_mm  <= 0.0 THEN Dia_S_Roller_mm  := 100.0; END_IF; (* Lô Dầu S: Đường kính 100.0 mm (Thanh ghi D648) *)

(* ============================================================================ *)
(* 4. KHỞI TẠO ĐƯỜNG KÍNH LÕI (CORE) VÀ ĐƯỜNG KÍNH TỐI ĐA (MAX DIA) (mm - REAL) *)
(* ============================================================================ *)
IF Core_Dia_T_mm <= 0.0 THEN Core_Dia_T_mm := 76.0;   END_IF; (* Lõi cuộn Thu T: 76.0 mm (Thanh ghi D644) *)
IF Core_Dia_M_mm <= 0.0 THEN Core_Dia_M_mm := 76.0;   END_IF; (* Lõi cuộn Xả M: 76.0 mm (Thanh ghi D645) *)
IF Core_Dia_U_mm <= 0.0 THEN Core_Dia_U_mm := 76.0;   END_IF; (* Lõi cuộn Xả U: 76.0 mm (Thanh ghi D647) *)

IF Max_Dia_T_mm  <= 0.0 THEN Max_Dia_T_mm  := 1000.0; END_IF; (* Đường kính tối đa cuộn Thu T: 1000.0 mm (D646) *)
IF Max_Dia_M_mm  <= 0.0 THEN Max_Dia_M_mm  := 600.0;  END_IF; (* Đường kính tối đa cuộn Xả M: 600.0 mm (D649) *)
IF Max_Dia_U_mm  <= 0.0 THEN Max_Dia_U_mm  := 800.0;  END_IF; (* Đường kính tối đa cuộn Xả U: 800.0 mm (D650) *)

(* ============================================================================ *)
(* 5. KHỞI TẠO ĐƯỜNG KÍNH BAN ĐẦU KHI MỚI KHỞI ĐỘNG (REAL, D720..D724)          *)
(* ============================================================================ *)
(* Cuộn Thu T lúc bắt đầu chạy luôn là cuộn rỗng (đường kính = lõi 76mm) *)
IF Real_Dia_T_mm < Core_Dia_T_mm OR Real_Dia_T_mm > Max_Dia_T_mm THEN
    Real_Dia_T_mm := Core_Dia_T_mm; (* 76.0 mm - D724 *)
END_IF;

(* Cuộn Xả Metalize M lúc bắt đầu thường là cuộn đầy nguyên khối (600mm) *)
IF Real_Dia_M_mm < Core_Dia_M_mm OR Real_Dia_M_mm > Max_Dia_M_mm THEN
    Real_Dia_M_mm := Max_Dia_M_mm;  (* 600.0 mm - D722 *)
END_IF;

(* Cuộn Xả Màng U lúc bắt đầu thường là cuộn đầy (800mm) *)
IF Real_Dia_U_mm < Core_Dia_U_mm OR Real_Dia_U_mm > Max_Dia_U_mm THEN
    Real_Dia_U_mm := Max_Dia_U_mm;  (* 800.0 mm - D720 *)
END_IF;

(* ============================================================================ *)
(* 6. KHỞI TẠO TỶ LỆ ĐỒNG BỘ TỐC ĐỘ VÀ BÙ TỐC (SPEED RATIO - REAL, 1.0 = 100%)  *)
(* ============================================================================ *)
IF Speed_Ratio_T  <= 0.0 THEN Speed_Ratio_T  := 1.05; END_IF; (* Cuộn Thu T chạy nhỉnh hơn 5% giữ độ căng (D756) *)
IF Speed_Ratio_X1 <= 0.0 THEN Speed_Ratio_X1 := 1.00; END_IF; (* Kéo X1 đồng bộ 100.0% theo Master (D758) *)
IF Speed_Ratio_Ms <= 0.0 THEN Speed_Ratio_Ms := 1.00; END_IF; (* Ghép Ms đồng bộ 100.0% theo Master (D762) *)
IF Speed_Ratio_S  <= 0.0 THEN Speed_Ratio_S  := 1.00; END_IF; (* Trục Dầu S đồng bộ 100.0% theo Master (D766) *)

(* ============================================================================ *)
(* 7. KHỞI TẠO GIỚI HẠN VẬN HÀNH DÂY CHUYỀN (m/phút & GIA TỐC RAMP)            *)
(* ============================================================================ *)
IF Max_Speed_MPM         <= 0.0 THEN Max_Speed_MPM         := 100.0; END_IF; (* Tốc độ max thiết kế: 100.0 m/p (D602) *)
IF Min_Speed_MPM         <= 0.0 THEN Min_Speed_MPM         := 2.0;   END_IF; (* Tốc độ min bò màng: 2.0 m/p (D603) *)
IF Release_Pen_Speed_MPM <= 0.0 THEN Release_Pen_Speed_MPM := 2.0;   END_IF; (* Tốc độ nhả Pen tự động: 2.0 m/p (D604) *)
IF Ramp_Accel_Rate       <= 0.0 THEN Ramp_Accel_Rate       := 0.5;   END_IF; (* Tốc độ tăng gia tốc chuẩn: 0.5 (D606) *)
IF Ramp_Decel_Rate       <= 0.0 THEN Ramp_Decel_Rate       := 1.0;   END_IF; (* Tốc độ hãm dừng: 1.0 (D608) *)
IF Decel_Distance_Meters <= 0.0 THEN Decel_Distance_Meters := 50.0;  END_IF; (* Bắt đầu giảm tốc trước khi dừng: 50.0m *)

(* ============================================================================ *)
(* 8. KHỞI TẠO CÀI ĐẶT LỰC CĂNG (TENSION SP - kg) & HỆ SỐ PID MẶC ĐỊNH         *)
(* ============================================================================ *)
IF SP_Tension_T  <= 0.0 THEN SP_Tension_T  := 15.0; END_IF; (* Setpoint lực căng Thu T: 15.0 kg (D660) *)
IF SP_Tension_X1 <= 0.0 THEN SP_Tension_X1 := 12.0; END_IF; (* Setpoint lực căng Xả X1: 12.0 kg (D662) *)
IF SP_Tension_M  <= 0.0 THEN SP_Tension_M  := 10.0; END_IF; (* Setpoint lực căng Xả M:  10.0 kg (D664) *)
IF SP_Tension_U  <= 0.0 THEN SP_Tension_U  := 10.0; END_IF; (* Setpoint lực căng Xả U:  10.0 kg (D668) *)

(* Khởi tạo hệ số PID cuộn Thu T (Tension Control) *)
IF Kp_T <= 0.0 THEN Kp_T := 1.5; END_IF;
IF Ki_T <= 0.0 THEN Ki_T := 0.2; END_IF;
IF Kd_T <= 0.0 THEN Kd_T := 0.1; END_IF;

(* Khởi tạo hệ số PID trục Kéo Giấy X1 (Tension Control) *)
IF Kp_X1 <= 0.0 THEN Kp_X1 := 1.2;  END_IF;
IF Ki_X1 <= 0.0 THEN Ki_X1 := 0.15; END_IF;
IF Kd_X1 <= 0.0 THEN Kd_X1 := 0.08; END_IF;

(* Khởi tạo hệ số PID trục chính Master X2 (Speed Sync) *)
IF Kp_X2 <= 0.0 THEN Kp_X2 := 1.0;  END_IF;
IF Ki_X2 <= 0.0 THEN Ki_X2 := 0.1;  END_IF;
IF Kd_X2 <= 0.0 THEN Kd_X2 := 0.05; END_IF;

(* Khởi tạo hệ số PID trục Ghép Ms (Speed Sync) *)
IF Kp_Ms <= 0.0 THEN Kp_Ms := 1.0;  END_IF;
IF Ki_Ms <= 0.0 THEN Ki_Ms := 0.1;  END_IF;
IF Kd_Ms <= 0.0 THEN Kd_Ms := 0.05; END_IF;

(* Khởi tạo hệ số PID trục Tráng Dầu S (Speed Sync) *)
IF Kp_S <= 0.0 THEN Kp_S := 1.0;  END_IF;
IF Ki_S <= 0.0 THEN Ki_S := 0.1;  END_IF;
IF Kd_S <= 0.0 THEN Kd_S := 0.05; END_IF;

(* Khởi tạo hệ số PID thắng từ cuộn Xả M *)
IF Kp_M <= 0.0 THEN Kp_M := 1.0;  END_IF;
IF Ki_M <= 0.0 THEN Ki_M := 0.1;  END_IF;
IF Kd_M <= 0.0 THEN Kd_M := 0.05; END_IF;

(* Khởi tạo hệ số PID cuộn Xả Màng U *)
IF Kp_U <= 0.0 THEN Kp_U := 1.0;  END_IF;
IF Ki_U <= 0.0 THEN Ki_U := 0.1;  END_IF;
IF Kd_U <= 0.0 THEN Kd_U := 0.05; END_IF;

(* ============================================================================ *)
(* 9. KHỞI TẠO TORQUE HÃM VÀ GIỮ DỪNG CUỘN XẢ M & U (% - REAL)                 *)
(* ============================================================================ *)
IF Min_Torque_M          <= 0.0 THEN Min_Torque_M          := 4.0;  END_IF; (* Torque hãm min cuộn M: 4.0% *)
IF Max_Torque_M          <= 0.0 THEN Max_Torque_M          := 20.0; END_IF; (* Torque hãm max cuộn M: 20.0% *)
IF Init_Holding_Torque_M <= 0.0 THEN Init_Holding_Torque_M := 8.0;  END_IF; (* Torque giữ căng khi máy dừng M: 8.0% *)

IF Min_Torque_U          <= 0.0 THEN Min_Torque_U          := 5.0;  END_IF; (* Torque hãm min cuộn U: 5.0% *)
IF Max_Torque_U          <= 0.0 THEN Max_Torque_U          := 25.0; END_IF; (* Torque hãm max cuộn U: 25.0% *)
IF Init_Holding_Torque_U <= 0.0 THEN Init_Holding_Torque_U := 10.0; END_IF; (* Torque giữ căng khi máy dừng U: 10.0% *)

(* ============================================================================ *)
(* 10. KHỞI TẠO HỆ SỐ GAIN HIỆU CHUẨN LOADCELL (CALIBRATION GAIN - REAL)        *)
(* ============================================================================ *)
IF Calib_Gain_T  <= 0.0 THEN Calib_Gain_T  := 1.0; END_IF; (* Gain Loadcell Thu T *)
IF Calib_Gain_X1 <= 0.0 THEN Calib_Gain_X1 := 1.0; END_IF; (* Gain Loadcell Kéo X1 *)
IF Calib_Gain_M  <= 0.0 THEN Calib_Gain_M  := 1.0; END_IF; (* Gain Loadcell Thắng M *)
IF Calib_Gain_U  <= 0.0 THEN Calib_Gain_U  := 1.0; END_IF; (* Gain Loadcell Xả U *)

(* ============================================================================ *)
(* 11. KHỞI TẠO CẤU HÌNH CC-LINK ADC TRẠM 2 (AJ65VBTCU-68ADVN - ĐỌC LOADCELL)   *)
(* ============================================================================ *)
W210 := 16#00FF; (* Bật cho phép chuyển đổi A/D cả 8 kênh CH1..CH8 *)
W211 := 16#0000; (* Cài đặt Range CH1..CH4: 0..10V (tương ứng 0..4000) *)
W212 := 16#0000; (* Cài đặt Range CH5..CH8: 0..10V *)
W213 := 16#2222; (* CH1..CH4 chọn Mode 2H = Lọc trung bình phần cứng (Count Averaging) *)
W214 := 16;      (* CH1 (Thu T): Lấy trung bình 16 mẫu chống rung kim loadcell *)
W215 := 16;      (* CH2 (Kéo X1): Lấy trung bình 16 mẫu *)
W216 := 16;      (* CH3 (Thắng M): Lấy trung bình 16 mẫu *)
W217 := 16;      (* CH4 (Xả U): Lấy trung bình 16 mẫu *)

(* Bật cờ cho phép chuyển đổi A/D của 8 kênh trên CC-Link Trạm 2 *)
Y1020 := TRUE; (* Cho phép CH1 (Loadcell Thu T) *)
Y1021 := TRUE; (* Cho phép CH2 (Loadcell Kéo X1) *)
Y1022 := TRUE; (* Cho phép CH3 (Loadcell Thắng M) *)
Y1023 := TRUE; (* Cho phép CH4 (Loadcell Xả U) *)
Y1024 := TRUE; (* Cho phép CH5 (Analog Out Servo Trục Dầu S) *)
Y1025 := TRUE; (* Cho phép CH6 Dự phòng *)
Y1026 := TRUE; (* Cho phép CH7 Dự phòng *)
Y1027 := TRUE; (* Cho phép CH8 Dự phòng *)

(* ============================================================================ *)
(* 12. KHỞI TẠO CẤU HÌNH CC-LINK DAC TRẠM 1 (AJ65VBTCU-68DAVN - XUẤT ÁP SERVO) *)
(* ============================================================================ *)
W208 := 16#0000; (* Bật cho phép xuất D/A cả 8 kênh (0 = ENABLE) *)
W209 := 16#1111; (* Range CH1..CH4: 0..5V (0..4000 = 0.0V..5.0V) *)
W20A := 16#1111; (* Range CH5..CH8: 0..5V *)
W20B := 16#0000; (* HOLD/CLEAR: 0 = CLEAR điện áp về 0V khi CPU PLC dừng (STOP) *)

(* Mở cờ cho phép xuất áp ra cọc domino 8 kênh của CC-Link Trạm 1 *)
Y1000 := TRUE; (* Cho phép xuất áp CH1: Tốc độ Thu T *)
Y1001 := TRUE; (* Cho phép xuất áp CH2: Torque Thu T *)
Y1002 := TRUE; (* Cho phép xuất áp CH3: Tốc độ Kéo X1 *)
Y1003 := TRUE; (* Cho phép xuất áp CH4: Tốc độ Master X2 *)
Y1004 := TRUE; (* Cho phép xuất áp CH5: Tốc độ Ghép Ms *)
Y1005 := TRUE; (* Cho phép xuất áp CH6: Torque Thắng M *)
Y1006 := TRUE; (* Cho phép xuất áp CH7: Tốc độ Tráng Dầu S *)
Y1007 := TRUE; (* Cho phép xuất áp CH8: Tốc độ Xả U *)

(* ============================================================================ *)
(* 13. KHỞI TẠO BỘ ĐẾM ENCODER VÀ CHỐT PHA Z (LATCH COUNTER) CHO CẢ 5 TRỤC       *)
(* ============================================================================ *)
(* 13.1. Bật cho phép đếm xung (Count Enable) trên tất cả các kênh QD62/QD62D   *)
Y14 := TRUE; (* QD62 Slot 1 (H10) CH1 Count Enable: Trục Lô Dầu S *)
Y24 := TRUE; (* QD62D Slot 2 (H20) CH1 Count Enable: Trục Thu T *)
Y2C := TRUE; (* QD62D Slot 2 (H20) CH2 Count Enable: Trục Kéo X1 *)
Y34 := TRUE; (* QD62D Slot 3 (H30) CH1 Count Enable: Trục Master X2 *)
Y3C := TRUE; (* QD62D Slot 3 (H30) CH2 Count Enable: Trục Ghép Ms *)

(* 13.2. Cài đặt Chế độ 1 (Latch Counter Function) vào Buffer Memory: CH1 = G9, CH2 = G41 *)
U1\G9  := 1; (* Slot 1 CH1: Trục Lô Dầu S (Chọn Latch Counter theo manual SH-080036) *)
U2\G9  := 1; (* Slot 2 CH1: Trục Thu T (Chọn Latch Counter) *)
U2\G41 := 1; (* Slot 2 CH2: Trục Kéo X1 (Chọn Latch Counter) *)
U3\G9  := 1; (* Slot 3 CH1: Trục Master X2 (Chọn Latch Counter) *)
U3\G41 := 1; (* Slot 3 CH2: Trục Ghép Ms (Chọn Latch Counter) *)

(* 13.3. Tắt cờ chốt mềm Yx6/YxE (để FALSE) nhằm nhường toàn quyền chốt xung cho chân giắc ngoài FUNC *)
Y16 := FALSE; (* Slot 1 CH1: Trục Lô Dầu S *)
Y26 := FALSE; (* Slot 2 CH1: Trục Thu T *)
Y2E := FALSE; (* Slot 2 CH2: Trục Kéo X1 *)
Y36 := FALSE; (* Slot 3 CH1: Trục Master X2 *)
Y3E := FALSE; (* Slot 3 CH2: Trục Ghép Ms *)

EI(TRUE);    (* Mở cờ Enable Interrupt toàn CPU Q cho phép chạy các ngắt thời gian Fixed Scan *)

