# 🖥️ HƯỚNG DẪN THIẾT KẾ GIAO DIỆN HMI WEINTEK MT6103iP (10.1" - 1024x600)
## DỰ ÁN: MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - MITSUBISHI Q02U PLC

---

## 🛠️ PHẦN 1: CẤU HÌNH KẾT NỐI PLC (SYSTEM PARAMETERS)

Trong phần mềm **EasyBuilder Pro**:
1. Tạo dự án mới $\rightarrow$ Chọn Model: **`MT6103iP (1024 x 600)`**.
2. Vào **`Home`** $\rightarrow$ **`System Parameters`** $\rightarrow$ Thêm thiết bị mới (**New Device**):
   * **Device Type:** `Mitsubishi Q/QnA (Serial)` *(hoặc `Mitsubishi Q/QnA (Ethernet)` nếu dùng cáp mạng)*.
   * **Interface:** `RS-232` (hoặc `RS-485 2W`).
   * **COM Port:** `COM1 (19200, O, 8, 1)` *(Baudrate: 19200, Parity: Odd, Data Bits: 8, Stop Bit: 1)*.
   * **PLC Station No.:** `0`.
3. Nhập bảng Tag biến:
   * Vào menu **`Project`** $\rightarrow$ **`Address Tag Library`** $\rightarrow$ Bấm nút **`Import...`** $\rightarrow$ Chọn file [`weintek_easybuilder_tags_import.csv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/weintek_easybuilder_tags_import.csv).
   * Toàn bộ 50+ biến điều khiển sẽ được nạp tự động vào HMI chỉ trong 1 click!

---

## 🎨 PHẦN 2: THIẾT KẾ CHI TIẾT 4 MÀN HÌNH CHÍNH (RESOLUTION: 1024 x 600)

### 🔹 MÀN HÌNH 10: VẬN HÀNH CHÍNH (MAIN OPERATION)

| Vị trí Layout | Loại Object trong EasyBuilder Pro | Địa chỉ kết nối | Thuộc tính & Định dạng | Ghi chú & Màu sắc |
| :--- | :--- | :---: | :--- | :--- |
| **Top Banner** | Text Label & System Date/Time | - | Font: Arial Bold, Size 20 | Nền xanh đen Header sang trọng |
| **Top Right** | Bit Lamp (Đèn báo) | `M100` | State 0: DỪNG (Xám), State 1: CHẠY (Xanh lá) | Báo trạng thái máy |
| **Top Right** | Bit Lamp (Đèn báo CC-Link) | `M1311` | State 0: OK (Xanh lá), State 1: LỖI (Đỏ nhấp nháy) | Báo lỗi truyền thông CC-Link |
| **Khung Tốc Độ** | **Numeric Display** (Tốc độ thực) | `D700` | 32-bit Signed, 1 số lẻ (Format: `999.9 m/p`) | Số to Size 36, màu Xanh lục |
| **Khung Tốc Độ** | **Numeric Input** (Tốc độ cài) | `D702` | 32-bit Signed, 1 số lẻ (Format: `999.9 m/p`) | Khung nhập màu Vàng cam |
| **Nút START** | **Set Bit Object** (Momentary) | `M102` | Style: Round Rect, Màu Xanh Lá | Chữ trắng: **CHẠY MÁY (START)** |
| **Nút STOP** | **Set Bit Object** (Momentary) | `M103` | Style: Round Rect, Màu Đỏ | Chữ trắng: **DỪNG MÁY (STOP)** |
| **Nút INC (+)** | **Set Bit Object** (Momentary) | `M109` | Style: Button, Màu Xanh Dương | Bấm giữ tăng tốc liên tục |
| **Nút DEC (-)** | **Set Bit Object** (Momentary) | `M114` | Style: Button, Màu Xanh Dương | Bấm giữ giảm tốc liên tục |
| **Nút PEN 1** | **Toggle Switch / Set Bit** | `M115` | Đèn chỉ thị: `M1309` | Bật / Nhả Van Ép Pen 1 |
| **Nút PEN 2** | **Toggle Switch / Set Bit** | `M116` | Đèn chỉ thị: `M1310` | Bật / Nhả Van Ép Pen 2 |
| **Cuộn Thu T** | Numeric Display + Reset Roll | `D710` + `M105` | Format: `9999 mm`, Nút nạp cuộn mới | Đo đường kính cuộn Thu T |
| **Cuộn Xả M** | Numeric Display + Reset Roll | `D712` + `M106` | Format: `9999 mm`, Nút nạp cuộn mới | Đo đường kính cuộn Xả M |
| **Cuộn Xả U** | Numeric Display + Reset Roll | `D714` + `M107` | Format: `9999 mm`, Nút nạp cuộn mới | Đo đường kính cuộn Xả U |
| **Độ dài Mét** | Numeric Display (Đã chạy) | `D720` | Format: `99,999 m` (32-bit Signed) | Đếm tổng chiều dài màng |
| **Cài đặt Mét**| Numeric Input (Dừng máy) | `D722` | Format: `99,999 m`, Reset `M104` | Tự động báo giảm tốc & dừng |
| **5 Trục Servo**| 5 Đèn Bit Lamp Ready | `M1104..M1108` | Xanh lá khi Driver sẵn sàng | T, X1, X2, Ms, S |

---

### 🔹 MÀN HÌNH 20: CÀI ĐẶT LỰC CĂNG & PID (TENSION & PID SETTINGS)

| Chức năng điều khiển | Loại Object | Địa chỉ hiển thị | Địa chỉ cài đặt | Đơn vị tính |
| :--- | :--- | :---: | :---: | :---: |
| **Lực căng Cuộn Thu T** | Numeric Input/Display | `D600` (Thực tế) | `D602` (Cài đặt) | $0 \sim 500\text{ N}$ |
| **Lực căng Kéo Giấy X1** | Numeric Input/Display | `D604` (Thực tế) | `D606` (Cài đặt) | $0 \sim 300\text{ N}$ |
| **Lực căng Thắng Xả M** | Numeric Input/Display | `D608` (Thực tế) | `D610` (Cài đặt) | $0 \sim 500\text{ N}$ |
| **Lực căng Trục Xả U** | Numeric Input/Display | `D612` (Thực tế) | `D614` (Cài đặt) | $0 \sim 400\text{ N}$ |
| **Hệ số PID Cuộn T** | 3 Numeric Inputs | - | `D620` (Kp), `D622` (Ki), `D624` (Kd) | x100 |
| **Hệ số PID Trục X1** | 3 Numeric Inputs | - | `D626` (Kp), `D628` (Ki), `D630` (Kd) | x100 |
| **Hệ số PID Thắng M** | 3 Numeric Inputs | - | `D682` (Kp), `D684` (Ki), `D686` (Kd) | x100 |
| **Hệ số PID Trục Xả U**| 3 Numeric Inputs | - | `D688` (Kp), `D690` (Ki), `D692` (Kd) | x100 |
| **Tỷ lệ Tốc độ Trục S** | Numeric Input | - | `D762` (1000 = 100%, >1000 Nhanh, <1000 Chậm) | $0.1\%$ |
| **Bù Tốc độ Trục S**   | Numeric Input | - | `D764` (Bù lệch tốc độ $\pm \Delta v$) | $0.1\text{ m/p}$ |
| **Côn Lực Taper Tension T**| Numeric Input | - | `D666` (% Côn lực) | $0 \sim 100\%$ |
| **3 Pha Thắng M** | 3 Numeric Inputs | - | `D764` (Hold), `D760` (Min), `D762` (Max) | $0 \sim 4000\text{ DAC}$ |

---

### 🔹 MÀN HÌNH 30: CÂN CHỈNH LOADCELL & CƠ KHÍ (CALIBRATION)

* **4 Nút Cân Bì Zero Loadcell (Set Bit Momentary):**
  * `M110`: Zero Set Cuộn Thu T
  * `M111`: Zero Set Kéo X1
  * `M112`: Zero Set Thắng M
  * `M113`: Zero Set Xả U
* **Cài đặt Tỷ số truyền và Bù tốc độ:**
  * `D760`: Tỷ số tốc độ Lô Ghép Ms (`1000 = 100.0%`)
  * `D762`: Tỷ số tốc độ Lô Dầu S (`1000 = 100.0%`)
  * `D764`: Tốc độ bù lệch Lô Dầu S (`Speed_Offset_S`)
  * `D734`: Gia tốc tăng tốc đường dốc (`Ramp_Accel_Rate`)
  * `D736`: Gia tốc giảm tốc đường dốc (`Ramp_Decel_Rate`)

---

### 🔹 MÀN HÌNH 40: BÁO LỖI & CHẨN ĐOÁN (ALARMS & DIAGNOSTICS)

* **Thanh trạng thái 3 Trạm CC-Link:**
  * Trạm 1 (AJ65SBT-64AD): Đèn xanh `M1016` (AD Conversion Ready).
  * Trạm 2 & 3 (AJ65VBTCU-68DAVN): Đèn xanh `M1064` (DA Output Ready).
  * Trạm 4 (AJ65SBTB1-16DT): Đèn xanh Cyclic OK.
* **Bảng Báo Động (Alarm Display Object):** Tự động ghi lại thời gian xảy ra lỗi Servo Not Ready, Quá tải WDT, Mất kết nối CC-Link.
* **Nút bấm RESET LỖI TOÀN HỆ THỐNG:** `M101` (Kích thước lớn, màu Vàng).

---

### 🔹 THANH ĐIỀU HƯỚNG DƯỚI CÙNG (BOTTOM NAVIGATION BAR - TỌA ĐỘ Y: 540..600):
Đặt 4 nút chuyển trang (**Function Key / Change Window Button**) cố định ở đáy màn hình:
1. `[ F1: VẬN HÀNH CHÍNH ]` $\rightarrow$ Mở Window 10
2. `[ F2: CÀI ĐẶT PID ]` $\rightarrow$ Mở Window 20
3. `[ F3: CÂN CHỈNH ]` $\rightarrow$ Mở Window 30
4. `[ F4: CHẨN ĐOÁN LỖI ]` $\rightarrow$ Mở Window 40
