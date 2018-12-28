`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/25 11:29:01
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
reg clk, reset;
wire [3:0]led_out;
initial
begin
    clk = 1'b0;
    reset = 1'b1;
    #1000 reset = 1'b0;
end

always #5 clk = ~clk;

led l1(clk, reset, led_out);
endmodule
