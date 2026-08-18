# 🌟 GIẢI PHÁP VẬN HÀNH TỐI GIẢN (1 NÚT BẤM) CHO CÔNG NHÂN ĐỨNG MÁY
### DÂY CHUYỀN MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - PLC Q02U & HMI WEINTEK

---

## 🎯 MỤC TIÊU CỐT LÕI
Biến một cỗ máy ghép màng 7 trục phức tạp trở nên **cực kỳ đơn giản, an toàn và chống thao tác sai (Foolproof / Poka-Yoke)**:
1. **Công nhân không cần nhớ thông số kỹ thuật** (PID, Gain, Tỷ số truyền, Torque...).
2. **Khởi động chạy máy chỉ bằng 1 nút bấm (One-Touch Start)**.
3. **Phân quyền rõ ràng**: Công nhân chỉ thấy nút bấm lớn, trang cài đặt sâu được khóa mật khẩu kỹ sư.

---

## 🚀 5 TÍNH NĂNG ĐỘT PHÁ TỐI GIẢN HÓA CHO CÔNG NHÂN

```
+---------------------------------------------------------------------------------------------------+
|  [ CHỌN ĐƠN HÀNG: HÀNG MÀNG BOPP 20MIC ]      | TRẠNG THÁI: [ SẴN SÀNG CHẠY ]       18/08/2026   |
+-----------------------------------------------+---------------------------------------------------+
|               TỐC ĐỘ HIỆN TẠI                 |                 TỔNG SỐ MÉT ĐÃ GHÉP               |
|            [    45.0 m/phút    ]              |                 [   1,850.5 mét   ]               |
+-----------------------------------------------+---------------------------------------------------+
|   🟢 [ CHẠY MÁY TỰ ĐỘNG ]                     |   🔄 [ NẠP CUỘN MỚI & RESET MÉT ]                 |
|      (Tự bò mồi màng -> Tự đóng Pen -> Tự chạy)|      (Bấm 1 nút tự reset cả 3 cuộn T, M, U)      |
|                                               |                                                   |
|   🔴 [ DỪNG MÁY AN TOÀN ]                     |   🐢 [ BÒ CHẬM NỐI MÀNG (2 m/p) ]                 |
|      (Tự nhả 2 Pen -> Tự hãm dừng êm)         |      (Nhấn giữ để luồn nối màng an toàn)          |
|                                               |                                                   |
|   ⬆️ [ TĂNG TỐC + ]     ⬇️ [ GIẢM TỐC - ]     |   🔒 [ CÀI ĐẶT KỸ THUẬT (CẦN MẬT KHẨU) ]          |
+-----------------------------------------------+---------------------------------------------------+
| 💡 HƯỚNG DẪN: Máy đang sẵn sàng. Đặt cuộn màng xong bấm [NẠP CUỘN MỚI] rồi bấm [CHẠY MÁY].        |
+---------------------------------------------------------------------------------------------------+
```

---

### 1️⃣ Nút bấm thông minh "NẠP CUỘN MỚI TOÀN BỘ (1-CLICK)"
* **Vấn đề cũ:** Công nhân phải nhớ bấm 3 nút riêng cho Cuộn Thu T, Thắng Metalize M, Cuộn Xả U và nút Reset mét. Nếu quên 1 nút $\rightarrow$ Lực căng tính sai làm đứt màng.
* **Giải pháp mới:** Tạo 1 nút to duy nhất **`[ THAY CUỘN MỚI TOÀN BỘ ]`**:
  * Khi công nhân gá xong cuộn giấy/màng mới $\rightarrow$ Chỉ bấm 1 nút này.
  * PLC tự động: Reset Ø Thu T về lõi, Reset Ø Metalize M về Max, Reset Ø Xả U về Max và Xóa mét về `0.0 m`.

---

### 2️⃣ Tự Động Hóa Hoàn Toàn Quy Trình Khởi Động & Đóng Pen Ép
* **Vấn đề cũ:** Công nhân phải bấm Start $\rightarrow$ Canh tốc độ tăng lên $\rightarrow$ Nhớ bấm đóng Pen 1 $\rightarrow$ Nhớ bấm đóng Pen 2. Nếu đóng Pen trễ thì hỏng màng, nếu quên nhả Pen khi dừng thì rách màng.
* **Giải pháp mới (Tự động thông minh trong PLC):**
  1. Khi nhấn **`START`**: Máy tự động kiểm tra 5 Servo. Nếu đủ an toàn $\rightarrow$ Tự động chạy bò mồi `2.0 m/phút` trong 3 giây để kéo căng đều mép màng.
  2. Khi tốc độ vượt ngưỡng `5.0 m/phút` $\rightarrow$ **PLC tự động kích đóng Van Pen 1 và Pen 2** (Công nhân không cần đụng tay!).
  3. Tự động kích hoạt toàn bộ PID lực căng mượt mà tăng tốc lên tốc độ cài đặt.
  4. Khi nhấn **`STOP`** hoặc máy tự dừng đủ mét $\rightarrow$ **PLC tự động nhả 2 Pen ép màng ngay lập tức**.

---

### 3️⃣ Quản Lý Theo "Công Thức Đơn Hàng (Recipe)" - 1 Chạm Chọn Hàng
* **Thanh ghi chọn công thức:** **`HMI_Recipe_Select` (`D604` - INT)**.
* **Cài đặt Menu thả xuống (Option List / Drop-Down) trên EasyBuilder Pro:**
  * Gán địa chỉ đọc/ghi: `D604` (16-bit Signed).
  * Danh sách các loại hàng cài sẵn:
    1. **`1: Màng Mỏng 12~15mic (Bánh kẹo)`** $\to$ Tốc độ `45 m/p`, Thu T `12 kg`, Kéo X1 `10 kg`, Thắng M `4 kg`, Xả U `8 kg`, Taper `15%`, ACC `0.05`.
    2. **`2: Màng Tiêu Chuẩn 18~20mic (Hộp bánh/trà/cà phê)`** $\to$ Tốc độ `60 m/p`, Thu T `16 kg`, Kéo X1 `14 kg`, Thắng M `6 kg`, Xả U `12 kg`, Taper `20%`, ACC `0.08`.
    3. **`3: Giấy Dày Duplex/Ivory 250~350g`** $\to$ Tốc độ `50 m/p`, Thu T `25 kg`, Kéo X1 `22 kg`, Thắng M `8 kg`, Xả U `18 kg`, Taper `25%`, ACC `0.06`.
    4. **`4: Màng Nhôm Foil Alu/PET Dẻo`** $\to$ Tốc độ `40 m/p`, Thu T `10 kg`, Kéo X1 `8 kg`, Thắng M `3.5 kg`, Xả U `7 kg`, Taper `15%`, ACC `0.04`.
    5. **`5: Chế Độ Tùy Chỉnh (Custom)`** $\to$ Cho phép tự nhập số tay tùy ý.
* **Thao tác công nhân:** Khi đổi ca / đổi đơn hàng $\to$ Chỉ cần chọn tên đơn hàng trên menu thả xuống $\to$ PLC tự động nạp toàn bộ tốc độ, lực căng và gia tốc trong chớp mắt!

---

### 4️⃣ Chế Độ Bò Chậm Nối Màng (Crawl / Jogging 2.0 m/phút)
* Thiết kế nút to **`[ BÒ CHẬM NỐI MÀNG ]`** (Chế độ Momentary - Nhấn giữ thì chạy bò `2 m/p`, thả tay ra thì dừng).
* Giúp công nhân dán băng keo nối đầu cuộn màng hoặc căn mép biên cực kỳ an toàn, không sợ máy giật tốc độ cao.

---

### 5️⃣ Thông Báo Lỗi Bằng Tiếng Việt Rõ Ràng (Smart Troubleshooting)
Thay vì hiện mã lỗi kỹ thuật khó hiểu (như `Alarm #04`, `Fault Bit M134`), HMI sẽ hiện thẳng câu hướng dẫn xử lý bằng tiếng Việt:
* ⚠️ *"Chưa bật Servo Trục Kéo X1 $\rightarrow$ Vui lòng kiểm tra CB nguồn Aptomat"*
* ⚠️ *"Đã hoàn thành đơn hàng 3,000 mét $\rightarrow$ Máy đã tự dừng an toàn"*
* ⚠️ *"Lực căng cuộn xả U quá cao $\rightarrow$ Kiểm tra có bị kẹt rulo màng không"*

---

## 📋 BẢNG TỔNG HỢP NÚT BẤM CHO MÀN HÌNH CÔNG NHÂN (DỄ DÙNG NHẤT)

| Nút Bấm / Hiển Thị | Tên Thao Tác | Địa Chỉ PLC | Mô Tả Cho Công Nhân |
| :--- | :--- | :---: | :--- |
| 🟢 **NÚT START** | **CHẠY MÁY TỰ ĐỘNG** | `M102` | Bấm 1 lần để chạy máy (Mọi thứ tự động hoàn toàn) |
| 🔴 **NÚT STOP** | **DỪNG MÁY** | `M103` | Bấm 1 lần để dừng máy an toàn |
| 🔄 **NÚT THAY CUỘN** | **NẠP CUỘN MỚI TOÀN BỘ** | Macro / `M104+M105+M106+M107` | Gá cuộn mới xong bấm nút này để làm mới dữ liệu |
| 🐢 **NÚT BÒ NỐI MÀNG** | **BÒ CHẬM 2 m/p** | `M109` (ở chế độ Manual) | Giữ để bò chậm luồn nối màng, thả tay tự dừng |
| ⬆️ **NÚT TĂNG TỐC** | **TĂNG TỐC ĐỘ (+)** | `M109` | Bấm để tăng nhanh thêm 5 m/phút |
| ⬇️ **NÚT GIẢM TỐC** | **GIẢM TỐC ĐỘ (-)** | `M114` | Bấm để giảm chậm bớt 5 m/phút |
