/**
 * @file plc_mitsu.c
 * @brief IMPLEMENTATION DRIVER TRUYỀN THÔNG PLC MITSUBISHI Q-SERIES CHO BO MASTER
 */

#include "plc_mitsu.h"
#include "can_vl53.h"
#include "VL53L.h"
#include "cmsis_os.h"
#include <stdio.h>
#include <string.h>

#include "usart.h"

static uint8_t rx_byte = 0;
static uint8_t rx_ring[256];
static volatile uint16_t rx_head = 0;
static volatile uint16_t rx_tail = 0;

PLC_Mitsu_Stats_t g_plc_stats = {
    .tx_write_count = 0,
    .rx_resp_count = 0,
    .comm_error_count = 0,
    .last_plc_end_code = 0xFFFF,
    .plc_connected = false,
    .last_success_time = 0
};

typedef enum {
    PLC_STATE_SEND_WRITE = 0,
    PLC_STATE_WAIT_WRITE_RESP,
    PLC_STATE_SEND_READ,
    PLC_STATE_WAIT_READ_RESP,
    PLC_STATE_SEND_CLEAR_CMD,
    PLC_STATE_WAIT_CLEAR_RESP,
    PLC_STATE_IDLE_DELAY
} PLC_State_t;

static PLC_State_t plc_fsm_state = PLC_STATE_SEND_WRITE;
static uint32_t state_timer = 0;
static uint8_t  tx_buf[256];
static uint16_t pending_clear_d952 = 0;

/* ==============================================================================
 *                       KHỞI TẠO TIẾP NHẬN DỮ LIỆU PLC
 * ============================================================================== */

bool PLC_Mitsu_Init(void) {
    rx_head = 0;
    rx_tail = 0;
    // Bắt đầu nhận byte ngắt từ USART1
    return (HAL_UART_Receive_IT(&huart1, &rx_byte, 1) == HAL_OK);
}

void PLC_Mitsu_UART_RxCallback(uint8_t byte) {
    uint16_t next = (rx_head + 1) % sizeof(rx_ring);
    if (next != rx_tail) {
        rx_ring[rx_head] = byte;
        rx_head = next;
    }
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) {
    if (huart->Instance == USART1) {
        PLC_Mitsu_UART_RxCallback(rx_byte);
        HAL_UART_Receive_IT(&huart1, &rx_byte, 1);
    }
}

/* ==============================================================================
 *                       XÂY DỰNG GÓI TIN MITSUBISHI FORMAT 5 (BINARY)
 * ============================================================================== */

// Gói Ghi Mảng D-Register lên PLC (Batch Write 0x1401)
static uint16_t Build_Batch_Write_Packet(uint8_t *out, uint16_t head_d_addr, const uint16_t *data, uint16_t num_points) {
    uint8_t payload[256];
    uint16_t p_len = 0;
    uint16_t total_payload_len = 18 + num_points * 2;

    // Chiều dài payload 2 bytes
    payload[p_len++] = (uint8_t)(total_payload_len & 0xFF);
    payload[p_len++] = (uint8_t)((total_payload_len >> 8) & 0xFF);

    // Routing Header (8 bytes chuẩn QJ71)
    payload[p_len++] = 0xF8; payload[p_len++] = 0x00; payload[p_len++] = 0x00;
    payload[p_len++] = 0xFF; payload[p_len++] = 0xFF; payload[p_len++] = 0x03;
    payload[p_len++] = 0x00; payload[p_len++] = 0x00;

    // Lệnh Ghi 0x1401 (Batch Write)
    payload[p_len++] = 0x01; payload[p_len++] = 0x14;
    payload[p_len++] = 0x00; payload[p_len++] = 0x00; // Subcommand

    // Địa chỉ đầu D
    payload[p_len++] = (uint8_t)(head_d_addr & 0xFF);
    payload[p_len++] = (uint8_t)((head_d_addr >> 8) & 0xFF);
    payload[p_len++] = 0x00;
    payload[p_len++] = 0xA8; // Mã thiết bị D

    // Số điểm ghi
    payload[p_len++] = (uint8_t)(num_points & 0xFF);
    payload[p_len++] = (uint8_t)((num_points >> 8) & 0xFF);

    // Mảng dữ liệu
    for (uint16_t i = 0; i < num_points; i++) {
        payload[p_len++] = (uint8_t)(data[i] & 0xFF);
        payload[p_len++] = (uint8_t)((data[i] >> 8) & 0xFF);
    }

    // Tính Checksum
    uint16_t sum = 0;
    for (uint16_t i = 0; i < p_len; i++) sum += payload[i];

    // Đóng gói DLE STX ... DLE ETX + Checksum
    uint16_t tx_idx = 0;
    out[tx_idx++] = 0x10; out[tx_idx++] = 0x02; // DLE STX
    for (uint16_t i = 0; i < p_len; i++) {
        out[tx_idx++] = payload[i];
        if (payload[i] == 0x10) out[tx_idx++] = 0x10; // DLE Escaping
    }
    out[tx_idx++] = 0x10; out[tx_idx++] = 0x03; // DLE ETX
    snprintf((char*)&out[tx_idx], 3, "%02X", (uint8_t)(sum & 0xFF));
    tx_idx += 2;

    return tx_idx;
}

// Gói Đọc Lệnh Calib từ PLC (Batch Read 0x0401 - 3 Words: D950..D952)
static uint16_t Build_Batch_Read_Packet(uint8_t *out, uint16_t head_d_addr, uint16_t num_points) {
    uint8_t payload[32];
    uint16_t p_len = 0;
    uint16_t total_payload_len = 18;

    payload[p_len++] = (uint8_t)(total_payload_len & 0xFF);
    payload[p_len++] = (uint8_t)((total_payload_len >> 8) & 0xFF);

    // Routing Header
    payload[p_len++] = 0xF8; payload[p_len++] = 0x00; payload[p_len++] = 0x00;
    payload[p_len++] = 0xFF; payload[p_len++] = 0xFF; payload[p_len++] = 0x03;
    payload[p_len++] = 0x00; payload[p_len++] = 0x00;

    // Lệnh Đọc 0x0401 (Batch Read)
    payload[p_len++] = 0x01; payload[p_len++] = 0x04;
    payload[p_len++] = 0x00; payload[p_len++] = 0x00;

    // Địa chỉ đầu
    payload[p_len++] = (uint8_t)(head_d_addr & 0xFF);
    payload[p_len++] = (uint8_t)((head_d_addr >> 8) & 0xFF);
    payload[p_len++] = 0x00;
    payload[p_len++] = 0xA8; // Code D

    // Số điểm đọc
    payload[p_len++] = (uint8_t)(num_points & 0xFF);
    payload[p_len++] = (uint8_t)((num_points >> 8) & 0xFF);

    uint16_t sum = 0;
    for (uint16_t i = 0; i < p_len; i++) sum += payload[i];

    uint16_t tx_idx = 0;
    out[tx_idx++] = 0x10; out[tx_idx++] = 0x02;
    for (uint16_t i = 0; i < p_len; i++) {
        out[tx_idx++] = payload[i];
        if (payload[i] == 0x10) out[tx_idx++] = 0x10;
    }
    out[tx_idx++] = 0x10; out[tx_idx++] = 0x03;
    snprintf((char*)&out[tx_idx], 3, "%02X", (uint8_t)(sum & 0xFF));
    tx_idx += 2;

    return tx_idx;
}

/* ==============================================================================
 *                       PARSER PHẢN HỒI TỪ PLC
 * ============================================================================== */

static bool Parse_PLC_Response(uint8_t *extracted_payload, uint16_t *payload_len, uint16_t *end_code) {
    uint8_t raw[128];
    uint16_t count = 0;

    while (rx_head != rx_tail && count < sizeof(raw)) {
        raw[count++] = rx_ring[rx_tail];
        rx_tail = (rx_tail + 1) % sizeof(rx_ring);
    }

    if (count < 6) return false;

    // Tìm DLE STX (0x10 0x02) và DLE ETX (0x10 0x03)
    int stx_pos = -1;
    int etx_pos = -1;
    for (int i = 0; i < count - 1; i++) {
        if (raw[i] == 0x10 && raw[i+1] == 0x02 && stx_pos < 0) {
            stx_pos = i;
        }
        if (raw[i] == 0x10 && raw[i+1] == 0x03 && stx_pos >= 0 && (i > stx_pos + 1)) {
            etx_pos = i;
            break;
        }
    }

    if (stx_pos < 0 || etx_pos < 0) return false;

    // Giải nén DLE byte stuffing
    uint16_t p_idx = 0;
    for (int i = stx_pos + 2; i < etx_pos; i++) {
        if (raw[i] == 0x10 && (i + 1 < etx_pos) && raw[i+1] == 0x10) {
            extracted_payload[p_idx++] = 0x10;
            i++;
        } else {
            extracted_payload[p_idx++] = raw[i];
        }
    }

    *payload_len = p_idx;
    if (p_idx >= 14) {
        // End Code nằm ở byte 12..13
        *end_code = (uint16_t)extracted_payload[12] | ((uint16_t)extracted_payload[13] << 8);
        return true;
    }
    return false;
}

/* ==============================================================================
 *                       TÁC VỤ GIAO TIẾP PLC CHẠY ĐỊNH KỲ
 * ============================================================================== */

void PLC_Mitsu_Task_Run(void) {
    uint32_t now = HAL_GetTick();

    switch (plc_fsm_state) {
        case PLC_STATE_SEND_WRITE: {
            // Chuẩn bị dữ liệu Master + Slaves để ghi lên PLC
            // D900..D905: Master ToF
            // D910..D915: Slave 1
            // D920..D925: Slave 2 ...
            uint16_t total_points = 6 + MAX_SLAVE_NODES * 6;
            uint16_t d_data[6 + MAX_SLAVE_NODES * 6];
            memset(d_data, 0, sizeof(d_data));

            // Master data (D900..D905)
            d_data[0] = g_vl53_app.d_distance_filtered;
            d_data[1] = g_vl53_app.d_distance_raw;
            d_data[2] = g_vl53_app.d_status;
            d_data[3] = g_vl53_app.d_error;
            d_data[4] = g_can_stats.online_slaves_cnt;
            d_data[5] = g_vl53_app.d_heartbeat;

            // Slaves data (D910..D9xx)
            for (uint8_t i = 0; i < MAX_SLAVE_NODES; i++) {
                uint16_t base = 6 + i * 6;
                d_data[base + 0] = g_slave_nodes[i].d_distance_filtered;
                d_data[base + 1] = g_slave_nodes[i].d_distance_raw;
                d_data[base + 2] = g_slave_nodes[i].d_status;
                d_data[base + 3] = g_slave_nodes[i].d_error;
                d_data[base + 4] = (uint16_t)g_slave_nodes[i].d_calib_offset;
                d_data[base + 5] = (uint16_t)g_slave_nodes[i].d_heartbeat;
            }

            uint16_t tx_len = Build_Batch_Write_Packet(tx_buf, PLC_D_BASE_MASTER, d_data, total_points);

            // Xóa bộ đệm nhận trước khi gửi
            rx_head = 0;
            rx_tail = 0;

            HAL_UART_Transmit_DMA(&huart1, tx_buf, tx_len);
            g_plc_stats.tx_write_count++;
            state_timer = now;
            plc_fsm_state = PLC_STATE_WAIT_WRITE_RESP;
            break;
        }

        case PLC_STATE_WAIT_WRITE_RESP: {
            uint8_t payload[128];
            uint16_t p_len = 0;
            uint16_t end_code = 0xFFFF;

            if (Parse_PLC_Response(payload, &p_len, &end_code)) {
                g_plc_stats.last_plc_end_code = end_code;
                if (end_code == 0x0000) {
                    g_plc_stats.rx_resp_count++;
                    g_plc_stats.plc_connected = true;
                    g_plc_stats.last_success_time = now;
                }
                plc_fsm_state = PLC_STATE_SEND_READ;
            } else if (now - state_timer > 60) {
                // Timeout phản hồi ghi
                g_plc_stats.comm_error_count++;
                if (now - g_plc_stats.last_success_time > 2000) {
                    g_plc_stats.plc_connected = false;
                }
                plc_fsm_state = PLC_STATE_SEND_READ;
            }
            break;
        }

        case PLC_STATE_SEND_READ: {
            // Đọc thanh ghi lệnh D950..D952 từ PLC
            uint16_t tx_len = Build_Batch_Read_Packet(tx_buf, PLC_D_READ_CMD_ADDR, PLC_D_READ_CMD_POINTS);
            rx_head = 0;
            rx_tail = 0;

            HAL_UART_Transmit_DMA(&huart1, tx_buf, tx_len);
            state_timer = now;
            plc_fsm_state = PLC_STATE_WAIT_READ_RESP;
            break;
        }

        case PLC_STATE_WAIT_READ_RESP: {
            uint8_t payload[128];
            uint16_t p_len = 0;
            uint16_t end_code = 0xFFFF;

            if (Parse_PLC_Response(payload, &p_len, &end_code)) {
                g_plc_stats.last_plc_end_code = end_code;
                if (end_code == 0x0000 && p_len >= 20) {
                    g_plc_stats.rx_resp_count++;
                    g_plc_stats.plc_connected = true;
                    g_plc_stats.last_success_time = now;

                    // Payload D950, D951, D952 nằm từ byte 14
                    uint16_t target_node = (uint16_t)payload[14] | ((uint16_t)payload[15] << 8);
                    uint16_t target_dist = (uint16_t)payload[16] | ((uint16_t)payload[17] << 8);
                    uint16_t calib_cmd   = (uint16_t)payload[18] | ((uint16_t)payload[19] << 8);

                    if (calib_cmd > 0) {
                        if (target_node == 0) {
                            // Lệnh Calib cho chính Master
                            VL53L_SetPendingCalib((uint8_t)calib_cmd, target_dist);
                        } else {
                            // Phân phối lệnh Calib cho Slave tương ứng qua mạng CAN
                            CAN_Master_Send_Command((uint8_t)target_node, (uint8_t)calib_cmd, target_dist);
                        }

                        // Chuẩn bị gửi lệnh xóa D952 = 0
                        pending_clear_d952 = 0;
                        plc_fsm_state = PLC_STATE_SEND_CLEAR_CMD;
                        break;
                    }
                }
                plc_fsm_state = PLC_STATE_IDLE_DELAY;
                state_timer = now;
            } else if (now - state_timer > 60) {
                // Timeout đọc
                g_plc_stats.comm_error_count++;
                if (now - g_plc_stats.last_success_time > 2000) {
                    g_plc_stats.plc_connected = false;
                }
                plc_fsm_state = PLC_STATE_IDLE_DELAY;
                state_timer = now;
            }
            break;
        }

        case PLC_STATE_SEND_CLEAR_CMD: {
            // Xóa thanh ghi D952 = 0 sau khi nhận lệnh
            uint16_t zero_val = 0;
            uint16_t tx_len = Build_Batch_Write_Packet(tx_buf, PLC_D_READ_CMD_ADDR + 2, &zero_val, 1);
            rx_head = 0;
            rx_tail = 0;

            HAL_UART_Transmit_DMA(&huart1, tx_buf, tx_len);
            state_timer = now;
            plc_fsm_state = PLC_STATE_WAIT_CLEAR_RESP;
            break;
        }

        case PLC_STATE_WAIT_CLEAR_RESP: {
            uint8_t payload[128];
            uint16_t p_len = 0;
            uint16_t end_code = 0xFFFF;
            if (Parse_PLC_Response(payload, &p_len, &end_code) || (now - state_timer > 60)) {
                plc_fsm_state = PLC_STATE_IDLE_DELAY;
                state_timer = now;
            }
            break;
        }

        case PLC_STATE_IDLE_DELAY: {
            if (now - state_timer >= 30) {
                plc_fsm_state = PLC_STATE_SEND_WRITE;
            }
            break;
        }
    }
}
