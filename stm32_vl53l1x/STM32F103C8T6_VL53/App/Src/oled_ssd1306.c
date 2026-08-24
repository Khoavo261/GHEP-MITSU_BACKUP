/**
 * @file oled_ssd1306.c
 * @brief IMPLEMENTATION DRIVER OLED SSD1306 CHO STM32F103C8T6 (HIỂN THỊ MULTI-NODE CAN & DISTANCE)
 */

#include "oled_ssd1306.h"
#include "can_vl53.h"
#include "cmsis_os.h"
#include "i2c.h"
#include <stdio.h>
#include <string.h>

/* ==============================================================================
 *                       BỘ ĐỆM FRAMEBUFFER 128x64 (1024 Bytes)
 * ============================================================================== */
static uint8_t OLED_Buffer[1024];
static uint8_t s_oled_tx_buf[1025]; // Static to avoid FreeRTOS stack overflow!
static bool    oled_is_ready = false;
static uint8_t oled_actual_addr = 0x78;
static OLED_DisplayMode_t g_oled_mode = OLED_VIEW_FULL_CAN_INFO;

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
    {0x08, 0x14, 0x54, 0x54, 0x3C, 0x00}, // 103 'g'
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
    {0x44, 0x64, 0x54, 0x4C, 0x44, 0x00}  // 122 'z'
};

static void OLED_WriteCommand_NoLock(uint8_t cmd) {
    uint8_t buffer[2] = {0x00, cmd};
    HAL_I2C_Master_Transmit(&OLED_I2C_HANDLE, oled_actual_addr, buffer, 2, 50);
}

bool OLED_Init(void) {
    if (!I2C_Lock(100)) return false;

    if (HAL_I2C_IsDeviceReady(&OLED_I2C_HANDLE, 0x78, 2, 50) == HAL_OK) {
        oled_actual_addr = 0x78;
    } else if (HAL_I2C_IsDeviceReady(&OLED_I2C_HANDLE, 0x7A, 2, 50) == HAL_OK) {
        oled_actual_addr = 0x7A;
    } else {
        oled_is_ready = false;
        I2C_Unlock();
        return false;
    }

    OLED_WriteCommand_NoLock(0xAE); // Display Off
    OLED_WriteCommand_NoLock(0xD5); // Set Display Clock Divide Ratio/Oscillator Frequency
    OLED_WriteCommand_NoLock(0x80);
    OLED_WriteCommand_NoLock(0xA8); // Set Multiplex Ratio
    OLED_WriteCommand_NoLock(0x3F); // 1/64 duty
    OLED_WriteCommand_NoLock(0xD3); // Set Display Offset
    OLED_WriteCommand_NoLock(0x00);
    OLED_WriteCommand_NoLock(0x40); // Set Start Line
    OLED_WriteCommand_NoLock(0x8D); // Set Charge Pump
    OLED_WriteCommand_NoLock(0x14); // Enable Charge Pump
    OLED_WriteCommand_NoLock(0x20); // Set Memory Addressing Mode
    OLED_WriteCommand_NoLock(0x00); // Horizontal Addressing Mode
    OLED_WriteCommand_NoLock(0xA1); // Set Segment Re-Map (Column 127 mapped to SEG0)
    OLED_WriteCommand_NoLock(0xC8); // Set COM Output Scan Direction (re-mapped)
    OLED_WriteCommand_NoLock(0xDA); // Set COM Pins Hardware Configuration
    OLED_WriteCommand_NoLock(0x12);
    OLED_WriteCommand_NoLock(0x81); // Set Contrast Control
    OLED_WriteCommand_NoLock(0xCF);
    OLED_WriteCommand_NoLock(0xD9); // Set Pre-Charge Period
    OLED_WriteCommand_NoLock(0xF1);
    OLED_WriteCommand_NoLock(0xDB); // Set VCOMH Deselect Level
    OLED_WriteCommand_NoLock(0x40);
    OLED_WriteCommand_NoLock(0xA4); // Entire Display ON Resume
    OLED_WriteCommand_NoLock(0xA6); // Set Normal Display
    OLED_WriteCommand_NoLock(0xAF); // Display ON

    oled_is_ready = true;
    I2C_Unlock();

    OLED_Clear();
    OLED_UpdateScreen();
    return true;
}

void OLED_Clear(void) {
    memset(OLED_Buffer, 0x00, sizeof(OLED_Buffer));
}

void OLED_UpdateScreen(void) {
    if (!oled_is_ready) return;

    if (!I2C_Lock(100)) return;

    OLED_WriteCommand_NoLock(0x21); // Set Column Address
    OLED_WriteCommand_NoLock(0x00);
    OLED_WriteCommand_NoLock(127);
    OLED_WriteCommand_NoLock(0x22); // Set Page Address
    OLED_WriteCommand_NoLock(0x00);
    OLED_WriteCommand_NoLock(7);

    s_oled_tx_buf[0] = 0x40; // Co = 0, D/C# = 1 (Data mode)
    memcpy(&s_oled_tx_buf[1], OLED_Buffer, 1024);
    HAL_I2C_Master_Transmit(&OLED_I2C_HANDLE, oled_actual_addr, s_oled_tx_buf, 1025, 200);

    I2C_Unlock();
}

void OLED_DrawPixel(uint8_t x, uint8_t y, bool color) {
    if (x >= OLED_WIDTH || y >= OLED_HEIGHT) return;
    if (color) OLED_Buffer[x + (y / 8) * OLED_WIDTH] |= (1 << (y % 8));
    else       OLED_Buffer[x + (y / 8) * OLED_WIDTH] &= ~(1 << (y % 8));
}

void OLED_DrawChar_Font(uint8_t x, uint8_t y, char c, OLED_Font_t font, bool invert) {
    if (c < 32 || c > 126) c = ' ';
    uint8_t char_idx = c - 32;

    if (font == OLED_FONT_6x8) {
        for (uint8_t col = 0; col < 6; col++) {
            uint8_t line = (char_idx < (sizeof(Font6x8) / 6)) ? Font6x8[char_idx][col] : 0x00;
            for (uint8_t row = 0; row < 8; row++) {
                bool pixel = (line & (1 << row)) != 0;
                OLED_DrawPixel(x + col, y + row, invert ? !pixel : pixel);
            }
        }
    } else if (font == OLED_FONT_8x16 || font == OLED_FONT_16x26) {
        uint8_t scale = (font == OLED_FONT_16x26) ? 3 : 2;
        for (uint8_t col = 0; col < 6; col++) {
            uint8_t line = (char_idx < (sizeof(Font6x8) / 6)) ? Font6x8[char_idx][col] : 0x00;
            for (uint8_t row = 0; row < 8; row++) {
                bool pixel = (line & (1 << row)) != 0;
                for (uint8_t sx = 0; sx < scale; sx++) {
                    for (uint8_t sy = 0; sy < scale; sy++) {
                        OLED_DrawPixel(x + col * scale + sx, y + row * scale + sy, invert ? !pixel : pixel);
                    }
                }
            }
        }
    }
}

void OLED_DrawString_Font(uint8_t x, uint8_t y, const char *str, OLED_Font_t font, bool invert) {
    uint8_t cur_x = x;
    uint8_t font_width = (font == OLED_FONT_6x8) ? 6 : (font == OLED_FONT_8x16 ? 12 : 18);

    while (*str) {
        if (cur_x + font_width > OLED_WIDTH) break;
        OLED_DrawChar_Font(cur_x, y, *str, font, invert);
        cur_x += font_width;
        str++;
    }
}

void OLED_SetDisplayMode(OLED_DisplayMode_t mode) {
    g_oled_mode = mode;
}

#include "plc_mitsu.h"

void OLED_Task_Run(void) {
    if (!oled_is_ready) {
        OLED_Init();
        if (!oled_is_ready) return;
    }

    OLED_Clear();
    char line_buf[32];

    if (MASTER) {
        // ==================== GIAO DIỆN BO MASTER ====================
        if (g_oled_mode == OLED_VIEW_FULL_CAN_INFO) {
            // Tiêu đề Master & Trạng thái kết nối PLC
            const char *plc_status_str = g_plc_stats.plc_connected ? "PLC:OK" : "PLC:ERR";
            snprintf(line_buf, sizeof(line_buf), "MASTER ToF  %s", plc_status_str);
            OLED_DrawString_Font(0, 0, line_buf, OLED_FONT_6x8, true);

            // Dòng 1: Khoảng cách Master đo được
            snprintf(line_buf, sizeof(line_buf), "M_DIST:%4d (RAW:%4d)", g_vl53_app.d_distance_filtered, g_vl53_app.d_distance_raw);
            OLED_DrawString_Font(0, 12, line_buf, OLED_FONT_6x8, false);

            // Dòng 2: Số lượng Slave Online
            snprintf(line_buf, sizeof(line_buf), "ONLINE SLAVES: %d/%d", g_can_stats.online_slaves_cnt, MAX_SLAVE_NODES);
            OLED_DrawString_Font(0, 22, line_buf, OLED_FONT_6x8, false);

            // Dòng 3: Khoảng cách Slave 1, 2, 3
            snprintf(line_buf, sizeof(line_buf), "1:%4d 2:%4d 3:%4d",
                     g_slave_nodes[0].is_online ? g_slave_nodes[0].d_distance_filtered : 0,
                     g_slave_nodes[1].is_online ? g_slave_nodes[1].d_distance_filtered : 0,
                     g_slave_nodes[2].is_online ? g_slave_nodes[2].d_distance_filtered : 0);
            OLED_DrawString_Font(0, 32, line_buf, OLED_FONT_6x8, false);

            // Dòng 4: Khoảng cách Slave 4, 5, 6
            snprintf(line_buf, sizeof(line_buf), "4:%4d 5:%4d 6:%4d",
                     g_slave_nodes[3].is_online ? g_slave_nodes[3].d_distance_filtered : 0,
                     g_slave_nodes[4].is_online ? g_slave_nodes[4].d_distance_filtered : 0,
                     g_slave_nodes[5].is_online ? g_slave_nodes[5].d_distance_filtered : 0);
            OLED_DrawString_Font(0, 42, line_buf, OLED_FONT_6x8, false);

            // Dòng 5: Thống kê CAN RX & PLC TX
            snprintf(line_buf, sizeof(line_buf), "CAN:%-5lu PLC_TX:%-5lu", g_can_stats.rx_count, g_plc_stats.tx_write_count);
            OLED_DrawString_Font(0, 54, line_buf, OLED_FONT_6x8, true);
        } else {
            // Chế độ số to: Hiển thị khoảng cách Master
            snprintf(line_buf, sizeof(line_buf), "MASTER [SLAVES:%d]", g_can_stats.online_slaves_cnt);
            OLED_DrawString_Font(0, 0, line_buf, OLED_FONT_6x8, false);

            snprintf(line_buf, sizeof(line_buf), "%4d", g_vl53_app.d_distance_filtered);
            OLED_DrawString_Font(12, 16, line_buf, OLED_FONT_16x26, false);

            snprintf(line_buf, sizeof(line_buf), "mm");
            OLED_DrawString_Font(95, 30, line_buf, OLED_FONT_8x16, false);

            snprintf(line_buf, sizeof(line_buf), "CAN_RX:%lu PLC:%s", g_can_stats.rx_count, g_plc_stats.plc_connected ? "OK" : "NO");
            OLED_DrawString_Font(0, 54, line_buf, OLED_FONT_6x8, true);
        }
    } else {
        // ==================== GIAO DIỆN BO SLAVE ====================
        if (g_oled_mode == OLED_VIEW_FULL_CAN_INFO) {
            // Tiêu đề & Node ID
            snprintf(line_buf, sizeof(line_buf), "NODE:#%02d  CAN:0x%03X", g_vl53_app.node_id, g_can_stats.tx_can_id);
            OLED_DrawString_Font(0, 0, line_buf, OLED_FONT_6x8, true);

            // Dòng 1: Khoảng cách Lọc & Thô
            snprintf(line_buf, sizeof(line_buf), "DIST:%4d  (RAW:%4d)", g_vl53_app.d_distance_filtered, g_vl53_app.d_distance_raw);
            OLED_DrawString_Font(0, 12, line_buf, OLED_FONT_6x8, false);

            // Dòng 2: Chip ID & Range Error Status
            snprintf(line_buf, sizeof(line_buf), "ID:0x%04X  ERR:%2d", g_vl53_app.sensor_chip_id, g_vl53_app.d_error);
            OLED_DrawString_Font(0, 22, line_buf, OLED_FONT_6x8, false);

            // Dòng 3: CAN Tx/Rx Counters
            snprintf(line_buf, sizeof(line_buf), "TX:%-5lu RX:%-4lu", g_can_stats.tx_count, g_can_stats.rx_count);
            OLED_DrawString_Font(0, 32, line_buf, OLED_FONT_6x8, false);

            // Dòng 4: CAN Error Counter & Last RX Cmd
            snprintf(line_buf, sizeof(line_buf), "TX_ERR:%-3lu CMD_ID:0x%03X", g_can_stats.tx_error_count, g_can_stats.rx_cmd_id);
            OLED_DrawString_Font(0, 42, line_buf, OLED_FONT_6x8, false);

            // Dòng 5: Trạng thái Calib & Heartbeat
            snprintf(line_buf, sizeof(line_buf), "CALIB:%s  HB:%-4d", g_vl53_app.calib_done ? "OK" : "NO", g_vl53_app.d_heartbeat % 1000);
            OLED_DrawString_Font(0, 54, line_buf, OLED_FONT_6x8, false);
        } else {
            // Hiển thị số to
            snprintf(line_buf, sizeof(line_buf), "NODE #%02d DIST", g_vl53_app.node_id);
            OLED_DrawString_Font(10, 0, line_buf, OLED_FONT_6x8, false);

            snprintf(line_buf, sizeof(line_buf), "%4d", g_vl53_app.d_distance_filtered);
            OLED_DrawString_Font(12, 16, line_buf, OLED_FONT_16x26, false);

            snprintf(line_buf, sizeof(line_buf), "mm");
            OLED_DrawString_Font(95, 30, line_buf, OLED_FONT_8x16, false);

            snprintf(line_buf, sizeof(line_buf), "ID:0x%03X TX:%lu", g_can_stats.tx_can_id, g_can_stats.tx_count);
            OLED_DrawString_Font(0, 54, line_buf, OLED_FONT_6x8, true);
        }
    }

    OLED_UpdateScreen();
}
