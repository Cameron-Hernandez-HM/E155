/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	

*/
`timescale 1ns/1ps
module holdKey_tb;

  // DUT signals
  logic clk, reset, holdEnable;
  logic [3:0] rowDataIn;
  logic holdLow;

  // Instantiate DUT
  holdKey #(.MAX_COUNT(8)) dut (
    .clk(clk),
    .reset(reset),
    .holdEnable(holdEnable),
    .rowDataIn(rowDataIn),
    .holdLow(holdLow)
  );

  // Clock: 10 ns period
  always #5 clk = ~clk;

  // Initial setup
  initial begin
    clk = 0;
    reset = 0;
    holdEnable = 0;
    rowDataIn = 4'b0000;
    #20;
    reset = 1;
  end

  // Test sequence
  initial begin
    // --- Idle state ---
    #30;
    holdEnable = 1;
    rowDataIn = 4'b0000;      // no key pressed
    #80;

    // --- Key press ---
    rowDataIn = 4'b0100;      // key pressed
    #100;

    // --- Key held ---
    rowDataIn = 4'b0100;
    #80;

    // --- Key released ---
    rowDataIn = 4'b0000;
    #120;

    // --- Disable the module (counter resets to mid) ---
    holdEnable = 0;
    #50;

    // --- Re-enable and simulate multiple key presses ---
    holdEnable = 1;
    rowDataIn = 4'b0010;      // press another key
    #70;
    rowDataIn = 4'b0000;      // release again
    #150;

    $finish;
  end

endmodule
