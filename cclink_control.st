(* ============================================================================ *)
(* PROGRAM: POU_CCLINK_CONTROL                                                  *)
(* HARDWARE: PLC Q02UCPU + Master QJ61BT11N (Slot 0)                             *)
(* BASE ADDRESSES: Remote Input (RX) = M1008 | Remote Output (RY) = M1200        *)
(* ============================================================================ *)

(* --- 1. CC-LINK NETWORK MONITOR & HANDSHAKE INITIALIZATION --- *)
(* SB0020=FALSE (0) và SB0049=FALSE (0): Mạng truyền thông CC-Link hoạt động bình thường *)
IF (NOT SB0020) AND (NOT SB0049) THEN

    (* Kích hoạt cho phép chuyển đổi A/D kênh 1..4 trên AJ65SBT-64AD (Trạm 1) *)
    M1208 := TRUE;  (* RY8: AD Conversion Enable (M1200 + 8) *)

    (* Kích hoạt cho phép xuất Analog D/A kênh 1..8 trên AJ65VBTCU-68DAVN (Trạm 2) *)
    M1240 := TRUE;  (* RY28: DA Conversion Enable (M1200 + 40) *)

ELSE
    (* Trường hợp truyền thông CC-Link bị lỗi *)
    M1208 := FALSE;
    M1240 := FALSE;
END_IF;

(* --- 2. ĐỌC VÀ QUY ĐỔI DỮ LIỆU ANALOG INPUT (AJ65SBT-64AD) --- *)
(* RWr0..RWr3 tự động map về D500..D503 *)
(* D500: Raw CH1 (0..4000) -> Quy đổi sang % D600 (0..1000 = 0.0%..100.0%) *)
IF M1016 THEN (* RX8: AD Conversion Completion Flag (M1008 + 8) *)
    
    (* Kênh CH1 Analog Input *)
    D600 := INT_TO_WORD(WORD_TO_INT(D500) * 1000 / 4000);
    
    (* Kênh CH2 Analog Input *)
    D601 := INT_TO_WORD(WORD_TO_INT(D501) * 1000 / 4000);
    
    (* Kênh CH3 Analog Input *)
    D602 := INT_TO_WORD(WORD_TO_INT(D502) * 1000 / 4000);
    
    (* Kênh CH4 Analog Input *)
    D603 := INT_TO_WORD(WORD_TO_INT(D503) * 1000 / 4000);
    
END_IF;

(* --- 3. XUẤT DỮ LIỆU ANALOG OUTPUT (AJ65VBTCU-68DAVN) --- *)
(* D610..D617 chứa giá trị cài đặt (0..1000 = 0.0%..100.0%) *)
(* Quy đổi sang dải DAC (-4000..+4000 hoặc 0..4000) để ghi vào RWw4..RWwB (D524..D531) *)

(* CH1 Analog Output Command *)
D524 := INT_TO_WORD(WORD_TO_INT(D610) * 4000 / 1000);

(* CH2 Analog Output Command *)
D525 := INT_TO_WORD(WORD_TO_INT(D611) * 4000 / 1000);

(* CH3 Analog Output Command *)
D526 := INT_TO_WORD(WORD_TO_INT(D612) * 4000 / 1000);

(* CH4 Analog Output Command *)
D527 := INT_TO_WORD(WORD_TO_INT(D613) * 4000 / 1000);

(* CH5 Analog Output Command *)
D528 := INT_TO_WORD(WORD_TO_INT(D614) * 4000 / 1000);

(* CH6 Analog Output Command *)
D529 := INT_TO_WORD(WORD_TO_INT(D615) * 4000 / 1000);

(* CH7 Analog Output Command *)
D530 := INT_TO_WORD(WORD_TO_INT(D616) * 4000 / 1000);

(* CH8 Analog Output Command *)
D531 := INT_TO_WORD(WORD_TO_INT(D617) * 4000 / 1000);

(* --- 4. ĐIỀU KHIỂN REMOTE DIGITAL I/O (AJ65SBTB1-16DT - TRẠM 4) --- *)
(* Đọc 8 bit Remote Input: M1104..M1111 (X0..X7) *)
(* Ghi 8 bit Remote Output: M1304..M1311 (Y8..YF) *)

(* Bật ngõ ra Y8 (M1304 - Cọc ra 1) khi nút nhấn X0 (M1104) được ấn và truyền thông OK *)
M1304 := M1104 AND (NOT SB0020) AND (NOT SB0049);

(* Bật ngõ ra Y9 (M1305 - Cọc ra 2) theo trạng thái nút nhấn X1 (M1105) *)
M1305 := M1105 AND (NOT SB0020) AND (NOT SB0049);

(* Báo lỗi (M1303) nếu CC-Link có lỗi hoặc module báo lỗi *)
M1303 := SB0020 OR SB0049 OR M1032 OR M1066;

(* --- 5. RESET LỖI KHI BẤM NÚT RESET (M1111 - X7) --- *)
IF M1111 THEN
    M1226 := TRUE; (* RY1A: Reset lỗi AJ65SBT-64AD *)
    M1258 := TRUE; (* RY3A: Reset lỗi AJ65VBTCU-68DAVN *)
ELSE
    M1226 := FALSE;
    M1258 := FALSE;
END_IF;
