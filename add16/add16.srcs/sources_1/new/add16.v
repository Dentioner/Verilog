`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/30 10:34:57
// Design Name: 
// Module Name: add16
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


module add16(A, B, CI, S, CO);
input [15:0]A;
input [15:0]B;
input CI;
output [15:0]S;
output CO;
wire [2:0]C_temp;
add4 addf1 (A[3:0], B[3:0], CI, S[3:0], C_temp[0]);
add4 addf2 (A[7:4], B[7:4], C_temp[0], S[7:4], C_temp[1]);
add4 addf3 (A[11:8], B[11:8], C_temp[1], S[11:8], C_temp[2]);
add4 addf4 (A[15:12], B[15:12], C_temp[2], S[15:12], CO);

endmodule


module add4(A, B, CI, S, CO);
    //parameter size = 4;
    input [4:1]A,B;
    input CI;
    output [4:1]S;
    output CO;
    wire [3:1]Ctemp;
single_add add1(A[1], B[1], CI, S[1], Ctemp[1]);
single_add add2(A[2], B[2], Ctemp[1], S[2], Ctemp[2]);
single_add add3(A[3], B[3], Ctemp[2], S[3], Ctemp[3]);
single_add add4(A[4], B[4], Ctemp[3], S[4], CO);
    
    
endmodule

module single_add(
    input a,
    input b,
    input ci,
    output s,
    output co
    );
    
    wire Sum_temp, c_1, c_2, c_3;
    xor
    XOR1(Sum_temp, a, b);
    xor
    XOR2(s, Sum_temp, ci);
    and
    AND3(c_3, a, b);
    and 
    AND2(c_2, b, ci);
    and
    AND1(c_1, a, ci);
    or
    OR1(co, c_1, c_2, c_3);
    
endmodule