/**
 * @file VL53L.c
 * @brief ĐÓNG GÓI 1 FILE DUY NHẤT: CẢM BIẾN VL53L1X <-> PLC MITSUBISHI Q-SERIES (LƯU FLASH VĨNH VIỄN)
 */

#include "VL53L.h"
#include "VL53L1X_api.h"
#include "vl53l1_platform.h"
#include "usart.h"
#include "i2c.h"
#include "gpio.h"
#include "cmsis_os.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* ==============================================================================
 *                       CẤU HÌNH BỘ NHỚ FLASH LƯU CALIB VĨNH VIỄN
 * ============================================================================== */
#define CALIB_FLASH_MAGIC_KEY       0x55AA1234
#define CALIB_FLASH_SECTOR          FLASH_SECTOR_5
#define CALIB_FLASH_ADDR            0x08020000  // Địa chỉ đầu Sector 5 trong STM32F401 Flash

typedef struct {
    uint32_t magic_key;     // Khóa nhận diện dữ liệu hợp lệ
    uint16_t calib_target;  // D910: Khoảng cách chuẩn đã đặt
    int16_t  calib_offset;  // Độ lệch bù trừ lưu vĩnh viễn
    uint32_t checksum;      // Kiểm tra toàn vẹn
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
    .d_calib_target = 500,  // Mặc định D910 = 500 mm
    .d_calib_offset = 0,
    .m_calib_trigger = false,
    .calib_done = false,
    .sensor_ok = false,
    .raw_range_status = 0,
    .comm_success_count = 0
};

static uint8_t  tx_dma_buf[128];
static uint8_t  rx_raw_byte = 0;
static uint8_t  rx_ring[128];
static volatile uint16_t rx_head = 0;
static volatile bool vl53_int_flag = false;

/* ==============================================================================
 *                       ĐỌC & GHI BỘ NHỚ FLASH STM32
 * ============================================================================== */

static void Calib_Load_From_Flash(void) {
    const Calib_Flash_Data_t *flash_ptr = (const Calib_Flash_Data_t*)CALIB_FLASH_ADDR;

    if (flash_ptr->magic_key == CALIB_FLASH_MAGIC_KEY) {
        uint32_t check = flash_ptr->magic_key + flash_ptr->calib_target + (uint16_t)flash_ptr->calib_offset;
        if (check == flash_ptr->checksum) {
            g_vl53_app.d_calib_target = flash_ptr->calib_target;
            g_vl53_app.d_calib_offset = flash_ptr->calib_offset;
            g_vl53_app.calib_done = true; // Đã khôi phục dữ liệu Calib từ Flash thành công!
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

    // Xóa Sector 5 Flash
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

    // Ghi dữ liệu vào Flash (Ghi từng từ 32-bit)
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
 *                       CALLBACK NGẮT PHẦN CỨNG
 * ============================================================================== */

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) {
    if (GPIO_Pin == VL53L_SENSOR_INT_PIN) {
        vl53_int_flag = true;
    }
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) {
    if (huart->Instance == VL53L_PLC_UART_HANDLE.Instance) {
        if (rx_head < 127) {
            rx_ring[rx_head++] = rx_raw_byte;
            rx_ring[rx_head] = 0;
        }
        g_vl53_app.comm_success_count++;
        HAL_UART_Receive_IT(&VL53L_PLC_UART_HANDLE, &rx_raw_byte, 1);
    }
}

void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart) {
    if (huart->Instance == VL53L_PLC_UART_HANDLE.Instance) {
        // DMA TX completed
    }
}

/* ==============================================================================
 *       BỘ LỌC TRUNG BÌNH TRƯỢT LOẠI BỎ GAI BẤT THƯỜNG (KHÔNG VÙNG CHẾT)
 * ============================================================================== */

#define FILTER_WINDOW_SIZE  7

static uint16_t Filter_TrimmedMovingAverage(uint16_t raw_mm) {
    static uint16_t window[FILTER_WINDOW_SIZE] = {0};
    static uint8_t  head = 0;
    static uint8_t  count = 0;
    static uint16_t last_valid_val = 2002;

    if (raw_mm < 30 || raw_mm > 4000) {
        return last_valid_val;
    }

    window[head] = raw_mm;
    head = (head + 1) % FILTER_WINDOW_SIZE;
    if (count < FILTER_WINDOW_SIZE) {
        count++;
    }

    if (count < 3) {
        last_valid_val = raw_mm;
        return raw_mm;
    }

    uint16_t sorted[FILTER_WINDOW_SIZE];
    for (uint8_t i = 0; i < count; i++) {
        sorted[i] = window[i];
    }

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

    if (valid_cnt > 0) {
        last_valid_val = (uint16_t)(sum / valid_cnt);
    } else {
        last_valid_val = raw_mm;
    }

    return last_valid_val;
}

/* ==============================================================================
 *                       XỬ LÝ HIỆU CHUẨN (CALIBRATION D910 / M910)
 * ============================================================================== */

void VL53L_SetCalibTarget(uint16_t target_mm) {
    if (target_mm >= 30 && target_mm <= 4000) {
        g_vl53_app.d_calib_target = target_mm;
    }
}

void VL53L_TriggerCalib(void) {
    if (g_vl53_app.d_distance_raw > 0) {
        int32_t offset = (int32_t)g_vl53_app.d_calib_target - (int32_t)g_vl53_app.d_distance_raw;
        g_vl53_app.d_calib_offset = (int16_t)offset;
        g_vl53_app.calib_done = true;
        g_vl53_app.m_calib_trigger = false;

        // Lưu vĩnh viễn vào Flash STM32 (mất điện không bao giờ mất)
        Calib_Save_To_Flash();
    }
}

/* ==============================================================================
 *                       GIAO THỨC MITSUBISHI Q-SERIES TYPE 5 BATCH WRITE
 * ============================================================================== */

static uint16_t Build_Mitsubishi_Batch_Write_6Words(uint8_t *out_buf, const uint16_t *data_6words) {
    uint8_t payload[48];
    uint16_t p_len = 0;
    
    // 1. Length (30 bytes = 0x001E: 18 bytes header/cmd/addr/pts + 12 bytes data)
    payload[p_len++] = 0x1E;
    payload[p_len++] = 0x00;
    
    // 2. Routing Header (8 bytes)
    payload[p_len++] = 0xF8;
    payload[p_len++] = 0x00;
    payload[p_len++] = 0x00; // Network No: 00
    payload[p_len++] = 0xFF; // PLC No: FF
    payload[p_len++] = 0xFF; // Module I/O: 0x03FF
    payload[p_len++] = 0x03;
    payload[p_len++] = 0x00; // Substation: 00
    payload[p_len++] = 0x00; // Timer: 00
    
    // 3. Command: 0x1401 (Batch Write)
    payload[p_len++] = 0x01;
    payload[p_len++] = 0x14;
    
    // 4. Subcommand: 0x0000 (Word)
    payload[p_len++] = 0x00;
    payload[p_len++] = 0x00;
    
    // 5. Device Head Address (D900)
    payload[p_len++] = (uint8_t)(VL53L_PLC_D_START_ADDR & 0xFF);
    payload[p_len++] = (uint8_t)((VL53L_PLC_D_START_ADDR >> 8) & 0xFF);
    payload[p_len++] = 0x00;
    
    // 6. Device Code: 0xA8 (Data Register D)
    payload[p_len++] = 0xA8;
    
    // 7. Device Points: 0x0006 (6 Words)
    payload[p_len++] = (uint8_t)(VL53L_PLC_D_TOTAL_POINTS & 0xFF);
    payload[p_len++] = (uint8_t)((VL53L_PLC_D_TOTAL_POINTS >> 8) & 0xFF);
    
    // 8. Dữ liệu 6 thanh ghi (12 bytes)
    for (uint8_t i = 0; i < VL53L_PLC_D_TOTAL_POINTS; i++) {
        payload[p_len++] = (uint8_t)(data_6words[i] & 0xFF);
        payload[p_len++] = (uint8_t)((data_6words[i] >> 8) & 0xFF);
    }
    
    // 9. Tính Checksum
    uint16_t sum = 0;
    for (uint16_t i = 0; i < p_len; i++) {
        sum += payload[i];
    }
    
    // 10. DLE Stuffing (nhân đôi byte 0x10 -> 0x10 0x10)
    uint16_t tx_idx = 0;
    out_buf[tx_idx++] = 0x10; // DLE
    out_buf[tx_idx++] = 0x02; // STX
    
    for (uint16_t i = 0; i < p_len; i++) {
        out_buf[tx_idx++] = payload[i];
        if (payload[i] == 0x10) {
            out_buf[tx_idx++] = 0x10;
        }
    }
    
    out_buf[tx_idx++] = 0x10; // DLE
    out_buf[tx_idx++] = 0x03; // ETX
    
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
    // 1. Khôi phục thông số Calib đã lưu trong Flash (nếu có)
    Calib_Load_From_Flash();

    // 2. Khởi tạo cảm biến và UART
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

            // Kiểm tra cờ lệnh Calib M910
            if (g_vl53_app.m_calib_trigger) {
                VL53L_TriggerCalib();
            }

            if (status == 0) {
                uint16_t raw_filtered = Filter_TrimmedMovingAverage(dist);
                
                // Áp dụng bù Offset Calib vào D900
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

    uint16_t status_word = 0;
    if (g_vl53_app.sensor_ok) status_word |= (1 << 0);
    if (g_vl53_app.d_distance_filtered > 0 && g_vl53_app.d_distance_filtered < 200) status_word |= (1 << 1);
    if (g_vl53_app.d_distance_filtered >= 30 && g_vl53_app.d_distance_filtered <= 3000) status_word |= (1 << 2);
    if (g_vl53_app.calib_done) status_word |= (1 << 3); // Bit 3: Đã có dữ liệu Calib
    g_vl53_app.d_status = status_word;
}

void VL53L_Task_PLC(void) {
    HAL_GPIO_TogglePin(led_GPIO_Port, led_Pin);
    g_vl53_app.d_heartbeat++;

    if (rx_head > 0) {
        rx_head = 0;
        g_vl53_app.comm_success_count++;
    }

    uint16_t d_table[VL53L_PLC_D_TOTAL_POINTS] = {
        g_vl53_app.d_distance_filtered, // D900
        g_vl53_app.d_distance_raw,      // D901
        g_vl53_app.d_status,            // D902
        g_vl53_app.d_error,             // D903
        g_vl53_app.d_scan_time_ms,      // D904
        g_vl53_app.d_heartbeat          // D905
    };

    uint16_t tx_len = Build_Mitsubishi_Batch_Write_6Words(tx_dma_buf, d_table);

    if (VL53L_PLC_UART_HANDLE.gState == HAL_UART_STATE_READY) {
        HAL_UART_Transmit_DMA(&VL53L_PLC_UART_HANDLE, tx_dma_buf, tx_len);
    }
}
