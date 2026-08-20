/**
 * @file VL53L1X_calibration.c
 * @brief Calibration functions implementation for VL53L1X
 */

#include "VL53L1X_calibration.h"

#define ALGO__PART_TO_PART_RANGE_OFFSET_MM 0x001E
#define MM_CONFIG__INNER_OFFSET_MM         0x0020
#define MM_CONFIG__OUTER_OFFSET_MM         0x0022

int8_t VL53L1X_CalibrateOffset(uint16_t dev, uint16_t TargetDistInMm, int16_t *offset) {
    uint8_t i = 0;
    int16_t AverageDistance = 0;
    uint16_t distance;
    VL53L1X_ERROR status = 0;

    status |= VL53L1_WrWord(dev, ALGO__PART_TO_PART_RANGE_OFFSET_MM, 0x0);
    status |= VL53L1_WrWord(dev, MM_CONFIG__INNER_OFFSET_MM, 0x0);
    status |= VL53L1_WrWord(dev, MM_CONFIG__OUTER_OFFSET_MM, 0x0);
    status |= VL53L1X_StartRanging(dev);

    while (i < 50) {
        uint8_t dataReady = 0;
        while (dataReady == 0) {
            status |= VL53L1X_CheckForDataReady(dev, &dataReady);
            VL53L1_WaitMs(dev, 2);
        }
        status |= VL53L1X_GetDistance(dev, &distance);
        status |= VL53L1X_ClearInterrupt(dev);
        AverageDistance = AverageDistance + distance;
        i++;
    }

    status |= VL53L1X_StopRanging(dev);
    AverageDistance = AverageDistance / 50;
    *offset = TargetDistInMm - AverageDistance;
    status |= VL53L1_WrWord(dev, ALGO__PART_TO_PART_RANGE_OFFSET_MM, *offset * 4);
    return status;
}

int8_t VL53L1X_CalibrateXtalk(uint16_t dev, uint16_t TargetDistInMm, uint16_t *xtalk) {
    uint8_t i = 0;
    float sum_spad = 0;
    float sum_signal = 0;
    float sum_distance = 0;
    uint16_t distance = 0;
    uint16_t spad = 0;
    uint16_t signal = 0;
    VL53L1X_ERROR status = 0;

    status |= VL53L1_WrWord(dev, 0x0016, 0);
    status |= VL53L1X_StartRanging(dev);

    while (i < 50) {
        uint8_t dataReady = 0;
        while (dataReady == 0) {
            status |= VL53L1X_CheckForDataReady(dev, &dataReady);
            VL53L1_WaitMs(dev, 2);
        }
        status |= VL53L1X_GetDistance(dev, &distance);
        status |= VL53L1X_GetSignalRate(dev, &signal);
        status |= VL53L1X_GetSpadNb(dev, &spad);
        status |= VL53L1X_ClearInterrupt(dev);
        sum_distance += distance;
        sum_spad += spad;
        sum_signal += signal;
        i++;
    }

    status |= VL53L1X_StopRanging(dev);
    float avg_dist = sum_distance / 50.0f;
    float avg_spad = sum_spad / 50.0f;
    float avg_signal = sum_signal / 50.0f;

    if (avg_spad > 0 && avg_dist > 0) {
        float cal_xtalk = 512.0f * (avg_signal * (1.0f - (avg_dist / (float)TargetDistInMm))) / avg_spad;
        if (cal_xtalk < 0) cal_xtalk = 0;
        *xtalk = (uint16_t)cal_xtalk;
        status |= VL53L1_WrWord(dev, 0x0016, *xtalk);
    }
    return status;
}
