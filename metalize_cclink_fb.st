(* ============================================================================ *)
(* FUNCTION BLOCK: FFB_METALIZE_CONTROL                                         *)
(* DỰ ÁN: QUẢN LÝ DÂY CHUYỀN MÁY GHÉP MÀNG METALIZE (Q02U + CC-LINK)            *)
(* PHẦN CỨNG:                                                                   *)
(*   - Trạm 1 (AJ65SBT-64AD): 4 CH Loadcell (Zero & Calib Gain)                 *)
(*   - Trạm 2&3 (AJ65VBTCU-68DAVN): 8 CH DAC Output (Ramping Tăng/Giảm Tốc)     *)
(*   - Trạm 4 (AJ65SBT-16DT): 5 Trục Servo Ready & Servo ON                     *)
(* ============================================================================ *)

VAR_INPUT
    Enable          : BOOL := TRUE;  (* Cho phep FB hoat dong *)
    ResetErr        : BOOL := FALSE; (* Nut Reset loi he thong *)
    Auto_Mode       : BOOL := TRUE;  (* TRUE: Tu dong, FALSE: Manual Test *)

    (* LỆNH SET ZERO VÀ HỆ SỐ CALIB LOADCELL (4 CH TRẠM 1) *)
    Zero_Set_T      : BOOL := FALSE;
    Zero_Set_X1     : BOOL := FALSE;
    Zero_Set_M      : BOOL := FALSE;
    Zero_Set_U      : BOOL := FALSE;

    Calib_Gain_T    : DINT := 1000;
    Calib_Gain_X1   : DINT := 1000;
    Calib_Gain_M    : DINT := 1000;
    Calib_Gain_U    : DINT := 1000;

    (* CÀI ĐẶT TỐC ĐỘ VÀ TORQUE TỪ CHƯƠNG TRÌNH CHÍNH (0..4000) *)
    Set_Speed_T     : WORD := 0; (* CH1: Speed Thu T *)
    Set_Torque_T    : WORD := 0; (* CH2: Torque Thu T *)
    Set_Speed_X1    : WORD := 0; (* CH3: Speed Xa Giay X1 *)
    Set_Speed_X2    : WORD := 0; (* CH4: Speed Master X2 *)
    Set_Speed_Ms    : WORD := 0; (* CH5: Speed Ghep Metalize Ms *)
    Set_Torque_M    : WORD := 0; (* CH6: Torque Thang Tu M *)
    Set_Speed_S     : WORD := 0; (* CH7: Speed Trang Dau S *)
    Set_Speed_U     : WORD := 0; (* CH8: Speed Xa Metalize U *)

    (* BƯỚC TĂNG GIẢM TỐC RAMPING *)
    Ramp_Step_ms    : DINT := 20;

    (* LỆNH SERVO ON CHẾ ĐỘ TỰ ĐỘNG *)
    Auto_Son_T      : BOOL := FALSE;
    Auto_Son_X1     : BOOL := FALSE;
    Auto_Son_X2     : BOOL := FALSE;
    Auto_Son_M      : BOOL := FALSE;
    Auto_Son_S      : BOOL := FALSE;

    (* LỆNH TEST TỪNG TRỤC CHẾ ĐỘ MANUAL *)
    Test_Son_T      : BOOL := FALSE;
    Test_Son_X1     : BOOL := FALSE;
    Test_Son_X2     : BOOL := FALSE;
    Test_Son_M      : BOOL := FALSE;
    Test_Son_S      : BOOL := FALSE;

    Test_Speed_T    : WORD := 0;
    Test_Speed_X1   : WORD := 0;
    Test_Speed_X2   : WORD := 0;
    Test_Speed_Ms   : WORD := 0;
    Test_Torque_M   : WORD := 0;
    Test_Speed_S    : WORD := 0;
    Test_Speed_U    : WORD := 0;
END_VAR

VAR_OUTPUT
    CCLink_OK       : BOOL := FALSE; (* Bao truyen thong CC-Link OK *)
    HasError        : BOOL := FALSE; (* Bao loi he thong *)

    (* GIÁ TRỊ TRỌNG LƯỢNG / LỰC CĂNG NET SAU CALIB & ZERO (0..4000 N/Kg) *)
    Weight_Net_T    : DINT := 0; (* CH1 *)
    Weight_Net_X1   : DINT := 0; (* CH2 *)
    Weight_Net_M    : DINT := 0; (* CH3 *)
    Weight_Net_U    : DINT := 0; (* CH4 *)

    (* TRẠNG THÁI SERVO READY VÀ SERVO ON *)
    S_Ready_T       : BOOL := FALSE;
    S_Ready_X1      : BOOL := FALSE;
    S_Ready_X2      : BOOL := FALSE;
    S_Ready_M       : BOOL := FALSE;
    S_Ready_S       : BOOL := FALSE;

    S_ON_T_Out      : BOOL := FALSE;
    S_ON_X1_Out     : BOOL := FALSE;
    S_ON_X2_Out     : BOOL := FALSE;
    S_ON_M_Out      : BOOL := FALSE;
    S_ON_S_Out      : BOOL := FALSE;
END_VAR

VAR
    Zero_Offset_T   : DINT := 0;
    Zero_Offset_X1  : DINT := 0;
    Zero_Offset_M   : DINT := 0;
    Zero_Offset_U   : DINT := 0;

    Ramp_Speed_T    : DINT := 0;
    Ramp_Torque_T   : DINT := 0;
    Ramp_Speed_X1   : DINT := 0;
    Ramp_Speed_X2   : DINT := 0;
    Ramp_Speed_Ms   : DINT := 0;
    Ramp_Torque_M   : DINT := 0;
    Ramp_Speed_S    : DINT := 0;
    Ramp_Speed_U    : DINT := 0;

    Target_D524     : DINT := 0;
    Target_D525     : DINT := 0;
    Target_D526     : DINT := 0;
    Target_D527     : DINT := 0;
    Target_D528     : DINT := 0;
    Target_D529     : DINT := 0;
    Target_D530     : DINT := 0;
    Target_D531     : DINT := 0;
END_VAR

IF Enable THEN

    (* 1. KIỂM TRA MẠNG CC-LINK (SB0020=0 và SB0049=0 là mạng bình thường) *)
    CCLink_OK := (NOT SB0020) AND (NOT SB0049);
    HasError  := SB0020 OR SB0049 OR M1032 OR M1066;

    M1208 := CCLink_OK; (* RY8: Kick ADC Tram 1 *)
    M1240 := CCLink_OK; (* RY28: Kick DAC Tram 2 *)

    (* 2. ĐỌC VÀ HIỆU CHUẨN (CALIB & ZERO) 4 KÊNH LOADCELL (TRẠM 1 - AJ65SBT-64AD) *)
    IF M1016 THEN (* RX8 *)
        IF Zero_Set_T  THEN Zero_Offset_T  := WORD_TO_INT(D500); END_IF;
        IF Zero_Set_X1 THEN Zero_Offset_X1 := WORD_TO_INT(D501); END_IF;
        IF Zero_Set_M  THEN Zero_Offset_M  := WORD_TO_INT(D502); END_IF;
        IF Zero_Set_U  THEN Zero_Offset_U  := WORD_TO_INT(D503); END_IF;

        Weight_Net_T  := ((WORD_TO_INT(D500) - Zero_Offset_T)  * Calib_Gain_T)  / 1000;
        Weight_Net_X1 := ((WORD_TO_INT(D501) - Zero_Offset_X1) * Calib_Gain_X1) / 1000;
        Weight_Net_M  := ((WORD_TO_INT(D502) - Zero_Offset_M)  * Calib_Gain_M)  / 1000;
        Weight_Net_U  := ((WORD_TO_INT(D503) - Zero_Offset_U)  * Calib_Gain_U)  / 1000;

        IF Weight_Net_T  < 0 THEN Weight_Net_T  := 0; END_IF;
        IF Weight_Net_X1 < 0 THEN Weight_Net_X1 := 0; END_IF;
        IF Weight_Net_M  < 0 THEN Weight_Net_M  := 0; END_IF;
        IF Weight_Net_U  < 0 THEN Weight_Net_U  := 0; END_IF;
    END_IF;

    (* 3. LỰA CHỌN MỤC TIÊU TỐC ĐỘ VÀ RAMPING TĂNG GIẢM TỐC *)
    IF Auto_Mode THEN
        Target_D524 := WORD_TO_INT(Set_Speed_T)  / 2;
        Target_D525 := WORD_TO_INT(Set_Torque_T) / 2;
        Target_D526 := WORD_TO_INT(Set_Speed_X1) / 2;
        Target_D527 := WORD_TO_INT(Set_Speed_X2) / 2;
        Target_D528 := WORD_TO_INT(Set_Speed_Ms) / 2;
        Target_D529 := WORD_TO_INT(Set_Torque_M) / 2;
        Target_D530 := WORD_TO_INT(Set_Speed_S)  / 2;
        Target_D531 := WORD_TO_INT(Set_Speed_U)  / 2;

        S_ON_T_Out  := Auto_Son_T  AND CCLink_OK;
        S_ON_X1_Out := Auto_Son_X1 AND CCLink_OK;
        S_ON_X2_Out := Auto_Son_X2 AND CCLink_OK;
        S_ON_M_Out  := Auto_Son_M  AND CCLink_OK;
        S_ON_S_Out  := Auto_Son_S  AND CCLink_OK;
    ELSE
        Target_D524 := WORD_TO_INT(Test_Speed_T)  / 2;
        Target_D525 := 0;
        Target_D526 := WORD_TO_INT(Test_Speed_X1) / 2;
        Target_D527 := WORD_TO_INT(Test_Speed_X2) / 2;
        Target_D528 := WORD_TO_INT(Test_Speed_Ms) / 2;
        Target_D529 := WORD_TO_INT(Test_Torque_M) / 2;
        Target_D530 := WORD_TO_INT(Test_Speed_S)  / 2;
        Target_D531 := WORD_TO_INT(Test_Speed_U)  / 2;

        S_ON_T_Out  := Test_Son_T  AND CCLink_OK;
        S_ON_X1_Out := Test_Son_X1 AND CCLink_OK;
        S_ON_X2_Out := Test_Son_X2 AND CCLink_OK;
        S_ON_M_Out  := Test_Son_M  AND CCLink_OK;
        S_ON_S_Out  := Test_Son_S  AND CCLink_OK;
    END_IF;

    (* RAMPING TĂNG GIẢM TỐC CHỐNG ĐỨT MÀNG (ACCEL/DECEL RAMP) *)
    IF Ramp_Speed_T < Target_D524 THEN Ramp_Speed_T := Ramp_Speed_T + Ramp_Step_ms; IF Ramp_Speed_T > Target_D524 THEN Ramp_Speed_T := Target_D524; END_IF;
    ELSIF Ramp_Speed_T > Target_D524 THEN Ramp_Speed_T := Ramp_Speed_T - Ramp_Step_ms; IF Ramp_Speed_T < Target_D524 THEN Ramp_Speed_T := Target_D524; END_IF; END_IF;

    IF Ramp_Speed_X1 < Target_D526 THEN Ramp_Speed_X1 := Ramp_Speed_X1 + Ramp_Step_ms; IF Ramp_Speed_X1 > Target_D526 THEN Ramp_Speed_X1 := Target_D526; END_IF;
    ELSIF Ramp_Speed_X1 > Target_D526 THEN Ramp_Speed_X1 := Ramp_Speed_X1 - Ramp_Step_ms; IF Ramp_Speed_X1 < Target_D526 THEN Ramp_Speed_X1 := Target_D526; END_IF; END_IF;

    IF Ramp_Speed_X2 < Target_D527 THEN Ramp_Speed_X2 := Ramp_Speed_X2 + Ramp_Step_ms; IF Ramp_Speed_X2 > Target_D527 THEN Ramp_Speed_X2 := Target_D527; END_IF;
    ELSIF Ramp_Speed_X2 > Target_D527 THEN Ramp_Speed_X2 := Ramp_Speed_X2 - Ramp_Step_ms; IF Ramp_Speed_X2 < Target_D527 THEN Ramp_Speed_X2 := Target_D527; END_IF; END_IF;

    IF Ramp_Speed_Ms < Target_D528 THEN Ramp_Speed_Ms := Ramp_Speed_Ms + Ramp_Step_ms; IF Ramp_Speed_Ms > Target_D528 THEN Ramp_Speed_Ms := Target_D528; END_IF;
    ELSIF Ramp_Speed_Ms > Target_D528 THEN Ramp_Speed_Ms := Ramp_Speed_Ms - Ramp_Step_ms; IF Ramp_Speed_Ms < Target_D528 THEN Ramp_Speed_Ms := Target_D528; END_IF; END_IF;

    IF Ramp_Speed_S < Target_D530 THEN Ramp_Speed_S := Ramp_Speed_S + Ramp_Step_ms; IF Ramp_Speed_S > Target_D530 THEN Ramp_Speed_S := Target_D530; END_IF;
    ELSIF Ramp_Speed_S > Target_D530 THEN Ramp_Speed_S := Ramp_Speed_S - Ramp_Step_ms; IF Ramp_Speed_S < Target_D530 THEN Ramp_Speed_S := Target_D530; END_IF; END_IF;

    IF Ramp_Speed_U < Target_D531 THEN Ramp_Speed_U := Ramp_Speed_U + Ramp_Step_ms; IF Ramp_Speed_U > Target_D531 THEN Ramp_Speed_U := Target_D531; END_IF;
    ELSIF Ramp_Speed_U > Target_D531 THEN Ramp_Speed_U := Ramp_Speed_U - Ramp_Step_ms; IF Ramp_Speed_U < Target_D531 THEN Ramp_Speed_U := Target_D531; END_IF; END_IF;

    Ramp_Torque_T := Target_D525;
    Ramp_Torque_M := Target_D529;

    D524 := INT_TO_WORD(Ramp_Speed_T);
    D525 := INT_TO_WORD(Ramp_Torque_T);
    D526 := INT_TO_WORD(Ramp_Speed_X1);
    D527 := INT_TO_WORD(Ramp_Speed_X2);
    D528 := INT_TO_WORD(Ramp_Speed_Ms);
    D529 := INT_TO_WORD(Ramp_Torque_M);
    D530 := INT_TO_WORD(Ramp_Speed_S);
    D531 := INT_TO_WORD(Ramp_Speed_U);

    (* 4. ĐỌC SERVO READY VÀ XUẤT SERVO ON (AJ65SBT-16DT - TRẠM 4) *)
    S_Ready_T  := M1104;
    S_Ready_X1 := M1105;
    S_Ready_X2 := M1106;
    S_Ready_M  := M1107;
    S_Ready_S  := M1108;

    M1296 := S_ON_T_Out;
    M1297 := S_ON_X1_Out;
    M1298 := S_ON_X2_Out;
    M1299 := S_ON_M_Out;
    M1300 := S_ON_S_Out;

    M1303 := HasError;

    (* 5. RESET LỖI CC-LINK *)
    M1226 := ResetErr OR M1111;
    M1258 := ResetErr OR M1111;

END_IF;
