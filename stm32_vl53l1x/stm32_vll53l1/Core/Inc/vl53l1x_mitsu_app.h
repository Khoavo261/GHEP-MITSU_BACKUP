/**
 * @file vl53l1x_mitsu_app.h
 * @brief Application layer bridging VL53L1X ToF Sensor with Mitsubishi Q-Series PLC
 *        using MC Protocol Format 4 over UART DMA (TX/RX Idle).
 */

#ifndef _VL53L1X_MITSU_APP_H_
#define _VL53L1X_MITSU_APP_H_

#include "main.h"
#include "VL53L1X_api.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ========================================================================== */
/* CẤU HÌNH TRUYỀN THÔNG MC PROTOCOL & CẢM BIẾN                               */
/* ========================================================================== */
#define PLC_STATION_NO          "00"         // Số trạm QJ71C24 (Trạm 00)
#define PLC_CPU_NO              "FF"         // CPU mặc định Q-Series (FF)
#define REG_DIST_WRITE          "000900"     // Ghi khoảng cách vào D900 của PLC
#define REG_PARAM_READ          "000910"     // Đọc tham số/lệnh từ D910..D911 của PLC
#define NUM_READ_POINTS         2            // Đọc 2 thanh ghi (D910, D911)
#define FILTER_SAMPLES          16           // Số mẫu lọc trung bình động (Moving Average)
#define COMM_PERIOD_MS          50           // Chu kỳ gửi dữ liệu định kỳ (50ms = 20Hz)
#define VL53L1X_I2C_ADDR        0x52         // Địa chỉ I2C mặc định của VL53L1X

#define UART_TX_BUF_SIZE        128
#define UART_RX_BUF_SIZE        128

/* ========================================================================== */
/* CẤU TRÚC DỮ LIỆU ĐIỀU KHIỂN                                                */
/* ========================================================================== */
typedef struct {
    uint16_t raw_distance_mm;       // Khoảng cách thô từ sensor (mm)
    uint16_t filtered_distance_mm;  // Khoảng cách sau lọc trung bình động (mm)
    uint8_t  range_status;          // 0: Hợp lệ, khác 0: Lỗi quang/ngoại cảnh
    bool     sensor_ok;             // Trạng thái khởi tạo sensor thành công
    
    // Dữ liệu đọc về từ PLC
    uint16_t plc_param_D910;        // D910: Ngưỡng cảnh báo / Setpoint
    uint16_t plc_param_D911;        // D911: Lệnh điều khiển / Chế độ từ HMI/PLC
    uint32_t comm_success_count;    // Đếm số gói giao tiếp thành công với PLC
    uint32_t comm_error_count;      // Đếm số gói lỗi / timeout
} VL53L1X_AppData_t;

extern VL53L1X_AppData_t g_vl53_app;

/* ========================================================================== */
/* HÀM GIAO TIẾP ỨNG DỤNG                                                     */
/* ========================================================================== */
/**
 * @brief Khởi tạo cảm biến VL53L1X và kênh truyền thông UART DMA
 */
void VL53L1X_App_Init(void);

/**
 * @brief Xử lý đọc khoảng cách & truyền nhận MC Protocol định kỳ (gọi trong while(1))
 */
void VL53L1X_App_Process(void);

#ifdef __cplusplus
}
#endif

#endif /* _VL53L1X_MITSU_APP_H_ */
