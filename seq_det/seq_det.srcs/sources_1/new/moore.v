`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 20:56:36
// Design Name: 
// Module Name: moore
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


module moore(clk, reset, din, sout);
input clk, reset, din;
output sout;
localparam[2:0]
    s0 = 3'b000,
    s1 = 3'b001,
    s2 = 3'b010,
    s3 = 3'b011,
    s4 = 3'b100;
reg [2:0]cs, nst;

always @ (posedge clk, posedge reset)
    if (reset)
        cs <= s0;
    else
        cs <= nst;

always @ *
begin
    case(cs)
        s0:
            if (din == 1'b1)
                nst = s1;
            else
                nst = s0;
        s1:
            if (din == 1'b1)
                nst = s2;
            else
                nst = s0;  
        s2:
            if (din == 1'b1)
                nst = s2;
            else
                nst = s3;                                      
        s3:
            if (din == 1'b1)
                nst = s4;
            else
                nst = s0;
        s4:
            if (din == 1'b1)
                nst = s1;
            else
                nst = s0;
        default:
            nst = s0;
    endcase
end

assign sout = (cs == s4)?1:0;
endmodule


module mealy(clk, reset, din, sout);
input clk, reset, din;
output reg sout;
localparam[1:0]
    s0 = 2'b00,
    s1 = 2'b01,
    s2 = 2'b10,
    s3 = 2'b11;
reg [1:0]cs, nst;
always @ (posedge clk, posedge reset)
    if (reset)
        cs <= s0;
    else
        cs <= nst;
always @ *
begin
    case(cs)
        s0:
            if (din == 1'b1)
                nst = s1;
            else
                nst = s0;
        s1:
            if (din == 1'b1)
                nst = s2;
            else
                nst = s0;
        s2:
            if (din == 1'b1)
                nst = s2;
            else
                nst = s3;        
        s3:
            nst = s0;
        default:
            nst = s0;
    endcase
end
always @*
begin
    if (reset == 0)
        sout = 0;
    if ((cs == s3) && (din == 1'b1))
        sout = 1;
    else
        sout = 0;
end

endmodule