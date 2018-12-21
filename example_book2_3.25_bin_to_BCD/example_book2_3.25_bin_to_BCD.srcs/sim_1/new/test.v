`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/26 22:11:11
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
reg [7:0]bin;
wire [9:0]bcd;
reg clk;

initial
begin
    bin = 8'b00000000;
    clk = 0;
end
always #10 clk = ~clk;
always @(posedge clk)
begin
    bin = {$random}%256;
end

BinToBCD b1 (bin, bcd);
endmodule
