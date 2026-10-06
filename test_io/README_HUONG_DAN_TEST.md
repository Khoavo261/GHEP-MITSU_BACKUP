# HƯỚNG DẪN TEST TOÀN DIỆN CÁC MODULE I/O TRÊN PLC MITSUBISHI Q-SERIES

Thư mục này chứa bộ chương trình kiểm tra chuyên biệt từng module phần cứng và file cấu hình thẻ giao diện HMI Weintek theo đúng thứ tự cấu hình trên Rack PLC:

1. **`01_test_q68adv.st`**: Test Module Analog Input **Q68ADV** (Slot 0 - Head H00)
2. **`02_test_q68dav.st`**: Test Module Analog Output **Q68DAV** (Slot 1 - Head H10)
3. **`03_test_qd62d_slot2.st`**: Test Module Bộ đếm xung **QD62D #1** (Slot 2 - Head H20: Trục Thu T & Kéo X1)
4. **`04_test_qd62d_slot3.st`**: Test Module Bộ đếm xung **QD62D #2** (Slot 3 - Head H30: Trục Master X2 & Ghép Ms)
5. **`05_test_qx40.st`**: Test Module Ngõ vào số **QX40** (Slot 4 - Head H40: 16 ngõ vào X40..X4F)
6. **`06_test_qy10.st`**: Test Module Ngõ ra Relay **QY10** (Slot 5 - Head H50: 16 ngõ ra Y50..Y5F)
7. **`test_all_modules.st`**: Chương trình **tổng hợp** gom cả 6 module vào 1 POU duy nhất để nạp chạy thử toàn diện.
8. **`hmi.csv`**: File danh sách Tag chuẩn Weintek EasyBuilder Pro để import tạo màn hình Test I/O trên HMI.
9. **`test_io_labels_paste.tsv`**: Bảng Global Labels copy-paste 1-click vào GX Works2.
10. **`device_comments_test_io.csv`**: File Device Comment tiếng Việt nạp vào GX Works2.

---

## 🚀 1. HƯỚNG DẪN THAO TÁC TRÊN GX WORKS2 (1-CLICK NẠP CODE)

### Bước 1: Dán nhãn Global Labels
1. Mở file `test_io/test_io_labels_paste.tsv`.
2. Nhấn `Ctrl + A` -> `Ctrl + C`.
3. Trong GX Works2, mở mục **Global Label -> Global_Variables**. Click chuột vào dòng trống đầu tiên ở cột **Label Name** và nhấn `Ctrl + V`.

### Bước 2: Nạp Ghi Chú Thiết Bị (Device Comment)
1. Trong GX Works2, vào menu: **Project -> Device Comment -> Read from CSV File...**
2. Trỏ đến file `test_io/device_comments_test_io.csv` và nhấn Open. Toàn bộ chú thích tiếng Việt cho các biến test sẽ được điền tự động.

### Bước 3: Nạp Code ST Test
* **Nếu muốn test riêng lẻ từng module:** Tạo POU mới trong GX Works2 (ngôn ngữ Structured Text) rồi copy nội dung file tương ứng (`01_test_q68adv.st`, `02_test_q68dav.st`,...).
* **Nếu muốn test toàn bộ cả rack cùng lúc:** Tạo một POU tên là `TEST_ALL` (chọn kiểu Scan), copy toàn bộ nội dung file `test_all_modules.st` dán vào.

### Bước 4: Biên dịch
* Nhấn phím **`F4` (Rebuild All)** -> Đảm bảo báo **`0 Errors, 0 Warnings`**.

---

## 🖥️ 2. HƯỚNG DẪN IMPORT FILE `hmi.csv` VÀO WEINTEK EASYBUILDER PRO

1. Khởi động phần mềm **EasyBuilder Pro**, mở dự án HMI hiện tại.
2. Trên thanh công cụ, vào tab **Project -> Address** (hoặc mở cửa sổ **Address Tag Library**).
3. Nhấp vào nút **Import Tags** (hoặc *Import from CSV*).
4. Chọn file **`d:\data-2026\lap_top\GHEP-MITSU_BACKUP\test_io\hmi.csv`**.
5. Nhấn **OK**. Tất cả các tag điều khiển và giám sát (đèn báo, nút nhấn, số đếm, thanh trượt điện áp) sẽ được nạp đầy đủ vào thư viện Tag của HMI.
6. Thiết kế màn hình Test I/O:
   * **Trang Analog In:** Đặt 8 ô số hiển thị điện áp `ADC_Volt_CH1..CH8` (32-bit Float) và thanh Bar Graph 0..10V.
   * **Trang Analog Out:** Đặt 4 nút xuất áp nhanh (0V, 2.5V, 5V, 10V), 1 nút gạt bật Auto Sweep `DAC_AutoSweep_En`, và các thanh trượt chỉnh `DAC_Set_CH1..CH8`.
   * **Trang Encoder:** Đặt 4 ô số hiển thị xung 32-bit và 4 nút Reset xung về 0.
   * **Trang Digital In:** Đặt 16 đèn báo hiển thị trạng thái `X40..X4F` và 16 ô số đếm số lần kích xung.
   * **Trang Digital Out:** Đặt 16 công tắc Toggle bật/tắt rơ le `Y50..Y5F` và 1 nút bật chế độ đèn chạy rơ le tự động `QY10_AutoChaser_En`.

---

## 🔍 3. CHI TIẾT CÁCH THỬ NGHIỆM TỪNG MODULE TRÊN PHẦN CỨNG

### 🔹 Module 1: Q68ADV (Slot 0 - Analog Input)
* **Dải làm việc:** 0 ~ 10V (tương ứng giá trị số 0 ~ 16000).
* **Cách test:**
  - Dùng bộ phát dòng/áp chuẩn (hoặc chiết áp biến trở 10k nối nguồn 10V) đưa áp vào từng kênh CH1..CH8 (`V+` và `V-`).
  - Quan sát thanh ghi `D2000..D2007` (giá trị thô) và `D2008..D2022` (điện áp thực tế Volt).
  - Vặn chiết áp từ 0V -> 5V -> 10V: Giá trị Volt trên màn hình phải thay đổi mượt mà từ 0.00V đến 10.00V.

### 🔹 Module 2: Q68DAV (Slot 1 - Analog Output)
* **Dải xuất áp:** 0 ~ 10V (0 ~ 16000).
* **Cách test:**
  - Lấy đồng hồ vạn năng VOM (thang đo DC 20V), cắm que đỏ vào `V+`, que đen vào `COM` của kênh muốn thử.
  - **Cách 1 (Thử nhanh):** Bấm nút `2.5V` (`M1021`) -> Đồng hồ phải chỉ đúng ~2.50V; Bấm nút `5.0V` (`M1022`) -> Đồng hồ chỉ ~5.00V; Bấm nút `10.0V` (`M1023`) -> Đồng hồ chỉ ~10.00V.
  - **Cách 2 (Quét tự động Sweep):** Bật công tắc `DAC_AutoSweep_En` (`M1024` = ON). Điện áp trên đồng hồ sẽ tự động tăng dần từ 0V lên 10V rồi giảm dần về 0V liên tục.

### 🔹 Module 3 & 4: QD62D #1 & QD62D #2 (Slot 2 & Slot 3 - High Speed Counter)
* **Cách test:**
  - Cắm Encoder Line Driver (Pha A+, A-, B+, B-) vào cổng tương ứng của QD62D.
  - Dùng tay quay trục Encoder: Số xung trên thanh ghi `D2050 / D2052 / D2070 / D2072` phải tăng/giảm theo chiều quay.
  - Quay thử nhanh hoặc chậm: Ô hiển thị `Delta Pulse / 100ms` phải nhảy giá trị tỷ lệ thuận với tốc độ quay.
  - Bấm nút `Reset` trên HMI: Số xung lập tức quay về số `0`.

### 🔹 Module 5: QX40 (Slot 4 - Digital Input 24VDC)
* **Cách test:**
  - Dùng đoạn dây điện 24V chạm vào từng cọc đấu dây `X40` đến `X4F` (hoặc nhấn nút cơ ngoài tủ, gõ thử cảm biến tiệm cận kim loại).
  - Đèn LED trên mặt module QX40 sáng lên đồng thời đèn hiển thị trên HMI đổi màu xanh.
  - Bộ đếm sự kiện tương ứng (`D2100..D2115`) phải tăng thêm đúng `1` đơn vị sau mỗi lần kích. Nếu bấm 1 lần mà số đếm tăng nhiều đơn vị -> nút bấm/tiếp điểm bị dội rung.

### 🔹 Module 6: QY10 (Slot 5 - Digital Relay Output)
* **Cách test:**
  - **Test tay:** Bấm bật từng nút `Y50` đến `Y5F` trên HMI -> nghe tiếng rơ le trong module đóng "tách", đèn LED đỏ trên module tương ứng sáng lên, kiểm tra tiếp điểm thường mở thông mạch.
  - **Test tự động (Auto Chaser):** Bật công tắc `QY10_AutoChaser_En` (`M1116` = ON).
  - Module QY10 sẽ tự động đóng ngắt tuần tự: `Y50 -> Y51 -> Y52 -> ... -> Y5F -> Y50` theo nhịp 0.5 giây. Kỹ thuật viên quan sát hàng đèn LED đỏ chạy đuổi nhau như đèn sao băng để xác nhận 100% các rơ le ngõ ra đều hoạt động trơn tru.

---

### 🔹 Module 7: CC-Link ADC AJ65VBTCU-68ADVN (Trạm 1 - Ver.2 Quadruple)
* **File test:** [`07_test_cclink_68advn.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/test_io/07_test_cclink_68advn.st)
* **Dải làm việc:** 0 ~ 10V (tương ứng số 0 ~ 4000).
* **Vùng nhớ CC-Link:**
  * Dữ liệu Analog đọc về: `W100..W107` (CH1..CH8).
  * Cờ Ready trạm 1: `X101B`, Cờ Lỗi: `X101A`, Nút Reset Lỗi: `M605` (`Y101A`).
* **Cách test:**
  - Cấp điện áp 0..10V vào chân `V+` và `V-` của từng kênh trên module 68ADVN.
  - Quan sát thanh ghi thô `D600..D607` và điện áp quy đổi mV trên `D610..D617` (ví dụ đưa vào 5.0V thì `D600` hiển thị 2000, `D610` hiển thị 5000 mV).

---

### 🔹 Module 8: CC-Link DAC AJ65VBTCU-68DAVN (Trạm 2 - Ver.2 Quadruple)
* **File test:** [`08_test_cclink_68davn.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/test_io/08_test_cclink_68davn.st)
* **Dải xuất áp:** 0 ~ 10V (tương ứng số 0 ~ 4000).
* **Vùng nhớ CC-Link:**
  * Cho phép xuất áp 8 kênh: `Y1040..Y1047` (chương trình tự động duy trì ON khi mạng OK).
  * Dữ liệu xuất áp: `W210..W217` (nhập từ `D650..D657`).
  * Cờ Ready trạm 2: `X105B`, Cờ Lỗi: `X105A`, Nút Reset Lỗi: `M645` (`Y105A`).
* **Cách test:**
  - Lấy đồng hồ vạn năng VOM cắm vào `V+` và `COM` của kênh cần thử trên module 68DAVN.
  - **Thử nhanh 4 mức áp:** Kích bit `M650` (0V), `M651` (2.5V), `M652` (5.0V), `M653` (10.0V) -> đồng hồ VOM hiển thị đúng mức áp tương ứng.
  - **Quét áp tự động Sweep:** Bật bit `M654` = TRUE. Cả 8 kênh ngõ ra sẽ tự động tăng dần đều từ 0V lên 10V rồi giảm dần về 0V liên tục theo chu kỳ mỗi 100ms.

