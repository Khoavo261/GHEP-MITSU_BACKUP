# HƯỚNG DẪN GHÉP NỐI NHIỀU BO (MULTI-NODE) QUA CAN-BUS - STM32F103C8T6

Hệ thống cho phép ghép nối **từ 2 đến 64 bo STM32F103 + Cảm biến VL53L1X** trên cùng một đường truyền **CAN-Bus 2 dây (CAN_H, CAN_L)** duy nhất về PLC / Máy tính / Bo Master.

---

## 1. NGUYÊN LÝ ĐI DÂY MẠNG CAN NHIỀU BO (DAISY-CHAIN BUS TOPOLOGY)

```text
 [Bo Master / PLC]                 [Bo Node #01]                 [Bo Node #02]                 [Bo Node #N]
+-----------------+               +---------------+             +---------------+             +---------------+
|  CAN Module     |               | STM32 + VL53  |             | STM32 + VL53  |             | STM32 + VL53  |
|  [Trở 120 Ohm]  |               | (BỎ TRỞ 120R) |             | (BỎ TRỞ 120R) |             | [Trở 120 Ohm] |
+--------+--------+               +-------+-------+             +-------+-------+             +-------+-------+
         | CAN_H                          |                             |                             |
========+================================+=============================+=============================+========= CAN_H
========+================================+=============================+=============================+========= CAN_L
         | CAN_L                          |                             |                             |
```

> [!CAUTION]
> **Quy tắc vàng về điện trở đầu cuối 120 Ohm:**
> * Toàn bộ tuyến dây CAN chỉ được gắn **đúng 2 điện trở 120 Ohm** ở **2 điểm đầu và cuối xa nhất của đường bus**.
> * Tất cả các bo nằm ở giữa **BẮT BUỘC PHẢI THÁO JUMPER / BỎ TRỞ 120 Ohm** trên module CAN (TJA1050 / SN65HVD230). Nếu bo nào cũng gắn trở 120R, điện trở tương đương của mạng sẽ tụt xuống quá thấp làm sụp áp tín hiệu CAN!
> * Đi dây theo dạng đường thẳng (Daisy-Chain), không rẽ nhánh hình sao (Star topology).

---

## 2. QUY TẮC PHÂN BỔ ĐỊNH DANH CAN ID (NODE ADDRESSING)

Mỗi bo STM32 được gán một `Node_ID` duy nhất (từ `1` đến `64`):

| Bo Mạch | Node ID | CAN ID Phát Dữ Liệu (TX) | CAN ID Nhận Lệnh Riêng (RX) | CAN ID Nhận Lệnh Chung (Broadcast) |
| :--- | :--- | :--- | :--- | :--- |
| **Bo số 1** | `1` | `0x181` | `0x201` | `0x200` |
| **Bo số 2** | `2` | `0x182` | `0x202` | `0x200` |
| **Bo số 3** | `3` | `0x183` | `0x203` | `0x200` |
| **Bo số 4** | `4` | `0x184` | `0x204` | `0x200` |
| **Bo số $N$** | $N$ | `0x180 + N` | `0x200 + N` | `0x200` |

---

## 3. CẤU TRÚC GÓI TIN CAN-BUS

### A. Gói dữ liệu từng bo phát lên mạng (Mỗi 50ms):
* **CAN ID:** `0x180 + Node_ID` (DLC: 8 Bytes)
* **Byte 0..1:** `Distance Filtered` (uint16_t, khoảng cách đã lọc số, mm)
* **Byte 2..3:** `Distance Raw` (uint16_t, khoảng cách thô, mm)
* **Byte 4:** `Status` (Bit 0=OK, Bit 1=<200mm, Bit 2=30..3000mm, Bit 3=Calib Done)
* **Byte 5:** `Error` (Mã lỗi từ cảm biến: 0=Bình thường)
* **Byte 6:** `Heartbeat` (Nhịp sống 0..255)
* **Byte 7:** `Calib Offset` (int8_t, độ lệch bù mm)

---

### B. Gói gửi Lệnh Calib & Cài đặt Node ID vào bo:

Bạn có thể gửi lệnh qua **ID riêng của bo (`0x200 + Node_ID`)** hoặc **ID chung (`0x200`)**:
* **DLC:** 4 Bytes
  * `Byte 0..1`: `Target` (uint16_t, khoảng cách mm hoặc Node ID mới)
  * `Byte 2`: `Command Code` (Mã lệnh)
  * `Byte 3`: `0x5A` (Mã kích hoạt thực thi)

#### Bảng mã lệnh (Command Codes):
1. **Lệnh `10` (hoặc `1`):** Hiệu chuẩn Offset phần mềm (Software Offset Calib).
   * Ví dụ: Gửi vào ID `0x201` với Data: `[0x8C, 0x00, 0x0A, 0x5A]` $\rightarrow$ Bo #01 tự lấy mốc chuẩn 140mm để Calib.
2. **Lệnh `20`:** Hiệu chuẩn Offset phần cứng ST API (Hardware Offset Calib).
3. **Lệnh `30`:** Hiệu chuẩn Crosstalk kính che (Xtalk Calib).
4. **Lệnh `99`:** **ĐỔI NODE ID MỚI TRỰC TIẾP QUA CAN-BUS VÀ LƯU FLASH**:
   * Ví dụ: Muốn đổi bo đang có ID thành Node #05:
     * Gửi vào ID `0x200` (Broadcast) hoặc ID hiện tại của bo.
     * Payload: `[0x05, 0x00, 0x63, 0x5A]` (`0x63` = 99, `0x05` = Node 5).
     * Bo sẽ tự cập nhật Node ID = 5, lưu vào Flash `0x0800FC00`, tự chuyển ID phát sang `0x185` và cập nhật tiêu đề OLED!

---

## 4. HIỂN THỊ TRÊN MÀN HÌNH OLED 0.96 INCH

Màn hình OLED của từng bo sẽ hiển thị trực quan Node ID để không bao giờ bị nhầm lẫn giữa các vị trí:
```text
+----------------------+
| NODE:#01   CAN:0x181 |  <-- Node ID & CAN ID phát
| DIST: 450 mm(RAW:452)|  <-- Khoảng cách sau lọc & thô
| OFS :   0 mm ERR: 0  |  <-- Offset Calib & Mã lỗi
| TX:12504    RX:12    |  <-- Số gói CAN đã phát & nhận
| TX_ERR:0   CMD:0x201 |  <-- Lỗi phát & ID nhận lệnh
| CALIB:OK    HB:504   |  <-- Trạng thái Calib & Heartbeat
+----------------------+
```
