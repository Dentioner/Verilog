`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/02 21:12:39
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
reg d, clk;
wire q;
initial
begin
    d = 0;
    clk = 0;
end
always #10 clk = ~clk;
always #15
    d = {$random}%2;
latch1 l1(d, clk, q);
endmodule
