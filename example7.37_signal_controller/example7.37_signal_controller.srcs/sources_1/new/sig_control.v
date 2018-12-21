`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/17 10:44:17
// Design Name: 
// Module Name: sig_control
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
`define TRUE 1'b1
`define FALSE 1'b0
`define Y_TO_R_READY 3
`define R_TO_G_READY 2



module sig_control(hwy, cntry, x, clk, clear);
output reg [1:0]hwy, cntry;
input clk, clear;
input x;
reg [2:0] next_state;
reg [2:0] state;
parameter RED = 2'd0;
parameter YELLOW = 2'd1;
parameter GREEN = 2'd2;
//        state     //HWY           CNT
parameter S0 = 3'd0,//Green         Red
          S1 = 3'd1,//Yellow        Red
          S2 = 3'd2,//Red           Red
          S3 = 3'd3,//Red           Green
          S4 = 3'd4;//Red           Yellow


always@(posedge clk)
begin
    if (clear)
        state <= S0;
    else
        state <= next_state;
end

always@(state)
begin
    hwy = GREEN;
    cntry = RED;
    case(state)
        S0: ;
        S1: hwy = YELLOW;
        S2: hwy = RED;
        S3: begin
                hwy = RED;
                cntry = GREEN;
            
        
            end
        S4: begin
                hwy = RED;
                cntry = YELLOW;
            end
    endcase

            
            
end


always@(state or x)
begin
    case(state)
        S0: begin
                if(x) 
                    next_state = S1;
                else 
                    next_state = S0;
            end
        S1: begin
                repeat(`Y_TO_R_READY) @(posedge clk);
                next_state = S2;
            end
        S2: begin
                repeat(`R_TO_G_READY)@(posedge clk);
                next_state = S3;
            end
        S3: begin
                if(x) 
                    next_state = S3;
                else 
                    next_state = S4;
            end
        S4: begin
                repeat(`Y_TO_R_READY)@(posedge clk);
                next_state = S0;
            
            end
        default: next_state = S0;
    endcase
end



       
endmodule
