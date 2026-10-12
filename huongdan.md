# 🔌 HƯỚNG DẪN CẤU HÌNH & ĐẤU DÂY MODULE ĐẾM XUNG CAO TỐC QD62D (SLOT 2 & SLOT 3)

**Dự án:** Hệ thống Điều Khiển Dây Chuyền Máy Ghép Màng Metalize Tự Động  
**PLC:** Mitsubishi **Q02UCPU**  
**Module:** 02 Module **QD62D** (Differential Line Driver Input - Chuẩn vi sai EIA RS-422-A)  
- **QD62D #1 (Slot 2 - Head I/O `H0020`):** Kênh 1 đọc **Trục Thu T**, Kênh 2 đọc **Trục Kéo X1**  
- **QD62D #2 (Slot 3 - Head I/O `H0030`):** Kênh 1 đọc **Trục Master X2**, Kênh 2 đọc **Trục Ghép Ms**  
**Đầu nối:** Jack cắm **40-Pin Connector** (A6CON1 / A6CON2 hoặc Domino chuyển đổi FA-TBS40P / FTB-40Q)

---

## 📌 1. CẤU HÌNH SWITCH SETTING TRONG GX WORKS2 (PLC PARAMETER)

Để module QD62D đếm xung 4X và kích hoạt tính năng **Latch Counter** (dùng xung Pha Z chốt số xung/vòng mà không ảnh hưởng đến bộ đếm tốc độ), bạn cần cài đặt thông số Switch trong phần mềm GX Works2:

### Các bước thực hiện trên phần mềm GX Works2:
1. Mở dự án trong GX Works2 $\rightarrow$ Cây thư mục bên trái mở **`Parameter`** $\rightarrow$ Click đúp vào **`PLC Parameter`**.
2. Chọn tab **`I/O Assignment`**.
3. Tại dòng **Slot 2** (Head `0020`) và **Slot 3** (Head `0030`), bấm nút **`Switch Setting`**.

### Bảng Giá Trị Cài Đặt Chi Tiết:

| Vị trí Switch | Tên Tham Số | Giá Trị Cài Đặt (Hex) | Ý Nghĩa Kỹ Thuật |
| :--- | :--- | :---: | :--- |
| **Switch 1** | **CH1 Pulse Input Mode** | **`0003`** | **2-Phase 4-Multiple (Nhân 4 xung vi sai A/B)** giúp tăng độ phân giải lên gấp 4 lần. |
| **Switch 2** | **CH2 Pulse Input Mode** | **`0003`** | **2-Phase 4-Multiple (Nhân 4 xung vi sai A/B)** cho kênh 2. |
| **Switch 3** | **CH1 Counter Function Selection** | **`0001`** | **Latch Counter Function**: Khi có cạnh lên từ chân Pha Z (Function Start Input), module chốt giá trị PV vào ô nhớ Latch (`G12..G13`). |
| **Switch 4** | **CH2 Counter Function Selection** | **`0001`** | **Latch Counter Function**: Tương tự cho CH2, chốt giá trị PV vào ô nhớ Latch (`G44..G45`). |
| **Switch 5** | **Preset Mode / Coincidence Output** | **`0000`** | Mặc định (Internal preset & Normal coincidence). |

> [!IMPORTANT]
> Sau khi nhập xong giá trị Switch Setting, bấm **End** $\rightarrow$ nạp Parameter xuống CPU PLC (**Online $\rightarrow$ Write to PLC**) và **Tắt/Bật lại nguồn PLC (hoặc gạt Reset CPU)** để module nạp cấu hình mới.

---

## 📌 2. BẢNG SƠ ĐỒ CHÂN 40-PIN CONNECTOR (PINOUT MAP)

Module QD62D sử dụng giắc cắm 40 chân chia làm 2 hàng: **Hàng A (A01 .. A20)** và **Hàng B (B01 .. B20)**.

```
       [ NHÌN TỪ MẶT TRƯỚC JACK CẮM MODULE QD62D ]
      ┌────────────────────────┬────────────────────────┐
      │  HÀNG B (B01 .. B20)   │  HÀNG A (A01 .. A20)   │
      │  [B01]  ...  [B20]     │  [A01]  ...  [A20]     │
      └────────────────────────┴────────────────────────┘
```

### 📋 Bảng Chi Tiết Toàn Bộ 40 Chân (Chuẩn Mitsubishi SH-080036):

| Chân Hàng A | Ký Hiệu | Chức Năng | Chân Hàng B | Ký Hiệu | Chức Năng |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **A20** | **1A-** | **CH1 - Xung Pha A (-)** Line Driver | **B20** | **1A+** | **CH1 - Xung Pha A (+)** Line Driver |
| **A19** | **1B-** | **CH1 - Xung Pha B (-)** Line Driver | **B19** | **1B+** | **CH1 - Xung Pha B (+)** Line Driver |
| **A18** | 1PRST 24V | CH1 Ngõ vào Preset 24V DC | **B18** | 1PRST 12V | CH1 Ngõ vào Preset 12V DC |
| **A17** | 1PRST 5V | CH1 Ngõ vào Preset 5V DC | **B17** | 1PRSTCOM | CH1 Common âm Preset (0V) |
| **A16** | **1FUNC 24V**| **CH1 Latch Pha Z (24V DC)** | **B16** | 1FUNC 12V | CH1 Function Start 12V DC |
| **A15** | **1FUNC 5V** | **CH1 Latch Pha Z (5V DC TTL/Z+)** | **B15** | **1FUNCCOM** | **CH1 Common âm Latch Pha Z (0V)** |
| **A14** | **2A-** | **CH2 - Xung Pha A (-)** Line Driver | **B14** | **2A+** | **CH2 - Xung Pha A (+)** Line Driver |
| **A13** | **2B-** | **CH2 - Xung Pha B (-)** Line Driver | **B13** | **2B+** | **CH2 - Xung Pha B (+)** Line Driver |
| **A12** | 2PRST 24V | CH2 Ngõ vào Preset 24V DC | **B12** | 2PRST 12V | CH2 Ngõ vào Preset 12V DC |
| **A11** | 2PRST 5V | CH2 Ngõ vào Preset 5V DC | **B11** | 2PRSTCOM | CH2 Common âm Preset (0V) |
| **A10** | **2FUNC 24V**| **CH2 Latch Pha Z (24V DC)** | **B10** | 2FUNC 12V | CH2 Function Start 12V DC |
| **A09** | **2FUNC 5V** | **CH2 Latch Pha Z (5V DC TTL/Z+)** | **B09** | **2FUNCCOM** | **CH2 Common âm Latch Pha Z (0V)** |
| **A08** | NC | Không dùng (Trống) | **B08** | NC | Không dùng (Trống) |
| **A07** | NC | Không dùng (Trống) | **B07** | NC | Không dùng (Trống) |
| **A06** | EQU1- | CH1 Coincidence Output 1 (NPN) | **B06** | EQU1+ | CH1 Coincidence Output 2 (NPN) |
| **A05** | EQU2- | CH2 Coincidence Output 1 (NPN) | **B05** | EQU2+ | CH2 Coincidence Output 2 (NPN) |
| **A04** | NC | Không dùng (Trống) | **B04** | NC | Không dùng (Trống) |
| **A03** | NC | Không dùng (Trống) | **B03** | NC | Không dùng (Trống) |
| **A02** | **0V** | Nguồn ngoài 0VDC (GND) | **B02** | **12/24V** | Nguồn ngoài +12V/+24VDC |
| **A01** | **0V** | Nguồn ngoài 0VDC (GND) | **B01** | **12/24V** | Nguồn ngoài +12V/+24VDC |

---

## 📌 3. SƠ ĐỒ ĐẤU DÂY THỰC TẾ ENCODER LINE DRIVER VÀO QD62D

### 🔹 3.1 ĐẤU NỐI KÊNH 1 (CH1) - Trục Thu T (Slot 2) hoặc Trục Master X2 (Slot 3):
```
   ┌────────────────────────────────┐                 ┌─────────────────────────────┐
   │    ENCODER LINE DRIVER 5V      │                 │     MODULE MITSUBISHI       │
   │   (Ví dụ: Omron, Autonics,     │                 │          QD62D              │
   │    Yaskawa, Tamagawa...)       │                 │   (Chân Jack Cắm 40-Pin)    │
   ├────────────────────────────────┤                 ├─────────────────────────────┤
   │  Dây Pha A+ (Dương)            ├─────────────────┤ Chân B20  (1A+)             │
   │  Dây Pha A- (Âm / Đảo)         ├─────────────────┤ Chân A20  (1A-)             │
   │                                │                 │                             │
   │  Dây Pha B+ (Dương)            ├─────────────────┤ Chân B19  (1B+)             │
   │  Dây Pha B- (Âm / Đảo)         ├─────────────────┤ Chân A19  (1B-)             │
   │                                │                 │                             │
   │  Dây Pha Z+ (Đo Xung/Vòng)     ├─────────────────┤ Chân A15  (1FUNC 5V)        │
   │  Dây 0V Encoder (GND)          ├────────┬────────┤ Chân B15  (1FUNCCOM)        │
   ├────────────────────────────────┤        │        └─────────────────────────────┘
   │  Dây Nguồn +5VDC (VCC)         │◄───────┼─────── [ BỘ NGUỒN SWITCHING +5VDC ]
   │  Dây Nguồn 0VDC (GND)          │◄───────┴─────── [ BỘ NGUỒN SWITCHING  0VDC ]
   │  Lưới Chống Nhiễu (Shield)     ├────────────────► [ BẮT VÍT MASS TỦ ĐIỆN PE/FG]
   └────────────────────────────────┘
```

### 🔹 3.2 ĐẤU NỐI KÊNH 2 (CH2) - Trục Kéo X1 (Slot 2) hoặc Trục Ghép Ms (Slot 3):
```
   ┌────────────────────────────────┐                 ┌─────────────────────────────┐
   │    ENCODER LINE DRIVER 5V      │                 │     MODULE MITSUBISHI       │
   │   (Ví dụ: Omron, Autonics,     │                 │          QD62D              │
   │    Yaskawa, Tamagawa...)       │                 │   (Chân Jack Cắm 40-Pin)    │
   ├────────────────────────────────┤                 ├─────────────────────────────┤
   │  Dây Pha A+ (Dương)            ├─────────────────┤ Chân B14  (2A+)             │
   │  Dây Pha A- (Âm / Đảo)         ├─────────────────┤ Chân A14  (2A-)             │
   │                                │                 │                             │
   │  Dây Pha B+ (Dương)            ├─────────────────┤ Chân B13  (2B+)             │
   │  Dây Pha B- (Âm / Đảo)         ├─────────────────┤ Chân A13  (2B-)             │
   │                                │                 │                             │
   │  Dây Pha Z+ (Đo Xung/Vòng)     ├─────────────────┤ Chân A09  (2FUNC 5V)        │
   │  Dây 0V Encoder (GND)          ├────────┬────────┤ Chân B09  (2FUNCCOM)        │
   ├────────────────────────────────┤        │        └─────────────────────────────┘
   │  Dây Nguồn +5VDC (VCC)         │◄───────┼─────── [ BỘ NGUỒN SWITCHING +5VDC ]
   │  Dây Nguồn 0VDC (GND)          │◄───────┴─────── [ BỘ NGUỒN SWITCHING  0VDC ]
   │  Lưới Chống Nhiễu (Shield)     ├────────────────► [ BẮT VÍT MASS TỦ ĐIỆN PE/FG]
   └────────────────────────────────┘
```

---

## 📌 4. BẢNG MÀU DÂY TIÊU CHUẨN CỦA CÁC DÒNG ENCODER LINE DRIVER

| Tín Hiệu | Autonics (E50S/E40S) | Omron (E6B2-CWZ1X) | Koyo / Tamagawa | Đấu vào QD62D CH1 | Đấu vào QD62D CH2 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **A +** | **Đen (Black)** | **Đen (Black)** | **Xanh dương (Blue)** | **B20** | **B14** |
| **A -** | **Đỏ (Red)** | **Trắng (White)** | **Xanh dương sọc trắng** | **A20** | **A14** |
| **B +** | **Trắng (White)** | **Trắng (White)** | **Xanh lá (Green)** | **B19** | **B13** |
| **B -** | **Xám (Gray)** | **Vàng (Yellow)** | **Xanh lá sọc trắng** | **A19** | **A13** |
| **Z +** | **Cam (Orange)** | **Cam (Orange)** | **Vàng (Yellow)** | **A15** *(1FUNC 5V)* | **A09** *(2FUNC 5V)* |
| **+5V (VCC)** | **Nâu (Brown)** | **Nâu (Brown)** | **Đỏ (Red)** | Nguồn ngoài +5V | Nguồn ngoài +5V |
| **0V (GND)** | **Xanh dương (Blue)**| **Xanh dương (Blue)** | **Đen (Black)** | Nguồn ngoài 0V / B15 | Nguồn ngoài 0V / B09 |
| **Shield (FG)**| **Lưới bọc kim** | **Lưới bọc kim** | **Lưới bọc kim** | Kẹp Mass PE tủ | Kẹp Mass PE tủ |

---

## 📌 5. BẢNG ĐỐI CHIẾU BUFFER MEMORY VÀ HANDSHAKE I/O TRONG PLC

> [!CAUTION]
> **QUY TẮC ĐỊA CHỈ THẬP PHÂN TRONG GX WORKS2:**  
> - Tài liệu phần cứng Mitsubishi (SH-080036) ghi địa chỉ ở dạng **HEXADECIMAL** (suffix `H`).  
> - Lệnh trong GX Works2 (`Un\G...`) bắt buộc sử dụng địa chỉ dạng **THẬP PHÂN (DECIMAL)**!  
> - **CH2 Present Value:** Trong tài liệu là $22\text{H} \rightarrow$ Thập phân phải là **`G34`** (Tuyệt đối **KHÔNG** đọc `G10` hay `G22`).  
> - **CH2 Latch Value:** Trong tài liệu là $2\text{CH} \rightarrow$ Thập phân phải là **`G44`** ($2 \times 16 + 12 = 44$).

| Vị trí Module | Kênh | Trục Cơ Cấu | Đọc PV Đếm Xung (32-bit DINT) | Đọc Latch Pha Z (32-bit DINT) | Cờ Bật Đếm (`Y` Bit) | Cờ Bật Latch (`Y` Bit) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Slot 2 (`H20`)** | **CH1** | **Trục Thu T** | **`U2\G2`** *(G2..G3)* | **`U2\G12`** *(G12..G13)* | **`Y24 := TRUE;`** | **`Y26 := TRUE;`** |
| **Slot 2 (`H20`)** | **CH2** | **Trục Kéo X1** | **`U2\G34`** *(G34..G35)* | **`U2\G44`** *(G44..G45)* | **`Y2C := TRUE;`** | **`Y2E := TRUE;`** |
| **Slot 3 (`H30`)** | **CH1** | **Trục Master X2** | **`U3\G2`** *(G2..G3)* | **`U3\G12`** *(G12..G13)* | **`Y34 := TRUE;`** | **`Y36 := TRUE;`** |
| **Slot 3 (`H30`)** | **CH2** | **Trục Ghép Ms** | **`U3\G34`** *(G34..G35)* | **`U3\G44`** *(G44..G45)* | **`Y3C := TRUE;`** | **`Y3E := TRUE;`** |

---

## 📌 6. ĐOẠN MÃ STRUCTURED TEXT (ST) ĐO XUNG/VÒNG CHO 4 TRỤC

```iecst
(* ============================================================================ *)
(* KÍCH HOẠT VÀ ĐỌC 4 KÊNH ENCODER QD62D (SLOT 2 & 3)                           *)
(* ============================================================================ *)
(* Kích hoạt cờ đếm xung và cờ Latch Function Start *)
Y24 := TRUE; (* QD62D #1 CH1 Count Enable: Trục Thu T *)
Y26 := TRUE; (* QD62D #1 CH1 Latch Function Enable *)
Y2C := TRUE; (* QD62D #1 CH2 Count Enable: Trục Kéo X1 *)
Y2E := TRUE; (* QD62D #1 CH2 Latch Function Enable *)

Y34 := TRUE; (* QD62D #2 CH1 Count Enable: Trục Master X2 *)
Y36 := TRUE; (* QD62D #2 CH1 Latch Function Enable *)
Y3C := TRUE; (* QD62D #2 CH2 Count Enable: Trục Ghép Ms *)
Y3E := TRUE; (* QD62D #2 CH2 Latch Function Enable *)

(* Đọc xung 32-bit từ Buffer Memory liên tục mỗi scan: CH1 = G2, CH2 = G34 *)
DMOV(TRUE, U2\G2,  Curr_Pulse_T);  (* Slot 2 CH1: Trục Thu T *)
DMOV(TRUE, U2\G34, Curr_Pulse_X1); (* Slot 2 CH2: Trục Kéo X1 (22H = 34D) *)
DMOV(TRUE, U3\G2,  Curr_Pulse_X2); (* Slot 3 CH1: Trục Master X2 *)
DMOV(TRUE, U3\G34, Curr_Pulse_Ms); (* Slot 3 CH2: Trục Ghép Ms (22H = 34D) *)

(* Đọc giá trị Latch Pha Z (32-bit): CH1 = G12, CH2 = G44 *)
Curr_Latch_T  := U2\G12; (* Slot 2 CH1 Latch Value *)
Curr_Latch_X1 := U2\G44; (* Slot 2 CH2 Latch Value *)
Curr_Latch_X2 := U3\G12; (* Slot 3 CH1 Latch Value *)
Curr_Latch_Ms := U3\G44; (* Slot 3 CH2 Latch Value *)

(* Tự động tính số xung/vòng (PPR) và đếm vòng quay khi có xung Pha Z mới *)
IF (Curr_Latch_T <> Prev_Latch_T) THEN
    Delta_PPR_T := Curr_Latch_T - Prev_Latch_T;
    IF Delta_PPR_T < DINT#0 THEN Real_PPR_T := -Delta_PPR_T; ELSE Real_PPR_T := Delta_PPR_T; END_IF;
    Prev_Latch_T := Curr_Latch_T;
    Rev_Count_T  := Rev_Count_T + DINT#1;
END_IF;

IF (Curr_Latch_X1 <> Prev_Latch_X1) THEN
    Delta_PPR_X1 := Curr_Latch_X1 - Prev_Latch_X1;
    IF Delta_PPR_X1 < DINT#0 THEN Real_PPR_X1 := -Delta_PPR_X1; ELSE Real_PPR_X1 := Delta_PPR_X1; END_IF;
    Prev_Latch_X1 := Curr_Latch_X1;
    Rev_Count_X1  := Rev_Count_X1 + DINT#1;
END_IF;

IF (Curr_Latch_X2 <> Prev_Latch_X2) THEN
    Delta_PPR_X2 := Curr_Latch_X2 - Prev_Latch_X2;
    IF Delta_PPR_X2 < DINT#0 THEN Real_PPR_X2 := -Delta_PPR_X2; ELSE Real_PPR_X2 := Delta_PPR_X2; END_IF;
    Prev_Latch_X2 := Curr_Latch_X2;
    Rev_Count_X2  := Rev_Count_X2 + DINT#1;
END_IF;

IF (Curr_Latch_Ms <> Prev_Latch_Ms) THEN
    Delta_PPR_Ms := Curr_Latch_Ms - Prev_Latch_Ms;
    IF Delta_PPR_Ms < DINT#0 THEN Real_PPR_Ms := -Delta_PPR_Ms; ELSE Real_PPR_Ms := Delta_PPR_Ms; END_IF;
    Prev_Latch_Ms := Curr_Latch_Ms;
    Rev_Count_Ms  := Rev_Count_Ms + DINT#1;
END_IF;
```

---

## 📌 7. BẢNG MÃ TAG HMI WEINTEK & THANH GHI PLC D

| Trục Cơ Cấu | Tên Tag HMI | Địa Chỉ PLC | Kiểu Dữ Liệu | Diễn Giải Chức Năng |
| :--- | :--- | :---: | :---: | :--- |
| **Trục Thu T** | `Real_PPR_T` | **`D830`** | `32-bit Signed` | Số xung trên 1 vòng đo thực tế từ Pha Z |
| | `Rev_Count_T` | **`D840`** | `32-bit Signed` | Tổng số vòng quay đã hoàn thành |
| **Trục Kéo X1** | `Real_PPR_X1` | **`D832`** | `32-bit Signed` | Số xung trên 1 vòng đo thực tế từ Pha Z |
| | `Rev_Count_X1` | **`D842`** | `32-bit Signed` | Tổng số vòng quay đã hoàn thành |
| **Trục Master X2** | `Real_PPR_X2` | **`D834`** | `32-bit Signed` | Số xung trên 1 vòng đo thực tế từ Pha Z |
| | `Rev_Count_X2` | **`D844`** | `32-bit Signed` | Tổng số vòng quay đã hoàn thành |
| **Trục Ghép Ms** | `Real_PPR_Ms` | **`D836`** | `32-bit Signed` | Số xung trên 1 vòng đo thực tế từ Pha Z |
| | `Rev_Count_Ms` | **`D846`** | `32-bit Signed` | Tổng số vòng quay đã hoàn thành |
