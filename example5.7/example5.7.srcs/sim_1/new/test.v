`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/25 20:05:11
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


module test;
reg [3:0] A, B;
reg C_IN;
wire [3:0] SUM;
wire C_OUT;

fulladd4 FA1_4(SUM, C_OUT, A, B, C_IN);

initial
begin
    $monitor($time, " A= %b, B=%b, C_IN= %b, --- C_OUT= %b, SUM= %b\n", A, B, C_IN, C_OUT, SUM);
end

initial
begin
    A = 4'd0; B = 4'd0; C_IN = 1'b0;
    
    #5 A = 4'd3; B = 4'd4;
    #5 A = 4'd2; B = 4'd5;
    #5 A = 4'd9; B = 4'd9;
    #5 A = 4'd10; B = 4'd15;
    #5 A = 4'd10; B = 4'd5; C_IN = 1'b1;
end
    
endmodule
