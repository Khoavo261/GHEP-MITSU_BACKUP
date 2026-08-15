# HƯỚNG DẪN TẠO CHƯƠNG TRÌNH CON (SUBROUTINE / FUNCTION BLOCK) TRÊN GX WORKS2

Có 2 cách chuyên nghiệp nhất để đóng gói mã nguồn `cclink_control` thành một **chương trình con** trong GX Works2:

---

## 🛠️ CÁCH 1: TẠO FUNCTION BLOCK (FB) TRONG STRUCTURED PROJECT (KHUYÊN DÙNG)

Cách này đóng gói chương trình thành 1 khối Function Block (FB) có ngõ vào `VAR_INPUT` và ngõ ra `VAR_OUTPUT` độc lập, tái sử dụng cực kỳ dễ dàng.

### Bước 1.1: Tạo Khối FB Mới
1. Trên cây thư mục **Project Tree** $\rightarrow$ Kéo xuống mục **`FB/FUN`**.
2. Nhấp chuột phải vào **`FB/FUN`** $\rightarrow$ Chọn **`Create New Data...`**
3. Điền thông tin:
   - **Data Name:** `FB_CCLINK_CONTROL`
   - **Data Type:** `FB`
   - **Program Language:** `ST (Structured Text)`
4. Nhấn **OK**.

### Bước 1.2: Nạp Mã Nguồn ST Cho FB
1. Mở file [`fb_cclink_control.st`](file:///d:/data-2026/GHEP-MITSU/fb_cclink_control.st) đã tạo trong thư mục `D:\data-2026\GHEP-MITSU\`.
2. Copy phần khai báo biến `VAR_INPUT`, `VAR_OUTPUT` vào cửa sổ **Local Label** của FB.
3. Copy toàn bộ mã logic trong thân khối paste vào cửa sổ chương trình ST của FB.

### Bước 1.3: Gọi Function Block Từ Chương Trình Chính (`POU_01`)
Trong chương trình chính (`POU_01` hoặc `Program`), khai báo 1 Instance (Biến khối FB):
- **Label Name:** `fbCCLink`
- **Data Type:** `FB_CCLINK_CONTROL`

Viết dòng lệnh gọi trong POU chính:
```pascal
(* Gọi chương trình con CC-Link *)
fbCCLink(
    Enable      := TRUE,
    ResetErr    := M0,          (* Nút reset lỗi *)
    DAC_CH1_Set := D610,        (* Cài đặt tốc độ CH1 *)
    DAC_CH2_Set := D611         (* Cài đặt tốc độ CH2 *)
);

(* Lấy giá trị đọc về từ chương trình con *)
D600 := fbCCLink.ADC_CH1_Val;  (* Đọc Analog CH1 *)
M10  := fbCCLink.CCLink_OK;    (* Báo truyền thông OK *)
```

---

## 🛠️ CÁCH 2: TẠO POU CHƯƠNG TRÌNH CON ĐỘC LẬP (SUBROUTINE POU)

Cách này tạo một file POU chương trình con riêng biệt trong danh sách **Program** và gọi qua nhiệm vụ quét (Task Execution).

### Bước 2.1: Tạo POU Chương Trình Con
1. Trên cây thư mục **Project Tree** $\rightarrow$ Nhấp chuột phải vào mục **`Program`** $\rightarrow$ Chọn **`Create New Data...`**
2. Điền thông tin:
   - **Data Name:** `Sub_CCLink`
   - **Program Language:** `ST` *(hoặc `Ladder`)*
3. Nhấn **OK**.

### Bước 2.2: Copy Code Vào `Sub_CCLink`
Copy toàn bộ nội dung từ file [`cclink_control.st`](file:///d:/data-2026/GHEP-MITSU/cclink_control.st) paste trực tiếp vào POU `Sub_CCLink`.

### Bước 2.3: Đăng Ký Chu Kỳ Chạy Cho Chương Trình Con (Program Setting)
Để chương trình con `Sub_CCLink` được PLC thực thi tự động theo chu kỳ:

1. Vào **`Project Tree`** $\rightarrow$ **`Parameter`** $\rightarrow$ **`PLC Parameter`** $\rightarrow$ Chọn thẻ **`Program`**.
2. Ở cột danh sách POU bên trái, chọn `Sub_CCLink` $\rightarrow$ Nhấn nút **`Insert`** để chuyển qua cột bên phải (Scan Execution Task List).
3. Nhấn **`Check`** $\rightarrow$ **`End`**.
4. Chọn **`Compile`** $\rightarrow$ **`Rebuild All`** (`Shift + Alt + F4`).

---

## 💡 BẢNG SO SÁNH NÊN CHỌN CÁCH NÀO?

| Tiêu Chí | Cách 1: Function Block (FB) | Cách 2: Subroutine POU |
| :--- | :--- | :--- |
| **Độ gọn gàng** | ⭐⭐⭐⭐⭐ (Đóng gói thành 1 khối gọn đẹp) | ⭐⭐⭐ (Nhiều POU riêng biệt) |
| **Truyền tham số** | Có ngõ vào `VAR_INPUT` & ngõ ra `VAR_OUTPUT` rõ ràng | Dùng chung thanh ghi toàn cục (`D`, `M`) |
| **Tính tái sử dụng** | Rất cao (Thả khối dùng nhiều lần) | Trung bình |
| **Độ dễ lập trình** | Phù hợp dự án Structured Project ST | Phù hợp dự án Ladder truyền thống |
