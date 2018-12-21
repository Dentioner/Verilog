`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/24 11:03:00
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
reg [2:0]in;
wire [7:0]out;
reg clk;
initial
begin
    in = 3'b000;
    clk = 0;
end
always #10 clk = ~clk;
always@(posedge clk)
begin
    in = {$random}%8;
end
decoder d1 (in, out);
endmodule
