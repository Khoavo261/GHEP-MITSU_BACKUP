# HƯỚNG DẪN TEST TỪNG TRỤC & THIẾT KẾ GIAO DIỆN HMI CHUYÊN NGHIỆP
## DỰ ÁN: MÁY GHÉP MÀNG METALIZE - PLC Q02UCPU (MẠNG CC-LINK REMOTE ADC/DAC)

---

## PHẦN 1: TỔNG QUAN THƯ MỤC DỰ ÁN ĐÃ GOM GỌN
Thư mục phát hành chính thức: **`d:\data-2026\lap_top\GHEP-MITSU_BACKUP\GHEP_Q02U_NEW_RELEASE\`**

| Tên Tệp | Định dạng | Vai trò & Chức năng |
| :--- | :--- | :--- |
| **`GHEP-Q02U-NEW.gxw`** | GX Works2 | Dự án PLC tổng thể hoàn chỉnh |
| **`pou01_only_program.st`** | Structured Text | Chương trình điều khiển chính (Đã tích hợp CC-Link ADC/DAC, bỏ Slot 0 & 1) |
| **`init_program.st`** | Structured Text | Khởi tạo tham số phần cứng khi khởi động PLC (Initial Scan) |
| **`fb_code_body.st`** | Structured Text | Thân khối Function Block phụ trợ |
| **`fb_tension_pid_body.st`**| Structured Text | Thân khối Function Block điều khiển PID Lực căng tự động |
| **`global_labels_paste.tsv`**| TSV Table | Bảng nhãn toàn cục (Global Labels) để Import vào GX Works2 |
| **`pou01_local_labels_paste.tsv`**| TSV Table | Bảng nhãn cục bộ (Local Labels) của chương trình POU_01 |
| **`device_comments_full.csv`**| CSV Comment | Danh bạ chú thích địa chỉ Bit/Word đầy đủ tiếng Việt cho GX Works2 |
| **`EBProject1.emtp`** / **`.exob`**| EasyBuilder Pro | Dự án thiết kế giao diện màn hình HMI Weintek MT6103iP / cMT |
| **`weintek_easybuilder_tags_import.csv`**| CSV Tags | Bảng địa chỉ Tag để Import vào EasyBuilder Pro |

---

## PHẦN 2: HƯỚNG DẪN CHI TIẾT TEST TỪNG TRỤC (MANUAL TEST MODE)

Chương trình PLC đã tích hợp sẵn chế độ **Manual Test Mode** độc lập. Khi máy đang ở trạng thái dừng (**`State_Machine = 0`**), người vận hành có thể kích hoạt chạy riêng từng trục mà không làm ảnh hưởng đến các trục khác.

### 1. Bảng địa chỉ điều khiển & Giám sát 7 Trục:

| STT | Tên Trục | Bit Bật Chạy (`BOOL`) | Ô Nhập Tốc Độ / Lực (`REAL`) | Cọc Ra Servo ON (`Y`) | Cổng Xuất Áp DAC CC-Link (`W`) | Phản Hồi Đo Về (Encoder / ADC) |
| :---: | :--- | :---: | :---: | :---: | :---: | :--- |
| **1** | **Trục Thu T** (Winder) | **`M30`** | **`D620`** (Speed: 0..16000)<br>**`D622`** (Torque: 0..16000) | `Y50` | `W200` (CH1 Speed)<br>`W201` (CH2 Torque) | • Encoder Slot 2 CH1 (`Curr_Pulse_T`)<br>• Loadcell Thu T (`W110`) |
| **2** | **Trục Kéo X1** (Feed Nip 1) | **`M31`** | **`D624`** (Speed: 0..16000) | `Y51` | `W202` (CH3 Speed) | • Encoder Slot 2 CH2 (`Curr_Pulse_X1`)<br>• Loadcell Kéo X1 (`W111`) |
| **3** | **Trục Master X2** (Main Roller) | **`M32`** | **`D626`** (Speed: 0..16000) | `Y52` | `W203` (CH4 Speed) | • Encoder Slot 3 CH1 (`Curr_Pulse_X2`) |
| **4** | **Trục Ghép Ms** (Laminating Nip) | **`M33`** | **`D628`** (Speed: 0..16000) | `Y53` | `W204` (CH5 Speed) | • Encoder Slot 3 CH2 (`Curr_Pulse_Ms`) |
| **5** | **Trục Tráng Dầu S** (Coating S) | **`M34`** | **`D630`** (Speed: 0..16000) | `Y54` | `W206` (CH7 Speed) | • Tốc độ Analog Feedback S (`W114`) |
| **6** | **Thắng Từ M** (Brake Metalize) | **`M35`** | **`D632`** (Lực: 0..16000) | — | `W205` (CH6 Torque) | • Loadcell Thắng M (`W112`) |
| **7** | **Trục Xả U** (Unwinder U) | **`M36`** | **`D634`** (Speed: 0..16000) | — | `W207` (CH8 Speed) | • Loadcell Xả U (`W113`) |

---

### 2. Các bước thực hiện Test trên GX Works2 hoặc HMI:

#### 🔹 Bước 1: Chuẩn bị an toàn
1. Đảm bảo nút dừng khẩn cấp E-Stop không bị nhấn.
2. Kiểm tra đèn báo Ready của các Drive Servo: `X40` (Servo T), `X41` (Servo X1), `X42` (Servo X2), `X43` (Servo Ms), `X44` (Servo S).

#### 🔹 Bước 2: Nạp giá trị tốc độ thử nghiệm vừa phải
1. Mở cửa sổ **Modify Value** trong GX Works2 (hoặc nhập từ màn hình HMI):
   * Thang chuẩn: `0 ~ 16000` tương ứng `0.0V ~ 10.0V`.
   * Khuyến cáo nạp thử mức tốc độ chậm ban đầu: **`1600`** (tương đương **10% tốc độ**, điện áp ra **1.0V**).
   * Ví dụ muốn test Trục Thu T: Nạp **`D620 = 1600.0`** (hoặc kiểu REAL), **`D622 = 8000.0`** (Torque 50%).

#### 🔹 Bước 3: Kích hoạt chạy thử
1. Bật ON bit tương ứng (ví dụ: kích **`M30 := 1`** để chạy thử Trục Thu T).
2. Quan sát thực tế:
   * Cuộn hút Relay `Y50` đóng $\rightarrow$ Servo Driver báo `RUN` (hết trạng thái Servo OFF / Free).
   * Thanh ghi CC-Link DAC `W200` nhận giá trị `400` (sau khi chia 4 từ 1600) $\rightarrow$ Xuất **`1.00 VDC`** ra Domino Kênh 1.
   * Động cơ bắt đầu quay êm thuận chiều.
   * Xung Encoder tăng đều trên `Curr_Pulse_T` (Slot 2 CH1).

#### 🔹 Bước 4: Dừng thử nghiệm
1. Tắt bit tương ứng (**`M30 := 0`**).
2. Tốc độ ngõ ra `W200` tự động trở về `0` $\rightarrow$ Động cơ hãm dừng và nhả Servo ON.

---

## PHẦN 3: BẢN THIẾT KẾ GIAO DIỆN HMI WEINTEK HIỆN ĐẠI & ĐẸP MẮT

Để tạo ấn tượng chuyên nghiệp chuẩn Châu Âu (Industrial Clean Dark Mode), chúng ta thiết kế màn hình **`Window 20: TEST TỪNG TRỤC (MANUAL PANEL)`** theo phong cách Bento Grid hiện đại:

```
+---------------------------------------------------------------------------------------------------+
|  [LOGO] DÂY CHUYỀN GHÉP MÀNG METALIZE Q02U     | TRẠNG THÁI: [MÁY DỪNG] | CC-LINK: [KẾT NỐI OK]     |
+---------------------------------------------------------------------------------------------------+
|                                                                                                   |
|  +-- [CARD 1: TRỤC THU T] --------+  +-- [CARD 2: TRỤC KÉO X1] -------+  +-- [CARD 3: TRỤC MASTER X2] -+  |
|  | S.Ready: [ON]   S.ON: [ON]     |  | S.Ready: [ON]   S.ON: [OFF]    |  | S.Ready: [ON]   S.ON: [OFF]  |  |
|  | Tốc độ Test: [  1600  ] (10%)  |  | Tốc độ Test: [  1600  ] (10%)  |  | Tốc độ Test: [  2000  ] (12%)|  |
|  | Torque Test: [  8000  ] (50%)  |  |                                |  |                              |  |
|  | Áp DAC: 1.00V | Xung: 12450 p  |  | Áp DAC: 0.00V | Xung: 0 p      |  | Áp DAC: 0.00V | Xung: 0 p    |  |
|  | Loadcell:  12.5 kg             |  | Loadcell:   0.0 kg             |  | Tốc độ Line:  0.0 m/p        |  |
|  |                                |  |                                |  |                              |  |
|  | [ RUN TEST M30 ]  [ JOG M30 ]  |  | [ RUN TEST M31 ]  [ JOG M31 ]  |  | [ RUN TEST M32 ] [ JOG M32 ] |  |
|  +--------------------------------+  +--------------------------------+  +------------------------------+  |
|                                                                                                   |
|  +-- [CARD 4: TRỤC GHÉP MS] ------+  +-- [CARD 5: TRỤC TRÁNG DẦU S] --+  +-- [CARD 6: THẮNG / XẢ U] ---+  |
|  | S.Ready: [ON]   S.ON: [OFF]    |  | S.Ready: [ON]   S.ON: [OFF]    |  | Thắng M Test: [ 4000 ] (25%) |  |
|  | Tốc độ Test: [  1600  ] (10%)  |  | Tốc độ Test: [  1200  ] (8%)   |  | [ TEST THẮNG M35 ] L: 5.2 kg |  |
|  | Áp DAC: 0.00V | Xung: 0 p      |  | Áp DAC: 0.00V | RPM: 0 rpm     |  | ---------------------------- |  |
|  | Lực ép Ghép:  OK               |  | Bơm Dầu:    [CHẠY SẴN]         |  | Xả U Test:    [ 1600 ] (10%) |  |
|  |                                |  |                                |  | [ TEST XẢ U M36 ]  L: 0.0 kg |  |
|  | [ RUN TEST M33 ]  [ JOG M33 ]  |  | [ RUN TEST M34 ]  [ JOG M34 ]  |  |                              |  |
|  +--------------------------------+  +--------------------------------+  +------------------------------+  |
|                                                                                                   |
+---------------------------------------------------------------------------------------------------+
|  [F1: VẬN HÀNH CHÍNH]   [F2: TEST TỪNG TRỤC]   [F3: CÂN CHỈNH LOADCELL]   [F4: THÔNG SỐ PID/RECIPE]   |
+---------------------------------------------------------------------------------------------------+
```

### 3. Hướng dẫn phối màu & Styling trong EasyBuilder Pro:
1. **Màu nền (Background):** Dùng màu xám đen kỹ thuật cao `#1E222B` (không dùng màu trắng chói mắt gây mỏi mắt công nhân).
2. **Khung Card từng trục (Containers):** Nền `#282E3D`, bo tròn góc 8px (Radius = 8), viền mỏng `#3A4459`.
3. **Nút Bấm Test (Button States):**
   * Khi OFF: Nền xám `#3B4252`, chữ trắng.
   * Khi ON (Đang chạy test): Nền Xanh Lục rực rỡ `#10B981` (Emerald Green) hoặc Vàng Cam Cảnh Báo `#F59E0B`.
4. **Hiển thị số liệu (Numeric Display):**
   * Dùng font chữ **Roboto** hoặc **Consolas / Arial Bold**.
   * Màu chữ hiển thị: Vàng chanh `#EBCB8B` hoặc Xanh ngọc `#88C0D0` nổi bật trên nền tối.
5. **Cảnh báo an toàn (Safety Interlock):**
   * Nếu `State_Machine = 1` (Đang chạy tự động toàn dây chuyền), toàn bộ nút Test trên trang này sẽ bị **Disable / Ẩn** để ngăn ngừa công nhân vô tình bấm nhầm gây đứt màng.
