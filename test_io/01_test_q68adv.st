(* ============================================================================ *)
(* CHƯƠNG TRÌNH TEST MODULE 1: Q68ADV (ANALOG INPUT - 8 KÊNH 0..10V)            *)
(* VỊ TRÍ PHẦN CỨNG: SLOT 0 (HEAD ADDRESS: H00 - ĐỊA CHỈ I/O: X00..X0F, Y00..Y0F) *)
(* TÍNH NĂNG:                                                                   *)
(*   - Khởi tạo chuyển đổi A/D cả 8 kênh (0..16000 tương ứng 0.00..10.00V)       *)
(*   - Lọc trung bình động Moving Average 16 mẫu chống nhiễu                    *)
(*   - Đọc giá trị số thô (Raw) vào D2000..D2007                                *)
(*   - Tự động quy đổi sang điện áp Float thực tế (V) vào D2008..D2022          *)
(*   - Báo lỗi Error Flag và nút bấm Clear Error                                *)
(* ============================================================================ *)

(* 1. KHỞI TẠO CẤU HÌNH MODULE Q68ADV KHI KHỞI ĐỘNG *)
IF SM402 THEN (* Xung ON 1 scan đầu tiên khi chuyển sang RUN *)
    U0\G0  := 16#0000; (* Cho phép chuyển đổi A/D cả 8 kênh CH1..CH8 (0 = Enable) *)
    U0\G9  := 16#3333; (* Cài đặt lọc trung bình động Moving Average cho CH1..CH4 *)
    U0\G10 := 16#3333; (* Cài đặt lọc trung bình động Moving Average cho CH5..CH8 *)
    U0\G11 := 16;      (* Số mẫu lọc CH1: 16 mẫu *)
    U0\G12 := 16;      (* Số mẫu lọc CH2: 16 mẫu *)
    U0\G13 := 16;      (* Số mẫu lọc CH3: 16 mẫu *)
    U0\G14 := 16;      (* Số mẫu lọc CH4: 16 mẫu *)
    U0\G15 := 16;      (* Số mẫu lọc CH5: 16 mẫu *)
    U0\G16 := 16;      (* Số mẫu lọc CH6: 16 mẫu *)
    U0\G17 := 16;      (* Số mẫu lọc CH7: 16 mẫu *)
    U0\G18 := 16;      (* Số mẫu lọc CH8: 16 mẫu *)
END_IF;

(* 2. ĐỌC DỮ LIỆU SỐ THÔ RAW (0..16000) TỪ BUFFER MEMORY RA THANH GHI D *)
D2000 := U0\G1; (* CH1 Raw (Loadcell Thu T) *)
D2001 := U0\G2; (* CH2 Raw (Loadcell Kéo X1) *)
D2002 := U0\G3; (* CH3 Raw (Loadcell Thắng M) *)
D2003 := U0\G4; (* CH4 Raw (Loadcell Xả U) *)
D2004 := U0\G5; (* CH5 Raw (Analog Monitor Servo S) *)
D2005 := U0\G6; (* CH6 Raw (Dự phòng) *)
D2006 := U0\G7; (* CH7 Raw (Dự phòng) *)
D2007 := U0\G8; (* CH8 Raw (Dự phòng) *)

(* 3. TỰ ĐỘNG QUY ĐỔI SANG ĐIỆN ÁP FLOAT REAL (0.00 .. 10.00 V) *)
(* Lưu ý: Biến REAL chiếm 2 word bộ nhớ (bước chẵn: D2008, D2010, D2012, D2014, D2016, D2018, D2020, D2022) *)
Test_Volt_CH1 := (INT_TO_REAL(D2000) * 10.0) / 16000.0; (* D2008-D2009 *)
Test_Volt_CH2 := (INT_TO_REAL(D2001) * 10.0) / 16000.0; (* D2010-D2011 *)
Test_Volt_CH3 := (INT_TO_REAL(D2002) * 10.0) / 16000.0; (* D2012-D2013 *)
Test_Volt_CH4 := (INT_TO_REAL(D2003) * 10.0) / 16000.0; (* D2014-D2015 *)
Test_Volt_CH5 := (INT_TO_REAL(D2004) * 10.0) / 16000.0; (* D2016-D2017 *)
Test_Volt_CH6 := (INT_TO_REAL(D2005) * 10.0) / 16000.0; (* D2018-D2019 *)
Test_Volt_CH7 := (INT_TO_REAL(D2006) * 10.0) / 16000.0; (* D2020-D2021 *)
Test_Volt_CH8 := (INT_TO_REAL(D2007) * 10.0) / 16000.0; (* D2022-D2023 *)

(* Giới hạn chống tràn âm *)
IF Test_Volt_CH1 < 0.0 THEN Test_Volt_CH1 := 0.0; END_IF;
IF Test_Volt_CH2 < 0.0 THEN Test_Volt_CH2 := 0.0; END_IF;
IF Test_Volt_CH3 < 0.0 THEN Test_Volt_CH3 := 0.0; END_IF;
IF Test_Volt_CH4 < 0.0 THEN Test_Volt_CH4 := 0.0; END_IF;
IF Test_Volt_CH5 < 0.0 THEN Test_Volt_CH5 := 0.0; END_IF;
IF Test_Volt_CH6 < 0.0 THEN Test_Volt_CH6 := 0.0; END_IF;
IF Test_Volt_CH7 < 0.0 THEN Test_Volt_CH7 := 0.0; END_IF;
IF Test_Volt_CH8 < 0.0 THEN Test_Volt_CH8 := 0.0; END_IF;

(* 4. GIÁM SÁT TRẠNG THÁI VÀ XÓA LỖI MODULE *)
M1001 := X00;   (* Đèn báo Module Q68ADV Ready *)
M1002 := X0E;   (* Đèn báo phát hiện lỗi phần cứng Q68ADV *)
D2024 := U0\G19; (* Đọc mã lỗi (Error Code) từ Buffer Memory 19 *)

(* Nút nhấn Reset lỗi từ HMI (M1000) kích cờ Y0E *)
Y0E := M1000;
IF Y0E AND NOT X0E THEN
    M1000 := FALSE; (* Tự động nhả nút nhấn khi hết lỗi *)
END_IF;
