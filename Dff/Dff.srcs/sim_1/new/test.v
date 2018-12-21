`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/02 20:17:16
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
reg clk, d, reset, en;
wire q;
initial
begin
    clk = 0;
    d = 0;
    reset = 1;
    en = 0;
    #10 reset = 0; 
end
always #10 clk = ~clk;
always @(posedge clk)
begin
    d = {$random}%2;
    en = {$random}%2;
end
dff4 d1 (clk, d, reset, en, q);
endmodule
