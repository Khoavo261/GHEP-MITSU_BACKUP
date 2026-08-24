/**
 * @file oled_ssd1306.h
 * @brief DRIVER OLED SSD1306 0.96 INCH I2C TRÊN STM32F103C8T6 (HỖ TRỢ CAN-BUS & ĐA CỠ FONT)
 */

#ifndef OLED_SSD1306_H
#define OLED_SSD1306_H

#include "main.h"
#include "VL53L.h"
#include "can_vl53.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ==============================================================================
 *                       CẤU HÌNH CỔNG I2C CHO MÀN HÌNH OLED
 * ============================================================================== */
extern I2C_HandleTypeDef hi2c2;
#define OLED_I2C_HANDLE             hi2c2   // Tách riêng bus I2C2 cho màn hình OLED (PB10=SCL, PB11=SDA)

#define OLED_I2C_ADDR               0x78
#define OLED_WIDTH                  128
#define OLED_HEIGHT                 64

/* ==============================================================================
 *                       CÁC CỠ FONT CHỮ CÓ THỂ CHỌN
 * ============================================================================== */
typedef enum {
    OLED_FONT_6x8 = 0,      // Cỡ nhỏ (8 dòng x 21 ký tự)
    OLED_FONT_8x16 = 1,     // Cỡ vừa (4 dòng x 16 ký tự)
    OLED_FONT_16x26 = 2     // Cỡ số lớn chuyên hiển thị khoảng cách mm
} OLED_Font_t;

typedef enum {
    OLED_VIEW_FULL_CAN_INFO = 0, // Chế độ 1: Xem chi tiết Khoảng cách + Trạng thái CAN Bus (TX/RX/Err)
    OLED_VIEW_BIG_DISTANCE = 1   // Chế độ 2: Xem Khoảng cách Số Cực Lớn (Font 16x26)
} OLED_DisplayMode_t;

/* ==============================================================================
 *                       CÁC HÀM ĐIỀU KHIỂN & HIỂN THỊ
 * ============================================================================== */

/**
 * @brief Khởi tạo màn hình OLED SSD1306
 */
bool OLED_Init(void);

/**
 * @brief Xóa toàn bộ màn hình
 */
void OLED_Clear(void);

/**
 * @brief Đẩy dữ liệu bộ đệm RAM lên màn hình OLED vật lý
 */
void OLED_UpdateScreen(void);

/**
 * @brief Vẽ ký tự với font tùy chọn
 */
void OLED_DrawChar_Font(uint8_t x, uint8_t y, char c, OLED_Font_t font, bool invert);

/**
 * @brief Vẽ chuỗi ký tự với font tùy chọn tại tọa độ pixel (x, y)
 */
void OLED_DrawString_Font(uint8_t x, uint8_t y, const char *str, OLED_Font_t font, bool invert);

/**
 * @brief Chuyển đổi chế độ hiển thị màn hình
 */
void OLED_SetDisplayMode(OLED_DisplayMode_t mode);

/**
 * @brief Tác vụ hiển thị OLED định kỳ trong FreeRTOS
 */
void OLED_Task_Run(void);

#ifdef __cplusplus
}
#endif

#endif /* OLED_SSD1306_H */
