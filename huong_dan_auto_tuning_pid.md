# HƯỚNG DẪN CHI TIẾT VẬN HÀNH AUTO-TUNING PID CHO HỆ THỐNG MÁY GHÉP GIẤY METALIZE

Tài liệu này hướng dẫn chi tiết quy trình thực hiện **Auto-Tuning PID (Tự động dò tìm thông số $K_p, K_i, K_d$)** lần lượt cho từng trục trên hệ thống máy ghép giấy sử dụng PLC Mitsubishi Q02U và màn hình HMI Weintek.

---

## 1. NGUYÊN LÝ HOẠT ĐỘNG CỦA CHỨC NĂNG AUTO-TUNING

* **Thuật toán sử dụng**: *Relay Feedback Limit-Cycle (Ziegler-Nichols cải tiến chống vọt lố)*.
* **Cơ chế**: Khi bạn kích hoạt Auto-Tune cho một trục:
  1. PLC sẽ tạo ra các dao động bước nhảy nhỏ ($\pm 200$ đơn vị DAC $\approx 5\%$ biên độ) quanh giá trị lực căng cài đặt (`Setpoint`).
  2. PLC tự động đo:
     - **Chu kỳ dao động riêng ($T_u$)**: Thời gian phản hồi cơ học của quán tính cuộn giấy.
     - **Độ khuếch đại giới hạn ($K_u$)**: Biên độ phản hồi thực tế từ cảm biến Loadcell / Encoder.
  3. Sau đúng **3 chu kỳ dao động** (khoảng $5 \sim 10$ giây), PLC tự động tính ra bộ thông số $K_p, K_i, K_d$ tối ưu nhất, tự động lưu vào bộ nhớ trục đó và **tự ngắt Auto-Tune** chuyển về chế độ chạy êm.

---

## 2. BẢNG ĐỊA CHỈ GIAO TIẾP HMI & PLC CHO AUTO-TUNING

| Tên Đối Tượng HMI | Địa chỉ PLC | Kiểu Dữ Liệu | Chức năng trên giao diện |
| :--- | :--- | :--- | :--- |
| **Dropdown Chọn Trục** | **`D610`** | `16-bit Signed` (INT) | Chọn trục muốn Auto-Tune (**1**=Thu T, **2**=Xả X1, **3**=Master X2, **4**=Ghép Ms, **5**=Dầu S, **6**=Thắng M, **7**=Xả U) |
| **Nút AUTO-TUNE** | **`M126`** | `Bit` (Momentary) | Nhấn để bắt đầu dò thông số cho trục đang chọn |
| **Đèn ĐANG DÒ (Busy)** | **`M127`** | `Bit` (Indicator) | **SÁNG** khi PLC đang phát xung dao động test |
| **Đèn DÒ XONG (Done)** | **`M128`** | `Bit` (Indicator) | **SÁNG** báo hoàn thành, đã tự nạp $K_p, K_i, K_d$ |
| **Ô hiển thị $K_p$** | **`D612`** | `32-bit Float` | Hiển thị giá trị $K_p$ vừa dò được |
| **Ô hiển thị $K_i$** | **`D614`** | `32-bit Float` | Hiển thị giá trị $K_i$ vừa dò được |
| **Ô hiển thị $K_d$** | **`D616`** | `32-bit Float` | Hiển thị giá trị $K_d$ vừa dò được |
| **Nút LƯU CÀI ĐẶT** | **`M125`** | `Bit` (Momentary) | Nhấn để lưu thủ công nếu có chỉnh sửa thêm |

---

## 3. THỨ TỰ VÀ QUY TRÌNH THỰC HIỆN TỪNG BƯỚC (SOP)

### Giai đoạn 1: Chuẩn bị cơ khí và màng giấy
1. Lắp cuộn giấy và cuộn màng metalize vào các trục xả và luồn qua các lô kéo, lô ghép đến trục thu T.
2. Căn chỉnh áp lực 2 Pen ép màng hoạt động tốt.
3. Kiểm tra các cảm biến Loadcell đã được **Set Zero** khi chưa có giấy đè lên.

---

### Giai đoạn 2: Vận hành chạy máy lấy điểm làm việc nền
1. Khởi động máy ở chế độ tự động, tăng tốc độ lên mức trung bình ổn định: **$20 \sim 30\text{ m/phút}$**.
2. Quan sát màng giấy chạy thẳng hàng, không bị chùng hay nhăn.

---

### Giai đoạn 3: Thực hiện Auto-Tuning lần lượt từng trục

> [!TIP]
> **Thứ tự Auto-Tune tối ưu nhất cho dây chuyền:**
> **Trục Kéo Giấy X1** $\to$ **Trục Thu T** $\to$ **Trục Xả Metalize U / Thắng M** $\to$ **Trục Ghép Ms / Dầu S**.

#### 1. Auto-Tune TRỤC KÉO GIẤY X1 (Loadcell X1):
* Trên HMI chọn: **`D610 = 2`** *(Trục Xả X1)*.
* Nhấn nút **`AUTO-TUNE` (`M126`)**.
* **Hiện tượng quan sát**: Đèn `M127` sáng. Lực căng Loadcell X1 sẽ nhấp nhô nhẹ quanh giá trị đặt $12.0\text{ kg}$ trong khoảng $5 \sim 8\text{ giây}$.
* **Kết thúc**: Đèn `M128` sáng, cờ `M126` tự tắt. Các ô `D612, D614, D616` hiển thị bộ thông số vừa tìm được (Ví dụ: $K_p \approx 1.2 \dots 1.8$, $K_i \approx 0.1 \dots 0.3$, $K_d \approx 0.05$).

#### 2. Auto-Tune TRỤC CUỘN THU T (Loadcell T):
* Trên HMI chọn: **`D610 = 1`** *(Trục Thu T)*.
* Nhấn nút **`AUTO-TUNE` (`M126`)**.
* Quan sát cuộn thu T tự điều chỉnh lực xiết trong 3 chu kỳ.
* Khi hoàn tất, bộ số $K_p, K_i, K_d$ trục T tự động cập nhật.

#### 3. Auto-Tune TRỤC XẢ METALIZE U & THẮNG TỪ M:
* Lần lượt chọn **`D610 = 7`** (Trục U) và **`D610 = 6`** (Thắng M), sau đó nhấn **`AUTO-TUNE`** cho từng trục.

---

## 4. BẢNG GHI NHẬN KẾT QUẢ BÁO CÁO (BẠN ĐIỀN VÀO ĐÂY)

Sau khi bấm Auto-Tune từng trục, bạn ghi lại các giá trị hiển thị trên HMI vào bảng dưới đây để cùng đánh giá:

| STT | Trục Điều Khiển | Giá trị $K_p$ tìm được | Giá trị $K_i$ tìm được | Giá trị $K_d$ tìm được | Đánh giá độ êm màng giấy |
| :---: | :--- | :---: | :---: | :---: | :--- |
| **1** | **Trục Thu T** (`D610=1`) | ............ | ............ | ............ | Cuộn chặt, không bị xô lệch |
| **2** | **Trục Kéo X1** (`D610=2`) | ............ | ............ | ............ | Giấy phẳng, lực căng ổn định |
| **3** | **Trục Master X2** (`D610=3`) | ............ | ............ | ............ | Tốc độ dây chuyền chuẩn xác |
| **4** | **Trục Ghép Ms** (`D610=4`) | ............ | ............ | ............ | Ép keo đều, không nhăn |
| **5** | **Trục Dầu S** (`D610=5`) | ............ | ............ | ............ | Tráng dầu mịn |
| **6** | **Trục Thắng M** (`D610=6`) | ............ | ............ | ............ | Thắng từ giữ đều |
| **7** | **Trục Xả Metalize U** (`D610=7`)| ............ | ............ | ............ | Màng nhôm không bị dãn |

---

## 5. HƯỚNG DẪN XỬ LÝ NHANH CÁC TÌNH HUỐNG THỰC TẾ

1. **Nếu sau khi Auto-Tune lực căng vẫn dao động gợn sóng nhẹ**:
   - Giảm $K_p$ đi khoảng $20\%$ (Ví dụ: từ `1.5` giảm xuống `1.2`).
2. **Nếu sau khi Auto-Tune lực căng bám tới điểm đặt hơi chậm**:
   - Tăng nhẹ $K_i$ lên một chút (Ví dụ: từ `0.1` lên `0.15`).
3. **Nếu lúc bấm tăng tốc nhanh (phím INC) bị vọt lực căng**:
   - Tăng nhẹ $K_d$ (Ví dụ: từ `0.02` lên `0.05`).
