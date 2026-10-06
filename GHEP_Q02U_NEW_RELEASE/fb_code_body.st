(* ============================================================================ *)
(* FUNCTION BLOCK BODY: FB_CCLINK_CONTROL (CHUẨN CHÍNH THỨC MANUAL MITSUBISHI)  *)
(* TRẠM 1: ADC INPUT  (AJ65VBTCU-68ADV  - D500..D507 | RWw0: D520 = 16#00FF)    *)
(* TRẠM 2: DAC OUTPUT (AJ65VBTCU-68DAVN - D524..D535 | XUẤT 5.0V D524)          *)
(* TRẠM 3: DIGITAL IO (AJ65SBTB1-16DT   - RX: M1072..M1079 | RY: M1272..M1279) *)
(* ============================================================================ *)

IF Enable THEN

    (* 1. TRẠNG THÁI MẠNG *)
    CCLink_OK := (NOT SB0020) AND (NOT SB0049);
    HasError  := SB0020 OR SB0049;

    (* 2. CẤU HÌNH BẮT BUỘC THEO MANUAL MITSUBISHI CHO AJ65VBTCU-68ADV *)
    (* RWw0 (D520): Cho phép chuyển đổi A/D cả 8 kênh (16#00FF = 255) *)
    D520 := 16#00FF; 
    (* RWw1 (D521): Dải ngõ vào 0..10V cho cả 8 kênh *)
    D521 := 16#0000; 

    (* Tự động gửi xung bắt tay RY19 (M1225) nạp thông số vào module (Gán 1 dòng duy nhất) *)
    M1225 := M1032;

    (* Bật cờ chuyển đổi RY0..RY7 *)
    M1200 := CCLink_OK; M1201 := CCLink_OK; M1202 := CCLink_OK; M1203 := CCLink_OK;
    M1204 := CCLink_OK; M1205 := CCLink_OK; M1206 := CCLink_OK; M1207 := CCLink_OK;

    (* 3. BẬT CỜ XUẤT ÁP CHO TRẠM 2 DAC *)
    M1232 := CCLink_OK; M1233 := CCLink_OK; M1234 := CCLink_OK; M1235 := CCLink_OK;

    (* 4. ĐỌC 8 KÊNH ANALOG INPUT TỪ TRẠM 1 ADC (D500..D507) *)
    ADC_CH1_Raw := D500;
    ADC_CH2_Raw := D501;
    ADC_CH3_Raw := D502;
    ADC_CH4_Raw := D503;
    ADC_CH5_Raw := D504;
    ADC_CH6_Raw := D505;
    ADC_CH7_Raw := D506;
    ADC_CH8_Raw := D507;

    (* Chuyển đổi sang số thực REAL *)
    ADC_CH1_Val := INT_TO_REAL(WORD_TO_INT(D500));
    ADC_CH2_Val := INT_TO_REAL(WORD_TO_INT(D501));
    ADC_CH3_Val := INT_TO_REAL(WORD_TO_INT(D502));
    ADC_CH4_Val := INT_TO_REAL(WORD_TO_INT(D503));
    ADC_CH5_Val := INT_TO_REAL(WORD_TO_INT(D504));
    ADC_CH6_Val := INT_TO_REAL(WORD_TO_INT(D505));
    ADC_CH7_Val := INT_TO_REAL(WORD_TO_INT(D506));
    ADC_CH8_Val := INT_TO_REAL(WORD_TO_INT(D507));

    (* 5. XUẤT ÁP 5.0V RA DAC TRẠM 2 (D524 / D528) *)
    D524 := INT_TO_WORD(2000);  (* Xuất 5.0V Kênh 1 *)
    D528 := INT_TO_WORD(2000);

    (* CH2..CH4 *)
    IF Set_Torque_T < 0.0 THEN D525 := INT_TO_WORD(0); ELSIF Set_Torque_T > 4000.0 THEN D525 := INT_TO_WORD(4000); ELSE D525 := INT_TO_WORD(REAL_TO_INT(Set_Torque_T)); END_IF;
    IF Set_Speed_X1 < 0.0 THEN D526 := INT_TO_WORD(0); ELSIF Set_Speed_X1 > 4000.0 THEN D526 := INT_TO_WORD(4000); ELSE D526 := INT_TO_WORD(REAL_TO_INT(Set_Speed_X1)); END_IF;
    IF Set_Speed_X2 < 0.0 THEN D527 := INT_TO_WORD(0); ELSIF Set_Speed_X2 > 4000.0 THEN D527 := INT_TO_WORD(4000); ELSE D527 := INT_TO_WORD(REAL_TO_INT(Set_Speed_X2)); END_IF;

    (* 6. XỬ LÝ DIGITAL REMOTE I/O TRẠM 3 (AJ65SBTB1-16DT: RX: M1072..M1076 | RY: M1272..M1273) *)
    DI_X0_State := M1072;
    DI_X1_State := M1073;
    M1272 := DO_Y8_Cmd;
    M1273 := DO_Y9_Cmd;

    (* 7. RESET LỖI *)
    M1226 := ResetErr OR M1111;
    M1258 := ResetErr OR M1111;

END_IF;
