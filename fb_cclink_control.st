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

    (* 1. Kiểm tra trạng thái mạng CC-Link & Ghi 1 lần tránh cảnh báo C9300 *)
    CCLink_OK := SB0020;
    HasError  := NOT(SB0020) OR M1032 OR M1066;

    M1208 := SB0020;  (* RY8: AD Conversion Enable *)
    M1240 := SB0020;  (* RY28: DA Conversion Enable *)

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
    D524 := INT_TO_WORD(WORD_TO_INT(DAC_CH1_Set) * 4000 / 1000);
    D525 := INT_TO_WORD(WORD_TO_INT(DAC_CH2_Set) * 4000 / 1000);
    D526 := INT_TO_WORD(WORD_TO_INT(DAC_CH3_Set) * 4000 / 1000);
    D527 := INT_TO_WORD(WORD_TO_INT(DAC_CH4_Set) * 4000 / 1000);
    D528 := INT_TO_WORD(WORD_TO_INT(DAC_CH5_Set) * 4000 / 1000);
    D529 := INT_TO_WORD(WORD_TO_INT(DAC_CH6_Set) * 4000 / 1000);
    D530 := INT_TO_WORD(WORD_TO_INT(DAC_CH7_Set) * 4000 / 1000);
    D531 := INT_TO_WORD(WORD_TO_INT(DAC_CH8_Set) * 4000 / 1000);

    (* 4. Xử lý Digital Remote I/O (AJ65SBT-16DT) *)
    DI_X0_State := M1104;
    DI_X1_State := M1105;

    M1296 := DO_Y0_Cmd AND SB0020;
    M1297 := DO_Y1_Cmd AND SB0020;
    M1303 := HasError;

    (* 5. Reset lỗi (Ghi 1 lần tránh cảnh báo C9300) *)
    M1226 := ResetErr OR M1111; (* RY1A: Reset lỗi AJ65SBT-64AD *)
    M1258 := ResetErr OR M1111; (* RY3A: Reset lỗi AJ65VBTCU-68DAVN *)

END_IF;
