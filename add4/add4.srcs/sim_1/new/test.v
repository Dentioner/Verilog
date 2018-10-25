`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/25 10:30:11
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

reg[3:0] A;
reg[3:0] B;
wire [3:0] S;
wire CO;
wire CI;

initial begin
    A = 10;
    B = 5;
    CI = 0;
    clk = 0;
end

always #10 clk=~clk;

add4 add(
    .A(A),
    .B(B),
    .CI(CI), 
    .S(S),
    .CO(CO)
);

endmodule
