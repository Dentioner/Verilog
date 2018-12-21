`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/26 21:26:04
// Design Name: 
// Module Name: encoder2
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


module encoder2(in, out);
input [7:0]in;
output reg [2:0]out;

always@*
begin
    casez(in)
    8'b00000001: out <= 3'b000;
    8'b0000001z: out <= 3'b001;
    8'b000001zz: out <= 3'b010;
    8'b00001zzz: out <= 3'b011;
    8'b0001zzzz: out <= 3'b100;
    8'b001zzzzz: out <= 3'b101;
    8'b01zzzzzz: out <= 3'b110;
    8'b1zzzzzzz: out <= 3'b111;
    default:
    begin
        out <= 3'b000;
        $display("error\n");
    end
    endcase
    
end

endmodule
