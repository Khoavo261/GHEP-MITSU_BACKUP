/**
 * @file app_config.h
 * @brief CẤU HÌNH HỆ THỐNG ĐA NĂNG MASTER / SLAVE - STM32F103C8T6
 */

#ifndef APP_CONFIG_H
#define APP_CONFIG_H

#include "main.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ==============================================================================
 *           CẤU HÌNH VAI TRÒ BO MẠCH (MASTER / SLAVE)
 * ============================================================================== */
/**
 * @brief CẤU HÌNH VAI TRÒ HOẠT ĐỘNG:
 *   - MASTER = 1 (Bo MASTER):
 *       + Nhận toàn bộ gói tin CAN từ tất cả các bo Slave (0x181 .. 0x18F)
 *       + Đóng gói gửi toàn bộ dữ liệu (Master + Slaves) về PLC Mitsubishi qua UART DMA (PA9/PA10)
 *       + Nhận lệnh Calib từ PLC để phân phối qua CAN-Bus cho các Slave
 *       + Màn hình OLED hiển thị thông số Master + tổng số Slave Online + trạng thái PLC Link
 *
 *   - MASTER = 0 (Bo SLAVE):
 *       + Định kỳ phát dữ liệu 8-byte qua CAN-Bus (ID = 0x180 + Node_ID) lên Master
 *       + Nhận lệnh Calib riêng (0x200 + Node_ID) hoặc chung (0x200) từ Master
 *       + Màn hình OLED hiển thị thông số Node riêng
 */
#define MASTER                          1    // 1: MASTER, 0: SLAVE

/* ==============================================================================
 *                       CẤU HÌNH MẠNG CAN-BUS
 * ============================================================================== */
#define MAX_SLAVE_NODES                 8    // Số lượng Slave Nodes tối đa quản lý trên PLC (1..16)
#define SLAVE_OFFLINE_TIMEOUT_MS        1500 // Thời gian không nhận được CAN thì báo Node mất kết nối (Offline)

/* ==============================================================================
 *                       CẤU HÌNH TRUYỀN THÔNG PLC MITSUBISHI Q-SERIES
 * ============================================================================== */
// Cấu hình cổng UART kết nối module QJ71C24N-R4 (Format 5 Binary):
#define PLC_UART_BAUDRATE               9600
#define PLC_UART_PARITY                 UART_PARITY_ODD
#define PLC_UART_STOPBITS               UART_STOPBITS_1
#define PLC_UART_WORDLENGTH             UART_WORDLENGTH_9B // 8 Data + 1 Parity = 9B

// Ánh xạ địa chỉ thanh ghi D trên PLC:
// Master ghi lên PLC:
#define PLC_D_BASE_MASTER               900   // D900..D905 (Master ToF: Dist, Raw, Status, Error, Online Count, HB)
#define PLC_D_BASE_SLAVES               910   // D910..D915 (Slave 1), D920..D925 (Slave 2)...
#define PLC_D_WORDS_PER_NODE            6     // 6 Words cho mỗi Node

// Master đọc từ PLC:
#define PLC_D_READ_CMD_ADDR             950   // D950 (Node ID cần Calib: 0=Master, 1..N=Slave), D951 (Target mm), D952 (Mã lệnh: 10,20,30,99)
#define PLC_D_READ_CMD_POINTS           3     // 3 Words (D950, D951, D952)

#ifdef __cplusplus
}
#endif

#endif /* APP_CONFIG_H */
