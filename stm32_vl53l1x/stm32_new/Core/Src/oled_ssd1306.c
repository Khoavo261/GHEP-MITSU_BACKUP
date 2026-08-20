/**
 * @file oled_ssd1306.c
 * @brief IMPLEMENTATION DRIVER OLED SSD1306 - HIỂN THỊ TRỰC QUAN Ô NHỚ D910 & D900..D905
 */

#include "oled_ssd1306.h"
#include "i2c.h"
#include "cmsis_os.h"
#include <stdio.h>
#include <string.h>

/* ==============================================================================
 *                       BỘ ĐỆM FRAMEBUFFER 128x64 (1024 Bytes)
 * ============================================================================== */
static uint8_t OLED_Buffer[1024];
static bool    oled_is_ready = false;
static uint8_t oled_actual_addr = 0x78;
static OLED_DisplayMode_t g_oled_mode = OLED_VIEW_FULL_6REG;

/* Bảng Font 6x8 (Ký tự 32 ' ' đến 126 '~') */
static const uint8_t Font6x8[][6] = {
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00}, // 32 ' '
    {0x00, 0x00, 0x5F, 0x00, 0x00, 0x00}, // 33 '!'
    {0x00, 0x07, 0x00, 0x07, 0x00, 0x00}, // 34 '"'
    {0x14, 0x7F, 0x14, 0x7F, 0x14, 0x00}, // 35 '#'
    {0x24, 0x2A, 0x7F, 0x2A, 0x12, 0x00}, // 36 '$'
    {0x23, 0x13, 0x08, 0x64, 0x62, 0x00}, // 37 '%'
    {0x36, 0x49, 0x55, 0x22, 0x50, 0x00}, // 38 '&'
    {0x00, 0x05, 0x03, 0x00, 0x00, 0x00}, // 39 '''
    {0x00, 0x1C, 0x22, 0x41, 0x00, 0x00}, // 40 '('
    {0x00, 0x41, 0x22, 0x1C, 0x00, 0x00}, // 41 ')'
    {0x14, 0x08, 0x3E, 0x08, 0x14, 0x00}, // 42 '*'
    {0x08, 0x08, 0x3E, 0x08, 0x08, 0x00}, // 43 '+'
    {0x00, 0x50, 0x30, 0x00, 0x00, 0x00}, // 44 ','
    {0x08, 0x08, 0x08, 0x08, 0x08, 0x00}, // 45 '-'
    {0x00, 0x60, 0x60, 0x00, 0x00, 0x00}, // 46 '.'
    {0x20, 0x10, 0x08, 0x04, 0x02, 0x00}, // 47 '/'
    {0x3E, 0x51, 0x49, 0x45, 0x3E, 0x00}, // 48 '0'
    {0x00, 0x42, 0x7F, 0x40, 0x00, 0x00}, // 49 '1'
    {0x42, 0x61, 0x51, 0x49, 0x46, 0x00}, // 50 '2'
    {0x21, 0x41, 0x45, 0x4B, 0x31, 0x00}, // 51 '3'
    {0x18, 0x14, 0x12, 0x7F, 0x10, 0x00}, // 52 '4'
    {0x27, 0x45, 0x45, 0x45, 0x39, 0x00}, // 53 '5'
    {0x3C, 0x4A, 0x49, 0x49, 0x30, 0x00}, // 54 '6'
    {0x01, 0x71, 0x09, 0x05, 0x03, 0x00}, // 55 '7'
    {0x36, 0x49, 0x49, 0x49, 0x36, 0x00}, // 56 '8'
    {0x06, 0x49, 0x49, 0x29, 0x1E, 0x00}, // 57 '9'
    {0x00, 0x36, 0x36, 0x00, 0x00, 0x00}, // 58 ':'
    {0x00, 0x56, 0x36, 0x00, 0x00, 0x00}, // 59 ';'
    {0x08, 0x14, 0x22, 0x41, 0x00, 0x00}, // 60 '<'
    {0x14, 0x14, 0x14, 0x14, 0x14, 0x00}, // 61 '='
    {0x00, 0x41, 0x22, 0x14, 0x08, 0x00}, // 62 '>'
    {0x02, 0x01, 0x51, 0x09, 0x06, 0x00}, // 63 '?'
    {0x32, 0x49, 0x79, 0x41, 0x3E, 0x00}, // 64 '@'
    {0x7E, 0x11, 0x11, 0x11, 0x7E, 0x00}, // 65 'A'
    {0x7F, 0x49, 0x49, 0x49, 0x36, 0x00}, // 66 'B'
    {0x3E, 0x41, 0x41, 0x41, 0x22, 0x00}, // 67 'C'
    {0x7F, 0x41, 0x41, 0x22, 0x1C, 0x00}, // 68 'D'
    {0x7F, 0x49, 0x49, 0x49, 0x41, 0x00}, // 69 'E'
    {0x7F, 0x09, 0x09, 0x09, 0x01, 0x00}, // 70 'F'
    {0x3E, 0x41, 0x49, 0x49, 0x7A, 0x00}, // 71 'G'
    {0x7F, 0x08, 0x08, 0x08, 0x7F, 0x00}, // 72 'H'
    {0x00, 0x41, 0x7F, 0x41, 0x00, 0x00}, // 73 'I'
    {0x20, 0x40, 0x41, 0x3F, 0x01, 0x00}, // 74 'J'
    {0x7F, 0x08, 0x14, 0x22, 0x41, 0x00}, // 75 'K'
    {0x7F, 0x40, 0x40, 0x40, 0x40, 0x00}, // 76 'L'
    {0x7F, 0x02, 0x0C, 0x02, 0x7F, 0x00}, // 77 'M'
    {0x7F, 0x04, 0x08, 0x10, 0x7F, 0x00}, // 78 'N'
    {0x3E, 0x41, 0x41, 0x41, 0x3E, 0x00}, // 79 'O'
    {0x7F, 0x09, 0x09, 0x09, 0x06, 0x00}, // 80 'P'
    {0x3E, 0x41, 0x51, 0x21, 0x5E, 0x00}, // 81 'Q'
    {0x7F, 0x09, 0x19, 0x29, 0x46, 0x00}, // 82 'R'
    {0x46, 0x49, 0x49, 0x49, 0x31, 0x00}, // 83 'S'
    {0x01, 0x01, 0x7F, 0x01, 0x01, 0x00}, // 84 'T'
    {0x3F, 0x40, 0x40, 0x40, 0x3F, 0x00}, // 85 'U'
    {0x1F, 0x20, 0x40, 0x20, 0x1F, 0x00}, // 86 'V'
    {0x3F, 0x40, 0x38, 0x40, 0x3F, 0x00}, // 87 'W'
    {0x63, 0x14, 0x08, 0x14, 0x63, 0x00}, // 88 'X'
    {0x07, 0x08, 0x70, 0x08, 0x07, 0x00}, // 89 'Y'
    {0x61, 0x51, 0x49, 0x45, 0x43, 0x00}, // 90 'Z'
    {0x00, 0x7F, 0x41, 0x41, 0x00, 0x00}, // 91 '['
    {0x02, 0x04, 0x08, 0x10, 0x20, 0x00}, // 92 '\'
    {0x00, 0x41, 0x41, 0x7F, 0x00, 0x00}, // 93 ']'
    {0x04, 0x02, 0x01, 0x02, 0x04, 0x00}, // 94 '^'
    {0x40, 0x40, 0x40, 0x40, 0x40, 0x00}, // 95 '_'
    {0x00, 0x01, 0x02, 0x04, 0x00, 0x00}, // 96 '`'
    {0x20, 0x54, 0x54, 0x54, 0x78, 0x00}, // 97 'a'
    {0x7F, 0x48, 0x44, 0x44, 0x38, 0x00}, // 98 'b'
    {0x38, 0x44, 0x44, 0x44, 0x20, 0x00}, // 99 'c'
    {0x38, 0x44, 0x44, 0x48, 0x7F, 0x00}, // 100 'd'
    {0x38, 0x54, 0x54, 0x54, 0x18, 0x00}, // 101 'e'
    {0x08, 0x7E, 0x09, 0x01, 0x02, 0x00}, // 102 'f'
    {0x0C, 0x52, 0x52, 0x52, 0x3E, 0x00}, // 103 'g'
    {0x7F, 0x08, 0x04, 0x04, 0x78, 0x00}, // 104 'h'
    {0x00, 0x44, 0x7D, 0x40, 0x00, 0x00}, // 105 'i'
    {0x20, 0x40, 0x44, 0x3D, 0x00, 0x00}, // 106 'j'
    {0x7F, 0x10, 0x28, 0x44, 0x00, 0x00}, // 107 'k'
    {0x00, 0x41, 0x7F, 0x40, 0x00, 0x00}, // 108 'l'
    {0x7C, 0x04, 0x18, 0x04, 0x78, 0x00}, // 109 'm'
    {0x7C, 0x08, 0x04, 0x04, 0x78, 0x00}, // 110 'n'
    {0x38, 0x44, 0x44, 0x44, 0x38, 0x00}, // 111 'o'
    {0x7C, 0x14, 0x14, 0x14, 0x08, 0x00}, // 112 'p'
    {0x08, 0x14, 0x14, 0x18, 0x7C, 0x00}, // 113 'q'
    {0x7C, 0x08, 0x04, 0x04, 0x08, 0x00}, // 114 'r'
    {0x48, 0x54, 0x54, 0x54, 0x20, 0x00}, // 115 's'
    {0x04, 0x3F, 0x44, 0x40, 0x20, 0x00}, // 116 't'
    {0x3C, 0x40, 0x40, 0x20, 0x7C, 0x00}, // 117 'u'
    {0x1C, 0x20, 0x40, 0x20, 0x1C, 0x00}, // 118 'v'
    {0x3C, 0x40, 0x30, 0x40, 0x3C, 0x00}, // 119 'w'
    {0x44, 0x28, 0x10, 0x28, 0x44, 0x00}, // 120 'x'
    {0x0C, 0x50, 0x50, 0x50, 0x3C, 0x00}, // 121 'y'
    {0x44, 0x64, 0x54, 0x4C, 0x44, 0x00}, // 122 'z'
    {0x00, 0x08, 0x36, 0x41, 0x00, 0x00}, // 123 '{'
    {0x00, 0x00, 0x7F, 0x00, 0x00, 0x00}, // 124 '|'
    {0x00, 0x41, 0x36, 0x08, 0x00, 0x00}, // 125 '}'
    {0x08, 0x08, 0x2A, 0x1C, 0x08, 0x00}  // 126 '~'
};

/* ==============================================================================
 *                       GIAO TIẾP LỆNH / DỮ LIỆU I2C
 * ============================================================================== */

static void OLED_WriteCommand(uint8_t cmd) {
    uint8_t data[2] = {0x00, cmd};
    HAL_I2C_Master_Transmit(&OLED_I2C_HANDLE, oled_actual_addr, data, 2, 10);
}

bool OLED_Init(void) {
    if (HAL_I2C_IsDeviceReady(&OLED_I2C_HANDLE, 0x78, 2, 20) == HAL_OK) {
        oled_actual_addr = 0x78;
    } else if (HAL_I2C_IsDeviceReady(&OLED_I2C_HANDLE, 0x7A, 2, 20) == HAL_OK) {
        oled_actual_addr = 0x7A;
    } else {
        oled_is_ready = false;
        return false;
    }

    OLED_WriteCommand(0xAE); // Display OFF
    OLED_WriteCommand(0x20); // Addressing Mode
    OLED_WriteCommand(0x00); // Horizontal
    OLED_WriteCommand(0xB0);
    OLED_WriteCommand(0xC8);
    OLED_WriteCommand(0x00);
    OLED_WriteCommand(0x10);
    OLED_WriteCommand(0x40);
    OLED_WriteCommand(0x81);
    OLED_WriteCommand(0xFF);
    OLED_WriteCommand(0xA1);
    OLED_WriteCommand(0xA6);
    OLED_WriteCommand(0xA8);
    OLED_WriteCommand(0x3F);
    OLED_WriteCommand(0xA4);
    OLED_WriteCommand(0xD3);
    OLED_WriteCommand(0x00);
    OLED_WriteCommand(0xD5);
    OLED_WriteCommand(0x80);
    OLED_WriteCommand(0xD9);
    OLED_WriteCommand(0xF1);
    OLED_WriteCommand(0xDA);
    OLED_WriteCommand(0x12);
    OLED_WriteCommand(0xDB);
    OLED_WriteCommand(0x40);
    OLED_WriteCommand(0x8D);
    OLED_WriteCommand(0x14);
    OLED_WriteCommand(0xAF); // Display ON!

    OLED_Clear();
    OLED_UpdateScreen();
    oled_is_ready = true;
    return true;
}

void OLED_Clear(void) {
    memset(OLED_Buffer, 0x00, sizeof(OLED_Buffer));
}

void OLED_UpdateScreen(void) {
    if (!oled_is_ready) return;

    for (uint8_t page = 0; page < 8; page++) {
        OLED_WriteCommand(0xB0 + page);
        OLED_WriteCommand(0x00);
        OLED_WriteCommand(0x10);

        uint8_t payload[129];
        payload[0] = 0x40;
        memcpy(&payload[1], &OLED_Buffer[page * 128], 128);
        HAL_I2C_Master_Transmit(&OLED_I2C_HANDLE, oled_actual_addr, payload, 129, 20);
    }
}

/* ==============================================================================
 *                       BỘ VẼ ĐA FONT
 * ============================================================================== */

static void OLED_DrawPixel(uint8_t x, uint8_t y, bool color) {
    if (x >= OLED_WIDTH || y >= OLED_HEIGHT) return;
    if (color) {
        OLED_Buffer[x + (y / 8) * OLED_WIDTH] |= (1 << (y % 8));
    } else {
        OLED_Buffer[x + (y / 8) * OLED_WIDTH] &= ~(1 << (y % 8));
    }
}

void OLED_DrawChar_Font(uint8_t x, uint8_t y, char c, OLED_Font_t font, bool invert) {
    if (c < 32 || c > 126) c = ' ';
    uint8_t char_idx = c - 32;

    switch (font) {
        case OLED_FONT_6x8: {
            for (uint8_t col = 0; col < 6; col++) {
                uint8_t line = Font6x8[char_idx][col];
                for (uint8_t row = 0; row < 8; row++) {
                    bool pixel = (line & (1 << row)) ? true : false;
                    OLED_DrawPixel(x + col, y + row, invert ? !pixel : pixel);
                }
            }
            break;
        }

        case OLED_FONT_8x16: {
            for (uint8_t col = 0; col < 6; col++) {
                uint8_t line = Font6x8[char_idx][col];
                for (uint8_t row = 0; row < 8; row++) {
                    bool pixel = (line & (1 << row)) ? true : false;
                    bool draw_color = invert ? !pixel : pixel;
                    OLED_DrawPixel(x + col + (col / 3), y + row * 2,     draw_color);
                    OLED_DrawPixel(x + col + (col / 3), y + row * 2 + 1, draw_color);
                }
            }
            break;
        }

        case OLED_FONT_16x26: {
            for (uint8_t col = 0; col < 6; col++) {
                uint8_t line = Font6x8[char_idx][col];
                for (uint8_t row = 0; row < 8; row++) {
                    bool pixel = (line & (1 << row)) ? true : false;
                    bool draw_color = invert ? !pixel : pixel;
                    for (uint8_t dx = 0; dx < 2; dx++) {
                        for (uint8_t dy = 0; dy < 3; dy++) {
                            OLED_DrawPixel(x + col * 2 + dx, y + row * 3 + dy, draw_color);
                        }
                    }
                }
            }
            break;
        }
        default:
            break;
    }
}

void OLED_DrawString_Font(uint8_t x, uint8_t y, const char *str, OLED_Font_t font, bool invert) {
    uint8_t char_w = 6;
    if (font == OLED_FONT_8x16)  char_w = 8;
    if (font == OLED_FONT_16x26) char_w = 14;

    while (*str) {
        if (x + char_w > OLED_WIDTH) break;
        OLED_DrawChar_Font(x, y, *str, font, invert);
        x += char_w;
        str++;
    }
}

void OLED_SetDisplayMode(OLED_DisplayMode_t mode) {
    g_oled_mode = mode;
}

/* ==============================================================================
 *                       HIỂN THỊ DỮ LIỆU & CALIB D910 / M910
 * ============================================================================== */

static void OLED_Show_Full_6Registers(void) {
    char line_str[24];
    OLED_Clear();

    // Dòng 0: Tiêu đề nổi bật (Nền trắng chữ đen)
    OLED_DrawString_Font(0, 0, " [Q02U <-> VL53L1X] ", OLED_FONT_6x8, true);

    // Dòng 1: D900 - Khoảng cách sau Calib
    snprintf(line_str, sizeof(line_str), "D900(Cal):%4d mm", g_vl53_app.d_distance_filtered);
    OLED_DrawString_Font(0, 9, line_str, OLED_FONT_6x8, false);

    // Dòng 2: D901 - Khoảng cách thô
    snprintf(line_str, sizeof(line_str), "D901(Raw):%4d mm", g_vl53_app.d_distance_raw);
    OLED_DrawString_Font(0, 18, line_str, OLED_FONT_6x8, false);

    // Dòng 3: Ô NHỚ D910 - ĐỌC TRỰC TIẾP TỪ PLC/HMI (Rõ ràng 100%)
    snprintf(line_str, sizeof(line_str), "D910(PLC):%4d mm", g_vl53_app.d_calib_target);
    OLED_DrawString_Font(0, 27, line_str, OLED_FONT_6x8, false);

    // Dòng 4: Độ lệch Offset tính được & Trạng thái Calib
    snprintf(line_str, sizeof(line_str), "Offset:%+4dmm %s", g_vl53_app.d_calib_offset, g_vl53_app.calib_done ? "[OK]" : "[--]");
    OLED_DrawString_Font(0, 36, line_str, OLED_FONT_6x8, false);

    // Dòng 5: D902 - Trạng thái hoạt động
    snprintf(line_str, sizeof(line_str), "D902(Sta): 0x%04X", g_vl53_app.d_status);
    OLED_DrawString_Font(0, 45, line_str, OLED_FONT_6x8, false);

    // Dòng 6: D905 - Nhịp tim Heartbeat
    snprintf(line_str, sizeof(line_str), "D905(Hbt):%5u", g_vl53_app.d_heartbeat);
    OLED_DrawString_Font(0, 54, line_str, OLED_FONT_6x8, false);

    OLED_UpdateScreen();
}

static void OLED_Show_Big_Distance_View(void) {
    char dist_str[16];
    char sub_str[24];
    OLED_Clear();

    // Tiêu đề
    OLED_DrawString_Font(0, 0, "DISTANCE (D900):", OLED_FONT_8x16, false);

    // Số đo khoảng cách Siêu Lớn (Font 16x26)
    snprintf(dist_str, sizeof(dist_str), "%4d mm", g_vl53_app.d_distance_filtered);
    OLED_DrawString_Font(12, 18, dist_str, OLED_FONT_16x26, false);

    // Thông số ô nhớ D910 đọc từ PLC & Offset
    snprintf(sub_str, sizeof(sub_str), "D910:%4d Off:%+3d %s", g_vl53_app.d_calib_target, g_vl53_app.d_calib_offset, g_vl53_app.calib_done ? "OK" : "");
    OLED_DrawString_Font(0, 48, sub_str, OLED_FONT_6x8, false);

    // Trạng thái truyền thông
    snprintf(sub_str, sizeof(sub_str), "Raw:%4d Hbt:%5u", g_vl53_app.d_distance_raw, g_vl53_app.d_heartbeat);
    OLED_DrawString_Font(0, 56, sub_str, OLED_FONT_6x8, false);

    OLED_UpdateScreen();
}

void OLED_Task_Run(void) {
    if (!oled_is_ready) {
        static uint32_t last_init_tick = 0;
        if (HAL_GetTick() - last_init_tick >= 1000) {
            last_init_tick = HAL_GetTick();
            OLED_Init();
        }
        return;
    }

    if (g_oled_mode == OLED_VIEW_BIG_DISTANCE) {
        OLED_Show_Big_Distance_View();
    } else {
        OLED_Show_Full_6Registers();
    }
}
