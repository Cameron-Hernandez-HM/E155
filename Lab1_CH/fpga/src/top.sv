/*/
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/03/2025
	
	This file contains the top module which controls three LEDs and calls the seven segment display function
	
	Inputs: s[3:0] where s = {P37, P31, P35, P32} Assigned Pin
	Output1: led[2:0] where led = {}
	Outputs: seg[7:0] where seg = {A_P3, B_P45, C_P20, D_P12, E_P18, F_P44, G_P9} Segment name and its assigned Pin
	
*/

module top(
	input logic  [3:0] s,	// The four DIP switches (on the board, SW6)
	output logic [6:0] seg,	// The segments of a common-anode 7-segment display
	output logic [2:0] led	// 3 LEDs
);

	logic intOsc;
	logic ledState = 0;
	logic [24:0] counter = 0;
	
	// Internal high-speed oscillator
	HSOSC #(.CLKHF_DIV(2'b01)) 
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(intOsc));
	
	// Simple clock divider
	always_ff @(posedge intOsc)
		begin
			counter <= counter + 1;
			if (counter >= 23'd5000000)begin // Using 48, thus 2.4 Hz would require a 10000000 counter
				ledState = ~ledState;
				counter <= 23'd0;
			end
		end
	
	// Assign the LEDs
	assign led[2] = ledState; // 2.4Hz LED
	assign led[1] = s[3] & s[2]; // The AND gate LED
	assign led[0] = s[1] ^ s[0]; // The OR gate LED
	
	//Call the 4 input to hex seven segment display 
	segmentDisp sd1(s, seg);

endmodule