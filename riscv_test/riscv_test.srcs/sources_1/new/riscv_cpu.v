`timescale 10ns / 1ns



//****************************************************************ALU_ctrl_code************************************************************************************************

`define AND  4'b0000
`define OR   4'b0001
`define ADD  4'b0010
`define SLTU 4'b0011//无符号数的比较
`define SUB  4'b0110
`define SLT  4'b0111
`define XOR  4'b1000
`define NOR  4'b1100


`define and_aluop_raw    3'b000
`define or_aluop_raw     3'b001
`define add_aluop_raw    3'b010
`define sltu_aluop_raw	 3'b011
`define R_type_aluop_raw 3'b100
`define sub_aluop_raw	 3'b110
`define slt_aluop_raw	 3'b111
`define xor_aluop_raw	 3'b101

//****************************************************************R_type************************************************************************************************

//****************************************************************I_type************************************************************************************************

//****************************************************************S_type************************************************************************************************

//****************************************************************B-type************************************************************************************************

//****************************************************************U_type************************************************************************************************
`define lui_opcode		7'b0110111
`define auipc_opcode	7'b0010111

`define lui_out			11'b10101000010
//****************************************************************J_type************************************************************************************************

module riscv_cpu(
	input  rst,
	input  clk,

	//Instruction request channel
	output [31:0] PC,
	output reg Inst_Req_Valid,
	input Inst_Req_Ack,

	//Instruction response channel
	input  [31:0] Instruction,
	input Inst_Valid,
	output reg Inst_Ack,

	//Memory request channel
	output reg [31:0] Address,
	output reg MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,
	output reg MemRead,
	input Mem_Req_Ack,

	//Memory data response channel
	input  [31:0] Read_data,
	input Read_data_Valid,
	output reg Read_data_Ack
);

	// TODO: Please add your logic code here

//******************************wire & reg definition************************************************************

	wire [6:0] opcode;
	wire [10:0] control_data;

	wire DonotJump;
	wire RegDst;
	wire ALUsrc;
	wire MemtoReg;
	wire RegWrite;
//  wire MemRead has already been defined
//  wire MemWrite has already been defined
	wire MemRead_wire;
	wire MemWrite_wire;
	wire Branch;
	wire [2:0] ALUop_raw;
	wire [3:0] ALUop;

	wire [4:0] rd_address;
	wire [4:0] rs1_address;
	wire [4:0] rs2_address;


//*****************************assignment************************************************************************
	assign control_data = ;
	assign DonotJump 	 = control_data[10];
	assign RegDst    	 = control_data[9];
	assign ALUsrc    	 = control_data[8];
	assign MemtoReg  	 = control_data[7];
	assign RegWrite		 = control_data[6];
	assign MemRead_wire  = control_data[5];
	assign MemWrite_wire = control_data[4];
	assign Branch    	 = control_data[3];
	assign ALUop_raw 	 = control_data[2:0];
endmodule
