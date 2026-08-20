# HƯỚNG DẪN CẤU HÌNH QJ71C24N VÀ GIAO TIẾP MC PROTOCOL FORMAT 4 VỚI STM32

Tài liệu này hướng dẫn chi tiết cách cấu hình card truyền thông **Mitsubishi QJ71C24N (Cổng CH2 - RS422)** kết nối với vi điều khiển **STM32F401** để truyền nhận dữ liệu 2 chiều sử dụng giao thức công nghiệp **MC Protocol (Format 4)**.

---

## 1. 🔌 Sơ đồ đấu nối phần cứng (4-Wire Full-Duplex RS-422)

Module RS-422 (MAX490 / MAX3490 / SP3485) nối giữa **STM32F401** và cổng **CH2 của QJ71C24N**:

```
STM32F401 (USART1)          Module RS-422                Cầu đấu QJ71C24N CH2
------------------          -------------                --------------------
PA9 (TX)  --------------->  DI (Driver In) -> TX+ (A) -> RDA (Receive Data +)
                                           -> TX- (B) -> RDB (Receive Data -)
PA10 (RX) <---------------  RO (Rcvr Out)  <- RX+ (A) <- SDA (Send Data +)
                                           <- RX- (B) <- SDB (Send Data -)
GND       ----------------  GND            <---------->  SG  (Signal Ground)
```

> [!IMPORTANT]
> * Luôn nối chân **SG (Signal Ground)** giữa 2 thiết bị để cân bằng điện áp tham chiếu chống nhiễu công nghiệp.
> * Cặp tín hiệu vi sai: `RDA` / `RDB` là chân NHẬN của QJ71, `SDA` / `SDB` là chân PHÁT của QJ71.

---

## 2. ⚙️ Cài đặt Switch Parameter cho QJ71 trên GX Works2

Mở GX Works2 $\rightarrow$ **Parameter** $\rightarrow$ **PLC Parameter** $\rightarrow$ **I/O Assignment** $\rightarrow$ bấm nút **Switch Setting** tại vị trí gắn card QJ71:

| Switch No. | Giá trị HEX | Chức năng chi tiết |
| :--- | :---: | :--- |
| **Switch 1** (CH1 Setting) | `0000` | Cổng CH1 RS232 (để mặc định) |
| **Switch 2** (CH1 Protocol) | `0000` | Mặc định |
| **Switch 3** (CH2 Setting) | **`07E6`** | **Baudrate 9600 bps**, Data bit: **8**, Parity: **Even (Chẵn)**, Stop bit: **1**, Sum Check: **Enable** |
| **Switch 4** (CH2 Protocol) | **`0004`** | **MC Protocol (Format 4)** (Chế độ tự động giải mã phần cứng) |
| **Switch 5** (Station No) | **`0000`** | **Station No = 0** (Trạm chủ PLC) |

> [!TIP]
> * Nếu muốn chạy tốc độ **19200 bps**, cài **Switch 3 = `07E7`**.
> * Sau khi nạp Parameter xuống PLC, **bắt buộc phải TẮT và BẬT lại nguồn PLC (Power Cycle)** để module QJ71 nạp cấu hình Switch mới.

---

## 3. 📦 Chi tiết cấu trúc khung truyền MC Protocol Format 4

### A. Chiều 1: STM32 GHI dữ liệu lên PLC (Lệnh `WW` - Word Write)
* **Mục đích:** STM32 gửi khoảng cách Laser đã lọc trung bình động ghi vào thanh ghi `D900` của PLC.
* **Cấu trúc khung truyền STM32 gửi:**
```
[STX] + "00FFWW0D*0009000104E2" + [ETX] + "3E"
```
* **Ý nghĩa:**
  * `[STX]` = `0x02` (Bắt đầu khung).
  * `"00"`: Station No của QJ71.
  * `"FF"`: CPU chính trên rack PLC.
  * `"WW"`: Lệnh ghi Word (Word Write).
  * `"0"`: Thời gian chờ phản hồi (0ms).
  * `"D*"`: Loại thiết bị (Thanh ghi D).
  * `"000900"`: Địa chỉ bắt đầu ghi (D900).
  * `"01"`: Số lượng ô nhớ cần ghi (1 ô).
  * `"04E2"`: Giá trị dữ liệu dạng HEX ($1250\text{ mm} = \text{0x04E2}$).
  * `[ETX]` = `0x03` (Kết thúc nội dung).
  * `"3E"`: Mã Sum Check (tổng byte từ sau STX đến hết ETX).

---

### B. Chiều 2: STM32 ĐỌC dữ liệu từ PLC về (Lệnh `WR` - Word Read)
* **Mục đích:** STM32 đọc 2 thanh ghi `D910..D911` từ PLC (ví dụ: ngưỡng cảnh báo khoảng cách hoặc lệnh từ HMI).

#### 1. Khung STM32 gửi yêu cầu đọc:
```
[STX] + "00FFWR0D*00091002" + [ETX] + "56"
```
* `"WR"`: Lệnh đọc Word.
* `"000910"`: Bắt đầu đọc từ D910.
* `"02"`: Đọc 2 thanh ghi liên tiếp (`D910` và `D911`).

#### 2. Khung PLC QJ71 TỰ ĐỘNG PHẢN HỒI về cho STM32:
Khi lệnh đọc hợp lệ, module QJ71 sẽ tự động trả lời gói tin chuẩn Format 4:
```
[STX] + "00FF" + "0064" + "00C8" + [ETX] + "SumCheck"
```
* `[STX]` = `0x02`.
* `"00FF"`: Trạm 00, CPU FF.
* `"0064"`: Dữ liệu của `D910` = 100 dạng HEX.
* `"00C8"`: Dữ liệu của `D911` = 200 dạng HEX.
* `[ETX]` = `0x03`.
* `SumCheck`: 2 ký tự kiểm tra tổng byte do PLC tự tính toán.

---

## 4. 🔍 Bảng tra cứu lỗi truyền thông thường gặp (Troubleshooting)

| Hiện tượng | Nguyên nhân | Cách khắc phục |
| :--- | :--- | :--- |
| Đèn **ERR** trên QJ71 nhấp nháy | Sai mã Sum Check hoặc sai số trạm | Kiểm tra hàm tính SumCheck trên STM32, đảm bảo tính từ sau `STX` đến hết `ETX`. |
| Đèn **SD/RD** không sáng | Đấu ngược dây A/B hoặc lỏng dây | Đảo chéo cặp `RDA/RDB` với `TX+/TX-` và `SDA/SDB` với `RX+/RX-`. |
| PLC không nhận dữ liệu | Chưa Power Cycle sau khi cài Switch | Tắt hẳn CP nguồn PLC rồi bật lại. |
| STM32 không đọc được phản hồi | Baudrate hoặc Parity không khớp | Đảm bảo STM32 cấu hình: 9600 bps, 8 Data Bits, **Parity Even (Chẵn)**, 1 Stop Bit. |
