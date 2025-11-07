/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	

*/
`timescale 1ns/1ps

module top_tb();

    // --- Clocks ---
    logic int_osc;    // high frequency clock
    logic clk;        // FSM/system clock

    // --- IO and signals ---
    logic reset;
    logic [3:0] row, col;
    logic swL, swR;
    logic [6:0] seg;
    logic [7:0] display;
    logic [3:0] rowDataIn;

    // --- Generate clocks ---
    initial begin
        int_osc = 0;
        forever #1 int_osc = ~int_osc; // Fast clock
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;         // Slow clock
    end

    // --- Reset pulse ---
    initial begin
        reset = 0;
        row = 4'b1111;
        #40;
        reset = 1;
        $display("[%0t] Reset deasserted", $time);
    end

    // --- Instantiate modules (matching top.v exactly) ---
    dualSegmentDisp segDispCall(
        int_osc,      // same order as top
        ~display,
        reset,
        seg,
        swL,
        swR
    );

    displayPadFSM dispFSM(
        clk,
        reset,
        rowDataIn,
        col,
        display
    );

    ensureSinglePress singlePress(
        clk,
        reset,
        row,
        rowDataIn
    );

    // --- Stimulus (simulate keypad presses) ---
    initial begin
        wait (reset == 1);
        #100;
        $display("[%0t] Starting keypad input simulation", $time);

        row = 4'b1111;  #2000;
        row = 4'b1110;  #4000; // press row0
        row = 4'b1111;  #3000;
        row = 4'b1101;  #4000; // press row1
        row = 4'b1111;  #3000;
        row = 4'b1011;  #4000; // press row2
        row = 4'b1111;  #3000;
        row = 4'b0111;  #4000; // press row3
        row = 4'b1111;  #3000;

        $display("[%0t] Simulation done", $time);
        #5000;
        $stop;
    end

    // --- Monitor useful outputs ---
    initial begin
        $display("time\treset\trow\tcol\tdisplay\tseg\tswL\tswR");
        forever begin
            @(posedge clk);
            $display("%0t\t%b\t%b\t%b\t%h\t%b\t%b\t%b",
                $time, reset, row, col, display, seg, swL, swR);
        end
    end

    // --- VCD dump ---
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end

endmodule
