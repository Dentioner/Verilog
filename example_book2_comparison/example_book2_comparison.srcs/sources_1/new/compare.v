`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/23 21:15:43
// Design Name: 
// Module Name: compare
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


module compare(a, b, out);
input  a, b;
/*
output reg [1:0]out;
begin
always @*
    case(a-b)
        0: out = 2'b00;
        1: out = 2'b01;
       -1: out = 2'b10;
       default: out = 2'b11;
   endcase
end 
*/
output [1:0]out;
wire [1:0]c;
assign c= a - b;

assign out = (c == 2'b00)? 2'b00:
             (c == 2'b01)? 2'b01:
             (c == 2'b11)? 2'b10:
             2'b00;

endmodule

