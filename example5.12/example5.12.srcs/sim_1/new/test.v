`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/25 20:42:45
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


module test;
reg A, B, C;
wire OUT;
D d1(OUT, A, B, C);

initial
begin
    A = 1'b0; B= 1'b0; C= 1'b0;
    #10 A= 1'b1; B= 1'b1; C= 1'b1;
    #10 A= 1'b1; B= 1'b0; C= 1'b0;
    #20 $finish;
end

endmodule
