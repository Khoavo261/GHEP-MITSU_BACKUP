/**
 * @file can_vl53.c
 * @brief IMPLEMENTATION DRIVER TRUYỀN THÔNG CAN-BUS (TỰ ĐỘNG NHẬN DIỆN MASTER / SLAVE)
 */

#include "can_vl53.h"
#include "VL53L.h"
#include <string.h>

CAN_VL53_Stats_t g_can_stats = {
    .node_id = 0,
    .tx_can_id = 0x180,
    .rx_cmd_id = 0x200,
    .tx_count = 0,
    .rx_count = 0,
    .tx_error_count = 0,
    .last_rx_target = 0,
    .last_rx_cmd = 0,
    .online_slaves_cnt = 0,
    .can_bus_ok = false
};

Slave_Node_Record_t g_slave_nodes[MAX_SLAVE_NODES];
static uint32_t last_tx_time = 0;

/* ==============================================================================
 *                       ĐỌC ĐỊA CHỈ PHẦN CỨNG PB8 & PB9
 * ============================================================================== */

uint8_t CAN_Read_Hardware_NodeID(void) {
    // Đọc trạng thái chân (Có trở kéo lên Pull-up: Hở mạch = 1 / SET, Nối GND = 0 / RESET)
    uint8_t bit0 = (HAL_GPIO_ReadPin(CAN_ADDR_BIT0_GPIO_Port, CAN_ADDR_BIT0_Pin) == GPIO_PIN_RESET) ? 1 : 0;
    uint8_t bit1 = (HAL_GPIO_ReadPin(CAN_ADDR_BIT1_GPIO_Port, CAN_ADDR_BIT1_Pin) == GPIO_PIN_RESET) ? 1 : 0;
    
    // Mapping: PB9=1/PB8=1 -> 1; PB9=1/PB8=0 -> 2; PB9=0/PB8=1 -> 3; PB9=0/PB8=0 -> 4
    uint8_t node_id = 1 + (bit1 << 1) + bit0;
    return node_id;
}

/* ==============================================================================
 *                       CẤU HÌNH BỘ LỌC CAN FILTER
 * ============================================================================== */

static bool Configure_CAN_Filters(uint8_t node_id) {
    if (MASTER) {
        g_can_stats.node_id = 0;
        g_can_stats.tx_can_id = 0x180;
        g_can_stats.rx_cmd_id = 0x200;
    } else {
        g_can_stats.node_id = node_id;
        g_can_stats.tx_can_id = CAN_BASE_TX_DATA_ID + node_id;
        g_can_stats.rx_cmd_id = CAN_BASE_RX_CMD_ID + node_id;
    }

    CAN_FilterTypeDef canFilter;
    canFilter.FilterBank = 0;
    canFilter.FilterMode = CAN_FILTERMODE_IDMASK;
    canFilter.FilterScale = CAN_FILTERSCALE_32BIT;
    canFilter.FilterIdHigh = 0x0000;
    canFilter.FilterIdLow = 0x0000;
    canFilter.FilterMaskIdHigh = 0x0000;
    canFilter.FilterMaskIdLow = 0x0000;
    canFilter.FilterFIFOAssignment = CAN_RX_FIFO0;
    canFilter.FilterActivation = ENABLE;
    canFilter.SlaveStartFilterBank = 14;

    return (HAL_CAN_ConfigFilter(&VL53_CAN_HANDLE, &canFilter) == HAL_OK);
}

bool CAN_VL53_Init(uint8_t node_id) {
    memset(g_slave_nodes, 0, sizeof(g_slave_nodes));
    for (uint8_t i = 0; i < MAX_SLAVE_NODES; i++) {
        g_slave_nodes[i].node_id = i + 1;
    }

    if (!Configure_CAN_Filters(node_id)) {
        g_can_stats.can_bus_ok = false;
        return false;
    }

    if (HAL_CAN_Start(&VL53_CAN_HANDLE) != HAL_OK) {
        g_can_stats.can_bus_ok = false;
        return false;
    }

    if (HAL_CAN_ActivateNotification(&VL53_CAN_HANDLE, CAN_IT_RX_FIFO0_MSG_PENDING | CAN_IT_ERROR_WARNING | CAN_IT_ERROR_PASSIVE | CAN_IT_BUSOFF) != HAL_OK) {
        g_can_stats.can_bus_ok = false;
        return false;
    }

    g_can_stats.can_bus_ok = true;
    return true;
}

void CAN_VL53_SetNodeId(uint8_t new_node_id) {
    Configure_CAN_Filters(new_node_id);
}

/* ==============================================================================
 *                       PHÁT DỮ LIỆU CẢM BIẾN LÊN CAN-BUS
 * ============================================================================== */

bool CAN_VL53_Transmit_SensorData(void) {
    if (!g_can_stats.can_bus_ok) {
        return false;
    }

    CAN_TxHeaderTypeDef txHeader;
    uint8_t txData[8];
    uint32_t txMailbox = 0;

    txHeader.StdId = g_can_stats.tx_can_id;
    txHeader.ExtId = 0x00;
    txHeader.IDE = CAN_ID_STD;
    txHeader.RTR = CAN_RTR_DATA;
    txHeader.DLC = 8;
    txHeader.TransmitGlobalTime = DISABLE;

    txData[0] = (uint8_t)(g_vl53_app.d_distance_filtered & 0xFF);
    txData[1] = (uint8_t)(g_vl53_app.d_distance_filtered >> 8);
    txData[2] = (uint8_t)(g_vl53_app.d_distance_raw & 0xFF);
    txData[3] = (uint8_t)(g_vl53_app.d_distance_raw >> 8);
    txData[4] = (uint8_t)(g_vl53_app.d_status & 0xFF);
    txData[5] = (uint8_t)(g_vl53_app.d_error & 0xFF);
    txData[6] = (uint8_t)(g_vl53_app.d_heartbeat & 0xFF);
    txData[7] = (uint8_t)(g_vl53_app.d_calib_offset & 0xFF);

    if (HAL_CAN_GetTxMailboxesFreeLevel(&VL53_CAN_HANDLE) > 0) {
        if (HAL_CAN_AddTxMessage(&VL53_CAN_HANDLE, &txHeader, txData, &txMailbox) == HAL_OK) {
            g_can_stats.tx_count++;
            return true;
        }
    }

    g_can_stats.tx_error_count++;
    return false;
}

/* ==============================================================================
 *                       MASTER PHÁT LỆNH CALIB / ĐỔI ID XUỐNG SLAVE
 * ============================================================================== */

bool CAN_Master_Send_Command(uint8_t target_node, uint8_t cmd, uint16_t target_dist) {
    if (!g_can_stats.can_bus_ok) return false;

    CAN_TxHeaderTypeDef txHeader;
    uint8_t txData[4];
    uint32_t txMailbox = 0;

    txHeader.StdId = (target_node == 0 || target_node == 255) ? CAN_BROADCAST_CMD_ID : (CAN_BASE_RX_CMD_ID + target_node);
    txHeader.ExtId = 0x00;
    txHeader.IDE = CAN_ID_STD;
    txHeader.RTR = CAN_RTR_DATA;
    txHeader.DLC = 4;
    txHeader.TransmitGlobalTime = DISABLE;

    txData[0] = (uint8_t)(target_dist & 0xFF);
    txData[1] = (uint8_t)(target_dist >> 8);
    txData[2] = cmd;
    txData[3] = 0x5A; // Mã xác thực lệnh thực thi

    if (HAL_CAN_GetTxMailboxesFreeLevel(&VL53_CAN_HANDLE) > 0) {
        if (HAL_CAN_AddTxMessage(&VL53_CAN_HANDLE, &txHeader, txData, &txMailbox) == HAL_OK) {
            g_can_stats.tx_count++;
            return true;
        }
    }

    g_can_stats.tx_error_count++;
    return false;
}

/* ==============================================================================
 *                       CALLBACK NGẮT NHẬN CAN-BUS
 * ============================================================================== */

void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan) {
    CAN_RxHeaderTypeDef rxHeader;
    uint8_t rxData[8];

    if (HAL_CAN_GetRxMessage(hcan, CAN_RX_FIFO0, &rxHeader, rxData) == HAL_OK) {
        if (MASTER) {
            // ----------------- XỬ LÝ TRÊN BO MASTER -----------------
            // Thu thập dữ liệu từ các Slave Node (ID: 0x181 .. 0x180 + MAX_SLAVE_NODES)
            if (rxHeader.IDE == CAN_ID_STD && rxHeader.StdId >= 0x181 && rxHeader.StdId <= (0x180 + MAX_SLAVE_NODES) && rxHeader.DLC >= 8) {
                uint8_t slave_idx = (uint8_t)(rxHeader.StdId - 0x181);
                if (slave_idx < MAX_SLAVE_NODES) {
                    g_slave_nodes[slave_idx].node_id             = slave_idx + 1;
                    g_slave_nodes[slave_idx].d_distance_filtered = (uint16_t)rxData[0] | ((uint16_t)rxData[1] << 8);
                    g_slave_nodes[slave_idx].d_distance_raw      = (uint16_t)rxData[2] | ((uint16_t)rxData[3] << 8);
                    g_slave_nodes[slave_idx].d_status            = rxData[4];
                    g_slave_nodes[slave_idx].d_error             = rxData[5];
                    g_slave_nodes[slave_idx].d_heartbeat         = rxData[6];
                    g_slave_nodes[slave_idx].d_calib_offset      = (int8_t)rxData[7];
                    g_slave_nodes[slave_idx].last_seen_tick      = HAL_GetTick();
                    g_slave_nodes[slave_idx].is_online           = true;
                    g_can_stats.rx_count++;
                }
            }
        } else {
            // ----------------- XỬ LÝ TRÊN BO SLAVE -----------------
            bool is_for_me = (rxHeader.StdId == g_can_stats.rx_cmd_id) || (rxHeader.StdId == CAN_BROADCAST_CMD_ID);
            if (is_for_me && rxHeader.DLC >= 3) {
                uint16_t target = (uint16_t)rxData[0] | ((uint16_t)rxData[1] << 8);
                uint8_t  cmd    = rxData[2];

                if (rxHeader.DLC == 3 || rxData[3] == 0x5A) {
                    g_can_stats.rx_count++;
                    g_can_stats.last_rx_cmd = cmd;
                    g_can_stats.last_rx_target = target;
                    VL53L_SetPendingCalib(cmd, target);
                }
            }
        }
    }
}

/* ==============================================================================
 *                       TÁC VỤ CAN THỰC THI TRONG FREERTOS
 * ============================================================================== */

void CAN_VL53_Task_Run(void) {
    uint32_t now = HAL_GetTick();

    // Tự động phục hồi bus nếu gặp lỗi
    if (HAL_CAN_GetState(&VL53_CAN_HANDLE) == HAL_CAN_STATE_ERROR) {
        HAL_CAN_ResetError(&VL53_CAN_HANDLE);
        HAL_CAN_Start(&VL53_CAN_HANDLE);
    }

    if (MASTER) {
        // MASTER: Quét kiểm tra trạng thái Online/Offline của các Slave
        uint8_t online_count = 0;
        for (uint8_t i = 0; i < MAX_SLAVE_NODES; i++) {
            if (g_slave_nodes[i].is_online) {
                if (now - g_slave_nodes[i].last_seen_tick > SLAVE_OFFLINE_TIMEOUT_MS) {
                    g_slave_nodes[i].is_online = false;
                    g_slave_nodes[i].d_distance_filtered = 0; // Đánh dấu 0 khi mất kết nối
                    g_slave_nodes[i].d_status = 0;
                } else {
                    online_count++;
                }
            }
        }
        g_can_stats.online_slaves_cnt = online_count;
    } else {
        // SLAVE: Phát gói dữ liệu định kỳ mỗi 50ms
        uint32_t tx_interval = 50;
        if (now - last_tx_time >= tx_interval) {
            last_tx_time = now;
            g_vl53_app.d_heartbeat++;
            CAN_VL53_Transmit_SensorData();
        }
    }
}
