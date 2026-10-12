# 🧭 HƯỚNG DẪN CẤU HÌNH & ĐẤU NỐI CHÂN CHỐT PHA Z (1 XUNG/VÒNG) CHO 5 TRỤC
## DỰ ÁN: MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - PLC MITSUBISHI Q02U

---

## 📌 PHẦN 1: TỔNG QUAN NGUYÊN LÝ CHỐT PHẦN CỨNG (LATCH COUNTER FUNCTION)

1. **Tại sao phải dùng chân chốt phần cứng của QD62/QD62D?**
   - Pha Z của động cơ Servo chỉ xuất hiện đúng **1 lần trong mỗi vòng quay** với độ rộng cực ngắn ($30\,\mu\text{s} \sim 100\,\mu\text{s}$ ở tốc độ cao).
   - Module ngõ vào thường (QX40) có bộ lọc trễ $> 1\text{ms}$ nên **không thể bắt kịp Pha Z**.
   - Module **QD62 / QD62D** tích hợp mạch ngõ vào cao tốc ($5\,\mu\text{s}$) và tính năng **Latch Counter Function**:
     Khi xung Pha Z kích vào chân **`FUNC`**, module phần cứng **tự động chốt tức thì** giá trị xung hiện tại `PV` vào thanh ghi đệm Latch Buffer Memory mà không cần đợi chu kỳ quét Scan Time của CPU!

2. **Cơ chế an toàn kép (Dual Redundancy) trong chương trình:**
   - Khi có tín hiệu Pha Z: CPU đọc giá trị chốt, tăng số vòng quay chính thức `Rev_Count_Z`, và tính số xung thực tế giữa 2 vòng `Real_PPR`.
   - Nếu chưa đấu dây Pha Z: Chương trình tự động dự phòng đếm theo phép chia `Curr_Pulse / 8000` để đảm bảo máy luôn hoạt động liên tục.

---

## 📌 PHẦN 2: BẢNG ÁNH XẠ CHÂN CHỐT VÀ ĐỊA CHỈ PLC CHO 5 TRỤC

| Trục Cơ Cấu | Vị Trí Module | Kênh | Chân Chốt Trên Giắc 40-Pin | Chân Chung | Buffer Chọn Latch | Cờ Bật Latch (Y) | Buffer Giá Trị Chốt (32-bit) | Thanh Ghi Xung Chốt Pha Z | Thanh Ghi Số Vòng Pha Z |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Trục 1: Thu T** | Slot 2 (H20) - QD62D #1 | **CH1** | **B14** (1FUNC 5V) / **B15** (24V) | **A15** (CTRLCOM) | U2\G9 := 1 | **Y26 := FALSE** | **U2\G12** | **Latched_Pulse_T** (D560) | **Rev_Count_T** (D840) |
| **Trục 2: Kéo X1** | Slot 2 (H20) - QD62D #1 | **CH2** | **B07** (2FUNC 5V) / **B08** (24V) | **A08** (CTRLCOM) | U2\G41 := 1 | **Y2E := FALSE** | **U2\G44** | **Latched_Pulse_X1** (D562) | **Rev_Count_X1** (D842) |
| **Trục 3: Master X2** | Slot 3 (H30) - QD62D #2 | **CH1** | **B14** (1FUNC 5V) / **B15** (24V) | **A15** (CTRLCOM) | U3\G9 := 1 | **Y36 := FALSE** | **U3\G12** | **Latched_Pulse_X2** (D564) | **Rev_Count_X2** (D844) |
| **Trục 4: Ghép Ms** | Slot 3 (H30) - QD62D #2 | **CH2** | **B07** (2FUNC 5V) / **B08** (24V) | **A08** (CTRLCOM) | U3\G41 := 1 | **Y3E := FALSE** | **U3\G44** | **Latched_Pulse_Ms** (D566) | **Rev_Count_Ms** (D846) |
| **Trục 5: Lô Dầu S** | Slot 1 (H10) - QD62 | **CH1** | **B14** (1FUNC 5V) / **B15** (24V) | **A15** (CTRLCOM) | U1\G9 := 1 | **Y16 := FALSE** | **U1\G12** | **Latched_Pulse_S** (D568) | **Rev_Count_S** (D852) |

> ⚠️ **TẠI SAO BỊ HIỆN TƯỢNG "CHỐT ĐƯỢC CÓ 1 LẦN" RỒI ĐỨNG IM?**
> - Theo tài liệu chính hãng Mitsubishi (*Manual SH-080036 Section 6.3 - Latch Counter Function*):
>   * Các cờ **`Y16, Y26, Y2E, Y36, Y3E`** là **lệnh chốt bằng phần mềm (Software trigger)**.
>   * Nếu trong code ép `Yxx := TRUE` liên tục mỗi scan: Ngay lúc CPU khởi động, sườn lên của cờ Y sẽ khiến module chốt **đúng 1 lần duy nhất**, sau đó cờ bị giữ ở mức HIGH liên tục $\rightarrow$ **Module bị treo cứng ở trạng thái đã kích hoạt và chặn đứng toàn bộ xung phần cứng từ chân giắc `FUNC` (Pha Z)**!
>   * **Quy tắc chuẩn:** Khi dùng chân giắc ngoài `FUNC` để chốt Pha Z mỗi vòng quay, **TẤT CẢ CÁC CỜ `Yx6 / YxE` PHẢI ĐỂ `FALSE` (OFF)**! Khi đó, cứ mỗi vòng quay motor đưa 1 xung Pha Z vào chân `FUNC`, module sẽ tự động chốt xung tức thời và cập nhật thanh ghi đệm `G12 / G44` liên tục mà không bị nghẽn!

---

## 📌 PHẦN 3: SƠ ĐỒ ĐẤU DÂY PHA Z TỪ DRIVER SERVO SANG MODULE QD62/QD62D

Trên Driver Servo (Yaskawa Sigma-V / Sigma-7, Delta, v.v.), tín hiệu Pha Z từ giắc CN1 thường có 2 dạng ngõ ra:

### 🔹 Dạng 1: Ngõ ra Cực thu hở (Open Collector - OC) 24V hoặc NPN:
* Chân **`CTRLCOM`** (chân `A15` hoặc `A08` của QD62) $\rightarrow$ Đấu lên **`+24VDC`**.
* Chân Pha Z (Open Collector) của Driver $\rightarrow$ Đấu vào chân **`B15`** (1FUNC 24V) hoặc **`B08`** (2FUNC 24V).

### 🔹 Dạng 2: Ngõ ra Vi sai RS-422 (PZO và /PZO mức 5V):
Nếu lấy trực tiếp cặp vi sai Pha Z 5V từ Driver Yaskawa (chân PZO / /PZO):
* Chân **`CTRLCOM`** (chân `A15` hoặc `A08` của QD62D) $\rightarrow$ Đấu vào **`0V`** (GND 5V/24V).
* Chân **`PZO (+)`** của Driver $\rightarrow$ Đấu vào chân **`B14`** (1FUNC 5V) hoặc **`B07`** (2FUNC 5V).

```
   [ DRIVER SERVO CN1 ]                             [ GIẮC 40-PIN QD62 / QD62D ]
  
   +24VDC Nguồn Ngoài ────────────────────────────► Chân CTRLCOM (A15 cho CH1 / A08 cho CH2)
  
   Ngõ ra Pha Z (OC NPN) ─────────────────────────► Chân 1FUNC (B15 cho CH1) hoặc 2FUNC (B08 cho CH2)
```

---

## 📌 PHẦN 4: DANH SÁCH GIÁM SÁT ONLINE (WATCH TABLE GX WORKS2)

Copy danh sách này dán vào tab **Watch** trong GX Works2 để giám sát chốt Pha Z của cả 5 trục:

```text
D520  (DINT: Xung tức thời Trục Thu T)
D560  (DINT: Xung chốt tại thời điểm Pha Z Trục Thu T)
D840  (DINT: Số vòng quay Pha Z Trục Thu T)
D830  (DINT: Số xung/vòng thực tế đo được Trục Thu T)

D522  (DINT: Xung tức thời Trục Kéo X1)
D562  (DINT: Xung chốt tại thời điểm Pha Z Trục Kéo X1)
D842  (DINT: Số vòng quay Pha Z Trục Kéo X1)
D832  (DINT: Số xung/vòng thực tế đo được Trục Kéo X1)

D524  (DINT: Xung tức thời Trục Master X2)
D564  (DINT: Xung chốt tại thời điểm Pha Z Trục Master X2)
D844  (DINT: Số vòng quay Pha Z Trục Master X2)
D834  (DINT: Số xung/vòng thực tế đo được Trục Master X2)

D526  (DINT: Xung tức thời Trục Ghép Ms)
D566  (DINT: Xung chốt tại thời điểm Pha Z Trục Ghép Ms)
D846  (DINT: Số vòng quay Pha Z Trục Ghép Ms)
D836  (DINT: Số xung/vòng thực tế đo được Trục Ghép Ms)

D528  (DINT: Xung tức thời Trục Lô Dầu S)
D568  (DINT: Xung chốt tại thời điểm Pha Z Trục Lô Dầu S)
D852  (DINT: Số vòng quay Pha Z Trục Lô Dầu S)
D838  (DINT: Số xung/vòng thực tế đo được Trục Lô Dầu S)
```

---

## 📌 PHẦN 5: BƯỚC NẠP CHƯƠNG TRÌNH XUỐNG PLC

1. Mở GX Works2, copy nội dung mới trong [global_labels_paste.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/global_labels_paste.tsv) dán đè vào bảng **Global_Variables**.
2. Nhấn **F4 (Rebuild All)** để biên dịch toàn bộ.
3. Vào **Online $\rightarrow$ Write to PLC**, chọn cả **Parameter + Program**.
4. Gạt khóa CPU sang **STOP $\rightarrow$ RESET $\rightarrow$ RUN**.
5. Mở Watch Window kiểm tra: Khi xoay motor 1 vòng, ô `D840..D846, D852` sẽ tự động nhảy số vòng quay theo Pha Z!
