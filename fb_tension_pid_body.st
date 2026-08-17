IF NOT Enable THEN
    PID_Output := 0;
    I_Term     := 0;
    Error_Prev := 0;
    RETURN;
END_IF;

IF Reset THEN
    I_Term     := 0;
    Error_Prev := 0;
    PID_Output := 0;
    RETURN;
END_IF;

(* 1. TÍNH ĐỘ LỆCH ERROR E(K) *)
Error := Setpoint - Feedback;

(* 2. BỘ LỌC VÙNG CHẾT DEADBAND *)
IF ABS(Error) <= Deadband THEN
    Error := 0;
END_IF;

(* 3. TÍNH THÀNH PHẦN PROPORTIONAL (P) *)
P_Term := (Error * Kp) / 100;

(* 4. TÍNH THÀNH PHẦN INTEGRAL (I) VỚI CHỐNG BÃO HÒA ANTI-WINDUP *)
I_Term := I_Term + ((Error * Ki) / 100);

IF I_Term > Out_Max THEN
    I_Term := Out_Max;
ELSIF I_Term < Out_Min THEN
    I_Term := Out_Min;
END_IF;

(* 5. TÍNH THÀNH PHẦN DERIVATIVE (D) *)
D_Term := ((Error - Error_Prev) * Kd) / 100;
Error_Prev := Error;

(* 6. TỔNG HỢP NỔI PID VÀ ÉP BIÊN OUT_MIN..OUT_MAX *)
PID_Output := P_Term + I_Term + D_Term;

IF PID_Output > Out_Max THEN
    PID_Output := Out_Max;
ELSIF PID_Output < Out_Min THEN
    PID_Output := Out_Min;
END_IF;
