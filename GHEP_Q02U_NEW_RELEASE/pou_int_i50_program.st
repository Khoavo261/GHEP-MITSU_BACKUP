(* ============================================================================ *)
(* TÊN CHƯƠNG TRÌNH : POU_INT_I50 (INTERRUPT PROGRAM I50)                       *)
(* TÁC VỤ           : TÍNH ĐƯỜNG KÍNH CUỘN XẢ METALIZE M TỨC THỜI MỖI VÒNG QUAY  *)
(* NGUỒN NGẮT       : CẢM BIẾN M (NPN) ĐẤU VÀO CHÂN B10 (2PRST) CỦA QD62 SLOT 1   *)
(* CẤU HÌNH GXW2    : Program Type = Wait (Standby), Task Event = I50            *)
(* ============================================================================ *)

(* 1. Tang bo dem tong so vong quay cua cuon Xa M *)
Rev_Count_M := Rev_Count_M + 1;

(* 2. Doc xung tuc thoi cua truc Master X2 truc tiep tu Buffer Memory Slot 3 CH1 *)
DMOV(TRUE, U3\G2, Curr_Pulse_X2_Now);

(* 3. Tinh luong xung lo Master X2 da quay duoc trong dung 1 vong xa cua cuon M *)
Delta_Pulse_M := Curr_Pulse_X2_Now - Last_Pulse_X2_M;

(* 4. Tinh toan duong kinh thuc te cuon M khi may dang chay *)
IF (State_Machine = 1) AND (Delta_Pulse_M > 0) AND (Total_PPR > 0) AND (Gear_Ratio_X2 > 0.0) THEN

    Raw_Dia_M_mm := (DINT_TO_REAL(Delta_Pulse_M) * Dia_X2_Roller_mm * Gear_Ratio_M) 
                    / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);

    IF Raw_Dia_M_mm < Core_Dia_M_mm THEN 
        Raw_Dia_M_mm := Core_Dia_M_mm; 
    END_IF;
    IF Raw_Dia_M_mm > Max_Dia_M_mm THEN 
        Raw_Dia_M_mm := Max_Dia_M_mm; 
    END_IF;

    Real_Dia_M_mm := Real_Dia_M_mm + ((Raw_Dia_M_mm - Real_Dia_M_mm) * 0.2);

END_IF;

(* 5. Cap nhat moc xung chuan bi cho vong quay ke tiep *)
Last_Pulse_X2_M := Curr_Pulse_X2_Now;
