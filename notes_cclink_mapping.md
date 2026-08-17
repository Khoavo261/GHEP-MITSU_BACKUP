# GHI CHÚ THẢO LUẬN & BẢNG ÁNH XẠ THANH GHI PLC MITSUBISHI Q-SERIES

**Ngày tạo:** 15/08/2026  
**Dự án:** GHEP-MITSU_BACKUP  
**Module liên quan:** FB Control Truyền Thông CC-Link (`fb_code_body.st`, `fb_cclink_control.st`)

---

## 1. Giải thích dòng lệnh & Biến `DAC_CH1_Set`

### Dòng lệnh trong ST:
```pascal
D524 := INT_TO_WORD(WORD_TO_INT(DAC_CH1_Set) / 2); (* CH1 Output 0..5V *)
```

### Giải thích:
- **`DAC_CH1_Set`** là biến đầu vào (`VAR_INPUT`) kiểu `WORD` của Function Block.
- Trong chương trình chính và trên màn hình HMI Weintek, **`DAC_CH1_Set`** được liên kết (mapped) với thanh ghi **`D610`** (giá trị cài đặt `0 ~ 1000` tương ứng `0.0% ~ 100.0%`).
- **`D524`** là thanh ghi bộ đệm truyền thông CC-Link (RWw) để gửi dữ liệu xuất áp ra kênh 1 của trạm Analog Output (AJ65VBTCU-68DAVN).
- Công thức `/ 2` dùng để quy đổi thang đo xuất điện áp thực tế `0 .. 5V` (từ dải 0..10V mặc định của module).

---

## 2. Bảng tổng hợp ánh xạ thanh ghi (Mapping Table)

### 🔹 Analog Output (DAC) - Trạm 2 & 3 (AJ65VBTCU-68DAVN)
| Tên Biến FB | Thanh ghi HMI / Cài đặt | Thanh ghi CC-Link (RWw) | Chức năng / Thang đo |
| :--- | :--- | :--- | :--- |
| `DAC_CH1_Set` | **`D610`** | `D524` | Cài đặt Analog Output CH1 (0..1000 -> 0..5V) |
| `DAC_CH2_Set` | **`D611`** | `D525` | Cài đặt Analog Output CH2 (0..1000 -> 0..5V) |
| `DAC_CH3_Set` | **`D612`** | `D526` | Cài đặt Analog Output CH3 (0..1000 -> 0..5V) |
| `DAC_CH4_Set` | **`D613`** | `D527` | Cài đặt Analog Output CH4 (0..1000 -> 0..5V) |
| `DAC_CH5_Set` | **`D614`** | `D528` | Cài đặt Analog Output CH5 (0..1000 -> 0..5V) |
| `DAC_CH6_Set` | **`D615`** | `D529` | Cài đặt Analog Output CH6 (0..1000 -> 0..5V) |
| `DAC_CH7_Set` | **`D616`** | `D530` | Cài đặt Analog Output CH7 (0..1000 -> 0..5V) |
| `DAC_CH8_Set` | **`D617`** | `D531` | Cài đặt Analog Output CH8 (0..1000 -> 0..5V) |

### 🔹 Analog Input (ADC) - Trạm 1 (AJ65SBT-64AD)
| Tên Biến FB | Thanh ghi Đọc về (RWr) | Thanh ghi HMI / Hiển thị | Chức năng / Thang đo |
| :--- | :--- | :--- | :--- |
| `ADC_CH1_Val` | `D500` | **`D600`** | Giá trị đọc % Analog Input CH1 (0.0% ~ 100.0%) |
| `ADC_CH2_Val` | `D501` | **`D601`** | Giá trị đọc % Analog Input CH2 (0.0% ~ 100.0%) |
| `ADC_CH3_Val` | `D502` | **`D602`** | Giá trị đọc % Analog Input CH3 (0.0% ~ 100.0%) |
| `ADC_CH4_Val` | `D503` | **`D603`** | Giá trị đọc % Analog Input CH4 (0.0% ~ 100.0%) |

### 🔹 Digital Remote I/O - Trạm 4 (AJ65SBTB1-16DT: 8 Input X0..X7 / 8 Output Y8..YF)
| Tên Biến FB | Biến PLC / HMI | Tín hiệu CC-Link | Chức Năng Trên Module Trạm 4 |
| :--- | :--- | :--- | :--- |
| `DI_X0_State` | **`M1104`** | `RX60` | Đèn báo trạng thái ngõ vào X0 Trạm 4 |
| `DI_X1_State` | **`M1105`** | `RX61` | Đèn báo trạng thái ngõ vào X1 Trạm 4 |
| `DI_X2_State` | **`M1106`** | `RX62` | Đèn báo trạng thái ngõ vào X2 Trạm 4 |
| `DI_X3_State` | **`M1107`** | `RX63` | Đèn báo trạng thái ngõ vào X3 Trạm 4 |
| `DO_Servo_ON_T` | **`M1304`** | `RY68` | Servo ON Trục Thu T (Cọc ra Y8 Trạm 4) |
| `DO_Servo_ON_X1` | **`M1305`** | `RY69` | Servo ON Trục Xả X1 (Cọc ra Y9 Trạm 4) |
| `DO_Servo_ON_X2` | **`M1306`** | `RY6A` | Servo ON Trục Master X2 (Cọc ra YA Trạm 4) |
| `DO_Servo_ON_Ms` | **`M1307`** | `RY6B` | Servo ON Trục Ghép Ms (Cọc ra YB Trạm 4) |
| `DO_Servo_ON_S` | **`M1308`** | `RY6C` | Servo ON Trục Tráng Dầu S (Cọc ra YC Trạm 4) |
| `DO_Pen1` | **`M1309`** | `RY6D` | Ngõ ra Van Solenoid Pen 1 (Cọc ra YD Trạm 4) |
| `DO_Pen2` | **`M1310`** | `RY6E` | Ngõ ra Van Solenoid Pen 2 (Cọc ra YE Trạm 4) |
| `DO_Spare` | **`M1311`** | `RY6F` | Dự phòng / Báo lỗi (Cọc ra YF Trạm 4) |
| `HasError` | **`M1303`** | `RY67` | Đèn / Tín hiệu báo lỗi trạm Remote |
| `ResetErr` | **`M1111` / `M0`** | `RY1A / RY3A` | Nút bấm Reset lỗi hệ thống |

---

## 3. Cách xem lại trong các buổi làm việc sau
- Mở file này trực tiếp trong dự án: [`notes_cclink_mapping.md`](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/notes_cclink_mapping.md)
- Hoặc vào **Chat History** trên thanh công cụ của Antigravity IDE để xem lại toàn bộ nội dung trò chuyện.
