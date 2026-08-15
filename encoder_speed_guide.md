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

## ⏱️ 3. CẤU HÌNH CHU KỲ NGẮT 10MS CHO POU (FIXED SCAN)

Để công thức đo tốc độ RPM/MPM đạt độ chính xác cao nhất (100Hz):

1. Trong cây thư mục **`POU`** $\rightarrow$ Tạo POU mới tên **`POU_02_SPEED_CALC`** (Ngôn ngữ ST).
2. Nhấp chuột phải vào **`POU_02_SPEED_CALC`** $\rightarrow$ Chọn **`Property`**.
3. Tại mục **Execution Type**:
   - Chọn **`Fixed Scan Execution`**
   - Tại ô **Interval Time**: Nhập **`10ms`** (Ngắt ngầm chu kỳ 10ms của CPU Q02U).
4. Copy toàn bộ code từ file [`encoder_speed_calc.st`](file:///d:/data-2026/GHEP-MITSU/encoder_speed_calc.st) paste vào POU này.

---

## 📊 4. BẢNG BIẾN THỐNG KÊ KẾT QUẢ ĐO VÀ ĐÂU NỐI MÀN HÌNH HMI

| Tên Biến | Ý Nghĩa Tốc Độ | Đơn Vị Tải Về | Ví Dụ Giá Trị Hiển Thị |
| :--- | :--- | :--- | :--- |
| `RPM_X2` | Tốc độ vòng/phút Trục Master X2 | RPM x 10 | `1500` $\rightarrow$ Hiển thị HMI là **150.0 RPM** |
| **`MPM_X2`** | **Tốc độ dây chuyền máy ghép Metalize** | **MPM x 10** | **`1205` $\rightarrow$ Hiển thị HMI là 120.5 MPM** |
| `RPM_T` | Tốc độ vòng/phút Trục Thu T | RPM x 10 | `1450` $\rightarrow$ **145.0 RPM** |
| `MPM_T` | Vận tốc dây cuộn Thu T | MPM x 10 | `1205` $\rightarrow$ **120.5 MPM** |
| `RPM_X1` | Tốc độ vòng/phút Trục Xả X1 | RPM x 10 | `1320` $\rightarrow$ **132.0 RPM** |
| `MPM_X1` | Vận tốc dây cuộn Xả X1 | MPM x 10 | `1205` $\rightarrow$ **120.5 MPM** |
| `MPM_M` | Vận tốc dây Trục Metalize M | MPM x 10 | `1205` $\rightarrow$ **120.5 MPM** |
| `MPM_S` | Vận tốc dây Trục Dầu S | MPM x 10 | `1205` $\rightarrow$ **120.5 MPM** |

---

> [!TIP]
> 💡 Trên màn hình HMI Weintek, khi hiển thị các biến `MPM_X2`, `MPM_T`... bạn chỉ cần chỉnh thuộc tính **Decimal point (Số chữ số thập phân) = 1** thì số `1205` sẽ tự động hiển thị cực kỳ đẹp mắt là **120.5 m/phút**!
