`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/14 21:40:19
// Design Name: 
// Module Name: tb
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


module tb(

    );

reg[15:0] a;
reg[15:0] b;
wire[31:0] result;

initial
begin
	a = -6;
	b = -7;
	#100
	b = 5;

	#100
	a = 6;
	b = 3;
	#100
	a = 7;
	b = 6;
end

mul16 m1(.x(a), .y(b), .result(result));
endmodule
