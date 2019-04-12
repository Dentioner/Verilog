`timescale 10ns / 1ns

`define ADD 4'b0010
`define SUB 4'b0110
`define AND 4'b0000
`define OR  4'b0001
`define SLT 4'b0111

`define and_aluop_raw    3'b000
`define or_aluop_raw     3'b001
`define add_aluop_raw    3'b010
`define R_type_aluop_raw 3'b100
`define sub_aluop_raw	 3'b110
`define slt_aluop_raw	 3'b111

`define sll_funct  6'b000000
`define srl_funct  6'b000010
`define sra_funct  6'b000011
`define sllv_funct 6'b000100
`define srlv_funct 6'b000110
`define srav_funct 6'b000111
`define jr_funct   6'b001000
`define jalr_funct 6'b001001
`define movz_funct 6'b001010
`define movn_funct 6'b001011

`define addu_funct 6'b100001
`define subu_funct 6'b100011
`define and_funct  6'b100100
`define or_funct   6'b100101
`define xor_funct  6'b100110
`define nor_funct  6'b100111
`define slt_funct  6'b101010

`define R_type_in  6'b000000
`define j_in	   6'b000010
`define jal_in     6'b000011
`define beq_in     6'b000100
`define bne_in     6'b000101
`define addiu_in   6'b001001
`define slti_in	   6'b001010
`define lui_in	   6'b001111
`define lw_in      6'b100011
`define sw_in      6'b101011

`define j_out		11'b00000000000
`define jal_out		11'b00001000000
`define beq_out     11'b10000001110//9'bx0x000101;
`define bne_out     11'b10000001110//9'bx0x000101;
`define sw_out      11'b10100010000//9'bx1x001000;
`define addiu_out   11'b10101000000
`define lui_out		11'b10101000000
`define slti_out	11'b10101000111
`define lw_out      11'b10111100000
`define R_type_out  11'b11001000100




module mips_cpu(
	input  rst,
	input  clk,

	output reg [31:0] PC,
	input  [31:0] Instruction,

	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,

	input  [31:0] Read_data,
	output MemRead
);

	// THESE THREE SIGNALS ARE USED IN OUR TESTBENCH
	// PLEASE DO NOT MODIFY SIGNAL NAMES
	// AND PLEASE USE THEM TO CONNECT PORTS
	// OF YOUR INSTANTIATION OF THE REGISTER FILE MODULE
	wire			RF_wen;
	wire [4:0]		RF_waddr;
	wire [31:0]		RF_wdata;

	// TODO: PLEASE ADD YOUT CODE BELOW


	wire [8:0] control_data;
	wire DonotJump;
	wire RegDst;
	wire ALUsrc;
	wire MemtoReg;
	wire RegWrite;
//  wire MemRead has already been defined
//  wire MemWrite has already been defined
	wire Branch;
	wire [2:0] ALUop_raw;
	wire [3:0] ALUop;
//以上是“控制”模块使用的wire

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
	wire alu2_overflow;
	wire alu1_carryout;
	wire alu2_carryout;
	wire alu2_zero;
//以上5个wire也是给alu的，但是暂时用不到，在阶段1只是为了消除相关的warning而已


	wire [4:0]  RF_raddr1;
	wire [4:0]  RF_raddr2;
	wire [31:0] RF_rdata1;
	wire [31:0] RF_rdata2;
//以上是寄存器堆使用的wire

	wire [31:0] symbol_extension;//符号扩展单元使用
	wire Branch_after_AND;//这个信号是在branch和zero信号经过与门之后操作数据选择器的信号
	wire [31:0] add_result;//左上角加法器的结果
	wire [31:0] PC_input_before_jump;
	wire [31:0] PC_input_after_jump;//给PC输入的



//下面这两个线是给instruction最低的11位命名
	wire [5:0] funct;
	wire [4:0] shamt;
 
	wire [31:0] jump_address;//jmp类指令使用


	assign funct = Instruction[5:0];
	assign shamt = Instruction[10:6];


	//下面这堆assign是书上样例的“控制”模块
	assign control_data =   (Instruction[31:26] == `R_type_in)?`R_type_out:(
							(Instruction[31:26] == `lw_in)    ?`lw_out    :(
							(Instruction[31:26] == `sw_in)    ?`sw_out    :(
							(Instruction[31:26] == `beq_in)   ?`beq_out   :(
							(Instruction[31:26] == `addiu_in) ?`addiu_out :(
							(Instruction[31:26] == `bne_in)   ?`bne_out   :(
							(Instruction[31:26] == `j_in)	  ?`j_out	  :11'b1000000000))))));

	assign DonotJump = control_data[10];
	assign RegDst    = control_data[9];
	assign ALUsrc    = control_data[8];
	assign MemtoReg  = control_data[7];
	assign RegWrite  = control_data[6];
	assign MemRead   = control_data[5];
	assign MemWrite  = control_data[4];
	assign Branch    = control_data[3];
	assign ALUop_raw = control_data[2:0];

//下面这堆assign是寄存器堆使用的
	assign RF_raddr1 = Instruction[25:21];
	assign RF_raddr2 = Instruction[20:16];//这个raddr2可能还要改，因为样例图里面好像有Instruction20~16不进人raddr2的
	

	assign RF_waddr = (Instruction[31:26] == `jal_in)?31:(
						(RegDst == 1)?Instruction[15:11]:Instruction[20:16]);//此为样例图寄存器堆左边的数据选择器
	

	assign RF_wen = RegWrite;

//下面这堆assign是两个alu使用的
	assign alu1_a_raw = RF_rdata1;//这里进行一个移位操作
	assign alu1_b_raw = (ALUsrc == 1)?symbol_extension:RF_rdata2;//此为寄存器堆右边的数据选择器
	assign alu2_a = add_result;
	assign alu2_b = symbol_extension<<2;//符号扩展信号左移2位


//下面这堆assign是样例图寄存器下面的“符号扩展”模块
	assign symbol_extension = (Instruction[31:26] == `lui_in)?{Instruction[15:0], 16'b0}:
							{{16{Instruction[15]}}, Instruction[15:0]};//如果是lui指令则做左移，否则符号拓展

//下面这堆assign是给右上角的数据选择器用的
	assign Branch_after_AND = Branch & Zero_input_to_alu2;
	assign Zero_input_to_alu2 = (Instruction[31:26] == `bne_in)?~Zero_raw:Zero_raw;//Zero_raw对于bne需要处理一下
	assign PC_input_before_jump = (Branch_after_AND == 1)?alu2_result:add_result;

//下面这个是样例图左边的加法器
	assign add_result = PC + 4;

//下面这个是样例图最右边主存旁边的数据选择器
	assign RF_wdata = (Instruction[31:26] == `jal_in)?(PC+8):(
						(MemtoReg == 1)?Read_data:alu1_result);//先判断是否是直接将PC+8塞进去的指令，然后再判断别的

//下面是样例图右边主存的一堆输出信号
	assign Address = alu1_result;
	assign Write_data = RF_rdata2;
	assign Write_strb = 4'b1111;//阶段1保持全1即可

	assign jump_address = {add_result[31:28], Instruction[25:0], 2'b00};//jmp的地址拼接

	assign PC_input_after_jump =(DonotJump)?(
								(funct == `jr_funct)?alu1_result:PC_input_before_jump
								):jump_address;//这个地方实现多个信号选择，jump=1表示不用j类地址，而funct为jr时直接使用alu1的结果


//下面是程序计数器PC的赋值流程
always @(posedge clk or posedge rst) 
begin
	if (rst) 
		PC <= 32'b0;// reset	
	else 
		PC <= PC_input_after_jump;
end




	ALU_controller act1(.funct(funct), .ALUop_raw(ALUop_raw), .ALUop(ALUop));//书上样例的“ALU控制”模块
	shifter s1(.funct(funct), .shamt(shamt), .alu_a_raw(alu1_a_raw), .alu_b_raw(alu1_b_raw), .typecode(Instruction[31:26]), .alu_a(alu1_a), .alu_b(alu1_b));//最下面新增的移位模块


	alu alu1(.A(alu1_a), .B(alu1_b), .ALUop(ALUop), .Zero(Zero_raw),  .Result(alu1_result), .Overflow(alu1_overflow), .CarryOut(alu1_carryout));//overflow 和 carryout的信号暂时没引出
	alu alu2(.A(alu2_a), .B(alu2_b), .ALUop(`ADD),   .Zero(alu2_zero), .Result(alu2_result), .Overflow(alu2_overflow), .CarryOut(alu2_carryout));//Zero, overflow 和 carryout的信号暂时没引出, 此alu一直当做加法器使用
	//上面两个alu，第一个是样例图里面右下方的alu，第二个是样例图右上方的alu

	reg_file r1(.clk(clk), .rst(rst), .waddr(RF_waddr), .raddr1(RF_raddr1), .raddr2(RF_raddr2), .wen(RF_wen), .wdata(RF_wdata), .rdata1(RF_rdata1), .rdata2(RF_rdata2));
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
					(ALUop_raw == `R_type_aluop_raw)?(
						
					(funct == `sll_funct || funct == `addu_funct || funct == `jr_funct)?`ADD:(
					(funct[3:0] == 4'b0010)?`SUB:(
					(funct[3:0] == 4'b0100)?`AND:(
					(funct == `or_funct)?`OR :(
					(funct == `slt_funct)?`SLT:4'b1111))))):4'b1111)))));

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
	assign sllv_answer = alu_b_raw << alu_a_raw;
	assign srlv_answer = alu_b_raw >> alu_a_raw;
	//assign srav_answer = {{alu_a_raw{alu_b_raw[31]}}, alu_b_raw[31:32 - alu_a_raw]};
	assign srav_answer = (alu_b_raw[31])?(~((~alu_b_raw) >> alu_a_raw)):srlv_answer;





	assign alu_b = (typecode == `R_type_in)?(
				    (funct == `sll_funct)?  sll_answer:(
					(funct == `srl_funct)?  srl_answer:(
					(funct == `sra_funct)?  sra_answer:(
					(funct == `sllv_funct)?sllv_answer:(
					(funct == `srlv_funct)?srlv_answer:(
					(funct == `srav_funct)?srav_answer:alu_b_raw)))))):alu_b_raw; 

	

	

endmodule