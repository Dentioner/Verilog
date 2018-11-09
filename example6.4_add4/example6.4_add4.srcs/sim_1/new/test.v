`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/09 21:58:34
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
reg[3:0] a;
reg[3:0] b;
//reg[15:0] A;
//reg[15:0] B;
wire [3:0] sum;
wire c_out;
reg c_in;

initial
begin
    a = 0;
    b = 0;
    c_in = 0;
    clk = 0;
    
end

always #10 clk = ~clk;
always @(posedge clk)
begin
    a = {$random}%16;
             
    b = {$random}%16;
end

fulladd4 a1 (.sum(sum), .c_out(c_out), .a(a), .b(b), .c_in(c_in));
endmodule
