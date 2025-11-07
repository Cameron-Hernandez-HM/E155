/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	This module multiplexes a two-digit seven-segment display by rapidly toggling between the left and right digits. 
	It alternately selects and displays the upper or lower 4 bits of an 8-bit input value at a frequency determined by a divider, 
	creating the illusion that both digits are lit simultaneously. The outputs swL and swR control which display is active, 
	while seg drives the segment lines.
	
	Inputs: clk, reset, display[7:0]
	Outputs: seg[6:0], swL, swR

*/
module dualSegmentDisp (
    input  logic       clk,
    input  logic [7:0] display,
    input  logic       reset,   // active low
    output logic [6:0] seg,
    output logic       swL,
    output logic       swR
);

    logic       freq;
    logic       select;         // 0 = left, 1 = right
    logic [3:0] intDisplay;

    // Frequency divider 
    freqGen #(.divisionFactor(48000)) freqGenCall (clk, reset, freq);

    // Toggle between left and right digits
    always_ff @(posedge freq or negedge reset) begin
        if (!reset)
            select <= 1'b0;                 // start at left digit
        else
            select <= ~select;              // toggle each tick
    end

    // Select which nibble to display
    always_comb begin
        if (select)
            intDisplay = ~display[7:4];     // right
        else
            intDisplay = ~display[3:0];     // left
    end

    // Control which display is active
    assign swL = ~select;   // active low
    assign swR = select;    // active low (depending on hardware)

    segmentDisp segmentLogic(intDisplay, seg); 

endmodule





/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	This file contains the module segmentDisp which uses a four DIP switch input to 
	control the segments on a 7-segment display
	
	Inputs: s[3:0] where s = {P37, P31, P35, P32} Assigned Pin
	Outputs: seg[7:0] where seg = {A_P3, B_P45, C_P20, D_P12, E_P18, F_P44, G_P9} Segment name and its assigned Pin
	
*/

module segmentDisp(
    input logic [3:0] s,        // The four DIP switches (on the board, SW6)
    output logic [6:0] seg);   // The segments of a common-anode 7-segment display

    always_comb
        case (s)
            4'h0: seg <= ~7'b0111111;
            4'h1: seg <= ~7'b0000110;
            4'h2: seg <= ~7'b1011011;
            4'h3: seg <= ~7'b1001111;
            4'h4: seg <= ~7'b1100110;
            4'h5: seg <= ~7'b1101101;
            4'h6: seg <= ~7'b1111101;
            4'h7: seg <= ~7'b0000111;
            4'h8: seg <= ~7'b1111111;
            4'h9: seg <= ~7'b1100111;
            4'ha: seg <= ~7'b1110111;
            4'hb: seg <= ~7'b1111100;
            4'hc: seg <= ~7'b0111001;
            4'hd: seg <= ~7'b1011110;
            4'he: seg <= ~7'b1111001;
            4'hf: seg <= ~7'b1110001;
            default: seg <= ~7'b0000001;
        endcase
endmodule