`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/15 10:55:48
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
reg [2:0] A;
wire [7:0]Y;
reg clk;
initial
begin
    A = 3'b000;
 
    clk = 0;
end

always #10 clk = ~clk;
always @(posedge clk)
begin
    A = {$random}%8;
    
end

T_to_E t1 (A,Y);
endmodule
