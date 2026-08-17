# 🖥️ HƯỚNG DẪN THIẾT KẾ GIAO DIỆN HMI WEINTEK MT6103iP (10.1" - 1024x600)
## DỰ ÁN: MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - MITSUBISHI Q02U PLC

---

## 🛠️ PHẦN 1: THÔNG SỐ CƠ KHÍ & TỐC ĐỘ MAX RPM CÁC TRỤC ĐỘNG CƠ

| Trục Động Cơ | Tên Trục | Tốc độ Max RPM | Chế độ chạy khi máy Auto | Tỷ số truyền `Speed_Ratio` | Chế độ chạy Test độc lập |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **Trục X2** | **Master Trục Chính** | **1000 RPM** | Quyết định tốc độ dây chuyền + **`pid_X2` Tốc Độ** | Chuẩn gốc | Cờ `M172` + Tốc độ test `D804` |
| **Trục X1** | **Kéo / Xả Giấy X1** | **1000 RPM** | Đồng bộ vận tốc dài theo X2 + **`pid_X1` Lực căng** | `Speed_Ratio_X1` (`D758`) | Cờ `M171` + Tốc độ test `D802` |
| **Trục Ms** | **Lô Ép Ghép Ms** | **3000 RPM** | Đồng bộ vận tốc dài theo X2 + **`pid_Ms` Tốc Độ** | `Speed_Ratio_Ms` (`D760`) | Cờ `M173` + Tốc độ test `D806` |
| **Trục S** | **Lô Tráng Dầu S** | **3000 RPM** | Đồng bộ vận tốc dài theo X2 + **`pid_S` Tốc Độ** | `Speed_Ratio_S` (`D762`) | Cờ `M174` + Tốc độ test `D808` |
| **Trục T** | **Thu Cuộn T** | **1500 RPM** | **Speed / Torque**: Chạy nhanh hơn để giữ Torque | `Speed_Ratio_T` (`D756`) | Cờ `M170` + Tốc test `D800`/`D801` |
| **Trục M** | **Thắng Từ Xả Film**| - | 3 Pha Torque + **`pid_M` Lực căng Loadcell** | - | Cờ `M175` + Torque test `D810` |
| **Trục U** | **Xả Cuộn Giấy U** | - | Theo Ø Cuộn Xả + **`pid_U` Lực căng Loadcell** | - | Cờ `M176` + Tốc độ test `D812` |

---

## 🛠️ PHẦN 2: CẤU HÌNH KẾT NỐI PLC (SYSTEM PARAMETERS)

Trong phần mềm **EasyBuilder Pro**:
1. Tạo dự án mới $\rightarrow$ Chọn Model: **`MT6103iP (1024 x 600)`**.
2. Vào **`Home`** $\rightarrow$ **`System Parameters`** $\rightarrow$ Thêm thiết bị mới (**New Device**):
   * **Device Type:** `Mitsubishi Q00/Q00UJ/Q01/QJ71`.
   * **Interface:** `RS-232` (hoặc Ethernet).
   * **COM Port:** `COM1 (19200, O, 8, 1)`.
   * **PLC Station No.:** `0`.
3. Nhập bảng Tag biến:
   * Vào menu **`Project`** $\rightarrow$ **`Address Tag Library`** $\rightarrow$ Bấm nút **`Import...`** $\rightarrow$ Chọn file [`weintek_easybuilder_tags_import.csv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/weintek_easybuilder_tags_import.csv).
   * Toàn bộ 80+ biến điều khiển sẽ được nạp tự động vào HMI chỉ trong 1 click!

---

## 🎨 PHẦN 3: THIẾT KẾ 5 MÀN HÌNH CHỨC NĂNG (1024 x 600)

### 🔹 MÀN HÌNH 10: VẬN HÀNH CHÍNH (MAIN OPERATION)
* **Khung Tốc độ chính:** Hiển thị `Current_Line_MPM` (`D730`), Ô cài đặt `Target_Line_MPM` (`D732`).
* **Nút bấm điều khiển:** `START` (`M102`), `STOP` (`M103`), `INC` (`M109`), `DEC` (`M114`), `PEN 1` (`M115`), `PEN 2` (`M116`).
* **Đường kính thực 3 cuộn:** Cuộn Thu T (`D724`), Cuộn Xả M (`D722`), Cuộn Xả U (`D720`) + Nút nạp cuộn mới (`M105, M106, M107`).
* **Đồng hồ Mét hàng:** Đã chạy (`D708`), Cài đặt dừng (`D700`), Reset mét (`M104`).
* **5 Đèn Servo Ready:** `M1104..M1108` (T, X1, X2, Ms, S).

---

### 🔹 MÀN HÌNH 20: CÀI ĐẶT LỰC CĂNG & PID CÁC TRỤC (TENSION & PID SETTING)
* **Cài đặt lực căng đặt:** SP_T (`D660`), SP_X1 (`D662`), SP_M (`D664`), SP_U (`D668`).
* **Cài đặt hệ số PID Lực căng:** Kp, Ki, Kd cho 4 trục T, X1, M, U (`D670..D692`).
* **Cài đặt hệ số PID Tốc độ:** Kp, Ki, Kd cho 3 trục X2, Ms, S (`D681..D698`).
* **Cài đặt Tỷ lệ tốc độ `Speed_Ratio` (1000 = 100.0%):**
  * `Speed_Ratio_T` (`D756`): Mặc định `1050` (chạy nhanh hơn 5% để căng giữ Torque).
  * `Speed_Ratio_X1` (`D758`): Mặc định `1000`.
  * `Speed_Ratio_Ms` (`D760`): Mặc định `1000`.
  * `Speed_Ratio_S` (`D762`): Mặc định `1000` (>1000 chạy nhanh hơn, <1000 chạy chậm hơn).
* **Côn lực Taper Tension T:** `D666` (% Côn lực).
* **3 Pha Thắng M:** `D764` (Hold), `D760` (Min), `D762` (Max).

---

### 🔹 MÀN HÌNH 30: CHẾ ĐỘ TEST RIÊNG BIỆT TỪNG TRỤC (MANUAL / JOG TEST)
Dành cho kỹ sư đứng máy căn chỉnh từng trục độc lập:

| Trục Động Cơ | Cờ Kích Hoạt Test (Toggle/Set Bit) | Ô Nhập Tốc Độ Test (Numeric Input 0..4000) | Ô Nhập Torque Test (0..4000) |
| :--- | :---: | :---: | :---: |
| 🔵 **Test Trục Master X2** | **`M172`** | **`D804`** (`Test_Speed_X2`) | - |
| 🔵 **Test Trục Kéo X1** | **`M171`** | **`D802`** (`Test_Speed_X1`) | - |
| 🔵 **Test Trục Ghép Ms** | **`M173`** | **`D806`** (`Test_Speed_Ms`) | - |
| 🔵 **Test Trục Dầu S** | **`M174`** | **`D808`** (`Test_Speed_S`) | - |
| 🔵 **Test Trục Thu T** | **`M170`** | **`D800`** (`Test_Speed_T`) | **`D801`** (`Test_Torque_T`) |
| 🔵 **Test Thắng Từ M** | **`M175`** | - | **`D810`** (`Test_Torque_M`) |
| 🔵 **Test Trục Xả U** | **`M176`** | **`D812`** (`Test_Speed_U`) | - |

---

### 🔹 MÀN HÌNH 40: CÂN CHỈNH LOADCELL & CƠ KHÍ (CALIBRATION)
* 4 Nút Cân Bì Zero Loadcell: `M110` (T), `M111` (X1), `M112` (M), `M113` (U).
* Cài đặt Gia tốc đường dốc: `D704` (`Ramp_Accel_Rate`), `D706` (`Ramp_Decel_Rate`).

---

### 🔹 MÀN HÌNH 50: BÁO LỖI & CHẨN ĐOÁN (ALARMS & DIAGNOSTICS)
* Đèn trạng thái 3 Trạm CC-Link: Trạm 1 AD (`M1016`), Trạm 2&3 DA (`M1064`), Trạm 4 16DT.
* Bảng Báo Động (Alarm Display Object).
* Nút bấm RESET LỖI TOÀN HỆ THỐNG: `M101`.

---

### 🔹 THANH ĐIỀU HƯỚNG DƯỚI CÙNG (BOTTOM NAVIGATION BAR - TỌA ĐỘ Y: 540..600):
5 Nút chuyển trang (**Function Key / Change Window Button**):
`[F1: VẬN HÀNH]`  `[F2: CÀI ĐẶT PID]`  `[F3: TEST TRỤC]`  `[F4: CÂN CHỈNH]`  `[F5: BÁO LỖI]`
