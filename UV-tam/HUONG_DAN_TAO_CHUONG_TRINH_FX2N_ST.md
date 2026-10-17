# HƯỚNG DẪN CHI TIẾT TẠO VÀ NẠP DỰ ÁN FX_2N_UV_ST TRÊN GX WORKS2
## LẬP TRÌNH STRUCTURED TEXT (IEC 61131-3) THEO KIẾN TRÚC 3 TẦNG CHO MITSUBISHI FX2N

> [!NOTE]
> **ĐẶC ĐIỂM QUAN TRỌNG CỦA GX WORKS2 CHO DÒNG FXCPU (FX2N / FX3U):**
> * Dòng **FXCPU** trên GX Works2 **hoàn toàn KHÔNG dùng nhánh DUT** (nhánh DUT chỉ có trên Q/L-Series hoặc FX5U).
> * Toàn bộ biến đã được tối ưu thành các kiểu dữ liệu nguyên bản: `BOOL`, `INT`, `TIME`, `WORD`, `BYTE`.
> * Với mỗi POU (Function Block hoặc Program), bạn chỉ cần làm 2 bước:
>   1. Dán bảng biến từ file **`.tsv`** vào mục **`Local Label`**.
>   2. Dán mã lệnh ST từ file **`_ST.st`** vào mục **`Program [ST]`**.

---

## BẢNG DANH MỤC FILE NẠP NHANH CHO GX WORKS2

| Tên POU trong GX Works2 | Nhánh POU | File dán vào `Local Label` | File dán vào cửa sổ code `Program [ST]` |
| :--- | :--- | :--- | :--- |
| **`FB_UV_CuringUnit`** | `POU -> FB/FUN` | [Local_Labels_FB_UV_CuringUnit.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Labels/Local_Labels_FB_UV_CuringUnit.tsv) | [FB_UV_CuringUnit_ST.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/POUs_Core/FB_UV_CuringUnit_ST.st) |
| **`FB_UV_AlarmManager`** | `POU -> FB/FUN` | [Local_Labels_FB_UV_AlarmManager.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Labels/Local_Labels_FB_UV_AlarmManager.tsv) | [FB_UV_AlarmManager_ST.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/POUs_Core/FB_UV_AlarmManager_ST.st) |
| **`PRG_UV_Main`** (hoặc POU_01) | `POU -> Program` | [Local_Labels_PRG_UV_Main.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Labels/Local_Labels_PRG_UV_Main.tsv) | [PRG_UV_Main_ST.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/POUs_Program/PRG_UV_Main_ST.st) |

---

## QUY TRÌNH THỰC HIỆN 4 BƯỚC HOÀN THIỆN:

### BƯỚC 1: Function Block `FB_UV_CuringUnit`
1. Bạn đã dán thành công bảng [Local_Labels_FB_UV_CuringUnit.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Labels/Local_Labels_FB_UV_CuringUnit.tsv) vào `Local Label`.
2. Giờ nhấp đúp vào mục **`FB_UV_CuringUnit -> Program [ST]`** (cửa sổ soạn thảo code).
3. Mở file [FB_UV_CuringUnit_ST.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/POUs_Core/FB_UV_CuringUnit_ST.st), bấm `Ctrl + A` $\rightarrow$ `Ctrl + C` và dán vào.
4. Bấm `Ctrl + S`.

### BƯỚC 2: Function Block `FB_UV_AlarmManager`
1. Nhấp đúp vào mục **`FB_UV_AlarmManager -> Local Label`**.
2. Mở file [Local_Labels_FB_UV_AlarmManager.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Labels/Local_Labels_FB_UV_AlarmManager.tsv), bấm `Ctrl + A` $\rightarrow$ `Ctrl + C`.
3. Đặt chuột vào ô dòng 1 cột `Class` $\rightarrow$ Bấm `Ctrl + V`.
4. Nhấp đúp vào mục **`FB_UV_AlarmManager -> Program [ST]`**.
5. Mở file [FB_UV_AlarmManager_ST.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/POUs_Core/FB_UV_AlarmManager_ST.st), bấm `Ctrl + A` $\rightarrow$ `Ctrl + C` và dán vào.
6. Bấm `Ctrl + S`.

### BƯỚC 3: Chương trình chính `PRG_UV_Main` (hoặc `POU_01`)
1. Nhấp đúp vào mục **`PRG_UV_Main -> Local Label`** (hoặc `POU_01 -> Local Label`).
2. Mở file [Local_Labels_PRG_UV_Main.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/Labels/Local_Labels_PRG_UV_Main.tsv), bấm `Ctrl + A` $\rightarrow$ `Ctrl + C`.
3. Đặt chuột vào ô dòng 1 cột `Class` $\rightarrow$ Bấm `Ctrl + V`.
4. Nhấp đúp vào mục **`PRG_UV_Main -> Program [ST]`**.
5. Mở file [PRG_UV_Main_ST.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/POUs_Program/PRG_UV_Main_ST.st), bấm `Ctrl + A` $\rightarrow$ `Ctrl + C` và dán vào.
6. Bấm `Ctrl + S`.

### BƯỚC 4: Biên dịch dự án (Rebuild All)
1. Vào menu **Parameter** $\rightarrow$ **PLC Parameter** $\rightarrow$ Tab **Program Setting** $\rightarrow$ Đảm bảo `PRG_UV_Main` (hoặc `POU_01`) đã được đưa vào danh sách chạy **`Scan`**.
2. Nhấn phím **`F4` (Rebuild All)**.
3. Cửa sổ Output bên dưới sẽ báo: **`Compile complete -- 0 error(s), 0 warning(s)`**!
