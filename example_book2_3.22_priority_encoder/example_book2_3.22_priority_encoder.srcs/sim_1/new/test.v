`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/26 21:30:39
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

initial
begin
    in = 8'b00000000;
    clk = 0;
end
always #10 clk = ~clk;
always @(posedge clk)
begin
    in = {$random}%256;
    
end

encoder2 e1 (in, out);
endmodule
