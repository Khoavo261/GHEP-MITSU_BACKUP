# 📘 HƯỚNG DẪN CẤU HÌNH DỰ ÁN KẾT HỢP LADDER & ST TRONG GX WORKS2
## THƯ MỤC DỰ ÁN: `ST_LATCH_GHEP`
### DÀNH CHO: MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - PLC MITSUBISHI Q02U

---

## 📌 PHẦN 1: TỔNG QUAN KIẾN TRÚC HỆ THỐNG
Dự án được quy hoạch theo mô hình chuẩn chuyên nghiệp, kết hợp tối ưu giữa **Ladder (Mạch điều khiển vật lý)** và **ST (Mạch tính toán cao cấp)**:

```text
               ┌────────────────────────────────────────────────────────┐
               │             PLC MITSUBISHI Q02UCPU                     │
               └────────────────────────────────────────────────────────┘
                                           │
          ┌────────────────────────────────┼───────────────────────────────┐
          │                                │                               │
          ▼                                ▼                               ▼
┌──────────────────┐             ┌──────────────────┐            ┌──────────────────┐
│   01_POU_INIT    │             │  02_MAIN_LOGIC   │            │   03_MAIN_CALC   │
│   (Ngôn ngữ: ST) │             │ (Ngôn ngữ: LADDER│            │  (Ngôn ngữ: ST)  │
├──────────────────┤             ├──────────────────┤            ├──────────────────┤
│• Chạy 1 lần đầu  │             │• Nút Run, Stop   │            │• Đọc xung QD62D  │
│• Cài Buffer G9=1 │             │• E-Stop, Reset   │            │• Chốt Pha Z 5 trục│
│• Khởi tạo PID    │             │• An toàn 5 Servo │            │• 2 Sensor đo D cuộn│
│• Bật CC-Link AD/DA│            │• Van Pen ép màng │            │• PID lực căng    │
│                  │             │• Bơm dầu, Còi đèn│            │• Xuất áp CC-Link │
└──────────────────┘             └──────────────────┘            └──────────────────┘
```

---

## 📌 PHẦN 2: CHI TIẾT CÁC FILE TRONG THƯ MỤC `ST_LATCH_GHEP`

1. **[01_POU_INIT.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/01_POU_INIT.st)**:
   - Chạy kiểu **Initial Execution** (1 lần lúc khởi động CPU).
   - Thiết lập chọn chức năng Latch Counter `G9 := 1` (Slot 1, 2, 3), cờ `Count Enable` `Y14, Y24, Y2C, Y34, Y3C := TRUE`.
   - **Đặc biệt:** Để `Y16, Y26, Y2E, Y36, Y3E := FALSE` để nhường toàn quyền chốt xung cho chân giắc ngoài `FUNC`.

2. **[02_MAIN_LOGIC_LADDER.md](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/02_MAIN_LOGIC_LADDER.md)**:
   - Tài liệu sơ đồ mạch tiếp điểm **Ladder trực quan** và toàn bộ danh sách lệnh gõ phím Instruction List (`LD`, `AND`, `OR`, `OUT`, `MOV`).
   - Rất dễ soi tiếp điểm online khi máy không chạy hoặc sự cố.

3. **[03_MAIN_CALC_ST.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/03_MAIN_CALC_ST.st)**:
   - Chương trình **Structured Text (ST)** thực hiện chốt xung Pha Z liên tục mỗi vòng qua `G12 / G44`.
   - Bắt sườn lên 2 Sensor tiệm cận `X4A` (M) và `X4B` (U) chốt số xung Master X2 để tính đường kính thực tế `Real_Dia_M` và `Real_Dia_U`.
   - Lọc trung bình Analog CC-Link ADC Loadcell và thuật toán Tension PID.

4. **[04_GLOBAL_LABELS_ST_LATCH_GHEP.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/04_GLOBAL_LABELS_ST_LATCH_GHEP.tsv)**:
   - Bảng biến toàn cục chuẩn định dạng Tab-Separated. Copy/paste 1 click vào bảng **Global_Variables** của GX Works2.

5. **[05_DEVICE_COMMENTS_ST_LATCH_GHEP.csv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/05_DEVICE_COMMENTS_ST_LATCH_GHEP.csv)**:
   - File chú thích thiết bị tiếng Việt (D, M, X, Y) để nạp vào GX Works2 Device Comment.

---

## 📌 PHẦN 3: CÁC BƯỚC TẠO VÀ CẤU HÌNH TRONG GX WORKS2

### 🔹 BƯỚC 1: TẠO 3 CHƯƠNG TRÌNH TRONG DỰ ÁN
1. Mở GX Works2.
2. Ở cửa sổ **Project Tree** bên trái, chuột phải vào **Program** $\rightarrow$ chọn **New Data...**:
   - **Program 1:**
     * Data Name: `POU_INIT`
     * Program Language: **Structured Text (ST)**
   - **Program 2:**
     * Data Name: `MAIN_LOGIC`
     * Program Language: **Ladder**
   - **Program 3:**
     * Data Name: `MAIN_CALC`
     * Program Language: **Structured Text (ST)**

### 🔹 BƯỚC 2: DÁN NỘI DUNG VÀO TỪNG CHƯƠNG TRÌNH
1. Mở `POU_INIT`: Copy toàn bộ nội dung từ file [01_POU_INIT.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/01_POU_INIT.st) dán vào.
2. Mở `MAIN_LOGIC`:
   - Dùng các phím tắt GX Works2 (`F5: Thường hở`, `F6: Thường đóng`, `F7: Cuộn coil`, `F8: Khối lệnh MOV`) vẽ theo sơ đồ trong [02_MAIN_LOGIC_LADDER.md](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/02_MAIN_LOGIC_LADDER.md).
   - Hoặc gõ phím nhanh theo danh sách Instruction List ở Phần 4.
3. Mở `MAIN_CALC`: Copy toàn bộ nội dung từ file [03_MAIN_CALC_ST.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/03_MAIN_CALC_ST.st) dán vào.

### 🔹 BƯỚC 3: CẤU HÌNH THỨ TỰ QUÉT TRONG PLC PARAMETER (CỰC KỲ QUAN TRỌNG)
1. Trong Project Tree, click đúp vào **Parameter** $\rightarrow$ **PLC Parameter**.
2. Chọn tab **Program Setting**:
   - Nhấn vào chương trình `POU_INIT` $\rightarrow$ bấm **Insert** đưa sang khung bên phải. Ở cột **Execution Type**, chọn: **Initial** (hoặc để Scan nếu dùng cờ `SM402`).
   - Nhấn vào chương trình `MAIN_LOGIC` $\rightarrow$ bấm **Insert**. Ở cột **Execution Type**, chọn: **Scan**.
   - Nhấn vào chương trình `MAIN_CALC` $\rightarrow$ bấm **Insert**. Ở cột **Execution Type**, chọn: **Scan**.
3. Thứ tự chạy chuẩn:
   ```text
   No.1: POU_INIT   (Initial)
   No.2: MAIN_LOGIC (Scan)
   No.3: MAIN_CALC  (Scan)
   ```
4. Nhấn nút **End** để lưu cấu hình.

### 🔹 BƯỚC 4: DÁN BẢNG GLOBAL LABELS
1. Trong Project Tree, mở **Global Label** $\rightarrow$ **Global_Variables**.
2. Mở file [04_GLOBAL_LABELS_ST_LATCH_GHEP.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/04_GLOBAL_LABELS_ST_LATCH_GHEP.tsv) bằng Notepad hoặc Excel, nhấn `Ctrl + A` $\rightarrow$ `Ctrl + C`.
3. Trong GX Works2, click vào dòng trống đầu tiên, nhấn `Ctrl + V` để dán.

### 🔹 BƯỚC 5: BIÊN DỊCH VÀ NẠP XUỐNG PLC
1. Nhấn phím **F4 (Rebuild All)** để kiểm tra lỗi cú pháp.
2. Đảm bảo màn hình báo **0 Error, 0 Warning**.
3. Vào **Online** $\rightarrow$ **Write to PLC...**:
   - Tích chọn cả **Program** (cả 3 chương trình) và **Parameter**.
   - Nhấn **Execute**.
4. Gạt khóa CPU Q sang **STOP $\rightarrow$ RESET $\rightarrow$ RUN**.
5. Mở tab **Watch** hoặc mở trực tiếp trang Ladder để giám sát online tiếp điểm và số xung encoder!
