`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/22 10:44:45
// Design Name: 
// Module Name: calculator
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


module calculator(A, B, opcode, out);
input [7:0]A, B;
input [2:0]opcode;
output reg [8:0]out;
reg [7:0]a;
reg fuhao;
reg mod = 2'b11;
parameter Jia = 3'b000;
parameter Jian = 3'b001;
parameter Yu = 3'b010;
parameter Huo  = 3'b011;
parameter Fan = 3'b100; 
parameter Zuoyi = 3'b101; 
parameter Youyi = 3'b110;
parameter Yihuo = 3'b111;     
always@*
begin
    case(opcode)
        Jia: 
            begin
                a = A + B;
                fuhao = 0;
                out = {fuhao, a};
            end
        Jian: 
            begin
                a = (A>B)?(A-B):(B-A);
                fuhao = (A>B)?1'b0:1'b1;
                out = {fuhao, a};
            end
        Yu: 
            begin
                a = A&B;
                fuhao = 1'b0;
                out = {fuhao, a}; 
            end
        Huo: 
            begin
                a= A|B;
                fuhao = 1'b0;
                out = {fuhao, a};
            end
        Fan: 
            begin
                a = ~A;
                fuhao = 1'b0;
                out = {fuhao, a};
            end
        Zuoyi: 
            begin
                
                a = A<<B[1:0];
                fuhao = 1'b0;
                out = {fuhao, a};
            end
        Youyi: 
            begin
                //mod = B%4;
                a = A>>2;
                fuhao = 1'b0;
                out = {fuhao, a};
            end
        Yihuo: 
            begin
                a = A^B;
                fuhao = 1'b0;
                out = {fuhao, a};
            end
        default: 
            begin
                a = 0;
                fuhao = 1'b0;
                out = {fuhao, a};
            end
    endcase
end
endmodule
