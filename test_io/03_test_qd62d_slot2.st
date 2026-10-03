(* ============================================================================ *)
(* CHƯƠNG TRÌNH TEST MODULE 3: QD62D #1 (HIGH SPEED COUNTER - 2 KÊNH ENCODER)   *)
(* VỊ TRÍ PHẦN CỨNG: SLOT 2 (HEAD ADDRESS: H20 - ĐỊA CHỈ I/O: X20..X2F, Y20..Y2F) *)
(* TÍNH NĂNG:                                                                   *)
(*   - CH1: Encoder Trục Thu T                                                  *)
(*   - CH2: Encoder Trục Kéo X1                                                 *)
(*   - Đọc xung hiện tại 32-bit vào D2050 (CH1) và D2052 (CH2)                   *)
(*   - Nút nhấn Reset xung về 0 từ HMI (M1040: CH1, M1041: CH2)                 *)
(*   - Nút bật/tắt cho phép đếm xung (M1042: CH1, M1043: CH2)                   *)
(*   - Đo tốc độ biến thiên xung Delta Pulse mỗi 100ms vào D2054 và D2056       *)
(* ============================================================================ *)

(* 1. KHỞI TẠO MẶC ĐỊNH BẬT CHO PHÉP ĐẾM XUNG KHI MỚI RUN *)
IF SM402 THEN
    M1042 := TRUE; (* Mặc định bật đếm CH1 *)
    M1043 := TRUE; (* Mặc định bật đếm CH2 *)
END_IF;

(* 2. KÍCH HOẠT CỜ ĐẾM XUNG (COUNT ENABLE) *)
Y21 := M1042; (* Kích hoạt bộ đếm CH1 (Trục Thu T) *)
Y29 := M1043; (* Kích hoạt bộ đếm CH2 (Trục Kéo X1) *)

(* 3. ĐỌC XUNG HIỆN TẠI 32-BIT TỪ BUFFER MEMORY RA THANH GHI DINT *)
(* Lưu ý: Biến DINT chiếm 2 word bộ nhớ (CH1: D2050-D2051, CH2: D2052-D2053) *)
DMOV(TRUE, U2\G2,  Test_Pulse_T);  (* Đọc CH1 Present Value -> D2050 *)
DMOV(TRUE, U2\G10, Test_Pulse_X1); (* Đọc CH2 Present Value -> D2052 *)

(* 4. XỬ LÝ LỆNH RESET XUNG VỀ 0 TỪ HMI (PRESET = 0) *)
(* Reset kênh CH1 (Trục Thu T) *)
IF M1040 THEN
    U2\G0 := 0; (* Ghi giá trị Preset Word thấp = 0 *)
    U2\G1 := 0; (* Ghi giá trị Preset Word cao = 0 *)
    Y22   := TRUE; (* Kích xung Preset CH1 nạp 0 vào Present Value *)
    IF NOT SM400 THEN Y22 := FALSE; END_IF;
    M1040 := FALSE;
ELSE
    Y22 := FALSE;
END_IF;

(* Reset kênh CH2 (Trục Kéo X1) *)
IF M1041 THEN
    U2\G8 := 0; (* Ghi giá trị Preset Word thấp = 0 *)
    U2\G9 := 0; (* Ghi giá trị Preset Word cao = 0 *)
    Y2A   := TRUE; (* Kích xung Preset CH2 nạp 0 vào Present Value *)
    IF NOT SM400 THEN Y2A := FALSE; END_IF;
    M1041 := FALSE;
ELSE
    Y2A := FALSE;
END_IF;

(* 5. ĐO TỐC ĐỘ BIẾN THIÊN XUNG DELTA PULSE MỖI 100MS *)
IF SM412 THEN (* Chu kỳ đồng hồ 100ms *)
    Test_Delta_T  := Test_Pulse_T - Test_Last_Pulse_T;   (* Xung biến thiên CH1 trong 100ms -> D2054 *)
    Test_Delta_X1 := Test_Pulse_X1 - Test_Last_Pulse_X1; (* Xung biến thiên CH2 trong 100ms -> D2056 *)
    
    Test_Last_Pulse_T  := Test_Pulse_T;
    Test_Last_Pulse_X1 := Test_Pulse_X1;
END_IF;

(* 6. GIÁM SÁT TRẠNG THÁI MODULE QD62D #1 *)
M1044 := X20; (* Đèn báo Module QD62D #1 Ready *)
M1045 := X24; (* Đèn báo CH1 đang đếm xung *)
M1046 := X2C; (* Đèn báo CH2 đang đếm xung *)
