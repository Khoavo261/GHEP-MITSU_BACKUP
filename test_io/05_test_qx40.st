(* ============================================================================ *)
(* CHƯƠNG TRÌNH TEST MODULE 5: QX40 (DIGITAL DC INPUT - 16 NGÕ VÀO X40..X4F)     *)
(* VỊ TRÍ PHẦN CỨNG: SLOT 4 (HEAD ADDRESS: H40 - ĐỊA CHỈ I/O: X40..X4F)         *)
(* TÍNH NĂNG:                                                                   *)
(*   - Giám sát trực tiếp trạng thái logic 16 ngõ vào qua bit M1080..M1095       *)
(*   - Gộp 16 bit vào 1 Word hiển thị D2120 (Word Bitmask)                       *)
(*   - Bộ đếm xung kích hoạt cạnh lên (Event Counter) cho từng chân D2100..D2115 *)
(*     (Cực kỳ hiệu quả để phát hiện nút bấm chập chờn hoặc test cảm biến tiệm cận) *)
(*   - Nút nhấn Reset toàn bộ bộ đếm từ HMI (M1099)                              *)
(* ============================================================================ *)

(* 1. ÁNH XẠ TRỰC TIẾP TRẠNG THÁI 16 NGÕ VÀO X40..X4F RA BIT NỘI BỘ M *)
M1080 := X40; (* X40: Ready Servo Thu T *)
M1081 := X41; (* X41: Ready Servo Kéo X1 *)
M1082 := X42; (* X42: Ready Servo Master X2 *)
M1083 := X43; (* X43: Ready Servo Ghép Ms *)
M1084 := X44; (* X44: Ready Servo Dầu S *)
M1085 := X45; (* X45: Nút nhấn cơ START *)
M1086 := X46; (* X46: Nút nhấn cơ STOP *)
M1087 := X47; (* X47: Nút nhấn cơ TĂNG TỐC INC *)
M1088 := X48; (* X48: Nút nhấn cơ GIẢM TỐC DEC *)
M1089 := X49; (* X49: Nút nhấn cơ BÒ CHẬM JOG *)
M1090 := X4A; (* X4A: Sensor tiệm cận cuộn Thắng M *)
M1091 := X4B; (* X4B: Sensor tiệm cận cuộn Xả U *)
M1092 := X4C; (* X4C: Công tắc Pen 1 *)
M1093 := X4D; (* X4D: Công tắc Pen 2 *)
M1094 := X4E; (* X4E: Công tắc Giữ Torque M *)
M1095 := X4F; (* X4F: Công tắc Giữ Torque U *)

(* 2. GỘP TOÀN BỘ 16 NGÕ VÀO VÀO 1 WORD D2120 ĐỂ HIỂN THỊ HEX TRÊN HMI *)
D2120.0 := X40; D2120.1 := X41; D2120.2 := X42; D2120.3 := X43;
D2120.4 := X44; D2120.5 := X45; D2120.6 := X46; D2120.7 := X47;
D2120.8 := X48; D2120.9 := X49; D2120.A := X4A; D2120.B := X4B;
D2120.C := X4C; D2120.D := X4D; D2120.E := X4E; D2120.F := X4F;

(* 3. BỘ ĐẾM SỰ KIỆN CẠNH LÊN (EVENT COUNTERS) TỪNG CHÂN ĐỂ TEST TIỆM CẬN / TIẾP ĐIỂM *)
(* X40 *)
IF X40 AND NOT M1080_Old THEN D2100 := D2100 + 1; END_IF;
M1080_Old := X40;

(* X41 *)
IF X41 AND NOT M1081_Old THEN D2101 := D2101 + 1; END_IF;
M1081_Old := X41;

(* X42 *)
IF X42 AND NOT M1082_Old THEN D2102 := D2102 + 1; END_IF;
M1082_Old := X42;

(* X43 *)
IF X43 AND NOT M1083_Old THEN D2103 := D2103 + 1; END_IF;
M1083_Old := X43;

(* X44 *)
IF X44 AND NOT M1084_Old THEN D2104 := D2104 + 1; END_IF;
M1084_Old := X44;

(* X45 *)
IF X45 AND NOT M1085_Old THEN D2105 := D2105 + 1; END_IF;
M1085_Old := X45;

(* X46 *)
IF X46 AND NOT M1086_Old THEN D2106 := D2106 + 1; END_IF;
M1086_Old := X46;

(* X47 *)
IF X47 AND NOT M1087_Old THEN D2107 := D2107 + 1; END_IF;
M1087_Old := X47;

(* X48 *)
IF X48 AND NOT M1088_Old THEN D2108 := D2108 + 1; END_IF;
M1088_Old := X48;

(* X49 *)
IF X49 AND NOT M1089_Old THEN D2109 := D2109 + 1; END_IF;
M1089_Old := X49;

(* X4A *)
IF X4A AND NOT M1090_Old THEN D2110 := D2110 + 1; END_IF;
M1090_Old := X4A;

(* X4B *)
IF X4B AND NOT M1091_Old THEN D2111 := D2111 + 1; END_IF;
M1091_Old := X4B;

(* X4C *)
IF X4C AND NOT M1092_Old THEN D2112 := D2112 + 1; END_IF;
M1092_Old := X4C;

(* X4D *)
IF X4D AND NOT M1093_Old THEN D2113 := D2113 + 1; END_IF;
M1093_Old := X4D;

(* X4E *)
IF X4E AND NOT M1094_Old THEN D2114 := D2114 + 1; END_IF;
M1094_Old := X4E;

(* X4F *)
IF X4F AND NOT M1095_Old THEN D2115 := D2115 + 1; END_IF;
M1095_Old := X4F;

(* 4. NÚT NHẤN RESET TOÀN BỘ BỘ ĐẾM SỰ KIỆN TỪ HMI *)
IF M1099 THEN
    D2100 := 0; D2101 := 0; D2102 := 0; D2103 := 0;
    D2104 := 0; D2105 := 0; D2106 := 0; D2107 := 0;
    D2108 := 0; D2109 := 0; D2110 := 0; D2111 := 0;
    D2112 := 0; D2113 := 0; D2114 := 0; D2115 := 0;
    M1099 := FALSE;
END_IF;
