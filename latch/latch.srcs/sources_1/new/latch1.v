`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/02 21:10:40
// Design Name: 
// Module Name: latch1
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


module latch1(d, clk, q);
input d, clk;
output reg q;
always @(clk)
begin
    if (clk)
        q <= d;
end
endmodule
