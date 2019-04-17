`timescale 10ns / 1ns

module	test();
reg rst;
reg clk;
wire [31:0] PC;
reg [31:0] Instruction;
wire [31:0] Address;
wire MemWrite;
wire [31:0] Write_data;
wire [3:0] Write_strb;
reg [31:0] Read_data;
wire MemRead; 

initial
begin
	rst = 1;
	clk = 0;
	//Instruction = 32'b001001_00000_11010_00000_00000_000001;
	Instruction = 32'b00101100010000100000000000001110;
	Read_data = 32'b0;
	#1 rst = 0;
	//#19 Instruction = 32'b00010111010000000000000000000010;
end

always #10 clk = ~clk;


mips_cpu m1(rst, clk, PC, Instruction, Address, MemWrite, Write_data, Write_strb, Read_data, MemRead);

endmodule