# CHƯƠNG TRÌNH ĐIỀU KHIỂN HỆ THỐNG SẤY ĐÈN UV (MITSUBISHI FX2N)
*Nguồn trích xuất: `D:\UV-tam\fx2n-uv-1.pdf` (Tổng cộng 9 trang, từ Step 0 đến Step 388)*

---

## 1. BẢNG DANH MỤC THIẾT BỊ VÀ CHÚ THÍCH (I/O & INTERNAL RELAY)

### Ngõ vào số (Inputs - X)
| Device | Tiếng Nhật gốc | Nghĩa Tiếng Việt | Ghi chú kỹ thuật |
| :--- | :--- | :--- | :--- |
| **X000** | 排風装置異常 | Báo lỗi quạt hút thông gió | Tiếp điểm thường đóng/mở từ rơ le nhiệt quạt |
| **X001** | ランプ電圧下限異常 | Báo lỗi sụt áp đèn UV | Điện áp nuôi đèn thấp hơn ngưỡng |
| **X002** | ランプ電圧上限異常 | Báo lỗi quá áp đèn UV | Điện áp nuôi đèn vượt ngưỡng an toàn |
| **X003** | 非常停止 | Nút Dừng khẩn cấp (E-Stop) | Tiếp điểm an toàn ngoài |
| **X004** | 電源ドア異常 | Cửa tủ điện nguồn bị mở | Công tắc hành trình cánh tủ nguồn |
| **X005** | 搬入れ扉抜き | Cửa buồng nạp phôi đã đóng kín | Cảm biến cửa nạp phôi / vật liệu |
| **X006** | マシン運転 | Tín hiệu máy chính đang chạy | Interlock đồng bộ dây chuyền sản xuất |
| **X010** | 風圧SW | Công tắc áp suất gió (Flow switch) | Cảm biến lưu lượng hút gió làm mát |
| **X011** | 照射部LTS | Limit Switch buồng chiếu UV | Công tắc liên động an toàn buồng chiếu |
| **X012** | シャッター開 | Cảm biến Shutter đã mở hết | Sensor báo mở cửa chập Shutter |
| **X013** | シャッター閉 | Cảm biến Shutter đã đóng kín | Sensor báo đóng cửa chập Shutter |
| **X014** | 照射部位置1 | Cảm biến vị trí buồng chiếu 1 | Điều khiển mở van gió Damper 1 |
| **X015** | 照射部位置2 | Cảm biến vị trí buồng chiếu 2 | Điều khiển mở van gió Damper 2 |
| **X016** | フローSW検知 | Cảm biến lưu lượng nước làm mát | Flow switch giải nhiệt ballast/đèn |
| **X020** | ランプ点灯 | Nút bấm Bật đèn UV (PB ON) | Nút ấn điều khiển tại tủ |
| **X021** | ランプ消灯 | Nút bấm Tắt đèn UV (PB OFF) | Nút ấn dừng sấy đèn UV |
| **X022** | ブザー停止 | Nút tắt còi báo động (Buzzer Stop) | Xóa còi nhưng đèn lỗi vẫn sáng |
| **X023** | INTリセットPB | Nút Reset lỗi hệ thống | Reset giải trừ các lỗi đã xử lý xong |
| **X024** | ランプ160W | Công tắc chọn công suất cao 160W | Chọn nấc công suất sấy |
| **X025** | シャッター遅延閉 | Tín hiệu Shutter đóng trễ | Tín hiệu điều khiển liên động |
| **X026** | シャッター遅延閉 | Tín hiệu Shutter đóng trễ (Khóa) | Interlock đóng |
| **X027** | 80W設定 | Công tắc chọn công suất thấp 80W | Giữ nguyên công suất ban đầu 80W |
| **X030** | チラー運転 | Tín hiệu Chiller đang chạy | Phản hồi máy làm lạnh nước hoạt động |
| **X031** | チラー異常 | Tín hiệu báo lỗi Chiller | Cảnh báo quá nhiệt/lỗi máy lạnh |

### Ngõ ra số (Outputs - Y)
| Device | Tiếng Nhật gốc | Nghĩa Tiếng Việt | Ghi chú kỹ thuật |
| :--- | :--- | :--- | :--- |
| **Y000** | 総合異常 | Đèn/còi báo lỗi tổng hợp | Bật khi có bất kỳ lỗi nào trong hệ thống |
| **Y001** | 故障警報 | Còi báo sự cố (Buzzer) | Kêu khi có lỗi, ngắt bằng nút X022 |
| **Y002** | 80W点灯 | Khởi động đèn UV (Cấp 80W) | Kích mồi và duy trì ban đầu 80W |
| **Y003** | 120W点灯 | Tăng công suất đèn lên 120W | Kích nấc công suất trung bình 120W |
| **Y004** | 160W点灯 | Tăng công suất đèn lên 160W | Kích nấc công suất cực đại 160W |
| **Y005** | 排気ダンパー1 | Mở van xả khí buồng chiếu 1 | Van điện từ khí nén Damper 1 |
| **Y006** | 排気ダンパー2 | Mở van xả khí buồng chiếu 2 | Van điện từ khí nén Damper 2 |
| **Y007** | シャッター開閉 | Van điều khiển đóng mở Shutter | Xylanh đóng/mở cửa chắn tia UV |
| **Y010** | 排風機運転 | Khởi động động cơ quạt hút | Chạy quạt làm mát và hút khí ozone |
| **Y011** | 排風機多段1 | Điều khiển tốc độ quạt cấp 1 | Phù hợp với công suất đèn 80W/120W |
| **Y012** | 排風機多段2 | Điều khiển tốc độ quạt cấp 2 | Phù hợp với công suất đèn 160W |
| **Y014** | 排風機運転表示 | Đèn báo quạt hút đang chạy | Báo trạng thái trên mặt tủ |
| **Y015** | ランプ点灯表示 | Đèn báo đèn UV đang bật | Báo trạng thái UV ON |
| **Y016** | スタンバイ表示 | Đèn báo sẵn sàng (Standby) | Đèn UV đã đủ nhiệt độ & Shutter mở |
| **Y017** | ランニング表示 | Đèn báo đang sấy (Running) | Shutter đóng/đang trong chu trình |
| **Y020** | 120W表示 | Đèn báo chế độ 120W | Hiển thị nấc công suất 120W |
| **Y021** | 160W表示 | Đèn báo chế độ 160W | Hiển thị nấc công suất 160W |
| **Y022** | シャッター遅延開 | Lệnh mở Shutter trễ | Kích mở Shutter |
| **Y023** | シャッター遅延閉 | Lệnh đóng Shutter trễ | Kích đóng Shutter |
| **Y024~Y027** | エラーコード | 4-bit xuất mã lỗi (K1Y024) | Xuất mã lỗi từ 1 đến 9 ra LED 7 đoạn |
| **Y030** | チラー運転指令 | Lệnh khởi động Chiller | Kích máy nén làm lạnh giải nhiệt |

### Rơ le trung gian (M) & Timer (T) quan trọng
- **T0 (K20 = 2s):** Trễ 2s sau khi bật nguồn để ổn định các tiếp điểm.
- **T140 (K300 = 30s):** Thời gian sấy nóng ban đầu để đèn UV đạt cường độ ổn định.
- **T120 (K900 = 90s):** Duy trì quạt hút khi khởi động đèn.
- **T130 (K1800 = 180s = 3 phút):** Chế độ After-Cool (quạt tiếp tục chạy 3 phút sau khi tắt đèn UV để làm mát bóng và thổi sạch hơi ozone).
- **M180:** Cờ báo lỗi tổng hợp (Master Alarm).
- **MC N0 M189 / MCR N0:** Vùng điều khiển Master Control (bảo vệ an toàn cánh tủ điện nguồn).
- **M161 ~ M172:** Vòng thanh ghi dịch 12-bit để quét và hiển thị xoay vòng mã lỗi (Error Code Scanner).

---

## 2. NỘI DUNG CHI TIẾT CHƯƠNG TRÌNH LADDER / INSTRUCTION LIST (IL)

```plc
; ==============================================================================
; TRANG 1: KHỞI TẠO NGUỒN VÀ BẮT LỖI KHỐI 1 (STEP 0 - 48)
; ==============================================================================

; [Step 0] Tạo trễ 2 giây sau khi cấp điện PLC (On ổn định hệ thống)
LD      M8000           ; Cờ luôn ON
OUT     T0      K20     ; Timer 2.0s trễ nguồn

; [Step 4] Báo lỗi điện áp đèn UV quá cao hoặc quá thấp
LD      X002            ; Lỗi quá áp đèn UV
AND     Y002            ; Khi đang bật đèn 80W
LD      X001            ; Lỗi sụt áp đèn UV
AND     T140            ; Sau khi đèn đã chạy qua thời gian ổn định
ORB
OUT     T1      K50     ; Timer trễ 5.0s lọc nhiễu lỗi bộ chấn lưu Ballast

; [Step 12] Tự giữ cờ lỗi chấn lưu/Ballast M0
LD      T1              ; Khi hết trễ 5s lỗi ballast
OR      M0              ; Tiếp điểm tự giữ M0
ANI     X023            ; Nút Reset giải trừ lỗi
OUT     M0              ; M0 = 1 (Lỗi chấn lưu / Ballast)

; [Step 17] Báo lỗi hệ thống quạt thông gió M10
LD      X000            ; Tiếp điểm lỗi quạt hút
AND     T0              ; Sau khi nguồn mở 2s
OR      M10             ; Tự giữ
ANI     X023            ; Nút Reset
OUT     M10             ; M10 = 1 (Lỗi quạt hút làm mát)

; [Step 23] Kiểm tra công tắc áp suất gió T11
LD      X010            ; Cảm biến áp suất gió hở
AND     Y002            ; Khi đèn UV đang bật
AND     T140            ; Sau khi đã qua thời gian ổn định
OUT     T11     K50     ; Trễ 5.0s phát hiện lỗi áp suất gió

; [Step 29] Tự giữ cờ lỗi áp suất gió M20
LD      T11
OR      M20
ANI     X023
OUT     M20             ; M20 = 1 (Lỗi mất áp suất gió)

; [Step 34] Kiểm tra công tắc hành trình buồng chiếu UV M30
LD      X011            ; Công tắc buồng chiếu hở/kẹt
AND     Y002            ; Khi đèn UV đang bật
OR      M30             ; Tự giữ
ANI     X023
OUT     M30             ; M30 = 1 (Lỗi liên động buồng chiếu)

; [Step 40] Kiểm tra hành trình đóng/mở cửa chập Shutter T21
LD      X012            ; Cảm biến Shutter mở
AND     Y007            ; Khi lệnh đóng/mở đang tác động
AND     Y002            ; Và đèn đang bật
LD      X013            ; Hoặc cảm biến Shutter đóng
ANI     Y007            ; Khi lệnh đóng/mở không tác động
ORB
OUT     T21     K50     ; Trễ 5.0s kiểm tra kẹt Shutter

; ==============================================================================
; TRANG 2: BẮT LỖI KHỐI 2 - DÒNG CHẢY, E-STOP, CỬA TỦ & CHILLER (STEP 49 - 90)
; ==============================================================================

; [Step 49] Tự giữ lỗi Shutter M40
LD      T21
OR      M40
ANI     X023
OUT     M40             ; M40 = 1 (Lỗi Shutter kẹt / hành trình)

; [Step 54] Kiểm tra cảm biến dòng chảy nước giải nhiệt T41
LD      X016            ; Cảm biến lưu lượng dòng chảy không đạt
AND     Y002            ; Khi đèn UV đang sáng
OUT     T41     K150    ; Trễ 15.0s chống báo ảo bọt khí

; [Step 59] Tự giữ cờ lỗi dòng chảy nước giải nhiệt M60
LD      T41
OR      M60
ANI     X023
OUT     M60             ; M60 = 1 (Lỗi mất lưu lượng nước làm mát)

; [Step 64] Lỗi dừng khẩn cấp E-Stop M120
LD      X003            ; Nút nhấn E-Stop tác động
AND     T0              ; Sau khi bật nguồn 2s
OR      M120            ; Tự giữ
ANI     X023
OUT     M120            ; M120 = 1 (Lỗi dừng khẩn cấp)

; [Step 70] Lỗi mở cửa tủ nguồn điện UV M130
LD      X004            ; Cửa tủ nguồn bị mở
LD      M520            ; Khi đèn UV đang sáng
OR      Y010            ; Hoặc khi quạt hút đang chạy
ANB
OR      M130            ; Tự giữ
ANI     X023
OUT     M130            ; M130 = 1 (Lỗi mở cửa tủ nguồn điện)

; [Step 78] Kiểm tra lỗi máy làm lạnh Chiller T31
LD      X030            ; Chiller đang chạy
AND     T101            ; Sau trễ 10s khởi động chiller
LD      X031            ; Hoặc Chiller báo lỗi trực tiếp
AND     T0              ; Sau khi bật nguồn 2s
ORB
OUT     T31     K50     ; Trễ 5.0s xác nhận lỗi chiller

; [Step 86] Tự giữ cờ lỗi Chiller M51
LD      T31
OR      M51
ANI     X023
OUT     M51             ; M51 = 1 (Lỗi Chiller giải nhiệt)

; ==============================================================================
; TRANG 3: TỔNG HỢP LỖI & CÒI CẢNH BÁO BUZZER (STEP 91 - 116)
; ==============================================================================

; [Step 91] Gom toàn bộ 9 nguồn lỗi thành Cờ Lỗi Tổng Hợp M180 & Đèn Y000
LD      M0              ; Lỗi 1: Ballast / Chấn lưu
OR      M10             ; Lỗi 2: Quạt làm mát
OR      M20             ; Lỗi 3: Áp suất gió
OR      M30             ; Lỗi 4: Buồng UV
OR      M40             ; Lỗi 5: Shutter
OR      M60             ; Lỗi 6: Dòng chảy nước
OR      M120            ; Lỗi 7: E-Stop
OR      M130            ; Lỗi 8: Cửa tủ điện
OR      M51             ; Lỗi 9: Chiller
OUT     Y000            ; Đèn/còi báo lỗi tổng hợp bật sáng
OUT     M180            ; Cờ lỗi tổng hợp hệ thống ON

; [Step 102] Điều khiển còi hú Buzzer Y001 (Cho phép ngắt chuông bằng nút X022)
LD      M180            ; Có lỗi tổng hợp
ANI     M194            ; Chưa bị ngắt còi
OUT     Y001            ; Xuất tín hiệu còi hú sự cố Y001

; [Step 105] Tự giữ cờ ngắt còi M194 khi nhấn nút X022
LD      X022            ; Nhấn nút tắt còi
AND     M180            ; Khi đang có lỗi
OR      M194            ; Tự giữ
OUT     M194            ; M194 = 1 (Khóa còi, chỉ để đèn nháy)

; [Step 109 & 113] Tạo bộ tạo xung nhịp đồng hồ quét mã lỗi (Timer đa hài 0.1s)
LDI     T91             ; Đảo Timer 2
OUT     T90     K1      ; Timer 1 (0.1 giây)
LD      T90             ; Khi Timer 1 đếm đủ
OUT     T91     K1      ; Kích Timer 2 (0.1 giây)

; ==============================================================================
; TRANG 4 & 5: THANH GHI DỊCH QUÉT MÃ LỖI (SHIFT REGISTER SCANNER) (STEP 117 - 188)
; ==============================================================================

; [Step 117] Tạo tín hiệu dịch mã lỗi nhóm 1 (M150)
LD      M161            ; Vị trí quét 1
ANI     M180            ; Không có lỗi nào
AND     T90             ; Nhịp Timer 1
LD      M162            ; Vị trí quét 2
ANI     M0              ; Ballast không lỗi
AND     T93             ; Nhịp Timer 4
ORB
LD      M163            ; Vị trí quét 3
ANI     M10             ; Quạt không lỗi
AND     T92             ; Nhịp Timer 3
ORB
LD      M164            ; Vị trí quét 4
ANI     M20             ; Áp suất gió không lỗi
AND     T93
ORB
LD      M165            ; Vị trí quét 5
ANI     M30             ; Buồng chiếu không lỗi
AND     T92
ORB
LD      M166            ; Vị trí quét 6
ANI     M40             ; Shutter không lỗi
AND     T93
ORB
OUT     M150            ; Xung dịch nhóm 1

; [Step 146] Tạo tín hiệu dịch mã lỗi nhóm 2 (M151)
LD      M167            ; Vị trí quét 7
ANI     M60             ; Lưu lượng nước không lỗi
AND     T90
LD      M168            ; Vị trí quét 8
ANI     M120            ; E-Stop không lỗi
AND     T93
ORB
LD      M169            ; Vị trí quét 9
ANI     M130            ; Cửa tủ không lỗi
AND     T92
ORB
LD      M170            ; Vị trí quét 10
ANI     M51             ; Chiller không lỗi
AND     T93
ORB
LD      M171            ; Vị trí quét 11
ORB
LD      M172            ; Vị trí quét 12
ANI     M8000           ; Khóa đuôi chu kỳ
ORB
OUT     M151            ; Xung dịch nhóm 2

; [Step 171] Thực hiện lệnh dịch bit trái SFTL cho 12 bit (M161 -> M172)
LD      M150
OR      M151
SFTL    M8001   M161    K12     K1      ; Dịch 1 bit sang trái trong dải M161~M172

; [Step 182] Khởi tạo bit đầu tiên khi bật PLC RUN hoặc khi quét hết vòng 12 bit
LD      M8002           ; Xung đầu chu kỳ PLC RUN
OR      M172            ; Khi bit cuối M172 bật (hết vòng)
MOV     K1      K3M161  ; Nạp giá trị 1 vào bit M161 (M161=1, các bit còn lại = 0)

; ==============================================================================
; TRANG 6: ĐIỀU KHIỂN THỜI GIAN HIỂN THỊ & XUẤT MÃ LỖI 7 ĐOẠN (STEP 189 - 280)
; ==============================================================================

; [Step 189] Timer giữ hiển thị mã lỗi chẵn (2.0s)
LD      M162
OR      M164
OR      M166
OR      M168
OR      M170
OR      M172
AND     T0
OUT     T92     K20     ; Duy trì hiển thị mã lỗi 2.0 giây

; [Step 199] Timer giữ hiển thị mã lỗi lẻ (2.0s)
LD      M163
OR      M165
OR      M167
OR      M169
OR      M171
AND     T0
OUT     T93     K20     ; Duy trì hiển thị mã lỗi 2.0 giây

; [Step 208 ~ 270] Xuất mã số lỗi ra 4-bit ngõ ra Y24~Y27 (K1Y024)
LD      M180
MOV     H0      K1Y024  ; Khi không lỗi: Xuất mã 0

LD      M162
AND     M0
MOV     H1      K1Y024  ; Mã 1: Lỗi Ballast chấn lưu

LD      M163
AND     M10
MOV     H2      K1Y024  ; Mã 2: Lỗi Quạt hút làm mát

LD      M164
AND     M20
MOV     H3      K1Y024  ; Mã 3: Lỗi Mất áp suất gió

LD      M165
AND     M30
MOV     H4      K1Y024  ; Mã 4: Lỗi Interlock buồng UV

LD      M166
AND     M40
MOV     H5      K1Y024  ; Mã 5: Lỗi Kẹt Shutter

LD      M167
AND     M60
MOV     H6      K1Y024  ; Mã 6: Lỗi Dòng chảy nước Flow switch

LD      M168
AND     M120
MOV     H7      K1Y024  ; Mã 7: Lỗi Dừng khẩn cấp E-Stop

LD      M169
AND     M130
MOV     H8      K1Y024  ; Mã 8: Lỗi Mở cửa tủ điện nguồn

LD      M170
AND     M51
MOV     H9      K1Y024  ; Mã 9: Lỗi Chiller giải nhiệt

; [Step 277] KHỐI MASTER CONTROL N0 (Bảo vệ an toàn đóng cửa tủ điện)
LDI     M130            ; Cửa tủ nguồn đang đóng kín (không có lỗi M130)
MC      N0      M189    ; Bắt đầu khối điều khiển Master Control N0

; ==============================================================================
; TRANG 7: KHỞI ĐỘNG ĐÈN UV, VAN XẢ KHÍ & CHILLER (NẰM TRONG N0) (STEP 281 - 313)
; ==============================================================================

; [Step 281] Van xả khí buồng 1
LD      M189            ; (Thuộc khối N0)
LD      X014            ; Cảm biến vị trí buồng chiếu 1
OUT     Y005            ; Mở van xả khí Damper 1

; [Step 283] Van xả khí buồng 2
LD      X015            ; Cảm biến vị trí buồng chiếu 2
OUT     Y006            ; Mở van xả khí Damper 2

; [Step 285] Mạch bật/tắt đèn UV chính (Y002 - 80W ban đầu)
LD      X020            ; Nút bấm Bật đèn UV
AND     Y010            ; Điều kiện: Quạt hút phải đang chạy!
ANI     X021            ; Nút bấm Tắt đèn UV
ANI     M180            ; Điều kiện: Không có bất kỳ lỗi nào
OR      M520            ; Nhánh tự giữ M520
OUT     M520            ; M520 = 1 (Trạng thái đèn UV đang bật)
OUT     Y002            ; Y002 = 1 (Bật đèn UV ở công suất mồi 80W)
OUT     Y014            ; Bật đèn báo quạt hút
OUT     T120    K900    ; Trễ 90s duy trì quạt khi bật đèn
OUT     T101    K100    ; Trễ 10s trước khi kiểm tra lỗi Chiller
PLF     M560            ; Tạo xung sườn xuống M560 ngay khi tắt đèn UV

; [Step 302] Lệnh khởi động máy làm lạnh Chiller
LD      Y010            ; Khi quạt hút đang chạy
ANI     T130            ; Chưa hết thời gian làm mát sau tắt đèn
OR      Y002            ; Hoặc đèn UV đang sáng
OR      M520
OUT     Y030            ; Kích chạy Chiller Y030

; [Step 307] Timer giải nhiệt sau khi tắt đèn UV (After-cooling 180s)
LD      M560            ; Xung khi vừa bấm tắt đèn
OUT     T130    K1800   ; Đếm 180 giây (3 phút) làm mát tiếp tục

; [Step 311] Duy trì trạng thái làm mát tiếp tục
LD      M561
ANI     T130
OUT     M561            ; Cờ duy trì quạt làm mát sau tắt đèn

; ==============================================================================
; TRANG 8: ĐIỀU KHIỂN QUẠT HÚT, CÁC CẤP TỐC ĐỘ & SHUTTER (STEP 314 - 361)
; ==============================================================================

; [Step 314] Điều khiển động cơ quạt hút chính Y010
LD      T120            ; Khi hết trễ mồi quạt
ANI     M10             ; Quạt không bị lỗi
OR      M561            ; Hoặc đang trong chế độ After-cooling
OUT     Y010            ; Khởi động quạt hút Y010
OUT     Y015            ; Bật đèn báo UV ON

; [Step 320] Timer 30 giây để đèn UV sấy nóng ổn định
LD      M520            ; Khi đèn UV đang bật
OUT     T140    K300    ; Đếm 30.0 giây

; [Step 323] Điều khiển quạt tốc độ cấp 1 (Cho công suất 80W)
LD      Y002            ; Đang bật đèn 80W
ANI     Y003            ; Không bật nấc 120W
ANI     Y004            ; Không bật nấc 160W
AND     M520
LD      Y002
ANI     Y003
ANI     Y004
ORB
OUT     Y011            ; Chạy quạt cấp 1 (Tốc độ thấp)

; [Step 332] Điều khiển quạt tốc độ cấp 2 (Cho công suất 120W / 160W)
LD      Y002            ; Đang bật đèn
AND     Y003            ; Đang ở nấc 120W
ANI     Y004
AND     M520
LD      Y002
AND     Y003
ANI     Y004
ORB
OUT     Y012            ; Chạy quạt cấp 2 (Tốc độ cao)

; [Step 341] Cờ báo đèn UV đã đạt độ sáng ổn định M540
LD      M520
AND     T140            ; Đã qua 30s sấy nóng
OUT     M540            ; Đèn UV đã ổn định (Sẵn sàng sấy)

; [Step 344] Điều kiện cho phép mở Shutter M570
LD      M520
AND     T140
AND     X006            ; Máy chính đang chạy
OUT     M570            ; M570 = 1 (Đủ điều kiện mở cửa Shutter)

; [Step 348] Tín hiệu nạp phôi & Van mở Shutter trễ Y022
LD      M520            ; Đèn đang bật
AND     X005            ; Cửa nạp phôi đã đóng an toàn
AND     M570            ; Đủ điều kiện mở
ANI     X026            ; Không bị khóa đóng trễ
OR      M571            ; Tự giữ
OUT     M571            ; Cờ cho phép nạp phôi
OUT     Y022            ; Lệnh mở Shutter trễ Y022

; [Step 356] Lệnh đóng Shutter trễ Y023
LD      X005
AND     X025
OUT     Y023            ; Lệnh đóng Shutter trễ Y023

; [Step 359] Kích van khí nén đóng/mở Shutter Y007
LD      Y002            ; Đèn đang sáng
AND     X025            ; Tín hiệu đóng trễ
OUT     Y007            ; Cuộn hút Solenoid Valve Shutter Y007

; ==============================================================================
; TRANG 9: CÁC NẤC CÔNG SUẤT (120W, 160W) & ĐÈN BÁO TRẠNG THÁI (STEP 362 - 388)
; ==============================================================================

; [Step 362] Chọn nấc công suất sấy 120W và 160W
LD      Y002            ; Đèn đã bật 80W
AND     Y007            ; Shutter đã mở
ANI     X027            ; Không chọn chế độ 80W
OUT     Y003            ; Kích tăng lên công suất 120W (Y003)
AND     X024            ; Nếu gạt chọn công tắc 160W (X024)
OUT     Y004            ; Kích tăng lên công suất 160W (Y004)

; [Step 370] Đèn báo hiển thị công suất 120W / 160W
LD      Y002
AND     X024
ANI     X027
OUT     Y020            ; Đèn báo chế độ 120W sáng
AND     X024
OUT     Y021            ; Đèn báo chế độ 160W sáng

; [Step 376] Đèn báo Standby (Sẵn sàng) & Running (Đang sấy)
LD      Y002            ; Đèn đang sáng
AND     M540            ; Đã ổn định nhiệt độ
AND     X012            ; Shutter đã mở hoàn toàn
OUT     Y016            ; Đèn báo STANDBY sáng (Sẵn sàng cho phôi qua)
LD      Y002
AND     M540
AND     X013            ; Shutter đang đóng kín
OUT     Y017            ; Đèn báo RUNNING sáng

; [Step 386] KẾT THÚC VÙNG MASTER CONTROL N0
MCR     N0              ; Reset / Kết thúc vùng Master Control N0

; [Step 388] KẾT THÚC CHƯƠNG TRÌNH
END
```

---

## 3. CÁCH NẠP CHƯƠNG TRÌNH VÀ COMMENT VÀO GX WORKS2

1. **Nhập mã lệnh:**
   - Mở GX Works2 -> Chọn PLC: **FXCPU** -> Type: **FX2N / FX2NC**.
   - Chuyển sang dạng Instruction List (Edit mode) hoặc Ladder.
   - Nhập toàn bộ các bước theo danh sách lệnh trên.

2. **Nhập Comment tiếng Việt tự động:**
   - Đã có file sẵn tại: `D:\UV-tam\fx2n_uv_comments.csv`.
   - Trong GX Works2: Vào **Project** -> Chọn **Device Comment** -> Bấm chuột phải chọn **Import from CSV** -> Trỏ tới file `D:\UV-tam\fx2n_uv_comments.csv` để nhập toàn bộ chú thích tiếng Việt cho tất cả chân X, Y, M, T một cách tự động mà không cần gõ tay.
