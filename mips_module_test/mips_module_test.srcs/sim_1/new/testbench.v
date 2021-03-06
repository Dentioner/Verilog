`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/11 19:08:35
// Design Name: 
// Module Name: testbench
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

`define sll_funct  6'b000000
`define srl_funct  6'b000010
`define sra_funct  6'b000011
`define sllv_funct 6'b000100
`define srlv_funct 6'b000110
`define srav_funct 6'b000111

module testbench();
	reg [5:0] funct;
	reg [4:0] shamt;
	reg [31:0] alu_a_raw;
	reg [31:0] alu_b_raw;
	wire [31:0] alu_a;
	wire [31:0] alu_b;
	wire [7:0] answer;
	reg clk;
	wire [1:0] test_signal;
	reg [1:0] test_signal_r;
	wire testcase;
	reg clk_past;
	reg [31:0] counter;

	localparam justtest = 32'b1;
initial
begin
	shamt = 5'b0;
	alu_a_raw = {$random};
	alu_b_raw = {$random};//32'b00000000_00000000_00000000_00000000;
	clk = 1'b0;
	funct = `sll_funct;
	counter = 0;
	#20 funct = `srl_funct;
	#20 funct = `sra_funct;
	#20 funct = `sllv_funct;
	#20 funct = `sllv_funct;
	#20 funct = `srlv_funct;
	#20 funct = `srav_funct; 
end

assign test_signal = 3;

always #5 clk = ~clk;
always @(posedge clk) 
	shamt = {$random}%5;

always @*
begin
	
	case(test_signal)
	1: test_signal_r <= 1;
	2: test_signal_r <= 2;
	3: test_signal_r <= 3;
	0: test_signal_r <= 0;
	endcase

end

	always @(clk)
		clk_past <= ~clk;//人为实现上升沿

always @*
begin
	if (clk && !clk_past)
	counter = counter + 1; 
end

	shifter s1(funct, shamt, alu_a_raw, alu_b_raw, alu_a, alu_b);
	//shifter_two s2(.shamt(shamt), .answer(answer));



endmodule
