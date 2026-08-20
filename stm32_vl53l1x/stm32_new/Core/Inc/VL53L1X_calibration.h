/**
 * @file VL53L1X_calibration.h
 * @brief Calibration functions for VL53L1X
 */

#ifndef _VL53L1X_CALIBRATION_H_
#define _VL53L1X_CALIBRATION_H_

#include "VL53L1X_api.h"

#ifdef __cplusplus
extern "C" {
#endif

int8_t VL53L1X_CalibrateOffset(uint16_t dev, uint16_t TargetDistInMm, int16_t *offset);
int8_t VL53L1X_CalibrateXtalk(uint16_t dev, uint16_t TargetDistInMm, uint16_t *xtalk);

#ifdef __cplusplus
}
#endif

#endif /* _VL53L1X_CALIBRATION_H_ */
