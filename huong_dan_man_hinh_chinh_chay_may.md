# 🖥️ HƯỚNG DẪN THIẾT KẾ & VẬN HÀNH MÀN HÌNH CHÍNH (MAIN OPERATION)
### DỰ ÁN: DÂY CHUYỀN MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG (PLC MITSUBISHI Q02U - HMI WEINTEK)

---

## 📐 1. SƠ ĐỒ BỐ TRÍ TỔNG THỂ GIAO DIỆN (LAYOUT 1024 x 600)

```
+-------------------------------------------------------------------------------------------------------+
|  [LOGO / TÊN MÁY GHÉP MÀNG METALIZE]                 [TRẠNG THÁI: RUN / STOP]     15:30:00  18/08/2026|
+------------------------------------+----------------------------------+-------------------------------+
| 🚀 KHỐI ĐIỀU KHIỂN TỐC ĐỘ DÂY CHUYỀN| 📏 KHỐI ĐO MÉT & TỰ ĐỘNG DỪNG    | 🛡️ TRẠNG THÁI 5 SERVO READY   |
|                                    |                                  |                               |
| Tốc độ thực tế: [ 45.5 ] m/phút    | Tổng mét đã ghép: [ 1250.5 ] m   | [●] Servo Thu T   (M1104)     |
| Tốc độ cài đặt: [ 50.0 ] m/phút    | Cài mét tự dừng:  [ 2000.0 ] m   | [●] Servo Kéo X1  (M1105)     |
| Tốc độ Max / Min: [100.0] / [2.0]  | Khoảng cách hãm:  [   50.0 ] m   | [●] Servo Main X2 (M1106)     |
|                                    | [ RESET MÉT HÀNG (M104) ]        | [●] Servo Ghép Ms (M1107)     |
| [ ▲ INC (M109) ]  [ ▼ DEC (M114) ] |                                  | [●] Servo Dầu S   (M1108)     |
+------------------------------------+----------------------------------+-------------------------------+
| 🔘 NÚT ĐIỀU KHIỂN CHÍNH & 2 PEN ÉP | ⚖️ GIÁM SÁT 4 LỰC CĂNG LOADCELL  | 🔄 GIÁM SÁT ĐƯỜNG KÍNH 3 CUỘN |
|                                    |                                  |                               |
| [   START MÁY (M102)   ] (Xanh)    | 1. Cuộn Thu T:     [15.2] / 15.0 kg| • Cuộn Thu T:      [Ø 450] mm  |
| [   STOP MÁY  (M103)   ] (Đỏ)      | 2. Kéo Xả X1:      [12.0] / 12.0 kg|   [ Nạp Cuộn Mới T (M105) ]   |
|                                    | 3. Thắng Metalize M:[ 6.1] /  6.0 kg| • Thắng Metalize M:[Ø 680] mm  |
| [ PEN 1 ÉP MÀNG (M115) ] (ON/OFF)  | 4. Xả Sau Cùng U:  [10.1] / 10.0 kg|   [ Nạp Cuộn Mới M (M106) ]   |
| [ PEN 2 ÉP MÀNG (M116) ] (ON/OFF)  |                                  | • Xả Sau Cùng U:   [Ø 720] mm  |
| [ BẬT PID TỰ ĐỘNG (M108) ] (ON)    | (Giá trị thực tế / Giá trị SP đặt)|   [ Nạp Cuộn Mới U (M107) ]   |
+------------------------------------+----------------------------------+-------------------------------+
| [F1: MÀN HÌNH CHÍNH]   [F2: CÀI ĐẶT PID / CALIB]   [F3: TEST TỪNG TRỤC]   [F4: BÁO LỖI]   [RESET LỖI] |
+-------------------------------------------------------------------------------------------------------+
```

---

## 📋 2. BẢNG CHI TIẾT CÁC ĐỐI TƯỢNG (OBJECTS) TRÊN MÀN HÌNH CHÍNH

### A. Khối Vận Hành Chạy / Dừng & Điều Khiển Tốc Độ
| Tên Đối Tượng trên HMI | Loại Object trong EasyBuilder Pro | Tag / Địa Chỉ PLC | Kiểu Dữ Liệu | Chức Năng & Thao Tác |
| :--- | :--- | :---: | :---: | :--- |
| **Nút START** | Bit Button (Momentary / Set ON) | **`M102`** (`HMI_Start`) | Bit | Khởi động chạy máy tự động |
| **Nút STOP** | Bit Button (Momentary / Set ON) | **`M103`** (`HMI_Stop`) | Bit | Dừng máy giảm tốc an toàn |
| **Phím TĂNG TỐC (INC)** | Bit Button (Momentary) | **`M109`** (`HMI_Inc_Hold`) | Bit | Bấm hoặc giữ để tăng dần tốc độ màng |
| **Phím GIẢM TỐC (DEC)** | Bit Button (Momentary) | **`M114`** (`HMI_Dec_Hold`) | Bit | Bấm hoặc giữ để giảm dần tốc độ màng |
| **Tốc độ thực tế** | Numeric Display | **`D730`** (`Current_Line_MPM`) | `32-bit Float` | Tốc độ dây chuyền hiện tại (`m/phút`) |
| **Tốc độ mục tiêu** | Numeric Input | **`D732`** (`Target_Line_MPM`) | `32-bit Float` | Cài đặt tốc độ mong muốn (`m/phút`) |
| **Tốc độ Max** | Numeric Input / Display | **`D734`** (`Max_Speed_MPM`) | `32-bit Float` | Giới hạn tốc độ Max (Mặc định `100.0`) |
| **Tốc độ Min** | Numeric Input / Display | **`D736`** (`Min_Speed_MPM`) | `32-bit Float` | Giới hạn tốc độ Min (Mặc định `2.0`) |

---

### B. Khối Điều Khiển 2 Pen Ép Màng & Chế Độ PID
| Tên Đối Tượng trên HMI | Loại Object trong EasyBuilder Pro | Tag / Địa Chỉ PLC | Kiểu Dữ Liệu | Chức Năng & Thao Tác |
| :--- | :--- | :---: | :---: | :--- |
| **Công tắc PEN 1** | Toggle Switch / Bit Lamp Button | **`M115`** (`HMI_Pen1_Cmd`) | Bit | Đóng/Nhả Pen 1 ép màng (Van solenoid `YD`) |
| **Công tắc PEN 2** | Toggle Switch / Bit Lamp Button | **`M116`** (`HMI_Pen2_Cmd`) | Bit | Đóng/Nhả Pen 2 ép màng (Van solenoid `YE`) |
| **Bật/Tắt PID** | Toggle Switch | **`M108`** (`HMI_PID_Enable`) | Bit | Kích hoạt tự động cân chỉnh lực căng PID |
| **Reset Lỗi Hệ Thống** | Bit Button (Momentary) | **`M101`** (`HMI_Reset_Error`) | Bit | Xóa cờ báo lỗi truyền thông / Servo |

---

### C. Khối Giám Sát Đường Kính & Nạp Lại Cuộn Mới
| Tên Đối Tượng trên HMI | Loại Object | Tag / Địa Chỉ PLC | Kiểu Dữ Liệu | Chức Năng & Thao Tác |
| :--- | :--- | :---: | :---: | :--- |
| **Đường kính Cuộn Thu T** | Numeric Display | **`D724`** (`Real_Dia_T_mm`) | `32-bit Float` | Đường kính thực tế cuộn Thu T (`mm`) |
| **Nút Nạp Cuộn Mới T** | Bit Button (Momentary) | **`M105`** (`HMI_Reset_Roll_T`) | Bit | Đặt lại Ø Thu T về đường kính lõi (`D740`) |
| **Đường kính Thắng Metalize M** | Numeric Display | **`D722`** (`Real_Dia_M_mm`) | `32-bit Float` | Đường kính cuộn xả màng Metalize (`mm`) |
| **Nút Nạp Cuộn Mới M** | Bit Button (Momentary) | **`M106`** (`HMI_Reset_Roll_M`) | Bit | Đặt lại Ø M về đường kính cuộn Max (`D752`) |
| **Đường kính Cuộn Xả Sau Cùng U** | Numeric Display | **`D720`** (`Real_Dia_U_mm`) | `32-bit Float` | Đường kính cuộn xả sau cùng (`mm`) |
| **Nút Nạp Cuộn Mới U** | Bit Button (Momentary) | **`M107`** (`HMI_Reset_Roll_U`) | Bit | Đặt lại Ø U về đường kính cuộn Max (`D754`) |

---

### D. Khối Đo Chiều Dài Mét Hàng & Tự Động Dừng Máy
| Tên Đối Tượng trên HMI | Loại Object | Tag / Địa Chỉ PLC | Kiểu Dữ Liệu | Chức Năng & Thao Tác |
| :--- | :--- | :---: | :---: | :--- |
| **Tổng mét hàng đã ghép** | Numeric Display | **`D708`** (`Total_Length_Meters`)| `32-bit Float` | Chiều dài mét tích lũy từ Encoder X2 (`m`) |
| **Cài đặt mét dừng máy** | Numeric Input | **`D700`** (`Set_Target_Length`) | `32-bit Float` | Đặt số mét cần chạy để máy tự dừng (`m`) |
| **Khoảng cách báo giảm tốc** | Numeric Input | **`D702`** (`Decel_Distance_Meters`)| `32-bit Float`| Cách đích bao nhiêu mét thì hãm về 2 m/p |
| **Nút Reset Mét Hàng** | Bit Button (Momentary) | **`M104`** (`HMI_Reset_Length`) | Bit | Xóa tổng mét đã chạy về `0.0 m` |

---

### E. Khối Giám Sát 4 Lực Căng Loadcell
| Trục Giám Sát | Lực Căng Thực Tế (kg) | Lực Căng Cài Đặt SP (kg) | Trạng Thái Điều Khiển |
| :--- | :---: | :---: | :--- |
| **1. Cuộn Thu T** | **`D510`** (`Weight_Net_T`) | **`D660`** (`SP_Tension_T`) | Tự động tính Côn lực Taper (`D666`) |
| **2. Trục Kéo Xả X1** | **`D512`** (`Weight_Net_X1`) | **`D662`** (`SP_Tension_X1`) | PID bù tốc độ Servo Kéo X1 |
| **3. Thắng Từ Metalize M** | **`D514`** (`Weight_Net_M`) | **`D664`** (`SP_Tension_M`) | 3 Pha Torque + PID Thắng từ |
| **4. Cuộn Xả Sau Cùng U** | **`D516`** (`Weight_Net_U`) | **`D668`** (`SP_Tension_U`) | PID bù tốc độ/Torque xả sau cùng |

---

### F. Khối Đèn Báo Trạng Thái Sẵn Sàng (Interlock Safety)
| Đèn Báo | Địa Chỉ PLC | Màu Sắc Bình Thường | Ý Nghĩa Kỹ Thuật |
| :--- | :---: | :---: | :--- |
| **Servo Ready Thu T** | `M1104` (X0) | 🟢 XANH LÁ | Driver Servo Thu T sẵn sàng |
| **Servo Ready Kéo X1** | `M1105` (X1) | 🟢 XANH LÁ | Driver Servo Kéo X1 sẵn sàng |
| **Servo Ready Main X2** | `M1106` (X2) | 🟢 XANH LÁ | Driver Servo Trục chính X2 sẵn sàng |
| **Servo Ready Ghép Ms** | `M1107` (X3) | 🟢 XANH LÁ | Driver Servo Lô Ghép Ms sẵn sàng |
| **Servo Ready Dầu S** | `M1108` (X4) | 🟢 XANH LÁ | Driver Servo Lô Tráng Dầu S sẵn sàng |
| **Cảnh Báo Lỗi Servo** | `M134` | 🔴 ĐỎ (Nhấp nháy) | 1 trong 5 Servo bị ngắt/báo lỗi |

---

## 🚀 3. QUY TRÌNH 5 BƯỚC VẬN HÀNH CHẠY MÁY THỰC TẾ

### 🔹 Bước 1: Chuẩn bị & Kiểm tra an toàn trước khi chạy
1. Bật nguồn tủ điện, mở màn hình HMI.
2. Nhìn góc trên bên phải màn hình chính: Đảm bảo **5 đèn Servo Ready đều sáng XANH LÁ**.
3. Nếu có đèn đỏ hoặc cờ báo lỗi $\rightarrow$ Nhấn **`RESET LỖI`** (`M101`).

### 🔹 Bước 2: Nạp cuộn mới & Chuẩn bị màng
1. Gá cuộn màng mới vào trục Thu T, trục Thắng Metalize M, trục Xả Sau Cùng U.
2. Trên màn hình chính, nhấn các nút nạp cuộn:
   - Nhấn **`NẠP CUỘN MỚI T`** (`M105`) $\rightarrow$ Đường kính T nạp về đường kính lõi (VD: `76 mm` hoặc `150 mm`).
   - Nhấn **`NẠP CUỘN MỚI M`** (`M106`) $\rightarrow$ Đường kính M nạp về đường kính cuộn đầy (VD: `700 mm`).
   - Nhấn **`NẠP CUỘN MỚI U`** (`M107`) $\rightarrow$ Đường kính U nạp về đường kính cuộn đầy (VD: `750 mm`).
3. Nếu cần đo đơn hàng mới $\rightarrow$ Nhấn **`RESET MÉT HÀNG`** (`M104`).

### 🔹 Bước 3: Cài đặt thông số đơn hàng
1. Nhập **Tốc độ mục tiêu** (`D732`): Ví dụ `50.0 m/phút` (hoặc `60.0 m/phút`).
2. Nhập **Tổng số mét cần chạy** (`D700`): Ví dụ `3000 m` (Nếu chạy tự do không giới hạn, nhập `0`).
3. Bật công tắc **`BẬT PID TỰ ĐỘNG`** (`M108`) sang vị trí **ON**.

### 🔹 Bước 4: Khởi động chạy máy
1. Nhấn nút **`START MÁY`** (`M102`) trên HMI (hoặc nút vật lý màu xanh trên tủ).
2. Dây chuyền sẽ tự động Ramping tăng tốc êm ái từ `0` lên tốc độ bò `2.0 m/phút` rồi tăng dần đều theo độ dốc gia tốc cài đặt.
3. Khi tốc độ vượt qua ngưỡng `5.0 m/phút`, người vận hành nhấn nút **`PEN 1`** (`M115`) và **`PEN 2`** (`M116`) để đóng 2 pen ép màng ghép.
4. Có thể nhấn giữ phím **`INC`** / **`DEC`** để tinh chỉnh tăng/giảm tốc độ linh hoạt theo tình trạng keo/màng thực tế.

### 🔹 Bước 5: Giảm tốc và Dừng máy
* **Trường hợp máy tự động dừng:** Khi tổng mét (`D708`) đạt tới `2950 m` (cách đích `50 m`), máy tự động hãm về `2.0 m/phút`. Khi đủ đúng `3000 m`, máy tự động ngắt dừng hoàn toàn và tự nhả 2 pen ép màng.
* **Trường hợp người vận hành chủ động dừng:** Nhấn nút **`STOP MÁY`** (`M103`), máy sẽ hãm dừng theo đường dốc DEC và tự động nhả 2 Pen ép màng an toàn.
