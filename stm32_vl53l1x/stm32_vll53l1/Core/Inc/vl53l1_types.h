/**
 * @file vl53l1_types.h
 * @brief VL53L1X types definition
 */

#ifndef _VL53L1_TYPES_H_
#define _VL53L1_TYPES_H_

#include <stdint.h>
#include <stddef.h>
#include <string.h>

#ifndef NULL
#define NULL ((void *)0)
#endif

typedef uint8_t VL53L1X_ERROR;

#define VL53L1_ERROR_NONE                             ((VL53L1X_ERROR)  0)
#define VL53L1_ERROR_CALIBRATION_WARNING              ((VL53L1X_ERROR) -1)
#define VL53L1_ERROR_MIN_CLIPPED                      ((VL53L1X_ERROR) -2)
#define VL53L1_ERROR_UNDEFINED                        ((VL53L1X_ERROR) -3)
#define VL53L1_ERROR_INVALID_PARAMS                   ((VL53L1X_ERROR) -4)
#define VL53L1_ERROR_NOT_SUPPORTED                    ((VL53L1X_ERROR) -5)
#define VL53L1_ERROR_RANGE_ERROR                      ((VL53L1X_ERROR) -6)
#define VL53L1_ERROR_TIME_OUT                         ((VL53L1X_ERROR) -7)
#define VL53L1_ERROR_MODE_NOT_SUPPORTED               ((VL53L1X_ERROR) -8)
#define VL53L1_ERROR_BUFFER_TOO_SMALL                 ((VL53L1X_ERROR) -9)
#define VL53L1_ERROR_COMMS_BUFFER_TOO_SMALL           ((VL53L1X_ERROR) -10)
#define VL53L1_ERROR_GPIO_NOT_EXISTING                ((VL53L1X_ERROR) -11)
#define VL53L1_ERROR_GPIO_FUNCTIONALITY_NOT_SUPPORTED ((VL53L1X_ERROR) -12)
#define VL53L1_ERROR_CONTROL_INTERFACE                ((VL53L1X_ERROR) -13)
#define VL53L1_ERROR_INVALID_COMMAND                  ((VL53L1X_ERROR) -14)
#define VL53L1_ERROR_DIVISION_BY_ZERO                 ((VL53L1X_ERROR) -15)
#define VL53L1_ERROR_REF_SPAD_CHAR_NOT_ENOUGH_SPADS   ((VL53L1X_ERROR) -16)
#define VL53L1_ERROR_REF_SPAD_CHAR_REF_SPAD_INIT_FAIL ((VL53L1X_ERROR) -17)
#define VL53L1_ERROR_REF_SPAD_CHAR_XSHUT_FAIL         ((VL53L1X_ERROR) -18)
#define VL53L1_ERROR_POST_TUNING_FAIL                 ((VL53L1X_ERROR) -19)
#define VL53L1_ERROR_INCORRECT_MEASUREMENT_BUDGET     ((VL53L1X_ERROR) -20)
#define VL53L1_ERROR_CORRUPTED_DATA                   ((VL53L1X_ERROR) -21)
#define VL53L1_ERROR_CUSTOMER_TEST_FAIL               ((VL53L1X_ERROR) -22)

typedef struct {
    uint8_t   I2cDevAddr;
    void      *I2cHandle;
} VL53L1_Dev_t;

typedef VL53L1_Dev_t *VL53L1_DEV;

#endif /* _VL53L1_TYPES_H_ */
