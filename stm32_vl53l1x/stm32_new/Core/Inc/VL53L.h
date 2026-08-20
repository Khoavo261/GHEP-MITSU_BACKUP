/**
 * @file VL53L.h
 * @brief THƯ VIỆN CẢM BIẾN VL53L1X <-> PLC MITSUBISHI Q-SERIES (GHI D900..D905 & ĐỌC D910/M910 TỪ PLC)
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
#define VL53L_PLC_D_START_ADDR      900     // Ghi D900..D905
#define VL53L_PLC_D_TOTAL_POINTS    6

#define VL53L_PLC_READ_D_ADDR       910     // Đọc D910 (Target mm) & D911 (Cờ M910)
#define VL53L_PLC_READ_D_POINTS     2

/* ==============================================================================
 *                       CẤU TRÚC DỮ LIỆU ĐỒNG BỘ PLC & CALIBRATION
 * ============================================================================== */
typedef struct {
    // 1. Dữ liệu ghi xuống PLC (D900..D905)
    uint16_t d_distance_filtered;   // D900: Khoảng cách sau lọc & sau Calib (mm)
    uint16_t d_distance_raw;        // D901: Khoảng cách đo thô nguyên bản (mm)
    uint16_t d_status;              // D902: Trạng thái (Bit 0: OK, Bit 3: Calib OK)
    uint16_t d_error;               // D903: Mã lỗi cảm biến
    uint16_t d_scan_time_ms;        // D904: Chu kỳ quét (50ms)
    uint16_t d_heartbeat;           // D905: Nhịp tim sống tăng liên tục

    // 2. Dữ liệu STM32 ĐỌC TỪ PLC/HMI (D910 & M910/D911)
    uint16_t d_calib_target;        // D910: Đọc từ PLC (Khoảng cách chuẩn đặt trên HMI, ví dụ 500mm)
    uint16_t d_calib_cmd_flag;      // D911 (hoặc M910): Đọc từ PLC (1 = Yêu cầu Calib)
    int16_t  d_calib_offset;        // Độ lệch bù trừ đã tính và lưu Flash: Offset = D910 - D901 (mm)
    bool     calib_done;            // Báo Calib đã hoàn tất

    // Biến nội bộ
    bool     sensor_ok;
    uint8_t  raw_range_status;
    uint32_t comm_success_count;
    uint32_t read_success_count;
} VL53L_AppData_t;

extern VL53L_AppData_t g_vl53_app;

/* ==============================================================================
 *                       HÀM GIAO TIẾP & THỰC THI
 * ============================================================================== */

/**
 * @brief Khởi tạo toàn bộ Cảm biến ToF, khôi phục Flash và khởi động UART RX
 */
void VL53L_Init(void);

/**
 * @brief Task đọc cảm biến (chạy chu kỳ 30ms hoặc theo ngắt PB7)
 */
void VL53L_Task_Sensor(void);

/**
 * @brief Task truyền thông 2 chiều với PLC QJ71 (Ghi D900..D905 và Đọc D910/M910)
 */
void VL53L_Task_PLC(void);

/**
 * @brief Xử lý gói tin nhận về từ PLC (Tự động bóc tách phản hồi Đọc D910/M910)
 */
void VL53L_Process_PLC_Response(const uint8_t *rx_buf, uint16_t len);

#ifdef __cplusplus
}
#endif

#endif /* VL53L_H */
