/*/
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/11/2025
	
	This file contains the module clkWorld that divides the clock and has it run at 60MHz
	
	Inputs: intOsc
	Outputs: seg[7:0] where seg = {A_P3, B_P45, C_P20, D_P12, E_P18, F_P44, G_P9} Segment name and its assigned Pin
	
*/

module clkWorld(
	input logic intOsc,
	output logic ledState
);
	
	logic [24:0] counter = 0;

	// Simple clock divider
	always_ff @(posedge intOsc) begin
		counter <= counter + 1;
		if (counter >= 23'd60000)begin // Using 48, thus 2.4 Hz would require a 10000000 counter
			ledState = ~ledState;
			counter <= 23'd0;
		end
	end



endmodule