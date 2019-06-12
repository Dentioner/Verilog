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


	//下面这堆assign是书上样例的“控制”模块
	assign control_data =   (opcode == `R_type_in)?`R_type_out:(
							(Instruction_Register[31:29] == `L_type_in)?`L_type_out:(
							(Instruction_Register[31:29] == `S_type_in)?`S_type_out:(			
						
							

							(opcode == `beq_in)   ?`B_type_out:(
							(opcode == `bgez_in)  ?`B_type_out:(
							(opcode == `blez_in)  ?`B_type_out:(
							(opcode == `bltz_in)  ?`B_type_out:(
							(opcode == `bgtz_in)  ?`B_type_out:(
							(opcode == `bne_in)   ?`B_type_out:(

							(opcode == `addiu_in) ?`addiu_out :(							
							(opcode == `lui_in)   ?`lui_out   :(							
							(opcode == `andi_in)  ?`andi_out  :(
							(opcode == `ori_in)   ?`ori_out   :(					
							(opcode == `xori_in)  ?`xori_out  :(
							(opcode == `slti_in)  ?`slti_out  :(
							(opcode == `sltiu_in) ?`sltiu_out :(

							(opcode == `jal_in)   ?`jal_out   :(
							(opcode == `j_in)	   ?`j_out	  :11'b1000000000)))))))))))))))));



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

	assign funct = Instruction_Register[5:0];
	assign shamt = Instruction_Register[10:6];

	assign in_funct = Instruction_Register[28:26];


	

//下面这堆assign是寄存器堆使用的
	assign RF_raddr1 = Instruction_Register[25:21];
	assign RF_raddr2 = Instruction_Register[20:16];//这个raddr2可能还要改，因为样例图里面好像有Instruction_Register20~16不进人raddr2的
	

	assign RF_waddr = (opcode == `jal_in)?31:(
						(RegDst == 1)?Instruction_Register[15:11]:Instruction_Register[20:16]);//此为样例图寄存器堆左边的数据选择器
	

	assign RF_wen_before_always = 
					(RF_waddr == 32'b0)?1'b0:(
					(opcode == `R_type_in && funct == `movn_funct && RF_rdata2 == 32'b0)?1'b0:(//如果执行的是movn指令，而且rt=0时，写使能低电平
					(opcode == `R_type_in && funct == `movz_funct && RF_rdata2 != 32'b0)?1'b0://如果执行的是movz指令，而且rt≠0时，写使能低电平
					RegWrite));//好像仿真的时候认为写地址为0的时候是不能写的，
	//但是实际上在regfile模块里面都保证了写地址为0的时候不接受外来信号
	//为了让仿真通过只好再把这个地方加点条件保证RF_wen不能在写地址为0的时候=1了。

//下面这堆assign是两个alu使用的
	assign alu1_a_raw = (opcode == `R_type_in && funct == `jalr_funct)?(add_result + 4):RF_rdata1;//这里如果发现指令是jalr，直接将PC+4塞到A输入端即可
	assign alu1_b_raw = (ALUsrc == 1)?symbol_extension:(
						(opcode == `R_type_in && funct == `movn_funct)?32'b0://如果ALUSrc=0，说明操作数b不是16位那边过来的，这时候再判断是不是在执行movn指令，
						RF_rdata2);//如果是movn，则将操作数b变成0，否则照常输入RF_data2
						//此为寄存器堆右边的数据选择器
	assign alu2_a = add_result;
	assign alu2_b = symbol_extension<<2;//符号扩展信号左移2位


//下面这堆assign是样例图寄存器下面的“符号扩展”模块
	assign symbol_extension = (opcode == `lui_in)?{Instruction_Register[15:0], 16'b0}:(
							  (opcode == `sltiu_in || 
							  	opcode == `andi_in ||
							  	opcode == `xori_in || 
							  	opcode == `ori_in)?{16'b0, Instruction_Register[15:0]}:
							{{16{Instruction_Register[15]}}, Instruction_Register[15:0]});//如果是lui指令则做左移，否则符号拓展

//下面这堆assign是给右上角的数据选择器用的
	assign Branch_after_AND = Branch & Zero_input_to_alu2;
	assign Zero_input_to_alu2 = (opcode == `bne_in)?~Zero_raw:(//Zero_raw对于bne需要处理一下
								(opcode == `bgez_in && Instruction_Register[20:16] == `regimm_bgez)?~RF_rdata1[31]:(
								(opcode == `bltz_in && Instruction_Register[20:16] == `regimm_bltz)?RF_rdata1[31]:(
								(opcode == `blez_in)?(RF_rdata1[31]|Zero_raw):(
								(opcode == `bgtz_in)?((!RF_rdata1[31])&(!Zero_raw)):
									Zero_raw))));
	assign PC_input_before_jump = (Branch_after_AND == 1)?alu2_result:add_result;

//下面这个是样例图左边的加法器
	assign add_result = PC_reg + 4;

//下面这个是样例图最右边主存旁边的数据选择器
	assign RF_wdata = (opcode == `jal_in)?(PC_reg+8):(
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

	assign Read_data_symbol_extension = (Instruction_Register[31:29] == `L_type_in && in_funct == `lb_in_funct)?(
											(vAddr10 == 2'b00)?{{24{Read_data_reg[7]}}, Read_data_reg[7:0]}:(
											(vAddr10 == 2'b01)?{{24{Read_data_reg[15]}}, Read_data_reg[15:8]}:(
											(vAddr10 == 2'b10)?{{24{Read_data_reg[23]}}, Read_data_reg[23:16]}:{{24{Read_data_reg[31]}}, Read_data_reg[31:24]}))):(
										(Instruction_Register[31:29] == `L_type_in && in_funct == `lh_in_funct)?(
											(vAddr10[1] == 1'b1)?{{16{Read_data_reg[31]}}, Read_data_reg[31:16]}:{{16{Read_data_reg[15]}}, Read_data_reg[15:0]}):Read_data_reg);//将8位/16位Read_data符号扩展
										

	assign Read_data_logical_extension = (Instruction_Register[31:29] == `L_type_in && in_funct == `lbu_in_funct)?(
											(vAddr10 == 2'b00)?{24'b0, Read_data_reg[7:0]}:(
											(vAddr10 == 2'b01)?{24'b0, Read_data_reg[15:8]}:(
											(vAddr10 == 2'b10)?{24'b0, Read_data_reg[23:16]}:{24'b0, Read_data_reg[31:24]}))):(
										(Instruction_Register[31:29] == `L_type_in && in_funct == `lhu_in_funct)?(
											(vAddr10[1] == 1'b1)?{16'b0, Read_data_reg[31:16]}:{16'b0, Read_data_reg[15:0]}):Read_data_reg);//将8位/16位Read_data高位加0拓展为32位


	//下面几个assign是为了实现lwl/lwr而设置的
	assign Write_strb_for_reg_file = (Instruction_Register[31:29] == `L_type_in && in_funct == `lwl_in_funct)?(
										(vAddr10 == 2'b00)?4'b1000:(
										(vAddr10 == 2'b01)?4'b1100:(
										(vAddr10 == 2'b10)?4'b1110:4'b1111))):(
									 (Instruction_Register[31:29] == `L_type_in && in_funct == `lwr_in_funct)?(
									 	(vAddr10 == 2'b00)?4'b1111:(
									 	(vAddr10 == 2'b01)?4'b0111:(
									 	(vAddr10 == 2'b10)?4'b0011:4'b0001))):4'b1111);
	assign vAddr10 = Address_raw[1:0];


//下面是样例图右边主存的一堆输出信号
	assign Address_raw = alu1_result;
	assign Address_align = Address_raw - vAddr10;
	assign Address_before_always =
					 ((Instruction_Register[31:29] == `L_type_in && in_funct == `lwl_in_funct)|| 
					  (Instruction_Register[31:29] == `L_type_in && in_funct == `lwr_in_funct)||
					  (Instruction_Register[31:29] == `S_type_in && in_funct == `swl_in_funct)||
					  (Instruction_Register[31:29] == `S_type_in && in_funct == `swr_in_funct)||
					  (Instruction_Register[31:29] == `S_type_in && in_funct == `sb_in_funct) ||
					  (Instruction_Register[31:29] == `S_type_in && in_funct == `sh_in_funct) ||
					  (Instruction_Register[31:29] == `L_type_in && in_funct == `lb_in_funct) ||
					  (Instruction_Register[31:29] == `L_type_in && in_funct == `lh_in_funct)
					  )?Address_align:Address_raw;


	assign Write_data = (Instruction_Register[31:29] == `S_type_in && in_funct == `swl_in_funct)?(
							(vAddr10 == 2'b00)?{24'b0, RF_rdata2[31:24]}:(
							(vAddr10 == 2'b01)?{16'b0, RF_rdata2[31:16]}:(
							(vAddr10 == 2'b10)?{8'b0,  RF_rdata2[31:8]}:RF_rdata2))):(
						(Instruction_Register[31:29] == `S_type_in && in_funct == `swr_in_funct)?(
							(vAddr10 == 2'b00)?RF_rdata2:(
							(vAddr10 == 2'b01)?{RF_rdata2[23:0], 8'b0}:(
							(vAddr10 == 2'b10)?{RF_rdata2[15:0], 16'b0}:{RF_rdata2[7:0], 24'b0}))):(
						(Instruction_Register[31:29] == `S_type_in && in_funct == `sb_in_funct )?(
							(vAddr10 == 2'b00)?{24'b0, RF_rdata2[7:0]}:(
							(vAddr10 == 2'b01)?{16'b0, RF_rdata2[7:0], 8'b0}:(
							(vAddr10 == 2'b10)?{8'b0, RF_rdata2[7:0], 16'b0}:{RF_rdata2[7:0], 24'b0}))):(
						(Instruction_Register[31:29] == `S_type_in && in_funct == `sh_in_funct )?(
							(vAddr10[1] == 1'b1)?{RF_rdata2[15:0], 16'b0}:{16'b0, RF_rdata2}):RF_rdata2)));


	assign Write_strb = (Instruction_Register[31:29] == `S_type_in && in_funct == `swl_in_funct)?(
							(vAddr10 == 2'b00)?4'b0001:(
							(vAddr10 == 2'b01)?4'b0011:(
							(vAddr10 == 2'b10)?4'b0111:4'b1111))):(
						(Instruction_Register[31:29] == `S_type_in && in_funct == `swr_in_funct)?(
							(vAddr10 == 2'b00)?4'b1111:(
							(vAddr10 == 2'b01)?4'b1110:(
							(vAddr10 == 2'b10)?4'b1100:4'b1000))):(
						(Instruction_Register[31:29] == `S_type_in && in_funct == `sb_in_funct )?(
							(vAddr10 == 2'b00)?4'b0001:(
							(vAddr10 == 2'b01)?4'b0010:(
							(vAddr10 == 2'b10)?4'b0100:4'b1000))):(
						(Instruction_Register[31:29] == `S_type_in && in_funct == `sh_in_funct )?(
							(vAddr10[1] == 1'b1)?4'b1100:4'b0011):(4'b1111))));//阶段1保持全1即可


	assign jump_address = {add_result[31:28], Instruction_Register[25:0], 2'b00};//jmp的地址拼接

	assign PC_input_after_jump =(DonotJump)?(
								(funct == `jr_funct && opcode == `R_type_in)?alu1_result:(
								(funct == `jalr_funct && opcode == `R_type_in)?RF_rdata1:PC_input_before_jump
								)):jump_address;//这个地方实现多个信号选择，jump=1表示不用j类地址，而funct为jr时直接使用alu1的结果


	//下面是程序计数器PC的赋值流程
	/*
	always @(posedge clk or posedge rst) 
	begin
		if (rst) 
			PC_reg <= 32'b0;// reset	
		else 
			PC_reg <= PC_input_after_jump;
	end
	*/
	assign PC = PC_reg;
	assign RF_wen = RF_wen_reg;
	assign Instruction_for_submodule = Instruction_Register;
	assign RF_wdata_final = (opcode == `R_type_in && funct == `jalr_funct)?RF_wdata_just_for_jalr:RF_wdata;//考虑jalr这个奇葩指令之后的最终信号

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


