(* ============================================================================ *)
(* CHƯƠNG TRÌNH TEST MODULE 2: Q68DAV (ANALOG OUTPUT - 8 KÊNH 0..10V)           *)
(* VỊ TRÍ PHẦN CỨNG: SLOT 1 (HEAD ADDRESS: H10 - ĐỊA CHỈ I/O: X10..X1F, Y10..Y1F) *)
(* TÍNH NĂNG:                                                                   *)
(*   - Khởi tạo chuyển đổi D/A cả 8 kênh và cho phép xuất áp ra cọc đấu dây     *)
(*   - Chế độ Manual: Nhập trực tiếp giá trị 0..16000 (0..10V) vào D2030..D2037  *)
(*   - Phím tắt xuất áp nhanh toàn kênh: 0V (M1020), 2.5V (M1021),               *)
(*     5.0V (M1022), 10.0V (M1023)                                              *)
(*   - Chế độ Auto Sweep (M1024): Tự động quét điện áp hình tam giác 0V->10V->0V *)
(*     giúp kiểm tra đồng hồ VOM/Servo mà không cần thao tác tay                *)
(* ============================================================================ *)

(* 1. KHỞI TẠO CẤU HÌNH MODULE Q68DAV KHI KHỞI ĐỘNG VÀ DUY TRÌ RUN *)
IF SM402 THEN (* 1 scan đầu tiên *)
    U1\G0 := 16#0000; (* Cho phép chuyển đổi D/A cả 8 kênh CH1..CH8 (0 = Enable) *)
    D2038 := 500;     (* Bước tăng/giảm quét tự động Sweep Step: 500 (~0.31V/bước) *)
END_IF;

(* Duy trì cờ cho phép xuất áp ra cả 8 cọc dây (Y11..Y18) *)
Y11 := TRUE; (* CH1 *)
Y12 := TRUE; (* CH2 *)
Y13 := TRUE; (* CH3 *)
Y14 := TRUE; (* CH4 *)
Y15 := TRUE; (* CH5 *)
Y16 := TRUE; (* CH6 *)
Y17 := TRUE; (* CH7 *)
Y18 := TRUE; (* CH8 *)

(* XUẤT TRỰC TIẾP 2.5V RA CẢ 8 KÊNH ĐỂ ĐO KIỂM TRA NHANH (MẶC ĐỊNH M1019 = FALSE) *)
(* Thang chuẩn mặc định 0..4000: 2.5V = 1000 (Nếu thang High-Res 0..16000 thì là 4000) *)
IF NOT M1019 THEN
    D2030 := 1000; D2031 := 1000; D2032 := 1000; D2033 := 1000;
    D2034 := 1000; D2035 := 1000; D2036 := 1000; D2037 := 1000;
END_IF;

(* 2. CÁC NÚT NHẤN TÙY CHỌN ĐỔI ĐIỆN ÁP TRÊN HMI *)
IF M1020 THEN (* Nút Set 0.0V *)
    M1019 := TRUE;
    D2030 := 0; D2031 := 0; D2032 := 0; D2033 := 0;
    D2034 := 0; D2035 := 0; D2036 := 0; D2037 := 0;
    M1020 := FALSE;
END_IF;

IF M1021 THEN (* Nút Set quay lại 2.5V *)
    M1019 := FALSE;
    M1021 := FALSE;
END_IF;

IF M1022 THEN (* Nút Set 5.0V (2000 thang 4000 / 8000 thang 16000) *)
    M1019 := TRUE;
    D2030 := 2000; D2031 := 2000; D2032 := 2000; D2033 := 2000;
    D2034 := 2000; D2035 := 2000; D2036 := 2000; D2037 := 2000;
    M1022 := FALSE;
END_IF;

IF M1023 THEN (* Nút Set 10.0V (4000 thang 4000 / 16000 thang 16000) *)
    M1019 := TRUE;
    D2030 := 4000; D2031 := 4000; D2032 := 4000; D2033 := 4000;
    D2034 := 4000; D2035 := 4000; D2036 := 4000; D2037 := 4000;
    M1023 := FALSE;
END_IF;

(* 3. CHẾ ĐỘ QUÉT TỰ ĐỘNG HÌNH TAM GIÁC (AUTO SWEEP MODE) *)
(* Tạo xung chu kỳ 100ms từ clock hệ thống SM412 (100ms clock) *)
IF M1024 THEN
    IF D2038 <= 0 THEN D2038 := 500; END_IF;

    IF SM412 THEN (* Mỗi 100ms thực hiện 1 bước quét *)
        IF NOT M1025 THEN (* M1025 = FALSE: Hướng Tăng *)
            D2039 := D2039 + D2038;
            IF D2039 >= 16000 THEN
                D2039 := 16000;
                M1025 := TRUE; (* Đổi chiều sang Giảm *)
            END_IF;
        ELSE (* M1025 = TRUE: Hướng Giảm *)
            D2039 := D2039 - D2038;
            IF D2039 <= 0 THEN
                D2039 := 0;
                M1025 := FALSE; (* Đổi chiều sang Tăng *)
            END_IF;
        END_IF;

        (* Gán giá trị quét ra cả 8 kênh *)
        D2030 := D2039; D2031 := D2039; D2032 := D2039; D2033 := D2039;
        D2034 := D2039; D2035 := D2039; D2036 := D2039; D2037 := D2039;
    END_IF;
END_IF;

(* 4. GIỚI HẠN AN TOÀN ĐẦU RA (0..16000) *)
IF D2030 < 0 THEN D2030 := 0; ELSIF D2030 > 16000 THEN D2030 := 16000; END_IF;
IF D2031 < 0 THEN D2031 := 0; ELSIF D2031 > 16000 THEN D2031 := 16000; END_IF;
IF D2032 < 0 THEN D2032 := 0; ELSIF D2032 > 16000 THEN D2032 := 16000; END_IF;
IF D2033 < 0 THEN D2033 := 0; ELSIF D2033 > 16000 THEN D2033 := 16000; END_IF;
IF D2034 < 0 THEN D2034 := 0; ELSIF D2034 > 16000 THEN D2034 := 16000; END_IF;
IF D2035 < 0 THEN D2035 := 0; ELSIF D2035 > 16000 THEN D2035 := 16000; END_IF;
IF D2036 < 0 THEN D2036 := 0; ELSIF D2036 > 16000 THEN D2036 := 16000; END_IF;
IF D2037 < 0 THEN D2037 := 0; ELSIF D2037 > 16000 THEN D2037 := 16000; END_IF;

(* 5. XUẤT GIÁ TRỊ RA BUFFER MEMORY MODULE Q68DAV *)
U1\G1 := D2030; (* CH1 Out: Speed Thu T *)
U1\G2 := D2031; (* CH2 Out: Torque Thu T *)
U1\G3 := D2032; (* CH3 Out: Speed Kéo X1 *)
U1\G4 := D2033; (* CH4 Out: Speed Master X2 *)
U1\G5 := D2034; (* CH5 Out: Speed Ghép Ms *)
U1\G6 := D2035; (* CH6 Out: Torque Thắng M *)
U1\G7 := D2036; (* CH7 Out: Speed Tráng Dầu S *)
U1\G8 := D2037; (* CH8 Out: Speed Xả U *)

(* 6. GIÁM SÁT TRẠNG THÁI VÀ XÓA LỖI MODULE *)
M1026 := X10;    (* Đèn báo Module Q68DAV Ready *)
M1027 := X1E;    (* Đèn báo phát hiện lỗi phần cứng Q68DAV *)
D2046 := U1\G19; (* Đọc mã lỗi (Error Code) từ Buffer Memory 19 *)

(* Nút nhấn Reset lỗi từ HMI (M1028) kích cờ Y1E *)
Y1E := M1028;
IF Y1E AND NOT X1E THEN
    M1028 := FALSE;
END_IF;
