`timescale 10ns / 1ns

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
`define sltu_funct 6'b101011

`define R_type_in  6'b000000
`define bgez_in    6'b000001
`define bltz_in	   6'b000001
`define j_in	   6'b000010
`define jal_in     6'b000011
`define beq_in     6'b000100
`define bne_in     6'b000101
`define blez_in    6'b000110
`define addiu_in   6'b001001
`define slti_in	   6'b001010
`define sltiu_in   6'b001011
`define andi_in	   6'b001100
`define ori_in	   6'b001101
`define xori_in	   6'b001110
`define lui_in	   6'b001111
`define lb_in	   6'b100000
`define lh_in	   6'b100001
`define lwl_in	   6'b100010
`define lw_in      6'b100011
`define lbu_in	   6'b100100
`define lhu_in	   6'b100101
`define lwr_in	   6'b100110
`define sb_in	   6'b101000
`define sh_in	   6'b101001
`define swl_in	   6'b101010
`define sw_in      6'b101011
`define swr_in	   6'b101110

`define regimm_bltz 5'b00000
`define regimm_bgez 5'b00001

`define j_out		11'b00000000010
`define jal_out		11'b00001000010
`define beq_out     11'b10000001110//9'bx0x000101;
`define bne_out     11'b10000001110//9'bx0x000101;
`define bgez_out	11'b10000001110
`define blez_out	11'b10000001110
`define bltz_out	11'b10000001110
`define sb_out		11'b10100010010
`define sh_out		11'b10100010010
`define swl_out		11'b10100010010
`define sw_out      11'b10100010010//9'bx1x001000;
`define swr_out		11'b10100010010
`define andi_out	11'b10101000000
`define ori_out		11'b10101000001
`define addiu_out   11'b10101000010
`define lui_out		11'b10101000010
`define xori_out	11'b10101000101
`define slti_out	11'b10101000111
`define sltiu_out	11'b10101000011
`define lb_out		11'b10111100010
`define lh_out		11'b10111100010
`define lwl_out		11'b10111100010
`define lw_out      11'b10111100010
`define lbu_out		11'b10111100010
`define lhu_out		11'b10111100010
`define lwr_out		11'b10111100010
`define R_type_out  11'b11001000100

`define IF 		3'b000
`define IW 		3'b001
`define ID_EX 	3'b010
`define ST 		3'b011
`define LD 		3'b100
`define RDW 	3'b101
`define WB 		3'b110



module mips_cpu(
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
	// THESE THREE SIGNALS ARE USED IN OUR TESTBENCH
	// PLEASE DO NOT MODIFY SIGNAL NAMES
	// AND PLEASE USE THEM TO CONNECT PORTS
	// OF YOUR INSTANTIATION OF THE REGISTER FILE MODULE
	wire			RF_wen;
	wire [4:0]		RF_waddr;
	wire [31:0]		RF_wdata;

	// TODO: PLEASE ADD YOUT CODE BELOW


	wire [10:0] control_data;
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
	
	wire alu1_carryout;
	
	
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

	wire [31:0] Read_data_symbol_extension;//lb/lh指令使用
	wire [31:0] Read_data_logical_extension;//lbu/lhu指令使用

//下面的wire是给lwl/lwr用的
	wire [3:0] Write_strb_for_reg_file;//lwl/lwr使用
	wire [1:0] vAddr10;//lwl/lwr使用
	wire [31:0] Address_raw;//lwl/lwr使用
	wire [31:0] Address_align;


//多周期用
	reg [2:0] cpu_status_now;
	reg [2:0] cpu_status_next;
	//reg clk_past;
	reg [31:0] PC_reg;
	reg RF_wen_reg;
	reg [31:0] Instruction_Register;

	wire [31:0] Address_before_always;
	wire RF_wen_before_always;
	wire MemRead_wire;
	wire MemWrite_wire;
	wire [31:0] Instruction_for_submodule;

	assign funct = Instruction_Register[5:0];
	assign shamt = Instruction_Register[10:6];


	//下面这堆assign是书上样例的“控制”模块
	assign control_data =   (Instruction_Register[31:26] == `R_type_in)?`R_type_out:(
							(Instruction_Register[31:26] == `lw_in)    ?`lw_out    :(
							(Instruction_Register[31:26] == `sw_in)    ?`sw_out    :(
							(Instruction_Register[31:26] == `beq_in)   ?`beq_out   :(
							(Instruction_Register[31:26] == `addiu_in) ?`addiu_out :(
							(Instruction_Register[31:26] == `bne_in)   ?`bne_out   :(
							(Instruction_Register[31:26] == `jal_in)   ?`jal_out   :(
							(Instruction_Register[31:26] == `lui_in)   ?`lui_out   :(
							(Instruction_Register[31:26] == `slti_in)  ?`slti_out  :(
							(Instruction_Register[31:26] == `sltiu_in) ?`sltiu_out :(
							(Instruction_Register[31:26] == `andi_in)  ?`andi_out  :(
							(Instruction_Register[31:26] == `bgez_in)  ?`bgez_out  :(
							(Instruction_Register[31:26] == `blez_in)  ?`blez_out  :(
							(Instruction_Register[31:26] == `bltz_in)  ?`bltz_out  :(
							(Instruction_Register[31:26] == `lb_in)    ?`lb_out    :(
							(Instruction_Register[31:26] == `lbu_in)   ?`lbu_out   :(
							(Instruction_Register[31:26] == `lh_in)    ?`lh_out    :(
							(Instruction_Register[31:26] == `lhu_in)   ?`lhu_out   :(
							(Instruction_Register[31:26] == `lwl_in)   ?`lwl_out   :(
							(Instruction_Register[31:26] == `lwr_in)   ?`lwr_out   :(
							(Instruction_Register[31:26] == `ori_in)   ?`ori_out   :(
							(Instruction_Register[31:26] == `sb_in)	  ?`sb_out	  :(
							(Instruction_Register[31:26] == `sh_in)	  ?`sh_out	  :(
							(Instruction_Register[31:26] == `swl_in)   ?`swl_out   :(
							(Instruction_Register[31:26] == `swr_in)   ?`swr_out   :(
							(Instruction_Register[31:26] == `xori_in)  ?`xori_out  :(

							(Instruction_Register[31:26] == `j_in)	   ?`j_out	  :11'b1000000000))))))))))))))))))))))))));

	assign DonotJump 	 = control_data[10];
	assign RegDst    	 = control_data[9];
	assign ALUsrc    	 = control_data[8];
	assign MemtoReg  	 = control_data[7];
	assign RegWrite		 = control_data[6];
	assign MemRead_wire  = control_data[5];
	assign MemWrite_wire = control_data[4];
	assign Branch    	 = control_data[3];
	assign ALUop_raw 	 = control_data[2:0];

//下面这堆assign是寄存器堆使用的
	assign RF_raddr1 = Instruction_Register[25:21];
	assign RF_raddr2 = Instruction_Register[20:16];//这个raddr2可能还要改，因为样例图里面好像有Instruction_Register20~16不进人raddr2的
	

	assign RF_waddr = (Instruction_Register[31:26] == `jal_in)?31:(
						(RegDst == 1)?Instruction_Register[15:11]:Instruction_Register[20:16]);//此为样例图寄存器堆左边的数据选择器
	

	assign RF_wen_before_always = 
					(RF_waddr == 32'b0)?1'b0:(
					(Instruction_Register[31:26] == `R_type_in && funct == `movn_funct && RF_rdata2 == 32'b0)?1'b0:(//如果执行的是movn指令，而且rt=0时，写使能低电平
					(Instruction_Register[31:26] == `R_type_in && funct == `movz_funct && RF_rdata2 != 32'b0)?1'b0://如果执行的是movz指令，而且rt≠0时，写使能低电平
					RegWrite));//好像仿真的时候认为写地址为0的时候是不能写的，
	//但是实际上在regfile模块里面都保证了写地址为0的时候不接受外来信号
	//为了让仿真通过只好再把这个地方加点条件保证RF_wen不能在写地址为0的时候=1了。

//下面这堆assign是两个alu使用的
	assign alu1_a_raw = (Instruction_Register[31:26] == `R_type_in && funct == `jalr_funct)?(add_result + 4):RF_rdata1;//这里如果发现指令是jalr，直接将PC+4塞到A输入端即可
	assign alu1_b_raw = (ALUsrc == 1)?symbol_extension:(
						(Instruction_Register[31:26] == `R_type_in && funct == `movn_funct)?32'b0://如果ALUSrc=0，说明操作数b不是16位那边过来的，这时候再判断是不是在执行movn指令，
						RF_rdata2);//如果是movn，则将操作数b变成0，否则照常输入RF_data2
						//此为寄存器堆右边的数据选择器
	assign alu2_a = add_result;
	assign alu2_b = symbol_extension<<2;//符号扩展信号左移2位


//下面这堆assign是样例图寄存器下面的“符号扩展”模块
	assign symbol_extension = (Instruction_Register[31:26] == `lui_in)?{Instruction_Register[15:0], 16'b0}:(
							  (Instruction_Register[31:26] == `sltiu_in || 
							  	Instruction_Register[31:26] == `andi_in ||
							  	Instruction_Register[31:26] == `xori_in || 
							  	Instruction_Register[31:26] == `ori_in)?{16'b0, Instruction_Register[15:0]}:
							{{16{Instruction_Register[15]}}, Instruction_Register[15:0]});//如果是lui指令则做左移，否则符号拓展

//下面这堆assign是给右上角的数据选择器用的
	assign Branch_after_AND = Branch & Zero_input_to_alu2;
	assign Zero_input_to_alu2 = (Instruction_Register[31:26] == `bne_in)?~Zero_raw:(//Zero_raw对于bne需要处理一下
								(Instruction_Register[31:26] == `bgez_in && Instruction_Register[20:16] == `regimm_bgez)?~RF_rdata1[31]:(
								(Instruction_Register[31:26] == `bltz_in && Instruction_Register[20:16] == `regimm_bltz)?RF_rdata1[31]:(
								(Instruction_Register[31:26] == `blez_in)?(RF_rdata1[31]|Zero_raw):
									Zero_raw)));
	assign PC_input_before_jump = (Branch_after_AND == 1)?alu2_result:add_result;

//下面这个是样例图左边的加法器
	assign add_result = PC_reg + 4;

//下面这个是样例图最右边主存旁边的数据选择器
	assign RF_wdata = (Instruction_Register[31:26] == `jal_in)?(PC_reg+8):(
						(MemtoReg == 1)?(
						(Instruction_Register[31:26] == `lb_in || Instruction_Register[31:26] == `lh_in)?Read_data_symbol_extension:(
						(Instruction_Register[31:26] == `lbu_in || Instruction_Register[31:26] == `lhu_in)?Read_data_logical_extension:(
						(Instruction_Register[31:26] == `lwl_in)?(
							(vAddr10 == 2'b00)?{Read_data[7:0], RF_rdata2[23:0]}:(
							(vAddr10 == 2'b01)?{Read_data[15:0], RF_rdata2[15:0]}:(
							(vAddr10 == 2'b10)?{Read_data[23:0], RF_rdata2[7:0]}:Read_data))):(
						(Instruction_Register[31:26] == `lwr_in)?(
							(vAddr10 == 2'b00)?Read_data:(
							(vAddr10 == 2'b01)?{RF_rdata2[31:24], Read_data[31:8]}:(
							(vAddr10 == 2'b10)?{RF_rdata2[31:16], Read_data[31:16]}:{RF_rdata2[31:8], Read_data[31:24]}))):Read_data))
						)):alu1_result);//先判断是否是直接将PC+8塞进去的指令，然后再判断别的

	assign Read_data_symbol_extension = (Instruction_Register[31:26] == `lb_in)?(
											(vAddr10 == 2'b00)?{{24{Read_data[7]}}, Read_data[7:0]}:(
											(vAddr10 == 2'b01)?{{24{Read_data[15]}}, Read_data[15:8]}:(
											(vAddr10 == 2'b10)?{{24{Read_data[23]}}, Read_data[23:16]}:{{24{Read_data[31]}}, Read_data[31:24]}))):(
										(Instruction_Register[31:26] == `lh_in)?(
											(vAddr10[1] == 1'b1)?{{16{Read_data[31]}}, Read_data[31:16]}:{{16{Read_data[15]}}, Read_data[15:0]}):Read_data);//将8位/16位Read_data符号扩展
										

	assign Read_data_logical_extension = (Instruction_Register[31:26] == `lbu_in)?(
											(vAddr10 == 2'b00)?{24'b0, Read_data[7:0]}:(
											(vAddr10 == 2'b01)?{24'b0, Read_data[15:8]}:(
											(vAddr10 == 2'b10)?{24'b0, Read_data[23:16]}:{24'b0, Read_data[31:24]}))):(
										(Instruction_Register[31:26] == `lhu_in)?(
											(vAddr10[1] == 1'b1)?{16'b0, Read_data[31:16]}:{16'b0, Read_data[15:0]}):Read_data);//将8位/16位Read_data高位加0拓展为32位


	//下面几个assign是为了实现lwl/lwr而设置的
	assign Write_strb_for_reg_file = (Instruction_Register[31:26] == `lwl_in)?(
										(vAddr10 == 2'b00)?4'b1000:(
										(vAddr10 == 2'b01)?4'b1100:(
										(vAddr10 == 2'b10)?4'b1110:4'b1111))):(
									 (Instruction_Register[31:26] == `lwr_in)?(
									 	(vAddr10 == 2'b00)?4'b1111:(
									 	(vAddr10 == 2'b01)?4'b0111:(
									 	(vAddr10 == 2'b10)?4'b0011:4'b0001))):4'b1111);
	assign vAddr10 = Address_raw[1:0];


//下面是样例图右边主存的一堆输出信号
	assign Address_raw = alu1_result;
	assign Address_align = Address_raw - vAddr10;
	assign Address_before_always =
					 (Instruction_Register[31:26] == `lwl_in || 
					  Instruction_Register[31:26] == `lwr_in ||
					  Instruction_Register[31:26] == `swl_in ||
					  Instruction_Register[31:26] == `swr_in ||
					  Instruction_Register[31:26] == `sb_in  ||
					  Instruction_Register[31:26] == `sh_in  ||
					  Instruction_Register[31:26] == `lb_in  ||
					  Instruction_Register[31:26] == `lh_in
					  )?Address_align:Address_raw;


	assign Write_data = (Instruction_Register[31:26] == `swl_in)?(
							(vAddr10 == 2'b00)?{24'b0, RF_rdata2[31:24]}:(
							(vAddr10 == 2'b01)?{16'b0, RF_rdata2[31:16]}:(
							(vAddr10 == 2'b10)?{8'b0,  RF_rdata2[31:8]}:RF_rdata2))):(
						(Instruction_Register[31:26] == `swr_in)?(
							(vAddr10 == 2'b00)?RF_rdata2:(
							(vAddr10 == 2'b01)?{RF_rdata2[23:0], 8'b0}:(
							(vAddr10 == 2'b10)?{RF_rdata2[15:0], 16'b0}:{RF_rdata2[7:0], 24'b0}))):(
						(Instruction_Register[31:26] == `sb_in)?(
							(vAddr10 == 2'b00)?{24'b0, RF_rdata2[7:0]}:(
							(vAddr10 == 2'b01)?{16'b0, RF_rdata2[7:0], 8'b0}:(
							(vAddr10 == 2'b10)?{8'b0, RF_rdata2[7:0], 16'b0}:{RF_rdata2[7:0], 24'b0}))):(
						(Instruction_Register[31:26] == `sh_in)?(
							(vAddr10[1] == 1'b1)?{RF_rdata2[15:0], 16'b0}:{16'b0, RF_rdata2}):RF_rdata2)));


	assign Write_strb = (Instruction_Register[31:26] == `swl_in)?(
							(vAddr10 == 2'b00)?4'b0001:(
							(vAddr10 == 2'b01)?4'b0011:(
							(vAddr10 == 2'b10)?4'b0111:4'b1111))):(
						(Instruction_Register[31:26] == `swr_in)?(
							(vAddr10 == 2'b00)?4'b1111:(
							(vAddr10 == 2'b01)?4'b1110:(
							(vAddr10 == 2'b10)?4'b1100:4'b1000))):(
						(Instruction_Register[31:26] == `sb_in)?(
							(vAddr10 == 2'b00)?4'b0001:(
							(vAddr10 == 2'b01)?4'b0010:(
							(vAddr10 == 2'b10)?4'b0100:4'b1000))):(
						(Instruction_Register[31:26] == `sh_in)?(
							(vAddr10[1] == 1'b1)?4'b1100:4'b0011):(4'b1111))));//阶段1保持全1即可


	assign jump_address = {add_result[31:28], Instruction_Register[25:0], 2'b00};//jmp的地址拼接

	assign PC_input_after_jump =(DonotJump)?(
								(funct == `jr_funct && Instruction_Register[31:26] == `R_type_in)?alu1_result:(
								(funct == `jalr_funct && Instruction_Register[31:26] == `R_type_in)?RF_rdata1:PC_input_before_jump
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

	ALU_controller act1(.funct(funct), .ALUop_raw(ALUop_raw), .ALUop(ALUop));//书上样例的“ALU控制”模块
	shifter s1(.funct(funct), .shamt(shamt), .alu_a_raw(alu1_a_raw), .alu_b_raw(alu1_b_raw), .typecode(Instruction_for_submodule[31:26]), .alu_a(alu1_a), .alu_b(alu1_b));//最下面新增的移位模块


	alu alu1(.A(alu1_a), .B(alu1_b), .ALUop(ALUop), .Zero(Zero_raw),  .Result(alu1_result), .Overflow(alu1_overflow), .CarryOut(alu1_carryout));//overflow 和 carryout的信号暂时没引出
	//alu alu2(.A_raw(alu2_a), .B_raw(alu2_b), .ALUop(`ADD),   .Zero(alu2_zero), .Result(alu2_result), .Overflow(alu2_overflow), .CarryOut(alu2_carryout));//Zero, overflow 和 carryout的信号暂时没引出, 此alu一直当做加法器使用
	assign alu2_result = alu2_a + alu2_b;
	//上面两个alu，第一个是样例图里面右下方的alu，第二个是样例图右上方的alu

	reg_file r1(.clk(clk), .rst(rst), .waddr(RF_waddr), .raddr1(RF_raddr1), .raddr2(RF_raddr2), .wen(RF_wen), .wdata(RF_wdata), .rdata1(RF_rdata1), .rdata2(RF_rdata2));    //, .Write_strb(Write_strb_for_reg_file));
	//此为样例图里面的寄存器堆


//下面是状态机

	//always @(clk)
		//clk_past <= ~clk;//人为实现上升沿

	always @(posedge clk or posedge rst) //always1
	begin
		if (rst) 
		begin
			cpu_status_now <= `IF; // reset
			//cpu_status_next <= `IF;
			Address <= Address_before_always;
			Instruction_Register <= 0;
		end
		else 
		begin
			cpu_status_now <= cpu_status_next;	
		end
	end


	always @* //always2
	begin
		cpu_status_next = cpu_status_now;//default
		 
		
			case(cpu_status_now)
			`IF:
			begin
								
				//Inst_Req_Valid = 1'b1;
				//Inst_Ack = 1'b0;
				if (Inst_Req_Ack)
					cpu_status_next = `IW;
				
				
				RF_wen_reg = 1'b0;//记得修改别处的RF_wen信号
				//Address = Address_before_always;
			end
			`IW:
			begin
				if (Inst_Valid)
					cpu_status_next = `ID_EX;
				//Inst_Ack = 1'b1;
				RF_wen_reg = 1'b0;//记得修改别处的RF_wen信号
				//Address = Address_before_always;
				
			end
			`ID_EX:
			begin
				

				if (Instruction_Register[31:26] == `lb_in  ||//Load指令
					Instruction_Register[31:26] == `lh_in  ||
					Instruction_Register[31:26] == `lwl_in ||
					Instruction_Register[31:26] == `lw_in  ||
					Instruction_Register[31:26] == `lbu_in ||
					Instruction_Register[31:26] == `lhu_in ||
					Instruction_Register[31:26] == `lwr_in)

					cpu_status_next = `LD;
				else if (Instruction_Register[31:26] == `sb_in  ||//Store指令
						 Instruction_Register[31:26] == `sh_in  ||
						 Instruction_Register[31:26] == `swl_in ||
						 Instruction_Register[31:26] == `sw_in  ||
						 Instruction_Register[31:26] == `swr_in)
				 	cpu_status_next = `ST;
				else if (Instruction_Register[31:26] == `bgez_in ||//跳转指令
						 Instruction_Register[31:26] == `blez_in ||
						 Instruction_Register[31:26] == `bltz_in ||
						 Instruction_Register[31:26] == `bne_in  ||
						 Instruction_Register[31:26] == `beq_in  ||
						 Instruction_Register[31:26] == `j_in    ||
						 Instruction_Register[31:26] == `jal_in)
					cpu_status_next = `IF;
				else
					cpu_status_next = `WB;//其他指令

				RF_wen_reg = RF_wen_before_always;	

			end

			`ST:
			begin
				if (Mem_Req_Ack)
					cpu_status_next = `IF;
				//MemWrite = MemWrite_wire; //= 1'b1;//记得修改别处的MemWrite
				RF_wen_reg = 1'b0;//记得修改别处的RF_wen信号
				//Address = Address_before_always;

			end
			`LD:
			begin
				if (Mem_Req_Ack)
					cpu_status_next = `RDW;
				//MemRead = MemRead_wire; //=1'b1;//记得修改别处的MemRead
				RF_wen_reg = 1'b0;//记得修改别处的RF_wen信号
				//Address = Address_before_always;
				

			end
			`RDW:
			begin
				if (Read_data_Valid)
					cpu_status_next = `WB;
				//Read_data_Ack = 1'b1;
				RF_wen_reg = 1'b0;//记得修改别处的RF_wen信号
				//Address = Address_before_always;
				
			end
			`WB:
			begin
				cpu_status_next = `IF;
				RF_wen_reg = RF_wen_before_always;
			end
			default:
				cpu_status_next = `IF;

			endcase
		
			
	end


	always @(posedge clk or posedge rst) //always3
	begin
		if (rst) 
		begin
			PC_reg <= 32'b0;// reset
			Inst_Req_Valid <= 1'b0;
			Inst_Ack <= 1'b1;
			MemWrite <= 1'b0;
			MemRead <= 1'b0;
			Read_data_Ack <= 1'b0;
			//Address <= Address_before_always;
		end
		else 
		begin
			case(cpu_status_now)
			`IF:
			begin
				if (Inst_Req_Ack)
				begin
					Inst_Req_Valid <= 1'b0;
					Inst_Ack <= 1'b1;
				end
				else
				begin
					Inst_Req_Valid <= 1'b1;
					Inst_Ack <= 1'b0;//在这里加这个是为了避免和always3里面的赋值出现竞争
				end	
			end
			`IW:
			begin
				if (Inst_Valid)//说明是上升沿
				begin
				//Instruction_Register = Instruction_Register;
					Inst_Ack <= 1'b0;
					Instruction_Register <= Instruction;	
				end	
			end
			`ID_EX:
			begin
				PC_reg <= PC_input_after_jump;		
				if (Instruction_Register[31:26] == `jal_in ||
				(Instruction_Register[31:26] == `R_type_in && funct == `jalr_funct))
					Address <= 31;
				else //别的情况下address怎么变
					Address <= Address_before_always;
				case(cpu_status_next)
				`ST:
					MemWrite <= MemWrite_wire;
				`LD:
					MemRead <= MemRead_wire;
				`WB:
					;
				default:
					Inst_Req_Valid <= 1'b1;//`IF
				endcase
			end
			`ST:
			begin
				if (Mem_Req_Ack)//说明是上升沿
				begin
					MemWrite <= 1'b0;
					Inst_Req_Valid <= 1'b1;				
				end	
			end
			`LD:
			begin
				if (Mem_Req_Ack)//说明是上升沿
				begin
					Read_data_Ack <= 1'b1;
					MemRead <= 1'b0;	
				end	
			end
			`RDW:
			begin
				if (Read_data_Valid)//说明是上升沿
				begin
					Read_data_Ack <= 1'b0;
					
				end
			end
			`WB:
				Inst_Req_Valid <= 1'b1;
			default:
				;
			endcase
		end
	end

	




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

