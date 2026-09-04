# 📖 TÀI LIỆU HƯỚNG DẪN VẬN HÀNH, CÀI ĐẶT THÔNG SỐ & THIẾT KẾ HMI MÁY GHÉP METALIZE

**Dự án:** Hệ thống Điều Khiển Dây Chuyền Máy Ghép Màng Metalize Tự Động  
**PLC:** Mitsubishi **Q02UCPU** (Base Rack trực tiếp: Q68ADV, Q68DAV, QD62D, QX40, QY40)  
**HMI:** Màn hình cảm ứng **Weintek** (Phần mềm thiết kế **EasyBuilder Pro**)  
**Chuẩn dữ liệu:** Số thực **32-bit Float (REAL)** & Vùng nhớ **Liên tục 100%**  

---

## 📑 MỤC LỤC
1. [Trang Cài Đặt Đa Năng Thông Minh (Index Register - 1 Trang Cho 7 Trục)](#1-trang-cài-đặt-đa-năng-thông-minh-index-register---1-trang-cho-7-trục)
2. [Trang Hướng Dẫn Vận Hành Dành Cho Công Nhân (Giao Diện 1-Chạm)](#2-trang-hướng-dẫn-vận-hành-dành-cho-công-nhân-giao-diện-1-chạm)
   - [2.1 Sơ Đồ Bố Cục Giao Diện Màn Hình Chính](#21-sơ-đồ-bố-cục-giao-diện-màn-hình-chính-main-operation-dashboard)
   - [2.2 Cài Đặt Chiều Dài Đơn Hàng & Hãm Dừng Sớm (D14, D12, D112)](#22-hướng-dẫn-cài-đặt-chiều-dài-đơn-hàng-length-control)
   - [2.3 Cài Đặt Tốc Khởi Động, Tốc Max, Tốc Vận Hành & Gia Tốc (D100, D102, D104, D106)](#23-hướng-dẫn-cài-đặt-vận-tốc-dây-chuyền-tốc-khởi-động-tốc-max-vận-hành)
   - [2.4 Cài Đặt Lực Căng 4 Trục & Côn Lực Cuộn Thu (D120, D122, D124, D126, D128)](#24-hướng-dẫn-cài-đặt-lực-căng-từng-trục-tension-setpoint-per-axis)
   - [2.5 Cài Đặt & Vận Hành Torque Giữ Khi Dừng Chống Xổ Màng (D274, D280, M51, M52)](#25-hướng-dẫn-cài-đặt--vận-hành-torque-giữ-khi-dừng-holding-torque-stop)
   - [2.6 Bảng Công Thức Mẫu Đơn Hàng Cài Đặt Sẵn (Quick Recipes)](#26-bảng-công-thức-mẫu-đơn-hàng-cài-đặt-sẵn-quick-recipes)
   - [2.7 Quy Trình Vận Hành 6 Bước Thực Tế Dành Cho Công Nhân](#27-quy-trình-vận-hành-6-bước-thực-tế-dành-cho-công-nhân)
   - [2.8 Bảng Mã Trạng Thái Hiển Thị Tiếng Việt Trên HMI (D1)](#28-bảng-mã-trạng-thái-hiển-thị-tiếng-việt-trên-hmi-d1)
   - [2.9 Bảng Xử Lý Nhanh Sự Cố Màng Thường Gặp Của Công Nhân](#29-bảng-hướng-dẫn-xử-lý-nhanh-các-sự-cố-màng-thường-gặp)
3. [Trang Cài Đặt Thông Số Máy & Cấu Hình Cơ Khí (Machine Settings Dashboard)](#3-trang-cài-đặt-thông-số-máy--cấu-hình-cơ-khí-machine-settings-dashboard)
   - [3.1 Sơ Đồ Bố Cục Giao Diện Trang Cài Đặt Máy](#31-sơ-đồ-bố-cục-giao-diện-trang-cài-đặt-máy-machine-configuration-layout)
   - [3.2 Cài Đặt Tỷ Số Truyền Hộp Số & Tốc Độ Max RPM Động Cơ (D200..D220)](#32-cài-đặt-tỷ-số-truyền-hộp-số--tốc-độ-max-rpm-động-cơ-d200d220)
   - [3.3 Cài Đặt Kích Thước Lô Cơ Cấu & Quy Cách Cuộn Màng (D222..D240)](#33-cài-đặt-kích-thước-lô-cơ-cấu--quy-cách-cuộn-màng-d222d240)
   - [3.4 Cài Đặt Tỷ Lệ Đồng Tốc & Bù Tốc Độ Trục (D250..D264)](#34-cài-đặt-tỷ-lệ-đồng-tốc--bù-tốc-độ-trục-d250d264)
   - [3.5 Cài Đặt Dải Giới Hạn Torque Thắng Từ M & Xả U (D270..D280)](#35-cài-đặt-dải-giới-hạn-torque-thắng-từ-m--xả-u-d270d280)
   - [3.6 Cài Đặt Xung Đếm Encoder Trục Master QD62D (D290)](#36-cài-đặt-xung-đếm-encoder-trục-master-qd62d-d290)
   - [3.7 Bảng Điều Khiển Test Manual / Chạy Thử Độc Lập 7 Trục (D620..D634, M30..M36)](#37-bảng-điều-khiển-test-manual--chạy-thử-độc-lập-7-trục-d620d634-m30m36)
   - [3.8 Quy Trình Cân Chỉnh (Calib) Loadcell Lực Căng 0..50kg (D300..D316, M28..M29)](#38-quy-trình-cân-chỉnh-calib-loadcell-lực-căng-050kg-d300d316-m28m29)
   - [3.9 Hướng Dẫn Phân Quyền Bảo Mật Mật Khẩu (Security Password) Trên Weintek](#39-hướng-dẫn-phân-quyền-bảo-mật-mật-khẩu-security-password-trên-weintek)
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

Màn hình vận hành chính được thiết kế trực quan, dễ hiểu, giúp công nhân thao tác nhanh gọn, an toàn và hoàn toàn làm chủ dây chuyền mà không sợ bấm nhầm.

---

### 🖥️ 2.1. SƠ ĐỒ BỐ CỤC GIAO DIỆN MÀN HÌNH CHÍNH (MAIN OPERATION DASHBOARD)

Giao diện trên HMI Weintek được bố trí thành các khối chức năng rõ ràng:

```
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│  MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - [TRẠNG THÁI: D1 (Chữ Tiếng Việt lớn)]       [ĐÈN BÁO Y58-Y5A] │
├────────────────────────────────┬───────────────────────────────┬───────────────────────────────┤
│ 📏 1. QUẢN LÝ CHIỀU DÀI ĐƠN HÀNG │ 🏎️ 2. CÀI ĐẶT TỐC ĐỘ VẬN HÀNH │ ⚖️ 3. LỰC CĂNG TỪNG TRỤC (KG)  │
│                                │                               │                               │
│ • Mét Cài Đích: [ D14 ] (m)     │ • Tốc Đặt:   [ D100 ] (m/p)   │ • Thu T:   [ D120 ] SP | [D320] PV│
│ • Mét Thực Tế: [ D12 ] (m)     │ • Tốc Thực:  [ D10  ] (m/p)   │ • Côn Lực: [ D128 ] (%)        │
│ • Hãm Dừng Sớm: [ D112] (m)     │ • Tốc Khởi Động: [ D104 ] (m/p)│ • Kéo X1:  [ D122 ] SP | [D322] PV│
│                                │ • Tốc Tối Đa:   [ D102 ] (m/p)│ • Thắng M: [ D124 ] SP | [D324] PV│
│ [ NÚT XÓA MÉT (M4) ]           │ • Tốc Nhả Pen:  [ D106 ] (m/p)│ • Xả U:    [ D126 ] SP | [D326] PV│
│                                │ [ NÚT INC (M10) ] [ DEC (M11) ]│                               │
├────────────────────────────────┴───────────────────────────────┴───────────────────────────────┤
│ 🔒 4. TORQUE GIỮ KHI DỪNG MÁY (HOLDING TORQUE STOP - CHỐNG XỔ MÀNG)                             │
│                                                                                                │
│ • Thắng Từ M: Torque Giữ = [ D274 ] (%)   │ Switch Giữ: [ BẬT/TẮT M51 (hoặc công tắc tủ X4E) ] │
│ • Xả Nhôm U:  Torque Giữ = [ D280 ] (%)   │ Switch Giữ: [ BẬT/TẮT M52 (hoặc công tắc tủ X4F) ] │
├────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 🎛️ 5. PHÍM LỆNH VẬN HÀNH DÂY CHUYỀN (1-CHẠM)                                                   │
│                                                                                                │
│ [ ▶️ START MÁY (M2) ]   [ ⏹️ DỪNG MÁY (M3) ]   [ 🐢 BÒ CHẬM NỐI MÀNG (M14) ]                      │
│ [ 🔄 THAY CUỘN MỚI 1-CLICK (M8) ]   [ 📋 CHỌN CÔNG THỨC: D2 ]   [ 💾 ÁP DỤNG CÔNG THỨC (M15) ]  │
│ [ 🔘 ÉP/NHẢ PEN 1 (M12) ]           [ 🔘 ÉP/NHẢ PEN 2 (M13) ]   [ ⚠️ RESET LỖI (M1) ]           │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

### 📏 2.2. HƯỚNG DẪN CÀI ĐẶT CHIỀU DÀI ĐƠN HÀNG (LENGTH CONTROL)

Hệ thống sử dụng xung đếm tốc độ cao 32-bit từ Encoder trục Master X2 nối về module **QD62D** để đo đếm chính xác từng milimet màng đã chạy qua máy:

| Thông Số / Phím Bấm | Địa Chỉ PLC | Kiểu Dữ Liệu | Ý Nghĩa Kỹ Thuật & Hướng Dẫn Vận Hành |
| :--- | :---: | :---: | :--- |
| **Cài Số Mét Đích** | **`D14`** | `32-bit Float` | • **Ý nghĩa:** Tổng số mét cần chạy cho cuộn thành phẩm (ví dụ: `2000.0` m, `5000.0` m).<br>• **Thao tác:** Công nhân bấm vào ô và nhập số mét theo Lệnh sản xuất.<br>• Khi đủ số mét, máy **tự động hãm dừng hoàn toàn** mà không cần công nhân canh chừng bấm Stop thủ công. |
| **Số Mét Đã Chạy** | **`D12`** | `32-bit Float` | • **Ý nghĩa:** Chiều dài màng thực tế đã chạy tích lũy (m).<br>• Tự động đếm tiến liên tục theo vòng quay trục Master X2.<br>• Giá trị được duy trì ổn định ngay cả khi máy tạm dừng. |
| **Khoảng Cách Hãm Sớm** | **`D112`** | `32-bit Float` | • **Ý nghĩa:** Khoảng cách mét máy bắt đầu tự động giảm tốc về bò chậm trước khi dừng hẳn.<br>• **Khuyến nghị cài đặt:** `20.0` ~ `50.0` mét (tùy tốc độ chạy nhanh hay chậm).<br>• **Nguyên lý hoạt động:** Khi mét thực `D12` $\ge$ (`D14` - `D112`), máy tự động giảm tốc từ tốc độ cao (ví dụ 60 m/p) xuống tốc độ bò chậm `Min_Speed_MPM` (2.0 m/p) $\rightarrow$ Cờ `Auto_Decel_Flag` (`M56`) bật sáng $\rightarrow$ Công nhân có đủ thời gian chuẩn bị dao cắt, băng dán nối màng, máy không bị giật khựng quán tính làm nổ cuộn. |
| **Nút Xóa Mét Về 0** | **`M4`** | `Bit (Button)` | • **Thao tác:** Nhấn nút này khi bắt đầu một cuộn đơn hàng mới để reset `D12` về `0.0 m`.<br>*(Lưu ý: Nếu nhấn nút "THAY CUỘN MỚI 1-CLICK" `M8`, hệ thống cũng sẽ tự động xóa mét về 0)*. |

---

### 🏎️ 2.3. HƯỚNG DẪN CÀI ĐẶT VẬN TỐC DÂY CHUYỀN (TỐC KHỞI ĐỘNG, TỐC MAX, VẬN HÀNH)

Hệ thống bảo vệ chuyển động êm dịu thông qua thuật toán Ramping gia tốc đa tầng, chống giật đứt màng tuyệt đối:

| Thông Số / Nút Bấm | Địa Chỉ PLC | Giá Trị Chuẩn | Hướng Dẫn Vận Hành Dành Cho Công Nhân |
| :--- | :---: | :---: | :--- |
| **Tốc Độ Khởi Động / Bò Chậm** (`Min_Speed_MPM`) | **`D104`** | **`2.0 m/p`** | • **Tốc độ an toàn:** Mức tốc độ tối thiểu cho phép máy di chuyển.<br>• **Khi bấm nút "BÒ CHẬM NỐI MÀNG" (`M14` hoặc `X49`):** Dây chuyền chạy đúng tốc độ này để công nhân lấy mép màng, luồn qua các quả lô và dán băng keo nối màng an toàn cho đôi tay.<br>• **Khi nhấn START:** Máy luôn bắt đầu khởi hành từ vận tốc bò chậm này rồi mới êm ái tăng tốc lên, không khởi động giật cục. |
| **Tốc Độ Tối Đa Khống Chế** (`Max_Speed_MPM`) | **`D102`** | **`100.0 m/p`** | • **Trần tốc độ an toàn (Speed Ceiling):** Giới hạn tối đa máy có thể chạy.<br>• Cho dù công nhân có bấm giữ nút tăng tốc INC liên tục, tốc độ cài đặt cũng không thể vượt quá giá trị này, bảo vệ an toàn cho cơ khí hộp số và chống rung lắc máy. |
| **Tốc Độ Cài Đặt Vận Hành** (`Target_Line_MPM`) | **`D100`** | **`40.0 ~ 80.0 m/p`** | • **Tốc độ sản xuất mong muốn:** Nhập trực tiếp số mét/phút cần chạy theo từng loại nguyên liệu.<br>• Có thể điều chỉnh linh hoạt bằng 2 nút **`INC` (`M10`)** và **`DEC` (`M11`)** trên màn hình hoặc nút vật lý `X47` / `X48`. |
| **Tốc Độ Tự Động Nhả Pen** (`Release_Pen_Speed_MPM`) | **`D106`** | **`2.0 m/p`** | • **Bảo vệ lô ép cao su:** Khi vận tốc giảm xuống dưới ngưỡng này (hoặc khi bấm STOP), 2 Pen ép màng tự động mở ra.<br>• Ngăn chặn tình trạng quả lô cao su ép tì liên tục vào quả lô kim loại nóng gây biến dạng, méo lô hoặc cháy màng. |
| **Gia Tốc Tăng Tốc** (`Ramp_Accel_Rate`) | **`D108`** | **`0.05 ~ 0.10`** | • Độ tăng tốc m/phút trên mỗi chu kỳ scan. Càng nhỏ thì máy tăng tốc càng êm.<br>• Với màng nhôm dẻo/mỏng dễ đứt nên cài `0.04`, với màng chuẩn cài `0.08`. |
| **Gia Tốc Giảm Tốc** (`Ramp_Decel_Rate`) | **`D110`** | **`0.08 ~ 0.12`** | • Độ giảm tốc m/phút trên mỗi chu kỳ scan khi bấm STOP hoặc hãm về đích. Giúp máy dừng nhanh nhưng không bị trôi cuộn xả. |
| **Nút Tăng Tốc Lũy Tiến (`INC`)** | **`M10`** (`X47`) | `Bit (Hold)` | • **Nhấn nhấp nhả:** Tăng tốc từ từ từng chút một.<br>• **Nhấn giữ > 1 giây:** Tăng tốc nhanh gấp 2 lần.<br>• **Nhấn giữ > 3 giây:** Tăng tốc nhanh gấp 5 lần để lên dải tốc độ cao nhanh chóng. |
| **Nút Giảm Tốc Lũy Tiến (`DEC`)** | **`M11`** (`X48`) | `Bit (Hold)` | • Tương tự nút INC, dùng để giảm tốc êm ái khi phát hiện màng có hiện tượng nhăn hoặc keo ghép chưa đều. |

---

### ⚖️ 2.4. HƯỚNG DẪN CÀI ĐẶT LỰC CĂNG TỪNG TRỤC (TENSION SETPOINT PER AXIS)

Hệ thống trang bị 4 mạch vòng Loadcell Analog hồi tiếp thời gian thực độc lập giúp màng luôn phẳng tuyệt đối:

```
[ Cuộn Xả M (Thắng Từ) ] ──(Lực Căng D124)──► [ Lô Kéo X1 ] ──(Lực Căng D122)──► [ Cụm Ghép Ms ] ──► [ Cuộn Thu T (Motor) ] (Lực D120)
[ Cuộn Xả U (Nhôm Metalize) ] ──(Lực Căng D126)──┘                                                  └─ Côn lực D128 (%)
```

#### 📋 Bảng Chi Tiết Cài Đặt Lực Căng 4 Trục:

| Vị Trí Trục | Ô Cài Đặt (SP) | Ô Thực Tế (PV) | Dải Cài Đặt Phù Hợp | Hướng Dẫn Vận Hành & Tinh Chỉnh Thực Tế |
| :--- | :---: | :---: | :---: | :--- |
| **Trục 1: Cuộn Thu T (Winder)** | **`D120`** (`SP_Tension_T`) | **`D320`** (`Weight_Net_T`) | **`10.0 ~ 25.0 kg`** | • **Chức năng:** Lực căng cuộn thu thành phẩm.<br>• **Lực thực tế `D320`:** Phải bám sát ô cài đặt `D120` (sai lệch cho phép $\pm 0.3\text{ kg}$).<br>• Nếu cuộn thu bị lỏng, mép xộc xệch $\rightarrow$ Tăng `D120` lên $1\text{ ~ }2\text{ kg}$.<br>• Nếu cuộn thu quá căng làm co rút màng $\rightarrow$ Giảm `D120`. |
| **Côn Lực Cuộn Thu T (Taper %)** | **`D128`** (`Taper_Percent_T`) | **`D16`** (`Effective_SP_T`) | **`15.0 ~ 25.0 %`** | • **Bảo vệ lõi màng:** Khi cuộn thu to dần lên, áp lực nén vào trong rất lớn. Cài đặt Côn lực giúp PLC **tự động giảm dần lực căng** theo đường kính thực tế `D330`.<br>• Nhờ vậy, màng quấn chặt ở lõi nhưng êm ở ngoài, **cuộn không bị bẹp ruột, nổ cuộn hay hình hoa mai**.<br>• `D16` là lực căng thực tế sau khi đã trừ tỷ lệ côn lực. |
| **Trục 2: Kéo Giấy X1 (Main Pull)** | **`D122`** (`SP_Tension_X1`) | **`D322`** (`Weight_Net_X1`) | **`8.0 ~ 22.0 kg`** | • **Chức năng:** Lực căng kéo tờ giấy/màng chính từ trục xả 1 qua bàn tráng keo.<br>• Cần giữ lực căng đủ lớn để giấy đi thẳng, không bị chùng hay lệch bước mắt đọc. |
| **Trục 6: Thắng Từ M (Brake M)** | **`D124`** (`SP_Tension_M`) | **`D324`** (`Weight_Net_M`) | **`3.5 ~ 8.0 kg`** | • **Chức năng:** Lực căng xả màng OPP/BOPP.<br>• Màng mỏng rất dễ giãn, nếu cài quá $8\text{ kg}$ màng sẽ bị giãn dài làm co quắp sản phẩm sau khi ghép. Cài vừa đủ màng căng phẳng mép. |
| **Trục 7: Xả Metalize U (Unwinder U)** | **`D126`** (`SP_Tension_U`) | **`D326`** (`Weight_Net_U`) | **`7.0 ~ 18.0 kg`** | • **Chức năng:** Lực căng xả màng nhôm Metalize.<br>• Màng nhôm dễ bị nếp gấp hoặc gãy nếp nếu lực căng trồi sụt. Cần quan sát `D326` ổn định trước khi tăng tốc độ cao. |

---

### 🔒 2.5. HƯỚNG DẪN CÀI ĐẶT & VẬN HÀNH TORQUE GIỮ KHI DỪNG (HOLDING TORQUE STOP)

Đây là tính năng cực kỳ quan trọng giúp **chống xổ màng, chống chùng màng và chống trôi cuộn xả** khi máy dừng:

#### 💡 Tại sao phải có Torque Giữ Khi Dừng?
Cuộn màng Thắng Từ M và cuộn Xả Nhôm U có khối lượng rất nặng (từ $50\text{ kg}$ đến hàng trăm $\text{kg}$). Khi dây chuyền dừng máy đột ngột hoặc dừng đủ mét, nếu cắt hoàn toàn điện áp hãm về 0V:
- Hai cuộn màng sẽ **tiếp tục quay theo quán tính** $\rightarrow$ Hàng chục mét màng bị tuôn xổ rơi xuống sàn dơ bẩn.
- Màng bị chùng, làm mất lực căng ban đầu $\rightarrow$ Khi bấm chạy lại, máy sẽ giật mạnh làm đứt màng ngay lập tức.

#### 📋 Cài Đặt Thông Số & Thao Tác Công Tắc Giữ:

| Cơ Cấu Trục | Giá Trị Cài Đặt Torque Giữ | Vị Trí Công Tắc Bật / Tắt | Hướng Dẫn Vận Hành Cho Công Nhân |
| :--- | :---: | :---: | :--- |
| **Trục Thắng Từ M** | **`D274`** (`Init_Holding_Torque_M`)<br>• Giá trị: **`15.0 ~ 25.0 %`** | • **Trên HMI:** Switch **`M51`**<br>• **Ngoài Tủ Điện:** Công tắc gạt **`X4E`** | • **KHI CHẠY TỰ ĐỘNG:** Luôn gạt công tắc sang **ON**.<br>Khi máy dừng (`State_Machine = 0`), PLC sẽ tự động kích hoạt mức Torque `D274` để khóa hãm giữ chặt cuộn màng ở trạng thái căng phẳng.<br>• **KHI THAY CUỘN / NỐI MÀNG BẰNG TAY:** Gạt công tắc sang **OFF** $\rightarrow$ Trục nhả tự do hoàn toàn để công nhân dùng tay xoay tròn cuộn màng nhẹ nhàng và xả màng dán mép. |
| **Trục Xả Metalize U** | **`D280`** (`Init_Holding_Torque_U`)<br>• Giá trị: **`15.0 ~ 25.0 %`** | • **Trên HMI:** Switch **`M52`**<br>• **Ngoài Tủ Điện:** Công tắc gạt **`X4F`** | • **Quy tắc tương tự trục M:** Luôn bật ON trong suốt ca chạy.<br>• Nếu thấy cuộn nhôm dừng lại mà vẫn hơi bị lỏng màng $\rightarrow$ Nhập tăng `D280` từ 15% lên 20% hoặc 25%.<br>• Nếu thấy khi dừng màng bị kéo quá căng $\rightarrow$ Giảm `D280` xuống 12% ~ 15%. |

---

### 📋 2.6. BẢNG CÔNG THỨC MẪU ĐƠN HÀNG CÀI ĐẶT SẴN (QUICK RECIPES)

Công nhân chỉ cần chọn số thứ tự tại ô **`HMI_Recipe_Select` (`D2`)** và bấm **`ÁP DỤNG CÔNG THỨC` (`M15`)**, toàn bộ tốc độ, lực căng và côn lực sẽ tự động nạp vào máy:

| Mã Số (`D2`) | Loại Đơn Hàng | Tốc Đặt (`D100`) | Lực Thu T (`D120`) | Côn Lực (`D128`) | Kéo X1 (`D122`) | Thắng M (`D124`) | Xả U (`D126`) | Torque Giữ (`D274`/`D280`) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`1`** | **Màng Mỏng** (BOPP 12~15 mic) | `45.0 m/p` | `12.0 kg` | `15.0 %` | `10.0 kg` | `4.0 kg` | `8.0 kg` | `15.0 %` |
| **`2`** | **Hàng Tiêu Chuẩn** (BOPP 18~20 mic + Giấy) | `60.0 m/p` | `16.0 kg` | `20.0 %` | `14.0 kg` | `6.0 kg` | `12.0 kg` | `20.0 %` |
| **`3`** | **Bìa Cứng / Giấy Dày** (Duplex 250~350g) | `50.0 m/p` | `25.0 kg` | `25.0 %` | `22.0 kg` | `8.0 kg` | `18.0 kg` | `25.0 %` |
| **`4`** | **Màng Nhôm / Foil Dẻo Cao Cấp** | `40.0 m/p` | `10.0 kg` | `15.0 %` | `8.0 kg` | `3.5 kg` | `7.0 kg` | `15.0 %` |
| **`5`** | **Tùy Chỉnh (Custom)** | Giữ nguyên | Nhập tay | Nhập tay | Nhập tay | Nhập tay | Nhập tay | Nhập tay |

---

### 🛠️ 2.7. QUY TRÌNH VẬN HÀNH 6 BƯỚC THỰC TẾ DÀNH CHO CÔNG NHÂN

```
[BƯỚC 1: THAY CUỘN] ──► [BƯỚC 2: CÀI ĐẶT ĐƠN HÀNG] ──► [BƯỚC 3: BÒ CHẬM LUỒN MÀNG]
        │
        ▼
[BƯỚC 4: START TỰ ĐỘNG] ──► [BƯỚC 5: GIÁM SÁT & TĂNG TỐC] ──► [BƯỚC 6: TỰ ĐỘNG DỪNG KHI ĐỦ MÉT]
```

1. **Bước 1 (Thay cuộn màng mới):**
   - Tắt công tắc giữ torque (`M51=OFF`, `M52=OFF`). Lắp cuộn màng mạ nhôm, cuộn màng OPP và cuộn thu mới.
   - Nhấn **`NÚT THAY CUỘN MỚI 1-CLICK` (`M8`)** $\rightarrow$ Hệ thống tự động nạp lại đường kính chuẩn (Thu T về 76mm, Thắng M và Xả U về cuộn đầy) và xóa số mét `D12` về `0.0 m`.
   - Bật lại công tắc giữ torque (`M51=ON`, `M52=ON`).
2. **Bước 2 (Cài đặt thông số đơn hàng):**
   - Nhập số mét cần chạy vào ô **`Cài Mét Đích` (`D14`)** (ví dụ: `3000` m).
   - Kiểm tra khoảng cách hãm sớm **`D112`** (chuẩn: `30` m).
   - Chọn loại hàng tại ô **`HMI_Recipe_Select` (`D2`)** và bấm **`ÁP DỤNG CÔNG THỨC` (`M15`)**.
   - Kiểm tra lại lực căng 4 trục (`D120`, `D122`, `D124`, `D126`), nếu cần chỉnh riêng hãy nhập đè trực tiếp.
3. **Bước 3 (Luồn màng & dán băng keo):**
   - Nhấn giữ nút **`BÒ CHẬM NỐI MÀNG` (`M14` hoặc nút vật lý `X49`)** $\rightarrow$ Dây chuyền chạy với tốc độ an toàn $2.0\text{ m/phút}$ (`D104`).
   - Lấy mép màng luồn qua các quả lô, dán băng keo nối vào đầu màng trục thu. Sau khi màng đã kéo thẳng phẳng, nhả tay khỏi nút bò chậm.
4. **Bước 4 (Khởi động chạy tự động):**
   - Nhấn nút **`START` (`M2` hoặc nút vật lý `X45`)**.
   - Máy tự động tăng tốc êm ái từ $2.0\text{ m/p}$ lên tốc độ đặt `D100`.
   - Khi tốc độ vượt qua $5.0\text{ m/phút}$, hệ thống **tự động hạ 2 Pen ép màng xuống** (`DO_Pen1=Y55`, `DO_Pen2=Y56`), không cần công nhân phải nhớ gạt pen thủ công.
5. **Bước 5 (Giám sát khi đang chạy):**
   - Quan sát ô Lực căng thực tế `D320`, `D322`, `D324`, `D326`: Giá trị phải bám đều và ổn định.
   - Muốn tăng tốc: Nhấn giữ nút **`INC` (`M10`)**. Muốn giảm tốc: Nhấn giữ nút **`DEC` (`M11`)**.
6. **Bước 6 (Tự động hãm và hoàn thành cuộn):**
   - Khi chạy đến mét hãm sớm (`D12` $\ge$ `D14` - `D112`), máy tự động hãm tốc độ về bò chậm $2.0\text{ m/p}$.
   - Khi đạt đủ mét cài đặt `D14`, máy tự động ngắt dừng hoàn toàn.
   - 2 Pen ép tự động nhả lên khi tốc độ dưới $2.0\text{ m/p}$.
   - Hai trục Thắng M và Xả U tự động kích hoạt **Holding Torque** giữ căng màng, không bị xổ cuộn!

---

### 📋 2.8. BẢNG MÃ TRẠNG THÁI HIỂN THỊ TIẾNG VIỆT TRÊN HMI (`D1`):

| Giá Trị `D1` | Nội Dung Hiển Thị Trên HMI | Trạng Thái Đèn Tháp / Còi | Hướng Dẫn Xử Lý Cho Công Nhân |
| :---: | :--- | :--- | :--- |
| **`0`** | **MÁY DỪNG - SẴN SÀNG CHẠY** | Đèn Vàng sáng (`Y59`) | Máy bình thường, đã sẵn sàng để nhấn START hoặc Bò chậm. |
| **`1`** | **SỰ CỐ: KIỂM TRA 5 TRỤC SERVO NOT READY!** | Đèn Đỏ nháy (`Y5A`) + Còi kêu (`Y57`) | Có ít nhất 1 Driver Servo bị mất nguồn hoặc báo lỗi (kiểm tra `X40..X44`, rơ-le nhiệt, nút dừng khẩn E-Stop) $\rightarrow$ Nhấn Reset Lỗi (`M1`) sau khi kiểm tra xong. |
| **`2`** | **DÂY CHUYỀN ĐANG CHẠY TỰ ĐỘNG** | Đèn Xanh sáng (`Y58`) | Máy đang chạy bình thường ở chế độ sản xuất tự động. |
| **`3`** | **ĐANG BÒ CHẬM LUỒN MÀNG (2 m/phút)** | Đèn Vàng sáng (`Y59`) | Đang giữ phím bò chậm `M14`/`X49` để thao tác kỹ thuật luồn màng. |
| **`4`** | **HOÀN THÀNH ĐƠN HÀNG - ĐÃ ĐẠT ĐỦ SỐ MÉT** | Đèn Xanh nhấp nháy báo hiệu | Đơn hàng đã chạy đủ số mét `D14`, máy tự dừng an toàn. Công nhân tiến hành cắt màng và chuẩn bị cuộn mới. |

---

### ⚠️ 2.9. BẢNG HƯỚNG DẪN XỬ LÝ NHANH CÁC SỰ CỐ MÀNG THƯỜNG GẶP

| Hiện Tượng | Nguyên Nhân Chính | Thao Tác Xử Lý Nhanh Của Công Nhân |
| :--- | :--- | :--- |
| **Màng bị nhăn xéo khi ghép** | Lực căng 2 bên màng không cân hoặc Lực Thắng M quá chùng | • Tăng lực căng `SP_Tension_M` (`D124`) lên thêm $0.5\text{ ~ }1.0\text{ kg}$.<br>• Kiểm tra xem Pen ép 1 và Pen 2 đã hạ đều xuống chưa. |
| **Màng bị đứt khi tăng tốc** | Gia tốc tăng tốc quá gắt hoặc Lực căng cài quá lớn | • Giảm `Ramp_Accel_Rate` (`D108`) xuống `0.04`.<br>• Giảm bớt Lực căng trục tương ứng từ $1\text{ ~ }2\text{ kg}$. |
| **Cuộn thu bị móp lõi / bẹp ruột** | Không cài Côn Lực Taper Tension | • Cài ô Côn Lực `Taper_Percent_T` (`D128`) lên `20%` ~ `25%` để giảm dần lực khi cuộn to. |
| **Khi bấm STOP bị xổ màng** | Chưa bật công tắc Holding Torque hoặc Torque giữ quá nhỏ | • Kiểm tra công tắc giữ `M51`/`M52` (hoặc `X4E`/`X4F`) đã gạt sang **ON** chưa.<br>• Tăng Torque giữ `D274` (Thắng M) hoặc `D280` (Xả U) từ `15%` lên `25%`. |
| **Bấm START máy không chạy** | Đang có lỗi Servo (`D1=1`) hoặc chưa gạt công tắc an toàn | • Nhìn mã `D1` trên màn hình.<br>• Kiểm tra nút E-Stop ngoài tủ.<br>• Nhấn nút **Reset Lỗi (`M1`)** trên HMI. |

---

## ⚙️ 3. TRANG CÀI ĐẶT THÔNG SỐ MÁY & CẤU HÌNH CƠ KHÍ (MACHINE SETTINGS DASHBOARD)

Trang Cài Đặt Thông Số Máy (Machine Configuration / System Setup) là trang chuyên dụng dành riêng cho **Kỹ sư cơ điện, bảo trì và quản lý kỹ thuật**. Trang này quy định toàn bộ các tỷ số truyền vật lý, kích thước quả lô, trần tốc độ motor, tỷ lệ đồng tốc, giới hạn mô-men xoắn và xung đo đếm của dây chuyền máy ghép metalize.

---

### 🖥️ 3.1. SƠ ĐỒ BỐ CỤC GIAO DIỆN TRANG CÀI ĐẶT MÁY (MACHINE CONFIGURATION LAYOUT)

Giao diện trên màn hình Weintek MT6103iP (1024 x 600) được tổ chức theo các khối chức năng công nghiệp rõ ràng, trực quan:

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ⚙️ CÀI ĐẶT THÔNG SỐ CƠ KHÍ & CẤU HÌNH HỆ THỐNG MÁY GHÉP METALIZE          [🔒 KHÓA BẢO MẬT: BẬT]│
├────────────────────────────────┬────────────────────────────────┬────────────────────────────────┤
│ 1. ⚙️ TỶ SỐ TRUYỀN HỘP SỐ (GEAR)│ 2. ⚡ TỐC ĐỘ MAX RPM SERVO     │ 3. 📏 ĐƯỜNG KÍNH LÔ CƠ CẤU (mm)│
│                                │                                │                                │
│ • Thu T:     [ D200 ] (10.1:1) │ • Thu T:     [ D212 ] (1500)   │ • Kéo X1:    [ D222 ] (300.5)  │
│ • Xả X1:     [ D202 ] (8.0:1)  │ • Xả X1:     [ D214 ] (1000)   │ • Master X2: [ D224 ] (300.5)  │
│ • Master X2: [ D204 ] (8.0:1)  │ • Master X2: [ D216 ] (1000)   │ • Ghép Ms:   [ D226 ] (200.0)  │
│ • Ghép Ms:   [ D206 ] (10.0:1) │ • Ghép Ms:   [ D218 ] (3000)   │ • Lô Dầu S:  [ D228 ] (100.0)  │
│ • Dầu S:     [ D208 ] (10.0:1) │ • Dầu S:     [ D220 ] (3000)   │ • Nhông M:   [ D282 ] (33/32)  │
│ • Xả U:      [ D210 ] (1.0:1)  │                                │ • Xung QD62D: [ D290 ] (2000P) │
├────────────────────────────────┼────────────────────────────────┼────────────────────────────────┤
│ 4. 📦 QUY CÁCH LÕI & CUỘN MÀNG │ 5. 🎯 TỶ LỆ ĐỒNG TỐC & BÙ TỐC  │ 6. 🔒 GIỚI HẠN TORQUE THẮNG/XẢ │
│                                │                                │                                │
│ • Lõi Thu T:  [ D230 ] (76 mm) │ • Tỷ Lệ Thu T: [ D250 ] (1.05) │ • Thắng M Min: [ D270 ] (5.0%) │
│ • Cuộn T Max: [ D236 ] (1000mm)│ • Tỷ Lệ X1:    [ D252 ] (1.00) │ • Thắng M Max: [ D272 ] (80.0%)│
│ • Lõi Thắng M:[ D232 ] (76 mm) │ • Tỷ Lệ Ms:    [ D254 ] (1.00) │ • Giữ Khi Dừng:[ D274 ] (20.0%)│
│ • Thắng M Max:[ D238 ] (600 mm)│ • Tỷ Lệ S:     [ D256 ] (1.00) │ • Xả U Min:    [ D276 ] (5.0%) │
│ • Lõi Xả U:   [ D234 ] (76 mm) │ • Bù Tốc X1:   [ D260 ] (0.00) │ • Xả U Max:    [ D278 ] (80.0%)│
│ • Xả U Max:   [ D240 ] (800 mm)│ • Bù Tốc Ms:   [ D262 ] (0.00) │ • Giữ Khi Dừng:[ D280 ] (20.0%)│
│                                │ • Bù Tốc S:    [ D264 ] (0.00) │                                │
├────────────────────────────────┴────────────────────────────────┴────────────────────────────────┤
│ 🛠️ 7. CHẠY THỬ THỦ CÔNG MANUAL / JOG TEST ĐỘC LẬP TỪNG TRỤC (DÀNH CHO BẢO TRÌ CĂN MÁY)           │
│                                                                                                  │
│ [TEST T M30]  V: [D620] Tq:[D622] │ [TEST X1 M31] V:[D624] │ [TEST X2 M32] V:[D626] │ [TEST Ms M33] V:[D628]│
│ [TEST S M34]  V: [D630]           │ [TEST M  M35] Tq:[D632]│ [TEST U  M36] V:[D634] │ [🔄 RESET CUỘN: M8]  │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 🧭 ĐIỀU HƯỚNG: [🏠 MÀN HÌNH CHÍNH (F1)]  [🎯 TRANG TUNING PID (F2)]  [⚖️ CALIB LOADCELL (F4)]      │
└──────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

### ⚙️ 3.2. CÀI ĐẶT TỶ SỐ TRUYỀN HỘP SỐ & TỐC ĐỘ MAX RPM ĐỘNG CƠ (D200..D220)

Các thông số này liên kết trực tiếp giữa tốc độ quay của động cơ điện (RPM) với vận tốc di chuyển thực tế của màng (m/phút). Cần nhập đúng theo thông số catalog cơ khí máy:

| Tên Trục Cơ Cấu | Ô Cài Đặt Tỷ Số Truyền (`Gear_Ratio`) | Giá Trị Mặc Định | Ô Cài Đặt Max RPM (`Max_RPM`) | Giá Trị Mặc Định | Hướng Dẫn Kỹ Thuật & Ý Nghĩa Hoạt Động |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Trục Thu Cuộn T** | **`D200`** | `10.1` | **`D212`** | `1500 RPM` | • Động cơ Servo qua hộp số giảm tốc $10.1:1$.<br>• Max 1500 RPM đảm bảo dải mô-men xoắn lớn khi cuộn thu đạt đường kính cực đại $\varnothing 1000\text{ mm}$. |
| **Trục Kéo Giấy X1** | **`D202`** | `8.0` | **`D214`** | `1000 RPM` | • Hộp số $8:1$, dẫn động quả lô kéo giấy màng chính.<br>• Max 1000 RPM đáp ứng dải vận tốc dây chuyền lên đến $120\text{ m/phút}$. |
| **Trục Master X2** | **`D204`** | `8.0` | **`D216`** | `1000 RPM` | • **Trục chủ tốc độ (Line Master):** Trục quyết định vận tốc chuẩn cho toàn bộ dây chuyền.<br>• Tỷ số truyền $8:1$ tương đồng với trục X1 để đảm bảo tính tuyến tính tuyệt đối. |
| **Trục Ép Ghép Ms** | **`D206`** | `10.0` | **`D218`** | `3000 RPM` | • Lô ghép màng dùng động cơ Servo tốc độ cao qua hộp số $10:1$.<br>• Dải điều khiển tốc độ cực nhạy bám theo Master X2. |
| **Trục Tráng Keo/Dầu S** | **`D208`** | `10.0` | **`D220`** | `3000 RPM` | • Lô tráng keo dầu màng ghép.<br>• Điều khiển analog servo mượt mà, chống văng keo khi chạy tốc độ cao. |
| **Trục Xả Giấy/Màng U** | **`D210`** | `1.0` | — | — | • Trục xả màng U dẫn động trực tiếp $1:1$ (không qua hộp số giảm tốc trung gian). |
| **Trục Xả Metalize M** | **`D282`** | **`1.03125`**<br>($33/32$) | — | — | • Cuộn xả màng Metalize M truyền động qua bộ nhông xích/bánh răng tỷ số truyền $33/32 = 1.03125$.<br>• PLC tự động nhân hệ số bù $1.03125$ vào công thức tính đường kính cuộn `Real_Dia_M_mm` từ cảm biến tiệm cận đếm vòng `Sensor_Rev_M` (`X4A`), đảm bảo tính chuẩn xác từng milimet màng xả. |

> [!IMPORTANT]
> **Quy tắc tính toán vận tốc & Tỷ số truyền:** Vận tốc dài $V\text{ (m/p)} = \frac{\text{RPM}}{\text{Gear\_Ratio}} \times \frac{\pi \times D\text{ (mm)}}{1000}$. Khi thay đổi nhông xích hoặc hộp số cơ khí thực tế trên máy (ví dụ thay đổi nhông cuộn Metalize M $33/32$), chỉ cần cập nhật lại giá trị trên HMI tại `D282` (nhập `1.03125`), PLC sẽ tự động tính toán đồng bộ chuẩn xác tức thì.

---

### 📏 3.3. CÀI ĐẶT KÍCH THƯỚC LÔ CƠ CẤU & QUY CÁCH CUỘN MÀNG (D222..D240)

PLC Mitsubishi Q02U dùng các đường kính này để tự động tính toán chu vi, quy đổi xung Encoder và giám sát giới hạn cuộn màng:

#### 1. Đường Kính Quả Lô Cơ Cấu (Roller Diameter):
| Vị Trí Quả Lô | Địa Chỉ PLC | Kiểu Dữ Liệu | Kích Thước Chuẩn | Hướng Dẫn & Ý Nghĩa Kỹ Thuật |
| :--- | :---: | :---: | :---: | :--- |
| **Lô Kéo Giấy X1** | **`D222`** | `32-bit Float` | **`300.5 mm`** | Đường kính ngoài của quả lô thép kéo màng chính X1. |
| **Lô Master X2** | **`D224`** | `32-bit Float` | **`300.5 mm`** | Quả lô gắn Encoder đo mét và tính vận tốc dây chuyền `Current_Line_MPM` (`D10`). Cần đo chính xác bằng thước kẹp cơ khí. |
| **Lô Ép Ghép Ms** | **`D226`** | `32-bit Float` | **`200.0 mm`** | Đường kính quả lô nhiệt ép ghép màng 2 lớp. |
| **Lô Lăn Keo Dầu S** | **`D228`** | `32-bit Float` | **`100.0 mm`** | Quả lô cao su lăn keo bề mặt. |

#### 2. Quy Cách Lõi Cuộn & Đường Kính Cuộn Max (Core & Max Diameter):
| Trục Cuộn Màng | Ô Cài Đường Kính Lõi (`Core_Dia`) | Giá Trị Chuẩn | Ô Cài Đường Kính Max (`Max_Dia`) | Giá Trị Chuẩn | Ứng Dụng Trong Vận Hành |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Cuộn Thu Thành Phẩm T** | **`D230`** | `76.0 mm` | **`D236`** | `1000.0 mm` | • Lõi ống carton chuẩn phi 76mm.<br>• Khi mới nạp cuộn (`M8` hoặc `M5`), `Real_Dia_T` (`D330`) được nạp về `76.0 mm`. Khi quấn đầy máy cảnh báo chạm ngưỡng Max `1000.0 mm`. |
| **Cuộn Màng Thắng Từ M** | **`D232`** | `76.0 mm` | **`D238`** | `600.0 mm` | • Cuộn màng nguyên liệu mới bắt đầu từ $\varnothing 600\text{ mm}$ xả teo dần về lõi $76\text{ mm}$. |
| **Cuộn Xả Nhôm Metalize U**| **`D234`** | `76.0 mm` | **`D240`** | `800.0 mm` | • Cuộn nhôm mới bắt đầu từ $\varnothing 800\text{ mm}$ xả dần về lõi $76\text{ mm}$. |

---

### 🎯 3.4. CÀI ĐẶT TỶ LỆ ĐỒNG TỐC & BÙ TỐC ĐỘ TRỤC (D250..D264)

Hệ thống cho phép tinh chỉnh độ căng bề mặt màng giữa các quả lô thông qua tỷ lệ phần trăm đồng tốc và bù tốc độ:

| Thông Số Tinh Chỉnh | Địa Chỉ PLC | Giá Trị Chuẩn | Dải Cho Phép | Ý Nghĩa Chức Năng & Hướng Dẫn Vận Hành |
| :--- | :---: | :---: | :---: | :--- |
| **Tỷ Lệ Tốc Độ Thu T** (`Speed_Ratio_T`) | **`D250`** | **`1.05`** (105%) | `1.02 ~ 1.10` | • Thu T luôn cần chạy nhanh hơn vận tốc dây chuyền từ 2% ~ 8% để tạo lực căng đón đầu quấn chặt màng vào lõi.<br>• Nếu thấy cuộn thu bị chùng mép $\rightarrow$ Tăng lên `1.06` ~ `1.08`. |
| **Tỷ Lệ Tốc Độ Kéo X1** (`Speed_Ratio_X1`) | **`D252`** | **`1.00`** (100%) | `0.98 ~ 1.02` | • Đồng bộ 1:1 chuẩn xác với Master X2. Nếu giấy bị chùng trước lô ghép thì tăng nhẹ lên `1.01`. |
| **Tỷ Lệ Tốc Độ Ghép Ms** (`Speed_Ratio_Ms`) | **`D254`** | **`1.00`** (100%) | `0.98 ~ 1.02` | • Đồng bộ với Master X2. |
| **Tỷ Lệ Tốc Độ Lô Dầu S** (`Speed_Ratio_S`) | **`D256`** | **`1.00`** (100%) | `0.95 ~ 1.05` | • **Điều chỉnh lượng keo tráng:**<br>• Muốn tráng lớp keo dày hơn $\rightarrow$ Tăng tỷ lệ lên `1.03` ~ `1.05`.<br>• Muốn tráng keo mỏng mịn $\rightarrow$ Giảm tỷ lệ về `0.95` ~ `0.98`. |
| **Bù Tốc Độ X1 / Ms / S** (`Speed_Offset_*`) | **`D260, D262, D264`** | **`0.0 m/p`** | `-5.0 ~ +5.0` | • Lượng bù vận tốc cộng dồn tuyệt đối (m/phút) khi cần ép bù tốc độc lập ở các chế độ gia công đặc biệt. |

---

### 🔒 3.5. CÀI ĐẶT DẢI GIỚI HẠN TORQUE THẮNG TỪ M & XẢ U (D270..D280)

Hai cơ cấu xả màng hoạt động theo nguyên lý hãm mô-men xoắn (Torque Brake). Việc cài đặt trần sàn bảo vệ cuộn màng và cuộn dây thắng từ:

| Thông Số Torque | Địa Chỉ PLC | Giá Trị Chuẩn | Chức Năng Hoạt Động & Khuyến Nghị An Toàn |
| :--- | :---: | :---: | :--- |
| **Torque Thắng M Tối Thiểu** (`Min_Torque_M`) | **`D270`** | **`5.0 %`** | Lực hãm sàn thấp nhất khi xả màng. Tránh trường hợp lực hãm về 0 làm cuộn xả quay trơn trôi màng tự do. |
| **Torque Thắng M Tối Đa** (`Max_Torque_M`) | **`D272`** | **`80.0 %`** | Trần giới hạn trên. Không để ngõ ra quá 85% để chống nóng, chống cháy cuộn dây nam châm thắng từ khi chạy ca dài. |
| **Torque Giữ Khi Dừng M** (`Init_Holding_Torque_M`) | **`D274`** | **`20.0 %`** | Lực hãm tĩnh khi máy dừng (`State_Machine = 0`) để giữ chặt mép màng không xổ cuộn rơi xuống sàn. |
| **Torque Xả U Tối Thiểu** (`Min_Torque_U`) | **`D276`** | **`5.0 %`** | Lực hãm sàn cho cuộn nhôm Metalize U. |
| **Torque Xả U Tối Đa** (`Max_Torque_U`) | **`D278`** | **`80.0 %`** | Trần lực hãm tối đa cho cuộn xả nhôm U. |
| **Torque Giữ Khi Dừng U** (`Init_Holding_Torque_U`) | **`D280`** | **`20.0 %`** | Lực hãm tĩnh khi máy dừng cho cuộn xả nhôm U. |

---

### ⏱️ 3.6. CÀI ĐẶT XUNG ĐẾM ENCODER TRỤC MASTER QD62D (D290)

Hệ thống sử dụng module đếm xung tốc độ cao **QD62D** (Kênh 1 đọc Encoder Trục Master X2) để làm chuẩn đo đếm mét:

| Thông Số Kỹ Thuật | Địa Chỉ PLC | Kiểu Dữ Liệu | Giá Trị Chuẩn | Ghi Chú Kỹ Thuật |
| :--- | :---: | :---: | :---: | :--- |
| **Độ Phân Giải Encoder** (`PPR_Encoder`) | **`D290`** | `32-bit Signed (DINT)` | **`2000 PPR`** | Số xung trên 1 vòng quay của Encoder gắn trên trục Master X2. |
| **Nguyên Lý Đo Chiều Dài:** | Giá trị xung đếm thực tế được lưu tại `Curr_Pulse_X2` (**`D524`** - 32-bit DINT).<br>Công thức tính số mét màng tức thời:$$\text{Mét} = \frac{\text{Xung}}{4 \times \text{PPR} \times \text{Gear\_Ratio}} \times \frac{\pi \times D_{\text{Roller\_X2}}}{1000}$$Độ phân giải đếm đạt mức **dưới $0.1\text{ mm}$**, đảm bảo đo đếm chính xác đến từng centimet sản phẩm! |

---

### 🛠️ 3.7. BẢNG ĐIỀU KHIỂN TEST MANUAL / CHẠY THỬ ĐỘC LẬP 7 TRỤC (D620..D634, M30..M36)

Dành riêng cho thợ cơ điện, bảo trì khi cần kiểm tra chiều quay motor, test hộp số mới thay, kiểm tra vòng bi hoặc căn chỉnh quả lô mà **không cần chạy toàn bộ dây chuyền**:

```
[ BẢNG TEST MANUAL TỪNG TRỤC ] ────────────────────────────────────────────────────────────
• Trục 1 (Thu T):     Nút Test [ M30 (ON/OFF) ]  │ Tốc Độ: [ D620 ] m/p  │ Torque: [ D622 ] %
• Trục 2 (Kéo X1):    Nút Test [ M31 (ON/OFF) ]  │ Tốc Độ: [ D624 ] m/p  │
• Trục 3 (Master X2): Nút Test [ M32 (ON/OFF) ]  │ Tốc Độ: [ D626 ] m/p  │
• Trục 4 (Ghép Ms):   Nút Test [ M33 (ON/OFF) ]  │ Tốc Độ: [ D628 ] m/p  │
• Trục 5 (Dầu S):     Nút Test [ M34 (ON/OFF) ]  │ Tốc Độ: [ D630 ] m/p  │
• Trục 6 (Thắng M):   Nút Test [ M35 (ON/OFF) ]  │                     │ Torque: [ D632 ] %
• Trục 7 (Xả U):      Nút Test [ M36 (ON/OFF) ]  │ Tốc Độ: [ D634 ] m/p  │
───────────────────────────────────────────────────────────────────────────────────────────
```

#### 📋 Bảng Chi Tiết Cờ & Ô Cài Đặt Test Manual:
| Trục Động Cơ | Cờ Bật / Tắt Test | Kiểu Nút Bấm | Ô Nhập Tốc Độ Test (m/p) | Ô Nhập Torque Test (%) | Quy Tắc An Toàn Khi Test |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Trục Thu Cuộn T** | **`M30`** | `Toggle Bit` | **`D620`** (REAL) | **`D622`** (REAL) | Mở khoá ngàm cuộn thu trước khi test |
| **Trục Kéo X1** | **`M31`** | `Toggle Bit` | **`D624`** (REAL) | — | Nhả Pen ép 1 trước khi chạy |
| **Trục Master X2** | **`M32`** | `Toggle Bit` | **`D626`** (REAL) | — | Quan sát chiều quay lô chính |
| **Trục Ghép Ms** | **`M33`** | `Toggle Bit` | **`D628`** (REAL) | — | Nhả Pen ép 2 trước khi chạy |
| **Trục Dầu S** | **`M34`** | `Toggle Bit` | **`D630`** (REAL) | — | Chú ý chậu đựng keo/dầu |
| **Trục Thắng Từ M** | **`M35`** | `Toggle Bit` | — | **`D632`** (REAL) | Test thử lực hãm khi dùng tay xoay |
| **Trục Xả Metalize U**| **`M36`** | `Toggle Bit` | **`D634`** (REAL) | — | Kiểm tra trục xả màng nhôm |

> [!CAUTION]
> **CẢNH BÁO AN TOÀN:**
> 1. Chỉ thực hiện Chạy thử Manual khi **Máy đang Dừng (`State_Machine = 0`)**.
> 2. Đảm bảo toàn bộ công nhân đứng cách xa các quả lô quay và dao cắt trước khi bật cờ test `M30..M36`.
> 3. Sau khi test xong, **bắt buộc phải tắt cờ test về OFF** trước khi chuyển lại chế độ Tự Động (Auto).

---

### ⚖️ 3.8. QUY TRÌNH CÂN CHỈNH (CALIB) LOADCELL LỰC CĂNG 0..50kg (D300..D316, M28..M29)

Hệ thống sử dụng module analog đầu vào **Q68ADV** (độ phân giải 16-bit, dải tín hiệu $0..10\text{V} = 0..16000$ điểm số nguyên) tương ứng dải tải trọng $0.0\text{ kg} .. 50.0\text{ kg}$.

#### 📋 Bảng Thanh Ghi Cân Chỉnh 4 Trục Loadcell:
| Vị Trí Loadcell Lực Căng | Kênh ADC (Q68ADV) | Ô Điểm 0 Zero (`Zero_Offset`) | Ô Hệ Số Calib (`Calib_Gain`) | Giá Trị Lực Thực Tế (`Weight_Net`) | Nút Bấm Zero | Nút Bấm Calib |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Trục 1: Cuộn Thu T** | Kênh 1 (`D500`) | **`D300`** | **`D310`** | **`D320`** (kg) | `M20` (hoặc `M28` khi chọn trục 1) | `M24` (hoặc `M29` khi chọn trục 1) |
| **Trục 2: Kéo Giấy X1** | Kênh 2 (`D501`) | **`D302`** | **`D312`** | **`D322`** (kg) | `M21` (hoặc `M28` khi chọn trục 2) | `M25` (hoặc `M29` khi chọn trục 2) |
| **Trục 6: Thắng Từ M** | Kênh 3 (`D502`) | **`D304`** | **`D314`** | **`D324`** (kg) | `M22` (hoặc `M28` khi chọn trục 6) | `M26` (hoặc `M29` khi chọn trục 6) |
| **Trục 7: Xả Metalize U**| Kênh 4 (`D503`) | **`D306`** | **`D316`** | **`D326`** (kg) | `M23` (hoặc `M28` khi chọn trục 7) | `M27` (hoặc `M29` khi chọn trục 7) |

#### 📝 Quy Trình 2 Bước Calib Chuẩn Xác Tuyệt Đối:
1. **Bước 1: Lấy điểm không tải (Zero Calibration):**
   - Tháo hết màng ra khỏi quả lô Loadcell cần chỉnh, để quả lô ở trạng thái tự do 100%.
   - Nhập số thứ tự trục vào ô `HMI_Axis_Select` (**`D600`**) (ví dụ nhập `1` cho trục Thu T).
   - Nhấn nút **`ZERO SET CHUNG` (`M28`)**.
   - PLC sẽ chụp giá trị điện áp tĩnh hiện tại của kênh ADC tương ứng và lưu cố định vào ô `Zero_Offset` (ví dụ `D300`). Ô hiển thị lực `Weight_Net` sẽ nhảy ngay về **`0.0 kg`**.
2. **Bước 2: Cân chỉnh tải mẫu (Span/Gain Calibration):**
   - Dùng một sợi dây màng vắt qua giữa quả lô Loadcell (theo đúng góc ôm của đường đi màng thực tế).
   - Treo một quả cân chuẩn đã biết chính xác trọng lượng (ví dụ quả cân chuẩn $10.0\text{ kg}$).
   - Nhấn nút **`CALIB SET CHUNG` (`M29`)**.
   - Thuật toán PLC sẽ tự động tính toán:
     $$\text{Calib\_Gain} = \frac{\text{Trọng Lượng Quả Cân } (10.0\text{ kg})}{\text{Raw\_ADC} - \text{Zero\_Offset}}$$
   - Hệ số Gain mới được ghi ngay vào thanh ghi `Calib_Gain` (ví dụ `D310`). Ô hiển thị lực `Weight_Net` sẽ chỉ đúng $10.0\text{ kg} \pm 0.05\text{ kg}$.
   - Tháo quả cân ra $\rightarrow$ Màn hình quay về đúng `0.0 kg` hoàn hảo!

---

### 🛡️ 3.9. HƯỚNG DẪN PHÂN QUYỀN BẢO MẬT MẬT KHẨU (SECURITY PASSWORD) TRÊN WEINTEK

Để ngăn ngừa tình trạng công nhân vận hành vô tình bấm nhầm làm thay đổi tỷ số truyền, đường kính lô hoặc xung Encoder gây sự cố dây chuyền, Trang Cài Đặt Máy cần được thiết lập phân quyền mật khẩu bảo vệ trên phần mềm **EasyBuilder Pro**:

1. **Thiết lập Cấp Độ Bảo Mật (User Password & Class):**
   - Trong EasyBuilder Pro, mở menu **`Project`** $\rightarrow$ **`System Parameters`** $\rightarrow$ Chọn tab **`Security`**.
   - Cài đặt mật khẩu cho cấp quản trị (**Class A / Admin / Kỹ Thuật**): ví dụ `888888` hoặc `123456`.
2. **Khóa Nút Chuyển Trang Cài Đặt Máy:**
   - Tại nút bấm chuyển sang Trang Cài Đặt Máy (Function Key / Window Change Button) trên màn hình chính:
   - Chuột phải vào nút $\rightarrow$ Chọn **`Properties`** $\rightarrow$ Chọn tab **`Security`**.
   - Tick chọn **`Security Level`** $\rightarrow$ Chọn cấp độ **`Class A`**.
3. **Hiệu Ứng Vận Hành Thực Tế:**
   - Khi công nhân bấm vào nút "Cài Đặt Máy", HMI sẽ tự động bật popup yêu cầu nhập mật khẩu.
   - Chỉ khi kỹ sư bảo trì hoặc quản đốc nhập đúng mật khẩu thì màn hình cài đặt mới mở ra.
   - Khi không thao tác sau 3 phút, HMI tự động đăng xuất và khóa lại màn hình.

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
| | `D282` | `REAL` | `Gear_Ratio_M` | Tỷ số truyền nhông xích Xả Metalize M (33/32 = 1.03125) |
| | `D290` | `DINT` | `PPR_Encoder` | Độ phân giải Encoder (2000 PPR) |
| **Cân Chỉnh Loadcell** | `D300..D306`| `REAL` | `Zero_Offset_T..U` | Điểm 0 Zero Offset Loadcell 4 trục |
| | `D310..D316`| `REAL` | `Calib_Gain_T..U` | Hệ số khuếch đại Calib Loadcell 4 trục |
| | `D320..D326`| `REAL` | `Weight_Net_T..U` | Trọng lượng lực căng thực tế (kg) |
| | `D330..D334`| `REAL` | `Real_Dia_T..U` | Đường kính cuộn tính toán thực tế (mm) |
| **PID Tuning 7 Trục** | `D340..D344`| `REAL` | `Kp_T, Ki_T, Kd_T` | Thông số PID cuộn Thu T |
| | `D346..D350`| `REAL` | `Kp_X1, Ki_X1, Kd_X1` | Thông số PID trục Kéo X1 |
| | `D352..D356`| `REAL` | `Kp_X2, Ki_X2, Kd_X2` | Thông số PID trục Master X2 |
| | `D358..D362`| `REAL` | `Kp_Ms, Ki_Ms, Kd_Ms` | Thông số PID trục Ghép Ms |
| | `D364..D368`| `REAL` | `Kp_S, Ki_S, Kd_S` | Thông số PID trục Dầu S |
| | `D370..D374`| `REAL` | `Kp_M, Ki_M, Kd_M` | Thông số PID Thắng Từ M |
| | `D376..D380`| `REAL` | `Kp_U, Ki_U, Kd_U` | Thông số PID trục Xả U |
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
