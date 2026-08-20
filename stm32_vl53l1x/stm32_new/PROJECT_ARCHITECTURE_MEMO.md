# KIẾN TRÚC HỆ THỐNG & GIAO THỨC TRUYỀN THÔNG
## DỰ ÁN: CẢM BIẾN TOF VL53L1X + STM32F401 <-> PLC MITSUBISHI Q-SERIES (QJ71C24N-R4)

---

### 1. CẤU HÌNH PHẦN CỨNG & CỔNG TRUYỀN THÔNG:
* **Vi điều khiển:** STM32F401CCU6 (BlackPill).
* **Cảm biến khoảng cách:** Laser ToF VL53L1X giao tiếp qua cổng `I2C1`.
* **Màn hình OLED:** SSD1306 0.96 inch 128x64 giao tiếp qua cổng `I2C2`.
* **PLC Mitsubishi:** CPU Q02U + Module truyền thông nối tiếp `QJ71C24N-R4` (Slot 6, I/O 0070).
* **Chuẩn truyền thông:** RS-485 / RS-422, MC Protocol Format 5 (Binary Frame 3E).
* **Cài đặt Switch QJ71:**
  * Switch 3 = `0566` (9600 bps, 8 bit data, Odd Parity, 1 Stop, Checksum enabled).
  * Switch 4 = `0005` (Format 5 - MC Protocol Binary).

---

### 2. ÁNH XẠ Ô NHỚ VÀ CẤU TRÚC GÓI TIN (QUAN TRỌNG - KHÔNG THAY ĐỔI):

#### A. Gửi từ STM32 lên PLC (Batch Write Command 0x1401 - 6 Words: D900..D905)
* **`D900`:** Khoảng cách đã qua lọc thích nghi & bù sai số Calib (mm).
* **`D901`:** Khoảng cách thô chưa bù (mm).
* **`D902`:** Trạng thái hệ thống (Bit 0: Sensor OK, Bit 1: Near, Bit 2: In-range, Bit 3: Calib OK).
* **`D903`:** Mã lỗi cảm biến (0: OK, 10: Boot err, 20: Init err, 30: I2C err).
* **`D904`:** Chu kỳ quét đo lường (ms).
* **`D905`:** Heartbeat (Tự tăng liên tục mỗi chu kỳ gửi).

#### B. Đọc từ PLC xuống STM32 (Batch Read Command 0x0401 - 2 Words: D910..D911)
* **Gói phản hồi chuẩn từ QJ71 Format 5 (Tổng chiều dài payload = 18 bytes):**
  * `payload[0..1]`: Chiều dài gói dữ liệu (`0x0012` = 18 bytes).
  * `payload[2..9]`: 8 bytes Routing Header (`F8 00 00 FF FF 03 00 00`).
  * `payload[10..11]`: Subheader (`0x0000`).
  * `payload[12..13]`: Mã hoàn tất End Code (`0x0000` = Thành công).
  * **`payload[14..15]`:** **`Word 0 = D910` (Cự ly chuẩn mm đặt từ PLC/HMI, ví dụ: 280, 300 mm)**.
  * **`payload[16..17]`:** **`Word 1 = D911` (Mã lệnh hiệu chuẩn Calib: 1, 10, 20, 30)**.

#### C. Tự động xóa D911 = 0 sau khi Calib xong:
* Sau khi STM32 thực thi xong lệnh Calib và lưu Flash thành công, STM32 tự động gửi gói **Batch Write 0x1401** ghi giá trị `0` vào thanh ghi `D911` trên PLC.

---

### 3. CÁC CHẾ ĐỘ HIỆU CHUẨN (CALIBRATION MODES):
* **`D911 = 0`:** **RUN MODE (Mặc định)**: Màn hình OLED hiển thị số đo khoảng cách `D900` với **Font chữ Siêu Lớn (`16x26`)**.
* **`D911 = 10` (hoặc `1`):** **Calib Offset Phần Mềm**: $Offset = D910 - D\_Raw$, lưu vĩnh viễn vào Flash STM32 Sector 5 (`0x08020000`).
* **`D911 = 20`:** **Calib Offset Phần Cứng**: Gọi ST API `VL53L1X_CalibrateOffset()` (chuẩn 140 mm của ST).
* **`D911 = 30`:** **Calib Crosstalk (Xtalk Glass)**: Gọi ST API `VL53L1X_CalibrateXtalk()` (chuẩn 500 mm của ST) triệt tiêu phản xạ khi lắp cảm biến sau kính/mica bảo vệ.
* **`D911 ≠ 0` và không hợp lệ:** OLED tự động chuyển sang **`[CALIB GUIDE / HELP]`** hướng dẫn người dùng nhập đúng số `10`, `20`, `30`.

---

### 4. BỘ LỌC ĐỒNG THUẬN XU HƯỚNG THÍCH NGHI (ADAPTIVE TREND CONSENSUS FILTER):
* **Khi vật thể đứng yên:** Triệt tiêu hoàn toàn nhiễu quang học $\pm 1..2\text{ mm}$, **số đo đứng yên 100% không rung giật**.
* **Khi dịch chuyển $1\text{ mm}$:** Bộ tích lũy xu hướng xác nhận dịch chuyển thực sau 3 mẫu (~150 ms) và **nhảy số mịn từng $1\text{ mm}$ ($300 \rightarrow 301 \rightarrow 302$)**, không bị nhảy cóc 4 mm.
* **Khi di chuyển nhanh:** Hệ số bám tự động chuyển sang $\alpha = 0.85$ để bám sát chuyển động tức thì.

---

### 5. CƠ CHẾ CHỐNG TREO MÀN HÌNH OLED SSD1306:
* **Lọc vi sai (Dirty Buffer Check):** Chỉ phát lệnh I2C khi có điểm ảnh thay đổi hoặc mỗi 1 giây (Heartbeat), giảm 85% tải trên bus I2C.
* **Auto-Recovery Watchdog:** Nếu I2C bị lỗi/NACK 2 lần liên tiếp, tự động `HAL_I2C_DeInit` $\rightarrow$ `HAL_I2C_Init` $\rightarrow$ `OLED_Init` để phục hồi tức thì.
