IF Enable THEN

    (* 1. Kiem tra trang thai mang CC-Link (SB0020=0 va SB0049=0 la mang binh thuong) *)
    CCLink_OK := (NOT SB0020) AND (NOT SB0049);
    HasError  := SB0020 OR SB0049 OR M1032 OR M1066;

    M1208 := CCLink_OK;  (* RY8: AD Conversion Enable (St 1) *)
    M1240 := CCLink_OK;  (* RY28: DA Conversion Enable (St 2) *)

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
    (* QUY ĐỔI LỆNH 0..1000 XUẤT RA DẢI DAC 0..4000 *)
    D524 := INT_TO_WORD(WORD_TO_INT(Set_Speed_T)  * 4000 / 1000);
    D525 := INT_TO_WORD(WORD_TO_INT(Set_Torque_T) * 4000 / 1000);
    D526 := INT_TO_WORD(WORD_TO_INT(Set_Speed_X1) * 4000 / 1000);
    D527 := INT_TO_WORD(WORD_TO_INT(Set_Speed_X2) * 4000 / 1000);
    D528 := INT_TO_WORD(WORD_TO_INT(Set_Speed_Ms) * 4000 / 1000);
    D529 := INT_TO_WORD(WORD_TO_INT(Set_Torque_M) * 4000 / 1000);
    D530 := INT_TO_WORD(WORD_TO_INT(Set_Speed_S)  * 4000 / 1000);
    D531 := INT_TO_WORD(WORD_TO_INT(Set_Speed_U)  * 4000 / 1000);

    (* 4. Xu ly Digital Remote I/O (AJ65SBTB1-16DT: X0..X7 = M1104..M1111 | Y8..YF = M1304..M1311) *)
    DI_X0_State := M1104;  (* RX60 St 4 *)
    DI_X1_State := M1105;  (* RX61 St 4 *)

    (* Ngo ra Y8..YF (M1304..M1311) de HMI / User tu set ON/OFF truc tiep *)

    (* 5. Reset loi *)
    M1226 := ResetErr OR M1111; (* RY1A: Reset loi St 1 *)
    M1258 := ResetErr OR M1111; (* RY3A: Reset loi St 2 *)

END_IF;
