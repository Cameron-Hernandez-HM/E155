/*/
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/03/2025
	
	This file contains the module topTB which tests to see if the top module works properly
*/

module topTB();
	logic	     clk, reset;
	logic [3:0]  s;	
	logic [2:0]  led, ledExp;
	logic [6:0]  seg, segExp;  // Input and Output Logic
	logic [31:0] vectorNum, errors;
	logic [13:0] testVectors[15:0];
	

top dut(s, seg, led);

always
	begin	
		clk=1; #5;
		clk=0; #5;
	end
	
initial
	begin
		$readmemb("top.tv", testVectors);
		vectorNum=0;
		errors=0;
		reset=1; #22;
		reset=0;
	end
	
always @(posedge clk)
	begin
		#1;
		{s, segExp, ledExp} = testVectors[vectorNum];
	end
	
always @(negedge clk)
	if (~reset) begin
		if (seg !== segExp | led[1:0] !== ledExp[1:0]) begin
				$display("Error: inputs = %b", s);	
				$display(" outputs = seg:%b led:%b (seg:%b led:%b expected)", seg, led, segExp, ledExp);		
				errors = errors + 1;
		end
		vectorNum = vectorNum + 1;
		if (vectorNum === 31'd16) begin
			$display("%d tests completed with %d errors", vectorNum, 
				errors);		
			$stop;	
		end	
	end
endmodule