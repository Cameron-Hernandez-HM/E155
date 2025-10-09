// STM32L432KC_FLASH.c
// Cameron Hernandez
// cahernandez@hmc.edu
// 10/09/25
// Source code for FLASH functions

#include "STM32L432KC_FLASH.h"

void configureFlash() {
  FLASH->ACR |= FLASH_ACR_LATENCY_4WS;
  FLASH->ACR |= FLASH_ACR_PRFTEN;
} 