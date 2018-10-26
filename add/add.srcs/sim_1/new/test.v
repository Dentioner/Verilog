`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/26 20:16:10
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
reg rst;

reg [3:0] a;
reg [3:0] b;
wire [3:0] out;
wire cout;
reg cin;

initial
begin
    a = 15;
    b = 7;
    cin = 0;
    clk = 0;
end

always #10 clk = ~clk;

fulladd fa1(.a(a), .b(b), .c_in(cin), .sum(out), .c_out(cout));

endmodule
