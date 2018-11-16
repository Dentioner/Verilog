`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/16 20:05:52
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
wire out0, out1, out2, out3;
reg in;
reg s1, s0;
reg clk;
reg [1:0]state_of_in;
initial
begin
    in = 0;
    s1 = 0;
    s0 = 0;
    clk = 0;
    state_of_in = 2'b00;
end

always #10 clk = ~clk;
always @(posedge clk)
begin
    state_of_in = {$random}%4;
    s1 = {$random}%2;
    s0 = {$random}%2;
end
always @(state_of_in)
begin
    case(state_of_in)
        0: in = 1'b0;
        1: in = 1'b1;
        2: in = 1'bx;
        3: in = 1'bz;
    endcase
end

demultiplexer1_to_4 d1 (out0, out1, out2, out3, in, s1, s0);

endmodule
