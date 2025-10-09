// main.h
// Cameron Hernandez
// cahernandez@hmc.edu
// 10/09/25

#ifndef MAIN_H
#define MAIN_H

#include "STM32L432KC.h"
#include <stm32l432xx.h>

///////////////////////////////////////////////////////////////////////////////
// Custom defines
///////////////////////////////////////////////////////////////////////////////

#define PIN_A PA6
#define PIN_B PA8
#define DELAY_TIM TIM2



// Functions
void EXTI9_5_IRQHandler(void);
int main(void);
int _write(int file, char *ptr, int len);

#endif // MAIN_H