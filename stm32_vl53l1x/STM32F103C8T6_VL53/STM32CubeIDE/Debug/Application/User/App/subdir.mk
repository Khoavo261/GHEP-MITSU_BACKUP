################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/VL53L.c \
D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/VL53L1X_api.c \
D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/VL53L1X_calibration.c \
D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/can_vl53.c \
D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/oled_ssd1306.c \
D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/plc_mitsu.c \
D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/vl53l1_platform.c 

OBJS += \
./Application/User/App/VL53L.o \
./Application/User/App/VL53L1X_api.o \
./Application/User/App/VL53L1X_calibration.o \
./Application/User/App/can_vl53.o \
./Application/User/App/oled_ssd1306.o \
./Application/User/App/plc_mitsu.o \
./Application/User/App/vl53l1_platform.o 

C_DEPS += \
./Application/User/App/VL53L.d \
./Application/User/App/VL53L1X_api.d \
./Application/User/App/VL53L1X_calibration.d \
./Application/User/App/can_vl53.d \
./Application/User/App/oled_ssd1306.d \
./Application/User/App/plc_mitsu.d \
./Application/User/App/vl53l1_platform.d 


# Each subdirectory must supply rules for building sources it contributes
Application/User/App/VL53L.o: D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/VL53L.c Application/User/App/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../../Core/Inc -I../../App/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../../Middlewares/Third_Party/FreeRTOS/Source/include -I../../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2 -I../../Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3 -I../../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/User/App/VL53L1X_api.o: D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/VL53L1X_api.c Application/User/App/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../../Core/Inc -I../../App/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../../Middlewares/Third_Party/FreeRTOS/Source/include -I../../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2 -I../../Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3 -I../../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/User/App/VL53L1X_calibration.o: D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/VL53L1X_calibration.c Application/User/App/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../../Core/Inc -I../../App/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../../Middlewares/Third_Party/FreeRTOS/Source/include -I../../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2 -I../../Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3 -I../../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/User/App/can_vl53.o: D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/can_vl53.c Application/User/App/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../../Core/Inc -I../../App/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../../Middlewares/Third_Party/FreeRTOS/Source/include -I../../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2 -I../../Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3 -I../../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/User/App/oled_ssd1306.o: D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/oled_ssd1306.c Application/User/App/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../../Core/Inc -I../../App/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../../Middlewares/Third_Party/FreeRTOS/Source/include -I../../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2 -I../../Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3 -I../../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/User/App/plc_mitsu.o: D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/plc_mitsu.c Application/User/App/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../../Core/Inc -I../../App/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../../Middlewares/Third_Party/FreeRTOS/Source/include -I../../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2 -I../../Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3 -I../../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/User/App/vl53l1_platform.o: D:/data-2026/lap_top/GHEP-MITSU_BACKUP/stm32_vl53l1x/STM32F103C8T6_VL53/App/Src/vl53l1_platform.c Application/User/App/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../../Core/Inc -I../../App/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../../Middlewares/Third_Party/FreeRTOS/Source/include -I../../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2 -I../../Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM3 -I../../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Application-2f-User-2f-App

clean-Application-2f-User-2f-App:
	-$(RM) ./Application/User/App/VL53L.cyclo ./Application/User/App/VL53L.d ./Application/User/App/VL53L.o ./Application/User/App/VL53L.su ./Application/User/App/VL53L1X_api.cyclo ./Application/User/App/VL53L1X_api.d ./Application/User/App/VL53L1X_api.o ./Application/User/App/VL53L1X_api.su ./Application/User/App/VL53L1X_calibration.cyclo ./Application/User/App/VL53L1X_calibration.d ./Application/User/App/VL53L1X_calibration.o ./Application/User/App/VL53L1X_calibration.su ./Application/User/App/can_vl53.cyclo ./Application/User/App/can_vl53.d ./Application/User/App/can_vl53.o ./Application/User/App/can_vl53.su ./Application/User/App/oled_ssd1306.cyclo ./Application/User/App/oled_ssd1306.d ./Application/User/App/oled_ssd1306.o ./Application/User/App/oled_ssd1306.su ./Application/User/App/plc_mitsu.cyclo ./Application/User/App/plc_mitsu.d ./Application/User/App/plc_mitsu.o ./Application/User/App/plc_mitsu.su ./Application/User/App/vl53l1_platform.cyclo ./Application/User/App/vl53l1_platform.d ./Application/User/App/vl53l1_platform.o ./Application/User/App/vl53l1_platform.su

.PHONY: clean-Application-2f-User-2f-App

