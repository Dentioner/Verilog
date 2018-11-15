`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/15 11:08:58
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
reg[3:0]IN;
reg [1:0]S;
wire Y;

reg clk;
initial
begin
    IN = 4'b0000;
    S = 2'b00;
    clk = 0;
end

always #10 clk = ~clk;
always @(posedge clk)
begin
    IN = {$random}%16;
    S = {$random}%4;
    
end

mux41 m1 (IN, S, Y);

endmodule
