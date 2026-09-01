(* ============================================================================ *)
(* PROGRAM: POU_ENCODER_SPEED (Fixed Scan 10ms - Ngắt chu kỳ 10ms)             *)
(* MACHINE: MÁY GHÉP MÀNG METALIZE                                             *)
(* HARDWARE:                                                                    *)
(*   - Slot 2 (H20): QD62D #1 (CH1: Trục Thu T, CH2: Trục Kéo X1)              *)
(*   - Slot 3 (H30): QD62D #2 (CH1: Trục Master X2, CH2: Trục Ghép Ms)         *)
(*   - Slot 0 (H00): Q68ADV CH5 đọc tín hiệu Analog Out từ Servo Trục Dầu S    *)
(* ============================================================================ *)

(* --- 1. KÍCH HOẠT CỜ CHO PHÉP ĐẾM XUNG CHO 2 MODULE QD62D (SLOT 2 & 3) --- *)
Y21 := TRUE; (* QD62D #1 (Slot 2 H20) CH1: Enable Trục Thu T *)
Y22 := TRUE; (* QD62D #1 (Slot 2 H20) CH2: Enable Trục Kéo X1 *)

Y31 := TRUE; (* QD62D #2 (Slot 3 H30) CH1: Enable Trục Master X2 *)
Y32 := TRUE; (* QD62D #2 (Slot 3 H30) CH2: Enable Trục Ghép Ms *)

(* --- 2. ĐỌC XUNG 32-BIT TỪ BUFFER MEMORY G2/G3 VÀ G10/G11 --- *)
(* QD62D #1 (Slot 2 - H20) *)
DMOV(TRUE, U2\G2,  Curr_Pulse_T);  (* CH1: Trục Thu T *)
DMOV(TRUE, U2\G10, Curr_Pulse_X1); (* CH2: Trục Kéo X1 *)

(* QD62D #2 (Slot 3 - H30) *)
DMOV(TRUE, U3\G2,  Curr_Pulse_X2); (* CH1: Trục Master X2 *)
DMOV(TRUE, U3\G10, Curr_Pulse_Ms); (* CH2: Trục Ghép Ms *)

(* --- 3. TÍNH DELTA XUNG NỐI TIẾP TRONG 10MS (100Hz) CHO 4 TRỤC ENCODER --- *)
Delta_T  := ABS(Curr_Pulse_T  - Prev_Pulse_T);
Delta_X1 := ABS(Curr_Pulse_X1 - Prev_Pulse_X1);
Delta_X2 := ABS(Curr_Pulse_X2 - Prev_Pulse_X2);
Delta_Ms := ABS(Curr_Pulse_Ms - Prev_Pulse_Ms);

(* Cập nhật xung vòng trước *)
Prev_Pulse_T  := Curr_Pulse_T;
Prev_Pulse_X1 := Curr_Pulse_X1;
Prev_Pulse_X2 := Curr_Pulse_X2;
Prev_Pulse_Ms := Curr_Pulse_Ms;

Total_PPR := PPR_Encoder * 4; (* Nhân 4 độ phân giải mode 2-Phase 4x (Ví dụ: 2000 x 4 = 8000) *)

(* --- 4. TÍNH TỐC ĐỘ VÒNG/PHÚT RPM CHO 4 TRỤC ENCODER (RPM x10: 1500 -> 150.0 RPM) --- *)
(* Công thức: RPM = (Delta_Pulse * 60000ms / 10ms) / Total_PPR *)
IF Total_PPR > 0 THEN
    RPM_T   := (Delta_T   * 600000) / Total_PPR;
    RPM_X1  := (Delta_X1  * 600000) / Total_PPR;
    RPM_X2  := (Delta_X2  * 600000) / Total_PPR;
    RPM_Ms  := (Delta_Ms  * 600000) / Total_PPR;
END_IF;

(* --- 5. TÍNH TỐC ĐỘ TRỤC S TỪ TÍN HIỆU ANALOG OUT SERVO ĐẤU VÀO Q68ADV CH5 (U0\G5) --- *)
(* Dải điện áp Analog Servo Monitor: 0..10V = 0..16000 Digital = 0..Max_RPM_S (3000 RPM) *)
Raw_Analog_S := INT_TO_REAL(U0\G5);
IF Raw_Analog_S < 0.0 THEN Raw_Analog_S := 0.0; ELSIF Raw_Analog_S > 16000.0 THEN Raw_Analog_S := 16000.0; END_IF;

(* Quy đổi RPM Trục S (x10 để hiển thị số nguyên 1 chữ số thập phân) *)
IF Max_RPM_S > 0.0 THEN
    RPM_S_Real := (Raw_Analog_S * Max_RPM_S) / 16000.0;
    RPM_S      := REAL_TO_DINT(RPM_S_Real * 10.0);
ELSE
    RPM_S_Real := 0.0;
    RPM_S      := 0;
END_IF;

(* Gán biến Feedback cho vòng PID Tốc độ Trục S *)
Feedback_Speed_S := Raw_Analog_S;

(* Gán biến Feedback cho các vòng PID Tốc độ khác *)
IF Max_RPM_X2 > 0.0 THEN
    Feedback_Speed_X2 := (DINT_TO_REAL(RPM_X2) / 10.0 * 16000.0) / Max_RPM_X2;
END_IF;
IF Max_RPM_Ms > 0.0 THEN
    Feedback_Speed_Ms := (DINT_TO_REAL(RPM_Ms) / 10.0 * 16000.0) / Max_RPM_Ms;
END_IF;

(* --- 6. TÍNH VẬN TỐC DÂY MÉT/PHÚT MPM (MPM x10: 1205 -> 120.5 MPM) --- *)
(* Công thức: MPM = (RPM * PI * Dia_mm) / (1000 * Gear_Ratio) *)
(* PI x 1000 = 3142 *)
IF Gear_Ratio_T > 0.0 THEN
    MPM_T  := (RPM_T  * 3142 * REAL_TO_DINT(Real_Dia_T_mm)) / (1000000 * REAL_TO_DINT(Gear_Ratio_T));
END_IF;
IF Gear_Ratio_X1 > 0.0 THEN
    MPM_X1 := (RPM_X1 * 3142 * REAL_TO_DINT(Dia_X1_Roller_mm)) / (1000000 * REAL_TO_DINT(Gear_Ratio_X1));
END_IF;
IF Gear_Ratio_X2 > 0.0 THEN
    MPM_X2 := (RPM_X2 * 3142 * REAL_TO_DINT(Dia_X2_Roller_mm)) / (1000000 * REAL_TO_DINT(Gear_Ratio_X2));
END_IF;
IF Gear_Ratio_Ms > 0.0 THEN
    MPM_Ms := (RPM_Ms * 3142 * REAL_TO_DINT(Dia_Ms_Roller_mm)) / (1000000 * REAL_TO_DINT(Gear_Ratio_Ms));
END_IF;
IF Gear_Ratio_S > 0.0 THEN
    MPM_S  := (RPM_S  * 3142 * REAL_TO_DINT(Dia_S_Roller_mm)) / (1000000 * REAL_TO_DINT(Gear_Ratio_S));
END_IF;
