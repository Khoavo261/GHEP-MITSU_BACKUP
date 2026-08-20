/**
 * @file VL53L.h
 * @brief THƯ VIỆN CẢM BIẾN ToF VL53L1X <-> PLC MITSUBISHI Q-SERIES (TÍCH HỢP TÍNH NĂNG CALIB D910 & M910)
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

// 1. Tên biến UART kết nối sang module PLC QJ71
extern UART_HandleTypeDef huart6;
#define VL53L_PLC_UART_HANDLE       huart6

// 2. Tên biến I2C kết nối sang cảm biến ToF VL53L1X
extern I2C_HandleTypeDef  hi2c1;
#define VL53L_SENSOR_I2C_HANDLE     hi2c1

// 3. Chân ngắt INT của cảm biến ToF
#define VL53L_SENSOR_INT_PIN        GPIO_PIN_7

// 4. Địa chỉ I2C của cảm biến VL53L1X
#define VL53L_I2C_ADDR              0x52

// 5. Cấu hình vùng nhớ PLC Mitsubishi Q-Series
#define VL53L_PLC_D_START_ADDR      900     // Bắt đầu từ D900
#define VL53L_PLC_D_TOTAL_POINTS    6       // Gom 6 thanh ghi: D900..D905

/* ==============================================================================
 *                       CẤU TRÚC DỮ LIỆU ĐỒNG BỘ PLC & CALIBRATION
 * ============================================================================== */
typedef struct {
    // 1. Dữ liệu khoảng cách đo (mm)
    uint16_t d_distance_filtered;   // D900: Khoảng cách sau lọc & sau Calib (mm)
    uint16_t d_distance_raw;        // D901: Khoảng cách đo thô nguyên bản (mm)
    
    // 2. Trạng thái & Chẩn đoán lỗi
    uint16_t d_status;              // D902: Bit 0 = Online, Bit 1 = Near <200mm, Bit 2 = In Range
    uint16_t d_error;               // D903: Mã lỗi (0: OK, 1: Signal Fail, 2: Sigma Fail, 30: Mất I2C)
    
    // 3. Hệ thống & Giám sát truyền thông
    uint16_t d_scan_time_ms;        // D904: Chu kỳ quét (50ms)
    uint16_t d_heartbeat;           // D905: Bộ đếm sống tăng liên tục (0..65535)

    // 4. THÔNG SỐ HIỆU CHUẨN (CALIBRATION TỪ HMI)
    uint16_t d_calib_target;        // D910: Khoảng cách chuẩn đặt từ HMI (mặc định 500 mm)
    int16_t  d_calib_offset;        // Độ lệch bù trừ tính được: Offset = D910 - D901 (mm)
    bool     m_calib_trigger;       // M910: Cờ lệnh kích hoạt Calib từ HMI
    bool     calib_done;            // Báo trạng thái Calib hoàn tất

    // Biến nội bộ vi điều khiển
    bool     sensor_ok;
    uint8_t  raw_range_status;
    uint32_t comm_success_count;
} VL53L_AppData_t;

extern VL53L_AppData_t g_vl53_app;

/* ==============================================================================
 *                       HÀM GIAO TIẾP & CALIBRATION
 * ============================================================================== */

/**
 * @brief Khởi tạo toàn bộ Cảm biến ToF và Ngắt nhận UART
 */
void VL53L_Init(void);

/**
 * @brief Task đọc cảm biến (chạy chu kỳ 30ms hoặc theo ngắt PB7)
 */
void VL53L_Task_Sensor(void);

/**
 * @brief Task phát gom 6 thanh ghi D900..D905 qua DMA TX lên PLC (chu kỳ 100ms)
 */
void VL53L_Task_PLC(void);

/**
 * @brief Đặt khoảng cách chuẩn D910 để Calib từ HMI
 * @param target_mm Khoảng cách chuẩn đã đo bằng thước (ví dụ: 500mm, 1000mm)
 */
void VL53L_SetCalibTarget(uint16_t target_mm);

/**
 * @brief Kích hoạt lệnh Calib tương đương cờ M910 từ HMI
 */
void VL53L_TriggerCalib(void);

#ifdef __cplusplus
}
#endif

#endif /* VL53L_H */
