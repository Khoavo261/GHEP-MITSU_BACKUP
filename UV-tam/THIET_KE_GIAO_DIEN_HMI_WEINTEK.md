# BẢN THIẾT KẾ GIAO DIỆN HMI WEINTEK (EASYBUILDER PRO)
## HỆ THỐNG SẤY ĐÈN UV - PLC MITSUBISHI FX2N (TÊN THIẾT BỊ: `FX2N_UV`)

---

## 1. HƯỚNG DẪN CẤU HÌNH & IMPORT TAG VÀO WEINTEK EASYBUILDER PRO

### Bước 1: Cấu hình thiết bị PLC trong EasyBuilder Pro
1. Mở phần mềm **EasyBuilder Pro** -> Chọn model màn hình HMI của bạn (ví dụ: `MT8071iE`, `MT8071iP`, `cMT series`...).
2. Vào tab **Home** -> Click **System Parameters** (hoặc `Ctrl + P`).
3. Trong tab **Device**, bấm **New Device/Server...**:
   * **Device name:** Đặt chính xác là: **`FX2N_UV`** *(Bắt buộc trùng khớp 100% với file tag CSV)*.
   * **PLC type:** Chọn **`MITSUBISHI FX0n/FX2n`** (hoặc `MITSUBISHI FX3U/FX3G/FX3S`).
   * **PLC I/F:** Chọn cổng kết nối thực tế (ví dụ: `RS-485 2W` hoặc `RS-422` hoặc `RS-232`).
   * **COM Settings:** `9600`, Data bit: `7`, Parity: `Even`, Stop bit: `1` (Thông số mặc định của cổng lập trình tròn MD8 Mitsubishi FX).
4. Bấm **OK** để lưu lại.

### Bước 2: Import file `hmi.csv` vào Address Tag Library
1. Trên thanh công cụ, vào tab **Project** -> Chọn **Address** (Address Tag Manager).
2. Tại cửa sổ **Address Tag Library**, chọn tab **User-defined Tags**.
3. Bấm nút **Import...** -> Trỏ tới file: **`D:\UV-tam\hmi.csv`**.
4. Toàn bộ 72 tags gồm các chân X, Y, M, T (kèm chú thích tiếng Việt rõ ràng) sẽ tự động nạp vào hệ thống. Khi vẽ đối tượng, bạn chỉ cần chọn tên Tag mà không cần nhớ số địa chỉ.

---

## 2. Ý TƯỞNG THIẾT KẾ GIAO DIỆN HIỆN ĐẠI (AESTHETIC INDUSTRIAL UI)

* **Phong cách chủ đạo:** **Modern Industrial Dark Mode** (Nền xám đậm `#1E293B`, khung bo góc viền kim loại `#334155`), chống lóa mắt cho công nhân trong xưởng và làm nổi bật các trạng thái đèn màu.
* **Hệ thống màu sắc nhận diện trực quan:**
  * ⚪ **Hệ thống Tắt / Chờ:** Xám tro `#64748B`.
  * 🟡 **Nấc công suất 80W (Mồi / Standby):** Màu vàng hổ phách dịu `#F59E0B` (Amber Glow).
  * 🟠 **Nấc công suất 120W (Tiêu chuẩn):** Màu cam lửa `#F97316` (Warm Orange).
  * 🟣 **Nấc công suất 160W (Turbo Cực đại):** Màu tím tia UV huỳnh quang `#A855F7` (Deep UV Purple Glow).
  * 🟢 **Bình thường / Chạy tốt / Shutter Mở:** Xanh ngọc `#10B981`.
  * 🔴 **Cảnh báo lỗi / Dừng khẩn / Shutter Đóng:** Đỏ tươi `#EF4444`.

---

## 3. BỐ CỤC CHI TIẾT CÁC TRANG MÀN HÌNH (SCREEN LAYOUTS)

### 🖥 MÀN HÌNH 10: VẬN HÀNH CHÍNH (MAIN OPERATION MONITOR)

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│  [LOGO]  HỆ THỐNG SẤY ĐÈN UV - DÂY CHUYỀN SẢN XUẤT           19:45:00  11/10/2026      │
│  TRẠNG THÁI: [🟢 SẴN SÀNG - STANDBY]   CÔNG SUẤT: [ 120W ]   CHILLER: [ ❄️ CHẠY ]      │
├──────────────────────────────────────┬─────────────────────────────────────────────────┤
│    KHỐI MÔ PHỎNG BUỒNG SẤY (GRAPHIC) │        BẢNG ĐIỀU KHIỂN & CHỌN CÔNG SUẤT         │
│                                      │                                                 │
│       ┌──────────────────────┐       │  [ ▶ BẬT ĐÈN UV ]        [ ⏹ TẮT ĐÈN UV ]       │
│       │  VAN XẢ 1   VAN XẢ 2 │       │    Tag: BTN_UV_ON             Tag: BTN_UV_OFF   │
│       │   [Y005]     [Y006]  │       │                                                 │
│       │     ▲          ▲     │       │  CHẾ ĐỘ CÔNG SUẤT ĐÈN:                          │
│       │ ════════════════════ │       │  ┌──────────────┬──────────────┬──────────────┐ │
│       │      BÓNG ĐÈN UV     │       │  │ ( ) 80W      │ (●) 120W     │ ( ) 160W     │ │
│       │  ░░░░░░░░░░░░░░░░░░░ │       │  │ (Standby)    │ (Tiêu chuẩn) │ (Cực đại)    │ │
│       │    [ ĐANG SÁNG 120W ]│       │  └──────────────┴──────────────┴──────────────┘ │
│       │ ════════════════════ │       │                                                 │
│       │  CỬA CHẬP SHUTTER    │       │  [ 🔔 TẮT CÒI LỖI ]      [ 🔄 RESET HỆ THỐNG ] │
│       │   [ 🟢 ĐÃ MỞ HẾT ]   │       │    Tag: BTN_BUZZER_STOP       Tag: BTN_RESET    │
│       └──────────────────────┘       │                                                 │
│                                      │  TIẾN TRÌNH THỜI GIAN:                          │
│  QUẠT HÚT KHÍ:                       │  • Sấy nóng ổn định 30s: [▓▓▓▓▓▓▓▓▓▓ 100%] Hoàn tất│
│  [ 🌀 CẤP 2 (MẠNH) - Y012 ]          │  • Giải nhiệt After-Cool: [..........   0%] Chờ tắt│
│                                      │                                                 │
├──────────────────────────────────────┴─────────────────────────────────────────────────┤
│  [TRANG CHỦ - F1]   [CHẨN ĐOÁN LỖI - F2]   [GIÁM SÁT I/O - F3]   [CÀI ĐẶT THỜI GIAN - F4] │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

#### Các đối tượng (Objects) cần đặt trên Màn hình 10:
1. **Biểu tượng đèn UV trung tâm (State Lamp / Word Lamp):**
   * Sử dụng đối tượng **Multi-State Indicator** (hoặc gán qua macro):
     * Trạng thái 0: Đèn tắt (Màu xám tối).
     * Trạng thái 1: `CMD_UV_80W` ON $\rightarrow$ Màu vàng hổ phách, chữ "80W MỒI/CHỜ".
     * Trạng thái 2: `CMD_UV_120W` ON $\rightarrow$ Màu cam sáng rực, chữ "120W TIÊU CHUẨN".
     * Trạng thái 3: `CMD_UV_160W` ON $\rightarrow$ Màu tím sáng huỳnh quang, chữ "160W CỰC ĐẠI".
2. **Cửa chập Shutter (Bit Lamp):**
   * Đọc tag `VALVE_SHUTTER` (Y007) hoặc `SS_SHUTTER_OPENED` (X012):
     * Khi MỞ (X012 ON): Khung màu xanh ngọc, nhãn "SHUTTER MỞ - ĐANG CHIẾU XẠ".
     * Khi ĐÓNG (X013 ON): Khung màu đỏ cam, nhãn "SHUTTER ĐÓNG - CHẮN TIA UV".
3. **Nút bấm điều khiển (Bit Momentary Button):**
   * Nút **BẬT ĐÈN UV**: Ghi tag `BTN_UV_ON` (`X020`), kiểu Momentary (nhấn nhả).
   * Nút **TẮT ĐÈN UV**: Ghi tag `BTN_UV_OFF` (`X021`), kiểu Momentary.
   * Nút **TẮT CÒI**: Ghi tag `BTN_BUZZER_STOP` (`X022`).
   * Nút **RESET LỖI**: Ghi tag `BTN_RESET_ALARM` (`X023`).
4. **Công tắc chọn công suất (Toggle Switch / Radio Button):**
   * Công tắc **160W**: Ghi tag `SW_POWER_160W` (`X024`).
   * Công tắc **80W**: Ghi tag `SW_LOCK_80W` (`X027`).
5. **Thanh thời gian sấy nóng (Progress Bar / Slider Display):**
   * Đọc giá trị tức thời từ tag `TMR_WARMUP_VAL` (`TV140`): Giá trị max = 300 (tương đương 30.0s). Kèm ô số hiển thị `[TV140 / 10] s`.

---

### 🖥 MÀN HÌNH 20: TRUNG TÂM CHẨN ĐOÁN LỖI (ALARM & TROUBLESHOOTING)

Màn hình này thiết kế chuyên biệt để khi máy gặp sự cố, thợ vận hành hoặc kỹ thuật bảo trì chỉ cần nhìn vào là biết **ngay lập tức** máy đang bị lỗi gì, mã lỗi mấy và cần sửa chỗ nào:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│  ⚠️ TRUNG TÂM CHẨN ĐOÁN SỰ CỐ & GIẢI TRỪ LỖI                       [ 🔔 TẮT CÒI BUZZER ]│
├────────────────────────────────────────────────────────────────────────────────────────┤
│  BANNER BÁO LỖI: [ 🔴 CẢNH BÁO: HỆ THỐNG PHÁT HIỆN SỰ CỐ - MÁY TỰ ĐỘNG DỪNG AN TOÀN ]   │
│  MÃ SỐ LỖI HIỆN TẠI TRÊN BỘ QUÉT: [ SỐ 3: LỖI MẤT ÁP SUẤT GIÓ LÀM MÁT ]                 │
├────────────────────────────────────────────────────────────────────────────────────────┤
│  MA TRẬN 9 NGUỒN LỖI PHẦN CỨNG (ALARM TILES):                                          │
│                                                                                        │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐                     │
│  │ [1] LỖI BALLAST  │  │ [2] LỖI QUẠT HÚT │  │ [3] ÁP SUẤT GIÓ  │  <-- [🔴 ĐANG BÁO]  │
│  │ Tag: ALM_BALLAST │  │ Tag: ALM_EXHAUST │  │ Tag: ALM_AIR_PRS │                     │
│  │ (Điện áp đèn UV) │  │ (Rơ le nhiệt OL) │  │ (Công tắc gió hở)│                     │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘                     │
│                                                                                        │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐                     │
│  │ [4] BUỒNG CHIẾU  │  │ [5] KẸT SHUTTER  │  │ [6] DÒNG CHẢY NƯỚC│                     │
│  │ Tag: ALM_CHAMBER │  │ Tag: ALM_SHUTTER │  │ Tag: ALM_WATER   │                     │
│  │ (Công tắc cửa UV)│  │ (Kẹt xilanh mở)  │  │ (Flow Switch cạn)│                     │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘                     │
│                                                                                        │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐                     │
│  │ [7] DỪNG KHẨN CẤP│  │ [8] CỬA TỦ NGUỒN │  │ [9] LỖI CHILLER  │                     │
│  │ Tag: ALM_ESTOP   │  │ Tag: ALM_DOOR    │  │ Tag: ALM_CHILLER │                     │
│  │ (Nút E-Stop ấn)  │  │ (Cánh tủ mở hở)  │  │ (Máy nén quá tải)│                     │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘                     │
│                                                                                        │
├────────────────────────────────────────────────────────────────────────────────────────┤
│  HƯỚNG DẪN XỬ LÝ NHANH CHO MÃ LỖI ĐANG CHỌN:                                           │
│  👉 "Kiểm tra đường ống hút gió, vệ sinh tấm lọc bụi quạt hút, đo tiếp điểm X010"     │
│                                                        [ 🔄 RESET GIẢI TRỪ LỖI (X023) ]│
└────────────────────────────────────────────────────────────────────────────────────────┘
```

#### Thiết kế Ma trận 9 ô đèn lỗi (Alarm Tiles):
Mỗi ô đại diện cho 1 bit cờ lỗi nội bộ trong PLC. Khi không có lỗi: Khung xám viền xanh mờ (`Bình thường`). Khi có lỗi: Ô đổi sang **màu đỏ nhấp nháy** (`Báo động`):

1. **Mã 1 - Lỗi Ballast / Chấn lưu:** Gán bit `ALM_BALLAST` (`M0`).
2. **Mã 2 - Lỗi Quạt hút làm mát:** Gán bit `ALM_EXHAUST_FAN` (`M10`).
3. **Mã 3 - Lỗi Mất áp suất gió:** Gán bit `ALM_AIR_PRESSURE` (`M20`).
4. **Mã 4 - Lỗi Interlock buồng chiếu:** Gán bit `ALM_CHAMBER_INTLK` (`M30`).
5. **Mã 5 - Lỗi Kẹt cửa chập Shutter:** Gán bit `ALM_SHUTTER_JAM` (`M40`).
6. **Mã 6 - Lỗi Lưu lượng nước giải nhiệt:** Gán bit `ALM_WATER_FLOW` (`M60`).
7. **Mã 7 - Lỗi Dừng khẩn cấp E-Stop:** Gán bit `ALM_ESTOP` (`M120`).
8. **Mã 8 - Lỗi Mở cửa tủ điện nguồn:** Gán bit `ALM_DOOR_OPEN` (`M130`).
9. **Mã 9 - Lỗi Máy làm lạnh Chiller:** Gán bit `ALM_CHILLER` (`M51`).

---

### 🖥 MÀN HÌNH 30: GIÁM SÁT TOÀN DIỆN I/O (DIAGNOSTIC I/O MONITOR)

Màn hình dạng bảng đèn LED ma trận trực quan mô phỏng như mặt trước của PLC để kỹ thuật viên test tín hiệu không cần mở nắp tủ điện:

* **Bảng Inputs X (24 ngõ vào):**
  * `X000` (Lỗi Quạt) | `X001` (Sụt áp) | `X002` (Quá áp) | `X003` (E-Stop)
  * `X004` (Cửa tủ) | `X005` (Cửa phôi) | `X006` (Máy chạy) | `X010` (Áp suất gió)
  * `X011` (Buồng UV) | `X012` (Shutter mở) | `X013` (Shutter đóng) | `X014` (Vị trí 1)
  * `X015` (Vị trí 2) | `X016` (Nước chảy) | `X020` (Bật đèn) | `X021` (Tắt đèn)
  * `X022` (Tắt còi) | `X023` (Reset) | `X024` (160W) | `X027` (80W)
  * `X030` (Chiller chạy) | `X031` (Chiller lỗi)
* **Bảng Outputs Y (24 ngõ ra):**
  * `Y000` (Đèn lỗi) | `Y001` (Còi hú) | `Y002` (Đèn 80W) | `Y003` (Đèn 120W)
  * `Y004` (Đèn 160W) | `Y005` (Damper 1) | `Y006` (Damper 2) | `Y007` (Shutter)
  * `Y010` (Quạt chính) | `Y011` (Quạt cấp 1) | `Y012` (Quạt cấp 2) | `Y014` (Đèn quạt)
  * `Y015` (Đèn UV) | `Y016` (Standby) | `Y017` (Running) | `Y020` (Báo 120W)
  * `Y021` (Báo 160W) | `Y030` (Lệnh Chiller) | `Y024 ~ Y027` (4-bit mã lỗi LED)

---

## 4. MACRO TÍNH TOÁN MÃ LỖI HIỂN THỊ (EASYBUILDER PRO MACRO)

Trong PLC FX2N, mã lỗi được xuất ra 4 bit ngõ ra `Y024` ~ `Y027` (nhóm `K1Y024`). Để màn hình HMI hiển thị được số nguyên to rõ từ **0 đến 9** lên ô số (Numeric Object) hoặc Text, bạn tạo một đoạn Macro chu kỳ 100ms trong EasyBuilder Pro như sau:

```c
macro_command main()
    bool b0 = 0, b1 = 0, b2 = 0, b3 = 0
    short error_code = 0
    
    // Đọc trạng thái 4 bit ngõ ra mã lỗi từ PLC FX2N_UV
    GetData(b0, "FX2N_UV", Y, 24, 1) // Bit 0
    GetData(b1, "FX2N_UV", Y, 25, 1) // Bit 1
    GetData(b2, "FX2N_UV", Y, 26, 1) // Bit 2
    GetData(b3, "FX2N_UV", Y, 27, 1) // Bit 3
    
    // Tính toán giá trị số nguyên nhị phân sang thập phân (0 - 9)
    error_code = (short)b0 + ((short)b1 * 2) + ((short)b2 * 4) + ((short)b3 * 8)
    
    // Ghi mã lỗi vào thanh ghi nội bộ màn hình HMI LW-10
    SetData(error_code, "Local HMI", LW, 10, 1)
end macro_command
```

Sau đó trên Màn hình HMI, bạn chỉ cần đặt 1 đối tượng **Numeric Display** trỏ vào địa chỉ **`LW-10`** là sẽ hiển thị chính xác mã số lỗi 0 ~ 9 tức thời!
