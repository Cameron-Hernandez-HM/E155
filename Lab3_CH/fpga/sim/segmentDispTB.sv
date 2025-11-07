/*/
	Author: Cameron Hernandez
	Email: cahernandez@g.hmc.edu
	Date: 09/03/2025
	
	This file contains the module segmentDispTB which tests to see if the module segmentDispTB works properly
*/

module segmentDispTB();
	logic	     clk, reset;
	logic [3:0]  s;				
	logic [6:0]  seg, segExp;  // Input and Output Logic
	logic [31:0] vectorNum, errors;
	logic [10:0] testVectors[15:0];
	

segmentDisp dut(s, seg);

always
	begin	
		clk=1; #5;
		clk=0; #5;
	end
	
initial
	begin
		$readmemb("Seg.tv", testVectors);
		vectorNum=0;
		errors=0;
		reset=1; #22;
		reset=0;
	end
	
always @(posedge clk)
	begin
		#1;
		{s, segExp} = testVectors[vectorNum];
	end
	
always @(negedge clk)
	if (~reset) begin
		if (seg !== segExp) begin
				$display("Error: inputs = %b", s);	
				$display(" outputs = %b (%b expected)", seg, segExp);		
				errors = errors + 1;
		end
		vectorNum = vectorNum + 1;
		if (testVectors[vectorNum] === 11'bx) begin
			$display("%d tests completed with %d errors", vectorNum, 
				errors);		
			$stop;	
		end	
	end
endmodule