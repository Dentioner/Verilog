`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/12 21:31:59
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

reg CLOCK, CLEAR;
wire [3:0] Q;

initial 
    $monitor($time, " Count Q = %b CLear = %b", Q[3:0], CLEAR);

pulse4 p1(CLOCK, CLEAR, Q);
initial
begin
    CLEAR = 1'b1;
    #34 CLEAR = 1'b0;
    #200 CLEAR = 1'b1;
    #50 CLEAR = 1'b0;
end

initial
begin
    CLOCK = 1'b0;
    forever #10 CLOCK = ~CLOCK;
end

initial 
begin
    #400 $finish;
end
endmodule
