/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	The top level module for controling a seven segment displaypad using inputs from a keypad
	
	Inputs: clk, reset, row[3:0]
	Output: swL, swR, seg[6:0], col[3:0]

*/
module top(
    input   logic         reset,
    input   logic [3:0]   row,
    output  logic         swL, swR,
    output  logic [6:0]   seg,
    output  logic [3:0]   col);

    logic int_osc, clk, high;
	logic [3:0] rowDataIn;
	logic [7:0] display;
	
	// High Frequency Clock, generates the system clock by dividing the 48MHz internal oscillator (int_osc) down to 1kHz (clk).
	assign high = 1'b1;
    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
    freqGen #(.divisionFactor(48000)) freqGenCall (int_osc, high, clk);
	
    // Drives the segment display by rapidly multiplexing the left and right digits using the fast int_osc clock.
    dualSegmentDisp segDisp(int_osc, ~display, reset, seg, swL, swR);
    
    // The FSM controls the keypad column scanning, processes debounced input, and outputs the decoded digits.
    displayPadFSM dispFSM(clk, reset, rowDataIn, col, display);

	// Synchronizes the asynchronous row inputs (row) to the synchronous clock domain (rowDataIn) to prevent metastability.
    ensureSinglePress singlePress(clk, reset, row, rowDataIn);

endmodule
