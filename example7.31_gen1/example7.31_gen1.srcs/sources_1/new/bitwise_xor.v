`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/16 21:21:12
// Design Name: 
// Module Name: bitwise_xor
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


module bitwise_xor(out, i0, i1);
parameter N = 32;
output [N-1:0] out;
input [N-1:0]i0, i1;

genvar j;
generate
for (j = 0; j<N; j = j+1)
begin:xor_loop
    xor g1 (out[j], i0[j], i1[j]);

    
end
endgenerate
endmodule
