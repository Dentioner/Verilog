`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/15 11:33:56
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
reg [7:0]I;
reg S;
wire[2:0]Y;
wire Y_S, Y_EX;
reg clk;
initial
begin
    I = 8'b00000000;
    S = 0;
    clk = 0;
    #100 S = 1;
end
always #10 clk = ~clk;
always@(posedge clk)
begin
    //S = #100 1;
    I = {$random}%256;
    //#100 S = 1;
end

E_to_T e1 (I, Y, S, Y_S, Y_EX);
endmodule
