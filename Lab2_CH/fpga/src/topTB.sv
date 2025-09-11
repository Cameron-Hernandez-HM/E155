/*/
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/11/2025
	
	This file contains the module topTB which tests to see if the top module works properly
*/

module topTB();
	logic	   	clk, reset;
	logic [3:0]	s0, s1;	
	logic [4:0]	ledSum, ledSumExp;
	logic		enable0, enable1;
	logic [6:0] seg;
	logic [7:0] errors;
	logic [7:0]	ittr;
	

	top dut(s0, s1, seg, enable0, enable1, ledSum);

	always
		begin	
			clk=1; #5;
			clk=0; #5;
		end
		
	initial
		begin
			errors=0;
			reset=1; #22;
			reset=0;
			ittr=0;
		end
		
	always @(posedge clk)
		begin
			#1;
			ledSumExp = ~(ittr[3:0] + ittr[7:4]);
			s0 = ittr[3:0];
			s1 = ittr[7:4];
		end
		
	always @(negedge clk) begin
		if (~reset) begin
			if (ledSum !== ledSumExp) begin
					$display("Error: inputs = %b %b", s0, s1);	
					$display(" outputs = ledSum:%b (ledSum:%b expected)", ledSum, ledSumExp);		
					errors = errors + 1;
			end
			ittr = ittr + 1;
			if (ittr === 8'b11111111) begin
				$display("256 tests completed with %d errors", errors);		
				$stop;	
			end	
		end
	end
endmodule