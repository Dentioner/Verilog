`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 21:03:44
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
reg clk, reset, din;
wire sout1, sout2;
initial
begin
    clk = 1'b0;
    reset = 1'b1;
    din = 0;
    #20 reset = 0;
end
always #10 clk = ~clk;
always @(posedge clk)
    din = {$random}%2;
moore m1 (clk, reset, din, sout1);
mealy m2 (clk, reset, din, sout2);
endmodule
