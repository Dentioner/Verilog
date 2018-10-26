`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/26 20:00:47
// Design Name: 
// Module Name: add_1
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


module add_1(
    input A,
    input B,
    input CI,
    output S,
    output CO
    );

wire s_temp, c1, c2;

xor x1 (s_temp, A, B);
xor x2 (S, CI, s_temp);

and a1 (c1, A, B);
and a2 (c2, CI, s_temp);

xor o1 (CO, c1, c2);

endmodule

module fulladd(a, b, c_in, sum, c_out);
input [3:0]a;
input [3:0]b;
input c_in;
output [3:0]sum;
output c_out;

wire c_1, c_2, c_3;

add_1 a1(a[0], b[0], c_in, sum[0], c_1);
add_1 a2(a[1], b[1], c_1, sum[1], c_2);
add_1 a3(a[2], b[2], c_2, sum[2], c_3);
add_1 a4(a[3], b[3], c_3, sum[3], c_out);

endmodule