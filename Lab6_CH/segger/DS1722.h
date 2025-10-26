/*
File: Lab_6_JHB.c
Author: Cameron Hernandez
Email: cahernandez@hmc.edu
Date: 10/21/25
Description: Header for the DS1722 Digital Temperature Sensor Driver
*/

#ifndef DS1722_H
#define DS1722_H

#include "stm32l432xx.h"
#include <stdint.h>
#include "STM32L432KC_GPIO.h" // For digitalWrite()
#include "STM32L432KC_SPI.h"  // For spiSendReceive()
#include "STM32L432KC_TIM.h"  // For delay_millis()

#include <stdio.h>

// Define the Chip Select pin used by the sensor (now using the macro from STM32L432KC_SPI.h)
#define SPI_CE PA5

/*
 * @brief Reads the temperature from the DS1722 sensor using SPI.
 *
 * This function handles all necessary SPI communication (write config, read MSB/LSB)
 * and performs the 2's complement conversion to floating-point Celsius.
 *
 * @param resolution_config: The configuration byte for the resolution (output of updateTempResolution).
 * @param timer_base: The initialized TIM base address for the delay_millis function (e.g., TIM15).
 * @return The temperature reading in degrees Celsius (float).
 */

float getTemperatureFromSensor(int resolution_config);

#endif // DS1722_H
