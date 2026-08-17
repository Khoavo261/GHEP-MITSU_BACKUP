(******************************************************************************)
(* PHẦN 1: KHAI BÁO CÁC NHÃN TRONG CỬA SỔ LOCAL LABEL CỦA FB                 *)
(******************************************************************************)
(*
--- BẢNG VAR_INPUT (Class: VAR_INPUT) ---
Label Name      Data Type   Initial Value   Comment
Enable          BOOL        TRUE            Cho phép khối FB hoạt động
ResetErr        BOOL        FALSE           Nút reset lỗi hệ thống
DAC_CH1_Set     WORD        0               Cài đặt DAC CH1 (0..1000 = 0..100.0%)
DAC_CH2_Set     WORD        0               Cài đặt DAC CH2 (0..1000 = 0..100.0%)
DAC_CH3_Set     WORD        0               Cài đặt DAC CH3 (0..1000 = 0..100.0%)
DAC_CH4_Set     WORD        0               Cài đặt DAC CH4 (0..1000 = 0..100.0%)
DAC_CH5_Set     WORD        0               Cài đặt DAC CH5 (0..1000 = 0..100.0%)
DAC_CH6_Set     WORD        0               Cài đặt DAC CH6 (0..1000 = 0..100.0%)
DAC_CH7_Set     WORD        0               Cài đặt DAC CH7 (0..1000 = 0..100.0%)
DAC_CH8_Set     WORD        0               Cài đặt DAC CH8 (0..1000 = 0..100.0%)
DO_Y0_Cmd       BOOL        FALSE           Lệnh ngõ ra Y0 St 4 (M1296)
DO_Y1_Cmd       BOOL        FALSE           Lệnh ngõ ra Y1 St 4 (M1297)

--- BẢNG VAR_OUTPUT (Class: VAR_OUTPUT) ---
Label Name      Data Type   Initial Value   Comment
CCLink_OK       BOOL        FALSE           Trạng thái mạng CC-Link OK
HasError        BOOL        FALSE           Báo lỗi tổng truyền thông/module
ADC_CH1_Val     WORD        0               Giá trị % ADC CH1 (0..1000)
ADC_CH2_Val     WORD        0               Giá trị % ADC CH2 (0..1000)
ADC_CH3_Val     WORD        0               Giá trị % ADC CH3 (0..1000)
ADC_CH4_Val     WORD        0               Giá trị % ADC CH4 (0..1000)
ADC_CH1_Raw     WORD        0               Giá trị thô D500 ADC CH1 (0..4000)
ADC_CH2_Raw     WORD        0               Giá trị thô D501 ADC CH2 (0..4000)
ADC_CH3_Raw     WORD        0               Giá trị thô D502 ADC CH3 (0..4000)
ADC_CH4_Raw     WORD        0               Giá trị thô D503 ADC CH4 (0..4000)
DI_X0_State     BOOL        FALSE           Trạng thái ngõ vào X0 St 4 (M1104)
DI_X1_State     BOOL        FALSE           Trạng thái ngõ vào X1 St 4 (M1105)
*)

(******************************************************************************)
(* PHẦN 2: MÃ ST CHÍNH (COPY DÁN VÀO KHUNG CHƯƠNG TRÌNH ST CỦA FB)            *)
(******************************************************************************)

IF Enable THEN

    (* 1. Kiểm tra trạng thái mạng CC-Link (SB0020=0 và SB0049=0 là mạng bình thường) *)
    CCLink_OK := (NOT SB0020) AND (NOT SB0049);
    HasError  := SB0020 OR SB0049 OR M1032 OR M1066;

    M1208 := CCLink_OK;  (* RY8: AD Conversion Enable *)
    M1240 := CCLink_OK;  (* RY28: DA Conversion Enable *)

    (* 2. Đọc 4 kênh Analog Input (AJ65SBT-64AD) *)
    IF M1016 THEN (* RX8: AD Conversion Completed *)
        ADC_CH1_Raw := D500;
        ADC_CH2_Raw := D501;
        ADC_CH3_Raw := D502;
        ADC_CH4_Raw := D503;

        (* Quy đổi sang 0..1000 (0.0% .. 100.0%) *)
        ADC_CH1_Val := INT_TO_WORD(WORD_TO_INT(D500) * 1000 / 4000);
        ADC_CH2_Val := INT_TO_WORD(WORD_TO_INT(D501) * 1000 / 4000);
        ADC_CH3_Val := INT_TO_WORD(WORD_TO_INT(D502) * 1000 / 4000);
        ADC_CH4_Val := INT_TO_WORD(WORD_TO_INT(D503) * 1000 / 4000);
    END_IF;

    (* 3. Ghi 8 kênh Analog Output (AJ65VBTCU-68DAVN) *)
    (* Quy đổi lệnh 0..1000 sang dải DAC 0..4000 *)
    D524 := INT_TO_WORD(WORD_TO_INT(Set_Speed_T)  * 4000 / 1000);
    D525 := INT_TO_WORD(WORD_TO_INT(Set_Torque_T) * 4000 / 1000);
    D526 := INT_TO_WORD(WORD_TO_INT(Set_Speed_X1) * 4000 / 1000);
    D527 := INT_TO_WORD(WORD_TO_INT(Set_Speed_X2) * 4000 / 1000);
    D528 := INT_TO_WORD(WORD_TO_INT(Set_Speed_Ms) * 4000 / 1000);
    D529 := INT_TO_WORD(WORD_TO_INT(Set_Torque_M) * 4000 / 1000);
    D530 := INT_TO_WORD(WORD_TO_INT(Set_Speed_S)  * 4000 / 1000);
    D531 := INT_TO_WORD(WORD_TO_INT(Set_Speed_U)  * 4000 / 1000);

    (* 4. XỬ LÝ DIGITAL REMOTE I/O (AJ65SBTB1-16DT: X0..X7 = M1104..M1111 | Y8..YF = M1304..M1311) *)
    DI_X0_State := M1104;
    DI_X1_State := M1105;

    (* Ngõ ra Y8..YF (M1304..M1311) để HMI / User tự set ON/OFF trực tiếp *)

    (* 5. Reset lỗi (Ghi 1 lần tránh cảnh báo C9300) *)
    M1226 := ResetErr OR M1111; (* RY1A: Reset lỗi AJ65SBT-64AD *)
    M1258 := ResetErr OR M1111; (* RY3A: Reset lỗi AJ65VBTCU-68DAVN *)

END_IF;
