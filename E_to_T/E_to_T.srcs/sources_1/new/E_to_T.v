`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/15 11:18:31
// Design Name: 
// Module Name: E_to_T
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


module E_to_T(I, Y, S, Y_S, Y_EX);
input [7:0]I;
input S;
output reg[2:0]Y;
output reg Y_S, Y_EX;
wire [7:0]Ibar = ~I;
wire Sbar = ~S;
reg [2:0]Ybar;
reg Y_Sbar;
reg Y_EXbar;
always@*
begin
    Y = ~Ybar;
    Y_S = ~Y_Sbar;
    Y_EX = ~Y_EXbar;
    
end
always @*
begin
    if (Sbar == 1)
    begin
        Ybar = 3'b111;
        Y_Sbar = 1;
        Y_EXbar = 1;
    end
    else
    begin
        if (Ibar[7] == 0)
        begin
            Ybar = 3'b000;
            Y_Sbar = 1;
            Y_EXbar = 0; 
        end
        else if (Ibar[6] == 0)
        begin
            Ybar = 3'b001;
            Y_Sbar = 1;
            Y_EXbar = 0;
        end

        else if (Ibar[5] == 0)
        begin
            Ybar = 3'b010;
            Y_Sbar = 1;
            Y_EXbar = 0;
        end
        
        else if (Ibar[4] == 0)
        begin
            Ybar = 3'b011;
            Y_Sbar = 1;
            Y_EXbar = 0;
        end
        
        else if (Ibar[3] == 0)
        begin
            Ybar = 3'b100;
            Y_Sbar = 1;
            Y_EXbar = 0;
        end
        
        else if (Ibar[2] == 0)
        begin
            Ybar = 3'b101;
            Y_Sbar = 1;
            Y_EXbar = 0;
        end
        
        else if (Ibar[1] == 0)
        begin
            Ybar = 3'b110;
            Y_Sbar = 1;
            Y_EXbar = 0;
        end
        
        else if (Ibar[0] == 0)
        begin
            Ybar = 3'b111;
            Y_Sbar = 1;
            Y_EXbar = 0;
        end
        else 
        begin
            Ybar = 3'b111;
            Y_Sbar = 0;
            Y_EXbar = 1;
        end
    end
end

endmodule
