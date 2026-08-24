/**
 * @file VL53L.c
 * @brief IMPLEMENTATION CẢM BIẾN TOF VL53L0X TRÊN STM32F103C8T6 (HỖ TRỢ MULTI-NODE & FLASH)
 */

#include "VL53L.h"
#include "can_vl53.h"
#include "cmsis_os.h"
#include "i2c.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* ==============================================================================
 *                       CẤU HÌNH FLASH LƯU CALIB & NODE ID CHO STM32F103
 * ============================================================================== */
#define CALIB_FLASH_MAGIC_KEY       0x55AA1235   // Key phiên bản Multi-Node
#define CALIB_FLASH_ADDR            0x0800FC00   // Page 63 của 64KB Flash

typedef struct {
    uint32_t magic_key;
    uint16_t calib_target;
    int16_t  calib_offset;
    uint8_t  node_id;
    uint8_t  reserved[3];
    uint32_t checksum;
} Calib_Flash_Data_t;

/* ==============================================================================
 *                       BIẾN TOÀN CỤC & TRẠNG THÁI
 * ============================================================================== */
VL53L_AppData_t g_vl53_app = {
    .node_id = DEFAULT_NODE_ID,
    .d_distance_filtered = 0,
    .d_distance_raw = 0,
    .d_status = 1,
    .d_error = 0,
    .d_scan_time_ms = 0,
    .d_heartbeat = 0,
    .sensor_chip_id = 0,
    .is_vl53l0x = true,
    .d_calib_target = 0,
    .d_calib_cmd_flag = 0,
    .d_calib_offset = 0,
    .calib_done = false,
    .sensor_ok = false,
    .raw_range_status = 0
};

static volatile uint16_t pending_calib_cmd = 0;
static volatile uint16_t pending_calib_target = 0;
static uint8_t s_l0x_stop_variable = 0;

/* ==============================================================================
 *                       ĐỌC & GHI FLASH STM32F103 (PAGE ERASE)
 * ============================================================================== */

static void Calib_Load_From_Flash(void) {
    const Calib_Flash_Data_t *flash_ptr = (const Calib_Flash_Data_t*)CALIB_FLASH_ADDR;

    if (flash_ptr->magic_key == CALIB_FLASH_MAGIC_KEY) {
        uint32_t check = flash_ptr->magic_key + flash_ptr->calib_target + (uint16_t)flash_ptr->calib_offset + flash_ptr->node_id;
        if (check == flash_ptr->checksum) {
            g_vl53_app.d_calib_target = flash_ptr->calib_target;
            g_vl53_app.d_calib_offset = flash_ptr->calib_offset;
            if (flash_ptr->node_id >= 1 && flash_ptr->node_id <= 64) {
                g_vl53_app.node_id = flash_ptr->node_id;
            }
            g_vl53_app.calib_done = true;
        }
    }
}

static bool Calib_Save_To_Flash(void) {
    Calib_Flash_Data_t save_data;
    memset(&save_data, 0, sizeof(Calib_Flash_Data_t));
    save_data.magic_key    = CALIB_FLASH_MAGIC_KEY;
    save_data.calib_target = g_vl53_app.d_calib_target;
    save_data.calib_offset = g_vl53_app.d_calib_offset;
    save_data.node_id      = g_vl53_app.node_id;
    save_data.checksum     = save_data.magic_key + save_data.calib_target + (uint16_t)save_data.calib_offset + save_data.node_id;

    HAL_FLASH_Unlock();

    FLASH_EraseInitTypeDef EraseInitStruct;
    EraseInitStruct.TypeErase   = FLASH_TYPEERASE_PAGES;
    EraseInitStruct.PageAddress = CALIB_FLASH_ADDR;
    EraseInitStruct.NbPages     = 1;

    uint32_t PageError = 0;
    if (HAL_FLASHEx_Erase(&EraseInitStruct, &PageError) != HAL_OK) {
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

bool VL53L_SaveNodeId_To_Flash(uint8_t new_node_id) {
    if (new_node_id < 1 || new_node_id > 64) return false;
    g_vl53_app.node_id = new_node_id;
    return Calib_Save_To_Flash();
}

/* ==============================================================================
 *   BỘ LỌC THÍCH NGHI ADAPTIVE CONSENSUS: ĐỨNG YÊN & BÁM 1MM
 * ============================================================================== */

#define FILTER_WINDOW_SIZE      15

static uint16_t Filter_TrimmedMovingAverage(uint16_t raw_mm) {
    static uint16_t window[FILTER_WINDOW_SIZE] = {0};
    static uint8_t  head = 0;
    static uint8_t  count = 0;
    static float    smoothed_dist = 0.0f;
    static uint16_t stable_output = 0;
    static int8_t   drift_count = 0;

    // Loại bỏ giá trị dị biệt / lỗi đọc không hợp lệ của VL53L0X
    if (raw_mm < 20 || raw_mm >= 8000) {
        return stable_output ? stable_output : raw_mm;
    }

    window[head] = raw_mm;
    head = (head + 1) % FILTER_WINDOW_SIZE;
    if (count < FILTER_WINDOW_SIZE) count++;

    if (count < 5) {
        smoothed_dist = (float)raw_mm;
        stable_output = raw_mm;
        return raw_mm;
    }

    // 1. Sắp xếp mảng để lọc bỏ 2 giá trị cực đại và 2 giá trị cực tiểu (Double Trimmed Mean)
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

    // Lấy trung bình các phần tử trung tâm (loại bỏ 2 giá trị nhiễu lớn nhất và 2 giá trị nhỏ nhất)
    uint32_t sum = 0;
    uint8_t valid_cnt = 0;
    uint8_t trim_offset = (count >= 9) ? 2 : 1;
    for (uint8_t i = trim_offset; i < count - trim_offset; i++) {
        sum += sorted[i];
        valid_cnt++;
    }
    float current_avg = (float)sum / (float)valid_cnt;

    // 2. Bộ lọc thích nghi tốc độ phản hồi (Multi-tier Adaptive EMA):
    float diff = current_avg - smoothed_dist;
    float abs_diff = (diff < 0.0f) ? -diff : diff;

    float alpha;
    if (abs_diff > 20.0f) {
        alpha = 0.90f; // Nhảy xa / chuyển động rất nhanh: bám ngay lập tức
    } else if (abs_diff > 8.0f) {
        alpha = 0.45f; // Chuyển động vừa
    } else if (abs_diff > 3.0f) {
        alpha = 0.18f; // Chuyển động nhẹ
    } else {
        alpha = 0.06f; // Rung nhiễu vi mô khi đứng yên: dập tắt hoàn toàn
    }

    smoothed_dist += alpha * (current_avg - smoothed_dist);

    // 3. Khóa chống rung số Hysteresis & Trend Consensus (Giữ số đứng yên tuyệt đối như thước đo chuẩn):
    if (stable_output == 0) {
        stable_output = (uint16_t)(smoothed_dist + 0.5f);
    } else {
        float out_diff = smoothed_dist - (float)stable_output;
        float abs_out_diff = (out_diff < 0.0f) ? -out_diff : out_diff;

        // Nếu chênh lệch dịch chuyển thực tế lớn (>= 4mm), cập nhật mượt theo vị trí mới
        if (abs_out_diff >= 4.0f) {
            stable_output = (uint16_t)(smoothed_dist + 0.5f);
            drift_count = 0;
        }
        // Nếu thay đổi dịch chuyển nhỏ (1..3mm), yêu cầu xác nhận liên tục (chống nhấp nhô do nhiễu sensor)
        else if (out_diff >= 0.85f) {
            drift_count++;
            if (drift_count >= 5) { // Phải lệch đủ 5 chu kỳ liên tục mới cho nhảy +1mm
                stable_output++;
                drift_count = 0;
            }
        } else if (out_diff <= -0.85f) {
            drift_count--;
            if (drift_count <= -5) { // Phải lệch đủ 5 chu kỳ liên tục mới cho nhảy -1mm
                stable_output--;
                drift_count = 0;
            }
        } else {
            // Nằm trong vùng chết an toàn (Deadband: -0.85mm .. +0.85mm) -> Đứng yên 100%
            drift_count = 0;
        }
    }

    return stable_output;
}

static void Process_Calib_And_Status(void);

/* ==============================================================================
 *                       GIAO TIẾP THANH GHI VL53L0X
 * ============================================================================== */

static uint8_t L0X_Rd(uint8_t reg) {
    uint8_t val = 0;
    if (I2C_Lock(50)) {
        HAL_I2C_Mem_Read(&hi2c1, VL53L_I2C_ADDR, reg, I2C_MEMADD_SIZE_8BIT, &val, 1, 50);
        I2C_Unlock();
    }
    return val;
}

static void L0X_Wr(uint8_t reg, uint8_t val) {
    if (I2C_Lock(50)) {
        HAL_I2C_Mem_Write(&hi2c1, VL53L_I2C_ADDR, reg, I2C_MEMADD_SIZE_8BIT, &val, 1, 50);
        I2C_Unlock();
    }
}

static bool Try_Init_Sensor(void) {
    if (!I2C_Lock(100)) return false;
    HAL_StatusTypeDef dev_ready = HAL_I2C_IsDeviceReady(&hi2c1, VL53L_I2C_ADDR, 3, 50);
    I2C_Unlock();

    if (dev_ready != HAL_OK) {
        I2C_RecoverBus();
        osDelay(10);
        if (!I2C_Lock(100)) return false;
        dev_ready = HAL_I2C_IsDeviceReady(&hi2c1, VL53L_I2C_ADDR, 3, 50);
        I2C_Unlock();
        if (dev_ready != HAL_OK) {
            g_vl53_app.d_error = 10;
            g_vl53_app.sensor_ok = false;
            return false;
        }
    }

    // Đọc Model ID của VL53L0X (0xEEAA)
    uint8_t id_hi = L0X_Rd(0xC0);
    uint8_t id_lo = L0X_Rd(0xC1);
    g_vl53_app.sensor_chip_id = ((uint16_t)id_hi << 8) | id_lo;
    g_vl53_app.is_vl53l0x = true;

    // Chuỗi khởi tạo cơ bản tiêu chuẩn của VL53L0X
    L0X_Wr(0x89, L0X_Rd(0x89) | 0x01);
    L0X_Wr(0x88, 0x00);

    L0X_Wr(0x80, 0x01);
    L0X_Wr(0xFF, 0x01);
    L0X_Wr(0x00, 0x00);
    s_l0x_stop_variable = L0X_Rd(0x91);
    L0X_Wr(0x00, 0x01);
    L0X_Wr(0xFF, 0x00);
    L0X_Wr(0x80, 0x00);

    L0X_Wr(0x60, L0X_Rd(0x60) | 0x12);

    L0X_Wr(0xFF, 0x01);
    L0X_Wr(0x00, 0x00);
    L0X_Wr(0xFF, 0x00);
    L0X_Wr(0x09, 0x00);
    L0X_Wr(0x10, 0x00);
    L0X_Wr(0x11, 0x00);
    L0X_Wr(0x24, 0x01);
    L0X_Wr(0x25, 0xFF);
    L0X_Wr(0x75, 0x00);
    L0X_Wr(0xFF, 0x01);
    L0X_Wr(0x4E, 0x2C);
    L0X_Wr(0x48, 0x00);
    L0X_Wr(0x30, 0x20);
    L0X_Wr(0xFF, 0x00);
    L0X_Wr(0x30, 0x09);
    L0X_Wr(0x54, 0x00);
    L0X_Wr(0x31, 0x04);
    L0X_Wr(0x32, 0x03);
    L0X_Wr(0x40, 0x83);
    L0X_Wr(0x46, 0x25);
    L0X_Wr(0x60, 0x00);
    L0X_Wr(0x27, 0x00);
    L0X_Wr(0x50, 0x06);
    L0X_Wr(0x51, 0x00);
    L0X_Wr(0x52, 0x96);
    L0X_Wr(0x56, 0x08);
    L0X_Wr(0x57, 0x30);
    L0X_Wr(0x61, 0x00);
    L0X_Wr(0x62, 0x00);
    L0X_Wr(0x64, 0x00);
    L0X_Wr(0x65, 0x00);
    L0X_Wr(0x66, 0xA0);
    L0X_Wr(0xFF, 0x01);
    L0X_Wr(0x22, 0x32);
    L0X_Wr(0x47, 0x14);
    L0X_Wr(0x49, 0xFF);
    L0X_Wr(0x4A, 0x00);
    L0X_Wr(0xFF, 0x00);
    L0X_Wr(0x7A, 0x0A);
    L0X_Wr(0x7B, 0x00);
    L0X_Wr(0x78, 0x21);
    L0X_Wr(0xFF, 0x01);
    L0X_Wr(0x23, 0x34);
    L0X_Wr(0x42, 0x00);
    L0X_Wr(0x44, 0xFF);
    L0X_Wr(0x45, 0x26);
    L0X_Wr(0x46, 0x05);
    L0X_Wr(0x40, 0x40);
    L0X_Wr(0x0E, 0x06);
    L0X_Wr(0x20, 0x1A);
    L0X_Wr(0x43, 0x40);
    L0X_Wr(0xFF, 0x00);
    L0X_Wr(0x34, 0x03);
    L0X_Wr(0x35, 0x44);
    L0X_Wr(0xFF, 0x01);
    L0X_Wr(0x31, 0x04);
    L0X_Wr(0x4B, 0x09);
    L0X_Wr(0x4C, 0x05);
    L0X_Wr(0x4D, 0x04);
    L0X_Wr(0xFF, 0x00);
    L0X_Wr(0x44, 0x00);
    L0X_Wr(0x45, 0x20);
    L0X_Wr(0x47, 0x08);
    L0X_Wr(0x48, 0x28);
    L0X_Wr(0x67, 0x00);
    L0X_Wr(0x70, 0x04);
    L0X_Wr(0x71, 0x01);
    L0X_Wr(0x72, 0xFE);
    L0X_Wr(0x76, 0x00);
    L0X_Wr(0x77, 0x00);
    L0X_Wr(0xFF, 0x01);
    L0X_Wr(0x0D, 0x01);
    L0X_Wr(0xFF, 0x00);
    L0X_Wr(0x80, 0x01);
    L0X_Wr(0x01, 0xF8);
    L0X_Wr(0xFF, 0x01);
    L0X_Wr(0x8E, 0x01);
    L0X_Wr(0x00, 0x01);
    L0X_Wr(0xFF, 0x00);
    L0X_Wr(0x80, 0x00);

    L0X_Wr(0x0A, 0x04);
    L0X_Wr(0x84, L0X_Rd(0x84) & ~0x10);
    L0X_Wr(0x0B, 0x01);

    L0X_Wr(0x01, 0x01);
    L0X_Wr(0x00, 0x01);
    uint32_t t = HAL_GetTick();
    while ((L0X_Rd(0x00) & 0x01) != 0 && (HAL_GetTick() - t < 50)) osDelay(2);

    L0X_Wr(0x01, 0x02);
    L0X_Wr(0x00, 0x01);
    t = HAL_GetTick();
    while ((L0X_Rd(0x00) & 0x01) != 0 && (HAL_GetTick() - t < 50)) osDelay(2);

    L0X_Wr(0x01, 0xE8);

    L0X_Wr(0x80, 0x01);
    L0X_Wr(0xFF, 0x01);
    L0X_Wr(0x00, 0x00);
    L0X_Wr(0x91, s_l0x_stop_variable);
    L0X_Wr(0x00, 0x01);
    L0X_Wr(0xFF, 0x00);
    L0X_Wr(0x80, 0x00);
    L0X_Wr(0x00, 0x02); // Start Continuous Ranging Mode

    g_vl53_app.sensor_ok = true;
    g_vl53_app.d_error = 0;
    return true;
}

void VL53L_Task_Sensor(void) {
    if (g_vl53_app.sensor_ok) {
        // Kiểm tra bit dữ liệu sẵn sàng (Data Ready)
        if ((L0X_Rd(0x13) & 0x07) != 0) {
            uint8_t buf[2] = {0};
            uint16_t dist = 0;
            if (I2C_Lock(50)) {
                if (HAL_I2C_Mem_Read(&hi2c1, VL53L_I2C_ADDR, 0x1E, I2C_MEMADD_SIZE_8BIT, buf, 2, 50) == HAL_OK) {
                    dist = ((uint16_t)buf[0] << 8) | buf[1];
                }
                // Xóa cờ ngắt
                uint8_t clr = 0x01;
                HAL_I2C_Mem_Write(&hi2c1, VL53L_I2C_ADDR, 0x0B, I2C_MEMADD_SIZE_8BIT, &clr, 1, 50);
                I2C_Unlock();
            }

            if (dist > 0 && dist < 8000) {
                g_vl53_app.d_distance_raw = dist;
                g_vl53_app.raw_range_status = 0;
                g_vl53_app.d_error = 0;

                uint16_t raw_filtered = Filter_TrimmedMovingAverage(dist);
                int32_t calibrated_dist = (int32_t)raw_filtered + (int32_t)g_vl53_app.d_calib_offset;
                if (calibrated_dist < 0) calibrated_dist = 0;
                g_vl53_app.d_distance_filtered = (uint16_t)calibrated_dist;
            } else if (dist >= 8000) {
                g_vl53_app.d_distance_raw = dist;
                g_vl53_app.d_distance_filtered = 8191;
            }
        }
    } else {
        static uint32_t last_scan = 0;
        if (HAL_GetTick() - last_scan >= 1000) {
            last_scan = HAL_GetTick();
            Try_Init_Sensor();
        }
    }
    Process_Calib_And_Status();
}

void VL53L_Init(void) {
    Calib_Load_From_Flash();
    if (!MASTER) {
        g_vl53_app.node_id = CAN_Read_Hardware_NodeID();
    }
    osDelay(100);
    Try_Init_Sensor();
}

void VL53L_SetPendingCalib(uint16_t cmd, uint16_t target) {
    pending_calib_cmd = cmd;
    pending_calib_target = target;
}

static void Process_Calib_And_Status(void) {
    // Xử lý các lệnh Calib & Cài đặt Node ID từ mạng CAN:
    if (pending_calib_cmd > 0) {
        uint16_t cmd = pending_calib_cmd;
        uint16_t tgt = pending_calib_target;
        pending_calib_cmd = 0;

        // MODE 99: Đổi Node ID mới qua mạng CAN
        if (cmd == 99 && tgt >= 1 && tgt <= 64) {
            VL53L_SaveNodeId_To_Flash((uint8_t)tgt);
            CAN_VL53_SetNodeId((uint8_t)tgt);
        }
        // MODE 10 (hoặc 1): Calib Offset phần mềm
        else if ((cmd == 10 || cmd == 1) && g_vl53_app.d_distance_raw > 0) {
            uint16_t target = (tgt > 0) ? tgt : g_vl53_app.d_distance_raw;
            int32_t offset = (int32_t)target - (int32_t)g_vl53_app.d_distance_raw;
            g_vl53_app.d_calib_target = target;
            g_vl53_app.d_calib_offset = (int16_t)offset;
            g_vl53_app.calib_done = true;
            Calib_Save_To_Flash();
        }
    }

    uint16_t status_word = 0;
    if (g_vl53_app.sensor_ok) status_word |= (1 << 0);
    if (g_vl53_app.d_distance_filtered > 0 && g_vl53_app.d_distance_filtered < 200) status_word |= (1 << 1);
    if (g_vl53_app.d_distance_filtered >= 30 && g_vl53_app.d_distance_filtered <= 3000) status_word |= (1 << 2);
    if (g_vl53_app.calib_done) status_word |= (1 << 3);
    g_vl53_app.d_status = status_word;
}
