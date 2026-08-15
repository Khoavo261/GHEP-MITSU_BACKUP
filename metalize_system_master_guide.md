# KỊCH BẢN VẬN HÀNH TỔNG THỂ DÂY CHUYỀN MÁY GHÉP MÀNG METALIZE

Tài liệu thiết kế chi tiết toàn bộ quy trình công nghệ, phân bổ 6 trục cơ cấu (T, X1, X2, Ms, S, U), thắng từ M, thuật toán đo đường kính `X50`/`X51` và chu trình khởi động/dừng máy an toàn cho **PLC Mitsubishi Q02UCPU**.

---

## 📐 1. BẢNG THÔNG SỐ CƠ CẤU VÀ TỈ LỆ NỐI 6 TRỤC VẬN HÀNH

| Trục / Cơ Cấu | Chức Năng Kỹ Thuật | Tỷ Số Truyền Hộp Số (Gear) | Đường Kính Lô (Diameter) | Tín Hiệu Lực Căng (Loadcell ADC) | Tín Hiệu Xung / Cảm Biến |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Trục Thu T** | Thu cuộn màng thành phẩm (Giấy + Metalize) | **`10.1 / 1`** | `76mm` (Lõi) $\rightarrow$ Phồng to dần | **CH1 ADC** (`Weight_T` - `D500`) | QD62 #1 Kênh CH1 |
| **Trục X1** | Xả Giấy | **`8.0 / 1`** *(Chỉnh được)* | **`300.5 mm`** *(Chỉnh được)* | **CH2 ADC** (`Weight_X1` - `D501`) | QD62 #1 Kênh CH2 |
| **Trục X2** | Master tốc độ chuẩn dòng máy | **`8.0 / 1`** *(Chỉnh được)* | **`300.5 mm`** *(Chỉnh được)* | Synchronized Speed | QD62 #2 Kênh CH1 |
| **Trục S** | Trục Servo phủ hóa chất mỏng (Giữa X1 & X2) | **`10.0 / 1`** | **`100.0 mm`** | Sync Ratio theo Master | QD62 #3 Kênh CH1 |
| **Trục Ms** | Trục Servo ghép màng Metalize (Sau X2) | **`10.0 / 1`** | **`200.0 mm`** *(Chỉnh được)* | Vận tốc dài = Tốc độ X2 | QD62 #2 Kênh CH2 |
| **Thắng Từ M** | Giữ cuộn màng Metalize (Sau Ms) | Thắng Từ Torque | Giảm dần theo xả màng | **CH3 ADC** (`Weight_M` - `D502`) | **Cảm biến tiệm cận `X50`** |
| **Cuộn Xả U** | Cuộn xả màng phía sau cùng | Phanh hãm lực xả | Giảm dần theo xả màng | **CH4 ADC** (`Weight_U` - `D503`) | **Cảm biến tiệm cận `X51`** |

---

## 🔄 2. SƠ ĐỒ LUỒNG CÔNG NGHỆ DÂY CHUYỀN

```
[ Cuộn Xả U ] (Cân Weight_U - Sensor X51)
      │
      ▼
[ Trục X1 ] ◄── (Cân Weight_X1 Lực Căng Giấy) ──► [ Trục X2 Master ]
      │                                                │
  [ Trục S ] (Phủ Dầu Hóa Chất - Gear 10/1)           │
                                                       ▼
[ Cuộn Metalize M ] (Thắng Từ M - Weight_M - Sensor X50) ──► [ Trục Ghép Ms ] (Gear 10/1)
                                                                 │
                                                                 ▼
                                                        [ Cuộn Thu T ] (Gear 10.1/1 - Weight_T)
```

---

## 🌀 3. QUY TRÌNH NẠP THÔNG SỐ ĐƯỜNG KÍNH VÀ LỰC CĂNG

1. **Cuộn Xả Màng Metalize M (`X50` trên QX40):**
   - Cảm biến tiệm cận `X50` ngắt sườn lên báo 1 vòng quay của cuộn Metalize M.
   - PLC tính toán đường kính cuộn màng giảm dần và tự động quy đổi sinh ra lực Torque hãm phù hợp cho **Thắng Từ M** qua kênh DAC `D529`.
2. **Cuộn Xả Giấy Chính U (`X51` trên QX40):**
   - Cảm biến tiệm cận `X51` ngắt sườn lên báo 1 vòng quay của cuộn xả giấy U.
   - PLC tính toán đường kính giảm dần sinh ra lực hãm qua kênh DAC `D531` giữ vững lực căng `Weight_U`.
3. **Cuộn Thu T:**
   - Đọc xung đếm từ QD62 #1 CH1 qua tỷ số truyền **Gear `10.1/1`**. Đường kính cuộn thu `Real_Dia_T_mm` tăng dần để bù tốc độ và Torque xiết cuộn qua DAC `D524` & `D525`.

---

## 🚦 4. CHU TRÌNH TĂNG / GIẢM TỐC VÀ DỪNG MÁY CHUẨN CÔNG NGHIỆP

### 1. Thông số Tốc độ:
- **Tốc độ Max (`Max_Speed`):** **`100 m/phút`**
- **Tốc độ Khởi động / Tốc độ Min (`Min_Speed`):** **`2 m/phút`**

### 2. Các Phím Bấm Vận Hành Trên HMI:
- **Phím `START`:** Khởi động chạy máy.
- **Phím `STOP`:** Dừng máy an toàn.
- **Phím `INC` (Tăng tốc):** Nhấn giữ để tăng tốc độ máy lên.
- **Phím `DEC` (Giảm tốc):** Nhấn giữ để giảm tốc độ máy xuống.

### 3. Quy Trình Khởi Động Máy (Start Sequence):
- **Bước 1:** Nhấn phím **`START`** $\rightarrow$ PLC xuất lệnh cho 5 Servo ON, máy tự động tăng tốc từ `0` lên **`2 m/phút`** (Tốc độ khởi động).
- **Bước 2:** Máy duy trì chạy ở **`2 m/phút`** cho đến khi 4 kênh Loadcell (`Weight_T`, `Weight_X1`, `Weight_M`, `Weight_U`) đạt ổn định lực căng (Báo cờ `Tension_Stable = TRUE`).
- **Bước 3:** Khi lực căng đã ổn định, người vận hành nhấn giữ phím **`INC`** $\rightarrow$ Máy bắt đầu tăng tốc độ lên từ `2 m/phút` hướng tới `100 m/phút`. **Nhấn giữ `INC` càng lâu thì máy tăng tốc càng nhanh!**
- **Bước 4:** Nếu nhấn phím **`DEC`**, máy sẽ giảm tốc độ dần về lại mức mong muốn.

### 4. Quy Trình Dừng Máy (Stop Sequence):
- **Trường hợp Dừng Thủ Công (Bấm `STOP`):** 
  Nhấn phím **`STOP`** $\rightarrow$ Máy tự động giảm tốc từ tốc độ hiện tại về đúng **`2 m/phút`** (Tốc độ Min), duy trì xả nốt dư lực căng trong 2 giây rồi mới ngắt Servo dừng hoàn toàn!
- **Trường hợp Dừng Tự Động Theo Chiều Dài (Target Length Reached):** 
  Khi tổng số mét hàng chạy được (`Total_Length_Meters`) đạt tới số mét cài đặt trên HMI (`Set_Target_Length`) $\rightarrow$ Máy tự động giảm tốc từ tốc độ cao về **`2 m/phút`**, chạy đủ mét lẻ rồi ngắt Servo dừng máy êm ái tuyệt đối!

---

👉 **Bạn kiểm tra toàn bộ kịch bản quy hoạch chuẩn công nghiệp này xem đã hoàn toàn chính xác với yêu cầu của bạn chưa nhé!**
