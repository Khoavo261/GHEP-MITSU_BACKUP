# HƯỚNG DẪN ĐẤU NỐI PHẦN CỨNG & CẤU HÌNH KẾT NỐI HMI WEINTEK (CPU Q02U)

Tài liệu hướng dẫn chi tiết sơ đồ đấu nối dây truyền thông CC-Link, module Analog, Digital I/O và cấu hình kết nối HMI Weintek với PLC Mitsubishi Q02UCPU.

---

## 🔌 1. SƠ ĐỒ ĐẤU NỐI MẠNG CC-LINK (QJ61BT11N & 3 MODULE TRẠM XA)

### A. Cáp Truyền Thông CC-Link
Sử dụng cáp xoắn đôi 3 lõi chuyên dụng CC-Link (3-Core Shielded Cable):
- **DA (Dây Xanh Lục / Green):** Tín hiệu Data A
- **DB (Dây Xanh Dương / Blue):** Tín hiệu Data B
- **DG (Dây Trắng / White):** Dây Mass tín hiệu Data Ground
- **SLD (Vỏ giáp chống nhiễu / Shield):** Nối đất chống nhiễu FG (Frame Ground)

### B. Trở Kháng Đầu Cuối (Terminal Resistor) — *CỰC KỲ QUAN TRỌNG*
Mạng CC-Link bắt buộc phải gắn **02 Điện trở đầu cuối 110 $\Omega$ (1/2W)** ở 2 điểm đầu và cuối của đường trục CC-Link:
1. **Điểm đầu (Master QJ61BT11N - Slot 0):** Đấu điện trở $110\Omega$ giữa 2 chân **DA** và **DB**.
2. **Điểm cuối (Module xa nhất - St 4 AJ65SBT-16DT):** Đấu điện trở $110\Omega$ giữa 2 chân **DA** và **DB**.
3. Các trạm ở giữa (St 1, St 2&3) đấu song song cáp DA-DA, DB-DB, DG-DG, SLD-SLD *(Không gắn điện trở)*.

---

## ⚡ 2. SƠ ĐỒ ĐẤU NỐI MODULE ANALOG ADC / DAC & DIGITAL I/O

### A. Trạm 1: Module Analog Input 4 Kênh (`AJ65SBT-64AD`)
- **Nguồn cấp:** `24VDC` (Chân `+24V` và `24G`).
- **Tín hiệu Analog Input (Đọc Cảm biến/Loadcell/Áp suất):**
  - **Dạng Điện Áp (0~10V):** Nối chân dương tín hiệu vào **V+**, chân âm nối chung **COM**. (Nối tắt **V+** với **I+** nếu chọn dòng).
  - **Dạng Dòng Điện (4~20mA):** Nối chân dương tín hiệu vào **V+** và **I+** (Nối cầu ngắn V+ và I+ lại với nhau), chân âm nối **COM**.
  - **Vỏ giáp chống nhiễu:** Nối vào chân **FG** (Frame Ground).

### B. Trạm 2 & 3: Module Analog Output 8 Kênh (`AJ65VBTCU-68DAVN`)
- **Nguồn cấp:** `24VDC` (Chân `+24V` và `24G`).
- **Tín hiệu Analog Output (Xuất lệnh Tốc độ/Torque cho Servo/Biến tần):**
  - Kênh 1 ~ 8: Tín hiệu xuất ra từ chân **V+** và **COM** của từng kênh (Điện áp $-10\text{V} \sim +10\text{V}$ hoặc $0 \sim 10\text{V}$).
  - Nối chân **V+** vào cổng nhận ngõ vào Analog của Servo/Biến tần (chân `V-REF` / `T-REF` / `AI1`).
  - Nối chân **COM** vào chân Mass Analog của Servo/Biến tần (chân `GND` / `ACM`).

### C. Trạm 4: Module Digital Remote 16 Points (`AJ65SBT-16DT`)
- **8 Ngõ vào NPN/PNP (X0~X7):** Cấp nguồn 24VDC vào chân `COM`, các chân ngõ vào `X0`~`X7` nối tới nút nhấn, cảm biến.
- **8 Ngõ ra Transistor (Y0~Y7):** Nối tới cuộn hút Rơ le trung gian 24VDC, đèn báo, Solenoid valve.

---

## 🖥️ 3. CẤU HÌNH KẾT NỐI HMI WEINTEK VỚI PLC Q02UCPU (EASYBUILDER PRO)

PLC **Q02UCPU** kết nối với HMI Weintek qua 2 phương thức phổ biến:

### Phương Thức A: Kết Nối Qua Cổng Truyền Thông Nối Tiếp RS-232 / RS-422 (Mặc định trên CPU Q02U)
Sử dụng cáp truyền thông RS-232/RS-422 nối từ cổng COM1/COM3 của HMI Weintek vào cổng tròn Mini-DIN 6-pin (RS232) trên CPU Q02U.

#### 1. Cấu hình trong phần mềm EasyBuilder Pro (HMI Weintek):
- Vào menu **`System Parameters`** $\rightarrow$ Thẻ **`Device`** $\rightarrow$ Nhấp nút **`New Device...`**
- **Device Name:** `PLC`
- **Device Type:** **`Mitsubishi Q02/Q02H/Q06H/Q12H/Q25H (CPU Port)`** *(hoặc `Mitsubishi Q series (RS232/RS422)`)
- **Interface:** `RS-232` (hoặc `RS-422`)
- **Baud Rate:** `9600` (hoặc `115200`)
- **Data Bits:** `8`
- **Parity:** `Odd`
- **Stop Bits:** `1`

---

### Phương Thức B: Kết Nối Qua Ethernet MC Protocol (Sử dụng Module Ethernet QJ71E71-100)
Nếu PLC lắp thêm module Ethernet `QJ71E71-100` tại Slot 1 (Head I/O `H20`):

#### 1. Cấu hình Parameter Ethernet trên GX Works2:
- **IP Address:** `192.168.1.250`
- **Subnet Mask:** `255.255.255.0`
- **Open Settings:**
  - Protocol: `TCP`
  - Open Method: `MC Protocol`
  - Port No.: `5007` (Dạng HEX: `138F`)

#### 2. Cấu hình trong EasyBuilder Pro:
- **Device Type:** **`Mitsubishi QJ71E71 / Built-in ETH (MC Protocol)`**
- **IP Address:** `192.168.1.250`
- **Port No.:** `5007`

---

## 📊 4. BẢNG MAPPING BIẾN GIAO DIỆN HMI KẾT NỐI PLC

Bạn có thể import file [`hmi_weintek_tags.csv`](file:///d:/data-2026/GHEP-MITSU/hmi_weintek_tags.csv) trực tiếp vào EasyBuilder Pro:

| Tên Biến HMI (Tag Name) | Địa Chỉ PLC | Kiểu Dữ Liệu | Chức Năng Trên Giao Diện HMI |
| :--- | :--- | :--- | :--- |
| `CCLink_Status` | `M1303` hoặc `SB0020` | Bit (BOOL) | Đèn báo lỗi CC-Link (0 = Xanh/Bình thường, 1 = Đỏ/Có lỗi) |
| `CCLink_ErrCode` | `SW0000` | Word (16-bit) | Hiển thị mã lỗi truyền thông CC-Link |
| `ADC_CH1_Display` | `D600` | Unsigned Word | Hiển thị giá trị % Analog Input Kênh 1 (0.0% ~ 100.0%) |
| `ADC_CH2_Display` | `D601` | Unsigned Word | Hiển thị giá trị % Analog Input Kênh 2 |
| `ADC_CH3_Display` | `D602` | Unsigned Word | Hiển thị giá trị % Analog Input Kênh 3 |
| `ADC_CH4_Display` | `D603` | Unsigned Word | Hiển thị giá trị % Analog Input Kênh 4 |
| `DAC_CH1_SetVal` | `D610` | Unsigned Word | Ô nhập giá trị cài đặt Analog Output CH1 (0 ~ 1000) |
| `DAC_CH2_SetVal` | `D611` | Unsigned Word | Ô nhập giá trị cài đặt Analog Output CH2 (0 ~ 1000) |
| `DAC_CH3_SetVal` | `D612` | Unsigned Word | Ô nhập giá trị cài đặt Analog Output CH3 |
| `DAC_CH4_SetVal` | `D613` | Unsigned Word | Ô nhập giá trị cài đặt Analog Output CH4 |
| `Remote_DI0` | `M1104` | Bit (BOOL) | Đèn báo trạng thái ngõ vào X0 Trạm 4 |
| `Remote_DI1` | `M1105` | Bit (BOOL) | Đèn báo trạng thái ngõ vào X1 Trạm 4 |
| `Remote_DO_Y8_Servo_T` | `M1304` | Bit (BOOL) | Servo ON Trục Thu T (Cọc 1 Y8) |
| `Remote_DO_Y9_Servo_X1` | `M1305` | Bit (BOOL) | Servo ON Trục Xả X1 (Cọc 2 Y9) |
| `Remote_DO_YA_Servo_X2` | `M1306` | Bit (BOOL) | Servo ON Trục Master X2 (Cọc 3 YA) |
| `Remote_DO_YB_Servo_Ms` | `M1307` | Bit (BOOL) | Servo ON Trục Ghép Ms (Cọc 4 YB) |
| `Remote_DO_YC_Servo_S` | `M1308` | Bit (BOOL) | Servo ON Trục Tráng Dầu S (Cọc 5 YC) |
| `Remote_DO_YD_Pen1` | `M1309` | Bit (BOOL) | Ngõ ra Van Solenoid Pen 1 (Cọc 6 YD) |
| `Remote_DO_YE_Pen2` | `M1310` | Bit (BOOL) | Ngõ ra Van Solenoid Pen 2 (Cọc 7 YE) |
| `Reset_Fault_Btn` | `M1111` | Bit (BOOL) | Nút bấm Reset lỗi hệ thống |
