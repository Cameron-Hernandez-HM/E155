// STM32L432KC_GPIO.c
// Cameron Hernandez
// cahernandez@g.hmc.edu
// 10/2/2025
// Source code for GPIO functions

#include "STM32L432KC_GPIO.h"

void pinMode(int pin, int function) {
    switch(function) {
        case GPIO_INPUT:
            GPIO->MODER &= ~(0b11 << 2*pin);
            break;
        case GPIO_OUTPUT:
            GPIO->MODER |= (0b1 << 2*pin);
            GPIO->MODER &= ~(0b1 << (2*pin+1));
            break;
        case GPIO_ALT:
            GPIO->MODER &= ~(0b1 << 2*pin);
            GPIO->MODER |= (0b1 << (2*pin+1));
            break;
        case GPIO_ANALOG:
            GPIO->MODER |= (0b11 << 2*pin);
            break;
    }
}

int digitalRead(int pin) {
    return ((GPIO->IDR) >> pin) & 1;
}

void digitalWrite(int pin, int val) {
    GPIO->ODR |= (1 << pin);
}

void togglePin(int pin) {
    // Use XOR to toggle
    GPIO->ODR ^= (1 << pin);
}

void enablePWM(void){
    pinMode(6, GPIO_ALT);
    
    // Set Pin mode of what ever GPIO  1110: AF14
    GPIO->AFRL |= (0b1110 <<24);

    // Push Pull on OTYPER to allow current to flow in and out (PWM goes high and low)
    GPIO->OTYPER &= ~(0b1 <<6);
}