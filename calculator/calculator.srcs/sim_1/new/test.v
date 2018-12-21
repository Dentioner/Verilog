`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/22 10:52:27
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
reg [7:0]A, B;
reg [2:0]opcode;
wire [8:0]out;
reg clk;

initial 
begin
    clk = 0;
    A = 8'b00000000;
    B = 8'b00000000;
    
end
always #10 clk = ~clk;
always @(posedge clk)
begin
    A = {$random}%256;
    B = {$random}%256;
    opcode = {$random}%8;
end

calculator c1 (A, B, opcode, out);
endmodule
