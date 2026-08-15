(* ============================================================================ *)
(* FUNCTION BLOCK: FB_TENSION_PID (THUẬT TOÁN PID LỰC CĂNG CHUYÊN DỤNG MÁY GHÉP)  *)
(* TÍCH HỢP: ANTI-WINDUP, DEADBAND (VÙNG CHẾT), HẠN CHẾ VỌNG TỐC VÀ ÉP BIÊN    *)
(* ============================================================================ *)

FUNCTION_BLOCK FB_TENSION_PID
VAR_INPUT
    Enable          : BOOL := TRUE;  (* Bật PID *)
    Reset           : BOOL := FALSE; (* Reset tích lũy I *)

    Setpoint        : DINT := 1000;  (* Giá trị lực căng cài đặt (N hoặc Kg) *)
    Feedback        : DINT := 1000;  (* Tải trọng phản hồi từ Loadcell Net *)

    Kp              : DINT := 100;   (* Hệ số P (x100: 100 = 1.00) *)
    Ki              : DINT := 10;    (* Hệ số I (x100: 10 = 0.10) *)
    Kd              : DINT := 5;     (* Hệ số D (x100: 5 = 0.05) *)

    Deadband        : DINT := 10;    (* Vùng chết không chỉnh (N/Kg) *)
    Out_Min         : DINT := -1000; (* Giới hạn đầu ra tối thiểu *)
    Out_Max         : DINT := 1000;  (* Giới hạn đầu ra tối đa *)
END_VAR

VAR_OUTPUT
    PID_Output      : DINT := 0;     (* Giá trị bù tốc độ/torque cho DAC *)
    Error           : DINT := 0;     (* Độ lệch e(k) *)
END_VAR

VAR
    Error_Prev      : DINT := 0;
    I_Term          : DINT := 0;
    P_Term          : DINT := 0;
    D_Term          : DINT := 0;
END_VAR

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

END_FUNCTION_BLOCK
