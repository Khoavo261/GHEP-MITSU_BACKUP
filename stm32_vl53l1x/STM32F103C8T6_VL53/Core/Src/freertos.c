/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * File Name          : freertos.c
  * Description        : Code for freertos applications
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "FreeRTOS.h"
#include "task.h"
#include "main.h"
#include "cmsis_os.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "VL53L.h"
#include "oled_ssd1306.h"
#include "can_vl53.h"
#include "plc_mitsu.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN Variables */

/* USER CODE END Variables */
/* Definitions for VL53_T */
osThreadId_t VL53_THandle;
const osThreadAttr_t VL53_T_attributes = {
  .name = "VL53_T",
  .stack_size = 256 * 4,
  .priority = (osPriority_t) osPriorityNormal,
};
/* Definitions for CAN_T */
osThreadId_t CAN_THandle;
const osThreadAttr_t CAN_T_attributes = {
  .name = "CAN_T",
  .stack_size = 256 * 4,
  .priority = (osPriority_t) osPriorityNormal,
};
/* Definitions for OLED096_T */
osThreadId_t OLED096_THandle;
const osThreadAttr_t OLED096_T_attributes = {
  .name = "OLED096_T",
  .stack_size = 256 * 4,
  .priority = (osPriority_t) osPriorityLow,
};

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN FunctionPrototypes */

/* USER CODE END FunctionPrototypes */

void VL53_F(void *argument);
void CAN_F(void *argument);
void OLED096_F(void *argument);

void MX_FREERTOS_Init(void); /* (MISRA C 2004 rule 8.1) */

/**
  * @brief  FreeRTOS initialization
  * @param  None
  * @retval None
  */
void MX_FREERTOS_Init(void) {
  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* USER CODE BEGIN RTOS_MUTEX */
  /* add mutexes, ... */
  /* USER CODE END RTOS_MUTEX */

  /* USER CODE BEGIN RTOS_SEMAPHORES */
  /* add semaphores, ... */
  /* USER CODE END RTOS_SEMAPHORES */

  /* USER CODE BEGIN RTOS_TIMERS */
  /* start timers, add new ones, ... */
  /* USER CODE END RTOS_TIMERS */

  /* USER CODE BEGIN RTOS_QUEUES */
  /* add queues, ... */
  /* USER CODE END RTOS_QUEUES */

  /* Create the thread(s) */
  /* creation of VL53_T */
  VL53_THandle = osThreadNew(VL53_F, NULL, &VL53_T_attributes);

  /* creation of CAN_T */
  CAN_THandle = osThreadNew(CAN_F, NULL, &CAN_T_attributes);

  /* creation of OLED096_T */
  OLED096_THandle = osThreadNew(OLED096_F, NULL, &OLED096_T_attributes);

  /* USER CODE BEGIN RTOS_THREADS */
  /* add threads, ... */
  /* USER CODE END RTOS_THREADS */

  /* USER CODE BEGIN RTOS_EVENTS */
  /* add events, ... */
  /* USER CODE END RTOS_EVENTS */

}

/* USER CODE BEGIN Header_VL53_F */
/**
  * @brief  Function implementing the VL53_T thread.
  * @param  argument: Not used
  * @retval None
  */
/* USER CODE END Header_VL53_F */
void VL53_F(void *argument)
{
  /* USER CODE BEGIN VL53_F */
  VL53L_Init();
  /* Infinite loop */
  for(;;)
  {
    VL53L_Task_Sensor();
    osDelay(20);
  }
  /* USER CODE END VL53_F */
}

/* USER CODE BEGIN Header_CAN_F */
/**
* @brief Function implementing the CAN_T thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_CAN_F */
void CAN_F(void *argument)
{
  /* USER CODE BEGIN CAN_F */
  osDelay(100);
  if (MASTER) {
    CAN_VL53_Init(0);
    PLC_Mitsu_Init();
  } else {
    uint8_t hw_node_id = CAN_Read_Hardware_NodeID();
    g_vl53_app.node_id = hw_node_id;
    CAN_VL53_Init(hw_node_id);
  }

  /* Infinite loop */
  for(;;)
  {
    CAN_VL53_Task_Run();
    if (MASTER) {
      PLC_Mitsu_Task_Run();
    }
    osDelay(10);
  }
  /* USER CODE END CAN_F */
}

/* USER CODE BEGIN Header_OLED096_F */
/**
* @brief Function implementing the OLED096_T thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_OLED096_F */
void OLED096_F(void *argument)
{
  /* USER CODE BEGIN OLED096_F */
  osDelay(200);
  OLED_Init();
  /* Infinite loop */
  for(;;)
  {
    OLED_Task_Run();
    osDelay(200);
  }
  /* USER CODE END OLED096_F */
}

/* Private application code --------------------------------------------------*/
/* USER CODE BEGIN Application */

/* USER CODE END Application */

