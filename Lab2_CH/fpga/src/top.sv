/*/
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/11/2025
	
	This file contains the top module which controls three LEDs and calls the seven segment display function
	
	Inputs: s[3:0] where s = {P37, P31, P35, P32} Assigned Pin
	Output1: led[2:0] where led = {}
	Outputs: seg[7:0] where seg = {A_P3, B_P45, C_P20, D_P12, E_P18, F_P44, G_P9} Segment name and its assigned Pin

*/

module top(
	input logic  [3:0]	s0, s1,				// The four DIP switches (on the board, SW6)
	output logic [6:0]	seg,				// The segments of a common-anode 7-segment display
	output logic 	  	enable0, enable1,	// Controls which PNP is enabled
	output logic [4:0]	ledSum				// 5 LEDs which display the sum of the two dipswtich configuration
);

	logic intOsc;
	logic [3:0] tempSwitch;
	logic ledState;
	
	// Internal high-speed oscillator
	HSOSC #(.CLKHF_DIV(2'b11)) // 6MHz
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(intOsc));
	
	// Call the clkWorld that handles the osillation 
	clkWorld clockDivider(intOsc, ledState);
	
	// Alternate between Dip Switch 1 and 2
	assign tempSwitch = ledState? s0: s1;
	
	// Alternate between the PNPs
	assign enable0 = ~ledState;
	assign enable1 = ledState;
	
	// Assign the LEDs
	assign ledSum = ~(s0 + s1); // Need a Not Gate here because they system is active low
	
	//Call the 4 input to hex seven segment display 
	segmentDisp segmentToggle(tempSwitch, seg);

endmodule