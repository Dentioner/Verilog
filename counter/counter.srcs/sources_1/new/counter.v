`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/22 09:59:52
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


module counter(clk, reset, re_out, c);

input clk;
input reset;
//output out;
output reg [3:0]re_out;
output c;

always@( posedge clk)
begin
    if (reset)
    begin
        re_out = 4'b0000;
        $display ("%d\n", re_out);
    end
    else if (re_out < 9)
    begin
        re_out  = re_out + 1; 
        $display ("%d\n", re_out);
    end
    else
        re_out = 0;
        $display ("%d\n", re_out);
end
    assign out = re_out;
    assign c = (re_out == 9)?1'b1:1'b0;
    
    
endmodule
