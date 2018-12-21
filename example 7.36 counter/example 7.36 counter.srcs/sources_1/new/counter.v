`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/17 10:20:51
// Design Name: 
// Module Name: counter
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


module counter(Q, clock, clear);
input clear,clock;
output reg [3:0]Q;

always@(posedge clear or negedge clock)
begin
    if (clear)
        Q<=4'd0;
    else
        Q <= Q + 1;
end
endmodule
