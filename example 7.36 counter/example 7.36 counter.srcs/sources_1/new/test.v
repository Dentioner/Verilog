`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/17 10:23:25
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
reg clock, clear;
wire [3:0]Q;
initial
begin
    clock = 0;
    clear = 1;
    
end
always #10 clock = ~clock;
always #100 clear = {$random}%2;

counter c1(Q, clock, clear);
endmodule
