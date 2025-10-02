// STM32L432KC_RCC.c
// Source code for RCC functions

#include "STM32L432KC_TIM.h"


void configureTIM15(){
    // Enable ctrl reg 1
    TIM15->TIM15_CR1 &= ~(0b1);
    
    // Auto Reload register
    TIM15->TIM15_CR1 &= ~(0b1 << 7);
    
    // Enable internal clock (First three bits & bit 16 of the SMCR register need to be set to 0 to cloclk directly by the internal clock) 
    TIM15->TIM15_SMCR &= ~(0b1 << 16);
    TIM15->TIM15_SMCR &= ~(0b111);

    // PSC prescaler 
    TIM15->TIM15_PSC = 999; // fCK_PSC / (PSC[15:0] + 1) aiming for 200 micro seconds so the prescaler needs to be 999 in binary

    // Set the auto reload register
    TIM15->TIM15_ARR = 0;

    // TIM15_ARR set to 5 
    TIM15->TIM15_ARR = 5;

    // Update event generation and control register 
    TIM15->TIM15_EGR |= (0b1);
    TIM15->TIM15_CR1 |= (0b1);
}

void delay(uint32_t ms){

    // Set count to zero
    TIM15->TIM15_CNT = 0;

    // Length we want to delay for
    TIM15->TIM15_ARR = 5 * ms;

    // Delay
    while ((TIM15->TIM15_SR & 1) == 0);
    
    // Set UIF back to zero
    TIM15->TIM15_SR &= ~(0b1); 

}


void configureTIM16(){
    TIM16->TIM16_CR1 &= ~(0b1);
    
    TIM16->TIM16_CR1 &= ~(0b1 << 7);
    
    // Enable internal clock (First three bits & bit 16 of the SMCR register need to be set to 0 to cloclk directly by the internal clock) 
    TIM16->TIM16_SMCR &= ~(0b1 << 16);
    TIM16->TIM16_SMCR &= ~(0b111);
}



void configureTIMClock(){
    // Configure and turn on TIM15
    configureTIM15();

    // Select PLL as clock source
    RCC->CFGR |= (0b11 << 0);
    while(!((RCC->CFGR >> 2) & 0b11));
}