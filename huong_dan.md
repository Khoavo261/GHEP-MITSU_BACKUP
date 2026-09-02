# 📖 TÀI LIỆU HƯỚNG DẪN VẬN HÀNH, CÀI ĐẶT THÔNG SỐ & THIẾT KẾ HMI MÁY GHÉP METALIZE

**Dự án:** Hệ thống Điều Khiển Dây Chuyền Máy Ghép Màng Metalize Tự Động  
**PLC:** Mitsubishi **Q02UCPU** (Base Rack trực tiếp: Q68ADV, Q68DAV, QD62D, QX40, QY40)  
**HMI:** Màn hình cảm ứng **Weintek** (Phần mềm thiết kế **EasyBuilder Pro**)  
**Chuẩn dữ liệu:** Số thực **32-bit Float (REAL)** & Vùng nhớ **Liên tục 100%**  

---

## 📑 MỤC LỤC
1. [Trang Cài Đặt Đa Năng Thông Minh (Index Register - 1 Trang Cho 7 Trục)](#1-trang-cài-đặt-đa-năng-thông-minh-index-register---1-trang-cho-7-trục)
2. [Trang Hướng Dẫn Vận Hành Dành Cho Công Nhân (Giao Diện 1-Chạm)](#2-trang-hướng-dẫn-vận-hành-dành-cho-công-nhân-giao-diện-1-chạm)
3. [Trang Setup Thông Số Máy & Cân Chỉnh Loadcell](#3-trang-setup-thông-số-máy--cân-chỉnh-loadcell)
4. [Bảng Tra Cứu Toàn Bộ Địa Chỉ Vùng Nhớ Liên Tục (Memory Map)](#4-bảng-tra-cứu-toàn-bộ-địa-chỉ-vùng-nhớ-liên-tục-memory-map)
5. [Quy Trình Nạp Chương Trình Lên PLC & HMI](#5-quy-trình-nạp-chương-trình-lên-plc--hmi)

---

## 🎯 1. TRANG CÀI ĐẶT ĐA NĂNG THÔNG MINH (INDEX REGISTER - 1 TRANG CHO 7 TRỤC)

### 💡 Nguyên lý thiết kế tối giản:
Thay vì phải tạo 7 trang màn hình hoặc vẽ hàng chục ô nhập số rối mắt trên HMI, hệ thống sử dụng **Thanh ghi Index `HMI_Axis_Select` (`D600`)** để dùng chung **duy nhất 1 trang cài đặt** cho cả 7 trục:

```
[ Menu Chọn Trục: 1. Thu T | 2. Xả X1 | 3. Master X2 | 4. Ghép Ms | 5. Dầu S | 6. Thắng M | 7. Xả U ]
─────────────────────────────────────────────────────────────────────────────────────────────
  * Hệ số Kp : [ D602 (Float) ]       * Zero Offset : [ D610 (Float) ]
  * Hệ số Ki : [ D604 (Float) ]       * Calib Gain  : [ D608 (Float) ]
  * Hệ số Kd : [ D606 (Float) ]
─────────────────────────────────────────────────────────────────────────────────────────────
  [ NÚT LƯU THÔNG SỐ (M41) ]   [ NÚT BẬT AUTO-TUNE (M40) ]   [ ZERO SET (M28) ]   [ CALIB SET (M29) ]
  (Đèn báo Busy: M42 | Đèn báo Hoàn tất: M43)
```

### 📋 Bảng Ánh Xạ Thanh Ghi Trang Index HMI:

| Đối Tượng HMI | Địa Chỉ PLC | Kiểu Dữ Liệu | Chức Năng Hoạt Động |
| :--- | :---: | :---: | :--- |
| **Chọn Trục Cần Chỉnh** | **`D600`** | `16-bit Signed` | Nhập số **1..7** (hoặc dùng Drop-down / Radio Button trên HMI):<br>• `1`: Trục Thu T | `2`: Trục Xả X1 | `3`: Trục Master X2<br>• `4`: Trục Ghép Ms | `5`: Trục Dầu S | `6`: Trục Thắng M | `7`: Trục Xả U |
| **Ô Nhập Hệ Số Kp** | **`D602`** | `32-bit Float` | Tự động tải Kp của trục đang chọn lên màn hình / Nhập Kp mới |
| **Ô Nhập Hệ Số Ki** | **`D604`** | `32-bit Float` | Tự động tải Ki của trục đang chọn lên màn hình / Nhập Ki mới |
| **Ô Nhập Hệ Số Kd** | **`D606`** | `32-bit Float` | Tự động tải Kd của trục đang chọn lên màn hình / Nhập Kd mới |
| **Ô Nhập Calib Gain** | **`D608`** | `32-bit Float` | Hệ số tỷ lệ khuếch đại Loadcell (áp dụng cho trục 1, 2, 6, 7) |
| **Ô Nhập Zero Offset** | **`D610`** | `32-bit Float` | Giá trị điểm 0 Loadcell khi không tải |
| **Nút LƯU THÔNG SỐ** | **`M41`** | `Bit (Set ON)` | Nhấn nút này, PLC sẽ copy Kp, Ki, Kd, Calib vào vùng nhớ của trục đó |
| **Nút BẬT AUTO-TUNE** | **`M40`** | `Bit (Set ON)` | Kích hoạt tự động dò tìm thông số PID tối ưu cho trục đang chọn |
| **Nút ZERO SET CHUNG** | **`M28`** | `Bit (Set ON)` | Lấy điểm 0 tức thời cho trục đang chọn |
| **Nút CALIB SET CHUNG** | **`M29`** | `Bit (Set ON)` | Chốt hệ số Calib tải trọng mẫu cho trục đang chọn |
| **Đèn Đang Auto-Tune** | **`M42`** | `Bit (Lamp)` | Sáng khi thuật toán dò thông số đang chạy |
| **Đèn Hoàn Tất Auto-Tune** | **`M43`** | `Bit (Lamp)` | Sáng khi dò xong $\rightarrow$ Thông số tự nạp vào ô hiển thị |

---

## 🚀 2. TRANG HƯỚNG DẪN VẬN HÀNH DÀNH CHO CÔNG NHÂN (GIAO DIỆN 1-CHẠM)

Màn hình vận hành chính được thiết kế để công nhân thao tác cực kỳ đơn giản, không sợ bấm nhầm:

### 🔹 Các Bước Vận Hành Tiêu Chuẩn:
1. **Bước 1 (Thay cuộn màng):** Sau khi gắn các cuộn màng mới lên trục Thu T, Thắng M và Xả U, nhấn **`NÚT THAY CUỘN MỚI 1-CLICK` (`M8`)** $\rightarrow$ Hệ thống tự động đặt lại đường kính chuẩn (Thu T về 76mm, Thắng M và Xả U về cuộn đầy) và reset mét về 0.
2. **Bước 2 (Chọn đơn hàng):** Chọn loại đơn hàng tương ứng tại ô **`HMI_Recipe_Select` (`D2`)**:
   - `1`: Hàng Màng Mỏng (BOPP 12~15 mic - 45 m/phút)
   - `2`: Hàng Tiêu Chuẩn (BOPP 18~20 mic + Giấy 100~150g - 60 m/phút)
   - `3`: Hàng Giấy Dày / Bìa Cứng (Duplex/Ivory 250~350g - 50 m/phút)
   - `4`: Hàng Màng Nhôm / Foil Dẻo Cao Cấp (Alu Foil 9~12 mic - 40 m/phút)
   - `5`: Chế độ Tùy Chỉnh (Custom)
   - Nhấn nút **`ÁP DỤNG CÔNG THỨC` (`M15`)** để nạp tốc độ và lực căng chuẩn.
3. **Bước 3 (Luồn màng ban đầu):** Nhấn giữ nút **`BÒ CHẬM NỐI MÀNG` (`M14` hoặc nút vật lý `X49`)** để máy chạy chậm $2\text{ m/phút}$ giúp công nhân luồn màng và dán băng keo nối màng an toàn.
4. **Bước 4 (Chạy tự động):** Nhấn **`START` (`M2` hoặc `X45`)** $\rightarrow$ Máy tự động tăng tốc êm ái đến tốc độ cài đặt, 2 Pen ép màng tự động hạ xuống khi đạt vận tốc trên $5\text{ m/phút}$.
5. **Bước 5 (Tăng/Giảm tốc khi đang chạy):** Nhấn giữ phím **`INC` (`M10`)** để tăng tốc hoặc **`DEC` (`M11`)** để giảm tốc lũy tiến theo thời gian giữ nút.
6. **Bước 6 (Tự động hãm dừng khi đủ mét):** Khi tổng số mét (`D12`) chạm khoảng cách hãm dừng sớm (`D112`), máy tự động giảm tốc về $2\text{ m/phút}$ và tự động dừng hẳn khi đạt đủ số mét cài đặt (`D14`).

### 📋 Bảng Mã Trạng Thái Hiển Thị Tiếng Việt Trên HMI (`D1`):

| Giá Trị `D1` | Nội Dung Hiển Thị Trên HMI | Màu Sắc / Trạng Thái Đèn Tháp |
| :---: | :--- | :--- |
| **`0`** | **MÁY DỪNG - SẴN SÀNG CHẠY** | Đèn tháp Vàng sáng (`Y59`) |
| **`1`** | **SỰ CỐ: KIỂM TRA 5 TRỤC SERVO NOT READY!** | Đèn tháp Đỏ nhấp nháy (`Y5A`) + Còi báo (`Y57`) |
| **`2`** | **DÂY CHUYỀN ĐANG CHẠY TỰ ĐỘNG** | Đèn tháp Xanh sáng (`Y58`) |
| **`3`** | **ĐANG BÒ CHẬM LUỒN MÀNG (2 m/phút)** | Đèn tháp Vàng sáng (`Y59`) |
| **`4`** | **HOÀN THÀNH ĐƠN HÀNG - ĐÃ ĐẠT ĐỦ SỐ MÉT** | Đèn tháp Xanh nhấp nháy báo hiệu |

---

## ⚙️ 3. TRANG SETUP THÔNG SỐ MÁY & CÂN CHỈNH LOADCELL

### 🔹 1. Cài đặt Thông số Cơ khí Máy (D200..D240):
* **Tỷ số truyền hộp số (`Gear_Ratio`):**
  - `D200` (Thu T) = `10.1`, `D202` (Kéo X1) = `8.0`, `D204` (Master X2) = `8.0`, `D206` (Ghép Ms) = `10.0`, `D208` (Dầu S) = `10.0`.
* **Đường kính lô máy (`Roller Diameter`):**
  - `D222` (Lô Kéo X1) = `300.5 mm`, `D224` (Lô Master X2) = `300.5 mm`, `D226` (Lô Ghép Ms) = `200.0 mm`, `D228` (Lô Dầu S) = `100.0 mm`.
* **Đường kính cuộn màng (`Core / Max Dia`):**
  - Lõi cuộn: `D230` (Thu T) = `76.0 mm`, `D232` (Thắng M) = `76.0 mm`, `D234` (Xả U) = `76.0 mm`.
  - Đường kính cuộn Max: `D236` (Thu T) = `1000.0 mm`, `D238` (Thắng M) = `600.0 mm`, `D240` (Xả U) = `800.0 mm`.

---

### 🔹 2. Quy Trình Cân Chỉnh (Calib) Loadcell Lực Căng 0..50kg:
Hệ thống sử dụng bộ chuyển đổi 0..10V = 0..16000 tương ứng 0..50kg:
1. **Lấy điểm 0 (Zero Calibration):**
   - Đảm bảo quả lô loadcell đang ở trạng thái tự do, không mắc màng.
   - Trên HMI chọn trục cần chỉnh (ví dụ Trục 1 = Thu T) $\rightarrow$ Nhấn nút **`ZERO SET` (`M28` hoặc `M20`)**.
   - PLC sẽ tự động lưu giá trị điện áp tĩnh vào ô `Zero_Offset_T` (`D300`).
2. **Cân chỉnh tải mẫu (Span Calibration):**
   - Treo quả cân chuẩn (ví dụ quả cân chuẩn $10.0\text{ kg}$) lên giữa quả lô Loadcell.
   - Nhập trọng lượng quả cân $10.0$ vào ô Calib $\rightarrow$ Nhấn nút **`CALIB SET` (`M29` hoặc `M24`)**.
   - PLC sẽ tự động tính toán hệ số `Calib_Gain_T` (`D310`) chuẩn xác 100%.

---

## 📊 4. BẢNG TRA CỨU TOÀN BỘ ĐỊA CHỈ VÙNG NHỚ LIÊN TỤC (MEMORY MAP)

### 1. Bảng Thanh Ghi D (Data Registers):

| Vùng Nhớ | Dải Địa Chỉ | Kiểu Dữ Liệu | Tên Biến Global | Ý Nghĩa Chức Năng |
| :--- | :---: | :---: | :--- | :--- |
| **Trạng Thái** | `D0` | `INT` | `State_Machine` | Trạng thái máy (0 = Dừng, 1 = Chạy) |
| | `D1` | `INT` | `HMI_Status_Text_Code` | Mã trạng thái tiếng Việt (0..4) |
| | `D2` | `INT` | `HMI_Recipe_Select` | Công thức đơn hàng chọn (1..5) |
| | `D10` | `REAL` | `Current_Line_MPM` | Vận tốc dây chuyền thực tế (m/phút) |
| | `D12` | `REAL` | `Total_Length_Meters` | Tổng chiều dài mét màng đã chạy (m) |
| | `D14` | `REAL` | `Set_Target_Length` | Cài đặt số mét đích cần dừng (m) |
| | `D16` | `REAL` | `Effective_SP_T` | Lực căng Thu T sau khi trừ côn lực (kg) |
| **Tốc Độ Thực (Lọc 4 mẫu)** | `D50` | `REAL` | `RPM_T` | Tốc độ vòng/phút Motor Thu T |
| | `D52` | `REAL` | `RPM_X1` | Tốc độ vòng/phút Motor Xả X1 |
| | `D54` | `REAL` | `RPM_X2` | Tốc độ vòng/phút Motor Master X2 |
| | `D56` | `REAL` | `RPM_Ms` | Tốc độ vòng/phút Motor Ghép Ms |
| | `D58` | `REAL` | `RPM_S` | Tốc độ vòng/phút Motor Dầu S (Analog Servo) |
| | `D60` | `REAL` | `MPM_T` | Vận tốc dây màng cuộn Thu T (m/phút) |
| | `D62` | `REAL` | `MPM_X1` | Vận tốc dây màng trục Kéo X1 (m/phút) |
| | `D64` | `REAL` | `MPM_X2` | Vận tốc dây màng trục Master X2 (m/phút) |
| | `D66` | `REAL` | `MPM_Ms` | Vận tốc dây màng trục Ghép Ms (m/phút) |
| | `D68` | `REAL` | `MPM_S` | Vận tốc dây màng trục Dầu S (m/phút) |
| **Cài Đặt Vận Hành** | `D100` | `REAL` | `Target_Line_MPM` | Tốc độ cài đặt vận hành (m/phút) |
| | `D102` | `REAL` | `Max_Speed_MPM` | Tốc độ tối đa dây chuyền (100.0 m/p) |
| | `D104` | `REAL` | `Min_Speed_MPM` | Tốc độ tối thiểu bò chậm (2.0 m/p) |
| | `D106` | `REAL` | `Release_Pen_Speed_MPM` | Tốc độ tự động nhả Pen (2.0 m/p) |
| | `D108` | `REAL` | `Ramp_Accel_Rate` | Gia tốc tăng tốc m/p trên chu kỳ |
| | `D110` | `REAL` | `Ramp_Decel_Rate` | Gia tốc giảm tốc m/p trên chu kỳ |
| | `D112` | `REAL` | `Decel_Distance_Meters` | Khoảng cách hãm dừng sớm tự động (m) |
| | `D120` | `REAL` | `SP_Tension_T` | Cài đặt lực căng cuộn Thu T (kg) |
| | `D122` | `REAL` | `SP_Tension_X1` | Cài đặt lực căng trục Kéo X1 (kg) |
| | `D124` | `REAL` | `SP_Tension_M` | Cài đặt lực căng Thắng Từ M (kg) |
| | `D126` | `REAL` | `SP_Tension_U` | Cài đặt lực căng trục Xả Metalize U (kg) |
| | `D128` | `REAL` | `Taper_Percent_T` | Phần trăm côn lực cuộn Thu T (%) |
| **Cơ Khí Máy** | `D200..D210`| `REAL` | `Gear_Ratio_T..U` | Tỷ số truyền 6 hộp số |
| | `D212..D220`| `REAL` | `Max_RPM_T..S` | Tốc độ RPM tối đa 5 motor |
| | `D222..D228`| `REAL` | `Dia_*_Roller_mm` | Đường kính 4 lô cơ cấu (mm) |
| | `D230..D240`| `REAL` | `Core_Dia` / `Max_Dia` | Đường kính lõi và cuộn tối đa (mm) |
| | `D250..D264`| `REAL` | `Speed_Ratio` / `Offset`| Tỷ lệ tốc độ và bù tốc độ |
| | `D270..D280`| `REAL` | `Min/Max/Hold_Torque` | Thông số lực giữ thắng từ và xả |
| | `D290` | `DINT` | `PPR_Encoder` | Độ phân giải Encoder (2000 PPR) |
| **Cân Chỉnh Loadcell** | `D300..D306`| `REAL` | `Zero_Offset_T..U` | Điểm 0 Zero Offset Loadcell 4 trục |
| | `D310..D316`| `REAL` | `Calib_Gain_T..U` | Hệ số khuếch đại Calib Loadcell 4 trục |
| | `D320..D326`| `REAL` | `Weight_Net_T..U` | Trọng lượng lực căng thực tế (kg) |
| | `D330..D334`| `REAL` | `Real_Dia_T..U` | Đường kính cuộn tính toán thực tế (mm) |
| **PID Tuning 7 Trục** | `D400..D404`| `REAL` | `Kp_T, Ki_T, Kd_T` | Thông số PID cuộn Thu T |
| | `D406..D410`| `REAL` | `Kp_X1, Ki_X1, Kd_X1` | Thông số PID trục Kéo X1 |
| | `D412..D416`| `REAL` | `Kp_X2, Ki_X2, Kd_X2` | Thông số PID trục Master X2 |
| | `D418..D422`| `REAL` | `Kp_Ms, Ki_Ms, Kd_Ms` | Thông số PID trục Ghép Ms |
| | `D424..D428`| `REAL` | `Kp_S, Ki_S, Kd_S` | Thông số PID trục Dầu S |
| | `D430..D434`| `REAL` | `Kp_M, Ki_M, Kd_M` | Thông số PID Thắng Từ M |
| | `D436..D440`| `REAL` | `Kp_U, Ki_U, Kd_U` | Thông số PID trục Xả U |
| **Buffer Phần Cứng** | `D500..D507`| `WORD` | `ADC_CH1..CH8` | Raw ADC Module Q68ADV (0..16000) |
| | `D510..D517`| `WORD` | `DAC_CH1..CH8` | Xuất áp Module Q68DAV (0..16000 = 0..5V) |
| | `D520..D526`| `DINT` | `Curr_Pulse_T..Ms` | Xung đếm 32-bit Module QD62D |
| **Index HMI & Manual**| `D600` | `INT` | `HMI_Axis_Select` | Trục đang chọn chỉnh PID/Calib (1..7) |
| | `D602..D606`| `REAL` | `HMI_Disp_Kp, Ki, Kd` | Ô hiển thị/nhập Kp, Ki, Kd chung |
| | `D608..D610`| `REAL` | `HMI_Disp_Gain, Zero` | Ô hiển thị/nhập Calib Gain & Zero |
| | `D620..D634`| `REAL` | `Test_Speed/Torque` | Tốc độ/Torque chạy thử Manual từng trục |

---

### 2. Bảng Cờ Nhớ M (Internal Relays):

| Dải Địa Chỉ | Tên Biến Global | Ý Nghĩa Chức Năng |
| :--- | :--- | :--- |
| **`M0`** | `HMI_Auto_Mode` | Chế độ Auto / Manual |
| **`M1`** | `HMI_Reset_Error` | Nút Reset lỗi hệ thống |
| **`M2`** | `HMI_Start` | Nút Start khởi động máy |
| **`M3`** | `HMI_Stop` | Nút Stop dừng máy |
| **`M4`** | `HMI_Reset_Length` | Nút Reset tổng số mét về 0 |
| **`M5..M7`** | `HMI_Reset_Roll_T..U` | Nạp lại đường kính cuộn mới riêng từng trục |
| **`M8`** | `HMI_Reset_All_Rolls` | **Nút thay cuộn mới toàn bộ 1-Click** |
| **`M9`** | `HMI_PID_Enable` | Bật / Tắt chế độ PID tự động |
| **`M10, M11`** | `HMI_Inc_Hold, Dec_Hold` | Phím bấm INC tăng tốc / DEC giảm tốc |
| **`M12, M13`** | `HMI_Pen1_Cmd, Pen2_Cmd` | Lệnh đóng / mở Pen 1 và Pen 2 |
| **`M14`** | `HMI_Jog_Crawl_Cmd` | Nút nhấn Bò chậm luồn màng |
| **`M15, M16`** | `HMI_Cmd_Apply/Save_Recipe` | Nút áp dụng / Lưu công thức đơn hàng |
| **`M20..M23`** | `Zero_Set_T..U` | Nút Set Zero riêng cho từng trục T, X1, M, U |
| **`M24..M27`** | `Calib_Set_T..U` | Nút Calib Span riêng cho từng trục T, X1, M, U |
| **`M28, M29`** | `HMI_Cmd_Zero_Set, Calib_Set`| **Nút Zero & Calib đa năng theo trục đang chọn** |
| **`M30..M36`** | `HMI_Test_T..U` | Cờ kích chạy thử Manual riêng 7 trục |
| **`M40, M41`** | `HMI_Cmd_AutoTune, Save_PID` | **Nút kích hoạt Auto-Tuning & Lưu thông số PID** |
| **`M42, M43`** | `HMI_Status_AT_Busy, Done` | Đèn báo trạng thái Auto-Tuning |
| **`M50`** | `Servo_Not_Ready_Fault` | Cờ sự cố 5 Servo Not Ready |
| **`M51, M52`** | `Hold_Torque_Stop_M, U` | Công tắc giữ Torque Thắng M và Xả U khi dừng máy |
| **`M53, M54`** | `Pen1_State, Pen2_State` | Trạng thái đóng mở thực tế Pen 1 và Pen 2 |
| **`M55`** | `Pen_Auto_Engaged` | Cờ báo Pen đã tự động hạ khi đủ tốc độ |
| **`M56`** | `Auto_Decel_Flag` | Cờ báo hệ thống đang tự động hãm giảm tốc về đích |

---

## 💻 5. QUY TRÌNH NẠP CHƯƠNG TRÌNH LÊN PLC & HMI

### 1. Nạp vào PLC Mitsubishi Q02U (GX Works2):
1. Mở file [**`global_labels_paste.tsv`**](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/global_labels_paste.tsv) $\rightarrow$ Copy toàn bộ $\rightarrow$ Paste vào bảng **`Global_Label`** trong GX Works2.
2. Mở file [**`pou01_only_program.st`**](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/pou01_only_program.st) $\rightarrow$ Copy toàn bộ $\rightarrow$ Paste vào POU chính trong GX Works2.
3. Nhấn **`F4` (Rebuild All)** để biên dịch chương trình (đạt `0 Error(s)`).
4. Vào **`Online`** $\rightarrow$ **`Write to PLC...`**:
   - ✅ **Tick:** `Program` & `PLC Parameter`
   - ❌ **Bỏ tick:** `Comment` (để tránh lỗi tràn bộ nhớ `ES:010a41cf`).
   - Bấm **`Execute`** hoàn tất trong 2 giây.

### 2. Nạp Tag vào Màn Hình Weintek (EasyBuilder Pro):
1. Trong EasyBuilder Pro, mở menu **`Project`** $\rightarrow$ **`Address Tag Library`** (hoặc mở cửa sổ như hình bạn đang mở).
2. Đảm bảo bạn đang chọn mục **`User-defined tags`**.
3. Bấm vào biểu tượng **`Import` (hoặc chuột phải $\rightarrow$ Import from CSV)** $\rightarrow$ Chọn file [**`weintek_easybuilder_tags_import.csv`**](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/weintek_easybuilder_tags_import.csv).
4. File CSV đã được khớp chính xác với tên thiết bị **`metaline`** trong EasyBuilder Pro:
   - `Tag name`
   - `Device name` (`metaline`)
   - `Address type` (`D` hoặc `M`)
   - `Address` (Số thứ tự `0`, `10`, `100`...)
   - `Data format` (`Bit`, `16-bit Signed`, `32-bit Float`)
   - `Read/Write` (`Read/Write`)
   - `Comment`
5. Bấm **`OK`** $\rightarrow$ Toàn bộ danh sách Tag sẽ xuất hiện đầy đủ trong bảng và bạn có thể gán trực tiếp vào các ô số trên màn hình.
