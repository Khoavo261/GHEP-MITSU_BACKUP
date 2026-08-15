(* ============================================================================ *)
(* PROGRAM: POU_ENCODER_SPEED (Fixed Scan 10ms - Ngắt chu kỳ 10ms)             *)
(* MACHINE: MÁY GHÉP MÀNG METALIZE                                             *)
(* HARDWARE: 03 Module QD62 tại Slot 1 (H20), Slot 2 (H30), Slot 3 (H40)        *)
(* ENCODERS: 5 Trục (T = Thu, X1 = Xả 1, X2 = Master, M = Metalize, S = Dầu)     *)
(* ============================================================================ *)

VAR_GLOBAL
    (* --- DỮ LIỆU TỐC ĐỘ ĐỌC VỀ VÀ TÍNH TOÁN (HMI / PROGRAM DÙNG CHUNG) --- *)
    (* Tốc độ vòng/phút (RPM x10: 1500 -> 150.0 RPM) *)
    RPM_T       : DINT := 0; (* Trục Thu T *)
    RPM_X1      : DINT := 0; (* Trục Xả X1 *)
    RPM_X2      : DINT := 0; (* Trục Master X2 *)
    RPM_M       : DINT := 0; (* Trục Metalize M *)
    RPM_S       : DINT := 0; (* Trục Dầu S *)

    (* Tốc độ dây mét/phút (MPM x10: 1205 -> 120.5 MPM) *)
    MPM_T       : DINT := 0; (* Vận tốc dây Trục Thu T *)
    MPM_X1      : DINT := 0; (* Vận tốc dây Trục Xả X1 *)
    MPM_X2      : DINT := 0; (* Vận tốc dây Trục Master X2 (Tốc độ chuẩn dòng máy) *)
    MPM_M       : DINT := 0; (* Vận tốc dây Trục Metalize M *)
    MPM_S       : DINT := 0; (* Vận tốc dây Trục Dầu S *)

    (* Cài đặt đường kính lô (mm) *)
    Dia_T_mm    : DINT := 150; (* Đường kính cuộn Thu T *)
    Dia_X1_mm   : DINT := 150; (* Đường kính cuộn Xả X1 *)
    Dia_X2_mm   : DINT := 200; (* Đường kính lô Master X2 (Cố định 200mm) *)
    Dia_M_mm    : DINT := 180; (* Đường kính lô Metalize M *)
    Dia_S_mm    : DINT := 160; (* Đường kính lô Dầu S *)

    (* Cài đặt độ phân giải Encoder PPR (xung/vòng) *)
    PPR_Encoder : DINT := 2000; (* 2000 PPR x 4 = 8000 pulses/rev *)

    (* Biến lưu xung vòng trước *)
    Prev_Pulse_T  : DINT := 0;
    Prev_Pulse_X1 : DINT := 0;
    Prev_Pulse_X2 : DINT := 0;
    Prev_Pulse_M  : DINT := 0;
    Prev_Pulse_S  : DINT := 0;
END_VAR

VAR
    (* Biến xung hiện tại đọc từ Buffer Memory QD62 *)
    Curr_Pulse_T  : DINT := 0;
    Curr_Pulse_X1 : DINT := 0;
    Curr_Pulse_X2 : DINT := 0;
    Curr_Pulse_M  : DINT := 0;
    Curr_Pulse_S  : DINT := 0;

    (* Delta xung đếm được trong 10ms *)
    Delta_T  : DINT := 0;
    Delta_X1 : DINT := 0;
    Delta_X2 : DINT := 0;
    Delta_M  : DINT := 0;
    Delta_S  : DINT := 0;

    (* PPR tổng sau khi nhân 4 pha A/B *)
    Total_PPR : DINT := 8000;
END_VAR

(* ============================================================================ *)
(* MAIN BODY: CHẠY TRONG POU CHU KỲ NGẮT FIXED SCAN 10MS                      *)
(* ============================================================================ *)

(* --- 1. KÍCH HOẠT CỜ CHO PHÉP ĐẾM XUNG CHO 3 MODULE QD62 --- *)
Y21 := TRUE; (* QD62 #1 (Slot 1 H20) CH1: Enable Trục Thu T *)
Y22 := TRUE; (* QD62 #1 (Slot 1 H20) CH2: Enable Trục Xả X1 *)

Y31 := TRUE; (* QD62 #2 (Slot 2 H30) CH1: Enable Trục Master X2 *)
Y32 := TRUE; (* QD62 #2 (Slot 2 H30) CH2: Enable Trục Metalize M *)

Y41 := TRUE; (* QD62 #3 (Slot 3 H40) CH1: Enable Trục Dầu S *)

(* --- 2. ĐỌC XUNG 32-BIT TỪ BUFFER MEMORY G2/G3 VÀ G10/G11 --- *)
(* QD62 #1 (Slot 1 - H20) *)
DMOV(TRUE, U1\G2,  Curr_Pulse_T);  (* CH1: Trục Thu T *)
DMOV(TRUE, U1\G10, Curr_Pulse_X1); (* CH2: Trục Xả X1 *)

(* QD62 #2 (Slot 2 - H30) *)
DMOV(TRUE, U2\G2,  Curr_Pulse_X2); (* CH1: Trục Master X2 *)
DMOV(TRUE, U2\G10, Curr_Pulse_M);  (* CH2: Trục Metalize M *)

(* QD62 #3 (Slot 3 - H40) *)
DMOV(TRUE, U3\G2,  Curr_Pulse_S);  (* CH1: Trục Dầu S *)

(* --- 3. TÍNH DELTA XUNG NỐI TIẾP TRONG 10MS (100Hz) --- *)
Delta_T  := ABS(Curr_Pulse_T  - Prev_Pulse_T);
Delta_X1 := ABS(Curr_Pulse_X1 - Prev_Pulse_X1);
Delta_X2 := ABS(Curr_Pulse_X2 - Prev_Pulse_X2);
Delta_M  := ABS(Curr_Pulse_M  - Prev_Pulse_M);
Delta_S  := ABS(Curr_Pulse_S  - Prev_Pulse_S);

(* Cập nhật xung vòng trước *)
Prev_Pulse_T  := Curr_Pulse_T;
Prev_Pulse_X1 := Curr_Pulse_X1;
Prev_Pulse_X2 := Curr_Pulse_X2;
Prev_Pulse_M  := Curr_Pulse_M;
Prev_Pulse_S  := Curr_Pulse_S;

Total_PPR := PPR_Encoder * 4; (* Nhân 4 độ phân giải mode 2-Phase 4x *)

(* --- 4. TÍNH TỐC ĐỘ VÒNG/PHÚT RPM (RPM x10: 1500 -> 150.0 RPM) --- *)
(* Công thức: RPM = (Delta_Pulse * 60000ms / 10ms) / Total_PPR *)
IF Total_PPR > 0 THEN
    RPM_T  := (Delta_T  * 600000) / Total_PPR;
    RPM_X1 := (Delta_X1 * 600000) / Total_PPR;
    RPM_X2 := (Delta_X2 * 600000) / Total_PPR;
    RPM_M  := (Delta_M  * 600000) / Total_PPR;
    RPM_S  := (Delta_S  * 600000) / Total_PPR;
END_IF;

(* --- 5. TÍNH VẬN TỐC DÂY MÉT/PHÚT MPM (MPM x10: 1205 -> 120.5 MPM) --- *)
(* Công thức: MPM = (RPM * PI * Dia_mm) / 1000 *)
(* PI x 1000 = 3142 *)
MPM_T  := (RPM_T  * 3142 * Dia_T_mm)  / 1000000;
MPM_X1 := (RPM_X1 * 3142 * Dia_X1_mm) / 1000000;
MPM_X2 := (RPM_X2 * 3142 * Dia_X2_mm) / 1000000; (* Vận tốc Master dây chuyền *)
MPM_M  := (RPM_M  * 3142 * Dia_M_mm)  / 1000000;
MPM_S  := (RPM_S  * 3142 * Dia_S_mm)  / 1000000;
