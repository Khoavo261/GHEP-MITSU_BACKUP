(* ============================================================================ *)
(* POU_FIXED_10MS: CHƯƠNG TRÌNH NGẮT CHU KỲ CỐ ĐỊNH 10MS (FIXED SCAN 10MS)       *)
(* CẤU HÌNH TRONG GX WORKS2:                                                    *)
(*   - PLC Parameter -> Program Setting -> Program Name: POU_PID (hoặc POU_10MS)*)
(*   - Execution Type: FIXED SCAN                                               *)
(*   - Execution Interval: 10 ms                                                *)
(* TÁC VỤ:                                                                      *)
(*   1. Tính tốc độ quay RPM động cơ chính xác mỗi 10ms (Chuẩn 8000 xung/vòng)   *)
(*   2. Tính vận tốc dây MPM bề mặt cho tất cả các trục lô cơ cấu               *)
(*   3. Cập nhật tốc độ thực tế dây chuyền Current_Line_MPM (D10)               *)
(*   4. Thực thi 7 vòng điều khiển PID Lực căng & Tốc độ chuẩn chu kỳ 10ms      *)
(*   5. Xuất áp điều khiển Tốc độ/Torque ra Trạm 1 CC-Link DAC (W200..W207)     *)
(* ============================================================================ *)

(* ============================================================================ *)
(* 1. TÍNH DELTA XUNG TRONG CHU KỲ CỐ ĐỊNH 10MS (0.01 GIÂY)                      *)
(* ============================================================================ *)
Delta_T   := ABS(Curr_Pulse_T  - Prev_Pulse_T);
Delta_X1  := ABS(Curr_Pulse_X1 - Prev_Pulse_X1);
Delta_X2  := ABS(Curr_Pulse_X2 - Prev_Pulse_X2);
Delta_Ms  := ABS(Curr_Pulse_Ms - Prev_Pulse_Ms);
Delta_S   := ABS(Curr_Pulse_S  - Prev_Pulse_S);

Prev_Pulse_T  := Curr_Pulse_T;
Prev_Pulse_X1 := Curr_Pulse_X1;
Prev_Pulse_X2 := Curr_Pulse_X2;
Prev_Pulse_Ms := Curr_Pulse_Ms;
Prev_Pulse_S  := Curr_Pulse_S;

Total_PPR := 8000; (* Cố định 8000 xung/vòng (Mode Nhân 4 vi sai) *)

(* ============================================================================ *)
(* 2. TÍNH TOÁN TỐC ĐỘ RPM THÔ CHO CẢ 5 TRỤC TỪ ENCODER QUANG CHÍNH XÁC         *)
(* Chu kỳ 10ms: Delta * (60.0s / 0.01s) / 8000 = Delta * 0.75                   *)
(* ============================================================================ *)
Raw_RPM_T  := (DINT_TO_REAL(Delta_T)  * 6000.0) / DINT_TO_REAL(Total_PPR);
Raw_RPM_X1 := (DINT_TO_REAL(Delta_X1) * 6000.0) / DINT_TO_REAL(Total_PPR);
Raw_RPM_X2 := (DINT_TO_REAL(Delta_X2) * 6000.0) / DINT_TO_REAL(Total_PPR);
Raw_RPM_Ms := (DINT_TO_REAL(Delta_Ms) * 6000.0) / DINT_TO_REAL(Total_PPR);
Raw_RPM_S  := (DINT_TO_REAL(Delta_S)  * 6000.0) / DINT_TO_REAL(Total_PPR);

(* ============================================================================ *)
(* 3. BỘ LỌC TRUNG BÌNH TRƯỢT 4 MẪU (MOVING AVERAGE CHỐNG RUNG GIẬT TỐC ĐỘ)     *)
(* ============================================================================ *)
RPM_T  := (Raw_RPM_T  + Buf_RPM_T_1  + Buf_RPM_T_2  + Buf_RPM_T_3)  / 4.0;
RPM_X1 := (Raw_RPM_X1 + Buf_RPM_X1_1 + Buf_RPM_X1_2 + Buf_RPM_X1_3) / 4.0;
RPM_X2 := (Raw_RPM_X2 + Buf_RPM_X2_1 + Buf_RPM_X2_2 + Buf_RPM_X2_3) / 4.0;
RPM_Ms := (Raw_RPM_Ms + Buf_RPM_Ms_1 + Buf_RPM_Ms_2 + Buf_RPM_Ms_3) / 4.0;
RPM_S  := (Raw_RPM_S  + Buf_RPM_S_1  + Buf_RPM_S_2  + Buf_RPM_S_3)  / 4.0;

(* Dịch chuyển bộ nhớ đệm mẫu trượt *)
Buf_RPM_T_3  := Buf_RPM_T_2;   Buf_RPM_T_2  := Buf_RPM_T_1;   Buf_RPM_T_1  := Raw_RPM_T;
Buf_RPM_X1_3 := Buf_RPM_X1_2;  Buf_RPM_X1_2 := Buf_RPM_X1_1;  Buf_RPM_X1_1 := Raw_RPM_X1;
Buf_RPM_X2_3 := Buf_RPM_X2_2;  Buf_RPM_X2_2 := Buf_RPM_X2_1;  Buf_RPM_X2_1 := Raw_RPM_X2;
Buf_RPM_Ms_3 := Buf_RPM_Ms_2;  Buf_RPM_Ms_2 := Buf_RPM_Ms_1;  Buf_RPM_Ms_1 := Raw_RPM_Ms;
Buf_RPM_S_3  := Buf_RPM_S_2;   Buf_RPM_S_2  := Buf_RPM_S_1;   Buf_RPM_S_1  := Raw_RPM_S;

(* Xuất tốc độ RPM ra các thanh ghi số nguyên 16-bit (INT) để giám sát HMI *)
D550 := REAL_TO_INT(RPM_T);  (* Trục Thu T: D550 (INT) *)
D552 := REAL_TO_INT(RPM_X1); (* Trục Kéo X1: D552 (INT) *)
D554 := REAL_TO_INT(RPM_X2); (* Trục Master X2: D554 (INT) *)
D556 := REAL_TO_INT(RPM_Ms); (* Trục Ghép Ms: D556 (INT) *)
D558 := REAL_TO_INT(RPM_S);  (* Trục Lô Dầu S: D558 (INT) *)

(* ============================================================================ *)
(* 4. TÍNH VẬN TỐC DÂY MPM (MÉT / PHÚT) THỰC TẾ CHO TẤT CẢ CÁC TRỤC LÔ           *)
(* ============================================================================ *)
(* Nạp giá trị mặc định cơ khí an toàn nếu chưa được khởi tạo *)
IF Gear_Ratio_X2    <= 0.0 THEN Gear_Ratio_X2    := 8.0;   END_IF;
IF Dia_X2_Roller_mm <= 0.0 THEN Dia_X2_Roller_mm := 300.5; END_IF;
IF Gear_Ratio_X1    <= 0.0 THEN Gear_Ratio_X1    := 8.0;   END_IF;
IF Dia_X1_Roller_mm <= 0.0 THEN Dia_X1_Roller_mm := 300.5; END_IF;
IF Gear_Ratio_Ms    <= 0.0 THEN Gear_Ratio_Ms    := 10.0;  END_IF;
IF Dia_Ms_Roller_mm <= 0.0 THEN Dia_Ms_Roller_mm := 200.0; END_IF;
IF Gear_Ratio_S     <= 0.0 THEN Gear_Ratio_S     := 10.0;  END_IF;
IF Dia_S_Roller_mm  <= 0.0 THEN Dia_S_Roller_mm  := 100.0; END_IF;
IF Gear_Ratio_T     <= 0.0 THEN Gear_Ratio_T     := 10.1;  END_IF;
IF Real_Dia_T_mm    <= 0.0 THEN Real_Dia_T_mm    := 300.0; END_IF;
IF Max_Speed_MPM    <= 0.0 THEN Max_Speed_MPM    := 100.0; END_IF;

(* Trục Master X2: Lô kéo chính dây chuyền (Đường kính 300.5mm, Tỷ số truyền 8:1) *)
MPM_X2 := (RPM_X2 * 3.14159 * Dia_X2_Roller_mm) / (1000.0 * Gear_Ratio_X2);

(* Trục Kéo X1: Lô kéo giấy trước ghép (Đường kính 300.5mm, Tỷ số truyền 8:1) *)
MPM_X1 := (RPM_X1 * 3.14159 * Dia_X1_Roller_mm) / (1000.0 * Gear_Ratio_X1);

(* Trục Ghép Ms: Lô ép ghép màng metalize (Đường kính 200mm, Tỷ số truyền 10:1) *)
MPM_Ms := (RPM_Ms * 3.14159 * Dia_Ms_Roller_mm) / (1000.0 * Gear_Ratio_Ms);

(* Trục Tráng Dầu S: Lô bôi dầu silicon (Đường kính 100mm, Tỷ số truyền 10:1) *)
MPM_S  := (RPM_S  * 3.14159 * Dia_S_Roller_mm)  / (1000.0 * Gear_Ratio_S);

(* Trục Cuộn Thu T: Lô cuộn màng theo đường kính thực tế (Real_Dia_T_mm, Tỷ số truyền 10.1:1) *)
MPM_T  := (RPM_T  * 3.14159 * Real_Dia_T_mm)    / (1000.0 * Gear_Ratio_T);

(* CẬP NHẬT TỐC ĐỘ DÂY CHUYỀN THỰC TẾ LÊN THANH GHI HMI D10 (ĐO TỪ TRỤC MASTER X2) *)
Current_Line_MPM := MPM_X2;

(* ============================================================================ *)
(* 5. GÁN BIẾN FEEDBACK TỐC ĐỘ CHO CÁC VÒNG PID THEO MPM THỰC TẾ (0..16000 DAC)  *)
(* ============================================================================ *)
IF Max_Speed_MPM > 0.0 THEN
    Feedback_Speed_X2 := (MPM_X2 * 16000.0) / Max_Speed_MPM;
    Feedback_Speed_Ms := (MPM_Ms * 16000.0) / Max_Speed_MPM;
ELSIF Max_RPM_X2 > 0.0 THEN
    Feedback_Speed_X2 := (RPM_X2 * 16000.0) / Max_RPM_X2;
    Feedback_Speed_Ms := (RPM_Ms * 16000.0) / Max_RPM_Ms;
END_IF;
Feedback_Speed_S := Raw_Analog_S;

(* ============================================================================ *)
(* 6. GỌI 7 KHỐI PID ĐIỀU KHIỂN CHU KỲ CHUẨN 10MS                              *)
(* ============================================================================ *)
(* PID Tốc độ Trục chính Master X2 *)
pid_X2(
    Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 3),
    Setpoint    := SP_Speed_X2,
    Feedback    := Feedback_Speed_X2,
    Kp          := Kp_X2, Ki := Ki_X2, Kd := Kd_X2,
    AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 3)
);
PID_Out_X2 := pid_X2.PID_Output;

(* PID Tốc độ Trục Ghép Ms *)
pid_Ms(
    Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 4),
    Setpoint    := SP_Speed_Ms,
    Feedback    := Feedback_Speed_Ms,
    Kp          := Kp_Ms, Ki := Ki_Ms, Kd := Kd_Ms,
    AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 4)
);
PID_Out_Ms := pid_Ms.PID_Output;

(* PID Tốc độ Trục Tráng Dầu S *)
pid_S(
    Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 5),
    Setpoint    := SP_Speed_S,
    Feedback    := Feedback_Speed_S,
    Kp          := Kp_S, Ki := Ki_S, Kd := Kd_S,
    AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 5)
);
PID_Out_S := pid_S.PID_Output;

(* PID Lực căng Loadcell Trục Kéo Giấy X1 *)
pid_X1(
    Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 2),
    Setpoint    := SP_Tension_X1,
    Feedback    := Weight_Net_X1,
    Kp          := Kp_X1, Ki := Ki_X1, Kd := Kd_X1,
    AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 2)
);
PID_Out_X1 := pid_X1.PID_Output;

(* PID Lực căng Loadcell Cuộn Thu T *)
pid_T(
    Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 1),
    Setpoint    := Effective_SP_T,
    Feedback    := Weight_Net_T,
    Kp          := Kp_T, Ki := Ki_T, Kd := Kd_T,
    AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 1)
);
PID_Out_T := pid_T.PID_Output;

(* PID Lực căng Thắng Từ Xả Metalize M *)
pid_M(
    Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 6),
    Setpoint    := SP_Tension_M,
    Feedback    := Weight_Net_M,
    Kp          := Kp_M, Ki := Ki_M, Kd := Kd_M,
    AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 6)
);
PID_Out_M := pid_M.PID_Output;

(* PID Lực căng Trục Xả Metalize U *)
pid_U(
    Enable      := (HMI_PID_Enable AND State_Machine = 1) OR (HMI_Cmd_AutoTune AND HMI_Axis_Select = 7),
    Setpoint    := SP_Tension_U,
    Feedback    := Weight_Net_U,
    Kp          := Kp_U, Ki := Ki_U, Kd := Kd_U,
    AT_Enable   := (HMI_Cmd_AutoTune AND HMI_Axis_Select = 7)
);
PID_Out_U := pid_U.PID_Output;

(* CẬP NHẬT KẾT QUẢ KHI AUTO-TUNE HOÀN THÀNH *)
IF pid_X2.AT_Done THEN
    Kp_X2 := pid_X2.Tuned_Kp; Ki_X2 := pid_X2.Tuned_Ki; Kd_X2 := pid_X2.Tuned_Kd;
    HMI_Disp_Kp := Kp_X2; HMI_Disp_Ki := Ki_X2; HMI_Disp_Kd := Kd_X2;
ELSIF pid_Ms.AT_Done THEN
    Kp_Ms := pid_Ms.Tuned_Kp; Ki_Ms := pid_Ms.Tuned_Ki; Kd_Ms := pid_Ms.Tuned_Kd;
    HMI_Disp_Kp := Kp_Ms; HMI_Disp_Ki := Ki_Ms; HMI_Disp_Kd := Kd_Ms;
ELSIF pid_S.AT_Done THEN
    Kp_S := pid_S.Tuned_Kp; Ki_S := pid_S.Tuned_Ki; Kd_S := pid_S.Tuned_Kd;
    HMI_Disp_Kp := Kp_S; HMI_Disp_Ki := Ki_S; HMI_Disp_Kd := Kd_S;
ELSIF pid_X1.AT_Done THEN
    Kp_X1 := pid_X1.Tuned_Kp; Ki_X1 := pid_X1.Tuned_Ki; Kd_X1 := pid_X1.Tuned_Kd;
    HMI_Disp_Kp := Kp_X1; HMI_Disp_Ki := Ki_X1; HMI_Disp_Kd := Kd_X1;
ELSIF pid_T.AT_Done THEN
    Kp_T := pid_T.Tuned_Kp; Ki_T := pid_T.Tuned_Ki; Kd_T := pid_T.Tuned_Kd;
    HMI_Disp_Kp := Kp_T; HMI_Disp_Ki := Ki_T; HMI_Disp_Kd := Kd_T;
ELSIF pid_M.AT_Done THEN
    Kp_M := pid_M.Tuned_Kp; Ki_M := pid_M.Tuned_Ki; Kd_M := pid_M.Tuned_Kd;
    HMI_Disp_Kp := Kp_M; HMI_Disp_Ki := Ki_M; HMI_Disp_Kd := Kd_M;
ELSIF pid_U.AT_Done THEN
    Kp_U := pid_U.Tuned_Kp; Ki_U := pid_U.Tuned_Ki; Kd_U := pid_U.Tuned_Kd;
    HMI_Disp_Kp := Kp_U; HMI_Disp_Ki := Ki_U; HMI_Disp_Kd := Kd_U;
END_IF;

IF pid_X2.AT_Done OR pid_Ms.AT_Done OR pid_S.AT_Done OR pid_X1.AT_Done OR pid_T.AT_Done OR pid_M.AT_Done OR pid_U.AT_Done THEN
    HMI_Cmd_AutoTune   := FALSE;
    HMI_Status_AT_Done := TRUE;
END_IF;

HMI_Status_AT_Busy := pid_T.AT_Busy OR pid_X1.AT_Busy OR pid_X2.AT_Busy OR pid_Ms.AT_Busy OR pid_S.AT_Busy OR pid_M.AT_Busy OR pid_U.AT_Busy;

(* ============================================================================ *)
(* 7. TÍNH TOÁN XUẤT ÁP TỐC ĐỘ VÀ TORQUE CHO TỪNG TRỤC (FLOAT)                   *)
(* ============================================================================ *)
IF State_Machine = 0 THEN
    IF HMI_Test_X2 THEN Calc_Speed_X2 := Test_Speed_X2; ELSE Calc_Speed_X2 := 0.0; END_IF;
    IF HMI_Test_X1 THEN Calc_Speed_X1 := Test_Speed_X1; ELSE Calc_Speed_X1 := 0.0; END_IF;
    IF HMI_Test_Ms THEN Calc_Speed_Ms := Test_Speed_Ms; ELSE Calc_Speed_Ms := 0.0; END_IF;
    IF HMI_Test_S  THEN Calc_Speed_S  := Test_Speed_S;  ELSE Calc_Speed_S  := 0.0; END_IF;

    IF HMI_Test_T THEN
        Calc_Speed_T  := Test_Speed_T;
        Calc_Torque_T := Test_Torque_T;
    ELSE
        Calc_Speed_T  := 0.0;
        Calc_Torque_T := 0.0;
    END_IF;

    IF HMI_Test_M THEN
        Calc_Torque_M := Test_Torque_M;
    ELSIF Hold_Torque_Stop_M THEN
        Calc_Torque_M := (Base_Torque_M * 80.0);
    ELSE
        Calc_Torque_M := 0.0;
    END_IF;

    IF HMI_Test_U THEN
        Calc_Speed_U := Test_Speed_U;
    ELSIF Hold_Torque_Stop_U THEN
        Calc_Speed_U := (Init_Holding_Torque_U * 80.0);
    ELSE
        Calc_Speed_U := 0.0;
    END_IF;

ELSE
    Calc_Speed_X2 := SP_Speed_X2 + PID_Out_X2;
    Calc_Speed_X1 := SP_Speed_X1 + PID_Out_X1;
    Calc_Speed_Ms := SP_Speed_Ms + PID_Out_Ms;
    Calc_Speed_S  := SP_Speed_S  + PID_Out_S;
    Calc_Speed_T  := SP_Speed_T;
    Calc_Torque_T := (Effective_SP_T * 160.0) + PID_Out_T;

    (* Xả U: Giới hạn ngõ ra max 5V (tương đương 0..8000 trên dải 0..10V) *)
    IF Real_Dia_U_mm > 0.0 THEN
        Calc_Speed_U := (((Calc_Speed_X2 * Max_Dia_U_mm) / Real_Dia_U_mm) * 0.5) + PID_Out_U;
    ELSE
        Calc_Speed_U := (Calc_Speed_X2 * 0.5) + PID_Out_U;
    END_IF;

    IF Rev_Count_M <= 5 THEN
        Base_Torque_M := Init_Holding_Torque_M;
    ELSIF (Max_Dia_M_mm - Core_Dia_M_mm) > 0.0 THEN
        Base_Torque_M := Min_Torque_M + (((Max_Torque_M - Min_Torque_M) * (Real_Dia_M_mm - Core_Dia_M_mm)) / (Max_Dia_M_mm - Core_Dia_M_mm));
    ELSE
        Base_Torque_M := Min_Torque_M;
    END_IF;
    (* Thắng Từ M: Giới hạn ngõ ra max 5V (0..100% ứng với 0..8000) *)
    Calc_Torque_M := (Base_Torque_M * 80.0) + PID_Out_M;
END_IF;

(* Khống chế biên an toàn ngõ ra Analog: Servo xuất 0..16000 (0..10V), riêng Thắng M và Xả U xuất 0..8000 (0..5V) *)
IF Calc_Speed_T  < 0.0 THEN Calc_Speed_T  := 0.0; ELSIF Calc_Speed_T  > 16000.0 THEN Calc_Speed_T  := 16000.0; END_IF;
IF Calc_Torque_T < 0.0 THEN Calc_Torque_T := 0.0; ELSIF Calc_Torque_T > 16000.0 THEN Calc_Torque_T := 16000.0; END_IF;
IF Calc_Speed_X1 < 0.0 THEN Calc_Speed_X1 := 0.0; ELSIF Calc_Speed_X1 > 16000.0 THEN Calc_Speed_X1 := 16000.0; END_IF;
IF Calc_Speed_X2 < 0.0 THEN Calc_Speed_X2 := 0.0; ELSIF Calc_Speed_X2 > 16000.0 THEN Calc_Speed_X2 := 16000.0; END_IF;
IF Calc_Speed_Ms < 0.0 THEN Calc_Speed_Ms := 0.0; ELSIF Calc_Speed_Ms > 16000.0 THEN Calc_Speed_Ms := 16000.0; END_IF;
IF Calc_Torque_M < 0.0 THEN Calc_Torque_M := 0.0; ELSIF Calc_Torque_M > 8000.0  THEN Calc_Torque_M := 8000.0;  END_IF;
IF Calc_Speed_S  < 0.0 THEN Calc_Speed_S  := 0.0; ELSIF Calc_Speed_S  > 16000.0 THEN Calc_Speed_S  := 16000.0; END_IF;
IF Calc_Speed_U  < 0.0 THEN Calc_Speed_U  := 0.0; ELSIF Calc_Speed_U  > 8000.0  THEN Calc_Speed_U  := 8000.0;  END_IF;

(* ============================================================================ *)
(* 8. XUẤT ÁP RA TRẠM 1 CC-LINK DAC (AJ65VBTCU-68DAVN: W200..W207)               *)
(* ============================================================================ *)
W200 := REAL_TO_INT(Calc_Speed_T  / 4.0);
W201 := REAL_TO_INT(Calc_Torque_T / 4.0);
W202 := REAL_TO_INT(Calc_Speed_X1 / 4.0);
W203 := REAL_TO_INT(Calc_Speed_X2 / 4.0);
W204 := REAL_TO_INT(Calc_Speed_Ms / 4.0);
W205 := REAL_TO_INT(Calc_Torque_M / 4.0);
W206 := REAL_TO_INT(Calc_Speed_S  / 4.0);
W207 := REAL_TO_INT(Calc_Speed_U  / 4.0);

(* Cập nhật thanh ghi giám sát HMI D510..D517 *)
D510 := INT_TO_WORD(W200 * 4);
D511 := INT_TO_WORD(W201 * 4);
D512 := INT_TO_WORD(W202 * 4);
D513 := INT_TO_WORD(W203 * 4);
D514 := INT_TO_WORD(W204 * 4);
D515 := INT_TO_WORD(W205 * 4);
D516 := INT_TO_WORD(W206 * 4);
D517 := INT_TO_WORD(W207 * 4);

(* THÍ NGHIỆM ĐO TỐC ĐỘ CHUẨN 1 GIÂY BẰNG CỜ THẠCH ANH SM412 *)
IF SM412 AND NOT Prev_SM412 THEN
    Delta_1s := ABS(Curr_Pulse_T - Last_Pulse_1s);
    Last_Pulse_1s := Curr_Pulse_T;
    
    Test_RPM_1s := (DINT_TO_REAL(Delta_1s) * 60.0) / 8000.0;
    D994 := REAL_TO_INT(Test_RPM_1s); (* D994 hiển thị trực tiếp RPM đo chuẩn trong 1 giây *)
END_IF;
Prev_SM412 := SM412;
