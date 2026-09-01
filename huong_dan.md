# HƯỚNG DẪN TỔNG HỢP NẠP FILE VÀO PLC MITSUBISHI & HMI WEINTEK

**Dự án:** Hệ thống Dây chuyền Máy Ghép Màng Metalize  
**PLC Central CPU:** Mitsubishi **Q02UCPU** (Q-Series Universal CPU)  
**Phần mềm PLC:** **GX Works2** (Structured Project - ST / Ladder)  
**HMI Display:** **Weintek HMI** (Dòng MT8000/iE/cIP series)  
**Phần mềm HMI:** **EasyBuilder Pro**  
**Thư mục làm việc:** `d:\data-2026\lap_top\GHEP-MITSU_BACKUP\`

---

## 📌 1. BẢNG TỔNG HỢP DANH SÁCH FILE VÀ PHẦN MỀM SỬ DỤNG

| Đối tượng | Tên File / Thư mục | Định dạng | Phần mềm mở / Nạp | Mục đích & Chức năng chính |
| :--- | :--- | :--- | :--- | :--- |
| **PLC** | [`GHEP-Q02U.gxw`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP-Q02U.gxw) | `.gxw` | **GX Works2** | File dự án hoàn chỉnh của PLC (đã tích hợp logic, parameter & comment) |
| **PLC** | [`test.gxw`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/test.gxw) | `.gxw` | **GX Works2** | File dự án phụ dùng để kiểm tra/test từng module độc lập |
| **PLC** | [`master_all_program.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/master_all_program.st) | `.st` | Text Editor / GX Works2 | **File Master tổng hợp gộp tất cả code POU & FB PID, CC-Link sẵn sàng dán** |
| **PLC** | [`metalize_main_program.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/metalize_main_program.st) | `.st` | GX Works2 / Text Editor | Mã nguồn Structured Text chương trình chính (Master 6 trục & logic chạy/dừng) |
| **PLC** | [`metalize_cclink_fb.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/metalize_cclink_fb.st) | `.st` | GX Works2 | Function Block ST điều khiển mạng truyền thông CC-Link |
| **PLC** | [`metalize_pid_control.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/metalize_pid_control.st) | `.st` | GX Works2 | Thuật toán điều khiển PID lực căng và tốc độ dây chuyền |
| **PLC** | [`encoder_speed_calc.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/encoder_speed_calc.st) | `.st` | GX Works2 | Hàm tính toán tốc độ quay và đo mét từ Encoder qua QD62 |
| **PLC** | [`cclink_control.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/cclink_control.st), `fb_cclink_control.st` | `.st` | GX Works2 | Mã nguồn logic trao đổi dữ liệu thanh ghi trạm xa CC-Link |
| **PLC** | [`device_comments.csv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/device_comments.csv), `device_comments_full.csv` | `.csv` | GX Works2 (Comment Import) | Chú thích danh xưng thiết bị PLC (X, Y, M, D) nạp vào GX Works2 |
| **PLC** | [`fb_labels_paste.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/fb_labels_paste.tsv) | `.tsv` | GX Works2 (Global/Local Label) | Danh sách nhãn biến (Labels) paste vào bảng quản lý biến local/global |
| **PLC** | [`metalize_code_asc.asc`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/metalize_code_asc.asc), `cclink_code_asc.asc` | `.asc` | GX Works2 (Instruction Import) | Mã lệnh ASCII nạp/mở dạng lệnh sơ cấp Instruction List |
| **HMI** | [`EBProject1.emtp`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/EBProject1.emtp) | `.emtp` | **EasyBuilder Pro** | File dự án thiết kế giao diện HMI Weintek nguồn |
| **HMI** | [`EBProject1.exob`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/EBProject1.exob) | `.exob` | **EasyBuilder Pro / USB Download** | File thực thi HMI đã biên dịch, **dùng nạp thẳng xuống HMI Weintek** |
| **HMI** | [`hmi_weintek_metalize_tags.csv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/hmi_weintek_metalize_tags.csv), `hmi_weintek_tags.csv` | `.csv` | EasyBuilder Pro (Tag Address) | Bảng địa chỉ địa chỉ Tag mapping kết nối HMI với địa chỉ D, M, SB, SW của PLC |

---

## 🛠️ 2. QUY TRÌNH NẠP DỮ LIỆU VÀO PLC MITSUBISHI Q02UCPU (GX WORKS2)

### Cách A: Sử dụng trực tiếp file dự án đã đóng gói sẵn (Khuyên dùng - Nhanh nhất)
1. Khởi động phần mềm **GX Works2**.
2. Vào menu **`File`** $\rightarrow$ **`Open Project`** (hoặc nhấn `Ctrl + O`).
3. Trỏ đường dẫn đến thư mục `d:\data-2026\lap_top\GHEP-MITSU_BACKUP\` và chọn file **`GHEP-Q02U.gxw`**.
4. Dự án đã bao gồm đầy đủ cấu hình phần cứng CPU Q02U, tham số Network CC-Link QJ61BT11N, biến Labels và các chương trình con ST.

### Cách B: Import thủ công từng file nguồn (.st, .csv, .tsv) vào dự án mới
Nếu bạn muốn tự tạo dự án mới từ đầu trên GX Works2:
1. **Tạo dự án mới:** `Project` $\rightarrow$ `New...` $\rightarrow$ Series: `QCPU (Q mode)`, Model: `Q02U`, Project Type: `Structured Project`, Language: `ST`.
2. **Nạp chú thích thiết bị (Device Comments):**
   - Mở cây thư mục dự án bên trái: `Device Comment` $\rightarrow$ Click chuột phải chọn `Import from CSV File`.
   - Chọn file [`device_comments_full.csv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/device_comments_full.csv).
3. **Nạp biến Label:**
   - Mở `Global Labels` hoặc `Local Labels`.
   - Mở file [`fb_labels_paste.tsv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/fb_labels_paste.tsv) bằng Notepad/Excel, copy toàn bộ nội dung và dán (Paste) vào bảng Editor của GX Works2.
4. **Nạp chương trình ST & Tạo Function Block PID:**
   - **Tạo FB PID trong cây thư mục `FB/FUN`:** Click chuột phải vào mục **`FB/FUN`** (như trong ảnh GX Works2) $\rightarrow$ chọn **`Add New Data...`** $\rightarrow$ Đặt tên `FB_TENSION_PID`, Loại: `Function Block`, Ngôn ngữ: `ST`.
   - Copy toàn bộ nội dung file [`metalize_pid_control.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/metalize_pid_control.st) dán vào `FB_TENSION_PID`.
   - **Nạp chương trình chính:** Trong cây thư mục `POU` $\rightarrow$ `Program` $\rightarrow$ chọn chương trình chính (hoặc `POU_01`), dán mã nguồn từ [`metalize_main_program.st`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/metalize_main_program.st).


### Bước Biên Dịch & Nạp Xuống PLC (Write to PLC):
1. Nhấn phím **`F4`** (hoặc menu `Compile` $\rightarrow$ **`Rebuild All`**) để biên dịch toàn bộ dự án. Đảm bảo không có lỗi (`0 Error(s)`).
2. Kết nối cáp nạp (Cáp Mini-USB nối từ PC vào cổng USB trên CPU Q02U, hoặc qua Ethernet).
3. Vào menu **`Online`** $\rightarrow$ **`Read/Write Transfer Setup...`** $\rightarrow$ Thử test kết nối (`Connection Test` báo Success).
4. Vào menu **`Online`** $\rightarrow$ **`Write to PLC...`**.
5. Đánh dấu tick chọn:
   - ✅ **`Program`** (MAIN / POU)
   - ✅ **`Parameter`** (PLC Parameter, Network Parameter CC-Link)
   - ✅ **`Device Comment`** (Nếu muốn lưu comment trên PLC)
6. Nhấn nút **`Execute`**, đợi nạp hoàn tất 100%, gạt công tắc PLC sang **`RUN`**.

---

## 🖥️ 3. QUY TRÌNH NẠP DỮ LIỆU VÀO HMI WEINTEK (EASYBUILDER PRO)

### Cách A: Nạp trực tiếp file nạp compiled (.exob) qua USB Disk (Không cần phần mềm)
1. Thẻ nhớ USB cắm vào máy tính, format định dạng **FAT32**.
2. Copy file **`EBProject1.exob`** vào thư mục gốc của USB (hoặc tạo thư mục `disk` tùy dòng HMI Weintek).
3. Cắm USB vào cổng USB Host của màn hình HMI Weintek.
4. Trên màn hình HMI xuất hiện menu pop-up $\rightarrow$ Chọn **`Download`** $\rightarrow$ Nhập mật khẩu HMI (Mặc định: `111111` hoặc `888888`) $\rightarrow$ Chọn file `EBProject1.exob` để nạp.

### Cách B: Mở và chỉnh sửa file dự án nguồn (.emtp) bằng EasyBuilder Pro
1. Mở phần mềm **EasyBuilder Pro**.
2. Vào **`File`** $\rightarrow$ **`Open`** $\rightarrow$ Chọn file **`EBProject1.emtp`**.
3. **Kiểm tra/Import Tag Address:**
   - Đã cập nhật lại file [`hmi_weintek_metalize_tags.csv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/hmi_weintek_metalize_tags.csv) theo đúng cấu trúc tiêu chuẩn của EasyBuilder Pro: `"Name","Device Name","Address Type","Address","Data Type","Description"`.
   - Cách import trong EasyBuilder Pro: Vào menu **`Project`** $\rightarrow$ **`Address`** (hoặc `Tag Manager`) $\rightarrow$ Click nút **`Import Tags...`** (hoặc `Import CSV`) $\rightarrow$ Đảm bảo tên Device chọn đúng là **`PLC`** $\rightarrow$ Trỏ tới file [`hmi_weintek_metalize_tags.csv`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/hmi_weintek_metalize_tags.csv).
4. **Cấu hình kết nối truyền thông với PLC Q02U:**
   - Vào menu **`System Parameters`** $\rightarrow$ Chọn thiết bị **`PLC`**:
     - *Nếu kết nối qua RS-232/RS-422 (Cổng COM CPU Q02U):* Chọn Device Type = `Mitsubishi Q02/Q02H/Q06H (CPU Port)`, Cổng `RS-232/422`, `9600 bps`, `8 data bits`, `Odd parity`, `1 stop bit`.
     - *Nếu kết nối qua Ethernet MC Protocol (Module QJ71E71-100):* Chọn Device Type = `Mitsubishi QJ71E71 / Built-in ETH (MC Protocol)`, IP = `192.168.1.250`, Port = `5007`.
5. **Biên dịch & Download xuống HMI qua dây mạng/cáp USB:**
   - Vào menu **`Project`** $\rightarrow$ **`Compile`** (Tạo ra file `.exob`).
   - Vào menu **`Project`** $\rightarrow$ **`Download (PC to HMI)`**.
   - Nhập địa chỉ IP của HMI (hoặc chọn cổng USB) $\rightarrow$ Nhấn **`Download`**.

---

## 🔗 4. CÁCH TÍNH & PHÂN BỔ ĐỊA CHỈ CC-LINK DỄ HIỂU NHẤT

### A. Quy Tắc Nhớ Nhanh (Dành Cho 1 Trạm = 1 Station)
Khi cấu hình CC-Link ở chế độ Ver.1 Mode:
- **1 Trạm (1 Station):** Cấp 32 Bits RX, 32 Bits RY, 4 Words RWr, 4 Words RWw.
- **2 Trạm (2 Stations):** Cấp 64 Bits RX, 64 Bits RY, 8 Words RWr, 8 Words RWw.
*(Cả module ADC 8 kênh `AJ65VBT-68ADV` và DAC 8 kênh `AJ65VBTCU-68DAVN` đều chiếm **2 Stations** để đủ 8 thanh ghi dữ liệu).*

---

### B. Bảng Phân Bổ Địa Chỉ Chi Tiết Dự Án GHEP-MITSU (3 Module - 5 Trạm)

Dự án cài đặt địa chỉ gốc trong GX Works2:
- Bit ngõ vào gốc **`RX`**: Bắt đầu từ **`M1008`**
- Bit ngõ ra gốc **`RY`**: Bắt đầu từ **`M1200`**
- Thanh ghi đọc gốc **`RWr`**: Bắt đầu từ **`D500`**
- Thanh ghi ghi gốc **`RWw`**: Bắt đầu từ **`D520`**

| Trạm Phần Cứng | Thiết Bị Thực Tế | Số Trạm Chiếm | Dải Bit Đọc `RX` (Vùng `M` PLC) | Dải Bit Ghi `RY` (Vùng `M` PLC) | Dải Thanh Ghi Đọc `RWr` | Dải Thanh Ghi Ghi `RWw` |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Trạm 1 & 2** | Module ADC 8CH (`AJ65VBT-68ADV`) | **2 Stations** (64 bits / 8 Words) | `M1008` ~ `M1071` *(RX0 ~ RX3F)* | `M1200` ~ `M1263` *(RY0 ~ RY3F)* | **`D500` ~ `D507`** *(RWr0~RWr7)* | `D520` ~ `D527` *(RWw0~RWw7)* |
| **Trạm 3 & 4** | Module DAC 8CH (`AJ65VBTCU-68DAVN`) | **2 Stations** (64 bits / 8 Words) | `M1072` ~ `M1135` *(RX40 ~ RX7F)* | `M1264` ~ `M1327` *(RY40 ~ RY7F)* | `D508` ~ `D515` *(RWr8~RWrF)* | **`D528` ~ `D535`** *(RWw8~RWwF)* |
| **Trạm 5** | Digital Remote (`AJ65SBTB1-16DT`) | **1 Station** (32 bits / 4 Words) | `M1136` ~ `M1167` *(RX80 ~ RX9F)* | `M1328` ~ `M1359` *(RY80 ~ RY9F)* | `D516` ~ `D519` *(RWr10~RWr13)*| `D536` ~ `D539` *(RWw10~RWw13)*|

---

### C. Giải Thích Cụ Thể Từng Trạm:

#### 🔹 1. Trạm 1 & 2 (`AJ65VBT-68ADV` - Chiếm 2 Trạm, Công tắc gạt = `1`):
* **Đọc 8 kênh ADC (RWr0 ~ RWr7):** Nằm tại **`D500` đến `D507`** (`D500` = CH1 Loadcell Thu T, `D501` = CH2 Loadcell Kéo X1, `D502` = CH3 Loadcell Thắng M, `D503` = CH4 Loadcell Xả U, `D504..D507` = CH5..CH8 mở rộng).
* **Cờ báo trạng thái & Lệnh cho phép (RX/RY):**
  - **`M1200` đến `M1207` (`RY0` đến `RY7`):** **BẮT BUỘC BẬT ON = 1** để cho phép chuyển đổi A/D từng kênh CH1 ~ CH8 (Nếu các bit này OFF thì `D500..D507` luôn bằng 0!).
  - `M1208` (`RY8`): Cho phép chuyển đổi tổng.
  - `M1016` (`RX8`/`RX19`): Cờ báo ADC đổi xong.
  - `M1034` (`RX1A`): Cờ báo lỗi ADC.
  - `M1226` (`RY1A`): Bit reset lỗi ADC.

#### 🔹 2. Trạm 3 & 4 (`AJ65VBTCU-68DAVN` - Chiếm 2 Trạm, Công tắc gạt = `3`):
* **Ghi 8 kênh DAC xuất áp (RWw8 ~ RWwF):** Nằm tại **`D528` đến `D535`** (`D528` = CH1 Speed T, `D529` = CH2 Torque T, `D530` = CH3 Speed X1, `D531` = CH4 Speed X2, `D532` = CH5 Speed Ms, `D533` = CH6 Torque M, `D534` = CH7 Speed S, `D535` = CH8 Speed U).
* **Cờ báo trạng thái (RX/RY):** Lấy tiếp 64 bits từ **`M1072` đến `M1135`** (`M1096` cờ DAC Ready, `M1098` cờ lỗi DAC, `M1272` bit cho phép D/A, `M1290` bit reset lỗi DAC).

#### 🔹 3. Trạm 5 (`AJ65SBTB1-16DT` - Chiếm 1 Trạm, Công tắc gạt = `5`):
* **8 Ngõ vào Digital (X0 ~ X7):** Nằm tại **`M1136` đến `M1143`** (`M1136..M1140` = Ready 5 Servo T, X1, X2, Ms, S; `M1141` = Nút Jog bò chậm).
* **8 Ngõ ra Digital (Y8 ~ YF):** Nằm tại **`M1336` đến `M1343`** (`M1336..M1340` = Servo ON 5 Trục T, X1, X2, Ms, S; `M1341..M1342` = Van Solenoid Pen 1, Pen 2; `M1343` = Còi/Đèn báo lỗi).

---

## 📚 5. DANH SÁCH TÀI LIỆU THAM CHIẾU & HƯỚNG DẪN KỸ THUẬT TIÊN TIẾN

| Tên Tài Liệu Nội Bộ | Đường Dẫn Mở Trực Tiếp | Nội Dung Kỹ Thuật Chi Tiết |
| :--- | :--- | :--- |
| **Bảng Mapping Thanh Ghi CC-Link & HMI** | [`notes_cclink_mapping.md`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/notes_cclink_mapping.md) | Ánh xạ chi tiết biến D600~D617, D500~D507, D528~D535, M1136, M1336 giữa PLC, CC-Link và HMI |
| **Kịch Bản Vận Hành 6 Trục & Lực Căng** | [`metalize_system_master_guide.md`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/metalize_system_master_guide.md) | Tỷ số truyền 6 trục (T, X1, X2, Ms, S, U), thắng từ M, đo đường kính X50/X51, chu trình Start/Stop |
| **Hướng Dẫn Đấu Nối & Cấu HÌnh HMI** | [`wiring_and_hmi_guide.md`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/wiring_and_hmi_guide.md) | Sơ đồ dây CC-Link, điện trở 110$\Omega$, sơ đồ chân ADC 68ADV, DAC 68DAVN & kết nối HMI |
| **Hướng Dẫn CC-Link QJ61BT11N & Q02U** | [`cclink_q02u_guide.md`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/cclink_q02u_guide.md) | Cấu hình 2 Stations cho 68ADV & 68DAVN, bảng Station Information 5 trạm, vùng nhớ RX/RY/RWr/RWw |
| **Hướng Dẫn Encoder QD62** | [`encoder_speed_guide.md`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/encoder_speed_guide.md) | Cấu hình module đếm xung tốc độ cao QD62 đọc Encoder đo tốc độ dây chuyền |
| **Hướng Dẫn Modbus QJ71C24N / STM32** | [`stm32_qj71c24_guide.md`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_qj71c24_guide.md) | Truyền thông RS-485 Modbus RTU giữa PLC Q02U và bo mạch vi điều khiển STM32 |
| **Sơ Đồ Đấu Nối Cáp CC-Link (PDF)** | [`CCLINK.pdf`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/CCLINK.pdf) | Bản vẽ sơ đồ đấu nối cáp và phân bổ trạm CC-Link gốc |
| **Thông Số Phần Cứng CC-Link (PDF)** | [`PARA-CCLINK.pdf`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/PARA-CCLINK.pdf) | Tài liệu tra cứu thông số Parameter phần cứng CC-Link |


