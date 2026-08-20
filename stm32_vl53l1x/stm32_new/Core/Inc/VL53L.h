/**
 * @file VL53L.h
 * @brief THƯ VIỆN 1 FILE DUY NHẤT: CẢM BIẾN ToF VL53L1X <-> PLC MITSUBISHI Q-SERIES
 * @note  Tương thích 100% mọi dòng STM32 (F1, F4, F7, H7, G0, L4...)
 * 
 * ==============================================================================
 *                       HƯỚNG DẪN DÙNG CHO DỰ ÁN MỚI
 * ==============================================================================
 * 1. Chỉ cần copy đúng 2 file vào project mới:
 *        - Core/Inc/VL53L.h
 *        - Core/Src/VL53L.c
 * 2. Cấu hình bên dưới đúng tên biến UART và I2C trong STM32CubeMX:
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

// 1. Tên biến UART kết nối sang module PLC QJ71 (huart1, huart2, huart3, huart6...)
extern UART_HandleTypeDef huart6;
#define VL53L_PLC_UART_HANDLE       huart6

// 2. Tên biến I2C kết nối sang cảm biến ToF VL53L1X (hi2c1, hi2c2, hi2c3...)
extern I2C_HandleTypeDef  hi2c1;
#define VL53L_SENSOR_I2C_HANDLE     hi2c1

// 3. Chân ngắt INT của cảm biến ToF (ví dụ PB7)
#define VL53L_SENSOR_INT_PIN        GPIO_PIN_7

// 4. Địa chỉ I2C của cảm biến VL53L1X (mặc định 0x52)
#define VL53L_I2C_ADDR              0x52

// 5. Cấu hình vùng nhớ PLC Mitsubishi Q-Series
#define VL53L_PLC_D_START_ADDR      900     // Bắt đầu từ thanh ghi D900
#define VL53L_PLC_D_TOTAL_POINTS    6       // Gom 6 thanh ghi: D900..D905

/* ==============================================================================
 *                       CẤU TRÚC DỮ LIỆU ĐỒNG BỘ PLC
 * ============================================================================== */
typedef struct {
    // 1. Dữ liệu khoảng cách đo (mm)
    uint16_t d_distance_filtered;   // D900: Khoảng cách sau lọc chống rung quang học 3 tầng
    uint16_t d_distance_raw;        // D901: Khoảng cách thô nguyên bản từ cảm biến
    
    // 2. Trạng thái & Chẩn đoán lỗi
    uint16_t d_status;              // D902: Bit 0 = Online, Bit 1 = Near <200mm, Bit 2 = In Range
    uint16_t d_error;               // D903: Mã lỗi (0: OK, 1: Signal Fail, 2: Sigma Fail, 30: Mất I2C)
    
    // 3. Hệ thống & Giám sát truyền thông
    uint16_t d_scan_time_ms;        // D904: Chu kỳ quét (50ms)
    uint16_t d_heartbeat;           // D905: Bộ đếm sống tăng liên tục (0..65535)

    // Biến nội bộ
    bool     sensor_ok;
    uint8_t  raw_range_status;
    uint32_t comm_success_count;
} VL53L_AppData_t;

extern VL53L_AppData_t g_vl53_app;

/* ==============================================================================
 *                       HÀM GIAO TIẾP DUY NHẤT
 * ============================================================================== */

/**
 * @brief Khởi tạo toàn bộ Cảm biến ToF và Ngắt nhận phản hồi UART
 */
void VL53L_Init(void);

/**
 * @brief Task đọc cảm biến (chạy chu kỳ 30ms hoặc theo ngắt PB7)
 */
void VL53L_Task_Sensor(void);

/**
 * @brief Task phát gom 6 thanh ghi D900..D905 qua DMA TX lên PLC (chạy chu kỳ 100ms)
 */
void VL53L_Task_PLC(void);

#ifdef __cplusplus
}
#endif

#endif /* VL53L_H */
