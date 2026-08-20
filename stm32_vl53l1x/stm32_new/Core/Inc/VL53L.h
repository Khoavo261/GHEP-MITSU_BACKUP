/**
 * @file VL53L.h
 * @brief THƯ VIỆN CẢM BIẾN VL53L1X <-> PLC MITSUBISHI Q-SERIES (DIAGNOSTIC & BIDIRECTIONAL ENGINE)
 */

#ifndef VL53L_H
#define VL53L_H

#include "main.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ==============================================================================
 *                       KHU VỰC CẤU HÌNH PHẦN CỨNG
 * ============================================================================== */

extern UART_HandleTypeDef huart6;
#define VL53L_PLC_UART_HANDLE       huart6

extern I2C_HandleTypeDef  hi2c1;
#define VL53L_SENSOR_I2C_HANDLE     hi2c1

#define VL53L_SENSOR_INT_PIN        GPIO_PIN_7
#define VL53L_I2C_ADDR              0x52

#define VL53L_PLC_D_START_ADDR      900     // Ghi D900..D905
#define VL53L_PLC_D_TOTAL_POINTS    6

#define VL53L_PLC_READ_D_ADDR       910     // Đọc D910 (Target mm) & D911 (Cờ M910)
#define VL53L_PLC_READ_D_POINTS     2

/* ==============================================================================
 *                       CẤU TRÚC DỮ LIỆU ĐỒNG BỘ PLC & CHẨN ĐOÁN
 * ============================================================================== */
typedef struct {
    // 1. Dữ liệu ghi xuống PLC (D900..D905)
    uint16_t d_distance_filtered;   // D900: Khoảng cách sau lọc & Calib (mm)
    uint16_t d_distance_raw;        // D901: Khoảng cách đo thô (mm)
    uint16_t d_status;              // D902: Trạng thái
    uint16_t d_error;               // D903: Mã lỗi cảm biến
    uint16_t d_scan_time_ms;        // D904: Chu kỳ quét (50ms)
    uint16_t d_heartbeat;           // D905: Nhịp tim sống

    // 2. Dữ liệu ĐỌC TỪ PLC (D910 & M910/D911)
    uint16_t d_calib_target;        // D910: Đọc từ PLC (Khoảng cách chuẩn HMI)
    uint16_t d_calib_cmd_flag;      // D911 / M910: Cờ Calib từ PLC (1 = Calib)
    int16_t  d_calib_offset;        // Độ lệch tính được và lưu Flash
    bool     calib_done;            // Báo Calib hoàn tất

    // 3. Thông số giám sát truyền thông thời gian thực
    bool     sensor_ok;
    uint8_t  raw_range_status;
    uint32_t comm_success_count;
    uint32_t read_success_count;
    uint32_t total_rx_bytes;
    uint8_t  last_rx_bytes[8];      // 8 byte gần nhất nhận từ UART
} VL53L_AppData_t;

extern VL53L_AppData_t g_vl53_app;

/* ==============================================================================
 *                       HÀM GIAO TIẾP & THỰC THI
 * ============================================================================== */

void VL53L_Init(void);
void VL53L_Task_Sensor(void);
void VL53L_Task_PLC(void);
void VL53L_Process_PLC_Response(const uint8_t *rx_buf, uint16_t len);

#ifdef __cplusplus
}
#endif

#endif /* VL53L_H */
