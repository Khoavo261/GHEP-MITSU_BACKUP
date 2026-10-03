# 🔌 HƯỚNG DẪN ĐẤU DÂY MODULE ĐẾM XUNG CAO TỐC QD62D (CH1 & CH2)

**Dự án:** Hệ thống Điều Khiển Dây Chuyền Máy Ghép Màng Metalize Tự Động  
**PLC:** Mitsubishi **Q02UCPU**  
**Module:** **QD62D** (Line Driver Input - Chuẩn vi sai RS-422-A)  
**Đầu nối:** Jack cắm **40-Pin Connector** (A6CON1 / A6CON2 hoặc Domino chuyển đổi FA-TBS40P / FTB-40Q)

---

## 📌 1. ĐẶC TÍNH KỸ THUẬT QUAN TRỌNG CỦA QD62D

> [!IMPORTANT]
> **ĐẶC BIỆT LƯU Ý:**  
> Module **QD62D** có chữ cái **"D"** ở đuôi là viết tắt của **Differential Line Driver** (Chuẩn EIA RS-422-A vi sai).  
> - **Chỉ nhận tín hiệu vi sai:** Cặp dây tín hiệu luôn đi theo cặp đối xứng: $(A+, A-)$, $(B+, B-)$, $(Z+, Z-)$.  
> - **Mức điện áp xung ngõ vào:** Chuẩn vi sai **5V DC (RS-422-A)**, tương thích với các IC Driver như AM26LS31, 26C31 hoặc Encoder Line Driver (Line Driver Output).  
> - **Tần số đếm xung tối đa:** Lên tới **500 kpps** (500.000 xung/giây), tốc độ và khả năng chống nhiễu cao nhất trong dòng QD62.  
> - ⚠️ **Không đấu trực tiếp Encoder NPN Open Collector (Cực thu hở 24V)** vào các chân xung vi sai này. Nếu dùng encoder NPN, phải qua mạch chuyển đổi tín hiệu sang Line Driver trước khi đưa vào QD62D.

---

## 📌 2. BẢNG SƠ ĐỒ CHÂN 40-PIN CONNECTOR (PINOUT MAP)

Module sử dụng giắc cắm 40 chân chia làm 2 hàng: **Hàng A (A01 .. A20)** và **Hàng B (B01 .. B20)**.

```
       [ NHÌN TỪ MẶT TRƯỚC JACK CẮM MODULE QD62D ]
      ┌────────────────────────┬────────────────────────┐
      │  HÀNG B (B01 .. B20)   │  HÀNG A (A01 .. A20)   │
      │  [B01]  ...  [B20]     │  [A01]  ...  [A20]     │
      └────────────────────────┴────────────────────────┘
```

### 📋 Bảng Tra Cứu Chi Tiết Từng Chân:

| Hàng A (Pin No.) | Tên Tín Hiệu | Chức Năng Chi Tiết | Hàng B (Pin No.) | Tên Tín Hiệu | Chức Năng Chi Tiết |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **A20** | **1A+** | **CH1 - Xung Phase A (+)** | **B20** | **NC / Dự phòng** | Không đấu nối |
| **A19** | **1A-** | **CH1 - Xung Phase A (-)** | **B19** | **NC / Dự phòng** | Không đấu nối |
| **A18** | **1B+** | **CH1 - Xung Phase B (+)** | **B18** | **NC / Dự phòng** | Không đấu nối |
| **A17** | **1B-** | **CH1 - Xung Phase B (-)** | **B17** | **NC / Dự phòng** | Không đấu nối |
| **A16** | **1Z+** (Preset+) | **CH1 - Xung Reset/Gốc Z (+)** | **B16** | **1PRESET 24V** | Chân kích Preset ngoài 24V |
| **A15** | **1Z-** (Preset-) | **CH1 - Xung Reset/Gốc Z (-)** | **B15** | **1PRESET COM** | Chân 0V Preset ngoài |
| **A14** | **1FUNT 24V** | CH1 Function Start 24V | **B14** | **1FUNT COM** | CH1 Function Start 0V |
| **A13** | **NC** | Không dùng | **B13** | **NC** | Không dùng |
| **A12** | **NC** | Không dùng | **B12** | **NC** | Không dùng |
| **A11** | **NC** | Không dùng | **B11** | **NC** | Không dùng |
| ───────── | ─────────────── | ────────────────────────── | ───────── | ─────────────── | ────────────────────────── |
| **A10** | **2A+** | **CH2 - Xung Phase A (+)** | **B10** | **NC / Dự phòng** | Không đấu nối |
| **A09** | **2A-** | **CH2 - Xung Phase A (-)** | **B09** | **NC / Dự phòng** | Không đấu nối |
| **A08** | **2B+** | **CH2 - Xung Phase B (+)** | **B08** | **NC / Dự phòng** | Không đấu nối |
| **A07** | **2B-** | **CH2 - Xung Phase B (-)** | **B07** | **NC / Dự phòng** | Không đấu nối |
| **A06** | **2Z+** (Preset+) | **CH2 - Xung Reset/Gốc Z (+)** | **B06** | **2PRESET 24V** | Chân kích Preset ngoài 24V |
| **A05** | **2Z-** (Preset-) | **CH2 - Xung Reset/Gốc Z (-)** | **B05** | **2PRESET COM** | Chân 0V Preset ngoài |
| **A04** | **2FUNT 24V** | CH2 Function Start 24V | **B04** | **2FUNT COM** | CH2 Function Start 0V |
| **A03** | **NC** | Không dùng | **B03** | **NC** | Không dùng |
| **A02** | **EQU1** | Ngõ ra Coincidence CH1 (NPN) | **B02** | **OUT COM (-)** | 0V nguồn ngoài ngõ ra |
| **A01** | **EQU2** | Ngõ ra Coincidence CH2 (NPN) | **B01** | **+24V (EXT)** | +24V nguồn ngoài ngõ ra |

---

## 📌 3. SƠ ĐỒ ĐẤU DÂY THỰC TẾ GIỮA ENCODER LINE DRIVER VÀ QD62D

### 🔹 3.1 ĐẤU NỐI KÊNH 1 (CH1):

> Kênh 1 thường dùng cho: **Trục Thu Cuộn T** (Slot 2) hoặc **Trục Master X2** (Slot 3).

```
   ┌────────────────────────────────┐                 ┌─────────────────────────────┐
   │    ENCODER LINE DRIVER 5V      │                 │     MODULE MITSUBISHI       │
   │   (Ví dụ: Omron, Autonics,     │                 │          QD62D              │
   │    Yaskawa, Tamagawa...)       │                 │   (Chân Jack Cắm 40-Pin)    │
   ├────────────────────────────────┤                 ├─────────────────────────────┤
   │  Dây Phase A+ (Dương)          ├─────────────────┤ Chân A20  (1A+)             │
   │  Dây Phase A- (Âm / Đảo)       ├─────────────────┤ Chân A19  (1A-)             │
   │                                │                 │                             │
   │  Dây Phase B+ (Dương)          ├─────────────────┤ Chân A18  (1B+)             │
   │  Dây Phase B- (Âm / Đảo)       ├─────────────────┤ Chân A17  (1B-)             │
   │                                │                 │                             │
   │  Dây Phase Z+ (Gốc / Index)    ├─────────────────┤ Chân A16  (1Z+) [Tùy chọn]  │
   │  Dây Phase Z- (Gốc / Index)    ├─────────────────┤ Chân A15  (1Z-) [Tùy chọn]  │
   ├────────────────────────────────┤                 └─────────────────────────────┘
   │  Dây Cấp Nguồn +5VDC (VCC)     │◄─── [ NGUỒN NGOÀI SWITCHING +5VDC ]
   │  Dây Cấp Nguồn 0VDC (GND)      │◄─── [ NGUỒN NGOÀI SWITCHING  0VDC ]
   │  Lưới Chống Nhiễu (Shield)     ├─────────────────► [ BẮT VÍT MASS TỦ ĐIỆN PE/FG]
   └────────────────────────────────┘
```

---

### 🔹 3.2 ĐẤU NỐI KÊNH 2 (CH2):

> Kênh 2 thường dùng cho: **Trục Kéo X1** (Slot 2) hoặc **Trục Ghép MS** (Slot 3).

```
   ┌────────────────────────────────┐                 ┌─────────────────────────────┐
   │    ENCODER LINE DRIVER 5V      │                 │     MODULE MITSUBISHI       │
   │   (Ví dụ: Omron, Autonics,     │                 │          QD62D              │
   │    Yaskawa, Tamagawa...)       │                 │   (Chân Jack Cắm 40-Pin)    │
   ├────────────────────────────────┤                 ├─────────────────────────────┤
   │  Dây Phase A+ (Dương)          ├─────────────────┤ Chân A10  (2A+)             │
   │  Dây Phase A- (Âm / Đảo)       ├─────────────────┤ Chân A09  (2A-)             │
   │                                │                 │                             │
   │  Dây Phase B+ (Dương)          ├─────────────────┤ Chân A08  (2B+)             │
   │  Dây Phase B- (Âm / Đảo)       ├─────────────────┤ Chân A07  (2B-)             │
   │                                │                 │                             │
   │  Dây Phase Z+ (Gốc / Index)    ├─────────────────┤ Chân A06  (2Z+) [Tùy chọn]  │
   │  Dây Phase Z- (Gốc / Index)    ├─────────────────┤ Chân A05  (2Z-) [Tùy chọn]  │
   ├────────────────────────────────┤                 └─────────────────────────────┘
   │  Dây Cấp Nguồn +5VDC (VCC)     │◄─── [ NGUỒN NGOÀI SWITCHING +5VDC ]
   │  Dây Cấp Nguồn 0VDC (GND)      │◄─── [ NGUỒN NGOÀI SWITCHING  0VDC ]
   │  Lưới Chống Nhiễu (Shield)     ├─────────────────► [ BẮT VÍT MASS TỦ ĐIỆN PE/FG]
   └────────────────────────────────┘
```

---

## 📌 4. BẢNG MÀU DÂY TIÊU CHUẨN CỦA CÁC DÒNG ENCODER THƯỜNG GẶP

Khi đấu nối, hãy đối chiếu màu dây thực tế trên tem dán vỏ của Encoder:

| Tín Hiệu Vi Sai | Hãng Autonics (E50S / E40S) | Hãng Omron (E6B2-CWZ1X) | Hãng Koyo / Tamagawa | Đấu vào QD62D CH1 | Đấu vào QD62D CH2 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **A +** | **Đen (Black)** | **Đen (Black)** | **Xanh dương (Blue)** | **A20** | **A10** |
| **A -** | **Đỏ (Red)** | **Trắng (White)** | **Xanh dương sọc trắng** | **A19** | **A09** |
| **B +** | **Trắng (White)** | **Trắng (White)** | **Xanh lá (Green)** | **A18** | **A08** |
| **B -** | **Xám (Gray)** | **Vàng (Yellow)** | **Xanh lá sọc trắng** | **A17** | **A07** |
| **Z +** | **Cam (Orange)** | **Cam (Orange)** | **Vàng (Yellow)** | **A16** *(nếu dùng)* | **A06** *(nếu dùng)* |
| **Z -** | **Vàng (Yellow)** | **Xanh dương (Blue)** | **Vàng sọc trắng** | **A15** *(nếu dùng)* | **A05** *(nếu dùng)* |
| **+5V (VCC)** | **Nâu (Brown)** | **Nâu (Brown)** | **Đỏ (Red)** | Nguồn ngoài +5V | Nguồn ngoài +5V |
| **0V (GND)** | **Xanh dương (Blue)** | **Xanh dương (Blue)** | **Đen (Black)** | Nguồn ngoài 0V | Nguồn ngoài 0V |
| **Shield (FG)** | **Lưới bọc kim** | **Lưới bọc kim** | **Lưới bọc kim** | Tiếp địa vỏ tủ | Tiếp địa vỏ tủ |

---

## 📌 5. QUY TẮC CHỐNG NHIỄU BẮT BUỘC TRONG TỦ ĐIỆN CÔNG NGHIỆP

Do hệ thống máy ghép metalize có nhiều biến tần công suất lớn và động cơ kéo:
1. **Dùng cáp xoắn đôi có giáp bảo vệ (Shielded Twisted Pair - STP):**
   - Cặp dây $A+$ và $A-$ phải nằm cùng một cặp dây xoắn.
   - Cặp dây $B+$ và $B-$ phải nằm cùng một cặp dây xoắn.
   - Cặp dây $+5\text{V}$ và $0\text{V}$ phải nằm cùng một cặp dây xoắn.
2. **Tiếp địa chống nhiễu (Shield Grounding):**
   - Lớp lưới chống nhiễu của cáp encoder chỉ được tiếp địa **tại một đầu duy nhất** ở phía tủ điện (kẹp chặt vào thanh đồng tiếp địa PE tủ điện bằng cùm kẹp kim loại AD75CK hoặc tương đương).
   - Tuyệt đối không đấu đầu lưới còn lại vào vỏ máy motor để tránh dòng điện vòng (Ground Loop).
3. **Cách ly dây dẫn:**
   - Dây cáp encoder phải đi riêng biệt, cách xa cáp động lực của biến tần và servo tối thiểu **$150\text{mm} \sim 200\text{mm}$**.
   - Không được đi chung máng dây hoặc quấn chung với dây nguồn $380\text{V} / 220\text{V}$.

---

## 📌 6. BẢNG TRA CỨU ĐỊA CHỈ PLC & VÙNG NHỚ TRONG PHẦN MỀM

| Vị trí cắm | Tên Module | Kênh | Trục Cơ Cấu | Thanh ghi đọc xung (32-bit) | Cờ cho phép đếm | Cờ báo đang đếm | Lệnh Reset xung |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Slot 2** | **QD62D #1** | **CH1** | **Trục Thu T** | **`D550 - D551`** *(G2..G3)* | **`Y24 := 1`** | `X2A = 1` | `M220 := 1` |
| **Slot 2** | **QD62D #1** | **CH2** | **Trục Kéo X1** | **`D552 - D553`** *(G34..G35)* | **`Y2C := 1`** | `X2B = 1` | `M221 := 1` |
| **Slot 3** | **QD62D #2** | **CH1** | **Trục Master X2** | **`D562 - D563`** *(G2..G3)* | **`Y34 := 1`** | `X3A = 1` | `M230 := 1` |
| **Slot 3** | **QD62D #2** | **CH2** | **Trục Ghép MS** | **`D564 - D565`** *(G34..G35)* | **`Y3C := 1`** | `X3B = 1` | `M231 := 1` |

*(Trong chương trình PLC, khi quay encoder thì các thanh ghi D tương ứng sẽ tự động nhảy số theo thời gian thực).*
