`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 19:30:06
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
reg clk, load;
reg [7:0]din;
wire qb;
initial
begin
    clk = 0;
    load = 1;
    din = {$random}%256;
    #20 load = 0;
end
always #10 clk = ~clk;

shift_reg s1 (clk, load, din, qb);

endmodule
