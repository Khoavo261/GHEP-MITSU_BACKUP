/**
 * @file VL53L.h
 * @brief THƯ VIỆN CẢM BIẾN VL53L1X <-> PLC MITSUBISHI Q-SERIES (HIỂN THỊ CHI TIẾT ENDCODE & PAYLOAD)
 */

#ifndef VL53L_H
#define VL53L_H

#include "main.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

extern UART_HandleTypeDef huart6;
#define VL53L_PLC_UART_HANDLE       huart6

extern I2C_HandleTypeDef  hi2c1;
#define VL53L_SENSOR_I2C_HANDLE     hi2c1

#define VL53L_SENSOR_INT_PIN        GPIO_PIN_7
#define VL53L_I2C_ADDR              0x52

#define VL53L_PLC_D_START_ADDR      900     // Ghi D900..D905
#define VL53L_PLC_D_TOTAL_POINTS    6

#define VL53L_PLC_READ_D_ADDR       910     // Đọc D910 & D911
#define VL53L_PLC_READ_D_POINTS     2

typedef struct {
    uint16_t d_distance_filtered;   // D900
    uint16_t d_distance_raw;        // D901
    uint16_t d_status;              // D902
    uint16_t d_error;               // D903
    uint16_t d_scan_time_ms;        // D904
    uint16_t d_heartbeat;           // D905

    // Dữ liệu đọc từ PLC
    uint16_t d_calib_target;        // D910
    uint16_t d_calib_cmd_flag;      // D911 / M910
    int16_t  d_calib_offset;        // Offset
    bool     calib_done;

    // Chẩn đoán PLC
    uint16_t plc_last_end_code;     // Mã phản hồi từ PLC (0x0000: Thành công)
    uint8_t  plc_last_p_len;        // Độ dài payload giải mã được
    bool     sensor_ok;
    uint8_t  raw_range_status;
    uint32_t comm_success_count;
    uint32_t read_success_count;
    uint32_t total_rx_bytes;
    uint8_t  last_rx_bytes[8];
} VL53L_AppData_t;

extern VL53L_AppData_t g_vl53_app;

void VL53L_Init(void);
void VL53L_Task_Sensor(void);
void VL53L_Task_PLC(void);
void VL53L_Process_PLC_Response(const uint8_t *rx_buf, uint16_t len);

#ifdef __cplusplus
}
#endif

#endif /* VL53L_H */
