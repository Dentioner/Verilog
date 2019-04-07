`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/07 16:43:43
// Design Name: 
// Module Name: aluctl
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


module ALU_controller(
	input [5:0] funct,
	input [1:0]	ALUop_raw,
	output [3:0] ALUop
);
	localparam ADD = 4'b0010;
	localparam SUB = 4'b0110;
	localparam AND = 4'b0000;
	localparam OR  = 4'b0001;;

	localparam SLT = 4'b0111;

	assign ALUop = (ALUop_raw == 2'b00)?ADD:(
					(ALUop_raw[0] == 1'b1)?SUB:(
					(ALUop_raw[1] == 1'b1)?(
					(funct[3:0] == 4'b0000)?ADD:(
					(funct[3:0] == 4'b0010)?SUB:(
					(funct[3:0] == 4'b0100)?AND:(
					(funct[3:0] == 4'b0101)?OR :(
					(funct[3:0] == 4'b1010)?SLT:4'bzzzz))))):4'bzzzz));

endmodule