`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/16 21:24:44
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
parameter N = 32;
wire [N-1:0] out;
reg [N-1:0]i0, i1;
reg clk;
initial
begin
    i0 = 0;
    i1 = 0;
    clk = 0;
end


always#50 clk = ~clk;
always@(posedge clk)
begin
    i0 = {$random}%4096;
    i1 = {$random}%4096;
    
end
bitwise_xor b1 (out, i0, i1);
endmodule
