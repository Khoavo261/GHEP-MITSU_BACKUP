(* ============================================================================ *)
(* FUNCTION BLOCK BODY: FB_CCLINK_CONTROL (QUẢN LÝ MẠNG CC-LINK - CHUẨN SỐ THỰC REAL) *)
(* ============================================================================ *)

IF Enable THEN

    (* 1. Kiểm tra trạng thái mạng CC-Link (SB0020=0 và SB0049=0 là mạng bình thường) *)
    CCLink_OK := (NOT SB0020) AND (NOT SB0049);
    HasError  := SB0020 OR SB0049 OR M1032 OR M1066;

    M1208 := CCLink_OK;  (* RY8: AD Conversion Enable (St 1 - AJ65SBT-64AD) *)
    M1240 := CCLink_OK;  (* RY28: DA Conversion Enable (St 2 - AJ65VBTCU-68DAVN) *)

    (* 2. Đọc 4 kênh Analog Input (AJ65SBT-64AD - Trạm 1) *)
    IF M1016 THEN (* RX8: AD Conversion Completed *)
        ADC_CH1_Raw := D500;
        ADC_CH2_Raw := D501;
        ADC_CH3_Raw := D502;
        ADC_CH4_Raw := D503;

        (* Chuyển đổi sang số thực REAL *)
        ADC_CH1_Val := INT_TO_REAL(WORD_TO_INT(D500));
        ADC_CH2_Val := INT_TO_REAL(WORD_TO_INT(D501));
        ADC_CH3_Val := INT_TO_REAL(WORD_TO_INT(D502));
        ADC_CH4_Val := INT_TO_REAL(WORD_TO_INT(D503));
    END_IF;

    (* 3. Ghi 8 kênh Analog Output DAC 0..4000 (AJ65VBTCU-68DAVN - Trạm 2 & 3) *)
    (* Tự động kẹp biên an toàn 0.0..4000.0 và ép kiểu từ REAL sang WORD cho phần cứng *)
    
    (* CH1: Speed Thu T (D524) *)
    IF Set_Speed_T < 0.0 THEN D524 := INT_TO_WORD(0); ELSIF Set_Speed_T > 4000.0 THEN D524 := INT_TO_WORD(4000); ELSE D524 := INT_TO_WORD(REAL_TO_INT(Set_Speed_T)); END_IF;

    (* CH2: Torque Thu T (D525) *)
    IF Set_Torque_T < 0.0 THEN D525 := INT_TO_WORD(0); ELSIF Set_Torque_T > 4000.0 THEN D525 := INT_TO_WORD(4000); ELSE D525 := INT_TO_WORD(REAL_TO_INT(Set_Torque_T)); END_IF;

    (* CH3: Speed Xả X1 (D526) *)
    IF Set_Speed_X1 < 0.0 THEN D526 := INT_TO_WORD(0); ELSIF Set_Speed_X1 > 4000.0 THEN D526 := INT_TO_WORD(4000); ELSE D526 := INT_TO_WORD(REAL_TO_INT(Set_Speed_X1)); END_IF;

    (* CH4: Speed Master X2 (D527) *)
    IF Set_Speed_X2 < 0.0 THEN D527 := INT_TO_WORD(0); ELSIF Set_Speed_X2 > 4000.0 THEN D527 := INT_TO_WORD(4000); ELSE D527 := INT_TO_WORD(REAL_TO_INT(Set_Speed_X2)); END_IF;

    (* CH5: Speed Ghép Ms (D528) *)
    IF Set_Speed_Ms < 0.0 THEN D528 := INT_TO_WORD(0); ELSIF Set_Speed_Ms > 4000.0 THEN D528 := INT_TO_WORD(4000); ELSE D528 := INT_TO_WORD(REAL_TO_INT(Set_Speed_Ms)); END_IF;

    (* CH6: Torque Thắng M (D529) *)
    IF Set_Torque_M < 0.0 THEN D529 := INT_TO_WORD(0); ELSIF Set_Torque_M > 4000.0 THEN D529 := INT_TO_WORD(4000); ELSE D529 := INT_TO_WORD(REAL_TO_INT(Set_Torque_M)); END_IF;

    (* CH7: Speed Tráng Dầu S (D530) *)
    IF Set_Speed_S < 0.0 THEN D530 := INT_TO_WORD(0); ELSIF Set_Speed_S > 4000.0 THEN D530 := INT_TO_WORD(4000); ELSE D530 := INT_TO_WORD(REAL_TO_INT(Set_Speed_S)); END_IF;

    (* CH8: Speed Xả U (D531) *)
    IF Set_Speed_U < 0.0 THEN D531 := INT_TO_WORD(0); ELSIF Set_Speed_U > 4000.0 THEN D531 := INT_TO_WORD(4000); ELSE D531 := INT_TO_WORD(REAL_TO_INT(Set_Speed_U)); END_IF;

    (* 4. Xử lý Digital Remote I/O (AJ65SBTB1-16DT: X0..X7 = M1104..M1111 | Y8..YF = M1304..M1311) *)
    DI_X0_State := M1104;  (* RX60 St 4 *)
    DI_X1_State := M1105;  (* RX61 St 4 *)

    (* 5. Reset lỗi *)
    M1226 := ResetErr OR M1111; (* RY1A: Reset lỗi St 1 *)
    M1258 := ResetErr OR M1111; (* RY3A: Reset lỗi St 2 *)

END_IF;
