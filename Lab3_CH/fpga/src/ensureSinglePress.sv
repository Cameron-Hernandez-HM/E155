/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	The ensureSinglePress module reads the raw 4-bit row inputs from 
	a keypad, converts them into a single-hot, active-high representation, 
	and synchronizes the result to the system clock to avoid metastability. 
	It ensures that only valid single-key presses are captured while filtering 
	out multiple simultaneous presses. The synchronized output rowDataIn provides 
	a stable and safe signal for downstream modules like key decoders or FSMs.
	
	Inputs: clk, reset, row[3:0]
	Output: rowDataIn[3:0]

*/
module ensureSinglePress (
    input  logic       clk, 
    input  logic       reset,
    input  logic [3:0] row,
    output logic [3:0] rowDataIn
);

    logic [3:0] val, sync;

    // Map raw row input to single-hot active-high
    always_comb begin
        case (row)
            4'b0111: val = 4'b1000;
            4'b1011: val = 4'b0100;
            4'b1101: val = 4'b0010;
            4'b1110: val = 4'b0001;
            4'b1111: val = 4'b0000; // no button pressed
            default: val = 4'b1111; 
        endcase
    end

    // Two-stage synchronizer
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            sync <= 4'b0;
            rowDataIn <= 4'b0;
        end else begin
            sync <= val;
            rowDataIn <= sync;
        end
    end

endmodule
