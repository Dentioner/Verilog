`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/12 21:09:07
// Design Name: 
// Module Name: dff
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


module dff(clear, clk, d, q, qbar);
input clear, clk, d;
output q, qbar;
wire sbar, s, r, rbar, cbar;
assign s = ~(sbar & cbar & (~clk));
assign cbar = ~clear;
assign sbar = ~(s & rbar);
assign r = ~(s & (~clk) & rbar);
assign rbar = ~(r & cbar & d);
assign q = ~(s & qbar);
assign qbar = ~(cbar & q & r);

endmodule
