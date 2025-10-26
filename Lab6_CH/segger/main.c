/*
File: Lab_6_JHB.c
Author: Cameron Hernandez
Email: cahernandez@hmc.edu
Date: 10/21/25
Description: The main header code for lab6
*/


#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "main.h"
#include "stm32l432xx.h"
#include "DS1722.h" // Include the header for the temperature sensor module

/////////////////////////////////////////////////////////////////
// Provided Constants and Functions
/////////////////////////////////////////////////////////////////

//Defining the web page in two chunks: everything before the current time, and everything after the current time
char* webpageStart = "<!DOCTYPE html><html><head><title>E155 Web Server Demo Webpage</title>\
	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\
	</head>\
	<body><h1>E155 Web Server Demo Webpage</h1>";
char* ledStr = "<p>LED Control:</p><form action=\"ledon\"><input type=\"submit\" value=\"Turn the LED on!\"></form>\
	<form action=\"ledoff\"><input type=\"submit\" value=\"Turn the LED off!\"></form>";
char* webpageEnd   = "</body></html>";
char* tempfunc = "<p>Select Temperature Resolution:</p>\
  <form action=\"8bit\"><input type=\"submit\" value=\"8-bit Resolution\"></form>\
  <form action=\"9bit\"><input type=\"submit\" value=\"9-bit Resolution\"></form>\
  <form action=\"10bit\"><input type=\"submit\" value=\"10-bit Resolution\"></form>\
  <form action=\"11bit\"><input type=\"submit\" value=\"11-bit Resolution\"></form>\
  <form action=\"12bit\"><input type=\"submit\" value=\"12-bit Resolution\"></form>";


// Set global variables
int br = 0b111;  
int cpol = 0;
int cpha = 1;
int pastConfig = 8;

int temp_resolution = 0b11100000;

//determines whether a given character sequence is in a char array request, returning 1 if present, -1 if not present
int inString(char request[], char des[]) {
	if (strstr(request, des) != NULL) {return 1;}
	return -1;
}

int updateLEDStatus(char request[])
{
	int led_status = 0;
	// The request has been received. now process to determine whether to turn the LED on or off
	if (inString(request, "ledoff")==1) {
		digitalWrite(LED_PIN, PIO_LOW);
		led_status = 0;
	}
	else if (inString(request, "ledon")==1) {
		digitalWrite(LED_PIN, PIO_HIGH);
		led_status = 1;
	}

	return led_status;
}

// determines configuration bits based on user selected temperatue resolution 
int updateTempResolution(char request[]){
//int temp_resolution = 0b11100000; // default in 8 bit
  if (inString(request, "8bit")== 1) {
		temp_resolution = 0b11100000;
                pastConfig = 8;
	} else if (inString(request, "9bit")== 1) {
		temp_resolution = 0b11100010;
                pastConfig = 9;
	} else if (inString(request, "10bit")== 1) {
		temp_resolution = 0b11100100;
                pastConfig = 10;
	} else if (inString(request, "11bit")== 1) {
		temp_resolution = 0b11100110;
                pastConfig = 11;
	} else if (inString(request, "12bit")== 1) {
		temp_resolution = 0b11101000;
                pastConfig = 12;
	}

	return temp_resolution;
}

// Function used by printf to send characters to the laptop
int _write(int file, char *ptr, int len) {
  int i = 0;
  for (i = 0; i < len; i++) {
    ITM_SendChar((*ptr++));
  }
  return len;
}

// Main function
int main(void) {
  configureFlash();
  configureClock();

  gpioEnable(GPIO_PORT_A);
  gpioEnable(GPIO_PORT_B);
  gpioEnable(GPIO_PORT_C);

  // Initialize LED pin (PA5)
  pinMode(LED_PIN, GPIO_OUTPUT);
  
  RCC->APB2ENR |= (RCC_APB2ENR_TIM15EN);
  initTIM(TIM15);
  
  USART_TypeDef * USART = initUSART(USART1_ID, 125000);

  // Initialize SPI communication (sets up PB3, PB4, PB5, and PA8)
  initSPI(br, cpol, cpha); 
  
  while(1) {
    /* Wait for ESP8266 to send a request.
    Requests take the form of '/REQ:<tag>\n', with TAG begin <= 10 characters.
    Therefore the request[] array must be able to contain 18 characters.
    */
    printf("starting \n");

    // Receive web request from the ESP
    char request[BUFF_LEN] = "        "; // initialize to known value
    int charIndex = 0;
  
    // Keep going until you get end of line character
    while(inString(request, "\n") == -1) {
      // Wait for a complete request to be transmitted before processing
      while(!(USART->ISR & USART_ISR_RXNE));
      request[charIndex++] = readChar(USART);
    }

    // 1. Get the resolution config from the web request
    int res = updateTempResolution(request);

    // 2. Read the temperature by calling the new function
    float temperature = getTemperatureFromSensor(res);


    // Update string with current LED state
  
    int led_status = updateLEDStatus(request);
    //int resolutionBits = updateTempResolution(request);
    
    char ledStatusStr[20];
    if (led_status == 1)
      sprintf(ledStatusStr,"LED is on!");
    else if (led_status == 0)
      sprintf(ledStatusStr,"LED is off!");

    char temperatureStr[60];
    sprintf(temperatureStr, "Temperature is %.4f Celsius, Configuration is: %d bits", temperature, pastConfig);

    // finally, transmit the webpage over UART
    sendString(USART, webpageStart); // webpage header code
    sendString(USART, ledStr); // button for controlling LED

    sendString(USART, "<h2>LED Status</h2>");


    sendString(USART, "<p>");
    sendString(USART, ledStatusStr);
    sendString(USART, "</p>");

    sendString(USART, "<h2>Temperature Resoultion control </h2>");

    sendString(USART, tempfunc);

    sendString(USART, "<h2>Temperature:</h2>");
    sendString(USART, "<p>");
    sendString(USART, temperatureStr);
    sendString(USART, "<p>");
  
    sendString(USART, webpageEnd);
  }
}


