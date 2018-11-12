`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/12 20:59:23
// Design Name: 
// Module Name: pulse4
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


module pulse4(clock, clear, q);
input clock, clear;
output [3:0]q;

tff t0 (clock, clear, q[0]);
tff t1 (q[0], clear, q[1]);
tff t2 (q[1], clear, q[2]);
tff t3 (q[2], clear, q[3]);

endmodule







