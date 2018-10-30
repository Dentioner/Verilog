`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/30 15:44:25
// Design Name: 
// Module Name: mult_for
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


module mult_for(op1, op2, result);
input [8:1]op1, op2;
output reg [16:1]result;
integer i;
always @*
begin
    result = 0;
    for (i = 1; i<=8; i= i + 1)
    begin
        if (op1[i])
            result = result + (op2<<(i - 1));
    end
    
end
endmodule
