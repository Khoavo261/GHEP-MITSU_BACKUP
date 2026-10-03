(* ============================================================================ *)
(* CHƯƠNG TRÌNH TEST MODULE 4: QD62D #2 (HIGH SPEED COUNTER - 2 KÊNH ENCODER)   *)
(* VỊ TRÍ PHẦN CỨNG: SLOT 3 (HEAD ADDRESS: H30 - ĐỊA CHỈ I/O: X30..X3F, Y30..Y3F) *)
(* TÍNH NĂNG:                                                                   *)
(*   - CH1: Encoder Trục Master X2                                              *)
(*   - CH2: Encoder Trục Ghép Ms                                                *)
(*   - Đọc xung hiện tại 32-bit vào D2070 (CH1) và D2072 (CH2)                   *)
(*   - Nút nhấn Reset xung về 0 từ HMI (M1060: CH1, M1061: CH2)                 *)
(*   - Nút bật/tắt cho phép đếm xung (M1062: CH1, M1063: CH2)                   *)
(*   - Đo tốc độ biến thiên xung Delta Pulse mỗi 100ms vào D2074 và D2076       *)
(* ============================================================================ *)

(* 1. KHỞI TẠO MẶC ĐỊNH BẬT CHO PHÉP ĐẾM XUNG KHI MỚI RUN *)
IF SM402 THEN
    M1062 := TRUE; (* Mặc định bật đếm CH1 *)
    M1063 := TRUE; (* Mặc định bật đếm CH2 *)
END_IF;

(* 2. KÍCH HOẠT CỜ ĐẾM XUNG (COUNT ENABLE) *)
Y31 := M1062; (* Kích hoạt bộ đếm CH1 (Trục Master X2) *)
Y39 := M1063; (* Kích hoạt bộ đếm CH2 (Trục Ghép Ms) *)

(* 3. ĐỌC XUNG HIỆN TẠI 32-BIT TỪ BUFFER MEMORY RA THANH GHI DINT *)
(* Lưu ý: Biến DINT chiếm 2 word bộ nhớ (CH1: D2070-D2071, CH2: D2072-D2073) *)
DMOV(TRUE, U3\G2,  Test_Pulse_X2); (* Đọc CH1 Present Value -> D2070 *)
DMOV(TRUE, U3\G10, Test_Pulse_Ms); (* Đọc CH2 Present Value -> D2072 *)

(* 4. XỬ LÝ LỆNH RESET XUNG VỀ 0 TỪ HMI (PRESET = 0) *)
(* Reset kênh CH1 (Trục Master X2) *)
IF M1060 THEN
    U3\G0 := 0; (* Ghi giá trị Preset Word thấp = 0 *)
    U3\G1 := 0; (* Ghi giá trị Preset Word cao = 0 *)
    Y32   := TRUE; (* Kích xung Preset CH1 nạp 0 vào Present Value *)
    IF NOT SM400 THEN Y32 := FALSE; END_IF;
    M1060 := FALSE;
ELSE
    Y32 := FALSE;
END_IF;

(* Reset kênh CH2 (Trục Ghép Ms) *)
IF M1061 THEN
    U3\G8 := 0; (* Ghi giá trị Preset Word thấp = 0 *)
    U3\G9 := 0; (* Ghi giá trị Preset Word cao = 0 *)
    Y3A   := TRUE; (* Kích xung Preset CH2 nạp 0 vào Present Value *)
    IF NOT SM400 THEN Y3A := FALSE; END_IF;
    M1061 := FALSE;
ELSE
    Y3A := FALSE;
END_IF;

(* 5. ĐO TỐC ĐỘ BIẾN THIÊN XUNG DELTA PULSE MỖI 100MS *)
IF SM412 THEN (* Chu kỳ đồng hồ 100ms *)
    Test_Delta_X2 := Test_Pulse_X2 - Test_Last_Pulse_X2; (* Xung biến thiên CH1 trong 100ms -> D2074 *)
    Test_Delta_Ms := Test_Pulse_Ms - Test_Last_Pulse_Ms; (* Xung biến thiên CH2 trong 100ms -> D2076 *)
    
    Test_Last_Pulse_X2 := Test_Pulse_X2;
    Test_Last_Pulse_Ms := Test_Pulse_Ms;
END_IF;

(* 6. GIÁM SÁT TRẠNG THÁI MODULE QD62D #2 *)
M1064 := X30; (* Đèn báo Module QD62D #2 Ready *)
M1065 := X34; (* Đèn báo CH1 đang đếm xung *)
M1066 := X3C; (* Đèn báo CH2 đang đếm xung *)
