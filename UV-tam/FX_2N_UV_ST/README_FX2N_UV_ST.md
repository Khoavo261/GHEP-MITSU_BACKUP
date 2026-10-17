# HỆ THỐNG ĐIỀU KHIỂN SẤY ĐÈN UV CÔNG NGHIỆP: FX_2N_UV_ST
## CHUYỂN ĐỔI TOÀN DIỆN TỪ LADDER SANG STRUCTURED TEXT (IEC 61131-3)
### TỐI ƯU HÓA HOÀN HẢO CHO MITSUBISHI FX2N TRÊN GX WORKS2

---

## 1. CẤU TRÚC THƯ MỤC DỰ ÁN TINH GỌN (CLEAN & MINIMAL)

Toàn bộ dự án đã được tinh gọn tối đa, xóa bỏ toàn bộ file thừa, mỗi POU chỉ gồm **đúng 1 file biến `.tsv`** và **đúng 1 file code `_ST.st`**:

```
FX_2N_UV_ST/
├── Labels/                                 <--- DÁN VÀO MỤC "Local Label" CỦA TỪNG POU
│   ├── Local_Labels_FB_UV_CuringUnit.tsv   (Bảng biến 5 cột chuẩn cho FB CuringUnit)
│   ├── Local_Labels_FB_UV_AlarmManager.tsv (Bảng biến 5 cột chuẩn cho FB AlarmManager)
│   ├── Local_Labels_PRG_UV_Main.tsv        (Bảng biến 5 cột chuẩn cho Program Main)
│   └── Global_Labels.tsv                   (Bảng biến Global Label)
│
├── POUs_Core/                              <--- DÁN VÀO MỤC "Program [ST]" CỦA FUNCTION BLOCK
│   ├── FB_UV_CuringUnit_ST.st              (Mã ST chu trình mồi 80W, 120W, 160W, quạt, chiller, After-Cool)
│   └── FB_UV_AlarmManager_ST.st            (Mã ST quản lý 9 nguồn lỗi, còi hú & Smart Alarm Sequencer)
│
├── POUs_Program/                           <--- DÁN VÀO MỤC "Program [ST]" CỦA CHƯƠNG TRÌNH CHÍNH
│   └── PRG_UV_Main_ST.st                   (Mã ST đọc X, gọi FB, xuất Y, đồng bộ M và ghi D100..D105)
│
├── HMI_Mapping/                            <--- KẾT NỐI MÀN HÌNH HMI WEINTEK MT6103iP
│   ├── hmi.csv                             (Danh mục 78 Tag nạp vào EasyBuilder Pro)
│   └── weintek_macro_status.c              (Macro C tự động giải mã Text trạng thái và 9 mã lỗi)
│
└── README_FX2N_UV_ST.md                    (Tài liệu tổng quan dự án)
```

---

## 2. BẢNG TRA CỨU ĐỊA CHỈ & BIẾN SỐ LIÊN KẾT

| Tên thiết bị | Địa chỉ FX2N | Tên biến ST | Chức năng kỹ thuật |
| :--- | :---: | :--- | :--- |
| **Bật đèn UV** | `X020` | `di_BtnLampOn` | Nút nhấn Bật đèn sấy UV tại mặt tủ |
| **Tắt đèn UV** | `X021` | `di_BtnLampOff` | Nút nhấn Tắt đèn UV (kích After-Cool 180s) |
| **Tắt còi** | `X022` | `di_BtnBuzzerStop` | Nút tắt tiếng còi Buzzer khi có sự cố |
| **Reset lỗi** | `X023` | `di_BtnFaultReset` | Nút giải trừ lỗi hệ thống |
| **Chọn 160W** | `X024` | `di_SwPower160W` | Công tắc chọn nấc công suất cực đại 160W |
| **Chọn 80W** | `X027` | `di_SwPower80W` | Công tắc khóa giữ công suất mồi 80W |
| **Đèn lỗi tổng** | `Y000` | `bMasterAlarm` | Sáng khi có bất kỳ sự cố nào trong 9 lỗi |
| **Còi sự cố** | `Y001` | `bBuzzer` | Hú còi báo động |
| **Đèn 80W** | `Y002` | `do_LampPower80W` | Kích mồi hồ quang đèn UV 80W |
| **Đèn 120W** | `Y003` | `do_LampPower120W` | Kích tăng công suất đèn lên 120W |
| **Đèn 160W** | `Y004` | `do_LampPower160W` | Kích tăng công suất cực đại 160W |
| **Van Shutter** | `Y007` | `do_ShutterValve` | Xy lanh khí nén đóng/mở cửa chắn UV |
| **Quạt hút** | `Y010` | `do_ExhaustFan` | Khởi động động cơ quạt hút ozone |
| **Quạt cấp 1** | `Y011` | `do_FanSpeedStage1`| Quạt chạy cấp tốc độ thấp (80W) |
| **Quạt cấp 2** | `Y012` | `do_FanSpeedStage2`| Quạt chạy cấp tốc độ cao (120W/160W) |
| **Chiller** | `Y030` | `do_ChillerCommand`| Lệnh khởi động máy làm lạnh nước |
| **Trạng thái máy**| `D100` | `iMachineState` | 0:Dừng, 1:Ủ nhiệt, 2:Standby, 3:120W, 4:160W, 5:After-Cool, 6:Sự cố |
| **Mã số lỗi** | `D101` | `iActiveAlarmCode`| 0:Bình thường, 1..9: Tương ứng 9 lỗi an toàn |
| **Công suất Watt**| `D103`| `iCurrentPowerWatt`| Công suất sấy thực tế: 0, 80, 120, 160 Watt |
| **Giây After-Cool**| `D105`| `iRemainingCoolSec`| Đếm lùi thời gian làm mát còn lại (180s về 0s) |
