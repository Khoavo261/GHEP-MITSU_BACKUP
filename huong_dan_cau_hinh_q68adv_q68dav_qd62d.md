# HƯỚNG DẪN CẤU HÌNH PHẦN CỨNG & NẠP CHƯƠNG TRÌNH PLC Q02U + HMI WEINTEK
## HỆ THỐNG MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG (BỎ CC-LINK - CHUYỂN TOÀN BỘ VỀ BASE RACK)

**Ngày cập nhật:** 01/09/2026  
**Dự án:** GHEP-MITSU_BACKUP  
**CPU:** Mitsubishi Q02U / Q02H / Q00UJ / Q13UDEH  
**HMI:** Weintek MT8071iE / MT6103iP / cMT Series (EasyBuilder Pro)

---

## 1. BẢNG CẤU HÌNH KHAI BÁO I/O ASSIGNMENT TRONG GX WORKS2

Mở **Project Tree -> Parameter -> PLC Parameter -> I/O Assignment**:

| Slot | Type | Model Name | Points | Start XY | Chức Năng Chi Tiết |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **PLC** | CPU | `Q02UCPU` | - | - | CPU chính điều khiển toàn máy |
| **0** | **Intelli.** | **`Q68ADV`** | **16 Points** | **`0000` (H00)** | **8 Kênh Analog Input (Loadcell T, X1, M, U & Analog Servo S)** |
| **1** | **Intelli.** | **`Q68DAV`** | **16 Points** | **`0010` (H10)** | **8 Kênh Analog Output (Xuất áp Speed/Torque T, X1, X2, Ms, S, M, U)** |
| **2** | **Intelli.** | **`QD62D`** | **16 Points** | **`0020` (H20)** | **2 Kênh Bộ đếm High-Speed Counter (CH1: Trục T, CH2: Trục X1)** |
| **3** | **Intelli.** | **`QD62D`** | **16 Points** | **`0030` (H30)** | **2 Kênh Bộ đếm High-Speed Counter (CH1: Trục X2, CH2: Trục Ms)** |
| **4** | **Input** | **`QX40`** | **16 Points** | **`0040` (H40)** | **16 Ngõ vào DC 24V (Ready 5 Servo, Nút Start/Stop/Jog/Inc/Dec, Sensor M/U)** |
| **5** | **Output** | **`QY40`** | **16 Points** | **`0050` (H50)** | **16 Ngõ ra Transistor Sink (Servo ON 5 Trục, Pen 1, Pen 2, Đèn Tháp/Còi)** |
| **6** | **Intelli.** | **`QJ71C24N`** | **32 Points** | **`0060` (H60)** | **Module truyền thông nối tiếp RS-232 / RS-485** |

> [!IMPORTANT]
> - Sau khi nhập xong bảng trên, nhấn nút **Check** để kiểm tra không có lỗi trùng địa chỉ, sau đó nhấn **End**.
> - Trong thẻ **PLC RAS**, cài đặt: **`WDT = 500 ms`**, **`Constant Scanning = 2.0 ms`**.

---

## 2. CẤU HÌNH SWITCH SETTING CHO TỪNG MODULE TRONG GX WORKS2

Tại bảng **I/O Assignment**, click vào nút **Switch Setting** ở góc dưới bên phải:

### A. Module Q68ADV (Slot 0 - Head Address H00):
- **Switch 1 (Input Range Setting CH1..CH4):** `0000` (Tất cả CH1..CH4 chọn dải `0 ~ 10V`)
- **Switch 2 (Input Range Setting CH5..CH8):** `0000` (Tất cả CH5..CH8 chọn dải `0 ~ 10V` để đọc Analog Monitor 0~10V từ Servo S)
- **Switch 3 (Resolution Mode):** `0000` (High Resolution Mode: 0 ~ 16000)

### B. Module Q68DAV (Slot 1 - Head Address H10):
- **Switch 1 (Output Range Setting CH1..CH4):** `0000` (Tất cả CH1..CH4 chọn dải xuất `0 ~ 10V`)
- **Switch 2 (Output Range Setting CH5..CH8):** `0000` (Tất cả CH5..CH8 chọn dải xuất `0 ~ 10V`)
- **Switch 3 (Resolution Mode):** `0000` (High Resolution Mode: 0 ~ 16000)

### C. Module QD62D #1 (Slot 2 - Head Address H20 - Trục Thu T & Kéo X1):
- **Switch 1 (CH1 - Trục Thu T):** `0002` (Line Driver Phase A/B - Chế độ 4 Multiplier / x4 nhân tần số)
- **Switch 2 (CH2 - Trục Kéo X1):** `0002` (Line Driver Phase A/B - Chế độ 4 Multiplier / x4 nhân tần số)

### D. Module QD62D #2 (Slot 3 - Head Address H30 - Trục Master X2 & Ghép Ms):
- **Switch 1 (CH1 - Trục Master X2):** `0002` (Line Driver Phase A/B - Chế độ 4 Multiplier / x4)
- **Switch 2 (CH2 - Trục Ghép Ms):** `0002` (Line Driver Phase A/B - Chế độ 4 Multiplier / x4)

---

## 3. SƠ ĐỒ ĐẤU DÂY PHẦN CỨNG TOÀN DIỆN

### 🔹 1. Đấu nối Module Q68ADV (Slot 0 - Analog Input):
- **CH1 (V+ / V-):** Đấu ngõ ra Bộ khuếch đại Loadcell Lực căng Trục Thu T (0~10V).
- **CH2 (V+ / V-):** Đấu ngõ ra Bộ khuếch đại Loadcell Lực căng Trục Kéo X1 (0~10V).
- **CH3 (V+ / V-):** Đấu ngõ ra Bộ khuếch đại Loadcell Lực căng Thắng Metalize M (0~10V).
- **CH4 (V+ / V-):** Đấu ngõ ra Bộ khuếch đại Loadcell Lực căng Trục Xả U (0~10V).
- **CH5 (V+ / V-):** **ĐẤU TÍN HIỆU ANALOG MONITOR OUT TỪ SERVO DRIVER TRỤC S:**
  - Chân `V+` (CH5) nối chân `Speed Monitor Out` (Ví dụ chân `MON1` hoặc `A-OUT` trên Servo).
  - Chân `V-` (CH5) nối chân `GND / SG` (Chân mass Analog của Servo).
  - *(Trên Driver Servo Yaskawa/Mitsubishi: Cài đặt thông số xuất Speed Monitor tỉ lệ 0~10V tương ứng 0~3000 RPM)*.
- **CH6, CH7, CH8:** Dự phòng mở rộng.

### 🔹 2. Đấu nối Module Q68DAV (Slot 1 - Analog Output 0..10V):
- **CH1 (V+ / COM):** Xuất tốc độ `Speed Setpoint` cho Servo Driver Thu T.
- **CH2 (V+ / COM):** Xuất giới hạn lực `Torque Limit / Torque Setpoint` cho Servo Driver Thu T.
- **CH3 (V+ / COM):** Xuất tốc độ `Speed Setpoint` cho Servo Driver Kéo X1.
- **CH4 (V+ / COM):** Xuất tốc độ `Speed Setpoint` cho Servo Driver Master X2.
- **CH5 (V+ / COM):** Xuất tốc độ `Speed Setpoint` cho Servo Driver Ghép Ms.
- **CH6 (V+ / COM):** Xuất lực hãm `Brake Command` cho Bộ nguồn Thắng từ Metalize M.
- **CH7 (V+ / COM):** Xuất tốc độ `Speed Setpoint` cho Servo Driver Tráng Dầu S.
- **CH8 (V+ / COM):** Xuất tốc độ / lực hãm cho Trục Xả U.

### 🔹 3. Đấu nối 4 Encoder vào 2 Module QD62D:
- **Module QD62D #1 (Slot 2):**
  - **CH1 (1A+, 1A-, 1B+, 1B-):** Nối cáp Line Driver Encoder Trục Thu T.
  - **CH2 (2A+, 2A-, 2B+, 2B-):** Nối cáp Line Driver Encoder Trục Kéo X1.
- **Module QD62D #2 (Slot 3):**
  - **CH1 (1A+, 1A-, 1B+, 1B-):** Nối cáp Line Driver Encoder Trục Master X2.
  - **CH2 (2A+, 2A-, 2B+, 2B-):** Nối cáp Line Driver Encoder Trục Ghép Ms.

### 🔹 4. Đấu nối Module QX40 (Slot 4 - Digital Input X40..X4F):
*(Ghép toàn bộ tín hiệu của module 16DT cũ và nút bấm cơ vào QX40)*:
- **`X40`:** Tiếp điểm Relay báo Servo Ready Trục Thu T (`Servo_Ready_T`).
- **`X41`:** Tiếp điểm Relay báo Servo Ready Trục Kéo X1 (`Servo_Ready_X1`).
- **`X42`:** Tiếp điểm Relay báo Servo Ready Trục Master X2 (`Servo_Ready_X2`).
- **`X43`:** Tiếp điểm Relay báo Servo Ready Trục Ghép Ms (`Servo_Ready_Ms`).
- **`X44`:** Tiếp điểm Relay báo Servo Ready Trục Dầu S (`Servo_Ready_S`).
- **`X45`:** Nút nhấn cơ START ngoài tủ (`Physical_Start_PB`).
- **`X46`:** Nút nhấn cơ STOP ngoài tủ (`Physical_Stop_PB`).
- **`X47`:** Nút nhấn cơ TĂNG TỐC INC (`Physical_Inc_PB`).
- **`X48`:** Nút nhấn cơ GIẢM TỐC DEC (`Physical_Dec_PB`).
- **`X49`:** Nút nhấn cơ BÒ CHẬM NỐI MÀNG 2m/p (`Physical_Jog_PB`).
- **`X4A`:** Cảm biến tiệm cận NPN/PNP đếm 1 vòng cuộn Thắng M (`Sensor_Rev_M`).
- **`X4B`:** Cảm biến tiệm cận NPN/PNP đếm 1 vòng cuộn Xả U (`Sensor_Rev_U`).
- **`X4C`:** Nút gạt/bấm Toggle Pen 1 ngoài tủ (`Pen1_Toggle_PB`).
- **`X4D`:** Nút gạt/bấm Toggle Pen 2 ngoài tủ (`Pen2_Toggle_PB`).
- **`X4E`:** Công tắc gạt giữ Torque hãm cuộn M khi máy dừng (`Switch_Hold_M`).
- **`X4F`:** Công tắc gạt giữ Torque hãm cuộn U khi máy dừng (`Switch_Hold_U`).

### 🔹 5. Đấu nối Module QY40 (Slot 5 - Digital Output Y50..Y5F):
*(Ghép toàn bộ ngõ ra của module 16DT cũ vào QY40)*:
- **`Y50`:** Cuộn hút Relay kích Servo ON Trục Thu T (`Servo_ON_T`).
- **`Y51`:** Cuộn hút Relay kích Servo ON Trục Kéo X1 (`Servo_ON_X1`).
- **`Y52`:** Cuộn hút Relay kích Servo ON Trục Master X2 (`Servo_ON_X2`).
- **`Y53`:** Cuộn hút Relay kích Servo ON Trục Ghép Ms (`Servo_ON_Ms`).
- **`Y54`:** Cuộn hút Relay kích Servo ON Trục Dầu S (`Servo_ON_S`).
- **`Y55`:** Cuộn hút Van Solenoid 24VDC Pen 1 ép màng (`DO_Pen1`).
- **`Y56`:** Cuộn hút Van Solenoid 24VDC Pen 2 ép màng (`DO_Pen2`).
- **`Y57`:** Còi báo động / Báo lỗi hệ thống (`DO_Alarm_Horn`).
- **`Y58`:** Đèn tháp XANH (Báo máy đang chạy tự động).
- **`Y59`:** Đèn tháp VÀNG (Báo máy đang chờ / bò chậm).
- **`Y5A`:** Đèn tháp ĐỎ (Báo lỗi mất Ready Servo hoặc dừng khẩn cấp).

---

## 4. HƯỚNG DẪN THAO TÁC TRONG GX WORKS2 (1-CLICK COPY-PASTE)

1. **Copy Global Labels:**
   - Mở file [`global_labels_paste.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/global_labels_paste.tsv).
   - Nhấn `Ctrl + A` -> `Ctrl + C`.
   - Trong GX Works2, mở **Global Label -> Global_Variables**, click chuột vào ô đầu tiên ở cột `Label Name` và nhấn `Ctrl + V`.

2. **Copy Local Labels cho POU_01:**
   - Mở file [`pou01_local_labels_paste.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/pou01_local_labels_paste.tsv).
   - Nhấn `Ctrl + A` -> `Ctrl + C`.
   - Trong GX Works2, mở **POU_01 -> Local Label**, click chuột vào ô đầu tiên ở cột `Label Name` và nhấn `Ctrl + V`.

3. **Dán mã nguồn ST:**
   - Mở file [`init_program.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/init_program.st) copy vào POU `INIT_PROGRAM` (đặt thuộc tính POU là `Initial`).
   - Mở file [`pou01_only_program.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/pou01_only_program.st) copy vào POU `POU_01` (đặt thuộc tính POU là `Scan`).
   - Mở file [`encoder_speed_calc.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/encoder_speed_calc.st) copy vào POU `POU_ENCODER_SPEED` (đặt thuộc tính POU là `Fixed Scan 10.0 ms` hoặc gọi trong Scan).

4. **Import Comment Tiếng Việt:**
   - Trong GX Works2, vào menu: **Project -> Device Comment -> Read from CSV File...**
   - Chọn file [`device_comments_full.csv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/device_comments_full.csv) để nạp toàn bộ ghi chú tiếng Việt vào bảng thiết bị.

5. **Biên dịch chương trình:**
   - Nhấn phím **`F4` (Rebuild All)** -> Đảm bảo **`0 Errors, 0 Warnings`**.

---

## 5. HƯỚNG DẪN KHAI BÁO & IMPORT TAGS CHO HMI WEINTEK (EASYBUILDER PRO)

1. **Cấu hình kết nối Driver trong EasyBuilder Pro:**
   - Vào **Home -> System Parameters -> Device**.
   - Thêm thiết bị mới:
     - **Device Type:** `Mitsubishi Q00/Q00UJ/Q01/QJ71 (Ethernet)` hoặc `Mitsubishi Q00/Q00UJ/Q01/QJ71 (Serial)`.
     - **Interface:** RS-232 / RS-485 qua Slot 6 `QJ71C24N` hoặc CPU Port: `19200, 8, Odd, 1` (hoặc Ethernet Port IP: `192.168.1.250`).

2. **Import Tag Library 1-Click:**
   - Vào menu: **Project -> Address -> Import Tags...**
   - Chọn file [`weintek_easybuilder_tags_import.csv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/weintek_easybuilder_tags_import.csv).
   - Nhấn **Import** -> Toàn bộ các tag nút bấm, ô hiển thị số thực, trạng thái lỗi sẽ được tự động liên kết hoàn hảo!
