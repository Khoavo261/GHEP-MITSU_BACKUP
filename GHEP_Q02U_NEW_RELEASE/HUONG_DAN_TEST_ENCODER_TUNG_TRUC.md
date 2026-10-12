# 🧭 HƯỚNG DẪN TEST ENCODER & GIÁM SÁT TỐC ĐỘ MPM TỪNG TRỤC LÔ
## DỰ ÁN: MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - PLC MITSUBISHI Q02UCPU

---

## 📌 PHẦN 1: NGUYÊN LÝ HOẠT ĐỘNG (ĐƠN GIẢN HÓA - DÙNG CỜ 10MS)

Hệ thống sử dụng **02 Module đếm xung cao tốc vi sai QD62D** (Line Driver RS-422) đọc tín hiệu xung Phase A/B từ Driver Yaskawa hoặc Encoder ngoài:
* **Encoder phần cứng & Driver Yaskawa:** Cài đặt Pn212 = 2000 P/Rev.
* **Chế độ đếm PLC (QD62D):** **2-Phase 4-Multiple (Nhân 4 vi sai, Switch Setting = 0035 - Băng thông 500 kpps chống rơi xung)**:
  $$\text{Tổng xung/vòng} = 2000 \times 4 = \mathbf{8000\text{ xung/vòng}}$$
* **KHÔNG DÙNG CHỐT PHẦN CỨNG (BỎ PHA Z / CHÂN FUNC):** 
  * Không cần đấu nối chân FUNC 5V phức tạp, không cần cấu hình Latch Counter phần cứng.
  * Số vòng quay được PLC tính trực tiếp: $\text{Rev\_Count} = \text{Curr\_Pulse} / 8000$.
* **ĐO TỐC ĐỘ THEO CHU KỲ CONSTANT SCAN = 50MS (0.05S):**
  * CPU Q02U cài đặt Constant Scan = $50\text{ms}$ $\rightarrow$ Mỗi scan cách nhau đúng $0.05\text{s}$.
  * PLC tính $\Delta\text{Pulse} = \text{Curr\_Pulse} - \text{Prev\_Pulse}$ mỗi scan (không phụ thuộc cờ clock, không sợ lỡ nhịp).
  * Tính ra tốc độ quay $\text{RPM}$ của trục động cơ:
    $$\text{RPM} = \frac{\Delta\text{Pulse} \times 60.0}{0.05 \times 8000} = \frac{\Delta\text{Pulse} \times 1200.0}{8000} = \mathbf{\Delta\text{Pulse} \times 0.15}$$
  * Qua bộ lọc trượt 4 mẫu (Moving Average) để triệt tiêu rung giật (độ mịn đạt $0.0375\text{ RPM}$).

---

## 📌 PHẦN 2: CÔNG THỨC QUY ĐỔI TỐC ĐỘ THỰC TẾ RA MPM (MÉT / PHÚT)

> [!IMPORTANT]
> * **RPM (Vòng / Phút):** Chỉ dùng để **test động cơ không tải, chạy Jog, kiểm tra hộp số**.
> * **MPM (Mét / Phút):** Là **vận tốc bề mặt thực tế của màng trên từng quả lô** – thông số sống còn để đồng tốc dây chuyền ghép màng và kiểm soát lực căng!

Công thức chuẩn cơ khí của từng trục lô:
$$\mathbf{MPM} = \frac{\text{RPM} \times \pi \times D_{\text{lô}}\text{ (mm)}}{1000 \times \text{GearRatio}}$$

| Trục Cơ Cấu | Đường Kính Lô ($D$) | Tỷ Số Truyền ($i$) | Công Thức Quy Đổi MPM | Thanh Ghi MPM |
| :--- | :---: | :---: | :--- | :---: |
| **Trục 3: Master X2** *(Lô kéo chính)* | $300.5\text{ mm}$ | $8.0$ | $\text{MPM}_{X2} = \frac{\text{RPM}_{X2} \times 3.14159 \times 300.5}{1000 \times 8.0}$ | **`D64`** *(và `D10` tốc độ line)* |
| **Trục 2: Kéo X1** *(Lô kéo giấy)* | $300.5\text{ mm}$ | $8.0$ | $\text{MPM}_{X1} = \frac{\text{RPM}_{X1} \times 3.14159 \times 300.5}{1000 \times 8.0}$ | **`D62`** |
| **Trục 4: Ghép Ms** *(Lô ép ghép)* | $200.0\text{ mm}$ | $10.0$ | $\text{MPM}_{Ms} = \frac{\text{RPM}_{Ms} \times 3.14159 \times 200.0}{1000 \times 10.0}$ | **`D66`** |
| **Trục Dầu S** *(Lô tráng silicon)* | $100.0\text{ mm}$ | $10.0$ | $\text{MPM}_{S} = \frac{\text{RPM}_{S} \times 3.14159 \times 100.0}{1000 \times 10.0}$ | **`D68`** |
| **Trục 1: Thu T** *(Lô cuộn màng)* | $76 \sim 1000\text{ mm}$ | $10.1$ | $\text{MPM}_{T} = \frac{\text{RPM}_{T} \times 3.14159 \times \text{Real\_Dia\_T}}{1000 \times 10.1}$ | **`D60`** |

---

## 📌 PHẦN 3: BẢNG GIÁM SÁT TOÀN DIỆN (QUICK WATCH TABLE)

> [!TIP]
> **Quy luật đuôi số đối xứng (0 - 2 - 4 - 6) cực kỳ dễ nhớ:**
> * **Trục 1 (Thu T):** Đuôi **`0`** (`D520`, `D840`, `D550`, `D50`, **`D60`**)
> * **Trục 2 (Kéo X1):** Đuôi **`2`** (`D522`, `D842`, `D552`, `D52`, **`D62`**)
> * **Trục 3 (Master X2):** Đuôi **`4`** (`D524`, `D844`, `D554`, `D54`, **`D64`**, và Line Speed **`D10`**)
> * **Trục 4 (Ghép Ms):** Đuôi **`6`** (`D526`, `D846`, `D556`, `D56`, **`D66`**)
> * **Trục Phụ (Dầu S):** Đuôi **`8`** (`D58`, **`D68`**)

| Trục Cơ Cấu | 1. Xung Hiện Tại (PV)<br>*(32-bit DINT)* | 2. Số Vòng Quay (Rev Count)<br>*(Xung / 8000)* | 3. RPM Test Motor<br>*(INT 16-bit)* | 4. RPM Float<br>*(REAL 32-bit)* | 5. TỐC ĐỘ THỰC TẾ LÔ (MPM)<br>*(Mét / Phút - REAL Float)* |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Trục 1: Thu T** | **`D520`** *(32-bit)* | **`D840`** *(32-bit)* | **`D550`** *(INT)* | **`D50`** *(REAL)* | **`D60`** *(MPM_T)* |
| **Trục 2: Kéo X1** | **`D522`** *(32-bit)* | **`D842`** *(32-bit)* | **`D552`** *(INT)* | **`D52`** *(REAL)* | **`D62`** *(MPM_X1)* |
| **Trục 3: Master X2** | **`D524`** *(32-bit)* | **`D844`** *(32-bit)* | **`D554`** *(INT)* | **`D54`** *(REAL)* | **`D64`** *(MPM_X2)* & **`D10`** *(Current_Line)* |
| **Trục 4: Ghép Ms** | **`D526`** *(32-bit)* | **`D846`** *(32-bit)* | **`D556`** *(INT)* | **`D56`** *(REAL)* | **`D66`** *(MPM_Ms)* |
| **Trục Phụ: Dầu S** | *(Analog Feedback)* | *(Không Encoder)* | — | **`D58`** *(REAL)* | **`D68`** *(MPM_S)* |

---

## 📌 PHẦN 4: DANH SÁCH DÁN VÀO WATCH WINDOW (GX WORKS2)

*Trong GX Works2: Mở tab **Watch 1** (ở cửa sổ bên dưới), copy danh sách dưới đây dán vào:*

```text
D520  (DINT: Xung tức thời Trục Thu T)
D840  (DINT: Số vòng quay Trục Thu T)
D550  (INT:  Tốc độ RPM Trục Thu T - Để test Jog)
D50   (REAL: Tốc độ RPM Trục Thu T - Float)
D60   (REAL: VẬN TỐC DÂY THU T - MPM)

D522  (DINT: Xung tức thời Trục Kéo X1)
D842  (DINT: Số vòng quay Trục Kéo X1)
D552  (INT:  Tốc độ RPM Trục Kéo X1 - Để test Jog)
D52   (REAL: Tốc độ RPM Trục Kéo X1 - Float)
D62   (REAL: VẬN TỐC DÂY KÉO X1 - MPM)

D524  (DINT: Xung tức thời Trục Master X2)
D844  (DINT: Số vòng quay Trục Master X2)
D554  (INT:  Tốc độ RPM Trục Master X2 - Để test Jog)
D54   (REAL: Tốc độ RPM Trục Master X2 - Float)
D64   (REAL: VẬN TỐC DÂY MASTER X2 - MPM)
D18   (REAL: LỆNH TỐC ĐỘ SAU RAMP - MPM)
D10   (REAL: TỐC ĐỘ DÂY CHUYỀN THỰC TẾ - MPM)

D526  (DINT: Xung tức thời Trục Ghép Ms)
D846  (DINT: Số vòng quay Trục Ghép Ms)
D556  (INT:  Tốc độ RPM Trục Ghép Ms - Để test Jog)
D56   (REAL: Tốc độ RPM Trục Ghép Ms - Float)
D66   (REAL: VẬN TỐC DÂY GHÉP MS - MPM)

D58   (REAL: Tốc độ RPM Trục Dầu S)
D68   (REAL: VẬN TỐC DÂY DẦU S - MPM)
```

---

## 📌 PHẦN 5: QUY TRÌNH 3 BƯỚC TEST THỰC CHIẾN

```
   [ BƯỚC 1: SOI ĐÈN LED A/B ] ──► [ BƯỚC 2: XOAY TAY TEST CHIỀU & VÒNG ]
                                                    │
                                     [ BƯỚC 3: TEST CHẠY JOG & KIỂM TRA MPM ]
```

### 🔹 BƯỚC 1: KIỂM TRA ĐÈN BÁO TRÊN MẶT MODULE QD62D
1. **Đèn `RUN`:** Sáng xanh lá liên tục (Module đã nhận diện bình thường).
2. **Đèn `ERR`:** Tắt hoàn toàn.
3. **Đèn `A` & `B`:** Dùng tay lắc nhẹ trục motor, đèn A và B phải **nhấp nháy xen kẽ nhau**. *(Không cần quan tâm đèn FUNC nữa)*.

### 🔹 BƯỚC 2: TEST XOAY TAY - KIỂM TRA CHIỀU & BỘ ĐẾM VÒNG
*Chỉ thực hiện khi Servo đang OFF (xoay tự do bằng tay).*
1. Dùng tay quay trục máy theo **chiều tiến bình thường**:
   * Giá trị `D520 / D522 / D524 / D526` phải **TĂNG SỐ DƯƠNG**.
   * Nếu xung đếm âm: Đảo 2 dây tín hiệu Pha A và Pha B trên giắc cắm.
2. Quay tròn 1 vòng ($360^\circ$):
   * Xung tăng thêm đúng **$8000\text{ xung}$**.
   * Số vòng `D840 / D842 / D844 / D846` tự động tăng **$+1$ vòng**.

### 🔹 BƯỚC 3: TEST CHẠY ĐIỆN TỐC ĐỘ CHẬM (JOG TEST) VÀ ĐỐI CHIẾU MPM
1. Kích hoạt chạy Manual Test Mode (Section 16):
   * Kích bật bit Test: `M30` (Thu T), `M31` (Kéo X1), `M32` (Master X2), `M33` (Ghép Ms).
2. Quan sát tốc độ:
   * **RPM (`D50..D56`):** Tốc độ quay của motor tăng êm ái, dao động $< 0.5\%$.
   * **MPM (`D60..D68`):** Vận tốc màng trên quả lô hiển thị chính xác theo mét/phút.
   * Ví dụ: Khi Master X2 quay $80\text{ RPM}$, vận tốc dây trên quả lô $\phi 300.5\text{ mm}$ (tỷ số truyền 8:1) hiển thị:
     $$\text{MPM}_{X2} = \frac{80 \times 3.14159 \times 300.5}{1000 \times 8} \approx \mathbf{9.44\text{ m/phút}}$$
     $\rightarrow$ Ô `D64` và ô `D10` (Current_Line_MPM) đều hiển thị chuẩn $9.44\text{ m/p}$.

---

## 📌 PHẦN 6: GIAO DIỆN HMI WEINTEK HIỂN THỊ TỐC ĐỘ MPM

Giao diện giám sát tốc độ thực tế của máy ghép màng:

```
+---------------------------------------------------------------------------------------------------+
|  GIÁM SÁT TỐC ĐỘ MÁY GHÉP MÀNG (MPM)             | THỜI GIAN: 11:45:00     | TRẠNG THÁI: [RUNNING]|
+---------------------------------------------------------------------------------------------------+
|                                                                                                   |
|  [ TỐC ĐỘ DÂY CHUYỀN CHÍNH (D10 / D64) ] :  [   45.2 m/p ]   (Cài Đặt: 45.0 m/p)                  |
|                                                                                                   |
|  +-- [TRỤC 1: THU T] -------------+  +-- [TRỤC 2: KÉO X1] ------------+                           |
|  | Vận Tốc Dây:   [   45.5 m/p ]  |  | Vận Tốc Dây:   [   45.2 m/p ]  |                           |
|  | Tốc Độ Vòng:   [  152.0 rpm ]  |  | Tốc Độ Vòng:   [  383.0 rpm ]  |                           |
|  | Đường Kính Lô: [  318.0 mm  ]  |  | Đường Kính Lô: [  300.5 mm  ]  |                           |
|  | Số Vòng Quay:  [    125 vòng]  |  | Số Vòng Quay:  [    315 vòng]  |                           |
|  | Xung Hiện Tại: [ 1,000,000 p]  |  | Xung Hiện Tại: [ 2,520,000 p]  |                           |
|  +--------------------------------+  +--------------------------------+                           |
|                                                                                                   |
|  +-- [TRỤC 3: MASTER X2] ---------+  +-- [TRỤC 4: GHÉP MS] -----------+                           |
|  | Vận Tốc Dây:   [   45.2 m/p ]  |  | Vận Tốc Dây:   [   45.2 m/p ]  |                           |
|  | Tốc Độ Vòng:   [  383.0 rpm ]  |  | Tốc Độ Vòng:   [  719.0 rpm ]  |                           |
|  | Đường Kính Lô: [  300.5 mm  ]  |  | Đường Kính Lô: [  200.0 mm  ]  |                           |
|  | Số Vòng Quay:  [    315 vòng]  |  | Số Vòng Quay:  [    592 vòng]  |                           |
|  | Xung Hiện Tại: [ 2,520,000 p]  |  | Xung Hiện Tại: [ 4,736,000 p]  |                           |
|  +--------------------------------+  +--------------------------------+                           |
|                                                                                                   |
+---------------------------------------------------------------------------------------------------+
```
