/**
 * @file oled_ssd1306.h
 * @brief DRIVER OLED SSD1306 0.96 INCH I2C - HỖ TRỢ ĐA DẠNG CỠ FONT (6x8, 8x16, 16x26 SỐ LỚN)
 */

#ifndef OLED_SSD1306_H
#define OLED_SSD1306_H

#include "main.h"
#include "VL53L.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ==============================================================================
 *                       CẤU HÌNH CỔNG I2C CHO MÀN HÌNH OLED
 * ============================================================================== */
extern I2C_HandleTypeDef hi2c2;
#define OLED_I2C_HANDLE             hi2c2

#define OLED_I2C_ADDR               0x78
#define OLED_WIDTH                  128
#define OLED_HEIGHT                 64

/* ==============================================================================
 *                       CÁC CỠ FONT CHỮ CÓ THỂ CHỌN
 * ============================================================================== */
typedef enum {
    OLED_FONT_6x8 = 0,      // Cỡ nhỏ (8 dòng x 21 ký tự / dòng) - xem toàn bộ chi tiết
    OLED_FONT_8x16 = 1,     // Cỡ vừa (4 dòng x 16 ký tự / dòng) - chữ to rõ nét
    OLED_FONT_16x26 = 2     // Cỡ số cực lớn (chuyên cho hiển thị khoảng cách mm từ xa)
} OLED_Font_t;

typedef enum {
    OLED_VIEW_FULL_6REG = 0,    // Chế độ 1: Hiện đầy đủ 6 thanh ghi D900..D905 (Font 6x8)
    OLED_VIEW_BIG_DISTANCE = 1  // Chế độ 2: Hiện Khoảng cách Số Siêu To + Trạng thái (Font 16x26 & 8x16)
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
 * @param x Tọa độ pixel cột (0..127)
 * @param y Tọa độ pixel dòng (0..63)
 * @param str Chuỗi ký tự ASCII
 * @param font OLED_FONT_6x8, OLED_FONT_8x16 hoặc OLED_FONT_16x26
 * @param invert false = chữ trắng nền đen, true = đảo màu
 */
void OLED_DrawString_Font(uint8_t x, uint8_t y, const char *str, OLED_Font_t font, bool invert);

/**
 * @brief Chuyển đổi chế độ hiển thị màn hình (Xem đầy đủ 6 thanh ghi hoặc xem số lớn)
 */
void OLED_SetDisplayMode(OLED_DisplayMode_t mode);

/**
 * @brief Task thực thi hiển thị OLED (gọi trong vòng lặp OLED096_F)
 */
void OLED_Task_Run(void);

#ifdef __cplusplus
}
#endif

#endif /* OLED_SSD1306_H */
