(* ============================================================================ *)
(* DỰ ÁN: MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - PLC MITSUBISHI Q02U                *)
(* THƯ MỤC: ST_LATCH_GHEP                                                      *)
(* FILE: 03_MAIN_CALC_ST.st                                                    *)
(* LOẠI CHƯƠNG TRÌNH: SCAN EXECUTION (Chạy quét tuần hoàn song song với LADDER)*)
(* NGÔN NGỮ: STRUCTURED TEXT (ST)                                              *)
(* TÁC VỤ CHÍNH:                                                               *)
(*   1. Đọc xung tức thời QD62/QD62D 5 trục (D520..D528)                       *)
(*   2. Chốt xung Pha Z phần cứng qua Buffer G12/G44 và đếm số vòng quay 5 trục*)
(*   3. Đọc 2 cảm biến Sensor X4A (M) & X4B (U) chốt số xung Master tính đường kính*)
(*   4. Đọc & Lọc 8 kênh Analog CC-Link ADC Loadcell lực căng (D500..D507)     *)
(*   5. Tính toán mét màng, Tự động giảm tốc khi gần đủ mét                    *)
(*   6. Thuật toán điều khiển lực căng Tension PID cho 4 cuộn/trục             *)
(*   7. Tính toán đồng bộ tốc độ các trục theo Master X2                       *)
(*   8. Xuất áp điều khiển CC-Link DAC ra Servo & Thắng từ (D510..D517)       *)
(* ============================================================================ *)

(* ============================================================================ *)
(* 1. ĐỌC XUNG 32-BIT TỨC THỜI TỪ BUFFER QD62 & QD62D CHO 5 TRỤC MỖI SCAN      *)
(* ============================================================================ *)
DMOV(TRUE, U1\G2,  Curr_Pulse_S);  (* Slot 1 CH1: Trục Lô Dầu S (D528 - DINT) *)
DMOV(TRUE, U2\G2,  Curr_Pulse_T);  (* Slot 2 CH1: Trục Thu T (D520 - DINT) *)
DMOV(TRUE, U2\G34, Curr_Pulse_X1); (* Slot 2 CH2: Trục Kéo X1 (D522 - DINT) *)
DMOV(TRUE, U3\G2,  Curr_Pulse_X2); (* Slot 3 CH1: Trục Master X2 (D524 - DINT) *)
DMOV(TRUE, U3\G34, Curr_Pulse_Ms); (* Slot 3 CH2: Trục Ghép Ms (D526 - DINT) *)

Total_PPR := 8000; (* 2000 x 4 vi sai *)

(* ============================================================================ *)
(* 2. CHỐT XUNG PHA Z PHẦN CỨNG (LATCH COUNTER FUNCTION) CHO CẢ 5 TRỤC         *)
(* LƯU Ý: Tuyệt đối KHÔNG gán Y16, Y26, Y2E, Y36, Y3E := TRUE trong scan!       *)
(* Buffer G12 (CH1) và G44 (CH2) tự động cập nhật khi chân giắc FUNC có xung!  *)
(* ============================================================================ *)

(* --- TRỤC 1: THU T (SLOT 2 CH1 - BUFFER LATCH G12..G13 - DINT 32-BIT) --- *)
DMOV(TRUE, U2\G12, Latched_Pulse_T);
IF (Latched_Pulse_T <> Prev_Latch_T) AND (Latched_Pulse_T <> 0) THEN
    Real_PPR_T   := ABS(Latched_Pulse_T - Prev_Latch_T);
    Rev_Count_T  := Rev_Count_T + 1;
    Prev_Latch_T := Latched_Pulse_T;
END_IF;

(* --- TRỤC 2: KÉO X1 (SLOT 2 CH2 - BUFFER LATCH G44..G45 - DINT 32-BIT) --- *)
DMOV(TRUE, U2\G44, Latched_Pulse_X1);
IF (Latched_Pulse_X1 <> Prev_Latch_X1) AND (Latched_Pulse_X1 <> 0) THEN
    Real_PPR_X1   := ABS(Latched_Pulse_X1 - Prev_Latch_X1);
    Rev_Count_X1  := Rev_Count_X1 + 1;
    Prev_Latch_X1 := Latched_Pulse_X1;
END_IF;

(* --- TRỤC 3: MASTER X2 (SLOT 3 CH1 - BUFFER LATCH G12..G13 - DINT 32-BIT) --- *)
DMOV(TRUE, U3\G12, Latched_Pulse_X2);
IF (Latched_Pulse_X2 <> Prev_Latch_X2) AND (Latched_Pulse_X2 <> 0) THEN
    Real_PPR_X2   := ABS(Latched_Pulse_X2 - Prev_Latch_X2);
    Rev_Count_X2  := Rev_Count_X2 + 1;
    Prev_Latch_X2 := Latched_Pulse_X2;
END_IF;

(* --- TRỤC 4: GHÉP MS (SLOT 3 CH2 - BUFFER LATCH G44..G45 - DINT 32-BIT) --- *)
DMOV(TRUE, U3\G44, Latched_Pulse_Ms);
IF (Latched_Pulse_Ms <> Prev_Latch_Ms) AND (Latched_Pulse_Ms <> 0) THEN
    Real_PPR_Ms   := ABS(Latched_Pulse_Ms - Prev_Latch_Ms);
    Rev_Count_Ms  := Rev_Count_Ms + 1;
    Prev_Latch_Ms := Latched_Pulse_Ms;
END_IF;

(* --- TRỤC 5: LÔ DẦU S (SLOT 1 CH1 - BUFFER LATCH G12..G13 - DINT 32-BIT) --- *)
DMOV(TRUE, U1\G12, Latched_Pulse_S);
IF (Latched_Pulse_S <> Prev_Latch_S) AND (Latched_Pulse_S <> 0) THEN
    Real_PPR_S   := ABS(Latched_Pulse_S - Prev_Latch_S);
    Rev_Count_S  := Rev_Count_S + 1;
    Prev_Latch_S := Latched_Pulse_S;
END_IF;

(* ============================================================================ *)
(* 3. TÍNH ĐƯỜNG KÍNH CUỘN XẢ M & XẢ U TỪ 2 SENSOR TIỆM CẬN (X4A & X4B)        *)
(* NGUYÊN LÝ: Mỗi vòng quay của cuộn Xả M (hoặc U), Sensor chốt số xung Master *)
(* X2 đã lăn được. Đường kính = (Số xung Master lăn được / PPR_X2) * Dia_Master *)
(* ============================================================================ *)

(* --- 3.1. CUỘN XẢ METALIZE M (SENSOR X4A - 1 XUNG / VÒNG) --- *)
IF X4A AND NOT M_Sensor_M_Prev THEN
    Delta_Pulse_M := Curr_Pulse_X2 - Last_Pulse_M;
    Last_Pulse_M  := Curr_Pulse_X2;
    Rev_Count_M   := Rev_Count_M + 1;

    (* Chỉ tính đường kính khi máy đang chạy thực sự (Delta_Pulse_M hợp lệ) *)
    IF (Delta_Pulse_M > 1000) AND (Total_PPR > 0) THEN
        Calc_Dia_M := (DINT_TO_REAL(Delta_Pulse_M) / DINT_TO_REAL(Total_PPR)) * Dia_X2_Roller_mm;
        
        (* Lọc thông thấp chống nhiễu đo cho đường kính: 80% cũ + 20% mới *)
        IF (Calc_Dia_M >= Core_Dia_M_mm) AND (Calc_Dia_M <= Max_Dia_M_mm) THEN
            Real_Dia_M_mm := (Real_Dia_M_mm * 0.8) + (Calc_Dia_M * 0.2);
        END_IF;
    END_IF;
END_IF;
M_Sensor_M_Prev := X4A;

(* --- 3.2. CUỘN XẢ MÀNG U (SENSOR X4B - 1 XUNG / VÒNG) --- *)
IF X4B AND NOT M_Sensor_U_Prev THEN
    Delta_Pulse_U := Curr_Pulse_X2 - Last_Pulse_U;
    Last_Pulse_U  := Curr_Pulse_X2;
    Rev_Count_U   := Rev_Count_U + 1;

    IF (Delta_Pulse_U > 1000) AND (Total_PPR > 0) THEN
        Calc_Dia_U := (DINT_TO_REAL(Delta_Pulse_U) / DINT_TO_REAL(Total_PPR)) * Dia_X2_Roller_mm;
        
        IF (Calc_Dia_U >= Core_Dia_U_mm) AND (Calc_Dia_U <= Max_Dia_U_mm) THEN
            Real_Dia_U_mm := (Real_Dia_U_mm * 0.8) + (Calc_Dia_U * 0.2);
        END_IF;
    END_IF;
END_IF;
M_Sensor_U_Prev := X4B;

(* ============================================================================ *)
(* 4. ĐỌC VÀ LỌC 8 KÊNH ANALOG CC-LINK ADC TRẠM 2 (AJ65VBTCU-68ADVN)            *)
(* ============================================================================ *)
Raw_ADC_CH1 := W110; Raw_ADC_CH2 := W111;
Raw_ADC_CH3 := W112; Raw_ADC_CH4 := W113;
Raw_ADC_CH5 := W114; Raw_ADC_CH6 := W115;
Raw_ADC_CH7 := W116; Raw_ADC_CH8 := W117;

(* Lọc Exponential Moving Average (EMA) 90% cũ + 10% mới để kim lực căng êm ái *)
Filt_ADC_T  := (Filt_ADC_T  * 0.9) + (INT_TO_REAL(Raw_ADC_CH1) * 0.1);
Filt_ADC_X1 := (Filt_ADC_X1 * 0.9) + (INT_TO_REAL(Raw_ADC_CH2) * 0.1);
Filt_ADC_M  := (Filt_ADC_M  * 0.9) + (INT_TO_REAL(Raw_ADC_CH3) * 0.1);
Filt_ADC_U  := (Filt_ADC_U  * 0.9) + (INT_TO_REAL(Raw_ADC_CH4) * 0.1);

(* Quy đổi lực căng thực tế (kg): Range 0..4000 = 0..50.0 kg *)
Act_Tension_T  := (Filt_ADC_T  / 4000.0) * 50.0 * Calib_Gain_T;
Act_Tension_X1 := (Filt_ADC_X1 / 4000.0) * 50.0 * Calib_Gain_X1;
Act_Tension_M  := (Filt_ADC_M  / 4000.0) * 50.0 * Calib_Gain_M;
Act_Tension_U  := (Filt_ADC_U  / 4000.0) * 50.0 * Calib_Gain_U;

(* Duy trì cấu hình CC-Link ADC định kỳ chống mất cấu hình khi sụt nguồn *)
W210 := 16#00FF; W211 := 16#0000; W212 := 16#0000; W213 := 16#2222;
W214 := 16;      W215 := 16;      W216 := 16;      W217 := 16;

(* ============================================================================ *)
(* 5. TÍNH CHIỀU DÀI MÉT MÀNG VÀ TỰ ĐỘNG GIẢM TỐC KHI ĐỦ MÉT                   *)
(* ============================================================================ *)
IF Total_PPR > 0 THEN
    Delta_X2_Scan := Curr_Pulse_X2 - Prev_Pulse_X2;
    Prev_Pulse_X2 := Curr_Pulse_X2;
    
    IF Delta_X2_Scan > 0 THEN
        Total_Length_Meters := Total_Length_Meters + (DINT_TO_REAL(Delta_X2_Scan) / DINT_TO_REAL(Total_PPR)) * (3.1415926 * Dia_X2_Roller_mm / 1000.0);
    END_IF;
END_IF;

(* Tự động tính đường kính cuộn Thu T theo chiều dài mét màng tích lũy *)
IF (Film_Thickness_um > 0.0) AND (Core_Dia_T_mm > 0.0) THEN
    Real_Dia_T_mm := SQRT((Core_Dia_T_mm * Core_Dia_T_mm) + (4.0 * Total_Length_Meters * (Film_Thickness_um / 1000.0) / 3.1415926));
    IF Real_Dia_T_mm > Max_Dia_T_mm THEN Real_Dia_T_mm := Max_Dia_T_mm; END_IF;
END_IF;

(* Nhận trạng thái chạy máy từ LADDER (D100): 1 = Auto Run, 3 = Jog, 0 = Stop *)
State_Machine := D100;

IF State_Machine = 1 THEN (* AUTO RUN *)
    Target_Line_MPM := Set_Line_Speed_MPM;
    
    (* Giảm tốc khi gần đủ mét màng cài đặt *)
    IF (Set_Target_Length > 0.0) AND (Decel_Distance_Meters > 0.0) THEN
        IF Total_Length_Meters >= (Set_Target_Length - Decel_Distance_Meters) THEN
            IF Target_Line_MPM > Min_Speed_MPM THEN Target_Line_MPM := Min_Speed_MPM; END_IF;
        END_IF;
    END_IF;
ELSIF State_Machine = 3 THEN (* JOG CRAWL *)
    Target_Line_MPM := Jog_Speed_MPM;
ELSE (* STOP *)
    Target_Line_MPM := 0.0;
END_IF;

(* RAMP TĂNG/GIẢM TỐC TUẦN TỰ MỖI SCAN (0.01s) *)
Scan_Step_Accel := (Set_Line_Speed_MPM / Accel_Time_Sec) * 0.01;
Scan_Step_Decel := (Set_Line_Speed_MPM / Decel_Time_Sec) * 0.01;

IF Command_Speed_MPM < Target_Line_MPM THEN
    Command_Speed_MPM := Command_Speed_MPM + Scan_Step_Accel;
    IF Command_Speed_MPM > Target_Line_MPM THEN Command_Speed_MPM := Target_Line_MPM; END_IF;
ELSIF Command_Speed_MPM > Target_Line_MPM THEN
    Command_Speed_MPM := Command_Speed_MPM - Scan_Step_Decel;
    IF Command_Speed_MPM < Target_Line_MPM THEN Command_Speed_MPM := Target_Line_MPM; END_IF;
END_IF;

(* ============================================================================ *)
(* 6. TÍNH TỐC ĐỘ ĐỒNG BỘ 5 TRỤC THEO COMMAND_SPEED_MPM (RPM - REAL)           *)
(* ============================================================================ *)
(* Trục Master X2: Trục chuẩn dây chuyền *)
IF Dia_X2_Roller_mm > 0.0 THEN
    Sync_RPM_X2 := (Command_Speed_MPM * 1000.0) / (3.1415926 * Dia_X2_Roller_mm) * Gear_Ratio_X2;
ELSE
    Sync_RPM_X2 := 0.0;
END_IF;

(* Trục Kéo X1 *)
IF Dia_X1_Roller_mm > 0.0 THEN
    Sync_RPM_X1 := (Command_Speed_MPM * 1000.0) / (3.1415926 * Dia_X1_Roller_mm) * Gear_Ratio_X1;
ELSE
    Sync_RPM_X1 := 0.0;
END_IF;

(* Trục Ghép Màng Ms *)
IF Dia_Ms_Roller_mm > 0.0 THEN
    Sync_RPM_Ms := (Command_Speed_MPM * 1000.0) / (3.1415926 * Dia_Ms_Roller_mm) * Gear_Ratio_Ms;
ELSE
    Sync_RPM_Ms := 0.0;
END_IF;

(* Trục Lô Dầu S *)
IF Dia_S_Roller_mm > 0.0 THEN
    Sync_RPM_S := (Command_Speed_MPM * 1000.0) / (3.1415926 * Dia_S_Roller_mm) * Gear_Ratio_S;
ELSE
    Sync_RPM_S := 0.0;
END_IF;

(* Trục Thu T: Tốc độ vòng quay thay đổi nghịch đảo theo đường kính cuộn Real_Dia_T *)
IF Real_Dia_T_mm > 0.0 THEN
    Sync_RPM_T := (Command_Speed_MPM * 1000.0) / (3.1415926 * Real_Dia_T_mm) * Gear_Ratio_T;
ELSE
    Sync_RPM_T := 0.0;
END_IF;

(* ============================================================================ *)
(* 7. THUẬT TOÁN ĐIỀU KHIỂN LỰC CĂNG (TENSION PID CONTROLLER)                   *)
(* ============================================================================ *)
IF State_Machine = 1 THEN (* Đang chạy tự động *)
    (* PID Cuộn Thu T (Bù tốc độ motor) *)
    Err_Tension_T := Set_Tension_T - Act_Tension_T;
    Integral_T    := Integral_T + (Err_Tension_T * 0.01);
    IF Integral_T > 200.0 THEN Integral_T := 200.0; ELSIF Integral_T < -200.0 THEN Integral_T := -200.0; END_IF;
    Deriv_T       := (Err_Tension_T - Prev_Err_T) / 0.01;
    Prev_Err_T    := Err_Tension_T;
    PID_Out_T     := (Kp_T * Err_Tension_T) + (Ki_T * Integral_T) + (Kd_T * Deriv_T);
    Final_RPM_T   := Sync_RPM_T + PID_Out_T;

    (* PID Trục Kéo X1 *)
    Err_Tension_X1 := Set_Tension_X1 - Act_Tension_X1;
    Integral_X1    := Integral_X1 + (Err_Tension_X1 * 0.01);
    IF Integral_X1 > 100.0 THEN Integral_X1 := 100.0; ELSIF Integral_X1 < -100.0 THEN Integral_X1 := -100.0; END_IF;
    Deriv_X1       := (Err_Tension_X1 - Prev_Err_X1) / 0.01;
    Prev_Err_X1    := Err_Tension_X1;
    PID_Out_X1     := (Kp_X1 * Err_Tension_X1) + (Ki_X1 * Integral_X1) + (Kd_X1 * Deriv_X1);
    Final_RPM_X1   := Sync_RPM_X1 + PID_Out_X1;

    (* Điều khiển Torque Thắng từ Cuộn Xả M: Tỷ lệ theo đường kính cuộn Real_Dia_M *)
    IF Core_Dia_M_mm > 0.0 THEN
        Tension_Ratio_M := Real_Dia_M_mm / Core_Dia_M_mm;
        Final_Torque_M  := Min_Torque_M * Tension_Ratio_M;
        IF Final_Torque_M > Max_Torque_M THEN Final_Torque_M := Max_Torque_M; END_IF;
    ELSE
        Final_Torque_M := Min_Torque_M;
    END_IF;

    (* Tương tự Cuộn Xả U *)
    IF Core_Dia_U_mm > 0.0 THEN
        Tension_Ratio_U := Real_Dia_U_mm / Core_Dia_U_mm;
        Final_Torque_U  := Min_Torque_U * Tension_Ratio_U;
        IF Final_Torque_U > Max_Torque_U THEN Final_Torque_U := Max_Torque_U; END_IF;
    ELSE
        Final_Torque_U := Min_Torque_U;
    END_IF;
ELSE
    (* Khi dừng hoặc Jog: Giữ mức torque giữ căng chống chùng màng *)
    Final_RPM_T    := Sync_RPM_T;
    Final_RPM_X1   := Sync_RPM_X1;
    Final_Torque_M := Init_Holding_Torque_M;
    Final_Torque_U := Init_Holding_Torque_U;
    Integral_T     := 0.0;
    Integral_X1    := 0.0;
END_IF;

Final_RPM_X2 := Sync_RPM_X2;
Final_RPM_Ms := Sync_RPM_Ms;
Final_RPM_S  := Sync_RPM_S;

(* ============================================================================ *)
(* 8. QUY ĐỔI VÀ XUẤT ÁP ANALOG CC-LINK DAC TRẠM 1 (AJ65VBTCU-68DAVN: 0..4000)  *)
(* ============================================================================ *)
(* CH1: Tốc độ Thu T (0..Max_RPM_T -> 0..4000) *)
IF Max_RPM_T > 0.0 THEN
    Out_DAC_CH1 := REAL_TO_INT((Final_RPM_T / Max_RPM_T) * 4000.0);
    IF Out_DAC_CH1 > 4000 THEN Out_DAC_CH1 := 4000; ELSIF Out_DAC_CH1 < 0 THEN Out_DAC_CH1 := 0; END_IF;
ELSE Out_DAC_CH1 := 0; END_IF;

(* CH2: Torque Thu T *)
Out_DAC_CH2 := 4000; (* Mở 100% Torque giới hạn *)

(* CH3: Tốc độ Kéo X1 *)
IF Max_RPM_X1 > 0.0 THEN
    Out_DAC_CH3 := REAL_TO_INT((Final_RPM_X1 / Max_RPM_X1) * 4000.0);
    IF Out_DAC_CH3 > 4000 THEN Out_DAC_CH3 := 4000; ELSIF Out_DAC_CH3 < 0 THEN Out_DAC_CH3 := 0; END_IF;
ELSE Out_DAC_CH3 := 0; END_IF;

(* CH4: Tốc độ Master X2 *)
IF Max_RPM_X2 > 0.0 THEN
    Out_DAC_CH4 := REAL_TO_INT((Final_RPM_X2 / Max_RPM_X2) * 4000.0);
    IF Out_DAC_CH4 > 4000 THEN Out_DAC_CH4 := 4000; ELSIF Out_DAC_CH4 < 0 THEN Out_DAC_CH4 := 0; END_IF;
ELSE Out_DAC_CH4 := 0; END_IF;

(* CH5: Tốc độ Ghép Ms *)
IF Max_RPM_Ms > 0.0 THEN
    Out_DAC_CH5 := REAL_TO_INT((Final_RPM_Ms / Max_RPM_Ms) * 4000.0);
    IF Out_DAC_CH5 > 4000 THEN Out_DAC_CH5 := 4000; ELSIF Out_DAC_CH5 < 0 THEN Out_DAC_CH5 := 0; END_IF;
ELSE Out_DAC_CH5 := 0; END_IF;

(* CH6: Torque Thắng từ M (0..100% -> 0..4000) *)
Out_DAC_CH6 := REAL_TO_INT((Final_Torque_M / 100.0) * 4000.0);
IF Out_DAC_CH6 > 4000 THEN Out_DAC_CH6 := 4000; ELSIF Out_DAC_CH6 < 0 THEN Out_DAC_CH6 := 0; END_IF;

(* CH7: Tốc độ Tráng Dầu S *)
IF Max_RPM_S > 0.0 THEN
    Out_DAC_CH7 := REAL_TO_INT((Final_RPM_S / Max_RPM_S) * 4000.0);
    IF Out_DAC_CH7 > 4000 THEN Out_DAC_CH7 := 4000; ELSIF Out_DAC_CH7 < 0 THEN Out_DAC_CH7 := 0; END_IF;
ELSE Out_DAC_CH7 := 0; END_IF;

(* CH8: Tốc độ/Torque Xả U *)
Out_DAC_CH8 := REAL_TO_INT((Final_Torque_U / 100.0) * 4000.0);
IF Out_DAC_CH8 > 4000 THEN Out_DAC_CH8 := 4000; ELSIF Out_DAC_CH8 < 0 THEN Out_DAC_CH8 := 0; END_IF;

(* Ghi ra Link Register CC-Link DAC Trạm 1 *)
W100 := Out_DAC_CH1; W101 := Out_DAC_CH2;
W102 := Out_DAC_CH3; W103 := Out_DAC_CH4;
W104 := Out_DAC_CH5; W105 := Out_DAC_CH6;
W106 := Out_DAC_CH7; W107 := Out_DAC_CH8;
