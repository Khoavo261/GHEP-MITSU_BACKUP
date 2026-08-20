/**
 * @file oled_ssd1306.c
 * @brief IMPLEMENTATION DRIVER OLED SSD1306 - HIỂN THỊ TRỰC QUAN TOÀN BỘ 16 BYTE PAYLOAD TỪ PLC
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

    OLED_WriteCommand(0xAE);
    OLED_WriteCommand(0x20);
    OLED_WriteCommand(0x00);
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
    OLED_WriteCommand(0xAF);

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
 *                       HIỂN THỊ DỮ LIỆU & CHẨN ĐOÁN TRUYỀN THÔNG
 * ============================================================================== */

// Màn hình 1: Giám sát vận hành (Khi D911 == 0) - Font siêu lớn 16x26
static void OLED_Show_Big_Distance_View(void) {
    char dist_str[16];
    char sub_str[32];
    OLED_Clear();

    // Dòng 0: Tiêu đề
    OLED_DrawString_Font(0, 0, " [VL53L1X - RUN MODE] ", OLED_FONT_6x8, true);

    // Số đo khoảng cách Siêu Lớn (Font 16x26)
    snprintf(dist_str, sizeof(dist_str), "%4d mm", g_vl53_app.d_distance_filtered);
    OLED_DrawString_Font(10, 10, dist_str, OLED_FONT_16x26, false);

    // Thông số ô nhớ đọc từ PLC: D910 & D911
    snprintf(sub_str, sizeof(sub_str), "D910:%-4d  D911:%-4d", g_vl53_app.d_calib_target, g_vl53_app.d_calib_cmd_flag);
    OLED_DrawString_Font(0, 38, sub_str, OLED_FONT_6x8, false);

    // Thông số đo thô & Offset
    snprintf(sub_str, sizeof(sub_str), "Raw:%-4d Off:%+4d mm", g_vl53_app.d_distance_raw, g_vl53_app.d_calib_offset);
    OLED_DrawString_Font(0, 47, sub_str, OLED_FONT_6x8, false);

    // Trạng thái cảm biến & Chu kỳ đọc PLC
    snprintf(sub_str, sizeof(sub_str), "Stat:%s  Rd:%lu", g_vl53_app.sensor_ok ? "OK" : "ERR", g_vl53_app.read_success_count % 10000);
    OLED_DrawString_Font(0, 56, sub_str, OLED_FONT_6x8, false);

    OLED_UpdateScreen();
}

// Màn hình 2: Cài đặt & Hiệu chuẩn Calib (Khi D911 != 0 hoặc đang trong thời gian giữ hiển thị)
static void OLED_Show_Parameter_Calib_View(void) {
    char line_str[24];
    OLED_Clear();

    // Dòng 0: Tiêu đề
    OLED_DrawString_Font(0, 0, " [CALIB / PARAM MODE] ", OLED_FONT_6x8, true);

    uint16_t mode = g_vl53_app.active_calib_mode ? g_vl53_app.active_calib_mode : g_vl53_app.d_calib_cmd_flag;

    // Dòng 1: Chế độ Calib theo D911
    if (mode == 10 || mode == 1) {
        snprintf(line_str, sizeof(line_str), "MODE 10: SW OFFSET");
    } else if (mode == 20) {
        snprintf(line_str, sizeof(line_str), "MODE 20: HW OFFSET");
    } else if (mode == 30) {
        snprintf(line_str, sizeof(line_str), "MODE 30: XTALK REF");
    } else {
        snprintf(line_str, sizeof(line_str), "PARAM D911: %-4u", mode);
    }
    OLED_DrawString_Font(0, 9, line_str, OLED_FONT_6x8, false);

    // Dòng 2: D910 - Target từ PLC
    snprintf(line_str, sizeof(line_str), "Target(D910): %4d mm", g_vl53_app.d_calib_target);
    OLED_DrawString_Font(0, 18, line_str, OLED_FONT_6x8, false);

    // Dòng 3: D901 - Khoảng cách đo thô
    snprintf(line_str, sizeof(line_str), "Raw   (D901): %4d mm", g_vl53_app.d_distance_raw);
    OLED_DrawString_Font(0, 27, line_str, OLED_FONT_6x8, false);

    // Dòng 4: D900 - Khoảng cách sau Calib
    snprintf(line_str, sizeof(line_str), "Calib (D900): %4d mm", g_vl53_app.d_distance_filtered);
    OLED_DrawString_Font(0, 36, line_str, OLED_FONT_6x8, false);

    // Dòng 5: Offset tính toán & Payload thô byte 14-17 (D910 & D911)
    snprintf(line_str, sizeof(line_str), "Off:%+4d|%02X%02X %02X%02X", 
             g_vl53_app.d_calib_offset,
             g_vl53_app.last_payload[14], g_vl53_app.last_payload[15],
             g_vl53_app.last_payload[16], g_vl53_app.last_payload[17]);
    OLED_DrawString_Font(0, 45, line_str, OLED_FONT_6x8, false);

    // Dòng 6: Trạng thái Calib
    snprintf(line_str, sizeof(line_str), "Status: %s", g_vl53_app.calib_done ? "CALIB SUCCESS -> 0" : "CALIBRATING...");
    OLED_DrawString_Font(0, 54, line_str, OLED_FONT_6x8, false);

    OLED_UpdateScreen();
}

// Màn hình 3: Bảng hướng dẫn khi nhập sai mã lệnh D911 (# 10, 20, 30)
static void OLED_Show_Invalid_Param_Guide_View(uint16_t cur_d911) {
    char line_str[24];
    OLED_Clear();

    // Dòng 0: Tiêu đề
    OLED_DrawString_Font(0, 0, " [CALIB GUIDE / HELP] ", OLED_FONT_6x8, true);

    // Dòng 1: Hướng dẫn D911=10
    OLED_DrawString_Font(0, 9, "D911=10: SW Offset", OLED_FONT_6x8, false);

    // Dòng 2: Hướng dẫn D911=20
    OLED_DrawString_Font(0, 18, "D911=20: HW Offset", OLED_FONT_6x8, false);

    // Dòng 3: Hướng dẫn D911=30
    OLED_DrawString_Font(0, 27, "D911=30: Xtalk Glass", OLED_FONT_6x8, false);

    // Dòng 4: Target hiện tại
    snprintf(line_str, sizeof(line_str), "Target D910: %4d mm", g_vl53_app.d_calib_target);
    OLED_DrawString_Font(0, 36, line_str, OLED_FONT_6x8, false);

    // Dòng 5: Giá trị D911 vừa nhập
    snprintf(line_str, sizeof(line_str), "Cur D911   : %-4u", cur_d911);
    OLED_DrawString_Font(0, 45, line_str, OLED_FONT_6x8, false);

    // Dòng 6: Cảnh báo hướng dẫn
    OLED_DrawString_Font(0, 54, "Set 10,20,30 to Calib", OLED_FONT_6x8, false);

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

    bool is_holding_calib = (HAL_GetTick() < g_vl53_app.calib_display_hold_until);

    // Khi đã hết thời gian giữ màn hình Calib:
    if (!is_holding_calib) {
        g_vl53_app.active_calib_mode = 0;
    }

    // 1. Khi D911 = 0 và không trong thời gian giữ Calib -> Chuyển về Font chữ SIÊU LỚN 16x26 (RUN MODE)
    if (g_vl53_app.d_calib_cmd_flag == 0 && !is_holding_calib) {
        OLED_Show_Big_Distance_View();
    } 
    // 2. Khi đang Calib (D911 = 10, 20, 30) hoặc trong thời gian giữ hiển thị kết quả Calib -> Hiện Màn hình Calib
    else if (g_vl53_app.d_calib_cmd_flag == 10 || g_vl53_app.d_calib_cmd_flag == 1 ||
             g_vl53_app.d_calib_cmd_flag == 20 || g_vl53_app.d_calib_cmd_flag == 30 ||
             is_holding_calib) {
        OLED_Show_Parameter_Calib_View();
    } 
    // 3. Khi D911 khác 0 và khác 10, 20, 30: Hiện bảng hướng dẫn
    else {
        OLED_Show_Invalid_Param_Guide_View(g_vl53_app.d_calib_cmd_flag);
    }
}
