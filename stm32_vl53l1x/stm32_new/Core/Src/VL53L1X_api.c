/**
 * @file VL53L1X_api.c
 * @brief VL53L1X Ultra Lite Driver (ULD) core implementation
 */

#include "VL53L1X_api.h"

#define SOFT_RESET                                                          0x0000
#define VL53L1_I2C_SLAVE__DEVICE_ADDRESS                                    0x0001
#define VL53L1_VHV_CONFIG__TIMEOUT_MACROP_LOOP_BOUND                        0x0008
#define ALGO__CROSSTALK_COMPENSATION_PLANE_OFFSET_KCPS                      0x0016
#define ALGO__CROSSTALK_COMPENSATION_X_PLANE_GRADIENT_KCPS                  0x0018
#define ALGO__CROSSTALK_COMPENSATION_Y_PLANE_GRADIENT_KCPS                  0x001A
#define ALGO__PART_TO_PART_RANGE_OFFSET_MM                                  0x001E
#define MM_CONFIG__INNER_OFFSET_MM                                          0x0020
#define MM_CONFIG__OUTER_OFFSET_MM                                          0x0022
#define GPIO_HV_MUX__CTRL                                                   0x0030
#define GPIO__TIO_HV_STATUS                                                 0x0031
#define SYSTEM__INTERRUPT_CONFIG_GPIO                                       0x0046
#define PHASECAL_CONFIG__TIMEOUT_MACROP                                     0x004B
#define RANGE_CONFIG__TIMEOUT_MACROP_A_HI                                   0x005E
#define RANGE_CONFIG__VCSEL_PERIOD_A                                        0x0060
#define RANGE_CONFIG__TIMEOUT_MACROP_B_HI                                   0x0061
#define RANGE_CONFIG__VCSEL_PERIOD_B                                        0x0063
#define RANGE_CONFIG__VALID_PHASE_HIGH                                      0x0069
#define SD_CONFIG__WOI_ON                                                   0x0078
#define SD_CONFIG__INITIAL_PHASE_KEEP                                       0x0079
#define SYSTEM__INTERMEASUREMENT_PERIOD                                     0x006C
#define SYSTEM__GROUPED_PARAMETER_HOLD_0                                    0x0071
#define SYSTEM__THRESH_HIGH                                                 0x0072
#define SYSTEM__THRESH_LOW                                                  0x0074
#define SYSTEM__ENABLE_XTALK_PER_QUADRANT                                   0x0085
#define SYSTEM__SEED_CONFIG                                                 0x0086
#define SYSTEM__HISTOGRAM_BIN                                               0x0088
#define SYSTEM__INITIAL_PHASE_KEEP                                          0x0089
#define SD_CONFIG__RESET_STAGES_MSB                                         0x008A
#define SD_CONFIG__RESET_STAGES_LSB                                         0x008B
#define SYSTEM__INTERRUPT_CLEAR                                             0x0086
#define SYSTEM__MODE_START                                                  0x0087
#define VL53L1_RESULT__RANGE_STATUS                                         0x0089
#define VL53L1_RESULT__DSS_ACTUAL_EFFECTIVE_SPADS_SD0                       0x008C
#define VL53L1_RESULT__AMBIENT_COUNT_RATE_MCPS_SD0                          0x0090
#define VL53L1_RESULT__FINAL_CROSSTALK_CORRECTED_RANGE_MM_SD0               0x0096
#define VL53L1_RESULT__PEAK_SIGNAL_COUNT_RATE_CROSSTALK_CORRECTED_MCPS_SD0  0x0098
#define VL53L1_IDENTIFICATION__MODEL_ID                                     0x010F
#define ROI_CONFIG__USER_ROI_CENTRE_SPAD                                    0x007F
#define ROI_CONFIG__USER_ROI_REQUESTED_GLOBAL_XY                            0x0080

static const uint8_t VL53L1X_DEFAULT_CONFIGURATION[] = {
    0x00, /* 0x2d : set bit 2 and 5 to 1 for fast osc frequency */
    0x00, /* 0x2e : set bit 7 to 1 for fast osc frequency */
    0x00, /* 0x2f : bit 0 is reset value */
    0x01, /* 0x30 : GPIO_HV_MUX__CTRL */
    0x02, /* 0x31 : GPIO__TIO_HV_STATUS */
    0x00, /* 0x32 */
    0x02, /* 0x33 */
    0x08, /* 0x34 */
    0x00, /* 0x35 */
    0x08, /* 0x36 */
    0x10, /* 0x37 */
    0x01, /* 0x38 */
    0x01, /* 0x39 */
    0x00, /* 0x3a */
    0x00, /* 0x3b */
    0x00, /* 0x3c */
    0x00, /* 0x3d */
    0xff, /* 0x3e */
    0x00, /* 0x3f */
    0x0F, /* 0x40 */
    0x00, /* 0x41 */
    0x00, /* 0x42 */
    0x00, /* 0x43 */
    0x00, /* 0x44 */
    0x00, /* 0x45 */
    0x20, /* 0x46 : SYSTEM__INTERRUPT_CONFIG_GPIO */
    0x0b, /* 0x47 */
    0x00, /* 0x48 */
    0x00, /* 0x49 */
    0x02, /* 0x4a */
    0x0a, /* 0x4b : PHASECAL_CONFIG__TIMEOUT_MACROP */
    0x21, /* 0x4c */
    0x00, /* 0x4d */
    0x00, /* 0x4e */
    0x05, /* 0x4f */
    0x00, /* 0x50 */
    0x00, /* 0x51 */
    0x00, /* 0x52 */
    0x00, /* 0x53 */
    0xc8, /* 0x54 */
    0x00, /* 0x55 */
    0x00, /* 0x56 */
    0x38, /* 0x57 */
    0xff, /* 0x58 */
    0x01, /* 0x59 */
    0x00, /* 0x5a */
    0x08, /* 0x5b */
    0x00, /* 0x5c */
    0x00, /* 0x5d */
    0x01, /* 0x5e */
    0xcc, /* 0x5f */
    0x0f, /* 0x60 : RANGE_CONFIG__VCSEL_PERIOD_A */
    0x01, /* 0x61 */
    0xf1, /* 0x62 */
    0x0d, /* 0x63 : RANGE_CONFIG__VCSEL_PERIOD_B */
    0x01, /* 0x64 */
    0x68, /* 0x65 */
    0x00, /* 0x66 */
    0x80, /* 0x67 */
    0x08, /* 0x68 */
    0xb8, /* 0x69 : RANGE_CONFIG__VALID_PHASE_HIGH */
    0x00, /* 0x6a */
    0x00, /* 0x6b */
    0x00, /* 0x6c : SYSTEM__INTERMEASUREMENT_PERIOD */
    0x00, /* 0x6d */
    0x0f, /* 0x6e */
    0x89, /* 0x6f */
    0x00, /* 0x70 */
    0x00, /* 0x71 */
    0x00, /* 0x72 */
    0x00, /* 0x73 */
    0x00, /* 0x74 */
    0x00, /* 0x75 */
    0x00, /* 0x76 */
    0x01, /* 0x77 */
    0x0f, /* 0x78 : SD_CONFIG__WOI_ON */
    0x0d, /* 0x79 : SD_CONFIG__INITIAL_PHASE_KEEP */
    0x0e, /* 0x7a */
    0x0e, /* 0x7b */
    0x00, /* 0x7c */
    0x00, /* 0x7d */
    0x02, /* 0x7e */
    0xc7, /* 0x7f : ROI_CONFIG__USER_ROI_CENTRE_SPAD */
    0xff, /* 0x80 : ROI_CONFIG__USER_ROI_REQUESTED_GLOBAL_XY */
    0x9B, /* 0x81 */
    0x00, /* 0x82 */
    0x00, /* 0x83 */
    0x00, /* 0x84 */
    0x01, /* 0x85 : SYSTEM__ENABLE_XTALK_PER_QUADRANT */
    0x00, /* 0x86 : SYSTEM__INTERRUPT_CLEAR */
    0x00  /* 0x87 : SYSTEM__MODE_START */
};

VL53L1X_ERROR VL53L1X_GetDriverVersion(uint8_t *major, uint8_t *minor, uint8_t *build, uint8_t *revision) {
    *major = VL53L1X_IMPLEMENTATION_VER_MAJOR;
    *minor = VL53L1X_IMPLEMENTATION_VER_MINOR;
    *build = VL53L1X_IMPLEMENTATION_VER_SUB;
    *revision = VL53L1X_IMPLEMENTATION_VER_REVISION;
    return VL53L1_ERROR_NONE;
}

VL53L1X_ERROR VL53L1X_SetI2CAddress(uint16_t dev, uint8_t new_address) {
    VL53L1X_ERROR status = VL53L1_ERROR_NONE;
    status |= VL53L1_WrByte(dev, VL53L1_I2C_SLAVE__DEVICE_ADDRESS, (uint8_t)(new_address >> 1));
    return status;
}

VL53L1X_ERROR VL53L1X_BootState(uint16_t dev, uint8_t *state) {
    VL53L1X_ERROR status = VL53L1_ERROR_NONE;
    uint8_t tmp = 0;
    status |= VL53L1_RdByte(dev, 0x010F, &tmp); // MODEL_ID
    *state = (tmp == 0xEA) ? 1 : 0;
    return status;
}

VL53L1X_ERROR VL53L1X_SensorInit(uint16_t dev) {
    VL53L1X_ERROR status = VL53L1_ERROR_NONE;
    uint8_t Addr = 0x00, tmp = 0;

    for (Addr = 0x2D; Addr <= 0x87; Addr++) {
        status |= VL53L1_WrByte(dev, Addr, VL53L1X_DEFAULT_CONFIGURATION[Addr - 0x2D]);
    }

    status |= VL53L1X_StartRanging(dev);
    tmp = 0;
    while (tmp == 0) {
        status |= VL53L1X_CheckForDataReady(dev, &tmp);
    }
    status |= VL53L1X_ClearInterrupt(dev);
    status |= VL53L1X_StopRanging(dev);

    status |= VL53L1_WrByte(dev, VL53L1_VHV_CONFIG__TIMEOUT_MACROP_LOOP_BOUND, 0x09);
    status |= VL53L1_WrByte(dev, 0x0B, 0); // VHV_CONFIG_INIT
    return status;
}

VL53L1X_ERROR VL53L1X_ClearInterrupt(uint16_t dev) {
    return VL53L1_WrByte(dev, SYSTEM__INTERRUPT_CLEAR, 0x01);
}

VL53L1X_ERROR VL53L1X_SetInterruptPolarity(uint16_t dev, uint8_t IntPol) {
    uint8_t Temp;
    VL53L1_RdByte(dev, GPIO_HV_MUX__CTRL, &Temp);
    Temp = Temp & 0xEF;
    Temp = Temp | (!(IntPol & 1)) << 4;
    return VL53L1_WrByte(dev, GPIO_HV_MUX__CTRL, Temp);
}

VL53L1X_ERROR VL53L1X_GetInterruptPolarity(uint16_t dev, uint8_t *pIntPol) {
    uint8_t Temp;
    VL53L1X_ERROR status = VL53L1_RdByte(dev, GPIO_HV_MUX__CTRL, &Temp);
    Temp = Temp & 0x10;
    *pIntPol = !(Temp >> 4);
    return status;
}

VL53L1X_ERROR VL53L1X_StartRanging(uint16_t dev) {
    return VL53L1_WrByte(dev, SYSTEM__MODE_START, 0x40);
}

VL53L1X_ERROR VL53L1X_StopRanging(uint16_t dev) {
    return VL53L1_WrByte(dev, SYSTEM__MODE_START, 0x00);
}

VL53L1X_ERROR VL53L1X_CheckForDataReady(uint16_t dev, uint8_t *isDataReady) {
    uint8_t Temp;
    uint8_t IntPol;
    VL53L1X_ERROR status = VL53L1X_GetInterruptPolarity(dev, &IntPol);
    status |= VL53L1_RdByte(dev, GPIO__TIO_HV_STATUS, &Temp);
    if (status == 0) {
        if ((Temp & 1) == IntPol)
            *isDataReady = 1;
        else
            *isDataReady = 0;
    }
    return status;
}

VL53L1X_ERROR VL53L1X_SetTimingBudgetInMs(uint16_t dev, uint16_t TimingBudgetInMs) {
    uint16_t DM;
    VL53L1X_ERROR status = VL53L1X_GetDistanceMode(dev, &DM);
    if (DM == 0) return 1;

    if (DM == VL53L1X_DISTANCE_MODE_SHORT) {
        switch (TimingBudgetInMs) {
            case 15:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x01D);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x027);
                break;
            case 20:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x051);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x06E);
                break;
            case 33:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x0D6);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x06E);
                break;
            case 50:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x1AE);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x1E8);
                break;
            case 100:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x2E1);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x388);
                break;
            case 200:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x3E1);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x496);
                break;
            case 500:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x591);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x5C1);
                break;
            default:
                status = 1;
                break;
        }
    } else {
        switch (TimingBudgetInMs) {
            case 20:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x01E);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x022);
                break;
            case 33:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x060);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x06E);
                break;
            case 50:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x0AD);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x0C6);
                break;
            case 100:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x1D9);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x1EA);
                break;
            case 200:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x2D9);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x2F8);
                break;
            case 500:
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, 0x48F);
                VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, 0x4A4);
                break;
            default:
                status = 1;
                break;
        }
    }
    return status;
}

VL53L1X_ERROR VL53L1X_GetTimingBudgetInMs(uint16_t dev, uint16_t *pTimingBudgetInMs) {
    uint16_t Temp;
    VL53L1_RdWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, &Temp);
    switch (Temp) {
        case 0x001D: *pTimingBudgetInMs = 15; break;
        case 0x0051:
        case 0x001E: *pTimingBudgetInMs = 20; break;
        case 0x00D6:
        case 0x0060: *pTimingBudgetInMs = 33; break;
        case 0x01AE:
        case 0x00AD: *pTimingBudgetInMs = 50; break;
        case 0x02E1:
        case 0x01D9: *pTimingBudgetInMs = 100; break;
        case 0x03E1:
        case 0x02D9: *pTimingBudgetInMs = 200; break;
        case 0x0591:
        case 0x048F: *pTimingBudgetInMs = 500; break;
        default: *pTimingBudgetInMs = 0; break;
    }
    return 0;
}

VL53L1X_ERROR VL53L1X_SetDistanceMode(uint16_t dev, uint16_t DistanceMode) {
    uint16_t TB;
    VL53L1X_ERROR status = 0;
    VL53L1X_GetTimingBudgetInMs(dev, &TB);
    if (TB == 0) TB = 50; // Default fallback

    if (DistanceMode == VL53L1X_DISTANCE_MODE_SHORT) {
        status |= VL53L1_WrByte(dev, PHASECAL_CONFIG__TIMEOUT_MACROP, 0x14);
        status |= VL53L1_WrByte(dev, RANGE_CONFIG__VCSEL_PERIOD_A, 0x07);
        status |= VL53L1_WrByte(dev, RANGE_CONFIG__VCSEL_PERIOD_B, 0x05);
        status |= VL53L1_WrByte(dev, RANGE_CONFIG__VALID_PHASE_HIGH, 0x38);
        status |= VL53L1_WrWord(dev, SD_CONFIG__WOI_ON, 0x0705);
        status |= VL53L1_WrWord(dev, SD_CONFIG__INITIAL_PHASE_KEEP, 0x0606);
    } else if (DistanceMode == VL53L1X_DISTANCE_MODE_LONG) {
        status |= VL53L1_WrByte(dev, PHASECAL_CONFIG__TIMEOUT_MACROP, 0x0A);
        status |= VL53L1_WrByte(dev, RANGE_CONFIG__VCSEL_PERIOD_A, 0x0F);
        status |= VL53L1_WrByte(dev, RANGE_CONFIG__VCSEL_PERIOD_B, 0x0D);
        status |= VL53L1_WrByte(dev, RANGE_CONFIG__VALID_PHASE_HIGH, 0xB8);
        status |= VL53L1_WrWord(dev, SD_CONFIG__WOI_ON, 0x0F0D);
        status |= VL53L1_WrWord(dev, SD_CONFIG__INITIAL_PHASE_KEEP, 0x0E0E);
    }
    status |= VL53L1X_SetTimingBudgetInMs(dev, TB);
    return status;
}

VL53L1X_ERROR VL53L1X_GetDistanceMode(uint16_t dev, uint16_t *pDistanceMode) {
    uint8_t Temp;
    VL53L1X_ERROR status = VL53L1_RdByte(dev, PHASECAL_CONFIG__TIMEOUT_MACROP, &Temp);
    if (Temp == 0x14) *pDistanceMode = VL53L1X_DISTANCE_MODE_SHORT;
    else if (Temp == 0x0A) *pDistanceMode = VL53L1X_DISTANCE_MODE_LONG;
    else *pDistanceMode = 0;
    return status;
}

VL53L1X_ERROR VL53L1X_SetInterMeasurementInMs(uint16_t dev, uint32_t InterMeasurementInMs) {
    uint16_t ClockPLL;
    VL53L1_RdWord(dev, 0x0006, &ClockPLL);
    ClockPLL = ClockPLL & 0x3FF;
    uint32_t val = (uint32_t)(ClockPLL * InterMeasurementInMs * 1.075f);
    return VL53L1_WrDWord(dev, SYSTEM__INTERMEASUREMENT_PERIOD, val);
}

VL53L1X_ERROR VL53L1X_GetInterMeasurementInMs(uint16_t dev, uint16_t *pInterMeasurementInMs) {
    uint32_t val = 0;
    uint16_t ClockPLL = 0;
    VL53L1_RdDWord(dev, SYSTEM__INTERMEASUREMENT_PERIOD, &val);
    VL53L1_RdWord(dev, 0x0006, &ClockPLL);
    ClockPLL = ClockPLL & 0x3FF;
    if (ClockPLL > 0) {
        *pInterMeasurementInMs = (uint16_t)(val / (ClockPLL * 1.075f));
    }
    return 0;
}

VL53L1X_ERROR VL53L1X_GetSensorId(uint16_t dev, uint16_t *id) {
    return VL53L1_RdWord(dev, VL53L1_IDENTIFICATION__MODEL_ID, id);
}

VL53L1X_ERROR VL53L1X_GetDistance(uint16_t dev, uint16_t *distance) {
    return VL53L1_RdWord(dev, VL53L1_RESULT__FINAL_CROSSTALK_CORRECTED_RANGE_MM_SD0, distance);
}

VL53L1X_ERROR VL53L1X_GetSignalPerSpad(uint16_t dev, uint16_t *signalPerSp) {
    uint16_t SpNb = 1, signal = 0;
    VL53L1X_ERROR status = VL53L1_RdWord(dev, VL53L1_RESULT__PEAK_SIGNAL_COUNT_RATE_CROSSTALK_CORRECTED_MCPS_SD0, &signal);
    status |= VL53L1_RdWord(dev, VL53L1_RESULT__DSS_ACTUAL_EFFECTIVE_SPADS_SD0, &SpNb);
    if (SpNb > 0) {
        *signalPerSp = (uint16_t)(200.0f * signal / SpNb);
    }
    return status;
}

VL53L1X_ERROR VL53L1X_GetAmbientPerSpad(uint16_t dev, uint16_t *amb) {
    uint16_t SpNb = 1, AmbRate = 0;
    VL53L1X_ERROR status = VL53L1_RdWord(dev, VL53L1_RESULT__AMBIENT_COUNT_RATE_MCPS_SD0, &AmbRate);
    status |= VL53L1_RdWord(dev, VL53L1_RESULT__DSS_ACTUAL_EFFECTIVE_SPADS_SD0, &SpNb);
    if (SpNb > 0) {
        *amb = (uint16_t)(200.0f * AmbRate / SpNb);
    }
    return status;
}

VL53L1X_ERROR VL53L1X_GetSignalRate(uint16_t dev, uint16_t *signalRate) {
    uint16_t signal = 0;
    VL53L1X_ERROR status = VL53L1_RdWord(dev, VL53L1_RESULT__PEAK_SIGNAL_COUNT_RATE_CROSSTALK_CORRECTED_MCPS_SD0, &signal);
    *signalRate = signal * 8;
    return status;
}

VL53L1X_ERROR VL53L1X_GetSpadNb(uint16_t dev, uint16_t *spNb) {
    uint16_t SpNb = 0;
    VL53L1X_ERROR status = VL53L1_RdWord(dev, VL53L1_RESULT__DSS_ACTUAL_EFFECTIVE_SPADS_SD0, &SpNb);
    *spNb = SpNb >> 8;
    return status;
}

VL53L1X_ERROR VL53L1X_GetAmbientRate(uint16_t dev, uint16_t *ambRate) {
    uint16_t amb = 0;
    VL53L1X_ERROR status = VL53L1_RdWord(dev, VL53L1_RESULT__AMBIENT_COUNT_RATE_MCPS_SD0, &amb);
    *ambRate = amb * 8;
    return status;
}

VL53L1X_ERROR VL53L1X_GetRangeStatus(uint16_t dev, uint8_t *rangeStatus) {
    uint8_t RgSt = 0;
    VL53L1X_ERROR status = VL53L1_RdByte(dev, VL53L1_RESULT__RANGE_STATUS, &RgSt);
    RgSt = RgSt & 0x1F;
    switch (RgSt) {
        case 9:  *rangeStatus = 0; break; // Valid
        case 6:  *rangeStatus = 1; break; // Sigma Fail
        case 4:  *rangeStatus = 2; break; // Signal Fail
        case 7:  *rangeStatus = 4; break; // Out of bounds
        case 12: *rangeStatus = 7; break; // Wrap target
        default: *rangeStatus = 255; break;
    }
    return status;
}

VL53L1X_ERROR VL53L1X_GetResult(uint16_t dev, VL53L1X_Result_t *pResult) {
    uint8_t buffer[17];
    VL53L1X_ERROR status = VL53L1_ReadMulti(dev, VL53L1_RESULT__RANGE_STATUS, buffer, 17);
    if (status == 0) {
        uint8_t RgSt = buffer[0] & 0x1F;
        switch (RgSt) {
            case 9:  pResult->Status = 0; break;
            case 6:  pResult->Status = 1; break;
            case 4:  pResult->Status = 2; break;
            case 7:  pResult->Status = 4; break;
            case 12: pResult->Status = 7; break;
            default: pResult->Status = 255; break;
        }
        pResult->AmbientRate = ((uint16_t)buffer[7] << 8) | buffer[8];
        pResult->NumSPADs = buffer[3];
        pResult->SigPerSPAD = ((uint16_t)buffer[15] << 8) | buffer[16];
        pResult->Distance = ((uint16_t)buffer[13] << 8) | buffer[14];
    }
    return status;
}

VL53L1X_ERROR VL53L1X_SetOffset(uint16_t dev, int16_t OffsetValue) {
    return VL53L1_WrWord(dev, ALGO__PART_TO_PART_RANGE_OFFSET_MM, (uint16_t)(OffsetValue * 4));
}

VL53L1X_ERROR VL53L1X_GetOffset(uint16_t dev, int16_t *Offset) {
    uint16_t Temp;
    VL53L1X_ERROR status = VL53L1_RdWord(dev, ALGO__PART_TO_PART_RANGE_OFFSET_MM, &Temp);
    *Offset = (int16_t)(Temp / 4);
    return status;
}

VL53L1X_ERROR VL53L1X_SetXtalk(uint16_t dev, uint16_t XtalkValue) {
    return VL53L1_WrWord(dev, ALGO__CROSSTALK_COMPENSATION_PLANE_OFFSET_KCPS, (uint16_t)(XtalkValue * 512 / 1000));
}

VL53L1X_ERROR VL53L1X_GetXtalk(uint16_t dev, uint16_t *Xtalk) {
    uint16_t Temp;
    VL53L1X_ERROR status = VL53L1_RdWord(dev, ALGO__CROSSTALK_COMPENSATION_PLANE_OFFSET_KCPS, &Temp);
    *Xtalk = (uint16_t)(Temp * 1000 / 512);
    return status;
}

VL53L1X_ERROR VL53L1X_SetROI(uint16_t dev, uint16_t X, uint16_t Y) {
    uint8_t OpticalCenter;
    if (X > 16) X = 16;
    if (Y > 16) Y = 16;
    if (X < 4) X = 4;
    if (Y < 4) Y = 4;
    VL53L1_RdByte(dev, ROI_CONFIG__USER_ROI_CENTRE_SPAD, &OpticalCenter);
    uint8_t XY = (uint8_t)(((Y - 1) << 4) | (X - 1));
    return VL53L1_WrByte(dev, ROI_CONFIG__USER_ROI_REQUESTED_GLOBAL_XY, XY);
}

VL53L1X_ERROR VL53L1X_GetROI_XY(uint16_t dev, uint16_t *ROI_X, uint16_t *ROI_Y) {
    uint8_t tmp;
    VL53L1X_ERROR status = VL53L1_RdByte(dev, ROI_CONFIG__USER_ROI_REQUESTED_GLOBAL_XY, &tmp);
    *ROI_X = (tmp & 0x0F) + 1;
    *ROI_Y = ((tmp >> 4) & 0x0F) + 1;
    return status;
}

VL53L1X_ERROR VL53L1X_SetROICenter(uint16_t dev, uint8_t ROICenter) {
    return VL53L1_WrByte(dev, ROI_CONFIG__USER_ROI_CENTRE_SPAD, ROICenter);
}

VL53L1X_ERROR VL53L1X_GetROICenter(uint16_t dev, uint8_t *ROICenter) {
    return VL53L1_RdByte(dev, ROI_CONFIG__USER_ROI_CENTRE_SPAD, ROICenter);
}

VL53L1X_ERROR VL53L1X_SetSignalThreshold(uint16_t dev, uint16_t signal) {
    return VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, signal >> 3);
}

VL53L1X_ERROR VL53L1X_GetSignalThreshold(uint16_t dev, uint16_t *signal) {
    uint16_t tmp;
    VL53L1X_ERROR status = VL53L1_RdWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_B_HI, &tmp);
    *signal = tmp << 3;
    return status;
}

VL53L1X_ERROR VL53L1X_SetSigmaThreshold(uint16_t dev, uint16_t sigma) {
    if (sigma > (0xFFFF >> 2)) return 1;
    return VL53L1_WrWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, sigma << 2);
}

VL53L1X_ERROR VL53L1X_GetSigmaThreshold(uint16_t dev, uint16_t *sigma) {
    uint16_t tmp;
    VL53L1X_ERROR status = VL53L1_RdWord(dev, RANGE_CONFIG__TIMEOUT_MACROP_A_HI, &tmp);
    *sigma = tmp >> 2;
    return status;
}

VL53L1X_ERROR VL53L1X_StartTemperatureUpdate(uint16_t dev) {
    VL53L1X_ERROR status = 0;
    status |= VL53L1_WrByte(dev, VL53L1_VHV_CONFIG__TIMEOUT_MACROP_LOOP_BOUND, 0x81);
    status |= VL53L1_WrByte(dev, 0x0B, 0x92);
    status |= VL53L1X_StartRanging(dev);
    uint8_t tmp = 0;
    while (tmp == 0) {
        status |= VL53L1X_CheckForDataReady(dev, &tmp);
    }
    status |= VL53L1X_ClearInterrupt(dev);
    status |= VL53L1X_StopRanging(dev);
    status |= VL53L1_WrByte(dev, VL53L1_VHV_CONFIG__TIMEOUT_MACROP_LOOP_BOUND, 0x09);
    status |= VL53L1_WrByte(dev, 0x0B, 0);
    return status;
}
