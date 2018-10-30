`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/30 10:43:50
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
reg clk;
reg rst;
reg[15:0] A;
reg[15:0] B;
//reg[15:0] A;
//reg[15:0] B;
wire [15:0] S;
wire CO;
reg CI;


/*
initial 
begin
    A = 2343;
    B = 2312;
    CI = 1;
    clk = 0;
    #1000  A = 23435;
       B = 23125;
       CI = 1;
       clk = 0;
end

initial
begin
    $monitor(CO,S);
end
*/
/*
initial #1000 
begin 
    A = 23435;
    B = 23125;
    CI = 1;
    clk = 0;
end
*/
/*
always #10 clk=~clk;

add16 add(
    .A(A),
    .B(B),
    .CI(CI), 
    .S(S),
    .CO(CO)
);

*/
initial
begin
    A = 0;
    B = 0;
    CI = 0;
    clk = 0;
    
end

always #10 clk = ~clk;
always @(posedge clk)

    begin
/*
       A[0] = {$random}%2;
       A[1] = {$random}%2;
       A[2] = {$random}%2;
       A[3] = {$random}%2;
       A[4] = {$random}%2;
       A[5] = {$random}%2;
       A[6] = {$random}%2;
       A[7] = {$random}%2;
       A[8] = {$random}%2;
       A[9] = {$random}%2;
       A[10] = {$random}%2;
       A[11] = {$random}%2;
       A[12] = {$random}%2;
       A[13] = {$random}%2;
       A[14] = {$random}%2;
       A[15] = {$random}%2;
       B[0] = {$random}%2;
       B[1] = {$random}%2;
       B[2] = {$random}%2;
       B[3] = {$random}%2;
       B[4] = {$random}%2;
       B[5] = {$random}%2;
       B[6] = {$random}%2;
       B[7] = {$random}%2;
       B[8] = {$random}%2;
       B[9] = {$random}%2;
       B[10] = {$random}%2;
       B[11] = {$random}%2;
       B[12] = {$random}%2;
       B[13] = {$random}%2;
       B[14] = {$random}%2;
       B[15] = {$random}%2;
       */
       A = {$random}%10000;
             
       B = {$random}%10000;
      
    end

always #1000 @(posedge clk)
    begin
       A = {$random}%32768;
       B = {$random}%32768;
      
    end

    add16 add(
               .A(A),
               .B(B),
               .CI(CI), 
               .S(S),
               .CO(CO)
           );
       
       
    
endmodule