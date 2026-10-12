# 📘 HƯỚNG DẪN TẠO & GỌI HÀM PID TRUYỀN THAM SỐ (FUNCTION BLOCK)
## DỰ ÁN: MÁY GHÉP MÀNG METALIZE TỰ ĐỘNG - PLC MITSUBISHI Q02U
### THƯ MỤC: `ST_LATCH_GHEP`

---

## 📌 PHẦN 1: BẢN CHẤT CỦA FUNCTION BLOCK (FB) TRONG GX WORKS2
- **Function Block (FB)** giống như một "khuôn đúc" hay một chương trình con độc lập có bộ nhớ riêng.
- Khi tạo xong khối **`FB_TENSION_PID`**, bạn có thể dùng lại khối này cho **bất kỳ trục nào** (Cuộn Thu T, Trục Kéo X1, Thắng M, Xả U) chỉ bằng cách đặt tên một **Instance** (thể hiện) riêng cho trục đó:
  - `fb_PID_T` : Quản lý PID cho trục Thu T.
  - `fb_PID_X1`: Quản lý PID cho trục Kéo X1.
  - `fb_PID_M` : Quản lý PID cho thắng từ Xả M.
  - `fb_PID_U` : Quản lý PID cho cuộn Xả U.
- Các trục hoàn toàn độc lập, không bị chồng chéo tích phân hay biến số của nhau!

---

## 📌 PHẦN 2: CÁC BƯỚC TẠO KHỐI `FB_TENSION_PID` TRONG GX WORKS2

### 🔹 Bước 1: Tạo mới Function Block
1. Mở GX Works2.
2. Ở cửa sổ **Project Tree** bên trái, tìm mục **FB/FUN** (hoặc **Function Block**).
3. Chuột phải vào **FB/FUN** $\rightarrow$ chọn **New Data...**:
   - **Data Type:** Chọn **Function Block**.
   - **Data Name:** Gõ tên: `FB_TENSION_PID`
   - **Program Language:** Chọn: **Structured Text (ST)**
4. Nhấn **OK**.

---

### 🔹 Bước 2: Dán bảng tham số vào Local Labels của FB
1. Mở rộng cây thư mục `FB_TENSION_PID` $\rightarrow$ nhấp đúp vào **Local Label**.
2. Mở file [08_FB_PID_LOCAL_LABELS.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/08_FB_PID_LOCAL_LABELS.tsv) bằng Notepad hoặc Excel:
   - Nhấn `Ctrl + A` $\rightarrow$ `Ctrl + C` để copy toàn bộ bảng.
3. Trong bảng Local Label của GX Works2:
   - Bấm vào ô trống đầu tiên (cột Class), nhấn `Ctrl + V` để dán.
   - Bạn sẽ thấy đầy đủ các tham số:
     * `VAR_INPUT`: `Enable`, `Reset`, `Setpoint`, `Feedback`, `Kp`, `Ki`, `Kd`, `Deadband`, `Out_Min`, `Out_Max`, `AT_Enable`, `AT_Step`.
     * `VAR_OUTPUT`: `PID_Output`, `Error`, `AT_Done`, `AT_Busy`, `Tuned_Kp`, `Tuned_Ki`, `Tuned_Kd`.
     * `VAR` (nội bộ): `I_Term`, `P_Term`, `D_Term`...

---

### 🔹 Bước 3: Dán mã thuật toán ST vào ruột khối FB
1. Trong `FB_TENSION_PID`, nhấp đúp vào mục **Body** (hoặc chương trình ST của FB).
2. Mở file [07_FB_TENSION_PID.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/07_FB_TENSION_PID.st), copy toàn bộ nội dung dán vào.
3. Nhấn **F4 (Build)**: Đảm bảo báo **0 Error**. Khối FB của bạn đã hoàn thành!

---

## 📌 PHẦN 3: CÁCH GỌI VÀ TRUYỀN PARAMETER TRONG STRUCTURED TEXT (ST)

Trong chương trình ST (ví dụ trong file [03_MAIN_CALC_ST.st](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/ST_LATCH_GHEP/03_MAIN_CALC_ST.st)):

### 🔹 Bước 1: Khai báo Instance cho từng trục
Trong **Global Label** (hoặc Local Label của POU gọi nó), bạn khai báo:
```text
Class       Label Name     Data Type
VAR_GLOBAL  fb_PID_T       FB_TENSION_PID
VAR_GLOBAL  fb_PID_X1      FB_TENSION_PID
```

### 🔹 Bước 2: Cú pháp gọi truyền Parameter cho từng trục:

```pascal
(* ============================================================================ *)
(* GỌI PID CHO TRỤC CUỘN THU T                                                 *)
(* ============================================================================ *)
fb_PID_T(
    Enable    := (State_Machine = 1),      (* Bật khi máy chạy Auto *)
    Reset     := (State_Machine = 0),      (* Reset tích phân khi dừng *)
    Setpoint  := Set_Tension_T,            (* Cài đặt lực căng: D130 *)
    Feedback  := Act_Tension_T,            (* Phản hồi từ Loadcell T: D140 *)
    Kp        := Kp_T,                     (* Hệ số Kp: D340 *)
    Ki        := Ki_T,                     (* Hệ số Ki: D342 *)
    Kd        := Kd_T,                     (* Hệ số Kd: D344 *)
    Deadband  := 0.2,                      (* Vùng chết 0.2 kg chống rung *)
    Out_Min   := -200.0,                   (* Giới hạn bù tốc tối thiểu -200 RPM *)
    Out_Max   := 200.0,                    (* Giới hạn bù tốc tối đa +200 RPM *)
    AT_Enable := HMI_Cmd_AutoTune,         (* Lệnh bật Auto-Tuning từ HMI *)
    AT_Step   := 500.0                     (* Bước nhay test Auto-Tune *)
);

(* Lấy kết quả đầu ra của FB để cộng vào tốc độ đồng bộ *)
PID_Out_T   := fb_PID_T.PID_Output;
Final_RPM_T := Sync_RPM_T + PID_Out_T;


(* ============================================================================ *)
(* GỌI PID CHO TRỤC KÉO X1                                                     *)
(* ============================================================================ *)
fb_PID_X1(
    Enable    := (State_Machine = 1),
    Reset     := (State_Machine = 0),
    Setpoint  := Set_Tension_X1,           (* Cài đặt lực căng: D132 *)
    Feedback  := Act_Tension_X1,           (* Phản hồi Loadcell X1: D142 *)
    Kp        := Kp_X1,                    (* Kp: D346 *)
    Ki        := Ki_X1,                    (* Ki: D348 *)
    Kd        := Kd_X1,                    (* Kd: D350 *)
    Deadband  := 0.1,
    Out_Min   := -100.0,
    Out_Max   := 100.0,
    AT_Enable := FALSE,
    AT_Step   := 0.0
);

PID_Out_X1   := fb_PID_X1.PID_Output;
Final_RPM_X1 := Sync_RPM_X1 + PID_Out_X1;
```

---

## 📌 PHẦN 4: CÁCH GỌI VÀ TRUYỀN PARAMETER TRONG SƠ ĐỒ LADDER

Nếu bạn muốn gọi Function Block này trong chương trình **LADDER** (ví dụ trong file `MAIN_LOGIC`):

### 🔹 Cách thao tác trên giao diện GX Works2:
1. Mở chương trình Ladder.
2. Di chuyển con trỏ đến vị trí muốn đặt khối PID.
3. Nhấn phím **F8** (hoặc chọn biểu tượng Box trên thanh công cụ).
4. Trong ô nhập lệnh, gõ:
   ```text
   fb_PID_T
   ```
   *(Trong đó `fb_PID_T` là tên Instance có kiểu dữ liệu là `FB_TENSION_PID`)*.
5. Nhấn **Enter**: Khối hàm sẽ hiện ra thành một hộp chữ nhật trực quan!

### 🔹 Sơ đồ tiếp điểm Ladder khi kết nối các chân:

```text
  M101 (Auto Run)
--[ ]----------------------------+
                                 │
                                ┌┴─────────────────────────────────┐
                                │            fb_PID_T              │
                                │         FB_TENSION_PID           │
                                ├──────────────────────────────────┤
                                │ EN                               │
     M101 (Auto Run) ───────────┤ Enable                PID_Output ├────── D570 (PID_Out_T)
     M100 (Stop) ───────────────┤ Reset                      Error ├────── D572 (Err_T)
     D130 (Set_Tension_T) ──────┤ Setpoint                 AT_Done ├────── M43  (AT_Done)
     D140 (Act_Tension_T) ──────┤ Feedback                 AT_Busy ├────── M42  (AT_Busy)
     D340 (Kp_T) ───────────────┤ Kp                      Tuned_Kp ├────── D574 (Tuned_Kp)
     D342 (Ki_T) ───────────────┤ Ki                      Tuned_Ki ├────── D576 (Tuned_Ki)
     D344 (Kd_T) ───────────────┤ Kd                      Tuned_Kd ├────── D578 (Tuned_Kd)
     E0.2 (0.2 kg) ─────────────┤ Deadband                         │
     E-200.0 ───────────────────┤ Out_Min                          │
     E200.0 ────────────────────┤ Out_Max                          │
     M40 (AutoTune) ────────────┤ AT_Enable                        │
     E500.0 ────────────────────┤ AT_Step                          │
                                └──────────────────────────────────┘
```

> 💡 **Mẹo nhập số thực (REAL) trong Ladder Mitsubishi:**
> - Số thực có dấu chấm động trong Ladder gõ bằng tiền tố **`E`** (ví dụ: `E0.2` = 0.2, `E200.0` = 200.0, `E-200.0` = -200.0).

---

## 📌 PHẦN 5: TÓM TẮT ƯU ĐIỂM
1. **Tái sử dụng tuyệt đối:** Chỉ cần viết thuật toán PID đúng 1 lần, sau đó gọi ra cho 5 trục, 10 trục chỉ bằng cách gõ tên Instance.
2. **Online giám sát dễ dàng:** Bạn có thể mở trực tiếp Instance `fb_PID_T` trong GX Works2 để xem đồ thị đường cong PID, độ lệch Error, tích lũy `I_Term` và kết quả Auto-Tuning tức thời!
