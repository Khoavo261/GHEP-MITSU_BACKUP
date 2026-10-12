# 🪜 CHƯƠNG TRÌNH LADDER: 02_MAIN_LOGIC
## DỰ ÁN: MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - PLC MITSUBISHI Q02U
### THƯ MỤC: ST_LATCH_GHEP
- **Loại chương trình:** Scan Execution (Quét tuần hoàn cùng POU ST)
- **Ngôn ngữ:** **LADDER DIAGRAM (LD)** trong GX Works2

---

## 📌 PHẦN 1: TỔNG QUAN PHÂN CHIA NHIỆM VỤ
Chương trình **`MAIN_LOGIC` (LADDER)** đảm nhận toàn bộ các mạch tiếp điểm rơ-le, nút nhấn cơ khí, an toàn và van chấp hành:
1. **Nút nhấn Run / Stop / E-Stop / Jog luồn màng**.
2. **Liên động an toàn 5 trục Servo Ready** (Thu T, Kéo X1, Master X2, Ghép Ms, Lô Dầu S).
3. **Điều khiển Solenoid van khí nén Pen ép lô cao su (`Y50`)**.
4. **Điều khiển Bơm dầu bôi trơn lô tráng keo (`Y51`)**.
5. **Đèn tháp cảnh báo và còi báo động sự cố (`Y52`, `Y53`)**.
6. **Nút Reset sự cố (`X4F`)**.

---

## 📌 PHẦN 2: BẢNG TIẾP ĐIỂM VÀ CUỘN HÚT TRONG LADDER

| Thiết Bị | Loại | Tên Biến | Ý Nghĩa Chức Năng |
| :---: | :---: | :--- | :--- |
| **`X40`** | N.O (Thường hở) | `PB_Start_Run` | Nút nhấn Bắt đầu chạy tự động (Start) |
| **`X41`** | N.C (Thường đóng)| `PB_Stop` | Nút nhấn Dừng máy (Stop) |
| **`X49`** | N.C (Thường đóng)| `PB_EStop` | Nút nhấn Dừng khẩn cấp (E-Stop) |
| **`X43`** | N.O (Thường hở) | `PB_Jog_Forward` | Nút nhấn Nhấp bò luồn màng (Jog Crawl) |
| **`X42`** | N.O (Thường hở) | `PB_Pen_Clamp` | Công tắc/Nút gạt Hạ Pen ép màng |
| **`X44`** | N.O (Thường hở) | `DI_Servo_Rdy_T` | Tín hiệu Servo Ready Trục Thu T |
| **`X45`** | N.O (Thường hở) | `DI_Servo_Rdy_X1` | Tín hiệu Servo Ready Trục Kéo X1 |
| **`X46`** | N.O (Thường hở) | `DI_Servo_Rdy_X2` | Tín hiệu Servo Ready Trục Master X2 |
| **`X47`** | N.O (Thường hở) | `DI_Servo_Rdy_Ms` | Tín hiệu Servo Ready Trục Ghép Ms |
| **`X48`** | N.O (Thường hở) | `DI_Servo_Rdy_S` | Tín hiệu Servo Ready Trục Lô Dầu S |
| **`X4F`** | N.O (Thường hở) | `PB_Fault_Reset` | Nút nhấn Reset lỗi hệ thống |
| **`M100`**| Relay nội | `Sys_Power_On` | Hệ thống sẵn sàng (All Safe) |
| **`M101`**| Relay nội | `Cmd_Auto_Run` | Lệnh Chạy Tự Động (Auto Run) |
| **`M102`**| Relay nội | `Cmd_Jog_Crawl` | Lệnh Nhấp bò luồn màng (Jog) |
| **`M105`**| Relay nội | `All_Servo_Ready` | Cả 5 trục Servo đã sẵn sàng |
| **`M106`**| Relay nội | `Servo_Fault_Alarm` | Cờ báo lỗi mất sẵn sàng Servo |
| **`Y50`** | Ngõ ra cứng | `Out_Valve_Pen_Press`| Cuộn Solenoid Van hạ Pen ép màng |
| **`Y51`** | Ngõ ra cứng | `Out_Pump_Oil_Lube` | Contactor Bơm dầu bôi trơn trục S |
| **`Y52`** | Ngõ ra cứng | `Out_Buzzer_Alarm` | Còi hú báo động sự cố |
| **`Y53`** | Ngõ ra cứng | `Out_Tower_Lamp_Run` | Đèn tháp báo máy đang chạy |

---

## 📌 PHẦN 3: SƠ ĐỒ TIẾP ĐIỂM LADDER (VISUAL ASCII DIAGRAM)

```text
[ RUNG 0: GIÁM SÁT AN TOÀN 5 TRỤC SERVO READY ]
  X44         X45         X46         X47         X48               M105
--[ ]---------[ ]---------[ ]---------[ ]---------[ ]----------------( )--- (All_Servo_Ready)
 (Rdy_T)     (Rdy_X1)    (Rdy_X2)    (Rdy_Ms)    (Rdy_S)

[ RUNG 1: CẢNH BÁO MẤT SẴN SÀNG SERVO (SERVO FAULT) ]
  M105                                                              M106
--[/]----------------------------------------------------------------( )--- (Servo_Fault_Alarm)

[ RUNG 2: MẠCH DUY TRÌ BẬT/TẮT CHẠY TỰ ĐỘNG (START / STOP / ESTOP) ]
  X40         M106        X41         X49         M102              M101
--[ ]---+-----[/]---------[/]---------[/]---------[/]----------------( )--- (Cmd_Auto_Run)
 (Start)|    (Fault)     (Stop)      (EStop)     (Jog)
  M101  |
--[ ]---+
(Duy trì)

[ RUNG 3: MẠCH NHẤP BÒ LUỒN MÀNG (JOG CRAWL - KHÔNG DUY TRÌ) ]
  X43         M101        M106        X49                           M102
--[ ]---------[/]---------[/]---------[/]----------------------------( )--- (Cmd_Jog_Crawl)
 (Jog)       (AutoRun)   (Fault)     (EStop)

[ RUNG 4: ĐIỀU KHIỂN VAN KHÍ NÉN PEN ÉP LÔ CAO SU ]
  X42         X49                                                   Y50
--[ ]---+-----[/]----------------------------------------------------( )--- (Van ép Pen màng)
(Ctac ép)|   (EStop)
  M101  |
--[ ]---+
(AutoRun)

[ RUNG 5: ĐIỀU KHIỂN BƠM DẦU TRỤC TRÁNG DẦU S (CHẠY KHI MÁY RUN HOẶC JOG) ]
  M101                                                              Y51
--[ ]---+------------------------------------------------------------( )--- (Bơm dầu Lô S)
(AutoRun)|
  M102  |
--[ ]---+
 (Jog)

[ RUNG 6: ĐÈN THÁP BÁO MÁY HOẠT ĐỘNG ]
  M101                                                              Y53
--[ ]----------------------------------------------------------------( )--- (Đèn Tháp Xanh)

[ RUNG 7: CÒI BÁO ĐỘNG SỰ CỐ (KHI CÓ LỖI SERVO HOẶC ĐỨT MÀNG) ]
  M106                                                              Y52
--[ ]---+------------------------------------------------------------( )--- (Còi Báo Động)
(Servo) |
  M107  |
--[ ]---+
(Đứt màng)

[ RUNG 8: ĐỒNG BỘ TRẠNG THÁI SANG THANH GHI D100 CHO CHƯƠNG TRÌNH ST ]
  M101                                                    [ MOV K1 D100 ] (State = 1: Auto Run)
--[ ]-----------------------------------------------------
  M102                                                    [ MOV K3 D100 ] (State = 3: Jog Crawl)
--[ ]-----------------------------------------------------
  M101        M102                                        [ MOV K0 D100 ] (State = 0: Stop)
--[/]---------[/]-----------------------------------------
```

---

## 📌 PHẦN 4: MÃ LỆNH GÕ PHÍM TRỰC TIẾP TRONG GX WORKS2 (INSTRUCTION LIST)

Nếu bạn gõ phím trực tiếp trong màn hình soạn thảo Ladder của GX Works2, hãy nhập tuần tự theo danh sách lệnh sau:

```text
Step 0:   LD   X44
Step 1:   AND  X45
Step 2:   AND  X46
Step 3:   AND  X47
Step 4:   AND  X48
Step 5:   OUT  M105

Step 6:   LDI  M105
Step 7:   OUT  M106

Step 8:   LD   X40
Step 9:   OR   M101
Step 10:  ANI  M106
Step 11:  ANI  X41
Step 12:  ANI  X49
Step 13:  ANI  M102
Step 14:  OUT  M101

Step 15:  LD   X43
Step 16:  ANI  M101
Step 17:  ANI  M106
Step 18:  ANI  X49
Step 19:  OUT  M102

Step 20:  LD   X42
Step 21:  OR   M101
Step 22:  ANI  X49
Step 23:  OUT  Y50

Step 24:  LD   M101
Step 25:  OR   M102
Step 26:  OUT  Y51

Step 27:  LD   M101
Step 28:  OUT  Y53

Step 29:  LD   M106
Step 30:  OR   M107
Step 31:  OUT  Y52

Step 32:  LD   M101
Step 33:  MOV  K1   D100

Step 34:  LD   M102
Step 35:  MOV  K3   D100

Step 36:  LDI  M101
Step 37:  ANI  M102
Step 38:  MOV  K0   D100
```
