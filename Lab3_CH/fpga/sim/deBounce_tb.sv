/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	

*/
`timescale 1ns / 1ps

module deBounce_tb;

    // Testbench signals
    logic clk;
    logic reset;
    logic enable;
    logic [3:0] rowDataIn;
    logic [3:0] holdRow;
    logic high;
    logic low;

    // Instantiate DUT
    deBounce #(.MAX_COUNT(10)) dut (   // Smaller MAX_COUNT for faster simulation
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .rowDataIn(rowDataIn),
        .holdRow(holdRow),
        .high(high),
        .low(low)
    );

    // Clock generation (4ns period)
    always #2 clk = ~clk;

    // Initialize testbench
    initial begin
        // Setup initial conditions
        clk = 0;
        reset = 0;
        enable = 0;
        rowDataIn = 4'b1111;   // No key pressed
        holdRow = 4'b0100;     // Expected stable value

        // Apply reset pulse (active low)
        $display("Time\tReset\tEnable\tRowIn\tHoldRow\tCounterHigh\tCounterLow");
        #5 reset = 1;

        // Enable system
        #5 enable = 1;

        // Simulate signal bouncing and stabilization
        // Step 1: No key pressed
        repeat (5) begin
            @(posedge clk);
            displayState();
        end

        // Step 2: Start pressing a key (matches holdRow)
        rowDataIn = 4'b0100;
        repeat (12) begin
            @(posedge clk);
            displayState();
        end

        // Step 3: Introduce noise (different row briefly)
        rowDataIn = 4'b0010;
        repeat (4) begin
            @(posedge clk);
            displayState();
        end

        // Step 4: Return to stable press
        rowDataIn = 4'b0100;
        repeat (12) begin
            @(posedge clk);
            displayState();
        end

        // Step 5: Release key (no key pressed)
        rowDataIn = 4'b1111;
        repeat (10) begin
            @(posedge clk);
            displayState();
        end

        $finish;
    end

    // Display signal states for observation
    task displayState;
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b", 
                 $time, reset, enable, rowDataIn, holdRow, high, low);
    endtask

endmodule
