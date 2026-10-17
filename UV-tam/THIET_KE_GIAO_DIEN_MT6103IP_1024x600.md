# THIẾT KẾ GIAO DIỆN HMI WEINTEK MT6103iP (10.1 INCH - 1024x600)
## HỆ THỐNG ĐIỀU KHIỂN SẤY ĐÈN UV CÔNG NGHIỆP (MITSUBISHI FX2N)
### PHONG CÁCH INDUSTRIAL DARK CYBER-GLASS • ĐỘ NÉT CAO • TỐI ƯU THAO TÁC CẢM ỨNG

---

## 1. THÔNG SỐ PHẦN CỨNG HMI WEINTEK MT6103iP

* **Kích thước màn hình:** 10.1 inch TFT LCD Widescreen (Tỉ lệ 16:9).
* **Độ phân giải hiển thị:** **1024 × 600 pixels**.
* **Màu sắc:** 16.7 triệu màu, độ sáng cao $300\text{ cd/m}^2$, góc nhìn rộng.
* **Cổng giao tiếp:**
  - **COM1 (DB9 Cái):** RS-485 2-dây / RS-485 4-dây / RS-422.
  - **COM2 (DB9 Cái):** RS-232.
  - **USB Host:** Cắm chuột hoặc USB lưu Data Log.
  - **Micro USB:** Nạp chương trình từ máy tính.

### Sơ đồ bấm cáp kết nối HMI MT6103iP (COM1 RS-422) với CPU FX2N (Cổng tròn Mini-DIN 8 Chân)

| Chân HMI MT6103iP (Đầu DB9 Đực - COM1 RS-422) | Tín hiệu | Chân PLC FX2N (Đầu tròn Mini-DIN 8 chân) | Tín hiệu FX2N |
| :---: | :---: | :---: | :---: |
| **Chân 1 (Rx-)** | Nhận tín hiệu (-) | **Chân 4 (TXD-)** | Phát dữ liệu (-) |
| **Chân 2 (Rx+)** | Nhận tín hiệu (+) | **Chân 7 (TXD+)** | Phát dữ liệu (+) |
| **Chân 3 (Tx-)** | Phát tín hiệu (-) | **Chân 1 (RXD-)** | Nhận dữ liệu (-) |
| **Chân 4 (Tx+)** | Phát tín hiệu (+) | **Chân 2 (RXD+)** | Nhận dữ liệu (+) |
| **Chân 5 (GND)** | Nối đất mass | **Chân 3 (GND)** | 0V Signal Ground |

*(Nếu PLC gắn thêm module mở rộng RS-232 `FX2N-232-BD`, chỉ cần dùng cổng COM2 của HMI: Chân 6 RxD $\rightarrow$ TxD PLC, Chân 9 TxD $\rightarrow$ RxD PLC, Chân 5 GND $\rightarrow$ GND).*

---

## 2. CẤU HÌNH DỰ ÁN TRONG WEINTEK EASYBUILDER PRO

1. Khởi động **EasyBuilder Pro**:
   - Chọn **New Project**.
   - Model HMI: Chọn **`MT6103iP`** (hoặc `MT8102iP` / `iP Series` - Resolution: **`1024 x 600`**).
2. Vào tab **Home** $\rightarrow$ Click **System Parameters** (hoặc nhấn `Ctrl + P`):
   - Trong tab **Device**, bấm **New Device/Server...**:
     * **Device Name:** Nhập chính xác là **`FX2N_UV`** *(Bắt buộc trùng khớp để ăn khớp với file `hmi.csv`)*.
     * **Device Type:** Chọn **`MITSUBISHI FX0n/FX2n`**.
     * **Interface:** Chọn `RS-485 4W` (hoặc `RS-422` nếu cắm cổng tròn CPU).
     * **COM Port:** Chọn `COM1 (1024x600)`.
     * **Baud rate:** `9600`, Data bit: `7`, Parity: `Even`, Stop bit: `1` (Chuẩn cổng tròn FX2N).
3. Import danh mục biến:
   - Vào tab **Project** $\rightarrow$ Click **Address** (Address Tag Manager).
   - Chọn tab **User-defined Tags** $\rightarrow$ Bấm nút **Import...**
   - Trỏ tới file: [hmi.csv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/hmi.csv).
   - Hệ thống tự động nạp toàn bộ 78 Tags gồm các chân `X`, `Y`, `M`, `T` và các thanh ghi trạng thái mới `D100..D105`.

---

## 3. Ý TƯỞNG THIẾT KẾ GIAO DIỆN HIỆN ĐẠI (AESTHETIC DARK MODE)

* **Bảng màu nhận diện thương hiệu công nghiệp cao cấp:**
  - Nền toàn trang (Background): Xanh than thẫm `#0F172A` (Slate 900), tạo chiều sâu không gian phòng máy.
  - Khung module (Card Panels): Bo tròn góc 12px, màu `#1E293B` (Slate 800), viền phát sáng vi mô `#334155`.
  - Màu sắc trạng thái bóng đèn UV:
    * ⚪ **Tắt hoàn toàn:** Xám tro `#475569`.
    * 🟡 **Nấc 80W (Mồi / Standby):** Vàng mật ong ấm `#F59E0B` (Amber Glow).
    * 🟠 **Nấc 120W (Tiêu chuẩn):** Cam nhiệt rực lửa `#EA580C` (Flame Orange).
    * 🟣 **Nấc 160W (Turbo cực đại):** Tím huỳnh quang UV Neon `#9333EA` (Ultraviolet Glow).
  - Tín hiệu an toàn: Xanh ngọc lục bảo `#10B981` (Emerald).
  - Tín hiệu sự cố nguy hiểm: Đỏ phản quang `#EF4444` (Crimson Red).

---

## 4. CHI TIẾT BỐ CỤC 4 TRANG MÀN HÌNH (1024 × 600 PX)

```
0,0 ─────────────────────────────────────────────────────────────────────────── 1024,0
│  HEADER BAR (Cao 60px): Logo, Trạng thái máy (Text D100), Công suất Watt, Đồng hồ RTC │
├──────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  CONTENT AREA (Tọa độ Y: 60 đến 530 - Cao 470px):                                    │
│  - Window 10: VẬN HÀNH TRUNG TÂM (Buồng sấy mô phỏng, Nút Bật/Tắt, Chọn nấc sấy)    │
│  - Window 20: GIÁM SÁT BUỒNG CHIẾU & PHẦN CỨNG I/O (Bảng LED 24 IN / 24 OUT)        │
│  - Window 30: TRANG BÁO ĐỘNG & LỊCH SỬ SỰ CỐ (Bảng giải mã 9 mã lỗi E01..E09)        │
│  - Window 40: THAM SỐ CẤU HÌNH & BẢO TRÌ (Timer sấy nóng, After-Cooling, Test tay)   │
│                                                                                      │
├──────────────────────────────────────────────────────────────────────────────────────┤
│  NAVIGATION BAR (Cao 70px - Tọa độ Y: 530 đến 600):                                  │
│  [ F1: VẬN HÀNH ]    [ F2: BUỒNG SẤY & I/O ]    [ F3: BÁO ĐỘNG ]    [ F4: CÀI ĐẶT ]  │
0,600 ───────────────────────────────────────────────────────────────────────── 1024,600
```

---

### 🖥 CỬA SỔ 10: VẬN HÀNH CHÍNH (MAIN OPERATION MONITOR)

Tọa độ: `X: 0, Y: 60, Width: 1024, Height: 470`.

```
┌───────────────────────────────────────┬──────────────────────────────────────────────┐
│  MÔ PHỎNG BUỒNG SẤY UV (GRAPHIC)      │  BẢNG ĐIỀU KHIỂN & CHẾ ĐỘ CÔNG SUẤT          │
│                                       │                                              │
│    ┌──────────────────────────────┐   │  [ ▶ BẬT ĐÈN UV ]        [ ⏹ TẮT ĐÈN UV ]    │
│    │  VAN XẢ 1          VAN XẢ 2  │   │    (X020 - Xanh lá)          (X021 - Đỏ)     │
│    │   [Y005]            [Y006]   │   │                                              │
│    │     ▲                 ▲      │   │  NẤC CÔNG SUẤT SẤY:                          │
│    │  ══════════════════════════  │   │  ┌────────────┬─────────────┬─────────────┐  │
│    │        BÓNG ĐÈN UV           │   │  │ ( ) 80W    │ (●) 120W    │ ( ) 160W    │  │
│    │   ░░░░░░░░░░░░░░░░░░░░░░░░   │   │  │  Standby   │  Tiêu chuẩn │  Cực đại    │  │
│    │     [ ĐANG SÁNG 120W ]       │   │  └────────────┴─────────────┴─────────────┘  │
│    │  ══════════════════════════  │   │                                              │
│    │       CỬA CHẬP SHUTTER       │   │  THỜI GIAN LÀM MÁT (AFTER-COOL 180S):        │
│    │       [ 🟢 ĐÃ MỞ HẾT ]       │   │  ┌────────────────────────────────────────┐  │
│    │          (X012/X013)         │   │  │  ████████████░░░░░░░░   115 GIÂY (D105)│  │
│    └──────────────────────────────┘   │  └────────────────────────────────────────┘  │
│                                       │                                              │
│  GIÁM SÁT NHIỆT VÀ KHÍ ĐỘNG HỌC:      │  CỤM GIẢI TRỪ SỰ CỐ:                         │
│  - Áp suất gió: [ 🟢 ĐỦ ÁP (X010) ]   │  [ 🔔 TẮT CÒI LỖI ]      [ 🔄 RESET HỆ THỐNG]│
│  - Nước Chiller:[ 🟢 ỔN ĐỊNH (X016) ] │    (X022 - Vàng)             (X023 - Xanh)   │
│  - Cửa buồng:   [ 🟢 AN TOÀN (X004) ] │                                              │
└───────────────────────────────────────┴──────────────────────────────────────────────┘
```

#### Danh sách đối tượng đồ họa trên Window 10:

1. **Header Bar (Khung tiêu đề trên cùng):**
   - **Tọa độ:** `X: 0, Y: 0, W: 1024, H: 60`.
   - **Text Tiêu đề:** *"HỆ THỐNG SẤY ĐÈN UV CÔNG NGHIỆP - FX2N ST"*, Font Arial Bold 22pt, Màu Trắng.
   - **Multi-State Text (Trạng thái máy):** Đọc địa chỉ `D100` (Tag: `HMI_MACHINE_STATE`).
     * State 0: *"HỆ THỐNG DỪNG (OFF)"* - Màu xám tro `#94A3B8`.
     * State 1: *"Ủ NHIỆT 80W (WARM-UP)"* - Màu vàng `#FBBF24`.
     * State 2: *"SẴN SÀNG SẤY (STANDBY)"* - Màu xanh ngọc `#34D399`.
     * State 3: *"SẤY TIÊU CHUẨN (120W)"* - Màu cam sáng `#FB923C`.
     * State 4: *"SẤY CỰC ĐẠI (160W TURBO)"* - Màu tím Neon `#C084FC`.
     * State 5: *"ĐANG GIẢI NHIỆT (AFTER-COOL)"* - Màu xanh dương `#60A5FA`.
     * State 6: *"DỪNG SỰ CỐ (ALARM FAULT)"* - Màu đỏ nhấp nháy `#F87171`.
   - **Đồng hồ RTC thời gian thực:** Hiển thị ngày giờ thực tế từ HMI.

2. **Panel Mô phỏng Buồng sấy (Graphic Simulation Panel):**
   - **Tọa độ:** `X: 20, Y: 75, W: 480, H: 440`.
   - **Bóng đèn UV động (Word Lamp):** Đọc biến nội bộ `LW-10` (tính toán từ Macro theo công suất Watt):
     * State 0 (OFF): Ống thủy tinh màu xám tối.
     * State 1 (80W): Phát sáng vầng hào quang vàng ấm.
     * State 2 (120W): Phát sáng vầng hào quang cam rực lửa.
     * State 3 (160W): Phát sáng tia cực tím UV huỳnh quang tím rực rỡ kèm animation nhấp nháy.
   - **Cánh cửa chập Shutter (Bit Lamp):** Đọc Tag `SS_SHUTTER_OPENED` (`X012`) và `SS_SHUTTER_CLOSED` (`X013`):
     * Khi Shutter mở (`Y007 = 1` & `X012 = 1`): Cửa tách sang hai bên lộ buồng chiếu, chữ xanh *"SHUTTER OPEN"*.
     * Khi Shutter đóng: Cửa kim loại chắn kín giữa buồng, chữ cam *"SHUTTER CLOSED"*.
   - **Van xả khí Damper 1 & Damper 2 (Bit Lamp):**
     * Damper 1 (`Y005`): Icon quạt van khí đổi sang màu xanh sáng khi `X014 = 1`.
     * Damper 2 (`Y006`): Icon quạt van khí đổi sang màu xanh sáng khi `X015 = 1`.

3. **Panel Bảng điều khiển & Thao tác (Control Panel):**
   - **Tọa độ:** `X: 520, Y: 75, W: 484, H: 440`.
   - **Nút BẬT ĐÈN (Bit Switch - Momentary):**
     * Gán địa chỉ: `X020` (Tag: `BTN_UV_ON`).
     * Kích thước: `W: 220, H: 65`. Màu xanh lá `#10B981`, bo góc 10px, Font Bold 18pt: *"▶ BẬT ĐÈN UV"*.
   - **Nút TẮT ĐÈN (Bit Switch - Momentary):**
     * Gán địa chỉ: `X021` (Tag: `BTN_UV_OFF`).
     * Kích thước: `W: 220, H: 65`. Màu đỏ tươi `#EF4444`, bo góc 10px, Font Bold 18pt: *"⏹ TẮT ĐÈN UV"*.
   - **Cụm chọn công suất 3 nấc (Radio Button / Bit Switch):**
     * Nấc 80W: Kích Tag `SW_LOCK_80W` (`X027`).
     * Nấc 120W: Nhả `X027` và nhả `X024`.
     * Nấc 160W: Kích Tag `SW_POWER_160W` (`X024`).
   - **Thanh Progress Bar đếm lùi After-Cooling:**
     * Đọc thanh ghi: `D105` (Tag: `HMI_REMAINING_COOL_SEC`).
     * Thang đo: `0 đến 180 giây`.
     * Hiển thị số giây còn lại màu xanh Cyan: *"180s ... 0s"*. Khi đang đếm lùi, thanh giảm dần và hiển thị cảnh báo *"KHÔNG NGẮT NGUỒN ĐIỆN - ĐANG LÀM NGUỘI BÓNG"*.
   - **Nút Tắt Còi (Bit Switch):** Gán Tag `BTN_BUZZER_STOP` (`X022`), màu vàng hổ phách.
   - **Nút Reset Lỗi (Bit Switch):** Gán Tag `BTN_RESET_ALARM` (`X023`), màu xanh dương.

---

### 🖥 CỬA SỔ 20: GIÁM SÁT BUỒNG SẤY & TRẠNG THÁI I/O (DIAGNOSTICS)

Tọa độ: `X: 0, Y: 60, Width: 1024, Height: 470`.

Màn hình này mô phỏng toàn bộ **Bàn đấu dây PLC ảo** gồm 24 ngõ vào số (X) và 24 ngõ ra số (Y) giúp thợ bảo trì kiểm tra nhanh tình trạng dây dẫn và tiếp điểm rơ-le mà không cần mở tủ điện:

* **Cột trái (Inputs X000 ~ X031):**
  - Bảng 16 đèn LED tròn xanh lá kèm nhãn tên tiếng Việt:
    * `X000`: Quá tải quạt hút (Thermal Overload).
    * `X001`: Sụt áp đèn UV.
    * `X002`: Quá áp đèn UV.
    * `X003`: Nút dừng khẩn cấp E-Stop.
    * `X004`: Cửa tủ điện nguồn.
    * `X005`: Cửa nạp phôi buồng sấy.
    * `X006`: Tín hiệu máy chính dây chuyền chạy.
    * `X010`: Áp suất gió buồng sấy.
    * `X011`: Limit switch buồng UV.
    * `X012`: Shutter mở / `X013`: Shutter đóng.
    * `X014`: Buồng vị trí 1 / `X015`: Buồng vị trí 2.
    * `X016`: Cảm biến dòng chảy nước làm mát (Flow Switch).
    * `X030`: Phản hồi Chiller chạy / `X031`: Báo lỗi Chiller.
* **Cột phải (Outputs Y000 ~ Y030):**
  - Bảng 16 đèn LED tròn vàng/cam kèm nhãn tên:
    * `Y000`: Đèn lỗi tổng hợp / `Y001`: Còi báo động.
    * `Y002`: Đèn 80W / `Y003`: Đèn 120W / `Y004`: Đèn 160W.
    * `Y005`: Damper 1 / `Y006`: Damper 2 / `Y007`: Solenoid Shutter.
    * `Y010`: Quạt hút chính / `Y011`: Quạt cấp 1 / `Y012`: Quạt cấp 2.
    * `Y016`: Đèn Standby / `Y017`: Đèn Running.
    * `Y022`: Mở Shutter trễ / `Y023`: Đóng Shutter trễ / `Y030`: Kích chạy Chiller.

---

### 🖥 CỬA SỔ 30: TRANG BÁO ĐỘNG & CHẨN ĐOÁN SỰ CỐ (ALARM MONITOR)

Tọa độ: `X: 0, Y: 60, Width: 1024, Height: 470`.

Khi có bất kỳ lỗi nào, còi hú `Y001` kêu, banner đầu trang chuyển sang nền đỏ nhấp nháy, đồng thời trang này hiển thị thẻ báo lỗi trực quan:

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│  MÃ SỐ LỖI HIỆN TẠI (D101): [ E03 - MẤT ÁP SUẤT GIÓ BUỒNG SẤY UV ]                  │
├──────────────────────────────────────────────────────────────────────────────────────┤
│  DANH SÁCH 9 HẠNG MỤC AN TOÀN HỆ THỐNG:                                              │
│                                                                                      │
│  [🟢] E01: ĐIỆN ÁP BALLAST (X001/X002)     [🔴] E03: ÁP SUẤT GIÓ PHÒNG SẤY (X010)    │
│  [🟢] E02: RƠ LE NHIỆT QUẠT HÚT (X000)     [🟢] E04: LIÊN ĐỘNG BUỒNG CHIẾU (X011)   │
│  [🟢] E05: KẸT HÀNH TRÌNH SHUTTER (X012)   [🟢] E06: LƯU LƯỢNG NƯỚC LÀM MÁT (X016)   │
│  [🟢] E07: DỪNG KHẨN CẤP E-STOP (X003)     [🟢] E08: CỬA TỦ NGUỒN CAO ÁP (X004)      │
│  [🟢] E09: SỰ CỐ MÁY LẠNH CHILLER (X031)                                             │
├──────────────────────────────────────────────────────────────────────────────────────┤
│  HƯỚNG DẪN XỬ LÝ SỰ CỐ:                                                              │
│  1. Kiểm tra ống dẫn gió quạt hút có bị gập hoặc tắc lưới lọc bụi không.             │
│  2. Kiểm tra tiếp điểm công tắc áp suất vi sai (Air Pressure Switch X010).           │
│  3. Sau khi xử lý xong nguyên nhân, nhấn nút [ 🔄 RESET HỆ THỐNG ] để khôi phục.     │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

#### Thiết lập kỹ thuật cho Window 30:
1. **Numeric Display lớn:** Đọc địa chỉ `D101` (Tag: `HMI_ACTIVE_ALARM_CODE`).
2. **Dynamic Alarm Text:** Đọc chuỗi ký tự từ `LW-300` (được cập nhật tự động qua Macro C [weintek_macro_status.c](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/UV-tam/FX_2N_UV_ST/HMI_Mapping/weintek_macro_status.c)).
3. **9 Đèn Bit Lamp cảnh báo:** Đọc trực tiếp các cờ lỗi `M0`, `M10`, `M20`, `M30`, `M40`, `M60`, `M120`, `M130`, `M51`. Khi lỗi nào tác động, đèn tương ứng sẽ đổi sang màu đỏ rực rỡ và nhấp nháy!

---

### 🖥 CỬA SỔ 40: THAM SỐ CẤU HÌNH & BẢO TRÌ (SETTINGS & SERVICE)

Tọa độ: `X: 0, Y: 60, Width: 1024, Height: 470`.

Cho phép kỹ sư nhà máy cài đặt thời gian và thực hiện kích tay từng thiết bị khi bảo dưỡng máy:

1. **Bảng cài đặt thông số thời gian (Numeric Input):**
   - Thời gian sấy nóng ban đầu (Warm-up): `30 giây` (Mặc định).
   - Thời gian duy trì quạt khi mồi: `90 giây`.
   - Thời gian làm mát cưỡng bức sau tắt đèn (After-Cooling): `180 giây` (Khuyến nghị không đặt dưới 120s để tránh làm hỏng bóng).
   - Thời gian lọc nhiễu các cảm biến áp suất / dòng chảy: `5 ~ 15 giây`.
2. **Cụm nút Test thủ công (Manual Jog Mode):**
   - Chỉ cho phép bấm khi đèn UV đang tắt (`M520 = 0`):
     * Nút [ Test Quạt Hút Y010 ]: Nhấn giữ để kích chạy quạt kiểm tra chiều quay.
     * Nút [ Test Van Shutter Y007 ]: Kích đóng/mở kiểm tra xy-lanh khí nén.
     * Nút [ Test Damper 1 Y005 ] & [ Test Damper 2 Y006 ]: Thử van khí buồng sấy.
     * Nút [ Test Máy lạnh Chiller Y030 ]: Bật bơm tuần hoàn kiểm tra áp lực nước.

---

## 5. HƯỚNG DẪN BIÊN DỊCH VÀ NẠP XUỐNG HMI MT6103iP

1. Trong phần mềm **EasyBuilder Pro**, nhấn phím **`F7`** (hoặc vào menu **Project** $\rightarrow$ **Compile**).
2. Kiểm tra cửa sổ Output thông báo: **`Compilation succeeded (0 errors)`**.
3. Cắm cáp Micro-USB hoặc dây mạng LAN từ máy tính vào cổng của màn hình MT6103iP.
4. Nhấn phím **`F8`** (hoặc chọn **Project** $\rightarrow$ **Download...**):
   - Chọn chuẩn kết nối: `USB` hoặc nhập địa chỉ `IP` của HMI (ví dụ: `192.168.1.100`).
   - Bấm nút **Download**.
5. Màn hình HMI sẽ khởi động lại và giao diện điều khiển đèn UV hiện đại 10.1 inch sẽ xuất hiện ngay lập tức!
