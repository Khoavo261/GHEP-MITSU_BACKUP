# HƯỚNG DẪN HIỆU CHUẨN (CALIB) LOADCELL ĐO LỰC CĂNG (WEIGHT CALIBRATION)
### HỆ THỐNG MÁY GHÉP MÀNG METALIZE - PLC MITSUBISHI Q02U & HMI WEINTEK

---

## 📌 1. BẢNG PHÂN BỔ ĐỊA CHỈ Ô NHỚ 4 TRỤC LOADCELL (CHUẨN HÓA M & U)

| Trục | Ký hiệu | Chức năng chi tiết | Lực căng thực tế (kg/N) | Nút Set Zero (Tare) | **Ô nhớ Zero Offset (Điểm 0)** | Nút Calib Span | **Ô nhớ Calib Gain** | Mã chọn trục HMI (`D610`) |
| :--- | :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Cuộn Thu** | **T** | Thu cuộn màng thành phẩm | `D510` (Float) | `M110` | **`D852`** (Float) | `M120` | **`D830`** (Float) | **1** |
| **Trục Kéo Xả** | **X1** | Kéo xả cấp liệu | `D512` (Float) | `M111` | **`D854`** (Float) | `M121` | **`D832`** (Float) | **2** |
| **Thắng Từ Metalize** | **M** | **Thắng từ xả màng Metalize** | `D514` (Float) | `M112` | **`D856`** (Float) | `M122` | **`D834`** (Float) | **6** |
| **Cuộn Xả Sau Cùng** | **U** | **Cuộn Xả (Unwind) sau cùng** | `D516` (Float) | `M113` | **`D858`** (Float) | `M123` | **`D836`** (Float) | **7** |

---

## 🎯 2. NGUYÊN LÝ HIỆU CHUẨN LOADCELL (2 BƯỚC CHUẨN)

Hệ thống tính toán lực căng theo phương trình tuyến tính chuẩn:

$$\text{Weight\_Net (kg)} = (\text{Raw\_ADC} - \text{Zero\_Offset}) \times \text{Calib\_Gain}$$

- **Bước 1: Zero Calibration (Set Tare - Điểm 0):** Xác định `Zero_Offset` (`D852..D858`) khi không có màng / không có tải.
- **Bước 2: Span Calibration (Hệ số Calib Gain):** Xác định độ nhạy khuếch đại `Calib_Gain` (`D830..D836`) khi treo quả cân chuẩn.

---

## 🛠️ 3. QUY TRÌNH THAO TÁC CALIB TRÊN MÀN HÌNH HMI WEINTEK

### Cách 1: Sử dụng Màn hình Tích hợp Đa Trục (Giao diện 1 Cửa sổ Tiện lợi)

Trên HMI, bạn quản lý tất cả các trục trên 1 giao diện duy nhất:
- Ô chọn trục: **`HMI_Axis_Select` (`D610`)**:
  - `1`: Trục Thu T
  - `2`: Trục Kéo Xả X1
  - `6`: **Thắng Từ Metalize M**
  - `7`: **Cuộn Xả Sau Cùng U**
- Ô xem/chỉnh Zero Offset: **`HMI_Disp_Zero_Offset` (`D608` - 32-bit Float)**.
- Ô xem/chỉnh Calib Gain: **`HMI_Disp_Calib_Gain` (`D618` - 32-bit Float)**.
- Nút **`SET ZERO`** (`HMI_Cmd_Zero_Set` - `M118`).
- Nút **`CALIB SPAN`** (`HMI_Cmd_Calib_Set` - `M119`).
- Nút **`LƯU CÀI ĐẶT`** (`HMI_Cmd_Save_PID` - `M125`).

#### Quy trình thực hiện:
1. **Chọn trục cần Calib:**
   - Tại ô **Chọn Trục** (`D610`), nhập mã trục tương ứng (1, 2, 6, 7).
   - Khi đổi trục, ô `HMI_Disp_Zero_Offset` (`D608`) và `HMI_Disp_Calib_Gain` (`D618`) sẽ tự động hiển thị giá trị hiện tại của trục đó.

2. **Hiệu chuẩn Điểm 0 (Zero Tare):**
   - Đảm bảo rulo loadcell đang **thả tự do hoàn toàn**, không luồn màng hoặc luồn màng chùng (không có lực căng).
   - Nhấn nút **`SET ZERO`** (`M118`) (hoặc nhập trực tiếp giá trị vào ô `D608`).
   - Kiểm tra ô hiển thị lực căng tương ứng trở về `0.0 kg`.

3. **Hiệu chuẩn Tải trọng chuẩn (Span Calib):**
   - Dùng một sợi dây luồn qua rulo loadcell theo đúng **góc ôm thực tế của màng khi máy chạy**.
   - Móc một quả cân chuẩn đã biết chính xác khối lượng (Ví dụ: quả cân $W_{chuẩn} = 5.0\text{ kg}$ hoặc $10.0\text{ kg}$).
   - Đọc giá trị đang hiển thị trên ô lực căng ($W_{hiển\_thị}$).
   - **Cách A (Tự động):** Nhấn nút **`CALIB SPAN`** (`M119`).
   - **Cách B (Thủ công):** Nhập giá trị hệ số Gain vào ô **`Calib Gain`** (`D618`):
     $$\text{Calib\_Gain\_Mới} = \text{Calib\_Gain\_Cũ} \times \left( \frac{W_{chuẩn}}{W_{hiển\_thị}} \right)$$
   - Nhấn nút **`LƯU CÀI ĐẶT`** (`M125`) để PLC chốt giá trị lưu vĩnh viễn vào các ô nhớ `D852..D858` và `D830..D836`.

---

### Cách 2: Thao tác bằng bảng ô nhớ riêng từng trục trên HMI

Nếu bạn thiết kế màn hình bảng chi tiết 4 trục:

| Thao tác / Hiển thị | Trục Thu T | Trục Kéo Xả X1 | Thắng Từ Metalize M | Cuộn Xả Sau Cùng U |
| :--- | :---: | :---: | :---: | :---: |
| **Nút bấm Set Zero** | `Zero_Set_T` (`M110`) | `Zero_Set_X1` (`M111`) | `Zero_Set_M` (`M112`) | `Zero_Set_U` (`M113`) |
| **Ô nhớ Zero Offset (Xem/Sửa)** | **`Zero_Offset_T` (`D852`)** | **`Zero_Offset_X1` (`D854`)** | **`Zero_Offset_M` (`D856`)** | **`Zero_Offset_U` (`D858`)** |
| **Nút bấm Calib Span** | `Calib_Set_T` (`M120`) | `Calib_Set_X1` (`M121`) | `Calib_Set_M` (`M122`) | `Calib_Set_U` (`M123`) |
| **Ô nhớ Calib Gain (Xem/Sửa)** | `Calib_Gain_T` (`D830`) | `Calib_Gain_X1` (`D832`) | `Calib_Gain_M` (`D834`) | `Calib_Gain_U` (`D836`) |
| **Lực căng thực tế (Hiển thị)** | `Weight_Net_T` (`D510`) | `Weight_Net_X1` (`D512`) | `Weight_Net_M` (`D514`) | `Weight_Net_U` (`D516`) |

---

## ⚡ 4. NHỮNG LƯU Ý QUAN TRỌNG KHI CALIB LOADCELL

> [!IMPORTANT]
> 1. **Góc ôm của dây treo quả cân:** Khi móc quả cân mẫu để Calib, dây kéo **bắt buộc phải ôm qua rulo loadcell đúng hướng và góc tiếp xúc** như lúc màng thực tế chạy qua.
> 2. **Kiểm tra độ rung cơ khí:** Khi nhấn Set Zero và Calib Span, đảm bảo cơ khí tĩnh, không có rung lắc.
> 3. **Bảo vệ hệ số Gain:** Hệ số `Calib_Gain` mặc định là `1.0`. Nếu hệ số tính ra $\le 0.0$, chương trình sẽ tự động bảo vệ về `1.0`.
