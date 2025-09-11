/*/
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/03/2025
	
	This file contains the module segmentDisp which uses a four DIP switch input to 
	control the segments on a 7-segment display
	
	Inputs: s[3:0] where s = {P37, P31, P35, P32} Assigned Pin
	Outputs: seg[7:0] where seg = {A_P3, B_P45, C_P20, D_P12, E_P18, F_P44, G_P9} Segment name and its assigned Pin
	
*/

module segmentDisp(
    input logic  [3:0] s,        // The four DIP switches (on the board, SW6)
    output logic [6:0] seg);    // The segments of a common-anode 7-segment display

    always_comb begin
        case(s)
            4'b0000: seg = 7'b0000001; // 0
            4'b0001: seg = 7'b1001111; // 1
            4'b0010: seg = 7'b0010010; // 2
            4'b0011: seg = 7'b0000110; // 3
            4'b0100: seg = 7'b1001100; // 4
            4'b0101: seg = 7'b0100100; // 5
            4'b0110: seg = 7'b0100000; // 6
            4'b0111: seg = 7'b0001111; // 7
            4'b1000: seg = 7'b0000000; // 8
            4'b1001: seg = 7'b0000100; // 9
            4'b1010: seg = 7'b0001000; // a
            4'b1011: seg = 7'b1100000; // b
            4'b1100: seg = 7'b0110001; // c
            4'b1101: seg = 7'b1000010; // d
            4'b1110: seg = 7'b0110000; // e
            4'b1111: seg = 7'b0111000; // f
            default: seg = 7'b1111111; // Default (all segments off)
        endcase
    end
endmodule
