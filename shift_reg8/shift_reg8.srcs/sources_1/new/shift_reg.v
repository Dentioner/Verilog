`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 19:27:08
// Design Name: 
// Module Name: shift_reg
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


module shift_reg(clk, load, din, qb);
input clk, load;
input [7:0]din;
output qb;
reg [7:0]a;
always @ (posedge clk)
begin
    if (load)
        a <= din;
    else
       a[6:0] <= a[7:1];
       
end
assign qb = a[0];
endmodule

module univ_shift_reg
#(parameter N = 8)
(clk, reset, ctrl, d, q);
input clk, reset;
input [1:0]ctrl;
input [N-1:0]d;
output [N-1:0]q;
reg [N-1:0]r_reg, r_next;

always @ (posedge clk, reset)
begin
    if (reset)
        r_reg <= 0;
    else
        r_reg <= r_next;
end
always @*
begin
    case(ctrl)
        2'b00: r_next = r_reg;
        2'b01: r_next = {r_reg[N-2:0], d[0]};
        2'b10: r_next = {d[N-1], r_reg[N-1:1]};
        default: r_next = d;
    endcase
end
assign q = r_reg;
endmodule
