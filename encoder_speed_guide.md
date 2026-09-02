# HƯỚNG DẪN CẤU HÌNH & LẬP TRÌNH ĐỌC 5 ENCODER TÍNH RPM/MPM MÁY GHÉP METALIZE

Tài liệu hướng dẫn cấu hình 03 module đếm xung **QD62** và chương trình đo tốc độ dây chuyền máy ghép màng Metalize cho 5 trục (**T, X1, X2, M, S**).

---

## 📋 1. SƠ ĐỒ PHÂN BỔ PHẦN CỨNG & KÊNH ĐẾM XUNG QD62

Dựa trên cấu hình phần cứng `I/O Assignment` trong PLC Q02U của bạn:

| Slot | Tên Module | Head I/O | Kênh (Channel) | Trục Đếm Encoder | Tín Hiệu Xung | Cờ Cho Phép Đếm (`Y` Bit) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Slot 1** | **QD62 #1** | `H0020` | **CH1** | **Trục Thu T** | Phase A/B | **`Y21 := TRUE;`** |
| | | | **CH2** | **Trục Xả X1** | Phase A/B | **`Y22 := TRUE;`** |
| **Slot 2** | **QD62 #2** | `H0030` | **CH1** | **Trục Master X2** | Phase A/B | **`Y31 := TRUE;`** |
| | | | **CH2** | **Trục Metalize M** | Phase A/B | **`Y32 := TRUE;`** |
| **Slot 3** | **QD62 #3** | `H0040` | **CH1** | **Trục Dầu S** | Phase A/B | **`Y41 := TRUE;`** |
| | | | **CH2** | Dự phòng (Spare) | - | - |

---

## ⚙️ 2. CẤU HÌNH SWITCH SETTING TRÊN GX WORKS2 (CHẾ ĐỘ ĐẾM XUNG 4X)

Vào **`PLC Parameter`** $\rightarrow$ **`I/O Assignment`** $\rightarrow$ **`Switch Setting`**:

1. **Slot 1 (QD62 #1 - H20):**
   - **Switch 1 (CH1 - Trục T):** Nhập **`0003`** *(2-Phase 4x Multiple)*
   - **Switch 2 (CH2 - Trục X1):** Nhập **`0003`** *(2-Phase 4x Multiple)*
2. **Slot 2 (QD62 #2 - H30):**
   - **Switch 1 (CH1 - Trục X2 Master):** Nhập **`0003`**
   - **Switch 2 (CH2 - Trục Metalize M):** Nhập **`0003`**
3. **Slot 3 (QD62 #3 - H40):**
   - **Switch 1 (CH1 - Trục Dầu S):** Nhập **`0003`**
   - **Switch 2 (CH2 - Dự phòng):** Nhập **`0003`**

---

## ⏱️ 3. CHẾ ĐỘ CHẠY QUÉT LIÊN TỤC (MAIN SCAN) & TRIGGER TÍNH TOÁN 100MS

Chương trình chạy trong **Scan Execution (Main Scan liên tục)** để đảm bảo bắt trọn vẹn tín hiệu Sensor quang/tiệm cận đếm số vòng quay cuộn màng (tính đường kính tức thời mà không bị trượt xung).

1. Trong cây thư mục **`POU`** $\rightarrow$ Đặt POU ở chế độ **`Scan Execution`** (chạy liên tục theo chu kỳ quét chính của PLC).
2. Xung tính toán chu kỳ 100ms được tạo bằng cờ nhịp hệ thống **`SM410` (0.1s Clock của Mitsubishi Q-Series)**:
   ```pascal
   PLS(SM410, Trig_100ms); (* 100ms tạo 1 xung chốt số liệu *)
   ```
3. Công thức tính toán tốc độ chốt mỗi 100ms:
   - **RPM (vòng/phút):** `RPM := (DINT_TO_REAL(Delta_Pulse) * 600.0) / DINT_TO_REAL(Total_PPR);`
   - **MPM (mét/phút):** `MPM := (RPM * 3.14159265 * Dia_mm) / (1000.0 * Gear_Ratio);`

---

## 📊 4. BẢNG BIẾN THỐNG KÊ KẾT QUẢ ĐO VÀ ĐÂU NỐI MÀN HÌNH HMI (32-BIT FLOAT)

| Tên Biến | Địa Chỉ PLC | Kiểu Dữ Liệu | Đơn Vị | Ý Nghĩa Hiển Thị Trên HMI |
| :--- | :--- | :--- | :--- | :--- |
| `RPM_X2` | `D5014` | **`REAL` (32-bit Float)** | RPM | Tốc độ vòng/phút Trục Master X2 (VD: `150.25`) |
| **`MPM_X2`** | `D5024` | **`REAL` (32-bit Float)** | **m/phút** | **Tốc độ máy ghép Metalize (VD: `120.50`)** |
| `RPM_T` | `D5010` | **`REAL` (32-bit Float)** | RPM | Tốc độ vòng/phút Trục Thu T (VD: `145.30`) |
| `MPM_T` | `D5020` | **`REAL` (32-bit Float)** | m/phút | Vận tốc dây cuộn Thu T (VD: `120.50`) |
| `RPM_X1` | `D5012` | **`REAL` (32-bit Float)** | RPM | Tốc độ vòng/phút Trục Xả X1 (VD: `132.10`) |
| `MPM_X1` | `D5022` | **`REAL` (32-bit Float)** | m/phút | Vận tốc dây cuộn Xả X1 (VD: `120.50`) |
| `RPM_Ms` | `D5016` | **`REAL` (32-bit Float)** | RPM | Tốc độ vòng/phút Trục Ghép Ms |
| `MPM_Ms` | `D5026` | **`REAL` (32-bit Float)** | m/phút | Vận tốc dây Trục Ghép Ms |
| `RPM_S` | `D5018` | **`REAL` (32-bit Float)** | RPM | Tốc độ vòng/phút Trục Dầu S (Analog Servo) |
| `MPM_S` | `D5028` | **`REAL` (32-bit Float)** | m/phút | Vận tốc dây Trục Dầu S |

---

> [!TIP]
> 💡 Trên màn hình HMI Weintek EasyBuilder Pro:
> - Định dạng đối tượng Numeric Display: chọn **32-bit Float**.
> - Chọn số chữ số thập phân hiển thị mong muốn (ví dụ `###.#` cho 1 số thập phân hoặc `###.##` cho 2 số thập phân).
