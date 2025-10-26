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

// Define the Chip Select pin used by the sensor (PA8 in your main.c)
#define DS1722_CS_PIN PA8

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
float getTemperatureFromSensor(int resolution_config, TIM_TypeDef *timer_base);

#endif // DS1722_H
