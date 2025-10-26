/*
File: Lab_6_JHB.c
Author: Cameron Hernandez
Email: cahernandez@hmc.edu
Date: 10/21/25
Description: The Digital Temperature Sensor Driver Code
*/

#include "DS1722.h"

float getTemperatureFromSensor(int resolution_config) {

    // --- 1. Start Conversion (Write Configuration Register - Transaction 1) ---
    // Ensure the RUN bit (bit 0, value 0x01) is set to command a new conversion.
    //int config_byte_with_run = (resolution_config < 1) | 0xe0; 
    int config_byte_with_run = resolution_config;

    // START WRITE TRANSACTION (CS LOW)
    digitalWrite(SPI_CE, PIO_HIGH); 

    spiSendReceive(0x80); // Send write address of 0x80 for config register
    spiSendReceive(config_byte_with_run); // Send config bits (resolution + RUN bit)
    int val = spiSendReceive(0x00);
    // END WRITE TRANSACTION (CS HIGH)
    digitalWrite(SPI_CE, PIO_LOW);

    // --- 2. Read Temperature MSB (Transaction 2) ---

    // START MSB READ (CS LOW)
    digitalWrite(SPI_CE, PIO_HIGH);

    spiSendReceive(0x02); // Send address to read Temperature MSB (0x02)
    
    // <-- FIX 1: Changed 'char' to 'unsigned char' to prevent sign extension
    uint8_t tempmsb = spiSendReceive(0x00); // Receive temp MSB
    
    // END MSB READ (CS HIGH)
    digitalWrite(SPI_CE, PIO_LOW); // This toggles the CS pin, which is necessary.

    // --- 3. Read Temperature LSB (Transaction 3) ---

    // START LSB READ (CS LOW)
    digitalWrite(SPI_CE, PIO_HIGH);

    spiSendReceive(0x01); // Send address to read Temperature LSB (0x01)
    
    uint8_t templsb = spiSendReceive(0x00); // Receive temp LSB 

    // END LSB READ (CS HIGH)
    digitalWrite(SPI_CE, PIO_LOW);

    // --- 4. Conversion logic (12-bit result) ---
    
    // Combine 12 relevant bits: MSB(7:0) shifted left 4 bits, OR'd with LSB(7:4) shifted right 4 bits
    // The (unsigned char) casts ensure the 'tempmsb' and 'templsb' are treated as unsigned
    // before being promoted to 'int' for the bitwise operations.
    uint16_t value12_bit_unified = (tempmsb << 4) | (templsb >> 4);
    

    // Check if the 12th bit (bit 11, the sign bit) is set
    if (value12_bit_unified & 0x0200) { 
        // If it's negative, manually sign-extend the 12-bit value to 16 bits
        // by setting the upper 4 bits to 1.
        value12_bit_unified |= 0xF000;
    }
    
    // The DS1722 resolution is 1/16th degree C, so we divide the raw value by 16.0
    float temperature = (float)value12_bit_unified / 16.0f;

    printf("Raw MSB=0x%02X, LSB=0x%02X\n", tempmsb, templsb);
    
    return temperature;
}
