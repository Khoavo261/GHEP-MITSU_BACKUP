(* ============================================================================ *)
(* TÊN CHƯƠNG TRÌNH : POU_INT_I52 (INTERRUPT PROGRAM I52)                       *)
(* TÁC VỤ           : TÍNH ĐƯỜNG KÍNH CUỘN XẢ GIẤY U TỨC THỜI MỖI VÒNG QUAY        *)
(* NGUỒN NGẮT       : CẢM BIẾN U (NPN) ĐẤU VÀO CHÂN B08 (2FUNC) CỦA QD62 SLOT 1   *)
(* CẤU HÌNH GXW2    : Program Type = Wait (Standby), Task Event = I52            *)
(* ============================================================================ *)

(* 1. Tang bo dem tong so vong quay cua cuon Xa U *)
Rev_Count_U := Rev_Count_U + 1;

(* 2. Doc xung tuc thoi cua truc Master X2 truc tiep tu Buffer Memory Slot 3 CH1 *)
DMOV(TRUE, U3\G2, Curr_Pulse_X2_Now);

(* 3. Tinh luong xung lo Master X2 da quay duoc trong dung 1 vong xa cua cuon U *)
Delta_Pulse_U := Curr_Pulse_X2_Now - Last_Pulse_X2_U;

(* 4. Tinh toan duong kinh thuc te cuon U khi may dang chay *)
IF (State_Machine = 1) AND (Delta_Pulse_U > 0) AND (Total_PPR > 0) AND (Gear_Ratio_X2 > 0.0) THEN

    Raw_Dia_U_mm := (DINT_TO_REAL(Delta_Pulse_U) * Dia_X2_Roller_mm * Gear_Ratio_U) 
                    / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);

    IF Raw_Dia_U_mm < Core_Dia_U_mm THEN 
        Raw_Dia_U_mm := Core_Dia_U_mm; 
    END_IF;
    IF Raw_Dia_U_mm > Max_Dia_U_mm THEN 
        Raw_Dia_U_mm := Max_Dia_U_mm; 
    END_IF;

    Real_Dia_U_mm := Real_Dia_U_mm + ((Raw_Dia_U_mm - Real_Dia_U_mm) * 0.2);

END_IF;

(* 5. Cap nhat moc xung chuan bi cho vong quay ke tiep *)
Last_Pulse_X2_U := Curr_Pulse_X2_Now;
