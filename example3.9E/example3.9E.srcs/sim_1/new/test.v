`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/30 15:49:52
// Design Name: 
// Module Name: test
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


module test;
reg [8:1]op1, op2;
wire [16:1]result;
reg clk;
initial
begin
    op1 = 5;
    op2 = 3;
    clk = 0;
end
always #10 clk = ~clk;
always @ clk;
begin
    mult_for m1 (.op1(op1), .op2(op2), .result(result));
end
endmodule
