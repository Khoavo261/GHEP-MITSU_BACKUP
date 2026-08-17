# 🌟 HƯỚNG DẪN CẤU HÌNH CHẠY SONG SONG LADDER + ST (HYBRID ARCHITECTURE)

Hệ thống điều khiển máy ghép màng Metalize được phân công nhiệm vụ song song thành 2 khối chương trình chuyên biệt:

---

## 🏗️ 1. PHÂN CÔNG NHIỆM VỤ GIỮA LADDER VÀ ST

| Khối Chương Trình | Ngôn Ngữ | Tên File Nguồn | Nhiệm Vụ Chuyên Trách |
| :--- | :---: | :--- | :--- |
| **Khối 1: `POU_LADDER_IO`** | **Ladder (LAD)** | [`pou_ladder_io.asc`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/pou_ladder_io.asc) | • Mạch tự giữ Start/Stop (`M100`), bảo vệ Servo Ready (`M134`)<br>• Khởi tạo CC-Link A/D (`M1208`), D/A (`M1240`)<br>• Xuất 5 trục Servo ON (`M1304..M1308`) ra module 16DT<br>• Điều khiển 2 Van Pen ép màng (`M1309`, `M1310`) ra 16DT<br>• Bắt sườn xung cảm biến tiệm cận `X50` (`M160`), `X51` (`M161`)<br>• Đèn báo lỗi CC-Link (`M1311`) & Nút Reset (`M1226`, `M1258`) |
| **Khối 2: `POU_ST_MATH`** | **Structured Text (ST)** | [`pou_st_math.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/pou_st_math.st) | • Tăng giảm tốc lũy tiến theo đường dốc gia tốc<br>• Đo & lọc đường kính cuộn Thu T, cuộn Xả M, cuộn Xả U<br>• Tính côn lực Taper Tension cuộn Thu T<br>• Chạy 4 khối PID lực căng theo nhịp 10ms (`SM409`)<br>• Đồng bộ tỷ số truyền, tính tốc độ Master X2, Lô Ghép Ms, Lô Dầu S<br>• Xuất 8 kênh áp DAC (`D524..D531`) qua `fbCCLink` |

---

## 🛠️ 2. HƯỚNG DẪN CÀI ĐẶT TRONG GX WORKS2 (CHỈ 3 BƯỚC)

### 🔹 Bước 1: Tạo POU Ladder (`POU_LADDER_IO`)
1. Trong cây thư mục bên trái, nhấp chuột phải vào **`Program`** $\rightarrow$ chọn **`New Data...`**.
2. Đặt tên: **`POU_LADDER_IO`**, chọn **Program Type: `Ladder`** $\rightarrow$ bấm **OK**.
3. Mở file [pou_ladder_io.asc](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/pou_ladder_io.asc), copy toàn bộ nội dung và dán vào cửa sổ soạn thảo Instruction List của POU vừa tạo $\rightarrow$ bấm **F4 (Convert)** để phần mềm vẽ ra sơ đồ tiếp điểm Ladder.

---

### 🔹 Bước 2: Dán mã nguồn ST vào `POU_01` (`POU_ST_MATH`)
1. Mở cửa sổ **`POU_01`** (chương trình ST hiện tại).
2. Xóa nội dung cũ, mở file [pou_st_math.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/pou_st_math.st), copy toàn bộ và dán vào.

---

### 🔹 Bước 3: Cấu hình chạy song song trong `PLC Parameter`
1. Mở **`Parameter`** $\rightarrow$ **`PLC Parameter`** $\rightarrow$ chọn tab **`Program`**.
2. Cài đặt 2 dòng như sau:
   * **Dòng 1:** Program Name = **`POU_LADDER_IO`** | Execute Type = **`Scan`**
   * **Dòng 2:** Program Name = **`MAIN`** (hoặc `POU_01`) | Execute Type = **`Scan`**
3. Bấm nút **Check** $\rightarrow$ **End**.
4. Nhấn **Rebuild All (Shift + Alt + F4)** $\rightarrow$ **0 Error, 0 Warning**!

---

### 🌟 LỢI THẾ CỦA MÔ HÌNH NÀY:
* Mạch ON/OFF tiếp điểm, rơ-le, nút nhấn được vẽ bằng **Ladder** trực quan, dễ nhìn khi đứng máy.
* Các công thức toán, PID, căn chỉnh lực căng, đường kính được viết bằng **ST** gọn gàng, tính toán siêu nhanh và không tốn hàng trăm dòng tiếp điểm rườm rà.
* Hai chương trình phối hợp hoàn hảo qua biến trung gian (`M100`, `M160`, `M161`), **hoàn toàn không có xung đột hay trùng cuộn hút**!
