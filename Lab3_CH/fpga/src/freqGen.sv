/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	The freqGen module generates a lower-frequency clock signal from a 
	higher-frequency input clock by using a counter to divide the input frequency. 
	It toggles the output desiredFreqOut high or low based on the counter, 
	producing a square wave at approximately half the period of the division factor. 
	The module also supports a synchronous reset to restart the counting process.
	
	Inputs: clk, reset
	Output: desiredFreqOut

*/
module freqGen #(parameter divisionFactor=24000000) (
    input   logic   clk,
    input   logic   reset,
    output  logic   desiredFreqOut
    );
	
    logic [31:0] counter = 0;
    always_ff @(posedge clk)
        if (~(reset)) counter <= 0;
        else if (counter < divisionFactor) counter <= counter + 1;
        else    counter <= 0;
    
    // Get desired one bit frequency output from counter
    always_ff @(posedge clk)
        if (counter > (divisionFactor/2)) desiredFreqOut <= 1;
        else desiredFreqOut <= 0;
endmodule