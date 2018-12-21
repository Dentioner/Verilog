`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/24 10:44:44
// Design Name: 
// Module Name: compareN
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


module compareN(A, B, out);
parameter N = 8;
input [N-1:0] A, B;
output [1:0]out;

assign out = (A>B)?2'b10:
            (A<B)?2'b01:
            (A == B)?2'b00:2'b11;


endmodule
