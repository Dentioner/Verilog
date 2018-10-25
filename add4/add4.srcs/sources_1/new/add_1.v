`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/25 10:11:16
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


