`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/09 21:05:04
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
reg s1, s0;
reg i0, i1, i2, i3 ;
wire out1, out2;

initial
begin
    i0 = 0;
    i1 = 1;
    i2 = 0;
    i3 = 1;
    s0 = 0;
    s1 = 0;
    clk = 0;
end

always #1000 clk = ~clk;
always @ (posedge clk)
begin
    i0 = {$random}%2;
    i1 = {$random}%2;
    i2 = {$random}%2;
    i3 = {$random}%2;
    s0 = {$random}%2;
    s1 = {$random}%2;     
     
end
/*
always #1000 @*
begin
    s0 = 1;
    s1 = 0;     
     
end

always #2000 @*
begin
    s0 = 0;
    s1 = 1;     
     
end

always #3000 @*
begin
    s0 = 1;
    s1 = 1;     
     
end
*/
mux4_to_1 m1(.i0(i0), .i1(i1), .i2(i2), .i3(i3), .s1(s1), .s0(s0), .out(out1));
mux4_to_1_ver2 m2(.i0(i0), .i1(i1), .i2(i2), .i3(i3), .s1(s1), .s0(s0), .out(out2));




endmodule
