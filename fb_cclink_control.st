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

        ADC_CH1_Val := D500;
        ADC_CH2_Val := D501;
        ADC_CH3_Val := D502;
        ADC_CH4_Val := D503;
    END_IF;

    (* 3. Ghi 8 kenh Analog Output DAC 0..4000 (AJ65VBTCU-68DAVN - Tram 2 & 3) *)
    D524 := Set_Speed_T;   (* CH1: Speed Thu T (D524) *)
    D525 := Set_Torque_T;  (* CH2: Torque Thu T (D525) *)
    D526 := Set_Speed_X1;  (* CH3: Speed Xa X1 (D526) *)
    D527 := Set_Speed_X2;  (* CH4: Speed Master X2 (D527) *)
    D528 := Set_Speed_Ms;  (* CH5: Speed Ghep Ms (D528) *)
    D529 := Set_Torque_M;  (* CH6: Torque Thang M (D529) *)
    D530 := Set_Speed_S;   (* CH7: Speed Trang Dau S (D530) *)
    D531 := Set_Speed_U;   (* CH8: Speed Xa U (D531) *)

    (* 4. Xu ly Digital Remote I/O (AJ65SBTB1-16DT: X0..X7 = M1104..M1111 | Y8..YF = M1304..M1311) *)
    DI_X0_State := M1104;  (* RX60 St 4 *)
    DI_X1_State := M1105;  (* RX61 St 4 *)

    (* 5. Reset loi *)
    M1226 := ResetErr OR M1111; (* RY1A: Reset loi St 1 *)
    M1258 := ResetErr OR M1111; (* RY3A: Reset loi St 2 *)

END_IF;
