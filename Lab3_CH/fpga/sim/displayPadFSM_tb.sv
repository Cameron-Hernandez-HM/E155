/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	

*/
`timescale 1ns/1ps
module displayPadFSM_tb;

  // DUT signals
  logic clk, reset;
  logic [3:0] rowDataIn;
  logic [3:0] sweep;
  logic [7:0] display;

  // Instantiate DUT
  displayPadFSM dut(
    .clk(clk),
    .reset(reset),
    .rowDataIn(rowDataIn),
    .sweep(sweep),
    .display(display)
  );

  // Clock generation (10 ns period)
  always #5 clk = ~clk;

  // Reset sequence
  initial begin
    clk = 0;
    reset = 0;
    #20;
    reset = 1;
  end

  // Simulate a key press and release
  initial begin
    rowDataIn = 4'b0000;
    #100;

    // Key pressed
    rowDataIn = 4'b0010;
    #500;

    // Key released
    rowDataIn = 4'b0000;
    #300;

    // Second key press to see update on display
    rowDataIn = 4'b0100;
    #600;

    rowDataIn = 4'b0000;
    #300;

    $finish;
  end

  // Debounce simulation
  // Force internal debounce outputs to simulate a valid key press detection
  initial begin
    // Wait until FSM enters VERIFY
    wait (dut.state == dut.VERIFY);
    #20;
    force dut.high = 1;     // simulate "debounced high"
    #20;
    force dut.high = 0;     // release signal
    release dut.high;

    // Wait until HOLD state (key held)
    wait (dut.state == dut.HOLD);
    #100;
    force dut.holdLow = 1;  // simulate key release
    #10;
    force dut.holdLow = 0;
    release dut.holdLow;
  end
endmodule

