(* ============================================================================ *)
(* CHƯƠNG TRÌNH TEST MODULE 7: CC-LINK ADC AJ65VBTCU-68ADVN (TRẠM 1 - VER.2)    *)
(* ĐẶC TÍNH: 8 KÊNH ANALOG INPUT (-10..+10V HOẶC 0..10V / 0..4000)             *)
(* CẤU HÌNH CC-LINK VER.2 (QUADRUPLE CYCLIC, 1 STATION OCCUPIED)               *)
(*   - RX BẬT TẮT / CỜ TRẠNG THÁI: X1000 .. X103F                               *)
(*   - RY ĐIỀU KHIỂN / RESET LỖI : Y1000 .. Y103F                               *)
(*   - RWr GIÁ TRỊ SỐ ĐỌC VỀ     : W100 .. W107 (CH1 .. CH8)                     *)
(*   - RWw CÀI ĐẶT TRẠM          : W200 (Cho phép A/D 8 kênh)                   *)
(* ============================================================================ *)

(* 1. KIỂM TRA MẠNG CC-LINK VÀ CỜ TRẠNG THÁI TRẠM 1 *)
M600 := NOT SB0049;                   (* Đèn báo: Mạng CC-Link Master OK *)
M601 := X101B OR X103B;               (* Đèn báo: Trạm 1 (68ADVN) Ready sẵn sàng *)
M602 := X101A OR X103A;               (* Đèn báo: Cờ cảnh báo lỗi Trạm 1 *)

(* 2. TỰ ĐỘNG CHỐT CẤU HÌNH BẬT CHUYỂN ĐỔI A/D CẢ 8 KÊNH (BẮT BUỘC VỚI 68ADVN) *)
(* Mặc định xuất xưởng module 68ADVN khóa A/D cả 8 kênh. Phải ghi 16#00FF vào W200 và kích Y1019 *)
W200 := 16#00FF; (* Bit 0..7 = 1: Bật chuyển đổi A/D cả 8 kênh CH1..CH8 *)

IF M600 AND NOT M609 THEN
    Y1019 := TRUE; (* Kích cờ Initial Data Setting Request *)
    IF X1019 THEN  (* Khi trạm 1 báo đã nhận cấu hình *)
        Y1019 := FALSE;
        M609  := TRUE; (* Chốt hoàn tất, sẵn sàng chuyển đổi *)
    END_IF;
ELSE
    IF M609 THEN
        Y1019 := FALSE;
    END_IF;
END_IF;

(* 3. XÓA LỖI & CƯỠNG BỨC KHỞI TẠO LẠI NẾU BẤM NÚT M605 *)
IF M605 THEN
    Y101A := TRUE;  (* Error Reset Request *)
    M609  := FALSE; (* Cho phép chạy lại chu trình Initial *)
    IF NOT M602 THEN
        Y101A := FALSE;
        M605  := FALSE;
    END_IF;
ELSE
    Y101A := FALSE;
END_IF;

(* 4. ĐỌC DỮ LIỆU SỐ THÔ RAW TỪ W100..W107 VÀO D600..D607 *)
(* Luôn luôn cập nhật khi mạng CC-Link Master kết nối OK *)
IF M600 THEN
    D600 := W100; (* CH1 Raw ADC (0..4000) *)
    D601 := W101; (* CH2 Raw ADC *)
    D602 := W102; (* CH3 Raw ADC *)
    D603 := W103; (* CH4 Raw ADC *)
    D604 := W104; (* CH5 Raw ADC *)
    D605 := W105; (* CH6 Raw ADC *)
    D606 := W106; (* CH7 Raw ADC *)
    D607 := W107; (* CH8 Raw ADC *)

    (* 5. QUY ĐỔI SANG ĐIỆN ÁP mV (0..10000 mV tương ứng 0.00..10.00V) HIỂN THỊ HMI *)
    (* Thang đo 0..4000 -> 0..10000mV: Công thức = (Raw * 10) / 4 *)
    D610 := (D600 * 10) / 4;
    D611 := (D601 * 10) / 4;
    D612 := (D602 * 10) / 4;
    D613 := (D603 * 10) / 4;
    D614 := (D604 * 10) / 4;
    D615 := (D605 * 10) / 4;
    D616 := (D606 * 10) / 4;
    D617 := (D607 * 10) / 4;

    IF D610 < 0 THEN D610 := 0; END_IF;
    IF D611 < 0 THEN D611 := 0; END_IF;
    IF D612 < 0 THEN D612 := 0; END_IF;
    IF D613 < 0 THEN D613 := 0; END_IF;
    IF D614 < 0 THEN D614 := 0; END_IF;
    IF D615 < 0 THEN D615 := 0; END_IF;
    IF D616 < 0 THEN D616 := 0; END_IF;
    IF D617 < 0 THEN D617 := 0; END_IF;

    (* Giám sát cờ hoàn tất lấy mẫu từng kênh *)
    M610 := X1000; (* CH1 Conversion Complete *)
    M611 := X1001; (* CH2 Conversion Complete *)
    M612 := X1002; (* CH3 Conversion Complete *)
    M613 := X1003; (* CH4 Conversion Complete *)
    M614 := X1004; (* CH5 Conversion Complete *)
    M615 := X1005; (* CH6 Conversion Complete *)
    M616 := X1006; (* CH7 Conversion Complete *)
    M617 := X1007; (* CH8 Conversion Complete *)
END_IF;
