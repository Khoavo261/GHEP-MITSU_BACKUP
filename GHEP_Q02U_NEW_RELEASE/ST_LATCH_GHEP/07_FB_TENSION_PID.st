(* ============================================================================ *)
(* FUNCTION BLOCK: FB_TENSION_PID                                               *)
(* DỰ ÁN: MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - PLC MITSUBISHI Q02U                *)
(* THƯ MỤC: ST_LATCH_GHEP                                                      *)
(* FILE: 07_FB_TENSION_PID.st                                                  *)
(* TÍNH NĂNG:                                                                  *)
(*   1. Thuật toán điều khiển PID lực căng số thực (REAL) độ chính xác cao     *)
(*   2. Tích phân chống bão hòa (Anti-Windup Clamping)                         *)
(*   3. Vùng chết Deadband chống dao động rung kim Loadcell                    *)
(*   4. Tích hợp tính năng Auto-Tuning tự động dò tìm Kp, Ki, Kd theo chu kỳ   *)
(* ============================================================================ *)

IF NOT Enable THEN
    PID_Output := 0.0;
    I_Term     := 0.0;
    Error_Prev := 0.0;
    AT_Busy    := FALSE;
    AT_State   := 0;
    RETURN;
END_IF;

IF Reset THEN
    I_Term     := 0.0;
    Error_Prev := 0.0;
    PID_Output := 0.0;
    AT_Busy    := FALSE;
    AT_State   := 0;
    AT_Done    := FALSE;
    RETURN;
END_IF;

(* ============================================================================ *)
(* 1. CHẾ ĐỘ AUTO-TUNING (DÒ THÔNG SỐ TỰ ĐỘNG BẰNG RELAY LIMIT-CYCLE)           *)
(* ============================================================================ *)
IF AT_Enable THEN
    AT_Busy := TRUE;
    AT_Done := FALSE;
    
    IF AT_Step > 0.0 THEN
        Test_Step := AT_Step;
    ELSE
        Test_Step := 800.0; (* Mặc định 800 đơn vị *)
    END_IF;

    CASE AT_State OF
        0: (* KHỞI TẠO BƯỚC TEST *)
            AT_Base_Out     := PID_Output;
            AT_PV_Max       := Feedback;
            AT_PV_Min       := Feedback;
            AT_Cycle_Count  := 0;
            AT_Timer_10ms   := 0;
            AT_Relay_State  := TRUE;
            AT_State        := 1;

        1: (* THỰC THI DAO ĐỘNG BẬT/TẮT RELAY QUA SETPOINT *)
            AT_Timer_10ms := AT_Timer_10ms + 1;

            IF Feedback > AT_PV_Max THEN AT_PV_Max := Feedback; END_IF;
            IF Feedback < AT_PV_Min THEN AT_PV_Min := Feedback; END_IF;

            IF AT_Relay_State THEN
                PID_Output := AT_Base_Out + Test_Step;
                IF Feedback >= Setpoint THEN
                    AT_Relay_State := FALSE;
                END_IF;
            ELSE
                PID_Output := AT_Base_Out - Test_Step;
                IF Feedback < Setpoint THEN
                    AT_Relay_State := TRUE;
                    AT_Cycle_Count := AT_Cycle_Count + 1;
                END_IF;
            END_IF;

            IF AT_Cycle_Count >= 3 THEN
                AT_State := 2;
            END_IF;

        2: (* TÍNH TOÁN BỘ THÔNG SỐ TUNED_KP, TUNED_KI, TUNED_KD *)
            IF AT_Timer_10ms > 0 THEN
                AT_Period_Tu := (DINT_TO_REAL(AT_Timer_10ms) * 0.01) / 3.0;
            ELSE
                AT_Period_Tu := 1.0;
            END_IF;

            IF (AT_PV_Max - AT_PV_Min) > 0.1 THEN
                AT_Ku := (4.0 * Test_Step) / (3.141593 * ((AT_PV_Max - AT_PV_Min) / 2.0));
            ELSE
                AT_Ku := 1.0;
            END_IF;

            (* Công thức Ziegler-Nichols hiệu chỉnh chống vọt lố *)
            Tuned_Kp := AT_Ku * 0.35;
            
            IF AT_Period_Tu > 0.05 THEN
                Tuned_Ki := Tuned_Kp * (0.01 / (AT_Period_Tu * 0.85));
                Tuned_Kd := Tuned_Kp * ((AT_Period_Tu * 0.12) / 0.01);
            ELSE
                Tuned_Ki := Tuned_Kp * 0.05;
                Tuned_Kd := Tuned_Kp * 0.02;
            END_IF;

            (* Khống chế biên an toàn *)
            IF Tuned_Kp < 0.1 THEN Tuned_Kp := 0.1; ELSIF Tuned_Kp > 20.0 THEN Tuned_Kp := 20.0; END_IF;
            IF Tuned_Ki < 0.001 THEN Tuned_Ki := 0.001; ELSIF Tuned_Ki > 5.0 THEN Tuned_Ki := 5.0; END_IF;
            IF Tuned_Kd < 0.0 THEN Tuned_Kd := 0.0; ELSIF Tuned_Kd > 5.0 THEN Tuned_Kd := 5.0; END_IF;

            AT_Busy  := FALSE;
            AT_Done  := TRUE;
            AT_State := 0;
    END_CASE;

    IF PID_Output > Out_Max THEN PID_Output := Out_Max; END_IF;
    IF PID_Output < Out_Min THEN PID_Output := Out_Min; END_IF;
    RETURN;
END_IF;

IF AT_Busy THEN
    AT_Busy  := FALSE;
    AT_State := 0;
END_IF;

(* ============================================================================ *)
(* 2. CHẾ ĐỘ ĐIỀU KHIỂN PID TIÊU CHUẨN (NORMAL RUNNING)                        *)
(* ============================================================================ *)

(* 1. Tính độ lệch e(k) *)
Error := Setpoint - Feedback;

(* 2. Lọc vùng chết Deadband *)
IF ABS(Error) <= Deadband THEN
    Error := 0.0;
END_IF;

(* 3. Thành phần tỷ lệ Proportional (P) *)
P_Term := Error * Kp;

(* 4. Thành phần tích phân Integral (I) với Anti-Windup *)
I_Term := I_Term + (Error * Ki);

IF Out_Max > Out_Min THEN
    IF I_Term > Out_Max THEN
        I_Term := Out_Max;
    ELSIF I_Term < Out_Min THEN
        I_Term := Out_Min;
    END_IF;
END_IF;

(* 5. Thành phần vi phân Derivative (D) *)
D_Term := (Error - Error_Prev) * Kd;
Error_Prev := Error;

(* 6. Tổng hợp ngõ ra và giới hạn biên Out_Min..Out_Max *)
PID_Output := P_Term + I_Term + D_Term;

IF Out_Max > Out_Min THEN
    IF PID_Output > Out_Max THEN
        PID_Output := Out_Max;
    ELSIF PID_Output < Out_Min THEN
        PID_Output := Out_Min;
    END_IF;
END_IF;
