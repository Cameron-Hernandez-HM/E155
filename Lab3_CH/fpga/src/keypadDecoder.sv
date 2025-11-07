/*
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/18/2025
	
	This module decodes the pressed key from a 4x4 matrix keypad by identifying 
	which column (holdSweep) and row (holdRow) lines are active. It maps the detected 
	rows and column combination to a corresponding 4-bit hexadecimal value that represents 
	the keypads identity. The resulting decodedKey output provides a digital code used 
	for display or further processing in the system.
	
	Inputs: holdSweep[3:0], holdRow[3:0]
	Outputs: decodedKey[3:0]

*/
module keypadDecoder(
    input   logic   [3:0]   holdSweep,
    input   logic   [3:0]   holdRow,
    output  logic   [3:0]   decodedKey);

    always_comb
        case (holdSweep)
            4'b1000: case (holdRow)
                         4'b1000: decodedKey = 4'hd;
                         4'b0100: decodedKey = 4'hc;
                         4'b0010: decodedKey = 4'hb;
                         4'b0001: decodedKey = 4'ha;
                         default: decodedKey = 4'h0;
                     endcase
            4'b0100: case (holdRow)
                         4'b1000: decodedKey = 4'hf;
                         4'b0100: decodedKey = 4'h9;
                         4'b0010: decodedKey = 4'h6;
                         4'b0001: decodedKey = 4'h3;
                         default: decodedKey = 4'h0;
                     endcase
            4'b0010: case (holdRow)
                         4'b1000: decodedKey = 4'h0;
                         4'b0100: decodedKey = 4'h8;
                         4'b0010: decodedKey = 4'h5;
                         4'b0001: decodedKey = 4'h2;
                         default: decodedKey = 4'h0;
                     endcase
            4'b0001: case (holdRow)
                         4'b1000: decodedKey = 4'he;
                         4'b0100: decodedKey = 4'h7;
                         4'b0010: decodedKey = 4'h4;
                         4'b0001: decodedKey = 4'h1;
                         default: decodedKey = 4'h0;
                     endcase
            default:  decodedKey = 4'h0;
        endcase
endmodule
