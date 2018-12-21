`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/04 10:49:24
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
reg input_valid, output_enable, clk;
reg [3:0]Data_In;
wire [7:0]Data_Out;
initial
begin
    clk = 0;
    input_valid = 0;
    output_enable = 0;
    Data_In = 4'b0000;
end
always #10 clk = ~clk;
always @(posedge clk)
begin
    input_valid = {$random}%2;
    output_enable = {$random}%2;
    Data_In = {$random}%16;
end
FIFO f1(Data_In, Data_Out, input_valid, output_enable, clk);

endmodule
