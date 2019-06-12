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
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [19:0] U_type_imm;//u型指令使用的立即数


	wire [31:0] symbol_extension;
	wire [31:0] alu1_a_raw;
	wire [31:0] alu1_b_raw;

	wire [31:0] alu1_a;
	wire [31:0] alu1_b;
	wire [31:0] alu2_a;
	wire [31:0] alu2_b;
	wire Zero_raw;//原始的Zero信号
	wire Zero_input_to_alu2;//Zero_raw信号需要经过处理才能变成正式的信号输送给第二个alu，也就是为了区分bne和beq两种指令而设置的
	wire [31:0] alu1_result;
	wire [31:0] alu2_result;
//以上是两个alu的有用的wire
	wire alu1_overflow;	
	wire alu1_carryout;
	

	wire			RF_wen;
	wire [4:0]		RF_waddr;
	wire [31:0]		RF_wdata;
	wire [4:0]		RF_raddr1;
	wire [4:0]		RF_raddr2;
	wire [31:0]		RF_rdata1;
	wire [31:0]		RF_rdata2;
//以上是寄存器堆使用的wires


	reg [31:0] Instruction_Register;


//*****************************assignment for controlling signals************************************************************************
	assign opcode 		= Instruction_Register[6:0];
	assign rd_address 	= Instruction_Register[11:7];
	assign funct3		= Instruction_Register[14:12];
	assign rs1_address	= Instruction_Register[19:15];
	assign rs2_address 	= Instruction_Register[24:20];
	assign funct7 		= Instruction_Register[31:25];

	assign U_type_imm 	= Instruction_Register[31:12];


	assign control_data = (opcode == `lui_opcode)?`lui_out:11'b1000000000;

	/*
	assign control_data =   (Instruction_Register[31:26] == `R_type_in)?`R_type_out:(
							(Instruction_Register[31:29] == `L_type_in)?`L_type_out:(
							(Instruction_Register[31:29] == `S_type_in)?`S_type_out:(			
						
							

							(Instruction_Register[31:26] == `beq_in)   ?`B_type_out:(
							(Instruction_Register[31:26] == `bgez_in)  ?`B_type_out:(
							(Instruction_Register[31:26] == `blez_in)  ?`B_type_out:(
							(Instruction_Register[31:26] == `bltz_in)  ?`B_type_out:(
							(Instruction_Register[31:26] == `bgtz_in)  ?`B_type_out:(
							(Instruction_Register[31:26] == `bne_in)   ?`B_type_out:(

							(Instruction_Register[31:26] == `addiu_in) ?`addiu_out :(							
							(Instruction_Register[31:26] == `lui_in)   ?`lui_out   :(							
							(Instruction_Register[31:26] == `andi_in)  ?`andi_out  :(
							(Instruction_Register[31:26] == `ori_in)   ?`ori_out   :(					
							(Instruction_Register[31:26] == `xori_in)  ?`xori_out  :(
							(Instruction_Register[31:26] == `slti_in)  ?`slti_out  :(
							(Instruction_Register[31:26] == `sltiu_in) ?`sltiu_out :(

							(Instruction_Register[31:26] == `jal_in)   ?`jal_out   :(
							(Instruction_Register[31:26] == `j_in)	   ?`j_out	  :11'b1000000000)))))))))))))))));


	*/
	assign DonotJump 	 = control_data[10];
	assign RegDst    	 = control_data[9];
	assign ALUsrc    	 = control_data[8];
	assign MemtoReg  	 = control_data[7];
	assign RegWrite		 = control_data[6];
	assign MemRead_wire  = control_data[5];
	assign MemWrite_wire = control_data[4];
	assign Branch    	 = control_data[3];
	assign ALUop_raw 	 = control_data[2:0];


	assign symbol_extension = (opcode == `lui_opcode)?{U_type_imm, 12'b0}:;

	/*
	assign symbol_extension = (Instruction_Register[31:26] == `lui_in)?{Instruction_Register[15:0], 16'b0}:(
							  (Instruction_Register[31:26] == `sltiu_in || 
							  	Instruction_Register[31:26] == `andi_in ||
							  	Instruction_Register[31:26] == `xori_in || 
							  	Instruction_Register[31:26] == `ori_in)?{16'b0, Instruction_Register[15:0]}:
							{{16{Instruction_Register[15]}}, Instruction_Register[15:0]});//如果是lui指令则做左移，否则符号拓展

	*/


	assign alu1_b_raw = (ALUsrc == 1)?symbol_extension:;
	/*
	assign alu1_b_raw = (ALUsrc == 1)?symbol_extension:(
						(Instruction_Register[31:26] == `R_type_in && funct == `movn_funct)?32'b0://如果ALUSrc=0，说明操作数b不是16位那边过来的，这时候再判断是不是在执行movn指令，
						RF_rdata2);//如果是movn，则将操作数b变成0，否则照常输入RF_data2
						//此为寄存器堆右边的数据选择器
	*/

//*****************************assignment for register files************************************************************************
	

	assign RF_wdata = alu1_result;
	/*
	assign RF_wdata = (Instruction_Register[31:26] == `jal_in)?(PC_reg+8):(
						(MemtoReg == 1)?(
						((Instruction_Register[31:29] == `L_type_in && in_funct == `lb_in_funct) || 
						 (Instruction_Register[31:29] == `L_type_in && in_funct == `lh_in_funct))?Read_data_symbol_extension:(

						((Instruction_Register[31:29] == `L_type_in && in_funct == `lbu_in_funct) || 
						 (Instruction_Register[31:29] == `L_type_in && in_funct == `lhu_in_funct))?Read_data_logical_extension:(

						(Instruction_Register[31:29] == `L_type_in && in_funct == `lwl_in_funct)?(
							(vAddr10 == 2'b00)?{Read_data_reg[7:0], RF_rdata2[23:0]}:(
							(vAddr10 == 2'b01)?{Read_data_reg[15:0], RF_rdata2[15:0]}:(
							(vAddr10 == 2'b10)?{Read_data_reg[23:0], RF_rdata2[7:0]}:Read_data_reg))):(
						(Instruction_Register[31:29] == `L_type_in && in_funct == `lwr_in_funct)?(
							(vAddr10 == 2'b00)?Read_data_reg:(
							(vAddr10 == 2'b01)?{RF_rdata2[31:24], Read_data_reg[31:8]}:(
							(vAddr10 == 2'b10)?{RF_rdata2[31:16], Read_data_reg[31:16]}:{RF_rdata2[31:8], Read_data_reg[31:24]}))):Read_data_reg))
						)):alu1_result);//先判断是否是直接将PC+8塞进去的指令，然后再判断别的
	*/


	assign RF_waddr = (RegDst == 1)?:rd_address;
	//regdst=0的时候地址为rd

	/*
	assign RF_waddr = (Instruction_Register[31:26] == `jal_in)?31:(
						(RegDst == 1)?Instruction_Register[15:11]:Instruction_Register[20:16]);//此为样例图寄存器堆左边的数据选择器
	*/



//*****************************sub_modules************************************************************************
	ALU_controller act1(.funct(funct), .ALUop_raw(ALUop_raw), .ALUop(ALUop));//书上样例的“ALU控制”模块
	shifter s1(.funct(funct), .shamt(shamt), .alu_a_raw(alu1_a_raw), .alu_b_raw(alu1_b_raw), .typecode(Instruction_for_submodule[31:26]), .alu_a(alu1_a), .alu_b(alu1_b));//最下面新增的移位模块


	alu alu1(.A(alu1_a), .B(alu1_b), .ALUop(ALUop), .Zero(Zero_raw),  .Result(alu1_result), .Overflow(alu1_overflow), .CarryOut(alu1_carryout));//overflow 和 carryout的信号暂时没引出
	//alu alu2(.A_raw(alu2_a), .B_raw(alu2_b), .ALUop(`ADD),   .Zero(alu2_zero), .Result(alu2_result), .Overflow(alu2_overflow), .CarryOut(alu2_carryout));//Zero, overflow 和 carryout的信号暂时没引出, 此alu一直当做加法器使用
	assign alu2_result = alu2_a + alu2_b;
	//上面两个alu，第一个是样例图里面右下方的alu，第二个是样例图右上方的alu

	reg_file r1(.clk(clk), .rst(rst), .waddr(RF_waddr), .raddr1(RF_raddr1), .raddr2(RF_raddr2), .wen(RF_wen), .wdata(RF_wdata_final), .rdata1(RF_rdata1), .rdata2(RF_rdata2));    //, .Write_strb(Write_strb_for_reg_file));
	//此为样例图里面的寄存器堆




endmodule



module ALU_controller(
	input [5:0] funct,
	input [2:0]	ALUop_raw,
	output [3:0] ALUop
);
	//localparam ADD = 4'b0010;
	//localparam SUB = 4'b0110;
	//localparam AND = 4'b0000;
	//localparam OR  = 4'b0001;

	//localparam SLT = 4'b0111;

	assign ALUop = (ALUop_raw == `add_aluop_raw)?`ADD:(
					(ALUop_raw == `sub_aluop_raw)?`SUB:(
					(ALUop_raw == `and_aluop_raw)?`AND:(
					(ALUop_raw == `slt_aluop_raw)?`SLT:(
					(ALUop_raw == `or_aluop_raw)?`OR:(
					(ALUop_raw == `sltu_aluop_raw)?`SLTU:(
					(ALUop_raw == `xor_aluop_raw)?`XOR:(
					(ALUop_raw == `R_type_aluop_raw)?(
						
					(funct == `sll_funct  || 
					 funct == `addu_funct || 
					 funct == `jr_funct   || 
					 funct == `jalr_funct || 
					 funct == `movn_funct ||
				 	 funct == `srl_funct  ||
				 	 funct == `sllv_funct ||
					 funct == `sra_funct  ||
					 funct == `srav_funct ||
					 funct == `srlv_funct ||
					 funct == `movz_funct)?`ADD:(
					//(funct[3:0] == 4'b0010)?`SUB:(
					(funct == `subu_funct)?`SUB:(
					(funct == `and_funct)?`AND:(
					(funct == `or_funct)?`OR :(
					(funct == `nor_funct)?`NOR:(
					(funct == `xor_funct)?`XOR:(
					(funct == `sltu_funct)?`SLTU:(
					(funct == `slt_funct)?`SLT:4'b1111)))))))):4'b1111)))))));

endmodule


module shifter(
	input [5:0] funct,
	input [4:0] shamt,
	input [31:0] alu_a_raw,
	input [31:0] alu_b_raw,
	input [5:0] typecode,
	output [31:0] alu_a,
	output [31:0] alu_b
);
	//wire [31:0] shift_number;

	wire [31:0] sll_answer;
	wire [31:0] srl_answer;
	wire [31:0] sra_answer;
	wire [31:0] sllv_answer;
	wire [31:0] srlv_answer;
	wire [31:0] srav_answer;

	assign alu_a = (typecode == `R_type_in)?(
				   (funct == `sll_funct ||
					funct == `srl_funct ||
					funct == `sra_funct ||
					funct == `sllv_funct ||
					funct == `srlv_funct ||
					funct == `srav_funct)?32'b0:alu_a_raw):alu_a_raw;//如果是Rtype的这6种功能的话，alu的a端口不输入加数

					

	assign sll_answer  = alu_b_raw << shamt;
	assign srl_answer  = alu_b_raw >> shamt;
	//assign sra_answer  = {{shamt{alu_b_raw[31]}}, alu_b_raw[31:32-shamt]};
	assign sra_answer = (alu_b_raw[31])?(~((~alu_b_raw) >> shamt)):srl_answer;//取反逻辑右移之后再取反就行了
	assign sllv_answer = alu_b_raw << alu_a_raw[4:0];
	assign srlv_answer = alu_b_raw >> alu_a_raw[4:0];
	//assign srav_answer = {{alu_a_raw{alu_b_raw[31]}}, alu_b_raw[31:32 - alu_a_raw]};
	assign srav_answer = (alu_b_raw[31])?(~((~alu_b_raw) >> alu_a_raw[4:0])):srlv_answer;





	assign alu_b = (typecode == `R_type_in)?(
				    (funct == `sll_funct)?  sll_answer:(
					(funct == `srl_funct)?  srl_answer:(
					(funct == `sra_funct)?  sra_answer:(
					(funct == `sllv_funct)?sllv_answer:(
					(funct == `srlv_funct)?srlv_answer:(
					(funct == `srav_funct)?srav_answer:alu_b_raw)))))):alu_b_raw; 

	

	

endmodule


