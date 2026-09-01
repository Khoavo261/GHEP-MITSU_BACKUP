# HƯỚNG DẪN CẤU HÌNH & LẬP TRÌNH CC-LINK CHO PLC MITSUBISHI Q02UCPU

**Dự án:** Truyền thông CC-Link điều khiển Module Analog ADC/DAC & Remote I/O  
**PLC Central CPU:** Mitsubishi **Q02UCPU** (Q Series Universal CPU)  
**Software:** GX Works2 (Structured Project ST / Ladder IL)  
**Thư mục làm việc:** `d:\data-2026\lap_top\GHEP-MITSU_BACKUP\`  

---

## 1. TẠI SAO `AJ65VBT-68ADV` VÀ `AJ65VBTCU-68DAVN` ĐỀU PHẢI CHỌN `2 STATIONS`?

1. **Module `AJ65VBT-68ADV` (8 kênh ADC Điện Áp):**
   - Ở chế độ CC-Link Ver.1, **1 Station chỉ cấp 4 thanh ghi `RWr`** (chỉ đọc được 4 kênh).
   - Vì có 8 kênh ngõ vào, phần cứng module `AJ65VBT-68ADV` thiết kế cố định chiếm **`2 Stations`** (để lấy đủ 8 thanh ghi `RWr0..RWr7`).
2. **Module `AJ65VBTCU-68DAVN` (8 kênh DAC Xuất Áp):**
   - Tương tự, 1 Station chỉ cấp 4 thanh ghi `RWw` (chỉ xuất được 4 kênh).
   - Module có 8 kênh ngõ ra nên bắt buộc chiếm **`2 Stations`** (để lấy đủ 8 thanh ghi `RWw8..RWwF`).

> [!IMPORTANT]
> Nếu cài đặt sai số trạm (ví dụ chọn 1 Station), phần mềm và CPU sẽ báo lỗi **`Parameter mismatch error`** do lệch số trạm với phần cứng thực tế.

---

## 2. CẤU HÌNH PARAMETER BẢNG STATION INFORMATION CHUẨN 100%

Vào **`Network Parameter`** $\rightarrow$ **`CC-Link`** $\rightarrow$ Click nút **`Station Information`**:

| Station No. | Station Type | Occupied Modules | Thiết bị thực tế | Công tắc địa chỉ phần cứng (Station Switch) |
| :--- | :--- | :--- | :--- | :--- |
| **Station 1** | **`Remote Device Station`** | **`2 Stations`** | `AJ65VBT-68ADV` (ADC 8CH Voltage) | Gạt công tắc địa chỉ = **`1`** *(Chiếm trạm 1 & 2)* |
| **Station 3** | **`Remote Device Station`** | **`2 Stations`** | `AJ65VBTCU-68DAVN` (DAC 8CH Voltage) | Gạt công tắc địa chỉ = **`3`** *(Chiếm trạm 3 & 4)* |
| **Station 5** | **`Remote I/O Station`** | **`1 Station`** | `AJ65SBTB1-16DT` (Digital 16 I/O) | **Gạt công tắc địa chỉ = `5`** *(Chiếm trạm 5)* |

---

## 3. CẤU HÌNH PARAMETER BẢNG CC-LINK MASTER

Vào **`Network Parameter`** $\rightarrow$ **`CC-Link`**:

- **Number of Modules:** `1`
- **Start I/O No.:** `0000`
- **Type:** `Master Station`
- **Master Station Data Link Type:** `PLC Parameter Auto Start`
- **Mode:** `Remote Net(Ver.1 Mode)`
- **Total Module Connected:** **`3`**
- **Remote input (RX):** **`M1008`** *(Dùng M1008 ~ M1167 - 160 bits cho 5 trạm)*
- **Remote output (RY):** **`M1200`** *(Dùng M1200 ~ M1359 - 160 bits cho 5 trạm)*
- **Remote register (RWr):** **`D500`** *(RWr0~RWr13 -> D500..D519)*
- **Remote register (RWw):** **`D520`** *(RWw0~RWw13 -> D520..D539)*
- **Special relay (SB):** `SB0`
- **Special register (SW):** `SW0`

---

## 4. BẢN ĐỒ ĐỊA CHỈ VÙNG NHỚ CHUẨN (STATION 1&2, 3&4, 5)

### A. AJ65VBT-68ADV (Trạm 1 & 2 - Analog Input 8 Kênh ADC)
- **`M1200` ~ `M1207` (`RY0` ~ `RY7`):** **BẮT BUỘC BẬT ON = 1** để Cho phép chuyển đổi A/D từng kênh CH1 ~ CH8 (Nếu không bật ON thì giá trị đọc về `D500..D507` luôn bằng 0!).
- `M1208` (`RY8`): Bit cho phép tổng chuyển đổi A/D (AD Conversion Master Enable)
- `M1016` (`RX8` / `RX19`): Cờ báo hoàn tất chuyển đổi A/D
- `M1034` (`RX1A`): Cờ báo lỗi Module ADC
- `M1226` (`RY1A`): Bit Reset lỗi ADC
- `D500` ~ `D507` (`RWr0`~`RWr7`): Đọc giá trị 8 kênh ADC (0~4000 hoặc 0~16000)

### B. AJ65VBTCU-68DAVN (Trạm 3 & 4 - Analog Output 8 Kênh DAC)
- `M1096` (`RX58`): Cờ báo sẵn sàng DAC (Module Ready)
- `M1098` (`RX5A`): Cờ báo lỗi Module DAC
- `M1272` (`RY48`): Bit cho phép xuất Analog D/A (DA Conversion Enable)
- `M1290` (`RY5A`): Bit Reset lỗi DAC
- `D528` ~ `D535` (`RWw8`~`RWwF`): Xuất giá trị 8 kênh DAC (0..16000)

### C. AJ65SBTB1-16DT (Trạm 5 - Remote Digital 8 In / 8 Out)
- **Ngõ vào Digital Remote (`RX80`~`RX87`):** **`M1136` ~ `M1143`** (Nút nhấn / Cảm biến X0~X7)
- **Ngõ ra Digital Remote (`RY88`~`RY8F`):** **`M1336` ~ `M1343`** (Cuộn hút / Đèn Y8~YF)

