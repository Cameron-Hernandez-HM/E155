/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	

*/
module ensureSinglePress_tb();

    // Declare signals
    logic clk, reset;
    logic [3:0] row;
    logic [3:0] rowDataIn;

    // Instantiate DUT
    ensureSinglePress dut (
        .clk(clk),
        .reset(reset),
        .row(row),
        .rowDataIn(rowDataIn)
    );

    // Clock generation (10 ns period)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Apply reset (active low)
    initial begin
        reset = 0; 
        #15;
        reset = 1;
    end

    // Stimulus — simulate various keypress patterns
    initial begin
        // No press initially
        row = 4'b1111;  #30;  
        
        // Simulate a press on row 3 (4'b1101 → active low)
        row = 4'b1101;  #40;
        
        // Simulate a press on row 1 (4'b0111 → active low)
        row = 4'b0111;  #40;
        
        // Release key (no press)
        row = 4'b1111;  #30;

        // Invalid multi-key press (should map to 4'b1111)
        row = 4'b1010;  #40;
        
        // End simulation
        $stop;
    end

endmodule
