// button_interrupt.c
// Cameron Hernandez
// cahernandez@hmc.edu
// 10/09/25

#include "main.h"
#include <stdio.h>
#include "stm32l432xx.h"

// GLOBAL VARIABLES
// Variables shared between ISRs and main loop MUST be volatile.
volatile int direction = 0; // 0=Stopped, 1=Clockwise (CW), 2=Counter-Clockwise (CCW)
volatile unsigned long pulseCount = 0; // Total encoder edges counted in the frame
volatile uint8_t A_state = 0; // Current state of A pin (for direction logic)
volatile uint8_t B_state = 0; // Current state of B pin (for direction logic)

// Calculation variables
double RPS = 0.0;
#define FRAME_MS 200 // Time frame in milliseconds (used in main loop delay)
#define DELAY_TIM TIM2 // Use TIM2 for the frame timer as configured
#define EDGES_PER_REVOLUTION 1632 // Assuming 408 PPR encoder (120 * 4 edges/rev)


// Function used by printf to send characters to the laptop
int _write(int file, char *ptr, int len) {
  int i = 0;
  for (i = 0; i < len; i++) {
    ITM_SendChar((*ptr++));
  }
  return len;
}

int main(void) {
    // Enable GIPO ports A & B as inputs
    gpioEnable(GPIO_PORT_A);
    pinMode(PIN_A, GPIO_INPUT);

    //gpioEnable(GPIO_PORT_B);
    pinMode(PIN_B, GPIO_INPUT);

    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD6, 0b01); // Set PA6 as pull-up
    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD8, 0b01); // Set PA8 as pull-up

    // Initialize timer
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
    initTIM(DELAY_TIM);

    // 1. Enable SYSCFG clock domain in RCC
    RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
    // 2. Configure EXTICR for the input button interrupt
    SYSCFG->EXTICR[2] |= _VAL2FLD(SYSCFG_EXTICR2_EXTI6, 0b000); // Select PA6
    SYSCFG->EXTICR[3] |= _VAL2FLD(SYSCFG_EXTICR3_EXTI8, 0b000); // Select PA8

    // Enable interrupts globally
    __enable_irq();

    // Configure interrupt for rising & falling edge of GPIO pin for Pin A
    // 1. Configure mask bit
    EXTI->IMR1 |= (1 << gpioPinOffset(PIN_A)); // Configure the mask bit
    // 2. Enable rising edge trigger
    EXTI->RTSR1 |= (1 << gpioPinOffset(PIN_A));// Enable rising edge trigger
    // 3. Enable falling edge trigger
    EXTI->FTSR1 |= (1 << gpioPinOffset(PIN_A));// Enable falling edge trigger
    // 4. Turn on EXTI interrupt in NVIC_ISER
    NVIC_EnableIRQ(EXTI9_5_IRQn);

    // Configure interrupt for rising & falling edge of GPIO pin for Pin B
    // 1. Configure mask bit
    EXTI->IMR1 |= (1 << gpioPinOffset(PIN_B)); // Configure the mask bit
    // 2. Enable rising edge trigger
    EXTI->RTSR1 |= (1 << gpioPinOffset(PIN_B));// Enable rising edge trigger
    // 3. Enable falling edge trigger
    EXTI->FTSR1 |= (1 << gpioPinOffset(PIN_B));// Enable falling edge trigger
    
    // Pins for scoping
    pinMode(PA10, 1);
    pinMode(PA5,1);

    while (1) {
        digitalWrite(PA10,1);
        printf("HI");
        //delay_millis(DELAY_TIM, FRAME_MS);
        /*
        unsigned long counts_in_frame;
        int current_direction;

        // Disable interrupts to safely read/write shared counter variables
        __disable_irq();
        counts_in_frame = pulseCount;
        current_direction = direction;
        pulseCount = 0; // Reset the counter for the next frame
        __enable_irq();

        // Calculate RPS
        if (counts_in_frame > 0) {
            // RPS = (counts / edges_per_rev) * (1000.0 / FRAME_MS)
            RPS = (double)counts_in_frame / EDGES_PER_REVOLUTION * (1000.0 / (double)FRAME_MS);
        } else {
            RPS = 0.0;
            current_direction = 0; 
        }

        if (RPS == 0.0) {
            printf("Motor is stopped, 0 RPS\n");
        }
        else if (current_direction == 1) {
            printf("Motor spins at: %.2f rev/s, Clockwise\n", RPS); 
        } 
        else if (current_direction == 2) {
            printf("Motor spins at: %.2f rev/s, Counter-Clockwise\n", RPS); 
        } 
        else {
            printf("Motor has not yet started/Direction unknown\n");
        }
        */
        digitalWrite(PA10, 0);
    }

}

// EXTI[9:5] Interrupt Handler (Handles EXTI6 and EXTI8)
void EXTI9_5_IRQHandler(void){
    digitalWrite(PA5,1);
    // Check if EXTI line 6 (PIN_A) is the source of the interrupt
    if (EXTI->PR1 & (1 << 6)){
        
        uint8_t current_A = digitalRead(PIN_A);
        uint8_t current_B = digitalRead(PIN_B); 

        if (current_A != A_state) {
            // Quadrature Logic for A-edge:
            // If the current A state differs from the current B state, it's CW. Otherwise, CCW.
            if (current_A != current_B) {
                 direction = 1; // Clockwise
            } else {
                 direction = 2; // Counter-Clockwise
            }
            
            pulseCount++;
            A_state = current_A; // Update stored state
        }
        
        EXTI->PR1 |= (1 << 6); // Clear the EXTI line 6 pending bit
    }

    // Check if EXTI line 8 (PIN_B) is the source of the interrupt
    if (EXTI->PR1 & (1 << 8)){
        
        uint8_t current_A = digitalRead(PIN_A); 
        uint8_t current_B = digitalRead(PIN_B);

        if (current_B != B_state) {
            // Quadrature Logic for B-edge:
            // The logic reverses for the B-edge interrupt for the same direction.
            if (current_A != current_B) {
                direction = 2; // Counter-Clockwise
            } else {
                direction = 1; // Clockwise
            }

            pulseCount++;
            B_state = current_B; // Update stored state
        }

        EXTI->PR1 |= (1 << 8); // Clear the EXTI line 8 pending bit
    }
    digitalWrite(PA5, 0);
}