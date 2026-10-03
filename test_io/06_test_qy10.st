(* ============================================================================ *)
(* CHƯƠNG TRÌNH TEST MODULE 6: QY10 (DIGITAL RELAY OUTPUT - 16 NGÕ RA Y50..Y5F) *)
(* VỊ TRÍ PHẦN CỨNG: SLOT 5 (HEAD ADDRESS: H50 - ĐỊA CHỈ I/O: Y50..Y5F)         *)
(* TÍNH NĂNG:                                                                   *)
(*   - Chế độ Manual: Kích ON/OFF từng ngõ ra qua bit M1100..M1115               *)
(*   - Phím tắt kích nhanh: All ON (M1117) và All OFF (M1118)                    *)
(*   - Chế độ Auto Chaser (M1116): Tự động bật tuần tự từng rơ le Y50 -> Y5F     *)
(*     theo chu kỳ D2131 (mặc định 500ms) để test rơ le / cuộn hút rảnh tay    *)
(*   - Tuân thủ tuyệt đối quy tắc Single-Coil tránh lỗi cảnh báo C9300           *)
(* ============================================================================ *)

(* 1. KHỞI TẠO CẤU HÌNH THỜI GIAN TEST CHASER *)
IF SM402 THEN
    D2131 := 5; (* Thời gian mỗi bước chaser: 5 * 100ms = 500ms (0.5 giây) *)
END_IF;

(* 2. CÁC NÚT BẤM KÍCH NHANH TRÊN HMI *)
IF M1117 THEN (* All ON *)
    M1100 := TRUE; M1101 := TRUE; M1102 := TRUE; M1103 := TRUE;
    M1104 := TRUE; M1105 := TRUE; M1106 := TRUE; M1107 := TRUE;
    M1108 := TRUE; M1109 := TRUE; M1110 := TRUE; M1111 := TRUE;
    M1112 := TRUE; M1113 := TRUE; M1114 := TRUE; M1115 := TRUE;
    M1117 := FALSE;
END_IF;

IF M1118 THEN (* All OFF *)
    M1100 := FALSE; M1101 := FALSE; M1102 := FALSE; M1103 := FALSE;
    M1104 := FALSE; M1105 := FALSE; M1106 := FALSE; M1107 := FALSE;
    M1108 := FALSE; M1109 := FALSE; M1110 := FALSE; M1111 := FALSE;
    M1112 := FALSE; M1113 := FALSE; M1114 := FALSE; M1115 := FALSE;
    M1118 := FALSE;
END_IF;

(* 3. LOGIC CHẠY TUẦN TỰ TỰ ĐỘNG (AUTO CHASER / RUNNING RELAY TEST) *)
IF M1116 THEN
    IF D2131 < 1 THEN D2131 := 5; END_IF;

    (* Timer T100 tạo nhịp chuyển bước *)
    OUT_T(NOT TS100, T100, D2131);

    IF TS100 THEN
        D2130 := D2130 + 1; (* Chuyển sang rơ le kế tiếp *)
        IF D2130 > 15 THEN
            D2130 := 0;     (* Quay vòng lại Y50 *)
        END_IF;
    END_IF;
ELSE
    D2130 := 0;
END_IF;

(* 4. GÁN ĐẦU RA Y50..Y5F (CHUẨN SINGLE-COIL DUY NHẤT) *)
Y50 := (NOT M1116 AND M1100) OR (M1116 AND (D2130 = 0));  (* Servo ON Thu T *)
Y51 := (NOT M1116 AND M1101) OR (M1116 AND (D2130 = 1));  (* Servo ON Kéo X1 *)
Y52 := (NOT M1116 AND M1102) OR (M1116 AND (D2130 = 2));  (* Servo ON Master X2 *)
Y53 := (NOT M1116 AND M1103) OR (M1116 AND (D2130 = 3));  (* Servo ON Ghép Ms *)
Y54 := (NOT M1116 AND M1104) OR (M1116 AND (D2130 = 4));  (* Servo ON Dầu S *)
Y55 := (NOT M1116 AND M1105) OR (M1116 AND (D2130 = 5));  (* Van Pen 1 *)
Y56 := (NOT M1116 AND M1106) OR (M1116 AND (D2130 = 6));  (* Van Pen 2 *)
Y57 := (NOT M1116 AND M1107) OR (M1116 AND (D2130 = 7));  (* Còi báo động *)
Y58 := (NOT M1116 AND M1108) OR (M1116 AND (D2130 = 8));  (* Đèn tháp XANH *)
Y59 := (NOT M1116 AND M1109) OR (M1116 AND (D2130 = 9));  (* Đèn tháp VÀNG *)
Y5A := (NOT M1116 AND M1110) OR (M1116 AND (D2130 = 10)); (* Đèn tháp ĐỎ *)
Y5B := (NOT M1116 AND M1111) OR (M1116 AND (D2130 = 11)); (* Dự phòng Y5B *)
Y5C := (NOT M1116 AND M1112) OR (M1116 AND (D2130 = 12)); (* Dự phòng Y5C *)
Y5D := (NOT M1116 AND M1113) OR (M1116 AND (D2130 = 13)); (* Dự phòng Y5D *)
Y5E := (NOT M1116 AND M1114) OR (M1116 AND (D2130 = 14)); (* Dự phòng Y5E *)
Y5F := (NOT M1116 AND M1115) OR (M1116 AND (D2130 = 15)); (* Dự phòng Y5F *)

(* 5. GỘP TOÀN BỘ TRẠNG THÁI 16 NGÕ RA VÀO WORD D2132 ĐỂ HIỂN THỊ HEX TRÊN HMI *)
D2132.0 := Y50; D2132.1 := Y51; D2132.2 := Y52; D2132.3 := Y53;
D2132.4 := Y54; D2132.5 := Y55; D2132.6 := Y56; D2132.7 := Y57;
D2132.8 := Y58; D2132.9 := Y59; D2132.A := Y5A; D2132.B := Y5B;
D2132.C := Y5C; D2132.D := Y5D; D2132.E := Y5E; D2132.F := Y5F;
