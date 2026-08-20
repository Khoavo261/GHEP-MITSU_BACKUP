/**
 * @file VL53L1X_api.h
 * @brief VL53L1X Ultra Lite Driver (ULD) API functions
 */

#ifndef _VL53L1X_API_H_
#define _VL53L1X_API_H_

#include "vl53l1_platform.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint8_t   I2cDevAddr;
} VL53L1X_Dev_t;

typedef struct {
    uint8_t   Status;
    uint16_t  Distance;
    uint16_t  AmbientRate;
    uint16_t  SigPerSPAD;
    uint16_t  NumSPADs;
} VL53L1X_Result_t;

#define VL53L1X_IMPLEMENTATION_VER_MAJOR 3
#define VL53L1X_IMPLEMENTATION_VER_MINOR 5
#define VL53L1X_IMPLEMENTATION_VER_SUB   1
#define VL53L1X_IMPLEMENTATION_VER_REVISION 0

/* Distance Mode */
#define VL53L1X_DISTANCE_MODE_SHORT 1
#define VL53L1X_DISTANCE_MODE_LONG  2

/* API Functions */
VL53L1X_ERROR VL53L1X_GetDriverVersion(uint8_t *major, uint8_t *minor, uint8_t *build, uint8_t *revision);
VL53L1X_ERROR VL53L1X_SetI2CAddress(uint16_t dev, uint8_t new_address);
VL53L1X_ERROR VL53L1X_SensorInit(uint16_t dev);
VL53L1X_ERROR VL53L1X_ClearInterrupt(uint16_t dev);
VL53L1X_ERROR VL53L1X_SetInterruptPolarity(uint16_t dev, uint8_t IntPol);
VL53L1X_ERROR VL53L1X_GetInterruptPolarity(uint16_t dev, uint8_t *pIntPol);
VL53L1X_ERROR VL53L1X_StartRanging(uint16_t dev);
VL53L1X_ERROR VL53L1X_StopRanging(uint16_t dev);
VL53L1X_ERROR VL53L1X_CheckForDataReady(uint16_t dev, uint8_t *isDataReady);
VL53L1X_ERROR VL53L1X_SetTimingBudgetInMs(uint16_t dev, uint16_t TimingBudgetInMs);
VL53L1X_ERROR VL53L1X_GetTimingBudgetInMs(uint16_t dev, uint16_t *pTimingBudgetInMs);
VL53L1X_ERROR VL53L1X_SetDistanceMode(uint16_t dev, uint16_t DistanceMode);
VL53L1X_ERROR VL53L1X_GetDistanceMode(uint16_t dev, uint16_t *pDistanceMode);
VL53L1X_ERROR VL53L1X_SetInterMeasurementInMs(uint16_t dev, uint32_t InterMeasurementInMs);
VL53L1X_ERROR VL53L1X_GetInterMeasurementInMs(uint16_t dev, uint16_t *pInterMeasurementInMs);
VL53L1X_ERROR VL53L1X_BootState(uint16_t dev, uint8_t *state);
VL53L1X_ERROR VL53L1X_GetSensorId(uint16_t dev, uint16_t *id);
VL53L1X_ERROR VL53L1X_GetDistance(uint16_t dev, uint16_t *distance);
VL53L1X_ERROR VL53L1X_GetSignalPerSpad(uint16_t dev, uint16_t *signalPerSp);
VL53L1X_ERROR VL53L1X_GetAmbientPerSpad(uint16_t dev, uint16_t *amb);
VL53L1X_ERROR VL53L1X_GetSignalRate(uint16_t dev, uint16_t *signalRate);
VL53L1X_ERROR VL53L1X_GetSpadNb(uint16_t dev, uint16_t *spNb);
VL53L1X_ERROR VL53L1X_GetAmbientRate(uint16_t dev, uint16_t *ambRate);
VL53L1X_ERROR VL53L1X_GetRangeStatus(uint16_t dev, uint8_t *rangeStatus);
VL53L1X_ERROR VL53L1X_GetResult(uint16_t dev, VL53L1X_Result_t *pResult);
VL53L1X_ERROR VL53L1X_SetOffset(uint16_t dev, int16_t OffsetValue);
VL53L1X_ERROR VL53L1X_GetOffset(uint16_t dev, int16_t *Offset);
VL53L1X_ERROR VL53L1X_SetXtalk(uint16_t dev, uint16_t XtalkValue);
VL53L1X_ERROR VL53L1X_GetXtalk(uint16_t dev, uint16_t *Xtalk);
VL53L1X_ERROR VL53L1X_SetDistanceThreshold(uint16_t dev, uint16_t ThreshLow, uint16_t ThreshHigh, uint8_t Window, uint8_t IntOnNoTarget);
VL53L1X_ERROR VL53L1X_GetDistanceThresholdWindow(uint16_t dev, uint8_t *window);
VL53L1X_ERROR VL53L1X_GetDistanceThresholdLow(uint16_t dev, uint16_t *low);
VL53L1X_ERROR VL53L1X_GetDistanceThresholdHigh(uint16_t dev, uint16_t *high);
VL53L1X_ERROR VL53L1X_SetROI(uint16_t dev, uint16_t X, uint16_t Y);
VL53L1X_ERROR VL53L1X_GetROI_XY(uint16_t dev, uint16_t *ROI_X, uint16_t *ROI_Y);
VL53L1X_ERROR VL53L1X_SetROICenter(uint16_t dev, uint8_t ROICenter);
VL53L1X_ERROR VL53L1X_GetROICenter(uint16_t dev, uint8_t *ROICenter);
VL53L1X_ERROR VL53L1X_SetSignalThreshold(uint16_t dev, uint16_t signal);
VL53L1X_ERROR VL53L1X_GetSignalThreshold(uint16_t dev, uint16_t *signal);
VL53L1X_ERROR VL53L1X_SetSigmaThreshold(uint16_t dev, uint16_t sigma);
VL53L1X_ERROR VL53L1X_GetSigmaThreshold(uint16_t dev, uint16_t *sigma);
VL53L1X_ERROR VL53L1X_StartTemperatureUpdate(uint16_t dev);

#ifdef __cplusplus
}
#endif

#endif /* _VL53L1X_API_H_ */
