# 📖 TÀI LIỆU HƯỚNG DẪN & SƠ ĐỒ LADDER LOGIC MÁY GHÉP MÀNG METALIZE

Tập tin này mô tả chi tiết toàn bộ các Network/Rung của chương trình Ladder trên **Mitsubishi Q-Series (Q02U)** kết nối **CC-Link (QJ61BT11N)**.

---

## 📌 DANH SÁCH CÁC NETWORK LADDER CHÍNH

### 🔹 Network 1: Khởi Tạo Mạng CC-Link & Cho Phép Chuyển Đổi A/D, D/A
* **Điều kiện:** Khi CC-Link không có lỗi (`NOT SB0020` và `NOT SB0049`).
* **Hành động:** Kích cuộn `M1208` (cho phép A/D 64AD) và `M1240` (cho phép D/A 68DAVN).

```
|---[ / SB0020 ]---[ / SB0049 ]---+---( M1208 )---|  (RY8: Cho phép A/D Trạm 1)
                                  |
                                  +---( M1240 )---|  (RY28: Cho phép D/A Trạm 2)
```

---

### 🔹 Network 2: Đọc 4 Kênh ADC Loadcell (`D500..D503`) Quy Đổi Ra `%` (`D600..D603`)
* **Điều kiện:** Khi có cờ `M1016` (RX8 - A/D chuyển đổi xong).

```
|---[ M1016 ]---+---[ MUL D500 K1000 D10 ]---[ DIV D10 K4000 D600 ]---| (CH1: Loadcell Thu T)
                |
                +---[ MUL D501 K1000 D12 ]---[ DIV D12 K4000 D601 ]---| (CH2: Loadcell Xả X1)
                |
                +---[ MUL D502 K1000 D14 ]---[ DIV D14 K4000 D602 ]---| (CH3: Loadcell Thắng M)
                |
                +---[ MUL D503 K1000 D16 ]---[ DIV D16 K4000 D603 ]---| (CH4: Loadcell Xả U)
```

---

### 🔹 Network 3: Xuất 8 Kênh DAC Tốc Độ / Torque (`D524..D531`)
* **Điều kiện:** Khi có cờ `M1064` (RX38 - DAC sẵn sàng).

```
|---[ M1064 ]---+---[ MUL D610 K4000 D20 ]---[ DIV D20 K1000 D524 ]---| (CH1: Speed Thu T)
                |
                +---[ MUL D611 K4000 D22 ]---[ DIV D22 K1000 D525 ]---| (CH2: Torque Thu T)
                |
                +---[ MUL D612 K4000 D24 ]---[ DIV D24 K1000 D526 ]---| (CH3: Speed Xả X1)
                |
                +---[ MUL D613 K4000 D26 ]---[ DIV D26 K1000 D527 ]---| (CH4: Speed Master X2)
                |
                +---[ MUL D614 K4000 D28 ]---[ DIV D28 K1000 D528 ]---| (CH5: Speed Ghép Ms)
                |
                +---[ MUL D615 K4000 D30 ]---[ DIV D30 K1000 D529 ]---| (CH6: Torque Thắng M)
                |
                +---[ MUL D616 K4000 D32 ]---[ DIV D32 K1000 D530 ]---| (CH7: Speed Tráng Dầu S)
                |
                +---[ MUL D617 K4000 D34 ]---[ DIV D34 K1000 D531 ]---| (CH8: Speed Xả U)
```

---

### 🔹 Network 4: Khởi Động / Dừng Máy Ghép (State Machine & Mạch Tự Giữ)
* **Bảo vệ 5 trục Servo Ready:** Nếu bất kỳ trục nào mất Ready (`X40..X44`), cuộn `M134` sẽ ON để ngắt dừng máy ngay lập tức.
* **Mạch tự giữ:** Nút Start (`M102` HMI / `X49` vật lý) + Duy trì `M100` + Ngắt Stop (`M103` HMI / `X4A` vật lý / `M134` lỗi).

```
|---[ / X40 ]---+---( M134 )---| (Lỗi Servo Ready ngắt máy)
|---[ / X41 ]---|
|---[ / X42 ]---|
|---[ / X43 ]---|
|---[ / X44 ]---|

|---+---[ M102 ]---+---[ / M103 ]---[ / X4A ]---[ / M134 ]---( M100 )---| (M100: Máy chạy)
    |              |
    +---[ X49  ]---+
    |              |
    +---[ M100 ]---+
```

---

### 🔹 Network 5: Xuất 5 Trục Servo ON Ra Module 16DT (`M1304..M1308`)

```
|---[ M100 ]---+---( M1304 )---| (Cọc 1 Y8: Servo ON Thu T)
               |
               +---( M1305 )---| (Cọc 2 Y9: Servo ON Xả X1)
               |
               +---( M1306 )---| (Cọc 3 YA: Servo ON Master X2)

|---+---[ M100 ]---+---( M1307 )---| (Cọc 4 YB: Servo ON Ghép Ms - Tự chạy khi rửa máy X47)
    |              |
    +---[ X47  ]---+

|---+---[ M100 ]---+---( M1308 )---| (Cọc 5 YC: Servo ON Tráng Dầu S - Tự chạy khi rửa máy X48)
    |              |
    +---[ X48  ]---+
```

---

### 🔹 Network 6: Điều Khiển 2 Van Pen Ép Màng Ra Module 16DT (`M1309`, `M1310`)
* **Nút bấm Toggle:** Nút nhấn `X52` hoặc HMI `M115` đảo trạng thái Pen 1 (`FF M152`).
* **Tự nhả khi chạy chậm:** Khi tốc độ $\le 2.0\text{ m/p}$ (`D730 <= K20`) hoặc máy dừng (`NOT M100`), tự Reset `RST M152`, `RST M153`.

```
|---+---[ X52  ]---+---[ PLS M150 ]---|
    |              |
    +---[ M115 ]---+

|---[ M150 ]---[ FF M152 ]---| (Đảo trạng thái Pen 1)

|---+---[ <= D730 K20 ]---+---[ RST M152 ]---| (Tự nhả Pen 1 khi chậm/dừng)
    |                     |
    +---[ / M100      ]---+

|---[ M152 ]---( M1309 )---| (Cọc 6 YD: Kích van Solenoid Pen 1)
```

---

### 🔹 Network 7: Bắt Xung Cảm Biến Tiệm Cận Đo Đường Kính (`X50`, `X51`)
* Sử dụng lệnh bắt sườn lên `PLS` để đếm chính xác số vòng quay từng cuộn ở tốc độ $100\text{ m/phút}$.

```
|---[ X50 ]---[ PLS M160 ]---|
|---[ M160 ]---[ INCP D780 ]---| (Đếm số vòng quay Cuộn M)

|---[ X51 ]---[ PLS M161 ]---|
|---[ M161 ]---[ INCP D782 ]---| (Đếm số vòng quay Cuộn U)
```

---

### 🔹 Network 8: Cờ Xung Chuẩn 10ms Kích Hoạt PID Lực Căng (`SM409`)

```
|---[ SM409 ]---[ PLS M170 ]---| (M170: Cờ xung 10ms cố định chạy thuật toán PID)
```

---

### 🔹 Network 9: Báo Lỗi & Reset Hệ Thống

```
|---+---[ SB0020 ]---+---( M1311 )---| (Cọc 8 YF: Đèn / Còi báo lỗi trạm CC-Link)
    |                |
    +---[ SB0049 ]---+
    |                |
    +---[ M1032  ]---+
    |                |
    +---[ M1066  ]---+

|---+---[ M1111 ]---+---( M1226 )---| (Reset lỗi Trạm 1 ADC)
    |               |
    +---[ M101  ]---+---( M1258 )---| (Reset lỗi Trạm 2 DAC)
```

---

## 🛠️ HƯỚNG DẪN IMPORT FILE ASC VÀO GX WORKS2 (CHẾ ĐỘ LADDER):
1. Trong GX Works2, tạo một chương trình POU mới với **Program Type: `Ladder`**.
2. Mở file [pou01_ladder_asc.asc](file:///d:/data-2026/lap_top/GHEP-MITSU_BACKUP/pou01_ladder_asc.asc).
3. Copy toàn bộ nội dung mã lệnh và dán trực tiếp vào màn hình soạn thảo dạng Instruction List $\rightarrow$ Nhấn **F4 (Compile / Convert)**.
4. GX Works2 sẽ tự động vẽ toàn bộ sơ đồ tiếp điểm Ladder trực quan, sinh động ngay lập tức!
