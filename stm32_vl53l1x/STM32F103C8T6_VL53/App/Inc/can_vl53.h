/**
 * @file can_vl53.h
 * @brief DRIVER TRUYỀN THÔNG CAN-BUS ĐA NĂNG (HỖ TRỢ CẢ BO MASTER & BO SLAVE)
 */

#ifndef CAN_VL53_H
#define CAN_VL53_H

#include "main.h"
#include "app_config.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ==============================================================================
 *                       CẤU HÌNH ĐỊNH DANH CAN ID
 * ============================================================================== */
#define CAN_BASE_TX_DATA_ID         0x180   // Base ID phát dữ liệu Slave: 0x180 + Node_ID
#define CAN_BASE_RX_CMD_ID          0x200   // Base ID nhận lệnh riêng: 0x200 + Node_ID
#define CAN_BROADCAST_CMD_ID        0x200   // ID nhận lệnh chung (Broadcast): 0x200

#define DEFAULT_NODE_ID             1       // Node ID mặc định cho bo Slave

extern CAN_HandleTypeDef hcan;
#define VL53_CAN_HANDLE             hcan

/* ==============================================================================
 *                       CẤU TRÚC DỮ LIỆU SLAVE NODE (TRÊN MASTER)
 * ============================================================================== */
typedef struct {
    uint8_t  node_id;               // ID của Node (1..MAX_SLAVE_NODES)
    uint16_t d_distance_filtered;   // Khoảng cách đã lọc (mm)
    uint16_t d_distance_raw;        // Khoảng cách thô (mm)
    uint16_t d_status;              // Status word (Bit0=OK, Bit1=<200mm, Bit2=In-range, Bit3=Calib)
    uint16_t d_error;               // Mã lỗi Range Status
    uint8_t  d_heartbeat;           // Heartbeat từ cảm biến
    int8_t   d_calib_offset;        // Độ lệch bù Calib (mm)
    uint32_t last_seen_tick;        // Thời điểm nhận gói tin gần nhất
    bool     is_online;             // true: Node đang kết nối tốt, false: Offline
} Slave_Node_Record_t;

/* ==============================================================================
 *                       THỐNG KÊ TRUYỀN THÔNG CAN
 * ============================================================================== */
typedef struct {
    uint8_t  node_id;           // Node ID (nếu là Slave) hoặc 0 (nếu là Master)
    uint16_t tx_can_id;         // CAN ID phát dữ liệu
    uint16_t rx_cmd_id;         // CAN ID nhận lệnh
    
    uint32_t tx_count;          // Tổng số gói đã phát
    uint32_t rx_count;          // Tổng số gói đã nhận
    uint32_t tx_error_count;    // Số gói phát lỗi
    uint16_t last_rx_target;    // Target nhận gần nhất
    uint8_t  last_rx_cmd;       // Lệnh nhận gần nhất
    uint8_t  online_slaves_cnt; // Số lượng Slave đang Online (dành cho Master)
    bool     can_bus_ok;        // Trạng thái CAN Bus sẵn sàng
} CAN_VL53_Stats_t;

extern CAN_VL53_Stats_t g_can_stats;
extern Slave_Node_Record_t g_slave_nodes[MAX_SLAVE_NODES];

/* ==============================================================================
 *                       CÁC HÀM GIAO TIẾP CAN-BUS
 * ============================================================================== */

/**
 * @brief Đọc địa chỉ Node ID phần cứng từ 2 chân PB8 (Bit 0) và PB9 (Bit 1)
 *        (Chỉ đọc 1 lần duy nhất khi khởi động MCU)
 * 
 * Bảng ánh xạ Node ID (Có trở kéo lên 3.3V nội bộ):
 *   PB9=1 (Hở), PB8=1 (Hở)   --> Node ID = 1 (Mặc định)
 *   PB9=1 (Hở), PB8=0 (GND)  --> Node ID = 2
 *   PB9=0 (GND), PB8=1 (Hở)  --> Node ID = 3
 *   PB9=0 (GND), PB8=0 (GND) --> Node ID = 4
 */
uint8_t CAN_Read_Hardware_NodeID(void);

/**
 * @brief Khởi tạo phần cứng CAN, cấu hình bộ lọc theo chế độ Master hoặc Slave
 */
bool CAN_VL53_Init(uint8_t node_id);

/**
 * @brief Đổi Node ID và cấu hình lại bộ lọc CAN (khi là Slave)
 */
void CAN_VL53_SetNodeId(uint8_t new_node_id);

/**
 * @brief Tác vụ CAN chạy trong FreeRTOS:
 *        - Nếu là Slave: Phát gói cảm biến định kỳ 50ms lên Master
 *        - Nếu là Master: Quét kiểm tra trạng thái Online/Offline của các Slave
 */
void CAN_VL53_Task_Run(void);

/**
 * @brief Phát gói cảm biến (Dành cho Slave hoặc Master phát dự phòng)
 */
bool CAN_VL53_Transmit_SensorData(void);

/**
 * @brief Master phát lệnh Calib / Cài đặt xuống 1 Node hoặc toàn bộ các Node qua CAN
 * @param target_node ID của Node (0 = Broadcast toàn mạng, 1..N = Node cụ thể)
 * @param cmd Mã lệnh (10=Soft Calib, 20=Hard Calib, 30=Xtalk, 99=Đổi Node ID)
 * @param target_dist Giá trị cự ly mm hoặc ID mới
 */
bool CAN_Master_Send_Command(uint8_t target_node, uint8_t cmd, uint16_t target_dist);

#ifdef __cplusplus
}
#endif

#endif /* CAN_VL53_H */
