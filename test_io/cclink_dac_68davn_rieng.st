(* ============================================================================ *)
(* CHƯƠNG TRÌNH ĐỘC LẬP: TEST CC-LINK DAC AJ65VBTCU-68DAVN (TRẠM 1)             *)
(* FILE: cclink_dac_68davn_rieng.st                                            *)
(* ĐẶC TÍNH: 8 KÊNH ANALOG OUTPUT (-10V..+10V, NẠP 4000 = +10.0V, 2000 = +5.0V) *)
(* ============================================================================ *)

(* 1. THIẾT LẬP THAM SỐ CẤU HÌNH BAN ĐẦU VÀO THANH GHI BỘ ĐỆM GỬI ĐI RWw *)
(* CHÚ Ý: Chuẩn Mitsubishi AJ65VBTCU-68DAVN thì bit=0 là ENABLE, bit=1 là PROHIBIT *)
W208 := 16#0000; (* RWw8: BẬT chuyển đổi D/A cả 8 kênh CH1..CH8 (0 = ENABLE) *)
W209 := 16#1111; (* RWw9: Dải Range CH1..CH4: 1H (0..5V, Nạp 4000 = 5.0V, 2000 = 2.5V) *)
W20A := 16#1111; (* RWwA: Dải Range CH5..CH8: 1H (0..5V, Nạp 4000 = 5.0V, 2000 = 2.5V) *)
W20B := 16#0000; (* RWwB: HOLD/CLEAR = 0 (CLEAR về 0V khi PLC STOP) *)

(* 2. BẮT TAY GIẢI PHÓNG YÊU CẦU BAN ĐẦU X1018 *)
Y1018 := X1018;

(* 3. CHU TRÌNH TUẦN TỰ NẠP RANGE VÀ MỞ CỔNG CÔNG SUẤT (STATE MACHINE D670) *)
CASE D670 OF
    0: (* Khởi động: Tắt ngõ ra xuất áp, chuẩn bị nạp Range *)
        Y1000 := FALSE; Y1001 := FALSE; Y1002 := FALSE; Y1003 := FALSE;
        Y1004 := FALSE; Y1005 := FALSE; Y1006 := FALSE; Y1007 := FALSE;
        Y1019 := FALSE;
        IF NOT X1018 THEN
            D670 := 10; (* Chuyển sang kích nạp Range *)
        END_IF;

    10: (* Kích sườn phát lệnh nạp Range vào chip DAC *)
        Y1019 := TRUE;
        (* Chờ module phản hồi đã nhận và nạp xong Range *)
        IF X1019 THEN
            Y1019 := FALSE; (* Hạ tín hiệu yêu cầu nạp *)
            D670  := 20;
        END_IF;

    20: (* Chờ module tắt cờ xác nhận và sẵn sàng *)
        Y1019 := FALSE;
        IF NOT X1019 THEN
            D670 := 100; (* Nạp Range hoàn tất mỹ mãn, sang bước xuất áp *)
        END_IF;

    100: (* ĐÃ HOÀN TẤT NẠP RANGE: CHÍNH THỨC MỞ KHÓA TOÀN BỘ 8 KÊNH XUẤT ÁP *)
        Y1019 := FALSE;
        Y1000 := TRUE; (* CH1 Analog Output Enable: MỞ CỔNG XUẤT ÁP *)
        Y1001 := TRUE; (* CH2 *)
        Y1002 := TRUE; (* CH3 *)
        Y1003 := TRUE; (* CH4 *)
        Y1004 := TRUE; (* CH5 *)
        Y1005 := TRUE; (* CH6 *)
        Y1006 := TRUE; (* CH7 *)
        Y1007 := TRUE; (* CH8 *)
END_CASE;

(* Nếu bấm nút M645: Cho phép chạy lại chu trình nạp Range từ đầu *)
IF M645 THEN
    D670 := 0;
    M645 := FALSE;
END_IF;

(* 4. ĐÈN BÁO TRẠNG THÁI VÀ NÚT RESET LỖI *)
M641  := X101B; (* Đèn báo Trạm 1 READY *)
M642  := X101A; (* Đèn báo Cờ Lỗi *)
Y101A := M648;  (* Nút bấm xóa cờ lỗi *)

(* 5. TỰ ĐỘNG NẠP MẶC ĐỊNH LÀ 10.0V (4000) ĐỂ ĐO CỰC ĐẠI THẤY NGAY *)
IF (D650 = 0) AND (NOT M650) AND (NOT M654) THEN
    D650 := 4000; D651 := 4000; D652 := 4000; D653 := 4000;
    D654 := 4000; D655 := 4000; D656 := 4000; D657 := 4000;
END_IF;

(* 6. CÁC NÚT BẤM TEST NHANH 4 MỨC ĐIỆN ÁP TRÊN HMI / MONITOR *)
IF M650 THEN (* 0.0V *)
    D650 := 0;    D651 := 0;    D652 := 0;    D653 := 0;
    D654 := 0;    D655 := 0;    D656 := 0;    D657 := 0;
    M650 := FALSE;
END_IF;

IF M651 THEN (* 2.5V *)
    D650 := 1000; D651 := 1000; D652 := 1000; D653 := 1000;
    D654 := 1000; D655 := 1000; D656 := 1000; D657 := 1000;
    M651 := FALSE;
END_IF;

IF M652 THEN (* 5.0V *)
    D650 := 2000; D651 := 2000; D652 := 2000; D653 := 2000;
    D654 := 2000; D655 := 2000; D656 := 2000; D657 := 2000;
    M652 := FALSE;
END_IF;

IF M653 THEN (* 10.0V *)
    D650 := 4000; D651 := 4000; D652 := 4000; D653 := 4000;
    D654 := 4000; D655 := 4000; D656 := 4000; D657 := 4000;
    M653 := FALSE;
END_IF;

(* 7. CHẾ ĐỘ QUÉT TỰ ĐỘNG SWEEP (0V -> 10V -> 0V) *)
IF M654 AND SM412 THEN
    IF NOT M649 THEN
        D660 := D660 + 100;
        IF D660 >= 4000 THEN D660 := 4000; M649 := TRUE; END_IF;
    ELSE
        D660 := D660 - 100;
        IF D660 <= 0 THEN D660 := 0; M649 := FALSE; END_IF;
    END_IF;
    D650 := D660; D651 := D660; D652 := D660; D653 := D660;
    D654 := D660; D655 := D660; D656 := D660; D657 := D660;
END_IF;

(* 8. XUẤT DỮ LIỆU SỐ LIÊN TỤC VÀO THANH GHI BỘ ĐỆM RWw0..RWw7 *)
W200 := D650; (* Kênh 1: 4000 -> ra 10.0V *)
W201 := D651; (* Kênh 2 *)
W202 := D652; (* Kênh 3 *)
W203 := D653; (* Kênh 4 *)
W204 := D654; (* Kênh 5 *)
W205 := D655; (* Kênh 6 *)
W206 := D656; (* Kênh 7 *)
W207 := D657; (* Kênh 8 *)

(* 9. GIÁM SÁT MÃ LỖI VÀ TRẠNG THÁI TRẠM *)
D681 := W108;    (* RWr8: Mã lỗi (0 = OK) *)
D683 := K4X1010; (* Cờ X1010..X101F *)
