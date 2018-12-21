`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/22 10:16:11
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
reg clk;
reg reset;
wire [3:0]out;
wire c;

initial 
begin
    clk = 0;
    reset = 0;
    #10 reset = 1;
    #15 reset = 0;
    #500 reset = 1;
    #10 reset = 0;
end

always #10 clk = ~clk;


counter c1 (clk, reset, out, c);

endmodule
