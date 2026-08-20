/**
 * @file VL53L.c
 * @brief ĐÓNG GÓI TRUYỀN THÔNG 2 CHIỀU: GHI D900..D905 & ĐỌC D910/M910 TỪ PLC Q-SERIES
 */

#include "VL53L.h"
#include "VL53L1X_api.h"
#include "VL53L1X_calibration.h"
#include "vl53l1_platform.h"
#include "usart.h"
#include "i2c.h"
#include "gpio.h"
#include "cmsis_os.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* ==============================================================================
 *                       CẤU HÌNH FLASH LƯU CALIB VĨNH VIỄN
 * ============================================================================== */
#define CALIB_FLASH_MAGIC_KEY       0x55AA1234
#define CALIB_FLASH_SECTOR          FLASH_SECTOR_5
#define CALIB_FLASH_ADDR            0x08020000

typedef struct {
    uint32_t magic_key;
    uint16_t calib_target;
    int16_t  calib_offset;
    uint32_t checksum;
} Calib_Flash_Data_t;

/* ==============================================================================
 *                       BIẾN TOÀN CỤC & BỘ ĐỆM
 * ============================================================================== */
VL53L_AppData_t g_vl53_app = {
    .d_distance_filtered = 2002,
    .d_distance_raw = 2002,
    .d_status = 1,
    .d_error = 0,
    .d_scan_time_ms = 50,
    .d_heartbeat = 0,
    .d_calib_target = 0,
    .d_calib_cmd_flag = 0,
    .d_calib_offset = 0,
    .calib_done = false,
    .plc_last_end_code = 0xFFFF,
    .plc_last_p_len = 0,
    .last_payload = {0},
    .sensor_ok = false,
    .raw_range_status = 0,
    .comm_success_count = 0,
    .read_success_count = 0,
    .total_rx_bytes = 0
};

static uint8_t  tx_dma_buf[128];
static uint8_t  rx_raw_byte = 0;
static uint8_t  rx_ring[256];
static volatile uint16_t rx_head = 0;
static volatile bool vl53_int_flag = false;

typedef enum {
    PLC_STATE_SEND_WRITE = 0,
    PLC_STATE_WAIT_WRITE_RESP,
    PLC_STATE_IDLE_BEFORE_READ,
    PLC_STATE_SEND_READ,
    PLC_STATE_WAIT_READ_RESP,
    PLC_STATE_IDLE_BEFORE_WRITE
} PLC_CommState_t;

static PLC_CommState_t plc_state = PLC_STATE_SEND_WRITE;
static uint32_t resp_timer = 0;
static uint32_t state_delay_timer = 0;
static volatile bool resp_received = false;
static volatile bool need_write_d911_zero = false;
static volatile uint16_t pending_calib_cmd = 0;

/* ==============================================================================
 *                       ĐỌC & GHI FLASH STM32
 * ============================================================================== */

static void Calib_Load_From_Flash(void) {
    const Calib_Flash_Data_t *flash_ptr = (const Calib_Flash_Data_t*)CALIB_FLASH_ADDR;

    if (flash_ptr->magic_key == CALIB_FLASH_MAGIC_KEY) {
        uint32_t check = flash_ptr->magic_key + flash_ptr->calib_target + (uint16_t)flash_ptr->calib_offset;
        if (check == flash_ptr->checksum) {
            g_vl53_app.d_calib_target = flash_ptr->calib_target;
            g_vl53_app.d_calib_offset = flash_ptr->calib_offset;
            g_vl53_app.calib_done = true;
        }
    }
}

static bool Calib_Save_To_Flash(void) {
    Calib_Flash_Data_t save_data;
    save_data.magic_key    = CALIB_FLASH_MAGIC_KEY;
    save_data.calib_target = g_vl53_app.d_calib_target;
    save_data.calib_offset = g_vl53_app.d_calib_offset;
    save_data.checksum     = save_data.magic_key + save_data.calib_target + (uint16_t)save_data.calib_offset;

    HAL_FLASH_Unlock();

    FLASH_EraseInitTypeDef EraseInitStruct;
    EraseInitStruct.TypeErase    = FLASH_TYPEERASE_SECTORS;
    EraseInitStruct.VoltageRange = FLASH_VOLTAGE_RANGE_3;
    EraseInitStruct.Sector       = CALIB_FLASH_SECTOR;
    EraseInitStruct.NbSectors    = 1;

    uint32_t SectorError = 0;
    if (HAL_FLASHEx_Erase(&EraseInitStruct, &SectorError) != HAL_OK) {
        HAL_FLASH_Lock();
        return false;
    }

    uint32_t *src = (uint32_t*)&save_data;
    uint32_t addr = CALIB_FLASH_ADDR;
    for (uint32_t i = 0; i < sizeof(Calib_Flash_Data_t) / 4; i++) {
        if (HAL_FLASH_Program(FLASH_TYPEPROGRAM_WORD, addr, src[i]) != HAL_OK) {
            HAL_FLASH_Lock();
            return false;
        }
        addr += 4;
    }

    HAL_FLASH_Lock();
    return true;
}

/* ==============================================================================
 *                       XỬ LÝ GÓI PHẢN HỒI TỪ PLC QJ71
 * ============================================================================== */

void VL53L_Process_PLC_Response(const uint8_t *buf, uint16_t len) {
    if (len < 6) return;

    int16_t stx_pos = -1;
    for (uint16_t i = 0; i < len - 1; i++) {
        if (buf[i] == 0x10 && buf[i + 1] == 0x02) {
            stx_pos = i;
            break;
        }
    }
    if (stx_pos < 0) return;

    uint8_t payload[64];
    uint16_t p_len = 0;
    for (uint16_t i = stx_pos + 2; i < len; i++) {
        if (buf[i] == 0x10) {
            if (i + 1 < len && buf[i + 1] == 0x03) {
                break;
            } else if (i + 1 < len && buf[i + 1] == 0x10) {
                payload[p_len++] = 0x10;
                i++;
                continue;
            }
        }
        payload[p_len++] = buf[i];
    }

    if (p_len < 4) return;

    // Bỏ qua TX Echo (Khi byte 10..11 là mã lệnh Request 0x0401 hoặc 0x1401)
    if (p_len >= 12 && payload[10] == 0x01 && (payload[11] == 0x04 || payload[11] == 0x14)) {
        return; // Bỏ qua gói phát lặp TX Echo của chính STM32
    }

    memset(g_vl53_app.last_payload, 0, sizeof(g_vl53_app.last_payload));
    for (uint8_t i = 0; i < p_len && i < 24; i++) {
        g_vl53_app.last_payload[i] = payload[i];
    }
    g_vl53_app.plc_last_p_len = (uint8_t)p_len;

    // Gói phản hồi chuẩn Q-Series Type 5 / 3E Frame
    if (p_len >= 12) {
        uint16_t end_code = 0xFFFF;
        if (payload[8] == 0x00 && payload[9] == 0x00) {
            end_code = 0x0000;
        } else if (payload[10] == 0x00 && payload[11] == 0x00) {
            end_code = 0x0000;
        } else {
            end_code = payload[10] | (payload[11] << 8);
        }
        
        g_vl53_app.plc_last_end_code = end_code;
        resp_received = true;

        // Gói phản hồi Batch Read: D910 tại byte 14-15, D911 tại byte 16-17
        if (p_len >= 18) {
            uint16_t plc_d910 = payload[14] | (payload[15] << 8); // D910 (Target mm: Byte 14-15)
            uint16_t plc_d911 = payload[16] | (payload[17] << 8); // D911 (Lệnh Calib: Byte 16-17)

            g_vl53_app.d_calib_target = plc_d910;
            g_vl53_app.d_calib_cmd_flag = plc_d911;
            g_vl53_app.read_success_count++;

            // Khi nhận được lệnh Calib hợp lệ từ PLC (10, 20, 30 hoặc 1)
            if ((plc_d911 == 10 || plc_d911 == 1 || plc_d911 == 20 || plc_d911 == 30) && pending_calib_cmd == 0) {
                pending_calib_cmd = plc_d911;
                g_vl53_app.active_calib_mode = plc_d911;
                g_vl53_app.calib_display_hold_until = HAL_GetTick() + 4000; // Giữ màn hình Calib 4 giây
            }
        }
        else if (p_len >= 16) {
            uint16_t plc_d910 = payload[14] | (payload[15] << 8);
            uint16_t plc_d911 = payload[12] | (payload[13] << 8);

            g_vl53_app.d_calib_target = plc_d910;
            g_vl53_app.d_calib_cmd_flag = plc_d911;
            g_vl53_app.read_success_count++;

            if ((plc_d911 == 10 || plc_d911 == 1 || plc_d911 == 20 || plc_d911 == 30) && pending_calib_cmd == 0) {
                pending_calib_cmd = plc_d911;
                g_vl53_app.active_calib_mode = plc_d911;
                g_vl53_app.calib_display_hold_until = HAL_GetTick() + 4000;
            }
        }
    }
    // Gói phản hồi định dạng ngắn không kèm Routing Header
    else if (p_len >= 4) {
        uint16_t end_code = payload[2] | (payload[3] << 8);
        g_vl53_app.plc_last_end_code = end_code;
        resp_received = true;

        if (end_code == 0x0000 && p_len >= 8) {
            uint16_t plc_d910 = payload[4] | (payload[5] << 8);
            uint16_t plc_d911 = payload[6] | (payload[7] << 8);

            g_vl53_app.d_calib_target = plc_d910;
            g_vl53_app.d_calib_cmd_flag = plc_d911;
            g_vl53_app.read_success_count++;

            if ((plc_d911 == 10 || plc_d911 == 1 || plc_d911 == 20 || plc_d911 == 30) && pending_calib_cmd == 0) {
                pending_calib_cmd = plc_d911;
                g_vl53_app.active_calib_mode = plc_d911;
                g_vl53_app.calib_display_hold_until = HAL_GetTick() + 4000;
            }
        }
    }
}

/* ==============================================================================
 *                       CALLBACK NGẮT PHẦN CỨNG
 * ============================================================================== */

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) {
    if (GPIO_Pin == VL53L_SENSOR_INT_PIN) {
        vl53_int_flag = true;
    }
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) {
    if (huart->Instance == VL53L_PLC_UART_HANDLE.Instance) {
        g_vl53_app.total_rx_bytes++;

        if (rx_head < sizeof(rx_ring) - 1) {
            rx_ring[rx_head++] = rx_raw_byte;
        }

        // Quét gói tin khi nhận được DLE ETX (10 03 XX XX)
        if (rx_head >= 4) {
            for (uint16_t i = 0; i < rx_head - 3; i++) {
                if (rx_ring[i] == 0x10 && rx_ring[i + 1] == 0x03) {
                    VL53L_Process_PLC_Response(rx_ring, i + 4);
                    rx_head = 0;
                    g_vl53_app.comm_success_count++;
                    break;
                }
            }
        }

        if (rx_head >= sizeof(rx_ring) - 10) {
            rx_head = 0;
        }

        HAL_UART_Receive_IT(&VL53L_PLC_UART_HANDLE, &rx_raw_byte, 1);
    }
}

void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart) {
    if (huart->Instance == VL53L_PLC_UART_HANDLE.Instance) {
        // DMA TX completed
    }
}

/* ==============================================================================
 *   BỘ LỌC THÍCH NGHI ADAPTIVE CONSENSUS: ĐỨNG YÊN SỐ & BÁM CHUẨN TỪNG 1 MM
 * ============================================================================== */

#define FILTER_WINDOW_SIZE      9

static uint16_t Filter_TrimmedMovingAverage(uint16_t raw_mm) {
    static uint16_t window[FILTER_WINDOW_SIZE] = {0};
    static uint8_t  head = 0;
    static uint8_t  count = 0;
    static float    smoothed_dist = 0.0f;
    static uint16_t stable_output = 0;
    static int8_t   drift_count = 0;

    if (raw_mm < 30 || raw_mm > 4000) {
        return stable_output ? stable_output : raw_mm;
    }

    window[head] = raw_mm;
    head = (head + 1) % FILTER_WINDOW_SIZE;
    if (count < FILTER_WINDOW_SIZE) count++;

    if (count < 3) {
        smoothed_dist = (float)raw_mm;
        stable_output = raw_mm;
        return raw_mm;
    }

    // 1. Trimmed Mean: Loại bỏ 1 đỉnh cao nhất và 1 đáy thấp nhất
    uint16_t sorted[FILTER_WINDOW_SIZE];
    for (uint8_t i = 0; i < count; i++) sorted[i] = window[i];
    for (uint8_t i = 0; i < count - 1; i++) {
        for (uint8_t j = 0; j < count - 1 - i; j++) {
            if (sorted[j] > sorted[j + 1]) {
                uint16_t tmp = sorted[j];
                sorted[j] = sorted[j + 1];
                sorted[j + 1] = tmp;
            }
        }
    }

    uint32_t sum = 0;
    uint8_t valid_cnt = 0;
    for (uint8_t i = 1; i < count - 1; i++) {
        sum += sorted[i];
        valid_cnt++;
    }
    float current_avg = (float)sum / (float)valid_cnt;

    // 2. Bộ lọc thích nghi Adaptive Low-Pass:
    float diff = current_avg - smoothed_dist;
    float abs_diff = (diff < 0.0f) ? -diff : diff;

    float alpha;
    if (abs_diff > 12.0f) {
        alpha = 0.85f; // Chuyển động nhanh: Bám tức thì
    } else if (abs_diff > 4.0f) {
        alpha = 0.45f; // Chuyển động vừa
    } else {
        alpha = 0.18f; // Chuyển động chậm / đứng yên: Lọc mịn tối đa
    }

    smoothed_dist = smoothed_dist + alpha * (current_avg - smoothed_dist);

    // 3. Cơ chế đồng thuận xu hướng (Trend Consensus): 
    //    Đứng yên số tuyệt đối khi đứng yên, nhưng khi dịch chuyển dù chỉ 1mm vẫn nhảy đúng 1mm mượt mà
    uint16_t target_int = (uint16_t)(smoothed_dist + 0.5f);

    if (stable_output == 0) {
        stable_output = target_int;
    } else {
        if (target_int > stable_output) {
            drift_count++;
            if (drift_count >= 3 || abs_diff >= 2.5f) {
                stable_output++;
                drift_count = 0;
            }
        } else if (target_int < stable_output) {
            drift_count--;
            if (drift_count <= -3 || abs_diff >= 2.5f) {
                stable_output--;
                drift_count = 0;
            }
        } else {
            drift_count = 0; // Đứng yên tuyệt đối
        }
    }

    return stable_output;
}

/* ==============================================================================
 *                       XÂY DỰNG GÓI LỆNH MITSUBISHI TYPE 5
 * ============================================================================== */

// Gói Ghi D900..D905 (Batch Write 0x1401 - Chuẩn 30 bytes)
static uint16_t Build_Batch_Write_D900(uint8_t *out_buf, const uint16_t *data_6words) {
    uint8_t payload[48];
    uint16_t p_len = 0;
    
    payload[p_len++] = 0x1E; payload[p_len++] = 0x00; // Length: 30 bytes (0x001E)
    payload[p_len++] = 0xF8; payload[p_len++] = 0x00; payload[p_len++] = 0x00;
    payload[p_len++] = 0xFF; payload[p_len++] = 0xFF; payload[p_len++] = 0x03;
    payload[p_len++] = 0x00; payload[p_len++] = 0x00; // Routing: 8 bytes
    payload[p_len++] = 0x01; payload[p_len++] = 0x14; // Command 0x1401 (Batch Write)
    payload[p_len++] = 0x00; payload[p_len++] = 0x00; // Subcommand: 0000
    payload[p_len++] = (uint8_t)(VL53L_PLC_D_START_ADDR & 0xFF);
    payload[p_len++] = (uint8_t)((VL53L_PLC_D_START_ADDR >> 8) & 0xFF);
    payload[p_len++] = 0x00; // Head D900 (3 bytes)
    payload[p_len++] = 0xA8; // Device Code D
    payload[p_len++] = (uint8_t)(VL53L_PLC_D_TOTAL_POINTS & 0xFF);
    payload[p_len++] = (uint8_t)((VL53L_PLC_D_TOTAL_POINTS >> 8) & 0xFF); // 6 Points
    
    for (uint8_t i = 0; i < VL53L_PLC_D_TOTAL_POINTS; i++) {
        payload[p_len++] = (uint8_t)(data_6words[i] & 0xFF);
        payload[p_len++] = (uint8_t)((data_6words[i] >> 8) & 0xFF);
    }
    
    uint16_t sum = 0;
    for (uint16_t i = 0; i < p_len; i++) sum += payload[i];
    
    uint16_t tx_idx = 0;
    out_buf[tx_idx++] = 0x10; out_buf[tx_idx++] = 0x02; // DLE STX
    for (uint16_t i = 0; i < p_len; i++) {
        out_buf[tx_idx++] = payload[i];
        if (payload[i] == 0x10) out_buf[tx_idx++] = 0x10;
    }
    out_buf[tx_idx++] = 0x10; out_buf[tx_idx++] = 0x03; // DLE ETX
    snprintf((char*)&out_buf[tx_idx], 3, "%02X", (uint8_t)(sum & 0xFF));
    tx_idx += 2;
    return tx_idx;
}

// Gói Đọc D910..D911 (Batch Read 0x0401 - Chuẩn 18 bytes)
static uint16_t Build_Batch_Read_D910(uint8_t *out_buf) {
    uint8_t payload[24];
    uint16_t p_len = 0;
    
    payload[p_len++] = 0x12; payload[p_len++] = 0x00; // Length: 18 bytes (0x0012)
    payload[p_len++] = 0xF8; payload[p_len++] = 0x00; payload[p_len++] = 0x00;
    payload[p_len++] = 0xFF; payload[p_len++] = 0xFF; payload[p_len++] = 0x03;
    payload[p_len++] = 0x00; payload[p_len++] = 0x00; // Routing Header: 8 bytes
    payload[p_len++] = 0x01; payload[p_len++] = 0x04; // Command 0x0401 (Batch Read)
    payload[p_len++] = 0x00; payload[p_len++] = 0x00; // Subcommand: 0000
    payload[p_len++] = (uint8_t)(VL53L_PLC_READ_D_ADDR & 0xFF);         // 0x8E
    payload[p_len++] = (uint8_t)((VL53L_PLC_READ_D_ADDR >> 8) & 0xFF);  // 0x03
    payload[p_len++] = 0x00;                                            // 0x00 -> D910
    payload[p_len++] = 0xA8;                                            // Code D
    payload[p_len++] = (uint8_t)(VL53L_PLC_READ_D_POINTS & 0xFF);        // 0x02
    payload[p_len++] = (uint8_t)((VL53L_PLC_READ_D_POINTS >> 8) & 0xFF); // 0x00 -> 2 Points
    
    uint16_t sum = 0;
    for (uint16_t i = 0; i < p_len; i++) sum += payload[i];
    
    uint16_t tx_idx = 0;
    out_buf[tx_idx++] = 0x10; out_buf[tx_idx++] = 0x02;
    for (uint16_t i = 0; i < p_len; i++) {
        out_buf[tx_idx++] = payload[i];
        if (payload[i] == 0x10) out_buf[tx_idx++] = 0x10;
    }
    out_buf[tx_idx++] = 0x10; out_buf[tx_idx++] = 0x03;
    snprintf((char*)&out_buf[tx_idx], 3, "%02X", (uint8_t)(sum & 0xFF));
    tx_idx += 2;
    return tx_idx;
}

// Gói Ghi D911 = 0 về PLC (Khi hoàn tất hiệu chuẩn Calib)
static uint16_t Build_Write_D911_Zero(uint8_t *out_buf) {
    uint8_t payload[24];
    uint16_t p_len = 0;
    
    payload[p_len++] = 0x14; payload[p_len++] = 0x00; // Length: 20 bytes (0x0014)
    payload[p_len++] = 0xF8; payload[p_len++] = 0x00; payload[p_len++] = 0x00;
    payload[p_len++] = 0xFF; payload[p_len++] = 0xFF; payload[p_len++] = 0x03;
    payload[p_len++] = 0x00; payload[p_len++] = 0x00; // Routing Header: 8 bytes
    payload[p_len++] = 0x01; payload[p_len++] = 0x14; // Command 0x1401 (Batch Write)
    payload[p_len++] = 0x00; payload[p_len++] = 0x00; // Subcommand: 0000
    payload[p_len++] = (uint8_t)(911 & 0xFF);         // 0x8F (911 = 0x038F)
    payload[p_len++] = (uint8_t)((911 >> 8) & 0xFF);  // 0x03
    payload[p_len++] = 0x00;                          // 0x00 -> D911
    payload[p_len++] = 0xA8;                          // Code D
    payload[p_len++] = 0x01; payload[p_len++] = 0x00; // 1 Point
    payload[p_len++] = 0x00; payload[p_len++] = 0x00; // Data = 0
    
    uint16_t sum = 0;
    for (uint16_t i = 0; i < p_len; i++) sum += payload[i];
    
    uint16_t tx_idx = 0;
    out_buf[tx_idx++] = 0x10; out_buf[tx_idx++] = 0x02;
    for (uint16_t i = 0; i < p_len; i++) {
        out_buf[tx_idx++] = payload[i];
        if (payload[i] == 0x10) out_buf[tx_idx++] = 0x10;
    }
    out_buf[tx_idx++] = 0x10; out_buf[tx_idx++] = 0x03;
    snprintf((char*)&out_buf[tx_idx], 3, "%02X", (uint8_t)(sum & 0xFF));
    tx_idx += 2;
    return tx_idx;
}

/* ==============================================================================
 *                       KHỞI TẠO CẢM BIẾN
 * ============================================================================== */

static bool Try_Init_Sensor(void) {
    if (HAL_I2C_IsDeviceReady(&VL53L_SENSOR_I2C_HANDLE, VL53L_I2C_ADDR, 3, 10) != HAL_OK) {
        g_vl53_app.d_error = 30;
        return false;
    }

    uint8_t boot_state = 0;
    for (int i = 0; i < 10; i++) {
        VL53L1X_BootState(VL53L_I2C_ADDR, &boot_state);
        if (boot_state != 0) break;
        osDelay(10);
    }

    if (boot_state == 0) {
        g_vl53_app.d_error = 10;
        return false;
    }

    if (VL53L1X_SensorInit(VL53L_I2C_ADDR) != VL53L1_ERROR_NONE) {
        g_vl53_app.d_error = 20;
        return false;
    }

    uint16_t sensor_id = 0;
    VL53L1X_GetSensorId(VL53L_I2C_ADDR, &sensor_id);
    VL53L1X_SetDistanceMode(VL53L_I2C_ADDR, VL53L1X_DISTANCE_MODE_LONG);
    VL53L1X_SetTimingBudgetInMs(VL53L_I2C_ADDR, 50);
    VL53L1X_SetInterMeasurementInMs(VL53L_I2C_ADDR, 55);
    VL53L1X_StartRanging(VL53L_I2C_ADDR);

    g_vl53_app.sensor_ok = true;
    g_vl53_app.d_error = 0;
    return true;
}

void VL53L_Init(void) {
    Calib_Load_From_Flash();
    Try_Init_Sensor();
    HAL_UART_Receive_IT(&VL53L_PLC_UART_HANDLE, &rx_raw_byte, 1);
}

/* ==============================================================================
 *                       TÁC VỤ THỰC THI CHÍNH
 * ============================================================================== */

void VL53L_Task_Sensor(void) {
    if (g_vl53_app.sensor_ok) {
        uint8_t isDataReady = 0;
        if (vl53_int_flag) {
            vl53_int_flag = false;
            isDataReady = 1;
        } else {
            VL53L1X_CheckForDataReady(VL53L_I2C_ADDR, &isDataReady);
        }

        if (isDataReady) {
            uint16_t dist = 0;
            uint8_t status = 0;
            VL53L1X_GetRangeStatus(VL53L_I2C_ADDR, &status);
            VL53L1X_GetDistance(VL53L_I2C_ADDR, &dist);
            VL53L1X_ClearInterrupt(VL53L_I2C_ADDR);

            g_vl53_app.d_distance_raw = dist;
            g_vl53_app.raw_range_status = status;
            g_vl53_app.d_error = status;

            if (status == 0) {
                uint16_t raw_filtered = Filter_TrimmedMovingAverage(dist);
                
                int32_t calibrated_dist = (int32_t)raw_filtered + (int32_t)g_vl53_app.d_calib_offset;
                if (calibrated_dist < 0) calibrated_dist = 0;
                g_vl53_app.d_distance_filtered = (uint16_t)calibrated_dist;
            }
        }
    } else {
        static uint32_t last_scan = 0;
        if (HAL_GetTick() - last_scan >= 1000) {
            last_scan = HAL_GetTick();
            Try_Init_Sensor();
        }
        g_vl53_app.d_distance_raw = 2002;
        g_vl53_app.d_distance_filtered = 2002;
    }

    // Xử lý các chế độ Calib an toàn trong Task context (không chặn ISR):
    if (pending_calib_cmd > 0) {
        uint16_t cmd = pending_calib_cmd;
        pending_calib_cmd = 0;

        // MODE 10 (hoặc 1): Calib Offset phần mềm (Software Offset)
        if ((cmd == 10 || cmd == 1) && g_vl53_app.d_distance_raw > 0) {
            uint16_t target = (g_vl53_app.d_calib_target > 0) ? g_vl53_app.d_calib_target : g_vl53_app.d_distance_raw;
            int32_t offset = (int32_t)target - (int32_t)g_vl53_app.d_distance_raw;
            g_vl53_app.d_calib_offset = (int16_t)offset;
            g_vl53_app.calib_done = true;
            Calib_Save_To_Flash();
            need_write_d911_zero = true; // Gửi xóa D911 = 0 về PLC
        }
        // MODE 20: Calib Offset phần cứng (Hardware ST API)
        else if (cmd == 20) {
            uint16_t target = (g_vl53_app.d_calib_target > 0) ? g_vl53_app.d_calib_target : 140;
            int16_t hw_offset = 0;
            VL53L1X_CalibrateOffset(VL53L_I2C_ADDR, target, &hw_offset);
            g_vl53_app.d_calib_offset = hw_offset;
            g_vl53_app.calib_done = true;
            Calib_Save_To_Flash();
            VL53L1X_StartRanging(VL53L_I2C_ADDR);
            need_write_d911_zero = true;
        }
        // MODE 30: Calib Crosstalk (Xtalk khi có kính/mica bảo vệ)
        else if (cmd == 30) {
            uint16_t target = (g_vl53_app.d_calib_target > 0) ? g_vl53_app.d_calib_target : 500;
            uint16_t xtalk_val = 0;
            VL53L1X_CalibrateXtalk(VL53L_I2C_ADDR, target, &xtalk_val);
            g_vl53_app.calib_done = true;
            VL53L1X_StartRanging(VL53L_I2C_ADDR);
            need_write_d911_zero = true;
        }
    }

    uint16_t status_word = 0;
    if (g_vl53_app.sensor_ok) status_word |= (1 << 0);
    if (g_vl53_app.d_distance_filtered > 0 && g_vl53_app.d_distance_filtered < 200) status_word |= (1 << 1);
    if (g_vl53_app.d_distance_filtered >= 30 && g_vl53_app.d_distance_filtered <= 3000) status_word |= (1 << 2);
    if (g_vl53_app.calib_done) status_word |= (1 << 3);
    g_vl53_app.d_status = status_word;
}

void VL53L_Task_PLC(void) {
    uint32_t now = HAL_GetTick();

    switch (plc_state) {
        case PLC_STATE_SEND_WRITE: {
            HAL_GPIO_TogglePin(led_GPIO_Port, led_Pin);
            g_vl53_app.d_heartbeat++;

            uint16_t tx_len = 0;
            if (need_write_d911_zero) {
                need_write_d911_zero = false;
                tx_len = Build_Write_D911_Zero(tx_dma_buf);
            } else {
                uint16_t d_table[VL53L_PLC_D_TOTAL_POINTS] = {
                    g_vl53_app.d_distance_filtered, // D900
                    g_vl53_app.d_distance_raw,      // D901
                    g_vl53_app.d_status,            // D902
                    g_vl53_app.d_error,             // D903
                    g_vl53_app.d_scan_time_ms,      // D904
                    g_vl53_app.d_heartbeat          // D905
                };
                tx_len = Build_Batch_Write_D900(tx_dma_buf, d_table);
            }

            if (VL53L_PLC_UART_HANDLE.gState == HAL_UART_STATE_READY && tx_len > 0) {
                rx_head = 0;
                resp_received = false;
                resp_timer = now;
                HAL_UART_Transmit_DMA(&VL53L_PLC_UART_HANDLE, tx_dma_buf, tx_len);
                plc_state = PLC_STATE_WAIT_WRITE_RESP;
            }
            break;
        }

        case PLC_STATE_WAIT_WRITE_RESP:
            // Chờ nhận phản hồi từ PLC hoặc Timeout 300ms
            if (resp_received || (now - resp_timer >= 300)) {
                state_delay_timer = now;
                plc_state = PLC_STATE_IDLE_BEFORE_READ;
            }
            break;

        case PLC_STATE_IDLE_BEFORE_READ:
            // Khoảng nghỉ Inter-frame 100ms để QJ71 hoàn tất giải phóng bộ đệm và đường truyền RS485
            if (now - state_delay_timer >= 100) {
                plc_state = PLC_STATE_SEND_READ;
            }
            break;

        case PLC_STATE_SEND_READ: {
            uint16_t tx_len = Build_Batch_Read_D910(tx_dma_buf);
            if (VL53L_PLC_UART_HANDLE.gState == HAL_UART_STATE_READY && tx_len > 0) {
                rx_head = 0;
                resp_received = false;
                resp_timer = now;
                HAL_UART_Transmit_DMA(&VL53L_PLC_UART_HANDLE, tx_dma_buf, tx_len);
                plc_state = PLC_STATE_WAIT_READ_RESP;
            }
            break;
        }

        case PLC_STATE_WAIT_READ_RESP:
            // Chờ nhận phản hồi từ PLC hoặc Timeout 300ms
            if (resp_received || (now - resp_timer >= 300)) {
                state_delay_timer = now;
                plc_state = PLC_STATE_IDLE_BEFORE_WRITE;
            }
            break;

        case PLC_STATE_IDLE_BEFORE_WRITE:
            // Khoảng nghỉ Inter-frame 100ms trước khi bắt đầu chu kỳ gửi ghi tiếp theo
            if (now - state_delay_timer >= 100) {
                plc_state = PLC_STATE_SEND_WRITE;
            }
            break;

        default:
            plc_state = PLC_STATE_SEND_WRITE;
            break;
    }
}
