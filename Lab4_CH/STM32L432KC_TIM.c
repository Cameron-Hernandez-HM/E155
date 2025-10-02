// STM32L432KC_RCC.c
// Cameron Hernandez
// cahernandez@g.hmc.edu
// 10/2/2025
// Source code for TIM functions


#include "STM32L432KC_TIM.h"


void configureTIM15(void){
    // Disable ctrl reg 1
    TIM15->TIM15_CR1 &= ~(0b1);
    
    // Auto Reload register
    TIM15->TIM15_CR1 &= ~(0b1 << 7);
    
    // Enable internal clock (First three bits & bit 16 of the SMCR register need to be set to 0 to cloclk directly by the internal clock) 
    TIM15->TIM15_SMCR &= ~(0b1 << 16);
    TIM15->TIM15_SMCR &= ~(0b111);

    // Disable inturupts
    TIM15->TIM15_DIER &= ~(0b1);

    // PSC prescaler 
    TIM15->TIM15_PSC = 999; // fCK_PSC / (PSC[15:0] + 1) aiming for 200 micro seconds so the prescaler needs to be 999 in binary

    // Set the auto reload register
    TIM15->TIM15_ARR = 0;

    // TIM15_ARR set to 20 
    TIM15->TIM15_ARR = 10;

    // Update event generation and control register 
    TIM15->TIM15_EGR |= (0b1);
    TIM15->TIM15_CR1 |= (0b1);
}

void delay(uint32_t ms){
    // Set count to zero
    TIM15->TIM15_CNT = 0;
    
    // Clear flag
    TIM15->TIM15_SR &= ~(0b1);

    // Length we want to delay for
    TIM15->TIM15_ARR = 10 * ms;

    // Delay
    while ((TIM15->TIM15_SR & 1) == 0);
    
    // Set UIF back to zero
    TIM15->TIM15_SR &= ~(0b1); 

}


void configureTIM16(void){
    // Disable ctrl reg 1
    TIM16->TIM16_CR1 &= ~(0b1);

    // Enable the CCR preload register
    TIM16->TIM16_CCMR1 |= (0b1 << 3);
    
    // Enable PWM mode 1 (0110)
    // Set bit 16 to zero
    TIM16->TIM16_CCMR1 &= ~(0b1 << 16);
    // Set bit 6 through 4 to 110
    TIM16->TIM16_CCMR1 |= (0b110 << 4);

    // Set ARP in CR1 to 1
    TIM16->TIM16_CR1 |= (0b1 << 7);

    // Set polarity as active high
    TIM16->TIM16_CCER &= ~ (0b1 << 1);
    
    // Enable CC1E pull value from counter into capture compare register
    TIM16->TIM16_CCER |= (0b1);

    // Enable OC1 output
    // MOE
    TIM16->TIM16_BDTR |= (0b1 << 15);

    // Initialize EGR registers 
    TIM16->TIM16_EGR |= (0b1);
}

void defineDutyFreq(uint32_t inputFreq){
    // Disable ctrl reg 1
    TIM16->TIM16_CR1 &= ~(0b1);

    uint32_t val = ((5*(1e6)*2)/inputFreq)-1;
    
    // Frequency
    TIM16->TIM16_ARR = val;

    // Enable CEN in CR1
    TIM16->TIM16_CR1 |= (0b1);

    // Duty cycle 
    TIM16->TIM16_CCR1 = val/2;

    // Update register 
    TIM16->TIM16_EGR |= (0b1);
}