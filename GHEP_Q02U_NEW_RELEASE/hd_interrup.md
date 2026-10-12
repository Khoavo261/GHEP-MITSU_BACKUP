# ⚡ HƯỚNG DẪN XỬ LÝ & ĐẤU NỐI CẢM BIẾN ĐO ĐƯỜNG KÍNH CUỘN M & U (QX40 X4A / X4B)

> **Hệ thống:** Mitsubishi Q-Series (CPU Q02U)  
> **Bộ đếm chính:** Module QD62D Slot 3 CH1 (`U3\G2`) đo xung trục chính Master X2.  
> **Cảm biến:** 2 cảm biến tiệm cận NPN đo 1 vòng quay cuộn Xả M và cuộn Xả U.

---

## 📌 1. NGUYÊN NHÂN GỐC RỄ: TẠI SAO NGẮT I50, I52 TRÊN QD62 KHÔNG CHẠY?

1. **Đặc tính phần cứng QD62 (Hardware Invariant):**
   - Theo tài liệu chuẩn của Mitsubishi (*MELSEC-Q High-Speed Counter Module User's Manual*), module **QD62 chỉ hỗ trợ đúng 4 nguồn ngắt phần cứng (SI 0 ~ SI 3)**, và cả 4 nguồn này **CHỈ KÍCH HOẠT KHI XẢY RA COINCIDENCE OUTPUT (SO SÁNH BẰNG TRỊ SỐ ĐẾM XUNG)**:
     - `SI 0`: CH1 Coincidence detection point 1
     - `SI 1`: CH1 Coincidence detection point 2
     - `SI 2`: CH2 Coincidence detection point 1
     - `SI 3`: CH2 Coincidence detection point 2
   - Chân ngõ vào **Preset (B10)** và **Function Start (B08)** của QD62 chỉ là ngõ vào chức năng nội bộ (kích Preset counter hoặc kích Latch counter), **hoàn toàn KHÔNG tạo tín hiệu ngắt SI (System Interrupt) gửi về CPU Q**.

2. **Cấu hình sai dải SI trong bảng Interrupt Pointer Setting:**
   - Khi cấu hình `Start SI No. = 3` với `Count = 3`:
     - `I50` trỏ tới `SI 3` (là CH2 Coincidence point 2, không liên quan đến chân B10).
     - `I51` trỏ tới `SI 4` (QD62 **không có** SI 4).
     - `I52` trỏ tới `SI 5` (QD62 **không có** SI 5).
   - Do đó, CPU Q **không bao giờ nhận được tín hiệu kích ngắt từ phần cứng để nhảy vào I50 và I52**.

---

## 📌 2. GIẢI PHÁP CHUẨN CÔNG NGHIỆP: CHUYỂN CẢM BIẾN VỀ MODULE DIGITAL IN QX40

### 🔹 2.1 Tại sao dùng QX40 lại chính xác 100%?
* Cuộn xả có đường kính từ lõi $76\text{ mm}$ đến tối đa $600\text{ mm} \sim 800\text{ mm}$.
* Tốc độ máy lớn nhất $100\text{ m/phút}$.
* Khi cuộn sắp hết lõi ($76\text{ mm}$), chu vi $C \approx 0.239\text{ m}$, tốc độ quay lớn nhất chỉ đạt:
  $$\frac{100\text{ m/phút}}{0.239\text{ m}} \approx 418\text{ RPM} \approx 6.9\text{ vòng/giây (khoảng 7 Hz)}$$
* Chu kỳ 1 vòng quay là $\approx 145\text{ ms}$, xung kim loại cảm biến đi qua kéo dài $10\text{ ms} \sim 30\text{ ms}$.
* Trong khi đó, chu kỳ quét (Scan Time) của CPU Q02U chỉ **$1.5\text{ ms} \sim 2.5\text{ ms}$**.
* Do đó, chu kỳ quét thông thường bắt trọn vẹn 100% sườn lên của cảm biến mà không cần ngắt phần cứng, triệt tiêu hoàn toàn rủi ro cấu hình sai.

---

### 🔹 2.2 Sơ đồ đấu dây chính xác (Module QX40 tại Slot 4: X40 ~ X4F)

Sử dụng 2 địa chỉ đã được quy hoạch sẵn trong `device_comments_X.csv`:
* **`X4A`**: `Sensor tiem can 1 vong cuon M`
* **`X4B`**: `Sensor tiem can 1 vong cuon U`

```
  [ NGUỒN 24VDC NGOÀI ]          [ CẢM BIẾN NPN 3 DÂY ]          [ MODULE QX40 (SLOT 4) ]

  (+) +24VDC ───┬──────────────► Dây Nâu (+V Sensor M & U)
                └─────────────────────────────────────────────► Chân COM (Cực chung QX40)

  (-)  0VDC  ───┬──────────────► Dây Xanh (0V Sensor M & U)
                │
                │  [Sensor Cuộn M]
                ├─────────────── Dây Đen (OUT NPN) ────────────► Chân ngõ vào X4A
                │
                │  [Sensor Cuộn U]
                └─────────────── Dây Đen (OUT NPN) ────────────► Chân ngõ vào X4B
```

---

## 📌 3. MÃ NGUỒN ĐÃ ĐƯỢC TÍCH HỢP TRONG `pou_main_scan_program.st`

Đoạn mã sau đã được thêm trực tiếp vào chương trình quét chính:

```iecst
(* ============================================================================ *)
(* 10.1. TÍNH ĐƯỜNG KÍNH CUỘN XẢ METALIZE M (SƯỜN LÊN CẢM BIẾN X4A)             *)
(* ============================================================================ *)
IF (Sensor_Rev_M AND NOT M_Sensor_Rev_M_Last) THEN
    Rev_Count_M := Rev_Count_M + 1;
    Curr_Pulse_X2_Now := Curr_Pulse_X2; (* Đọc trực tiếp xung Master X2 *)
    Delta_Pulse_M := Curr_Pulse_X2_Now - Last_Pulse_X2_M;

    IF (State_Machine = 1) AND (Delta_Pulse_M > 0) AND (Total_PPR > 0) AND (Gear_Ratio_X2 > 0.0) THEN
        Raw_Dia_M_mm := (DINT_TO_REAL(Delta_Pulse_M) * Dia_X2_Roller_mm * Gear_Ratio_M) 
                        / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);

        IF Raw_Dia_M_mm < Core_Dia_M_mm THEN 
            Raw_Dia_M_mm := Core_Dia_M_mm; 
        END_IF;
        IF Raw_Dia_M_mm > Max_Dia_M_mm THEN 
            Raw_Dia_M_mm := Max_Dia_M_mm; 
        END_IF;

        (* Bộ lọc quán tính 80/20 giúp ổn định lực căng PID thắng từ M *)
        Real_Dia_M_mm := Real_Dia_M_mm + ((Raw_Dia_M_mm - Real_Dia_M_mm) * 0.2);
    END_IF;

    Last_Pulse_X2_M := Curr_Pulse_X2_Now;
END_IF;
M_Sensor_Rev_M_Last := Sensor_Rev_M;

(* ============================================================================ *)
(* 10.2. TÍNH ĐƯỜNG KÍNH CUỘN XẢ GIẤY U (SƯỜN LÊN CẢM BIẾN X4B)                 *)
(* ============================================================================ *)
IF (Sensor_Rev_U AND NOT M_Sensor_Rev_U_Last) THEN
    Rev_Count_U := Rev_Count_U + 1;
    Curr_Pulse_X2_Now := Curr_Pulse_X2;
    Delta_Pulse_U := Curr_Pulse_X2_Now - Last_Pulse_X2_U;

    IF (State_Machine = 1) AND (Delta_Pulse_U > 0) AND (Total_PPR > 0) AND (Gear_Ratio_X2 > 0.0) THEN
        Raw_Dia_U_mm := (DINT_TO_REAL(Delta_Pulse_U) * Dia_X2_Roller_mm * Gear_Ratio_U) 
                        / (DINT_TO_REAL(Total_PPR) * Gear_Ratio_X2);

        IF Raw_Dia_U_mm < Core_Dia_U_mm THEN 
            Raw_Dia_U_mm := Core_Dia_U_mm; 
        END_IF;
        IF Raw_Dia_U_mm > Max_Dia_U_mm THEN 
            Raw_Dia_U_mm := Max_Dia_U_mm; 
        END_IF;

        (* Bộ lọc quán tính 80/20 cấp điều khiển thắng từ cuộn U *)
        Real_Dia_U_mm := Real_Dia_U_mm + ((Raw_Dia_U_mm - Real_Dia_U_mm) * 0.2);
    END_IF;

    Last_Pulse_X2_U := Curr_Pulse_X2_Now;
END_IF;
M_Sensor_Rev_U_Last := Sensor_Rev_U;
```

---

## 📌 4. THAO TÁC CẦN LÀM TRÊN GX WORKS2

1. **Xóa cấu hình ngắt QD62 cũ trong PLC Parameter:**
   - Mở **Parameter** $\rightarrow$ **PLC Parameter** $\rightarrow$ **PLC System** $\rightarrow$ **Intelligent function module setting** $\rightarrow$ **Interrupt Pointer Settings**.
   - Xóa bỏ dòng cấu hình `Start I/O 0010` (QD62).
2. **Xóa POU ngắt không cần thiết trong Program Setting:**
   - Trong tab **Program Setting**: Xóa bỏ các POU ngắt `POU_INT_I50`, `POU_INT_I52` (hoặc `TASK_INT_M`, `TASK_INT_U`).
3. **Cập nhật Global Label:**
   - Copy nội dung mới nhất trong [global_labels_paste.tsv](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/GHEP_Q02U_NEW_RELEASE/global_labels_paste.tsv) dán vào bảng **Global_Variables** của GX Works2 (đã bổ sung 2 cờ sườn lên `M_Sensor_Rev_M_Last` tại `M70` và `M_Sensor_Rev_U_Last` tại `M71`).
4. **Rebuild & Nạp xuống PLC:**
   - Bấm **F4 (Rebuild All)**.
   - Nạp xuống PLC (**Online $\rightarrow$ Write to PLC**), chọn cả **Parameter + Program**.
   - Bật công tắc PLC sang **STOP $\rightarrow$ RESET $\rightarrow$ RUN**.
