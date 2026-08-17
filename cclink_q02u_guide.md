# HƯỚNG DẪN CẤU HÌNH & LẬP TRÌNH CC-LINK CHO PLC MITSUBISHI Q02UCPU

**Dự án:** Truyền thông CC-Link điều khiển Module Analog ADC/DAC & Remote I/O  
**PLC Central CPU:** Mitsubishi **Q02UCPU** (Q Series Universal CPU)  
**Software:** GX Works2 (Structured Project ST / Ladder IL)  
**Thư mục làm việc:** `D:\data-2026\GHEP-MITSU\`  

---

## 1. TẠI SAO MODULE `AJ65VBTCU-68DAVN` BẮT BUỘC PHẢI CHỌN `2 STATIONS`?

Module `AJ65VBTCU-68DAVN` có **8 kênh Analog Output** (xuất điện áp $-10\text{V} \sim +10\text{V}$).
- Ở chế độ CC-Link Ver.1, **1 Station chỉ cấp 4 thanh ghi `RWw`** (chỉ xuất được 4 kênh).
- Do đó, phần cứng module `AJ65VBTCU-68DAVN` thiết kế cố định chiếm **`2 Stations`** (để lấy đủ 8 thanh ghi `RWw` xuất cho 8 kênh DAC).
- Khi chọn `1 Station`, phần mềm báo lỗi **`Parameter mismatch error`** vì lệch số trạm với phần cứng.

---

## 2. CẤU HÌNH PARAMETER BẢNG STATION INFORMATION CHUẨN 100%

Vào **`Network Parameter`** $\rightarrow$ **`CC-Link`** $\rightarrow$ Click nút **`Station Information`**:

| Station No. | Station Type | Occupied Modules | Thiết bị thực tế | Công tắc địa chỉ phần cứng (Station Switch) |
| :--- | :--- | :--- | :--- | :--- |
| **Station 1** | **`Remote Device Station`** | **`1 Station`** | AJ65SBT-64AD (ADC 4CH) | Gạt công tắc địa chỉ = **`1`** |
| **Station 2** | **`Remote Device Station`** | **`2 Stations`** | AJ65VBTCU-68DAVN (DAC 8CH) | Gạt công tắc địa chỉ = **`2`** *(Chiếm trạm 2 & 3)* |
| **Station 4** | **`Remote I/O Station`** | **`1 Station`** | AJ65SBT-16DT (Digital I/O) | **Gạt công tắc địa chỉ = `4`** |

---

## 3. CẤU HÌNH PARAMETER BẢNG CC-LINK MASTER

Vào **`Network Parameter`** $\rightarrow$ **`CC-Link`**:

- **Number of Modules:** `1`
- **Start I/O No.:** `0000`
- **Type:** `Master Station`
- **Master Station Data Link Type:** `PLC Parameter Auto Start`
- **Mode:** `Remote Net(Ver.1 Mode)`
- **Total Module Connected:** **`3`**
- **Remote input (RX):** **`M1008`** *(Dùng M1008 ~ M1135 - 128 bits cho 4 trạm)*
- **Remote output (RY):** **`M1200`** *(Dùng M1200 ~ M1327 - Không bao giờ đè)*
- **Remote register (RWr):** **`D500`** *(RWr0~RWr11 -> D500..D511)*
- **Remote register (RWw):** **`D520`** *(RWw0~RWw11 -> D520..D531)*
- **Special relay (SB):** `SB0`
- **Special register (SW):** `SW0`

---

## 4. BẢN ĐỒ ĐỊA CHỈ VÙNG NHỚ CHUẨN (STATION 1, 2&3, 4)

### A. AJ65SBT-64AD (Trạm 1 - Analog Input 4 Kênh)
- `M1016` (`RX8`): Cờ báo hoàn tất chuyển đổi A/D
- `M1032` (`RX18`): Cờ báo lỗi Module ADC
- `M1208` (`RY8`): Bit cho phép chuyển đổi A/D (AD Conversion Enable)
- `M1226` (`RY1A`): Bit Reset lỗi ADC
- `D500` ~ `D503` (`RWr0`~`RWr3`): Đọc giá trị 4 kênh ADC (0~4000)

### B. AJ65VBTCU-68DAVN (Trạm 2 & 3 - Analog Output 8 Kênh DAC)
- `M1064` (`RX38`): Cờ báo sẵn sàng DAC
- `M1066` (`RX3A`): Cờ báo lỗi Module DAC
- `M1240` (`RY28`): Bit cho phép xuất Analog D/A (DA Conversion Enable)
- `M1258` (`RY3A`): Bit Reset lỗi DAC
- `D524` ~ `D531` (`RWw4`~`RWwB`): Xuất giá trị 8 kênh DAC

### C. AJ65SBTB1-16DT (Trạm 4 - Remote Digital 8 In / 8 Out)
- **Ngõ vào Digital Remote (`RX60`~`RX67`):** **`M1104` ~ `M1111`** (Nút nhấn / Cảm biến X0~X7)
- **Ngõ ra Digital Remote (`RY68`~`RY6F`):** **`M1304` ~ `M1311`** (Cuộn hút / Đèn Y8~YF)
