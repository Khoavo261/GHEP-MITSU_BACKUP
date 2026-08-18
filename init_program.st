(* ============================================================================ *)
(* TÊN CHƯƠNG TRÌNH : INIT_PROGRAM (INITIAL EXECUTION POU / FIRST SCAN SM402)   *)
(* HỆ THỐNG        : MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - MITSUBISHI Q02U PLC       *)
(* KIỂU DỮ LIỆU    : SỐ THỰC FLOAT / REAL (CHUẨN IEC)                          *)
(* MỤC ĐÍCH        : KHỞI TẠO TỶ SỐ TRUYỀN, ĐƯỜNG KÍNH LÔ, THÔNG SỐ TỐC ĐỘ,     *)
(*                   LỰC CĂNG, PID VÀ BẢO VỆ CHỐNG LỖI CHIA CHO 0 (ZERO DIV)    *)
(* ============================================================================ *)

(* CHỈ CHẠY ĐÚNG 1 LẦN DUY NHẤT KHI CPU CHUYỂN TỪ STOP SANG RUN *)
IF SM402 THEN

    (* ---------------------------------------------------------------------------- *)
    (* 1. KHỞI TẠO TỐC ĐỘ TỐI ĐA MOTOR (RPM - REAL)                                *)
    (* ---------------------------------------------------------------------------- *)
    IF Max_RPM_X2 <= 0.0 THEN Max_RPM_X2 := 1000.0; END_IF; (* Trục Master X2: Max 1000 RPM *)
    IF Max_RPM_X1 <= 0.0 THEN Max_RPM_X1 := 1000.0; END_IF; (* Trục Kéo X1:    Max 1000 RPM *)
    IF Max_RPM_Ms <= 0.0 THEN Max_RPM_Ms := 3000.0; END_IF; (* Trục Ghép Ms:   Max 3000 RPM *)
    IF Max_RPM_S  <= 0.0 THEN Max_RPM_S  := 3000.0; END_IF; (* Trục Dầu S:     Max 3000 RPM *)
    IF Max_RPM_T  <= 0.0 THEN Max_RPM_T  := 1500.0; END_IF; (* Trục Thu T:     Max 1500 RPM *)

    (* ---------------------------------------------------------------------------- *)
    (* 2. KHỞI TẠO TỶ SỐ TRUYỀN HỘP SỐ THỰC TẾ (GEAR RATIO - REAL)                *)
    (* ---------------------------------------------------------------------------- *)
    IF Gear_Ratio_T  <= 0.0 THEN Gear_Ratio_T  := 10.1; END_IF; (* Thu T:     10.1 : 1 (D620) *)
    IF Gear_Ratio_X1 <= 0.0 THEN Gear_Ratio_X1 := 8.0;  END_IF; (* Xả X1:     8.0  : 1 (D622) *)
    IF Gear_Ratio_X2 <= 0.0 THEN Gear_Ratio_X2 := 8.0;  END_IF; (* Master X2: 8.0  : 1 (D624) *)
    IF Gear_Ratio_Ms <= 0.0 THEN Gear_Ratio_Ms := 10.0; END_IF; (* Ghép Ms:   10.0 : 1 (D626) *)
    IF Gear_Ratio_S  <= 0.0 THEN Gear_Ratio_S  := 10.0; END_IF; (* Dầu S:     10.0 : 1 (D628) *)
    IF Gear_Ratio_U  <= 0.0 THEN Gear_Ratio_U  := 1.0;  END_IF; (* Xả U:      1.0  : 1 (D630) *)

    (* ---------------------------------------------------------------------------- *)
    (* 3. KHỞI TẠO ĐƯỜNG KÍNH LÔ CƠ CẤU (ROLLER DIAMETER - mm - REAL)              *)
    (* ---------------------------------------------------------------------------- *)
    IF Dia_X1_Roller_mm <= 0.0 THEN Dia_X1_Roller_mm := 300.5; END_IF; (* Lô Kéo X1:    300.5 mm (D638) *)
    IF Dia_X2_Roller_mm <= 0.0 THEN Dia_X2_Roller_mm := 300.5; END_IF; (* Lô Master X2: 300.5 mm (D642) *)
    IF Dia_Ms_Roller_mm <= 0.0 THEN Dia_Ms_Roller_mm := 200.0; END_IF; (* Lô Ghép Ms:   200.0 mm (D640) *)
    IF Dia_S_Roller_mm  <= 0.0 THEN Dia_S_Roller_mm  := 100.0; END_IF; (* Lô Dầu S:     100.0 mm (D648) *)

    (* ---------------------------------------------------------------------------- *)
    (* 4. KHỞI TẠO ĐƯỜNG KÍNH LÕI (CORE) VÀ ĐƯỜNG KÍNH MAX (MAX DIA) (mm - REAL)    *)
    (* ---------------------------------------------------------------------------- *)
    IF Core_Dia_T_mm <= 0.0 THEN Core_Dia_T_mm := 76.0;   END_IF; (* Lõi cuộn Thu T:  76.0 mm (D644) *)
    IF Core_Dia_M_mm <= 0.0 THEN Core_Dia_M_mm := 76.0;   END_IF; (* Lõi cuộn Xả M:   76.0 mm (D645) *)
    IF Core_Dia_U_mm <= 0.0 THEN Core_Dia_U_mm := 76.0;   END_IF; (* Lõi cuộn Xả U:   76.0 mm (D647) *)

    IF Max_Dia_T_mm  <= 0.0 THEN Max_Dia_T_mm  := 1000.0; END_IF; (* Cuộn Thu T max: 1000.0 mm (D646) *)
    IF Max_Dia_M_mm  <= 0.0 THEN Max_Dia_M_mm  := 600.0;  END_IF; (* Cuộn Xả M max:   600.0 mm (D649) *)
    IF Max_Dia_U_mm  <= 0.0 THEN Max_Dia_U_mm  := 800.0;  END_IF; (* Cuộn Xả U max:   800.0 mm (D650) *)

    (* ---------------------------------------------------------------------------- *)
    (* 5. KHỞI TẠO ĐƯỜNG KÍNH BAN ĐẦU KHI MỚI BẬT NGUỒN (REAL)                     *)
    (* ---------------------------------------------------------------------------- *)
    (* Cuộn Thu T bắt đầu từ Lõi *)
    IF Real_Dia_T_mm < Core_Dia_T_mm OR Real_Dia_T_mm > Max_Dia_T_mm THEN
        Real_Dia_T_mm := Core_Dia_T_mm; (* 76.0 mm - D724 *)
    END_IF;

    (* Cuộn Xả M & U bắt đầu từ cuộn đầy *)
    IF Real_Dia_M_mm < Core_Dia_M_mm OR Real_Dia_M_mm > Max_Dia_M_mm THEN
        Real_Dia_M_mm := Max_Dia_M_mm;  (* 600.0 mm - D722 *)
    END_IF;

    IF Real_Dia_U_mm < Core_Dia_U_mm OR Real_Dia_U_mm > Max_Dia_U_mm THEN
        Real_Dia_U_mm := Max_Dia_U_mm;  (* 800.0 mm - D720 *)
    END_IF;

    (* ---------------------------------------------------------------------------- *)
    (* 6. KHỞI TẠO TỶ LỆ TỐC ĐỘ VÀ BÙ TỐC (SPEED RATIO - REAL, 1.0 = 100%)         *)
    (* ---------------------------------------------------------------------------- *)
    IF Speed_Ratio_T  <= 0.0 THEN Speed_Ratio_T  := 1.05; END_IF; (* Chạy nhanh hơn 5% giữ căng (D756) *)
    IF Speed_Ratio_X1 <= 0.0 THEN Speed_Ratio_X1 := 1.00; END_IF; (* Đồng bộ 100.0% (D758) *)
    IF Speed_Ratio_Ms <= 0.0 THEN Speed_Ratio_Ms := 1.00; END_IF; (* Đồng bộ 100.0% (D762) *)
    IF Speed_Ratio_S  <= 0.0 THEN Speed_Ratio_S  := 1.00; END_IF; (* Đồng bộ 100.0% (D766) *)

    (* ---------------------------------------------------------------------------- *)
    (* 7. KHỞI TẠO GIỚI HẠN TỐC ĐỘ DÂY CHUYỀN (m/phút - REAL)                      *)
    (* ---------------------------------------------------------------------------- *)
    IF Max_Speed_MPM         <= 0.0 THEN Max_Speed_MPM         := 100.0; END_IF; (* Max 100.0 m/p (D602) *)
    IF Min_Speed_MPM         <= 0.0 THEN Min_Speed_MPM         := 2.0;   END_IF; (* Min 2.0 m/p (D603) *)
    IF Release_Pen_Speed_MPM <= 0.0 THEN Release_Pen_Speed_MPM := 2.0;   END_IF; (* Tốc độ nhả pen (D604) *)
    IF Ramp_Accel_Rate       <= 0.0 THEN Ramp_Accel_Rate       := 0.5;   END_IF; (* Gia tốc tăng tốc (D606) *)
    IF Ramp_Decel_Rate       <= 0.0 THEN Ramp_Decel_Rate       := 1.0;   END_IF; (* Gia tốc giảm tốc (D608) *)
    IF Decel_Distance_Meters <= 0.0 THEN Decel_Distance_Meters := 50.0;  END_IF; (* Khoảng cách hãm dừng (m) *)

    (* ---------------------------------------------------------------------------- *)
    (* 8. KHỞI TẠO CÀI ĐẶT LỰC CĂNG (TENSION SP - kg/N - REAL) & HỆ SỐ PID         *)
    (* ---------------------------------------------------------------------------- *)
    IF SP_Tension_T  <= 0.0 THEN SP_Tension_T  := 15.0; END_IF; (* SP Lực căng Thu T: 15.0 kg (D660) *)
    IF SP_Tension_X1 <= 0.0 THEN SP_Tension_X1 := 12.0; END_IF; (* SP Lực căng Xả X1: 12.0 kg (D662) *)
    IF SP_Tension_M  <= 0.0 THEN SP_Tension_M  := 10.0; END_IF; (* SP Lực căng Xả M:  10.0 kg (D664) *)
    IF SP_Tension_U  <= 0.0 THEN SP_Tension_U  := 10.0; END_IF; (* SP Lực căng Xả U:  10.0 kg (D668) *)

    (* Hệ số PID cuộn Thu T *)
    IF Kp_T <= 0.0 THEN Kp_T := 1.5; END_IF;
    IF Ki_T <= 0.0 THEN Ki_T := 0.2; END_IF;
    IF Kd_T <= 0.0 THEN Kd_T := 0.1; END_IF;

    (* Hệ số PID cuộn Xả X1 *)
    IF Kp_X1 <= 0.0 THEN Kp_X1 := 1.2; END_IF;
    IF Ki_X1 <= 0.0 THEN Ki_X1 := 0.15; END_IF;
    IF Kd_X1 <= 0.0 THEN Kd_X1 := 0.08; END_IF;

    (* Hệ số PID cuộn Xả M *)
    IF Kp_M <= 0.0 THEN Kp_M := 1.0; END_IF;
    IF Ki_M <= 0.0 THEN Ki_M := 0.1; END_IF;
    IF Kd_M <= 0.0 THEN Kd_M := 0.05; END_IF;

    (* Hệ số PID cuộn Xả U *)
    IF Kp_U <= 0.0 THEN Kp_U := 1.0; END_IF;
    IF Ki_U <= 0.0 THEN Ki_U := 0.1; END_IF;
    IF Kd_U <= 0.0 THEN Kd_U := 0.05; END_IF;

    (* ---------------------------------------------------------------------------- *)
    (* 9. KHỞI TẠO TORQUE HÃM MIN / MAX VÀ GIỮ DỪNG MÁY (% - REAL)                 *)
    (* ---------------------------------------------------------------------------- *)
    IF Min_Torque_M          <= 0.0 THEN Min_Torque_M          := 4.0;  END_IF; (* 4.0 % *)
    IF Max_Torque_M          <= 0.0 THEN Max_Torque_M          := 20.0; END_IF; (* 20.0 % *)
    IF Init_Holding_Torque_M <= 0.0 THEN Init_Holding_Torque_M := 8.0;  END_IF; (* 8.0 % *)

    IF Min_Torque_U          <= 0.0 THEN Min_Torque_U          := 5.0;  END_IF; (* 5.0 % *)
    IF Max_Torque_U          <= 0.0 THEN Max_Torque_U          := 25.0; END_IF; (* 25.0 % *)
    IF Init_Holding_Torque_U <= 0.0 THEN Init_Holding_Torque_U := 10.0; END_IF; (* 10.0 % *)

    (* ---------------------------------------------------------------------------- *)
    (* 10. KHỞI TẠO HỆ SỐ GAIN CALIB LOADCELL (REAL)                                *)
    (* ---------------------------------------------------------------------------- *)
    IF Calib_Gain_T  <= 0.0 THEN Calib_Gain_T  := 1.0; END_IF;
    IF Calib_Gain_X1 <= 0.0 THEN Calib_Gain_X1 := 1.0; END_IF;
    IF Calib_Gain_M  <= 0.0 THEN Calib_Gain_M  := 1.0; END_IF;
    IF Calib_Gain_U  <= 0.0 THEN Calib_Gain_U  := 1.0; END_IF;

END_IF;
