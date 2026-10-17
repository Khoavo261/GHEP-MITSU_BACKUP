# HƯỚNG DẪN TẠO STRUCTURED DATA TYPES TRÊN GX WORKS2
### (Kiến trúc chuẩn IEC 61131-3 - Dễ dàng chuyển đổi giữa Mitsubishi, ABB, Schneider, Siemens, Beckhoff)

---

## 1. NGUYÊN LÝ THIẾT KẾ ĐA NỀN TẢNG (PORTABLE PLC ARCHITECTURE)
Bằng cách gom nhóm toàn bộ dữ liệu vào **5 Structs**:
1. `ST_UV_Commands`: Lệnh nút nhấn & HMI.
2. `ST_UV_Sensors`: Cảm biến & tiếp điểm an toàn phần cứng.
3. `ST_UV_Status`: Trạng thái máy & thời gian đếm lùi.
4. `ST_UV_Alarms`: 9 sự cố & mã quét cảnh báo.
5. `ST_UV_Outputs`: Đầu ra điều khiển đèn, quạt, van gió, chiller, còi.

👉 Khi chuyển sang **ABB (Automation Builder)**, **Siemens (TIA Portal)**, **Schneider (EcoStruxure)** hay **Beckhoff (TwinCAT)**:
Bạn chỉ cần nạp file [`DUT_Export_IEC.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Structured_Data_Types/DUT_Export_IEC.st) là toàn bộ logic trong `FB_UV_CuringUnit` và `FB_UV_AlarmManager` giữ nguyên 100%, không cần viết lại dù chỉ 1 dòng code!

---

## 2. CÁC BƯỚC THỰC HIỆN TRÊN GX WORKS2

### BƯỚC 1: Tạo 5 Struct trong nhánh `Structured Data Types`
Trên cây thư mục dự án bên trái, tìm nhánh **`POU` $\rightarrow$ `Structured Data Types`**:
1. **Click chuột phải vào `Structured Data Types` $\rightarrow$ Chọn `New Data...`**.
2. Nhập lần lượt 5 tên Struct sau:
   - `ST_UV_Commands`
   - `ST_UV_Sensors`
   - `ST_UV_Status`
   - `ST_UV_Alarms`
   - `ST_UV_Outputs`
3. Với mỗi Struct vừa tạo, mở bảng lưới ra và dán nội dung từ các file TSV tương ứng:
   - Bảng của `ST_UV_Commands` $\leftarrow$ Copy từ [`ST_UV_Commands.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Structured_Data_Types/ST_UV_Commands.tsv)
   - Bảng của `ST_UV_Sensors` $\leftarrow$ Copy từ [`ST_UV_Sensors.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Structured_Data_Types/ST_UV_Sensors.tsv)
   - Bảng của `ST_UV_Status` $\leftarrow$ Copy từ [`ST_UV_Status.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Structured_Data_Types/ST_UV_Status.tsv)
   - Bảng của `ST_UV_Alarms` $\leftarrow$ Copy từ [`ST_UV_Alarms.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Structured_Data_Types/ST_UV_Alarms.tsv)
   - Bảng của `ST_UV_Outputs` $\leftarrow$ Copy từ [`ST_UV_Outputs.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Structured_Data_Types/ST_UV_Outputs.tsv)

---

### BƯỚC 2: Cập nhật Local Label của 2 Function Block
Mở lần lượt `Local Label` của từng FB và dán:
1. **`FB_UV_AlarmManager` $\rightarrow$ `Local Label`**:
   - Mở file [`Local_Labels_FB_UV_AlarmManager.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Labels/Local_Labels_FB_UV_AlarmManager.tsv), nhấn `Ctrl+A` $\rightarrow$ `Ctrl+C`.
   - Chọn ô đầu tiên hàng 1 trong bảng Local Label GX Works2 $\rightarrow$ Nhấn `Ctrl+V`.
2. **`FB_UV_CuringUnit` $\rightarrow$ `Local Label`**:
   - Mở file [`Local_Labels_FB_UV_CuringUnit.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Labels/Local_Labels_FB_UV_CuringUnit.tsv), nhấn `Ctrl+A` $\rightarrow$ `Ctrl+C`.
   - Chọn ô đầu tiên hàng 1 $\rightarrow$ Nhấn `Ctrl+V`.

---

### BƯỚC 3: Cập nhật mã nguồn logic Program [ST] của 2 Function Block
Mở lần lượt cửa sổ soạn thảo `Program [ST]` của từng FB và dán:
1. **`FB_UV_AlarmManager` $\rightarrow$ `Program`**:
   - Mở file [`FB_UV_AlarmManager_ST.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/POUs_Core/FB_UV_AlarmManager_ST.st), copy toàn bộ và dán vào.
2. **`FB_UV_CuringUnit` $\rightarrow$ `Program`**:
   - Mở file [`FB_UV_CuringUnit_ST.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/POUs_Core/FB_UV_CuringUnit_ST.st), copy toàn bộ và dán vào.

---

### BƯỚC 4: Cập nhật Program Main (`PRG_UV_Main`)
1. **`PRG_UV_Main` $\rightarrow$ `Local Label`**:
   - Mở file [`Local_Labels_PRG_UV_Main.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Labels/Local_Labels_PRG_UV_Main.tsv) (đã gồm 2 FB instance và 5 biến Struct), copy và dán vào bảng Local Label.
2. **`PRG_UV_Main` $\rightarrow$ `Program`**:
   - Mở file [`PRG_UV_Main_ST.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/POUs_Program/PRG_UV_Main_ST.st), copy toàn bộ và dán vào.
   - Code đã ánh xạ 100% chính xác với các biến Global Label (`X000..X031`, `Y000..Y030`, `D100..D105`) bạn đã nạp.

---

### BƯỚC 5: Biên dịch kiểm tra (Rebuild All)
- Nhấn phím **F4** (hoặc chọn menu **Compile $\rightarrow$ Rebuild All**).
- Xác nhận kết quả: **0 Error(s), 0 Warning(s)**!
