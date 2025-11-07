/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	

*/
`timescale 1ns / 1ps

module keypadDecoder_tb;

    // Testbench signals
    logic [3:0] holdSweep;
    logic [3:0] holdRow;
    logic [3:0] decodedKey;

    // Instantiate the DUT (Device Under Test)
    keypadDecoder dut (
        .holdSweep(holdSweep),
        .holdRow(holdRow),
        .decodedKey(decodedKey)
    );

    // Stimulus process
    initial begin
        // Display header
        $display("Time\tSweep\tRow\tDecodedKey");

        // Initialize signals
        holdSweep = 4'b0000;
        holdRow   = 4'b0000;
        #10;

        // Sweep through all columns and rows
        repeat (1) begin
            // Column 1 (LSB)
            holdSweep = 4'b0001;
            holdRow = 4'b0001; #10; displayState(); // 1
            holdRow = 4'b0010; #10; displayState(); // 4
            holdRow = 4'b0100; #10; displayState(); // 7
            holdRow = 4'b1000; #10; displayState(); // E
            holdRow = 4'b0000; #10; // 0

            // Column 2
            holdSweep = 4'b0010;
            holdRow = 4'b0001; #10; displayState(); // 2
            holdRow = 4'b0010; #10; displayState(); // 5
            holdRow = 4'b0100; #10; displayState(); // 8
            holdRow = 4'b1000; #10; displayState(); // 0
            holdRow = 4'b0000; #10; // 0

            // Column 3
            holdSweep = 4'b0100;
            holdRow = 4'b0001; #10; displayState(); // 3
            holdRow = 4'b0010; #10; displayState(); // 6
            holdRow = 4'b0100; #10; displayState(); // 9
            holdRow = 4'b1000; #10; displayState(); // F
            holdRow = 4'b0000; #10; // 0

            // Column 4 (MSB)
            holdSweep = 4'b1000;
            holdRow = 4'b0001; #10; displayState(); // A
            holdRow = 4'b0010; #10; displayState(); // B
            holdRow = 4'b0100; #10; displayState(); // C
            holdRow = 4'b1000; #10; displayState(); // D
        end

        $finish;
    end

    // Simple task to print results
    task displayState;
        $display("%0t\t%b\t%b\t%h", $time, holdSweep, holdRow, decodedKey);
    endtask

endmodule
