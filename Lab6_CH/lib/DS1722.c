/*
File: Lab_6_JHB.c
Author: Cameron Hernandez
Email: cahernandez@hmc.edu
Date: 10/21/25
Description: The Digital Temperature Sensor Driver Code
*/

#include "DS1722.h"

// Assuming these driver headers are available globally for the functions they provide
#include "STM32L432KC_GPIO.h" // For digitalWrite()
#include "STM32L432KC_SPI.h"  // For spiSendReceive()
#include "STM32L432KC_TIM.h"  // For delay_millis()

// The logic below was moved from main.c

float getTemperatureFromSensor(int resolution_config, TIM_TypeDef *timer_base) {

    // 1. Write the Configuration Register to set temperature resolution
    
    // Activate Chip Enable (PA8)
    digitalWrite(DS1722_CS_PIN, PIO_HIGH);

    spiSendReceive(0x80); // Send write address of 80h for config register
    spiSendReceive(resolution_config); // Send config bits (resolution)

    // Toggle chip enable to end write sequence
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    digitalWrite(DS1722_CS_PIN, PIO_HIGH);
    
    // 2. Read MSB of temperature
    spiSendReceive(0x02); // Send address to read Temperature MSB (0x02)
    char tempmsb = spiSendReceive(0x00); // Receive temp MSB
    
    // Toggle chip enable
    digitalWrite(DS1722_CS_PIN, PIO_LOW);
    digitalWrite(DS1722_CS_PIN, PIO_HIGH);

    // 3. Read LSB of temperature
    spiSendReceive(0x01); // Send address to read Temperature LSB (0x01)
    int templsb = spiSendReceive(0x00); // Receive temp LSB

    // Toggle chip enable to finish the read sequence
    digitalWrite(DS1722_CS_PIN, PIO_LOW);

    // Required delay before next read (120ms for 12-bit conversion time)
    delay_millis(timer_base, 120); 

    // 4. Conversion logic (12-bit result)
    float temperature;
    int sign = (tempmsb & 0b10000000); 
    
    // Check sign bit (bit 7 of MSB)
    if (!sign){ // Positive temperature
        temperature = tempmsb & 0b01111111; // 7 bits of integer part
        // Add fractional part from LSB
        if(1 << 7 & templsb) temperature += 0.5;
        if(1 << 6 & templsb) temperature += 0.25;
        if(1 << 5 & templsb) temperature += 0.125;
        if(1 << 4 & templsb) temperature += 0.0625;
    } 
    else { // Negative temperature (2's complement)
        temperature = -128 + (tempmsb & 0b01111111);
        // Subtract fractional part
        if(1 << 7 & templsb) temperature -= 0.5;
        if(1 << 6 & templsb) temperature -= 0.25;
        if(1 << 5 & templsb) temperature -= 0.125;
        if(1 << 4 & templsb) temperature -= 0.0625;
    }

    return temperature;
}
