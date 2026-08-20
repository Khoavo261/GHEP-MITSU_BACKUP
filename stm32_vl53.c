/**
  ******************************************************************************
  * @file           : stm32_vl53.c
  * @brief          : Giao tiep VL53L1X + MC Protocol Format 4 (QJ71C24N CH2 RS422)
  * @target         : STM32F401CCU6 (BlackPill / Custom Board)
  * @author         : Antigravity & Mitsubishi Q-Series Integration
  ******************************************************************************
  * Mo ta hoat dong:
  * 1. Doc khoang cach tu Laser VL53L1X qua I2C (PB6/PB7).
  * 2. Loc trung binh dong 16 mau (Moving Average) loai bo nhieu anh sang/rung.
  * 3. MC Protocol Format 4:
  *    - Ghi khoang cach (WW) vao D900 cua PLC QJ71.
  *    - Doc tham so (WR) tu D910..D911 cua PLC ve STM32.
  * 4. Truyen nhan qua UART1 DMA (PA9-TX, PA10-RX) khong ton tai CPU.
  ******************************************************************************
  */

#include "main.h"
#include "vl53l1_api.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* ========================================================================== */
/* CAU HINH THONG SO                                                          */
/* ========================================================================== */
#define STATION_NO          "00"         // So tram QJ71 (Phai khop Switch 5)
#define PLC_CPU_NO          "FF"         // CPU mac dinh
#define REG_DIST_WRITE      "000900"     // Ghi vao D900
#define REG_PARAM_READ      "000910"     // Doc tu D910..D911
#define NUM_READ_POINTS     2            // So thanh ghi can doc
#define FILTER_SAMPLES      16           // So mau loc trung binh dong
#define COMM_PERIOD_MS      50           // Chu ky truyen thong 50ms (20Hz)

#define TX_BUF_SIZE         128
#define RX_BUF_SIZE         128

/* ========================================================================== */
/* BIEN TOAN CUC                                                              */
/* ========================================================================== */
extern I2C_HandleTypeDef  hi2c1;
extern UART_HandleTypeDef huart1;

VL53L1_Dev_t dev;
VL53L1_RangingMeasurementData_t RangingData;

uint16_t filter_buf[FILTER_SAMPLES] = {0};
uint8_t  filter_idx = 0;
uint8_t  filter_cnt = 0;

uint8_t  tx_dma_buf[TX_BUF_SIZE];
uint8_t  rx_dma_buf[RX_BUF_SIZE];
uint8_t  rx_process_buf[RX_BUF_SIZE];

volatile uint8_t dma_tx_busy = 0;
volatile uint8_t rx_data_ready = 0;
volatile uint16_t rx_data_len = 0;

// Du lieu doc ve tu PLC (D910: Nguong canh bao, D911: Lenh dieu khien tu HMI)
uint16_t plc_param_D910 = 0;
uint16_t plc_param_D911 = 0;

typedef enum {
    COMM_STEP_IDLE = 0,
    COMM_STEP_SEND_WRITE,  // Lenh WW (Ghi D900)
    COMM_STEP_SEND_READ,   // Lenh WR (Doc D910..D911)
    COMM_STEP_WAIT_READ_RESP
} CommStep_t;

CommStep_t comm_step = COMM_STEP_SEND_WRITE;
uint32_t last_comm_time = 0;
uint32_t read_timeout_timer = 0;

/* ========================================================================== */
/* THUAT TOAN LOC TRUNG BINH DONG (MOVING AVERAGE FILTER)                     */
/* ========================================================================== */
uint16_t VL53_Filter_MovingAverage(uint16_t raw_mm) {
    // Loai bo mau rac khi cam bien bi vuot tam hoac bi chan
    if (raw_mm < 30 || raw_mm > 4000) {
        if (filter_cnt > 0) {
            uint8_t prev_idx = (filter_idx == 0) ? (FILTER_SAMPLES - 1) : (filter_idx - 1);
            return filter_buf[prev_idx];
        }
        return 0;
    }

    filter_buf[filter_idx] = raw_mm;
    filter_idx = (filter_idx + 1) % FILTER_SAMPLES;
    if (filter_cnt < FILTER_SAMPLES) filter_cnt++;

    uint32_t sum = 0;
    for (uint8_t i = 0; i < filter_cnt; i++) {
        sum += filter_buf[i];
    }
    return (uint16_t)(sum / filter_cnt);
}

/* ========================================================================== */
/* HAM DONG GOI MC PROTOCOL FORMAT 4 - LENH GHI WORD (WW)                     */
/* ========================================================================== */
uint16_t Build_MC_Format4_Write(uint8_t *out_buf, const char* head_reg, uint16_t *data, uint8_t points) {
    char payload[128];
    char hex_str[8];

    // Payload: [Station][PLC][Command:WW][Wait:0][Device:D*][HeadAddr][Points]
    sprintf(payload, "%s%sWW0D*%s%02X", STATION_NO, PLC_CPU_NO, head_reg, points);
    
    // Chen du lieu 4-digit HEX cua tung thanh ghi
    for (uint8_t i = 0; i < points; i++) {
        sprintf(hex_str, "%04X", data[i]);
        strcat(payload, hex_str);
    }

    uint16_t payload_len = strlen(payload);
    out_buf[0] = 0x02; // STX
    memcpy(&out_buf[1], payload, payload_len);
    out_buf[1 + payload_len] = 0x03; // ETX

    // Tinh Sum Check (Tong byte tu sau STX den het ETX)
    uint16_t sum = 0;
    for (uint16_t i = 1; i <= 1 + payload_len; i++) {
        sum += out_buf[i];
    }
    sprintf((char*)&out_buf[2 + payload_len], "%02X", (uint8_t)(sum & 0xFF));

    return (2 + payload_len + 2); // Do dai ca STX, Payload, ETX, SumCheck
}

/* ========================================================================== */
/* HAM DONG GOI MC PROTOCOL FORMAT 4 - LENH DOC WORD (WR)                      */
/* ========================================================================== */
uint16_t Build_MC_Format4_Read(uint8_t *out_buf, const char* head_reg, uint8_t points) {
    char payload[64];

    // Payload: [Station][PLC][Command:WR][Wait:0][Device:D*][HeadAddr][Points]
    sprintf(payload, "%s%sWR0D*%s%02X", STATION_NO, PLC_CPU_NO, head_reg, points);

    uint16_t payload_len = strlen(payload);
    out_buf[0] = 0x02; // STX
    memcpy(&out_buf[1], payload, payload_len);
    out_buf[1 + payload_len] = 0x03; // ETX

    // Tinh Sum Check
    uint16_t sum = 0;
    for (uint16_t i = 1; i <= 1 + payload_len; i++) {
        sum += out_buf[i];
    }
    sprintf((char*)&out_buf[2 + payload_len], "%02X", (uint8_t)(sum & 0xFF));

    return (2 + payload_len + 2);
}

/* ========================================================================== */
/* HAM GIAI MA PHAN HOI LENH DOC TU PLC (PARSE MC FORMAT 4 READ RESPONSE)    */
/* Khung tra ve chuan: [STX][Station:2][PLC:2][Data:4 x Points][ETX][SumCheck:2]*/
/* ========================================================================== */
uint8_t Parse_MC_Format4_Read_Response(uint8_t *rx, uint16_t len, uint16_t *out_data, uint8_t points) {
    uint16_t expected_len = 1 + 4 + (points * 4) + 1 + 2;
    if (len < expected_len) return 0; // Goi tin bi thieu byte
    if (rx[0] != 0x02) return 0;      // Khong co STX dau khung

    uint16_t etx_pos = 1 + 4 + (points * 4);
    if (rx[etx_pos] != 0x03) return 0; // Sai vi tri ETX

    // Kiem tra Sum Check
    uint16_t sum = 0;
    for (uint16_t i = 1; i <= etx_pos; i++) sum += rx[i];

    char calc_sum_str[3];
    sprintf(calc_sum_str, "%02X", (uint8_t)(sum & 0xFF));
    if (strncmp((char*)&rx[etx_pos + 1], calc_sum_str, 2) != 0) {
        return 0; // Sai ma Checksum do nhieu duong truyen
    }

    // Trich xuat tung gia tri 16-bit HEX
    char hex_str[5] = {0};
    uint8_t *p_data = &rx[5]; // Bat dau sau [STX][00FF]
    for (uint8_t i = 0; i < points; i++) {
        memcpy(hex_str, p_data + (i * 4), 4);
        out_data[i] = (uint16_t)strtol(hex_str, NULL, 16);
    }

    return 1; // Thanh cong 100%
}

/* ========================================================================== */
/* UART DMA CALLBACKS                                                         */
/* ========================================================================== */
void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart) {
    if (huart->Instance == USART1) {
        dma_tx_busy = 0;
    }
}

void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size) {
    if (huart->Instance == USART1) {
        memcpy(rx_process_buf, rx_dma_buf, Size);
        rx_data_len = Size;
        rx_data_ready = 1;
        
        // Kich hoat lai bo dem DMA san sang nhan lan ke tiep
        HAL_UARTEx_ReceiveToIdle_DMA(&huart1, rx_dma_buf, RX_BUF_SIZE);
    }
}

/* ========================================================================== */
/* KHOI TAO PHAN CUNG CAM BIEN & TRUYEN THONG                                 */
/* ========================================================================== */
void STM32_VL53_Init(void) {
    // 1. Khoi tao sensor VL53L1X qua I2C1
    dev.I2cHandle = &hi2c1;
    dev.I2cDevAddr = 0x52;

    VL53L1_WaitDeviceBooted(&dev);
    VL53L1_DataInit(&dev);
    VL53L1_StaticInit(&dev);
    VL53L1_SetDistanceMode(&dev, VL53L1_DISTANCEMODE_LONG);
    VL53L1_SetMeasurementTimingBudgetMicroSeconds(&dev, 40000); // 40ms trích mẫu
    VL53L1_SetInterMeasurementPeriodMilliSeconds(&dev, 45);
    VL53L1_StartMeasurement(&dev);

    // 2. Bat san che do DMA Nhan Idle tren USART1 (RS422)
    HAL_UARTEx_ReceiveToIdle_DMA(&huart1, rx_dma_buf, RX_BUF_SIZE);
}

/* ========================================================================== */
/* VONG LAP TRUYEN THONG 2 CHIEU (GOI TRONG WHILE(1) CUA MAIN)                */
/* ========================================================================== */
void STM32_VL53_Process(void) {
    uint32_t now = HAL_GetTick();

    // 1. Doc gia tri khoang cach moi tu VL53L1X
    uint8_t dataReady = 0;
    static uint16_t current_filtered_dist = 0;

    VL53L1_CheckForDataReady(&dev, &dataReady);
    if (dataReady != 0) {
        VL53L1_GetRangingMeasurementData(&dev, &RangingData);
        if (RangingData.RangeStatus == 0) {
            current_filtered_dist = VL53_Filter_MovingAverage(RangingData.RangeMilliMeter);
        }
        VL53L1_ClearInterruptAndStartMeasurement(&dev);
    }

    // 2. Xu ly goi phan hoi tu PLC neu co
    if (rx_data_ready) {
        rx_data_ready = 0;
        if (comm_step == COMM_STEP_WAIT_READ_RESP) {
            uint16_t read_vals[NUM_READ_POINTS];
            if (Parse_MC_Format4_Read_Response(rx_process_buf, rx_data_len, read_vals, NUM_READ_POINTS)) {
                plc_param_D910 = read_vals[0]; // Nguong canh bao doc tu PLC
                plc_param_D911 = read_vals[1]; // Lenh dieu khien tu HMI
            }
            comm_step = COMM_STEP_SEND_WRITE; // Hoan thanh doc -> quay ve luot ghi
        }
    }

    // 3. Quan ly Timeout neu PLC khong tra loi
    if (comm_step == COMM_STEP_WAIT_READ_RESP && (now - read_timeout_timer >= 100)) {
        comm_step = COMM_STEP_SEND_WRITE; // Bo qua luot doc bi loi
    }

    // 4. May trang thai dieu phoi truyen thong dinh ky
    if ((now - last_comm_time >= COMM_PERIOD_MS) && (!dma_tx_busy)) {
        last_comm_time = now;

        if (comm_step == COMM_STEP_SEND_WRITE) {
            // A. GHI KHOANG CACH LEN D900 CUA PLC (LENH WW)
            uint16_t send_val[1] = { current_filtered_dist };
            uint16_t tx_len = Build_MC_Format4_Write(tx_dma_buf, REG_DIST_WRITE, send_val, 1);

            dma_tx_busy = 1;
            HAL_UART_Transmit_DMA(&huart1, tx_dma_buf, tx_len);
            
            comm_step = COMM_STEP_SEND_READ; // Luot tiep theo se gui lenh doc
        }
        else if (comm_step == COMM_STEP_SEND_READ) {
            // B. GUI LENH YEU CAU DOC D910..D911 TU PLC (LENH WR)
            uint16_t tx_len = Build_MC_Format4_Read(tx_dma_buf, REG_PARAM_READ, NUM_READ_POINTS);

            dma_tx_busy = 1;
            read_timeout_timer = now;
            comm_step = COMM_STEP_WAIT_READ_RESP; // Chuyen sang cho phan hoi

            HAL_UART_Transmit_DMA(&huart1, tx_dma_buf, tx_len);
        }
    }
}
