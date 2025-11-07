/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	The holdKey module monitors keypad inputs and ensures that no key 
	has been pressed for a certain duration before signaling completion. 
	It increments a counter when any key is pressed and decrements it when all 
	keys are released, asserting the holdLow output once the counter reaches zero. 
	This mechanism prevents accidental or repeated key presses by confirming that 
	the keypad has been idle for the required time.
	
	Inputs: clk, reset, holdEnable, rowDataIn[3:0]
	Output: holdLow

*/
module holdKey #(
    parameter int MAX_COUNT = 8  
)(
    input  logic       clk,
    input  logic       reset,     
    input  logic       holdEnable,
    input  logic [3:0] rowDataIn,
    output logic       holdLow
);

    logic [$clog2(MAX_COUNT+1)-1:0] counter;

    // Counter logic
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter <= MAX_COUNT/2;
        end else if (!holdEnable) begin
            counter <= MAX_COUNT/2;       // idle midpoint when disabled
        end else begin
            if (|rowDataIn && counter < MAX_COUNT) begin
                counter <= counter + 1;   // button pressed -> count up
            end else if (~(|rowDataIn) && counter > 0) begin
                counter <= counter - 1;   // no button pressed -> count down
            end
        end
    end

    // Output flag
    assign holdLow = (holdEnable && counter == 0);

endmodule
