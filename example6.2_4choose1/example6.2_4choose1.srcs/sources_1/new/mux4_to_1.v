`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/09 21:01:46
// Design Name: 
// Module Name: mux4_to_1
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


module mux4_to_1(out, i0, i1, i2, i3, s1, s0);
output out;
input i0, i1, i2, i3;
input s1, s0;

assign out = (~s1 & ~s0 & i0)|  //00
            (~s1 & s0 & i1)|    //01
            (s1 & ~s0 & i2)|    //10
            (s1 & s0 & i3);     //11

endmodule


module mux4_to_1_ver2(out, i0, i1, i2, i3, s1, s0);
output out;
input i0, i1, i2, i3;
input s1, s0;

assign out = s1 ? (s0?i3:i2):(s0?i1:i0);
endmodule