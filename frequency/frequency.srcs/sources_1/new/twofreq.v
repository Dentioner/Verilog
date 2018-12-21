`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/27 10:11:43
// Design Name: 
// Module Name: twofreq
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


module twofreq(clk, out, tout);
input clk;
output reg out = 0;
output reg tout;
reg x = 0;
reg y = 0;
reg [2:0]i = 3'b000;
always@(posedge clk)
begin
    out <= ~out;
    
    
end
/*
always@(negedge clk)
begin
   
    if (i == 3'b001)
        begin
            y <= ~y;
          
        end
        else if (i == 3'b100)
            begin
            y <= ~y;
           
            end
       
end
*/
always@(posedge clk)
begin
    if (i == 3'b001)
    begin 
       
        i = i+ 1;
    end
    else if (i == 3'b101)
        begin
            
            i = 3'b000;
        end    
    else
        i = i + 1;
end 

always@(clk)
begin
    if (i == 3'b001)
    begin 
        x = 1;
   
    end
     else if (i == 3'b000)
           y = 1;    
    else if (i == 3'b101)
        begin
            x = 0;
           
        end    
   else if (i == 3'b100)
       y = 0;
end

always@*
tout <= y & x;
endmodule
