`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/26 21:52:18
// Design Name: 
// Module Name: BinToBCD
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


module BinToBCD(bin, bcd);
input [7:0]bin;
output reg [9:0]bcd;
reg [17:0] x;

always @*
begin
    
    x[7:0] = bin;
    x = x << 3;
    
    repeat(5)
    begin
        if (x[11:8] > 4)
            x[11:8] = x[11:8] + 3;
        if (x[15:12] > 4)
            x[15:12] = x[15:12] + 3;
        x = x << 1;
        
    end
    bcd = x[17:8];
end


endmodule
