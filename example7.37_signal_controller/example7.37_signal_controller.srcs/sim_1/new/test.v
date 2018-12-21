`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/17 11:15:08
// Design Name: 
// Module Name: test
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


module test();
wire [1:0] MAIN_SIG, CNTRY_SIG;
reg CAR_ON_CNTRY_RD;
reg clk, clear;

initial 
    $monitor ($time, "Main Sig = %b Country Sig = %b Car_on_country = %b", MAIN_SIG, CNTRY_SIG, CAR_ON_CNTRY_RD);
initial
begin
    clk = `FALSE;
    forever #5 clk = ~clk;
    
end
initial 
begin
    clear = `TRUE;
    repeat(5)@(negedge clk);
    clear = `FALSE;
end

initial
begin
    CAR_ON_CNTRY_RD = `FALSE;
    repeat (20)@(negedge clk); CAR_ON_CNTRY_RD = `TRUE;
    repeat (10)@(negedge clk); CAR_ON_CNTRY_RD = `FALSE;
    
    repeat (20)@(negedge clk); CAR_ON_CNTRY_RD = `TRUE;
    repeat (10)@(negedge clk); CAR_ON_CNTRY_RD = `FALSE;

    repeat (20)@(negedge clk); CAR_ON_CNTRY_RD = `TRUE;
    repeat (10)@(negedge clk); CAR_ON_CNTRY_RD = `FALSE;
    
    repeat(10)@(negedge clk);$stop;
end


sig_control s1(MAIN_SIG, CNTRY_SIG, CAR_ON_CNTRY_RD, clk,clear);
endmodule
