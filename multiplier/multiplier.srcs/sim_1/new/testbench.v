`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/14 09:48:52
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench();

reg[31:0] a;
reg[31:0] b;
wire[63:0] result;

initial
	
begin
	a = -6;
	b = -7;
	#100
	a = -8;
	b = 5;

	#100
	a = 6;
	b = 3;
	#100
	a = 7;
	b = -9;
end

mul m1(.x(a), .y(b), .result(result));

endmodule
