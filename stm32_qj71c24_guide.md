# HƯỚNG DẪN KẾT NỐI TRUYỀN THÔNG STM32 VỚI PLC MITSUBISHI Q02U (QJ71C24N-R4 KÊNH CH2)

Tài liệu chi tiết hướng dẫn sơ đồ đấu nối phần cứng và viết code C (STM32 HAL Library) truyền thông đọc/ghi dữ liệu PLC Q02U qua cổng Kênh CH2 của module `QJ71C24N-R4`.

---

## 🔌 1. SƠ ĐỒ ĐẤU NỐI PHẦN CỨNG (STM32 $\leftrightarrow$ MAX3485 $\leftrightarrow$ QJ71C24N-R4 CH2)

Vì STM32 dùng điện áp UART 3.3V TTL, nên bắt buộc sử dụng **Module chuyển đổi TTL sang RS-485 (chip MAX3485 hoặc SP3485 3.3V)**.

### Sơ đồ dây nối:
```
[ STM32 Microcontroller ]          [ Module MAX3485 (3.3V) ]           [ QJ71C24N-R4 (Kênh CH2) ]
  3.3V  --------------------------> VCC
  GND   --------------------------> GND ------------------------------> SG (Chân Mass tín hiệu)
  PA9   (USART1_TX) --------------> DI  (Data In)
  PA10  (USART1_RX) --------------> RO  (Receive Out)
  PA8   (GPIO_Control) -----------> DE & RE (Nối chập DE+RE)
                                    A (Data+) ------------------------> Nối chập SDA + RDA
                                    B (Data-) ------------------------> Nối chập SDB + RDB
```

---

## ⚙️ 2. CẤU HÌNH PARAMETER TRÊN GX WORKS2 CHO KÊNH CH2

Vào **`PLC Parameter`** $\rightarrow$ **`I/O Assignment`** $\rightarrow$ **`Switch Setting`** tại Slot module `QJ71C24N-R4`:

- **Switch 3 (Cấu hình CH2):** Nhập mã HEX **`0066`**
  - *(Mã `0066`: Giao thức Dedicated MC Protocol Format 4, Tốc độ **9600 bps**, Data bit **8**, Parity **Odd**, Stop bit **1**)*.
- **Switch 4 (Địa chỉ trạm CH2):** Nhập **`0000`**
- **Switch 5 (Chế độ RS-485 2 dây):** Nhập **`0001`** *(Tắt tiếng vọng Echo back)*.

---

## 💻 3. MÃ NGUỒN C MẪU TRÊN STM32 (STM32CUBE IDE / HAL LIBRARY)

Khung truyền MC Protocol Format 4 cực kỳ đơn giản. Để đọc 1 thanh ghi `D500` từ PLC, STM32 gửi chuỗi ASCII:

```c
#include "main.h"
#include "string.h"
#include "stdio.h"

extern UART_HandleTypeDef huart1;

// Định nghĩa chân điều khiển hướng RS-485 DE/RE
#define RS485_TX_ENABLE()   HAL_GPIO_WritePin(GPIOA, GPIO_PIN_8, GPIO_PIN_SET)
#define RS485_RX_ENABLE()   HAL_GPIO_WritePin(GPIOA, GPIO_PIN_8, GPIO_PIN_RESET)

uint8_t rx_buffer[64];
uint16_t plc_d500_val = 0;

// Khung lệnh ASCII đọc thanh ghi D500 từ PLC Q02U qua MC Protocol Format 4
// Cú pháp: ENQ(05H) + Station(00) + PC(FF) + Command(0401) + Delay(0) + Device(D*000500) + Points(0001)
const char read_d500_cmd[] = "\x05""00FF040100D*0005000001\r\n";

void Read_PLC_D500(void)
{
    // 1. Chuyển Module MAX3485 sang chế độ Phát (TX)
    RS485_TX_ENABLE();
    HAL_Delay(2);

    // 2. Gửi khung lệnh sang PLC Q02U
    HAL_UART_Transmit(&huart1, (uint8_t*)read_d500_cmd, strlen(read_d500_cmd), 100);
    HAL_Delay(2);

    // 3. Chuyển Module MAX3485 sang chế độ Nhận (RX)
    RS485_RX_ENABLE();

    // 4. Chờ nhận phản hồi từ PLC (Timeout 200ms)
    memset(rx_buffer, 0, sizeof(rx_buffer));
    if (HAL_UART_Receive(&huart1, rx_buffer, 32, 200) == HAL_OK)
    {
        // Kiểm tra mã phản hồi STX(02H) từ PLC
        if (rx_buffer[0] == 0x02)
        {
            // Giải mã 4 ký tự HEX dữ liệu D500 (VD: "07D0" -> 2000)
            sscanf((char*)&rx_buffer[11], "%4hX", &plc_d500_val);
        }
    }
}
```

---

## 🚀 4. TÓM TẮT QUY TRÌNH THỰC HIỆN

1. Mua 1 **Module MAX3485 (3.3V)** cắm vào STM32 (TX, RX, chân điều khiển DE/RE).
2. Nối 2 dây **A** và **B** của MAX3485 vào giắc cam **CH2** của module QJ71C24N-R4 (SDA+RDA $\rightarrow$ A, SDB+RDB $\rightarrow$ B).
3. Đổi **`Switch 3 = 0066`** và **`Switch 4 = 0000`** trên GX Works2 $\rightarrow$ Nạp xuống PLC.
4. Chạy hàm `Read_PLC_D500()` trên STM32 $\rightarrow$ STM32 sẽ đọc trực tiếp giá trị các thanh ghi `D`, `M` của PLC vô cùng chính xác và mượt mà!
