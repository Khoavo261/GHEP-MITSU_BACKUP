# GHI CHÚ THẢO LUẬN & BẢNG ÁNH XẠ THANH GHI PLC MITSUBISHI Q-SERIES

**Ngày tạo:** 15/08/2026 (Cập nhật: 24/08/2026)  
**Dự án:** GHEP-MITSU_BACKUP  
**Module liên quan:** FB Control Truyền Thông CC-Link (`fb_code_body.st`, `ffb_cclink_control_labels_paste.tsv`)

---

## 1. Giải thích dòng lệnh & Biến `DAC_CH1_Set`

### Dòng lệnh trong ST:
```pascal
D528 := INT_TO_WORD(WORD_TO_INT(DAC_CH1_Set) / 2); (* CH1 Output 0..5V *)
```

### Giải thích:
- **`DAC_CH1_Set`** là biến đầu vào (`VAR_INPUT`) kiểu `WORD` của Function Block.
- Trong chương trình chính và trên màn hình HMI Weintek, **`DAC_CH1_Set`** được liên kết (mapped) với thanh ghi **`D610`** (giá trị cài đặt `0 ~ 1000` tương ứng `0.0% ~ 100.0%`).
- **`D528`** là thanh ghi bộ đệm truyền thông CC-Link (RWw) để gửi dữ liệu xuất áp ra kênh 1 của trạm Analog Output (AJ65VBTCU-68DAVN - Trạm 3 & 4).
- Công thức `/ 2` dùng để quy đổi thang đo xuất điện áp thực tế `0 .. 5V` (từ dải 0..10V mặc định của module).

---

## 2. Bảng tổng hợp ánh xạ thanh ghi (Mapping Table)

### 🔹 Analog Input (ADC 8 Kênh Điện Áp) - Trạm 1 & 2 (AJ65VBT-68ADV - Chiếm 2 Trạm)
| Tên Biến FB | Thanh ghi Đọc về (RWr) | Thanh ghi HMI / Hiển thị | Chức năng / Thang đo |
| :--- | :--- | :--- | :--- |
| `ADC_CH1_Val` | **`D500`** | **`D600`** | Giá trị đọc % Loadcell Thu T (0.0% ~ 100.0%) |
| `ADC_CH2_Val` | **`D501`** | **`D601`** | Giá trị đọc % Loadcell Kéo X1 (0.0% ~ 100.0%) |
| `ADC_CH3_Val` | **`D502`** | **`D602`** | Giá trị đọc % Loadcell Thắng Metalize M (0.0% ~ 100.0%) |
| `ADC_CH4_Val` | **`D503`** | **`D603`** | Giá trị đọc % Loadcell Xả U (0.0% ~ 100.0%) |
| `ADC_CH5_Val` | **`D504`** | **`D604`** | Giá trị đọc % Kênh ADC CH5 Mở rộng |
| `ADC_CH6_Val` | **`D505`** | **`D605`** | Giá trị đọc % Kênh ADC CH6 Mở rộng |
| `ADC_CH7_Val` | **`D506`** | **`D606`** | Giá trị đọc % Kênh ADC CH7 Mở rộng |
| `ADC_CH8_Val` | **`D507`** | **`D607`** | Giá trị đọc % Kênh ADC CH8 Mở rộng |

### 🔹 Analog Output (DAC 8 Kênh Xuất Áp) - Trạm 3 & 4 (AJ65VBTCU-68DAVN - Chiếm 2 Trạm)
| Tên Biến FB | Thanh ghi HMI / Cài đặt | Thanh ghi CC-Link (RWw) | Chức năng / Thang đo |
| :--- | :--- | :--- | :--- |
| `DAC_CH1_Set` | **`D610`** | **`D528`** | Cài đặt Speed Thu T (0..16000) |
| `DAC_CH2_Set` | **`D611`** | **`D529`** | Cài đặt Torque Thu T (0..16000) |
| `DAC_CH3_Set` | **`D612`** | **`D530`** | Cài đặt Speed Kéo X1 (0..16000) |
| `DAC_CH4_Set` | **`D613`** | **`D531`** | Cài đặt Speed Master X2 (0..16000) |
| `DAC_CH5_Set` | **`D614`** | **`D532`** | Cài đặt Speed Ghép Ms (0..16000) |
| `DAC_CH6_Set` | **`D615`** | **`D533`** | Cài đặt Torque Thắng M (0..16000) |
| `DAC_CH7_Set` | **`D616`** | **`D534`** | Cài đặt Speed Tráng Dầu S (0..16000) |
| `DAC_CH8_Set` | **`D617`** | **`D535`** | Cài đặt Speed Xả U (0..16000) |

### 🔹 Digital Remote I/O - Trạm 5 (AJ65SBTB1-16DT: 8 Input X0..X7 / 8 Output Y8..YF - Chiếm 1 Trạm)
| Tên Biến FB | Biến PLC / HMI | Tín hiệu CC-Link | Chức Năng Trên Module Trạm 5 |
| :--- | :--- | :--- | :--- |
| `DI_X0_State` | **`M1136`** | `RX80` | Đèn báo trạng thái ngõ vào X0 Trạm 5 (Ready Servo T) |
| `DI_X1_State` | **`M1137`** | `RX81` | Đèn báo trạng thái ngõ vào X1 Trạm 5 (Ready Servo X1) |
| `DI_X2_State` | **`M1138`** | `RX82` | Đèn báo trạng thái ngõ vào X2 Trạm 5 (Ready Servo X2) |
| `DI_X3_State` | **`M1139`** | `RX83` | Đèn báo trạng thái ngõ vào X3 Trạm 5 (Ready Servo Ms) |
| `DI_X4_State` | **`M1140`** | `RX84` | Đèn báo trạng thái ngõ vào X4 Trạm 5 (Ready Servo S) |
| `DI_X5_State` | **`M1141`** | `RX85` | Nút nhấn Jog bò chậm nối màng 2 m/p |
| `DO_Servo_ON_T` | **`M1336`** | `RY88` | Servo ON Trục Thu T (Cọc ra Y8 Trạm 5) |
| `DO_Servo_ON_X1` | **`M1337`** | `RY89` | Servo ON Trục Xả X1 (Cọc ra Y9 Trạm 5) |
| `DO_Servo_ON_X2` | **`M1338`** | `RY8A` | Servo ON Trục Master X2 (Cọc ra YA Trạm 5) |
| `DO_Servo_ON_Ms` | **`M1339`** | `RY8B` | Servo ON Trục Ghép Ms (Cọc ra YB Trạm 5) |
| `DO_Servo_ON_S` | **`M1340`** | `RY8C` | Servo ON Trục Tráng Dầu S (Cọc ra YC Trạm 5) |
| `DO_Pen1` | **`M1341`** | `RY8D` | Ngõ ra Van Solenoid Pen 1 (Cọc ra YD Trạm 5) |
| `DO_Pen2` | **`M1342`** | `RY8E` | Ngõ ra Van Solenoid Pen 2 (Cọc ra YE Trạm 5) |
| `DO_Spare` | **`M1343`** | `RY8F` | Dự phòng / Còi báo lỗi (Cọc ra YF Trạm 5) |
| `HasError` | **`M1303`** | `RY67` / `SW0` | Đèn / Tín hiệu báo lỗi trạm Remote |
| `ResetErr` | **`M1111` / `M0`** | `RY1A / RY5A` | Nút bấm Reset lỗi hệ thống |

---

## 3. Cách xem lại trong các buổi làm việc sau
- Mở file này trực tiếp trong dự án: [`notes_cclink_mapping.md`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/notes_cclink_mapping.md)
- Hoặc vào **Chat History** trên thanh công cụ của Antigravity IDE để xem lại toàn bộ nội dung trò chuyện.

