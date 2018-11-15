`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/15 11:01:32
// Design Name: 
// Module Name: mux41
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


module mux41(IN, S, Y);
input [3:0]IN;
input [1:0]S;
output reg Y;
always @*
begin
   
    case(S)
        2'b00: Y = IN[0];
        2'b01: Y = IN[1];
        2'b10: Y = IN[2];
        2'b11: Y = IN[3];
    endcase
end 
endmodule
