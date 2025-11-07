/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	This module functions as a stability or debounce counter that verifies when a keypad 
	input remains consistent for a set duration. It increments a counter while the current input 
	(rowDataIn) matches the stored value (holdRow) and decrements when they differ, filtering out 
	noise or brief changes. Once the signal stays stable long enough, it asserts high to confirm a 
	valid press and low when the key is released.
	
	Inputs: clk, reset, rowDataIn[3:0]
	Outputs: sweep[3:0], display[7:0]

*/
module deBounce #(
    parameter int MAX_COUNT = 42   
) (
    input  logic       clk,
    input  logic       reset,      
    input  logic       enable,
    input  logic [3:0] rowDataIn,
    input  logic [3:0] holdRow,
    output logic       high,
    output logic       low
);

    logic [$clog2(MAX_COUNT+1)-1:0] counter;

    // Counter operation
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter <= 0;
        end else if (!enable) begin
            counter <= MAX_COUNT/2;             
        end else begin
            if (rowDataIn == 4'b1111) begin
                counter <= 0;                   // no key pressed -> clear
            end else if (rowDataIn == holdRow && counter < MAX_COUNT) begin
                counter <= counter + 1;         // stable -> count up
            end else if (rowDataIn != holdRow && counter > 0) begin
                counter <= counter - 1;         // unstable -> count down
            end
        end
    end

    // Output flags
    assign high = (enable && counter == MAX_COUNT);
    assign low  = (enable && counter == 0);

endmodule
