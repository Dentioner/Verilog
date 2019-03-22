`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/22 14:05:28
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




`define DATA_WIDTH 32

module alu_test
();

	reg [`DATA_WIDTH - 1:0] A;
	reg [`DATA_WIDTH - 1:0] B;
	reg [2:0] ALUop;
	wire Overflow;
	wire CarryOut;
	wire Zero;
	wire [`DATA_WIDTH - 1:0] Result;

	initial
	begin
		// TODO: Please add your testbench here
	end

	alu u_alu(
		.A(A),
		.B(B),
		.ALUop(ALUop),
		.Overflow(Overflow),
		.CarryOut(CarryOut),
		.Zero(Zero),
		.Result(Result)
	);

endmodule


