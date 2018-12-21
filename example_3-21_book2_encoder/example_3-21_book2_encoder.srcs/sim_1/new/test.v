`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/24 11:12:52
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
reg [7:0]in;
wire [2:0]out;
reg clk;
reg [2:0]index;
initial
begin
    in = 8'b00000000;
    clk = 0;
    index = 3'b000;
end
always #10 clk = ~clk;
always@(posedge clk)
begin
    index = {$random}%8;
    in = 8'b00000000;
    in[index] = 1;
   //in = {$random}%256;
    
end
encoder d1 (in, out);
endmodule
