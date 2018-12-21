`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/23 21:21:00
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
reg a, b;
wire [1:0]out;
reg clk;

initial
begin
    clk = 0;
    a = 0;
    b = 0;
end
always #10 clk = ~clk;
always @(posedge clk)
begin
    a = {$random}%2;
    b = {$random}%2;
end

compare c1 (a, b, out);
endmodule
