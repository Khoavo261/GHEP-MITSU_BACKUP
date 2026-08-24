/**
 * @file plc_mitsu.h
 * @brief DRIVER GIAO TIẾP PLC MITSUBISHI Q-SERIES (QJ71C24N FORMAT 5) TRÊN STM32F103 MASTER
 */

#ifndef PLC_MITSU_H
#define PLC_MITSU_H

#include "main.h"
#include "app_config.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

extern UART_HandleTypeDef huart1;

typedef struct {
    uint32_t tx_write_count;        // Số lần ghi dữ liệu lên PLC thành công
    uint32_t rx_resp_count;         // Số gói phản hồi hợp lệ từ PLC
    uint32_t comm_error_count;      // Số lần lỗi / timeout
    uint16_t last_plc_end_code;     // Mã lỗi phản hồi từ PLC (0x0000 = OK)
    bool     plc_connected;         // Trạng thái kết nối PLC (true = Đang giao tiếp tốt)
    uint32_t last_success_time;     // Timestamp lần giao tiếp thành công gần nhất
} PLC_Mitsu_Stats_t;

extern PLC_Mitsu_Stats_t g_plc_stats;

/**
 * @brief Khởi tạo UART1 (PA9-TX, PA10-RX) giao tiếp với PLC Mitsubishi
 */
bool PLC_Mitsu_Init(void);

/**
 * @brief Tác vụ truyền thông định kỳ giao tiếp PLC (Ghi D900..D9xx và Đọc D950..D952)
 */
void PLC_Mitsu_Task_Run(void);

/**
 * @brief Xử lý nhận 1 byte từ ngắt UART
 */
void PLC_Mitsu_UART_RxCallback(uint8_t byte);

#ifdef __cplusplus
}
#endif

#endif /* PLC_MITSU_H */
