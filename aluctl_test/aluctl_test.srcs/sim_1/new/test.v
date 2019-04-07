`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/07 16:44:19
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


module test();
reg [5:0] funct;
reg [1:0]	ALUop_raw;
wire [3:0] ALUop;	

initial
begin
	funct = 6'b000010;
	ALUop_raw = 2'b01;
end


ALU_controller a1(funct, ALUop_raw, ALUop);

endmodule
