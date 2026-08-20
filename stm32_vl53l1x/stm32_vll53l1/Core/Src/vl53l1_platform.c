/**
 * @file vl53l1_platform.c
 * @brief STM32 HAL I2C implementation for VL53L1X
 */

#include "vl53l1_platform.h"
#include "i2c.h"

#define I2C_TIMEOUT_MS 100

int8_t VL53L1_WriteMulti(uint16_t dev, uint16_t index, uint8_t *pdata, uint32_t count) {
    HAL_StatusTypeDef status;
    status = HAL_I2C_Mem_Write(&hi2c1, dev, index, I2C_MEMADD_SIZE_16BIT, pdata, (uint16_t)count, I2C_TIMEOUT_MS);
    return (status == HAL_OK) ? 0 : -1;
}

int8_t VL53L1_ReadMulti(uint16_t dev, uint16_t index, uint8_t *pdata, uint32_t count) {
    HAL_StatusTypeDef status;
    status = HAL_I2C_Mem_Read(&hi2c1, dev, index, I2C_MEMADD_SIZE_16BIT, pdata, (uint16_t)count, I2C_TIMEOUT_MS);
    return (status == HAL_OK) ? 0 : -1;
}

int8_t VL53L1_WrByte(uint16_t dev, uint16_t index, uint8_t data) {
    HAL_StatusTypeDef status;
    status = HAL_I2C_Mem_Write(&hi2c1, dev, index, I2C_MEMADD_SIZE_16BIT, &data, 1, I2C_TIMEOUT_MS);
    return (status == HAL_OK) ? 0 : -1;
}

int8_t VL53L1_WrWord(uint16_t dev, uint16_t index, uint16_t data) {
    uint8_t buffer[2];
    buffer[0] = (uint8_t)(data >> 8);
    buffer[1] = (uint8_t)(data & 0xFF);
    HAL_StatusTypeDef status;
    status = HAL_I2C_Mem_Write(&hi2c1, dev, index, I2C_MEMADD_SIZE_16BIT, buffer, 2, I2C_TIMEOUT_MS);
    return (status == HAL_OK) ? 0 : -1;
}

int8_t VL53L1_WrDWord(uint16_t dev, uint16_t index, uint32_t data) {
    uint8_t buffer[4];
    buffer[0] = (uint8_t)(data >> 24);
    buffer[1] = (uint8_t)(data >> 16);
    buffer[2] = (uint8_t)(data >> 8);
    buffer[3] = (uint8_t)(data & 0xFF);
    HAL_StatusTypeDef status;
    status = HAL_I2C_Mem_Write(&hi2c1, dev, index, I2C_MEMADD_SIZE_16BIT, buffer, 4, I2C_TIMEOUT_MS);
    return (status == HAL_OK) ? 0 : -1;
}

int8_t VL53L1_RdByte(uint16_t dev, uint16_t index, uint8_t *pdata) {
    HAL_StatusTypeDef status;
    status = HAL_I2C_Mem_Read(&hi2c1, dev, index, I2C_MEMADD_SIZE_16BIT, pdata, 1, I2C_TIMEOUT_MS);
    return (status == HAL_OK) ? 0 : -1;
}

int8_t VL53L1_RdWord(uint16_t dev, uint16_t index, uint16_t *pdata) {
    uint8_t buffer[2];
    HAL_StatusTypeDef status;
    status = HAL_I2C_Mem_Read(&hi2c1, dev, index, I2C_MEMADD_SIZE_16BIT, buffer, 2, I2C_TIMEOUT_MS);
    if (status == HAL_OK) {
        *pdata = ((uint16_t)buffer[0] << 8) | (uint16_t)buffer[1];
        return 0;
    }
    return -1;
}

int8_t VL53L1_RdDWord(uint16_t dev, uint16_t index, uint32_t *pdata) {
    uint8_t buffer[4];
    HAL_StatusTypeDef status;
    status = HAL_I2C_Mem_Read(&hi2c1, dev, index, I2C_MEMADD_SIZE_16BIT, buffer, 4, I2C_TIMEOUT_MS);
    if (status == HAL_OK) {
        *pdata = ((uint32_t)buffer[0] << 24) | ((uint32_t)buffer[1] << 16) | ((uint32_t)buffer[2] << 8) | (uint32_t)buffer[3];
        return 0;
    }
    return -1;
}

int8_t VL53L1_WaitMs(uint16_t dev, int32_t wait_ms) {
    (void)dev;
    HAL_Delay((uint32_t)wait_ms);
    return 0;
}

int8_t VL53L1_WaitValueMaskEx(uint16_t dev, uint32_t timeout_ms, uint16_t index, uint8_t value, uint8_t mask, uint32_t poll_delay_ms) {
    uint8_t data = 0;
    uint32_t start_time = HAL_GetTick();

    while (1) {
        if (VL53L1_RdByte(dev, index, &data) == 0) {
            if ((data & mask) == value) {
                return 0;
            }
        }
        if ((HAL_GetTick() - start_time) >= timeout_ms) {
            return -1;
        }
        if (poll_delay_ms > 0) {
            HAL_Delay(poll_delay_ms);
        }
    }
}
