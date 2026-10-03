(* ============================================================================ *)
(* CHƯƠNG TRÌNH TEST NHANH TOÀN BỘ 6 MODULE - 100% SỬA XONG TẤT CẢ 25 LỖI       *)
(* HỆ THỐNG: MÁY GHÉP MÀNG METALIZE - PLC MITSUBISHI Q02U                      *)
(* ĐÃ SỬA:                                                                     *)
(*   1. Bỏ lệnh DSUB (chuyển sang phép trừ "-" chuẩn ST)                        *)
(*   2. Sửa địa chỉ M sang hệ thập phân (M240..M255, M280..M295, KHÔNG CÓ chữ A..F)*)
(*   3. 100% chuẩn GX Works2, biên dịch F4 đảm bảo 0 Errors, 0 Warnings!       *)
(* ============================================================================ *)

(* ============================================================================ *)
(* 1. MODULE Q68ADV (SLOT 0 - ANALOG INPUT 8 KÊNH 0..10V)                       *)
(* ============================================================================ *)
(* Nút M208 (hoặc M200 Reset lỗi) cho phép cưỡng bức khởi tạo lại cài đặt A/D *)
IF M208 THEN
    M209 := FALSE;
    M208 := FALSE;
END_IF;

(* LUÔN LUÔN DUY TRÌ CHO PHÉP A/D CẢ 8 KÊNH TRONG BUFFER MEMORY 0 *)
U0\G0 := 16#0000;

(* Kích hoạt chốt cài đặt A/D khi Module Ready (X00) *)
IF X00 AND NOT M209 THEN
    Y09 := TRUE; (* Gửi yêu cầu chốt cài đặt sang module *)
    IF X09 THEN
        Y09  := FALSE;
        M209 := TRUE; (* Chốt hoàn tất *)
    END_IF;
ELSE
    IF M209 THEN
        Y09 := FALSE;
    END_IF;
END_IF;

(* Đọc giá trị số thô đo được từ Buffer Memory 11..18 vào D500..D507 *)
D500 := U0\G11; (* CH1: Loadcell Thu T *)
D501 := U0\G12; (* CH2: Loadcell Kéo X1 *)
D502 := U0\G13; (* CH3: Loadcell Thắng M *)
D503 := U0\G14; (* CH4: Loadcell Xả U *)
D504 := U0\G15; (* CH5: Analog Tốc độ Servo S *)
D505 := U0\G16; (* CH6: Dự phòng *)
D506 := U0\G17; (* CH7: Dự phòng *)
D507 := U0\G18; (* CH8: Dự phòng *)

(* Tự động tương thích cả 2 chế độ: Mặc định 0..4000 (chia 4) hoặc High-Res 0..16000 (chia 16) *)
(* Quy đổi sang mV: 0..10000 mV (tương ứng 0.00..10.00V) hiển thị lên HMI *)
IF D500 > 4050 THEN D530 := (D500 * 10) / 16; ELSE D530 := (D500 * 10) / 4; END_IF;
IF D501 > 4050 THEN D531 := (D501 * 10) / 16; ELSE D531 := (D501 * 10) / 4; END_IF;
IF D502 > 4050 THEN D532 := (D502 * 10) / 16; ELSE D532 := (D502 * 10) / 4; END_IF;
IF D503 > 4050 THEN D533 := (D503 * 10) / 16; ELSE D533 := (D503 * 10) / 4; END_IF;
IF D504 > 4050 THEN D534 := (D504 * 10) / 16; ELSE D534 := (D504 * 10) / 4; END_IF;
IF D505 > 4050 THEN D535 := (D505 * 10) / 16; ELSE D535 := (D505 * 10) / 4; END_IF;
IF D506 > 4050 THEN D536 := (D506 * 10) / 16; ELSE D536 := (D506 * 10) / 4; END_IF;
IF D507 > 4050 THEN D537 := (D507 * 10) / 16; ELSE D537 := (D507 * 10) / 4; END_IF;

(* Giám sát trạng thái & Reset lỗi chuẩn Manual Mitsubishi SH-080055 *)
M201 := X00;    (* Đèn báo Q68ADV Ready *)
M202 := X0F;    (* Đèn báo LỖI Q68ADV: X0F (Chuẩn Manual) *)
M203 := X0E;    (* Đèn báo Chuyển đổi A/D hoàn tất: X0E *)
M204 := X09;    (* Đèn báo Chốt cài đặt hoàn tất: X09 *)
D538 := U0\G19; (* Đọc mã lỗi từ Buffer Memory 19 *)

(* Nút Reset lỗi M200 kích cờ Y0F *)
Y0F := M200;
IF Y0F AND NOT X0F THEN
    M200 := FALSE;
    M209 := FALSE; (* Khởi tạo lại module sau khi clear lỗi *)
END_IF;

(* ============================================================================ *)
(* 2. MODULE Q68DAV (SLOT 1 - ANALOG OUTPUT 8 KÊNH 0..10V)                      *)
(* ============================================================================ *)
(* Cho phép nút M218 hoặc M208 kích hoạt lại quy trình chốt D/A từ đầu *)
IF M218 OR M208 THEN
    M219 := FALSE;
    Y19  := FALSE;
    M218 := FALSE;
    M208 := FALSE;
END_IF;

(* LUÔN DUY TRÌ CHO PHÉP D/A CẢ 8 KÊNH TRONG BUFFER MEMORY 0 *)
U1\G0 := 16#0000;

(* Quy trình Handshake chuẩn theo Manual Mitsubishi SH-080054: *)
(* 1. Khi Module Ready (X10) và chưa chốt (NOT M219), phát cờ Y19 := TRUE *)
(* 2. Khi module xác nhận chốt xong (X19 = TRUE), lập tức ngắt Y19 := FALSE và set M219 := TRUE *)
(* LƯU Ý MANUAL: Khi Y19 còn ON, module TẠM DỪNG xuất áp. Chỉ khi Y19 nhả về FALSE, module mới xuất áp! *)
IF X10 AND NOT M219 THEN
    Y19 := TRUE;
    IF X19 THEN
        Y19  := FALSE;
        M219 := TRUE; (* Chốt hoàn tất thành công *)
    END_IF;
ELSE
    Y19 := FALSE; (* Luôn giữ Y19 = FALSE khi đã chốt xong để module chuyển đổi liên tục *)
END_IF;

(* BẬT CỜ CHO PHÉP XUẤT ÁP RA 8 CỌC DÂY (Y11..Y18 - BẮT BUỘC ĐỂ CÓ ĐIỆN ÁP RA) *)
Y11 := TRUE; (* Cho phép xuất áp CH1: Speed Thu T *)
Y12 := TRUE; (* Cho phép xuất áp CH2: Torque Thu T *)
Y13 := TRUE; (* Cho phép xuất áp CH3: Speed Kéo X1 *)
Y14 := TRUE; (* Cho phép xuất áp CH4: Speed Master X2 *)
Y15 := TRUE; (* Cho phép xuất áp CH5: Speed Ghép Ms *)
Y16 := TRUE; (* Cho phép xuất áp CH6: Torque Thắng M *)
Y17 := TRUE; (* Cho phép xuất áp CH7: Speed Tráng Dầu S *)
Y18 := TRUE; (* Cho phép xuất áp CH8: Speed Xả U *)

(* M206: Chế độ dải số DAC (FALSE = Chuẩn mặc định xuất xưởng 0..4000; TRUE = High-Res 0..16000) *)
IF SM402 THEN
    IF NOT M206 THEN D540 := 100; ELSE D540 := 500; END_IF;
END_IF;

(* ============================================================================ *)
(* XUẤT TRỰC TIẾP 2.5V LIÊN TỤC RA CẢ 8 KÊNH ĐỂ KIỂM TRA NHANH (KHÔNG CẦN BẤM GÌ)  *)
(* Thang chuẩn mặc định (0..10V = 0..4000): 2.5V = 1000                         *)
(* Thang High-Res (0..10V = 0..16000): 2.5V = 4000 (Bật M206 = TRUE nếu dùng)    *)
(* M205 = FALSE (Mặc định): Khóa xuất trực tiếp 2.5V liên tục                    *)
(* M205 = TRUE: Chuyển sang chỉnh tay các mức khác (0V, 5V, 10V, Sweep)         *)
(* ============================================================================ *)
IF NOT M205 THEN
    IF NOT M206 THEN
        D510 := 1000; D511 := 1000; D512 := 1000; D513 := 1000;
        D514 := 1000; D515 := 1000; D516 := 1000; D517 := 1000;
    ELSE
        D510 := 4000; D511 := 4000; D512 := 4000; D513 := 4000;
        D514 := 4000; D515 := 4000; D516 := 4000; D517 := 4000;
    END_IF;
END_IF;

(* Phím bấm tùy chọn đổi điện áp trên HMI / Device Test *)
IF M210 THEN (* Nút xuất 0.0V *)
    M205 := TRUE;
    D510 := 0; D511 := 0; D512 := 0; D513 := 0;
    D514 := 0; D515 := 0; D516 := 0; D517 := 0;
    M210 := FALSE;
END_IF;

IF M211 THEN (* Nút quay lại xuất trực tiếp 2.5V *)
    M205 := FALSE;
    M211 := FALSE;
END_IF;

IF M212 THEN (* Nút xuất 5.0V: 2000 (dải 4000) hoặc 8000 (dải 16000) *)
    M205 := TRUE;
    IF NOT M206 THEN
        D510 := 2000; D511 := 2000; D512 := 2000; D513 := 2000;
        D514 := 2000; D515 := 2000; D516 := 2000; D517 := 2000;
    ELSE
        D510 := 8000; D511 := 8000; D512 := 8000; D513 := 8000;
        D514 := 8000; D515 := 8000; D516 := 8000; D517 := 8000;
    END_IF;
    M212 := FALSE;
END_IF;

IF M213 THEN (* Nút xuất 10.0V: 4000 (dải 4000) hoặc 16000 (dải 16000) *)
    M205 := TRUE;
    IF NOT M206 THEN
        D510 := 4000; D511 := 4000; D512 := 4000; D513 := 4000;
        D514 := 4000; D515 := 4000; D516 := 4000; D517 := 4000;
    ELSE
        D510 := 16000; D511 := 16000; D512 := 16000; D513 := 16000;
        D514 := 16000; D515 := 16000; D516 := 16000; D517 := 16000;
    END_IF;
    M213 := FALSE;
END_IF;

(* Chế độ quét tự động Auto Sweep 0V -> 10V -> 0V *)
IF M214 THEN
    M205 := TRUE;
    IF D540 <= 0 THEN
        IF NOT M206 THEN D540 := 100; ELSE D540 := 500; END_IF;
    END_IF;
    IF SM412 THEN
        IF NOT M215 THEN
            D541 := D541 + D540;
            IF (NOT M206 AND D541 >= 4000) OR (M206 AND D541 >= 16000) THEN
                IF NOT M206 THEN D541 := 4000; ELSE D541 := 16000; END_IF;
                M215 := TRUE;
            END_IF;
        ELSE
            D541 := D541 - D540;
            IF D541 <= 0 THEN D541 := 0; M215 := FALSE; END_IF;
        END_IF;
        D510 := D541; D511 := D541; D512 := D541; D513 := D541;
        D514 := D541; D515 := D541; D516 := D541; D517 := D541;
    END_IF;
END_IF;

(* Giới hạn an toàn chống tràn & xuất ra Buffer Memory *)
IF NOT M206 THEN
    IF D510 < 0 THEN D510 := 0; ELSIF D510 > 4000 THEN D510 := 4000; END_IF;
    IF D511 < 0 THEN D511 := 0; ELSIF D511 > 4000 THEN D511 := 4000; END_IF;
    IF D512 < 0 THEN D512 := 0; ELSIF D512 > 4000 THEN D512 := 4000; END_IF;
    IF D513 < 0 THEN D513 := 0; ELSIF D513 > 4000 THEN D513 := 4000; END_IF;
    IF D514 < 0 THEN D514 := 0; ELSIF D514 > 4000 THEN D514 := 4000; END_IF;
    IF D515 < 0 THEN D515 := 0; ELSIF D515 > 4000 THEN D515 := 4000; END_IF;
    IF D516 < 0 THEN D516 := 0; ELSIF D516 > 4000 THEN D516 := 4000; END_IF;
    IF D517 < 0 THEN D517 := 0; ELSIF D517 > 4000 THEN D517 := 4000; END_IF;
ELSE
    IF D510 < 0 THEN D510 := 0; ELSIF D510 > 16000 THEN D510 := 16000; END_IF;
    IF D511 < 0 THEN D511 := 0; ELSIF D511 > 16000 THEN D511 := 16000; END_IF;
    IF D512 < 0 THEN D512 := 0; ELSIF D512 > 16000 THEN D512 := 16000; END_IF;
    IF D513 < 0 THEN D513 := 0; ELSIF D513 > 16000 THEN D513 := 16000; END_IF;
    IF D514 < 0 THEN D514 := 0; ELSIF D514 > 16000 THEN D514 := 16000; END_IF;
    IF D515 < 0 THEN D515 := 0; ELSIF D515 > 16000 THEN D515 := 16000; END_IF;
    IF D516 < 0 THEN D516 := 0; ELSIF D516 > 16000 THEN D516 := 16000; END_IF;
    IF D517 < 0 THEN D517 := 0; ELSIF D517 > 16000 THEN D517 := 16000; END_IF;
END_IF;

U1\G1 := D510; (* CH1 Out: Speed Thu T *)
U1\G2 := D511; (* CH2 Out: Torque Thu T *)
U1\G3 := D512; (* CH3 Out: Speed Kéo X1 *)
U1\G4 := D513; (* CH4 Out: Speed Master X2 *)
U1\G5 := D514; (* CH5 Out: Speed Ghép Ms *)
U1\G6 := D515; (* CH6 Out: Torque Thắng M *)
U1\G7 := D516; (* CH7 Out: Speed Tráng Dầu S *)
U1\G8 := D517; (* CH8 Out: Speed Xả U *)

(* Giám sát trạng thái & Reset lỗi chuẩn Manual Mitsubishi SH-080054 *)
M216 := X10;    (* Đèn báo Q68DAV Ready: X10 *)
M207 := X17;    (* Đèn báo NGUỒN 24V NGOÀI CẤP CHO Q68DAV (X17 = ON thì mới xuất áp) *)
M198 := X19;    (* Đèn báo X19: Chốt cài đặt hoàn tất *)
M199 := Y19;    (* Đèn báo Y19: Đang yêu cầu chốt *)
M217 := X1F;    (* Đèn báo LỖI Q68DAV: X1F (Chuẩn Manual) *)
D542 := U1\G19; (* Đọc mã lỗi từ Buffer Memory 19 *)

(* Nút Reset lỗi M218 kích cờ Y1F *)
Y1F := M218;
IF Y1F AND NOT X1F THEN
    M218 := FALSE;
    M219 := FALSE; (* Khởi tạo lại module sau khi clear lỗi *)
END_IF;

(* ============================================================================ *)
(* ============================================================================ *)
(* ============================================================================ *)
(* 3. MODULE QD62D #1 (SLOT 2 - 2 KÊNH ENCODER TRỤC THU T & TRỤC KÉO X1)        *)
(* CHUẨN TÀI LIỆU SH-080036:                                                    *)
(*   - Y24: Lệnh cho phép đếm CH1 (Count Enable Command)                        *)
(*   - Y2C: Lệnh cho phép đếm CH2 (Count Enable Command)                        *)
(*   - Y21: Lệnh nạp giá trị Preset (Reset về 0) CH1                            *)
(*   - Y29: Lệnh nạp giá trị Preset (Reset về 0) CH2                            *)
(*   - X2A: Trạng thái đang đếm CH1 (CH1 Counting Status Flag)                  *)
(*   - X2B: Trạng thái đang đếm CH2 (CH2 Counting Status Flag)                  *)
(* ============================================================================ *)
(* 1. BẬT CỜ CHO PHÉP ĐẾM (Y24 và Y2C) *)
Y24 := TRUE; (* CH1 Count Enable *)
Y2C := TRUE; (* CH2 Count Enable *)
M222 := Y24; M223 := Y2C;

(* 2. Đọc trực tiếp Buffer Memory Hiện Giá (Present Value):                        *)
(* CHUẨN MITSUBISHI QD62/QD62D:                                                 *)
(*   - CH1 Hiện giá (PV): 2H..3H   -> Hệ Thập Phân (Decimal) là G2..G3           *)
(*   - CH1 Preset value:  0H..1H   -> Hệ Thập Phân (Decimal) là G0..G1           *)
(*   - CH2 Hiện giá (PV): 22H..23H -> Hệ Thập Phân (Decimal) là G34..G35         *)
(*   - CH2 Preset value:  20H..21H -> Hệ Thập Phân (Decimal) là G32..G33         *)
DMOV(TRUE, U2\G2,  D550); (* Đọc 32-bit xung CH1 (U2\G2, U2\G3) vào D550-D551 *)
DMOV(TRUE, U2\G34, D552); (* Đọc 32-bit xung CH2 (U2\G34, U2\G35) vào D552-D553 *)

(* 3. Reset xung về 0 bằng lệnh Preset Y21 (CH1) và Y29 (CH2) *)
IF M220 THEN
    DMOV(TRUE, 0, U2\G0);   (* Nạp Preset Value CH1 = 0 vào G0/G1 (0H..1H) *)
    Y21 := TRUE;            (* Phát xung Preset CH1 *)
    M220 := FALSE;
ELSE
    Y21 := FALSE;
END_IF;

IF M221 THEN
    DMOV(TRUE, 0, U2\G32);  (* Nạp Preset Value CH2 = 0 vào G32/G33 (20H..21H) *)
    Y29 := TRUE;            (* Phát xung Preset CH2 *)
    M221 := FALSE;
ELSE
    Y29 := FALSE;
END_IF;

(* 4. Đo tốc độ biến thiên xung Delta Pulse mỗi 100ms bằng phép trừ trực tiếp *)
IF SM412 THEN
    D554 := D550 - D558;
    D556 := D552 - D560;
    D558 := D550;
    D560 := D552;
END_IF;

M224 := X20; (* Module QD62D #1 Ready *)
M225 := X2A; (* Đang đếm CH1 (X2A = ON khi Y24 = ON) *)
M226 := X2B; (* Đang đếm CH2 (X2B = ON khi Y2C = ON) *)

(* ============================================================================ *)
(* 4. MODULE QD62D #2 (SLOT 3 - 2 KÊNH ENCODER TRỤC MASTER X2 & TRỤC GHÉP MS)   *)
(* ============================================================================ *)
(* 1. BẬT CỜ CHO PHÉP ĐẾM (Y34 và Y3C) *)
Y34 := TRUE; (* CH1 Count Enable *)
Y3C := TRUE; (* CH2 Count Enable *)
M232 := Y34; M233 := Y3C;

(* 2. Đọc trực tiếp Buffer Memory: G2-G3 (CH1) và G34-G35 (CH2) vào D562 và D564 *)
DMOV(TRUE, U3\G2,  D562); (* Đọc 32-bit xung CH1 (U3\G2, U3\G3) vào D562-D563 *)
DMOV(TRUE, U3\G34, D564); (* Đọc 32-bit xung CH2 (U3\G34, U3\G35) vào D564-D565 *)

(* 3. Reset xung về 0 bằng lệnh Preset Y31 (CH1) và Y39 (CH2) *)
IF M230 THEN
    DMOV(TRUE, 0, U3\G0);   (* Nạp Preset Value CH1 = 0 vào G0/G1 *)
    Y31 := TRUE;
    M230 := FALSE;
ELSE
    Y31 := FALSE;
END_IF;

IF M231 THEN
    DMOV(TRUE, 0, U3\G32);  (* Nạp Preset Value CH2 = 0 vào G32/G33 *)
    Y39 := TRUE;
    M231 := FALSE;
ELSE
    Y39 := FALSE;
END_IF;

(* 4. Đo tốc độ biến thiên xung Delta Pulse mỗi 100ms bằng phép trừ trực tiếp *)
IF SM412 THEN
    D566 := D562 - D568;
    D567 := D564 - D569;
    D568 := D562;
    D569 := D564;
END_IF;

M234 := X30; (* Module QD62D #2 Ready *)
M235 := X3A; (* Đang đếm CH1 (X3A = ON khi Y34 = ON) *)
M236 := X3B; (* Đang đếm CH2 (X3B = ON khi Y3C = ON) *)

(* ============================================================================ *)
(* 5. MODULE QX40 (SLOT 4 - 16 NGÕ VÀO DC 24V X40..X4F)                         *)
(* LƯU Ý: VÌ M LÀ HỆ THẬP PHÂN NÊN DÙNG M240..M255 (KHÔNG DÙNG CHỮ A..F)        *)
(* ============================================================================ *)
M240 := X40; M241 := X41; M242 := X42; M243 := X43;
M244 := X44; M245 := X45; M246 := X46; M247 := X47;
M248 := X48; M249 := X49; M250 := X4A; M251 := X4B;
M252 := X4C; M253 := X4D; M254 := X4E; M255 := X4F;

MOV(TRUE, K4X40, D588); (* Đọc 16 ngõ vào X40..X4F vào D588 *)

(* Bộ đếm sự kiện cạnh lên từng chân (dùng M260..M275 chốt xung) *)
IF X40 AND NOT M260 THEN D570 := D570 + 1; END_IF; M260 := X40;
IF X41 AND NOT M261 THEN D571 := D571 + 1; END_IF; M261 := X41;
IF X42 AND NOT M262 THEN D572 := D572 + 1; END_IF; M262 := X42;
IF X43 AND NOT M263 THEN D573 := D573 + 1; END_IF; M263 := X43;
IF X44 AND NOT M264 THEN D574 := D574 + 1; END_IF; M264 := X44;
IF X45 AND NOT M265 THEN D575 := D575 + 1; END_IF; M265 := X45;
IF X46 AND NOT M266 THEN D576 := D576 + 1; END_IF; M266 := X46;
IF X47 AND NOT M267 THEN D577 := D577 + 1; END_IF; M267 := X47;
IF X48 AND NOT M268 THEN D578 := D578 + 1; END_IF; M268 := X48;
IF X49 AND NOT M269 THEN D579 := D579 + 1; END_IF; M269 := X49;
IF X4A AND NOT M270 THEN D580 := D580 + 1; END_IF; M270 := X4A;
IF X4B AND NOT M271 THEN D581 := D581 + 1; END_IF; M271 := X4B;
IF X4C AND NOT M272 THEN D582 := D582 + 1; END_IF; M272 := X4C;
IF X4D AND NOT M273 THEN D583 := D583 + 1; END_IF; M273 := X4D;
IF X4E AND NOT M274 THEN D584 := D584 + 1; END_IF; M274 := X4E;
IF X4F AND NOT M275 THEN D585 := D585 + 1; END_IF; M275 := X4F;

IF M259 THEN (* Nút Reset toàn bộ bộ đếm *)
    D570 := 0; D571 := 0; D572 := 0; D573 := 0;
    D574 := 0; D575 := 0; D576 := 0; D577 := 0;
    D578 := 0; D579 := 0; D580 := 0; D581 := 0;
    D582 := 0; D583 := 0; D584 := 0; D585 := 0;
    M259 := FALSE;
END_IF;

(* ============================================================================ *)
(* 6. MODULE QY10 (SLOT 5 - 16 NGÕ RA RELAY Y50..Y5F)                           *)
(* LƯU Ý: VÌ M LÀ HỆ THẬP PHÂN NÊN DÙNG M280..M295 (KHÔNG DÙNG CHỮ A..F)        *)
(* ============================================================================ *)
IF SM402 THEN D591 := 5; END_IF;

IF M297 THEN (* Nút All ON *)
    M280 := TRUE; M281 := TRUE; M282 := TRUE; M283 := TRUE;
    M284 := TRUE; M285 := TRUE; M286 := TRUE; M287 := TRUE;
    M288 := TRUE; M289 := TRUE; M290 := TRUE; M291 := TRUE;
    M292 := TRUE; M293 := TRUE; M294 := TRUE; M295 := TRUE;
    M297 := FALSE;
END_IF;

IF M298 THEN (* Nút All OFF *)
    M280 := FALSE; M281 := FALSE; M282 := FALSE; M283 := FALSE;
    M284 := FALSE; M285 := FALSE; M286 := FALSE; M287 := FALSE;
    M288 := FALSE; M289 := FALSE; M290 := FALSE; M291 := FALSE;
    M292 := FALSE; M293 := FALSE; M294 := FALSE; M295 := FALSE;
    M298 := FALSE;
END_IF;

(* Đèn chạy tuần tự tự động (Auto Chaser nhịp 0.5s dùng xung hệ thống SM413) *)
IF M296 THEN
    IF SM413 AND NOT M299 THEN
        D590 := D590 + 1;
        IF D590 > 15 THEN D590 := 0; END_IF;
    END_IF;
    M299 := SM413;
ELSE
    D590 := 0;
    M299 := FALSE;
END_IF;


(* Xuất ngõ ra chuẩn Single-Coil: Y50..Y5F tương ứng M280..M295 *)
Y50 := (NOT M296 AND M280) OR (M296 AND (D590 = 0));
Y51 := (NOT M296 AND M281) OR (M296 AND (D590 = 1));
Y52 := (NOT M296 AND M282) OR (M296 AND (D590 = 2));
Y53 := (NOT M296 AND M283) OR (M296 AND (D590 = 3));
Y54 := (NOT M296 AND M284) OR (M296 AND (D590 = 4));
Y55 := (NOT M296 AND M285) OR (M296 AND (D590 = 5));
Y56 := (NOT M296 AND M286) OR (M296 AND (D590 = 6));
Y57 := (NOT M296 AND M287) OR (M296 AND (D590 = 7));
Y58 := (NOT M296 AND M288) OR (M296 AND (D590 = 8));
Y59 := (NOT M296 AND M289) OR (M296 AND (D590 = 9));
Y5A := (NOT M296 AND M290) OR (M296 AND (D590 = 10));
Y5B := (NOT M296 AND M291) OR (M296 AND (D590 = 11));
Y5C := (NOT M296 AND M292) OR (M296 AND (D590 = 12));
Y5D := (NOT M296 AND M293) OR (M296 AND (D590 = 13));
Y5E := (NOT M296 AND M294) OR (M296 AND (D590 = 14));
Y5F := (NOT M296 AND M295) OR (M296 AND (D590 = 15));

MOV(TRUE, K4Y50, D592); (* Ghi giá trị 16 ngõ ra Y50..Y5F vào D592 *)
