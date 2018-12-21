`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/02 20:15:14
// Design Name: 
// Module Name: dff
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


module dff(clk, d, q);
input clk, d;
output reg q;
always @ (posedge clk)
begin
    q <= d;
end
endmodule

module dff2(clk, d, reset, q);
input clk, d, reset;
output reg q;
always @(posedge clk , reset)
begin
    if (reset)
        q <= 1'b0;
    else
        q <= d;
end
endmodule


module dff3(clk, d, reset, en, q);
input clk, d, reset, en;
output reg q;
always @ (posedge clk, reset)
begin
    if (reset)
        q <= 1'b0;
    else
    begin
        if (en)
            q <= d;
    end
end
endmodule


module dff4(clk, d, reset, en, q);
input clk, d, reset, en;
output reg q;
wire r_next, r_reg;
always @(posedge clk , reset)
begin
    if (reset)
        q <= 1'b0;
    else
        q <= r_next;
end
mux2 m1 (d, r_reg, en, r_next);
assign r_next = q;
endmodule

module mux2(d, r_reg, en, r_next);
input d, r_reg, en;
output r_next;
assign r_next = en?d:r_reg;
endmodule
//p86~p87 It doesn't work