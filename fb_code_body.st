IF Enable THEN

    (* 1. Kiem tra trang thai mang CC-Link & Ghi 1 lan duy nhat (Tranh canh bao C9300) *)
    CCLink_OK := SB0020;
    HasError  := NOT(SB0020) OR M1032 OR M1066;

    M1208 := SB0020;  (* RY8: AD Conversion Enable (St 1) *)
    M1240 := SB0020;  (* RY28: DA Conversion Enable (St 2) *)

    (* 2. Doc 4 kenh Analog Input (AJ65SBT-64AD - Tram 1) *)
    IF M1016 THEN (* RX8: AD Conversion Completed *)
        ADC_CH1_Raw := D500;
        ADC_CH2_Raw := D501;
        ADC_CH3_Raw := D502;
        ADC_CH4_Raw := D503;

        (* Quy doi sang 0..1000 (0.0% .. 100.0%) *)
        ADC_CH1_Val := INT_TO_WORD(WORD_TO_INT(D500) * 1000 / 4000);
        ADC_CH2_Val := INT_TO_WORD(WORD_TO_INT(D501) * 1000 / 4000);
        ADC_CH3_Val := INT_TO_WORD(WORD_TO_INT(D502) * 1000 / 4000);
        ADC_CH4_Val := INT_TO_WORD(WORD_TO_INT(D503) * 1000 / 4000);
    END_IF;

    (* 3. Ghi 8 kenh Analog Output (AJ65VBTCU-68DAVN - Tram 2 & 3) *)
    (* QUY ĐỔI LỆNH 0..4000 XUẤT RA ĐIỆN ÁP THỰC TẾ 0..5V *)
    (* (Vi dải dac 0..10V tuong ung 0..4000, nen de xuat 0..5V ta lay User_Cmd / 2) *)
    D524 := INT_TO_WORD(WORD_TO_INT(DAC_CH1_Set) / 2); (* CH1 Output 0..5V *)
    D525 := INT_TO_WORD(WORD_TO_INT(DAC_CH2_Set) / 2); (* CH2 Output 0..5V *)
    D526 := INT_TO_WORD(WORD_TO_INT(DAC_CH3_Set) / 2); (* CH3 Output 0..5V *)
    D527 := INT_TO_WORD(WORD_TO_INT(DAC_CH4_Set) / 2); (* CH4 Output 0..5V *)
    D528 := INT_TO_WORD(WORD_TO_INT(DAC_CH5_Set) / 2); (* CH5 Output 0..5V *)
    D529 := INT_TO_WORD(WORD_TO_INT(DAC_CH6_Set) / 2); (* CH6 Output 0..5V *)
    D530 := INT_TO_WORD(WORD_TO_INT(DAC_CH7_Set) / 2); (* CH7 Output 0..5V *)
    D531 := INT_TO_WORD(WORD_TO_INT(DAC_CH8_Set) / 2); (* CH8 Output 0..5V *)

    (* 4. Xu ly Digital Remote I/O (AJ65SBT-16DT - Tram 4) *)
    DI_X0_State := M1104;  (* RX60 St 4 *)
    DI_X1_State := M1105;  (* RX61 St 4 *)

    M1296 := DO_Y0_Cmd AND SB0020;  (* RY60 St 4 *)
    M1297 := DO_Y1_Cmd AND SB0020;  (* RY61 St 4 *)
    M1303 := HasError;             (* RY67 St 4 *)

    (* 5. Reset loi *)
    M1226 := ResetErr OR M1111; (* RY1A: Reset loi St 1 *)
    M1258 := ResetErr OR M1111; (* RY3A: Reset loi St 2 *)

END_IF;
