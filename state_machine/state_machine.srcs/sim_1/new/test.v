`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/13 10:53:14
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
reg A, B, clk, reset;
wire out, bug;
initial
begin
    A = 0;
    B= 0;
    clk = 0;
    reset = 1;
    
end
always #10 clk = ~clk;
always @(posedge clk)
begin
    A = {$random}%2;
    B = {$random}%2;
    reset = 0;
    
end

state s1 (.A(A), .B(B), .clk(clk), .out(out), .bug(bug), .reset(reset));


endmodule
