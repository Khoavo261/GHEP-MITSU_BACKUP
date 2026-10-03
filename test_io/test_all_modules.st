(* ============================================================================ *)
(* TÊN CHƯƠNG TRÌNH: TEST_ALL_MODULES (CHƯƠNG TRÌNH TEST TỔNG HỢP TOÀN BỘ RACK) *)
(* HỆ THỐNG: MÁY GHÉP MÀNG METALIZE - MITSUBISHI Q-SERIES PLC                  *)
(* THỨ TỰ CÁC MODULE KIỂM TRA THEO ĐÚNG CẤU HÌNH PHẦN CỨNG:                     *)
(*   1. SLOT 0 (H00): Q68ADV (8CH Analog Input 0..10V)                          *)
(*   2. SLOT 1 (H10): Q68DAV (8CH Analog Output 0..10V)                         *)
(*   3. SLOT 2 (H20): QD62D #1 (2CH High Speed Counter: CH1 Thu T, CH2 Kéo X1)  *)
(*   4. SLOT 3 (H30): QD62D #2 (2CH High Speed Counter: CH1 Master X2, CH2 Ms) *)
(*   5. SLOT 4 (H40): QX40   (16CH Digital Input: X40..X4F)                     *)
(*   6. SLOT 5 (H50): QY10   (16CH Digital Output: Y50..Y5F)                    *)
(* ============================================================================ *)

(* ============================================================================ *)
(* PHẦN 1. KIỂM TRA MODULE 1: Q68ADV (SLOT 0 - HEAD H00)                       *)
(* ============================================================================ *)
IF SM402 THEN
    U0\G0  := 16#0000; (* Cho phép A/D cả 8 kênh *)
    U0\G9  := 16#3333; (* Lọc trung bình CH1..CH4 *)
    U0\G10 := 16#3333; (* Lọc trung bình CH5..CH8 *)
    U0\G11 := 16; U0\G12 := 16; U0\G13 := 16; U0\G14 := 16;
    U0\G15 := 16; U0\G16 := 16; U0\G17 := 16; U0\G18 := 16;
END_IF;

(* Đọc Raw 0..16000 *)
D2000 := U0\G1; D2001 := U0\G2; D2002 := U0\G3; D2003 := U0\G4;
D2004 := U0\G5; D2005 := U0\G6; D2006 := U0\G7; D2007 := U0\G8;

(* Quy đổi Volt Float (0.00..10.00 V) *)
Test_Volt_CH1 := (INT_TO_REAL(D2000) * 10.0) / 16000.0;
Test_Volt_CH2 := (INT_TO_REAL(D2001) * 10.0) / 16000.0;
Test_Volt_CH3 := (INT_TO_REAL(D2002) * 10.0) / 16000.0;
Test_Volt_CH4 := (INT_TO_REAL(D2003) * 10.0) / 16000.0;
Test_Volt_CH5 := (INT_TO_REAL(D2004) * 10.0) / 16000.0;
Test_Volt_CH6 := (INT_TO_REAL(D2005) * 10.0) / 16000.0;
Test_Volt_CH7 := (INT_TO_REAL(D2006) * 10.0) / 16000.0;
Test_Volt_CH8 := (INT_TO_REAL(D2007) * 10.0) / 16000.0;

M1001 := X00; M1002 := X0E; D2024 := U0\G19;
Y0E := M1000;
IF Y0E AND NOT X0E THEN M1000 := FALSE; END_IF;

(* ============================================================================ *)
(* PHẦN 2. KIỂM TRA MODULE 2: Q68DAV (SLOT 1 - HEAD H10)                       *)
(* ============================================================================ *)
IF SM402 THEN
    U1\G0 := 16#0000; (* Cho phép D/A cả 8 kênh *)
    U1\G9 := 16#00FF; (* Cho phép xuất áp cả 8 kênh *)
    D2038 := 500;
END_IF;

Y11 := TRUE; (* Cho phép chuyển đổi D/A *)

(* Phím tắt xuất nhanh *)
IF M1020 THEN (* 0V *)
    D2030 := 0; D2031 := 0; D2032 := 0; D2033 := 0;
    D2034 := 0; D2035 := 0; D2036 := 0; D2037 := 0;
    M1020 := FALSE;
END_IF;
IF M1021 THEN (* 2.5V *)
    D2030 := 4000; D2031 := 4000; D2032 := 4000; D2033 := 4000;
    D2034 := 4000; D2035 := 4000; D2036 := 4000; D2037 := 4000;
    M1021 := FALSE;
END_IF;
IF M1022 THEN (* 5.0V *)
    D2030 := 8000; D2031 := 8000; D2032 := 8000; D2033 := 8000;
    D2034 := 8000; D2035 := 8000; D2036 := 8000; D2037 := 8000;
    M1022 := FALSE;
END_IF;
IF M1023 THEN (* 10.0V *)
    D2030 := 16000; D2031 := 16000; D2032 := 16000; D2033 := 16000;
    D2034 := 16000; D2035 := 16000; D2036 := 16000; D2037 := 16000;
    M1023 := FALSE;
END_IF;

(* Quét tự động hình tam giác *)
IF M1024 THEN
    IF D2038 <= 0 THEN D2038 := 500; END_IF;
    IF SM412 THEN
        IF NOT M1025 THEN
            D2039 := D2039 + D2038;
            IF D2039 >= 16000 THEN D2039 := 16000; M1025 := TRUE; END_IF;
        ELSE
            D2039 := D2039 - D2038;
            IF D2039 <= 0 THEN D2039 := 0; M1025 := FALSE; END_IF;
        END_IF;
        D2030 := D2039; D2031 := D2039; D2032 := D2039; D2033 := D2039;
        D2034 := D2039; D2035 := D2039; D2036 := D2039; D2037 := D2039;
    END_IF;
END_IF;

(* Giới hạn an toàn & Xuất ra Buffer *)
IF D2030 < 0 THEN D2030 := 0; ELSIF D2030 > 16000 THEN D2030 := 16000; END_IF;
IF D2031 < 0 THEN D2031 := 0; ELSIF D2031 > 16000 THEN D2031 := 16000; END_IF;
IF D2032 < 0 THEN D2032 := 0; ELSIF D2032 > 16000 THEN D2032 := 16000; END_IF;
IF D2033 < 0 THEN D2033 := 0; ELSIF D2033 > 16000 THEN D2033 := 16000; END_IF;
IF D2034 < 0 THEN D2034 := 0; ELSIF D2034 > 16000 THEN D2034 := 16000; END_IF;
IF D2035 < 0 THEN D2035 := 0; ELSIF D2035 > 16000 THEN D2035 := 16000; END_IF;
IF D2036 < 0 THEN D2036 := 0; ELSIF D2036 > 16000 THEN D2036 := 16000; END_IF;
IF D2037 < 0 THEN D2037 := 0; ELSIF D2037 > 16000 THEN D2037 := 16000; END_IF;

U1\G1 := D2030; U1\G2 := D2031; U1\G3 := D2032; U1\G4 := D2033;
U1\G5 := D2034; U1\G6 := D2035; U1\G7 := D2036; U1\G8 := D2037;

M1026 := X10; M1027 := X1E; D2046 := U1\G19;
Y1E := M1028;
IF Y1E AND NOT X1E THEN M1028 := FALSE; END_IF;

(* ============================================================================ *)
(* PHẦN 3. KIỂM TRA MODULE 3: QD62D #1 (SLOT 2 - HEAD H20 - TRỤC T & X1)       *)
(* ============================================================================ *)
IF SM402 THEN M1042 := TRUE; M1043 := TRUE; END_IF;
Y21 := M1042; Y29 := M1043;

DMOV(TRUE, U2\G2,  Test_Pulse_T);
DMOV(TRUE, U2\G10, Test_Pulse_X1);

IF M1040 THEN
    U2\G0 := 0; U2\G1 := 0; Y22 := TRUE;
    IF NOT SM400 THEN Y22 := FALSE; END_IF;
    M1040 := FALSE;
ELSE
    Y22 := FALSE;
END_IF;

IF M1041 THEN
    U2\G8 := 0; U2\G9 := 0; Y2A := TRUE;
    IF NOT SM400 THEN Y2A := FALSE; END_IF;
    M1041 := FALSE;
ELSE
    Y2A := FALSE;
END_IF;

IF SM412 THEN
    Test_Delta_T  := Test_Pulse_T - Test_Last_Pulse_T;
    Test_Delta_X1 := Test_Pulse_X1 - Test_Last_Pulse_X1;
    Test_Last_Pulse_T  := Test_Pulse_T;
    Test_Last_Pulse_X1 := Test_Pulse_X1;
END_IF;

M1044 := X20; M1045 := X24; M1046 := X2C;

(* ============================================================================ *)
(* PHẦN 4. KIỂM TRA MODULE 4: QD62D #2 (SLOT 3 - HEAD H30 - TRỤC X2 & MS)       *)
(* ============================================================================ *)
IF SM402 THEN M1062 := TRUE; M1063 := TRUE; END_IF;
Y31 := M1062; Y39 := M1063;

DMOV(TRUE, U3\G2,  Test_Pulse_X2);
DMOV(TRUE, U3\G10, Test_Pulse_Ms);

IF M1060 THEN
    U3\G0 := 0; U3\G1 := 0; Y32 := TRUE;
    IF NOT SM400 THEN Y32 := FALSE; END_IF;
    M1060 := FALSE;
ELSE
    Y32 := FALSE;
END_IF;

IF M1061 THEN
    U3\G8 := 0; U3\G9 := 0; Y3A := TRUE;
    IF NOT SM400 THEN Y3A := FALSE; END_IF;
    M1061 := FALSE;
ELSE
    Y3A := FALSE;
END_IF;

IF SM412 THEN
    Test_Delta_X2 := Test_Pulse_X2 - Test_Last_Pulse_X2;
    Test_Delta_Ms := Test_Pulse_Ms - Test_Last_Pulse_Ms;
    Test_Last_Pulse_X2 := Test_Pulse_X2;
    Test_Last_Pulse_Ms := Test_Pulse_Ms;
END_IF;

M1064 := X30; M1065 := X34; M1066 := X3C;

(* ============================================================================ *)
(* PHẦN 5. KIỂM TRA MODULE 5: QX40 (SLOT 4 - HEAD H40 - 16 NGÕ VÀO X40..X4F)    *)
(* ============================================================================ *)
M1080 := X40; M1081 := X41; M1082 := X42; M1083 := X43;
M1084 := X44; M1085 := X45; M1086 := X46; M1087 := X47;
M1088 := X48; M1089 := X49; M1090 := X4A; M1091 := X4B;
M1092 := X4C; M1093 := X4D; M1094 := X4E; M1095 := X4F;

D2120.0 := X40; D2120.1 := X41; D2120.2 := X42; D2120.3 := X43;
D2120.4 := X44; D2120.5 := X45; D2120.6 := X46; D2120.7 := X47;
D2120.8 := X48; D2120.9 := X49; D2120.A := X4A; D2120.B := X4B;
D2120.C := X4C; D2120.D := X4D; D2120.E := X4E; D2120.F := X4F;

IF X40 AND NOT M1080_Old THEN D2100 := D2100 + 1; END_IF; M1080_Old := X40;
IF X41 AND NOT M1081_Old THEN D2101 := D2101 + 1; END_IF; M1081_Old := X41;
IF X42 AND NOT M1082_Old THEN D2102 := D2102 + 1; END_IF; M1082_Old := X42;
IF X43 AND NOT M1083_Old THEN D2103 := D2103 + 1; END_IF; M1083_Old := X43;
IF X44 AND NOT M1084_Old THEN D2104 := D2104 + 1; END_IF; M1084_Old := X44;
IF X45 AND NOT M1085_Old THEN D2105 := D2105 + 1; END_IF; M1085_Old := X45;
IF X46 AND NOT M1086_Old THEN D2106 := D2106 + 1; END_IF; M1086_Old := X46;
IF X47 AND NOT M1087_Old THEN D2107 := D2107 + 1; END_IF; M1087_Old := X47;
IF X48 AND NOT M1088_Old THEN D2108 := D2108 + 1; END_IF; M1088_Old := X48;
IF X49 AND NOT M1089_Old THEN D2109 := D2109 + 1; END_IF; M1089_Old := X49;
IF X4A AND NOT M1090_Old THEN D2110 := D2110 + 1; END_IF; M1090_Old := X4A;
IF X4B AND NOT M1091_Old THEN D2111 := D2111 + 1; END_IF; M1091_Old := X4B;
IF X4C AND NOT M1092_Old THEN D2112 := D2112 + 1; END_IF; M1092_Old := X4C;
IF X4D AND NOT M1093_Old THEN D2113 := D2113 + 1; END_IF; M1093_Old := X4D;
IF X4E AND NOT M1094_Old THEN D2114 := D2114 + 1; END_IF; M1094_Old := X4E;
IF X4F AND NOT M1095_Old THEN D2115 := D2115 + 1; END_IF; M1095_Old := X4F;

IF M1099 THEN
    D2100 := 0; D2101 := 0; D2102 := 0; D2103 := 0;
    D2104 := 0; D2105 := 0; D2106 := 0; D2107 := 0;
    D2108 := 0; D2109 := 0; D2110 := 0; D2111 := 0;
    D2112 := 0; D2113 := 0; D2114 := 0; D2115 := 0;
    M1099 := FALSE;
END_IF;

(* ============================================================================ *)
(* PHẦN 6. KIỂM TRA MODULE 6: QY10 (SLOT 5 - HEAD H50 - 16 NGÕ RA Y50..Y5F)     *)
(* ============================================================================ *)
IF SM402 THEN D2131 := 5; END_IF;

IF M1117 THEN
    M1100 := TRUE; M1101 := TRUE; M1102 := TRUE; M1103 := TRUE;
    M1104 := TRUE; M1105 := TRUE; M1106 := TRUE; M1107 := TRUE;
    M1108 := TRUE; M1109 := TRUE; M1110 := TRUE; M1111 := TRUE;
    M1112 := TRUE; M1113 := TRUE; M1114 := TRUE; M1115 := TRUE;
    M1117 := FALSE;
END_IF;

IF M1118 THEN
    M1100 := FALSE; M1101 := FALSE; M1102 := FALSE; M1103 := FALSE;
    M1104 := FALSE; M1105 := FALSE; M1106 := FALSE; M1107 := FALSE;
    M1108 := FALSE; M1109 := FALSE; M1110 := FALSE; M1111 := FALSE;
    M1112 := FALSE; M1113 := FALSE; M1114 := FALSE; M1115 := FALSE;
    M1118 := FALSE;
END_IF;

IF M1116 THEN
    IF D2131 < 1 THEN D2131 := 5; END_IF;
    OUT_T(NOT TS100, T100, D2131);
    IF TS100 THEN
        D2130 := D2130 + 1;
        IF D2130 > 15 THEN D2130 := 0; END_IF;
    END_IF;
ELSE
    D2130 := 0;
END_IF;

Y50 := (NOT M1116 AND M1100) OR (M1116 AND (D2130 = 0));
Y51 := (NOT M1116 AND M1101) OR (M1116 AND (D2130 = 1));
Y52 := (NOT M1116 AND M1102) OR (M1116 AND (D2130 = 2));
Y53 := (NOT M1116 AND M1103) OR (M1116 AND (D2130 = 3));
Y54 := (NOT M1116 AND M1104) OR (M1116 AND (D2130 = 4));
Y55 := (NOT M1116 AND M1105) OR (M1116 AND (D2130 = 5));
Y56 := (NOT M1116 AND M1106) OR (M1116 AND (D2130 = 6));
Y57 := (NOT M1116 AND M1107) OR (M1116 AND (D2130 = 7));
Y58 := (NOT M1116 AND M1108) OR (M1116 AND (D2130 = 8));
Y59 := (NOT M1116 AND M1109) OR (M1116 AND (D2130 = 9));
Y5A := (NOT M1116 AND M1110) OR (M1116 AND (D2130 = 10));
Y5B := (NOT M1116 AND M1111) OR (M1116 AND (D2130 = 11));
Y5C := (NOT M1116 AND M1112) OR (M1116 AND (D2130 = 12));
Y5D := (NOT M1116 AND M1113) OR (M1116 AND (D2130 = 13));
Y5E := (NOT M1116 AND M1114) OR (M1116 AND (D2130 = 14));
Y5F := (NOT M1116 AND M1115) OR (M1116 AND (D2130 = 15));

D2132.0 := Y50; D2132.1 := Y51; D2132.2 := Y52; D2132.3 := Y53;
D2132.4 := Y54; D2132.5 := Y55; D2132.6 := Y56; D2132.7 := Y57;
D2132.8 := Y58; D2132.9 := Y59; D2132.A := Y5A; D2132.B := Y5B;
D2132.C := Y5C; D2132.D := Y5D; D2132.E := Y5E; D2132.F := Y5F;
