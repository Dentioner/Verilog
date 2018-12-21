`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/24 10:49:22
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


module test();

reg[7:0] A, B;
wire [1:0]out;
reg clk;

initial
begin
    clk = 0;
    A = 0;
    B = 0;
end
always #10 clk = ~clk;
always @(posedge clk)
begin
    A = {$random}%16;
    B = {$random}%16;
end

compareN c1 (A, B, out);
endmodule
