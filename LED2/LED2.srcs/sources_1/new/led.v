`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/25 10:50:14
// Design Name: 
// Module Name: led
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


module led(
    input             clk,
    input             resetn,
    //output reg [3:0] led
    output reg [7:0] led
);
parameter CNT_1S = 27'd99_999_999;

reg [26:0] cnt;
wire cnt_eq_1s;

assign cnt_eq_1s = cnt==CNT_1S;

always @(posedge clk)
begin
    if (!resetn)
    begin
        cnt <= 27'd0;
    end
    else if (cnt_eq_1s)
    begin
        cnt <= 27'd0;
    end
    else
    begin
        cnt <= cnt + 1'b1;
    end
end

always @(posedge clk)
begin
    if (!resetn)
    begin
        led <= 8'b10000000;
    end
    else if (cnt_eq_1s)
    begin
        led <= {led[0],led[7:1]};
    end
end
endmodule