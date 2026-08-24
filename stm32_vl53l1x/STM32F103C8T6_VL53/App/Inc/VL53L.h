/**
 * @file VL53L.h
 * @brief THƯ VIỆN CẢM BIẾN TOF VL53L0X TRÊN STM32F103C8T6 (HỖ TRỢ MULTI-NODE CAN-BUS & FLASH)
 */

#ifndef VL53L_H
#define VL53L_H

#include "main.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

extern I2C_HandleTypeDef hi2c1;

#define VL53L_I2C_ADDR              0x52

/* ==============================================================================
 *                       CẤU TRÚC DỮ LIỆU TOÀN CỤC CỦA HỆ THỐNG
 * ============================================================================== */
typedef struct {
    uint8_t  node_id;               // Node ID của bo (1..64)
    uint16_t d_distance_filtered;   // Khoảng cách sau lọc số (mm)
    uint16_t d_distance_raw;        // Khoảng cách thô từ cảm biến (mm)
    uint16_t d_status;              // Trạng thái Bitmask (Bit0=OK, Bit1=<200mm, Bit2=30..3000mm, Bit3=Calib Done)
    uint16_t d_error;               // Mã lỗi Range Status từ cảm biến (10=I2C NAK, 20=Init Fail)
    uint16_t d_scan_time_ms;        // Chu kỳ đo (50ms)
    uint16_t d_heartbeat;           // Nhịp sống Heartbeat 0..65535
    uint16_t sensor_chip_id;        // ID phần cứng chip ToF (0xEEAA..)
    bool     is_vl53l0x;            // true nếu là chip VL53L0X

    uint16_t d_calib_target;        // Khoảng cách chuẩn Calib (mm)
    uint16_t d_calib_cmd_flag;      // Cờ lệnh Calib
    int16_t  d_calib_offset;        // Giá trị bù Offset (mm)
    bool     calib_done;            // Đã Calib thành công
    bool     sensor_ok;             // Cảm biến ToF sẵn sàng hoạt động
    uint8_t  raw_range_status;      // Range Status gốc từ chip
} VL53L_AppData_t;

extern VL53L_AppData_t g_vl53_app;

/* ==============================================================================
 *                       CÁC HÀM XỬ LÝ CHÍNH
 * ============================================================================== */

/**
 * @brief Khởi tạo cảm biến VL53L0X và load dữ liệu Calib + Node ID từ Flash STM32F103
 */
void VL53L_Init(void);

/**
 * @brief Tác vụ đọc cảm biến ToF VL53L0X và xử lý lọc số (gọi trong FreeRTOS VL53_T)
 */
void VL53L_Task_Sensor(void);

/**
 * @brief Kích hoạt lệnh Calib từ ngoài (gọi từ CAN-Bus hoặc UART)
 */
void VL53L_SetPendingCalib(uint16_t cmd, uint16_t target);

/**
 * @brief Lưu Node ID mới vào Flash vĩnh viễn
 */
bool VL53L_SaveNodeId_To_Flash(uint8_t new_node_id);

#ifdef __cplusplus
}
#endif

#endif /* VL53L_H */
