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


`define and_aluop_raw    4'b0000
`define or_aluop_raw     4'b0001
`define add_aluop_raw    4'b0010
`define sltu_aluop_raw	 4'b0011
`define R_type_aluop_raw 4'b0100
`define sub_aluop_raw	 4'b0110
`define slt_aluop_raw	 4'b0111
`define xor_aluop_raw	 4'b0101
`define B_type_aluop_raw 4'b1000

//****************************************************************R_type************************************************************************************************
`define R_type_opcode	7'b0110011
`define add_sub_funct3	3'b000
`define sll_funct3 		3'b001
`define slt_funct3 		3'b010
`define sltu_funct3 	3'b011
`define xor_funct3 		3'b100
`define srl_sra_funct3	3'b101
`define or_funct3 		3'b110
`define and_funct3 		3'b111

`define add_funct7		7'b0000000
`define sub_funct7		7'b0100000

`define srl_funct7 		7'b0000000
`define sra_funct7 		7'b0100000

`define R_type_out  	12'b110010000100


//****************************************************************I_type************************************************************************************************
`define I_type_opcode	7'b0010011
`define addi_funct3		3'b000
`define slti_funct3		3'b010
`define sltiu_funct3	3'b011
`define xori_funct3		3'b100
`define ori_funct3		3'b110
`define andi_funct3		3'b111

`define slli_funct3			3'b001
`define srli_srai_funct3	3'b101

`define slli_imm		7'b0000000
`define srli_imm		7'b0000000
`define srai_imm		7'b0100000

`define addiu_out   	12'b111010000010
`define slti_out		12'b111010000111
`define sltiu_out		12'b111010000011
`define xori_out		12'b111010000101
`define ori_out			12'b111010000001
`define andi_out		12'b111010000000

`define slli_out		12'b111010000010
`define srli_srai_out 	12'b111010000010


//****************************************************************L_type************************************************************************************************
`define L_type_opcode	7'b0000011
`define lb_funct3		3'b000
`define lh_funct3		3'b001
`define lw_funct3		3'b010
`define lbu_funct3		3'b100
`define lhu_funct3		3'b101

`define L_type_out		12'b111111000010

//****************************************************************S_type************************************************************************************************
`define S_type_opcode	7'b0100011
`define sb_funct3		3'b000
`define sh_funct3		3'b001
`define sw_funct3		3'b010

`define S_type_out		12'b101000100010
//****************************************************************B-type************************************************************************************************
`define B_type_opcode	7'b1100011
`define beq_funct3		3'b000
`define bne_funct3		3'b001
`define blt_funct3		3'b100
`define bge_funct3		3'b101
`define bltu_funct3		3'b110
`define bgeu_funct3		3'b111

`define B_type_out 		12'b100000011000

//****************************************************************U_type************************************************************************************************
`define lui_opcode		7'b0110111
`define auipc_opcode	7'b0010111

`define lui_out			12'b111010000010
`define auipc_out		12'b111010000010
//****************************************************************J_type************************************************************************************************
`define jal_opcode		7'b1101111
`define jalr_opcode		7'b1100111

`define jal_out			12'b010010000010
`define jalr_out 		12'b111010000010

//****************************************************************cpu_status************************************************************************************************

`define IF 		3'b000
`define IW 		3'b001
`define ID 		3'b010
`define EX 		3'b011
`define ST 		3'b100
`define LD 		3'b101
`define RDW 	3'b110
`define WB 		3'b111


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
	wire [11:0] control_data;

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
	wire [3:0] ALUop_raw;
	wire [3:0] ALUop;

	wire [4:0] rd_address;
	wire [4:0] rs1_address;
	wire [4:0] rs2_address;
	wire [2:0] funct3;
	wire [6:0] funct7;//由于某些指令共用一个funct3导致需要额外区分一下
	wire [19:0] U_type_imm;//u型指令使用的立即数
	wire [19:0]	jal_imm;//jal使用的offset
	wire [31:0] jal_offset_ex;//jal的偏移
	wire [11:0] jalr_imm;//jalr的立即数
	wire [11:0] B_type_imm;
	wire [11:0]	L_type_imm;
	wire [11:0] S_type_imm;
	wire [11:0] I_type_imm;

	

	
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
	wire [31:0] symbol_extension;//符号扩展单元使用
	wire Branch_after_AND;//这个信号是在branch和zero信号经过与门之后操作数据选择器的信号
	wire [31:0] add_result;//左上角加法器的结果
	wire [31:0] PC_input_before_jump;
	wire [31:0] PC_input_after_jump;//给PC输入的




	//wire [5:0] funct;
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
	reg [31:0] Read_data_reg;

	wire [31:0] Address_before_always;
	wire RF_wen_before_always;




//统一指令用
	

//由于jalr要求与别的j指令写寄存器的时候不一样，因此只能单独处理它了
	reg [31:0] RF_wdata_just_for_jalr;//单独给jalr的reg
	wire [31:0] RF_wdata_final;//最终给reg_file的值，这个是在处理jalr指令之后的


//*****************************assignment for controlling signals************************************************************************
	assign opcode 		= Instruction_Register[6:0];
	assign rd_address 	= Instruction_Register[11:7];
	assign funct3		= Instruction_Register[14:12];
	assign rs1_address	= Instruction_Register[19:15];
	assign rs2_address 	= Instruction_Register[24:20];
	assign funct7 		= Instruction_Register[31:25];
	assign shamt 		= Instruction_Register[24:20];

	assign U_type_imm 	= Instruction_Register[31:12];
	assign jal_imm 		= {Instruction_Register[31], Instruction_Register[19:12], Instruction_Register[20], Instruction_Register[30:21]};
	assign jalr_imm 	= Instruction_Register[31:20];
	assign B_type_imm 	= {Instruction_Register[31], Instruction_Register[7], Instruction_Register[30:25], Instruction_Register[11:8]};
	assign L_type_imm 	= Instruction_Register[31:20];
	assign S_type_imm 	= {Instruction_Register[31:25], Instruction_Register[11:7]};
	assign I_type_imm 	= Instruction_Register[31:20];

	
	//下面这堆assign是书上样例的“控制”模块
	assign control_data =   (opcode == `R_type_opcode)?`R_type_out:(
							(opcode == `L_type_opcode)?`L_type_out:(
							(opcode == `S_type_opcode)?`S_type_out:(
							(opcode == `B_type_opcode)?`B_type_out:(
							(opcode == `auipc_opcode) ?`auipc_out :(							
							(opcode == `lui_opcode)   ?`lui_out   :(
							(opcode == `jal_opcode)   ?`jal_out   :(
							(opcode == `I_type_opcode && funct3 == `addi_funct3)		?`addiu_out		:(
							(opcode == `I_type_opcode && funct3 == `slti_funct3)		?`slti_out 		:(
							(opcode == `I_type_opcode && funct3 == `sltiu_funct3)		?`sltiu_out		:(
							(opcode == `I_type_opcode && funct3 == `xori_funct3)		?`xori_out		:(
							(opcode == `I_type_opcode && funct3 == `ori_funct3)			?`ori_out		:(
							(opcode == `I_type_opcode && funct3 == `andi_funct3)		?`andi_out		:(
							(opcode == `I_type_opcode && funct3 == `slli_funct3)		?`slli_out		:(
							(opcode == `I_type_opcode && funct3 == `srli_srai_funct3)	?`srli_srai_out	:(
							(opcode == `jalr_opcode)	   ?`jalr_out	  :12'b10000000000)))))))))))))));



	assign DonotJump 	 = control_data[11];
	assign RegDst    	 = control_data[10];
	assign ALUsrc    	 = control_data[9];
	assign MemtoReg  	 = control_data[8];
	assign RegWrite		 = control_data[7];
	assign MemRead_wire  = control_data[6];
	assign MemWrite_wire = control_data[5];
	assign Branch    	 = control_data[4];
	assign ALUop_raw 	 = control_data[3:0];


	



	

//下面这堆assign是寄存器堆使用的
	assign RF_raddr1 = (opcode == `lui_opcode)?0:rs1_address;
	assign RF_raddr2 = rs2_address;

	assign RF_waddr = (RegDst == 0)?rs2_address:rd_address;//此为样例图寄存器堆左边的数据选择器
	//regdst = 0则为rs2，regdst=1则为rd
	

	assign RF_wen_before_always = (RF_waddr == 32'b0)?1'b0:RegWrite;//好像仿真的时候认为写地址为0的时候是不能写的，
	//但是实际上在regfile模块里面都保证了写地址为0的时候不接受外来信号
	//为了让仿真通过只好再把这个地方加点条件保证RF_wen不能在写地址为0的时候=1了。

//下面这堆assign是两个alu使用的
	assign alu1_a_raw = (opcode == `auipc_opcode)?(add_result - 4):RF_rdata1;//和mips不同，这里jalr也要使用RF_data的数据，而不是PC的，但是新增的auipc则要加PC
	assign alu1_b_raw = (ALUsrc == 1)?symbol_extension:RF_rdata2;//此为寄存器堆右边的数据选择器
						
	assign alu2_a = (opcode == `B_type_opcode)?PC_reg:add_result;
	assign alu2_b = (opcode == `B_type_opcode)?{{19{B_type_imm[11]}}, B_type_imm, 1'b0}:symbol_extension<<2;//符号扩展信号左移2位


//下面这堆assign是样例图寄存器下面的“符号扩展”模块
	assign symbol_extension = (opcode == `lui_opcode || opcode == `auipc_opcode)?{U_type_imm, 12'b0}:(
							  (opcode == `jalr_opcode)?{{20{jalr_imm[11]}}, jalr_imm}:(
							  (opcode == `L_type_opcode)?{{20{L_type_imm[11]}}, L_type_imm}:(
							  (opcode == `S_type_opcode)?{{20{S_type_imm[11]}}, S_type_imm}:(
							  (opcode == `I_type_opcode && 
							  		(funct3 == `addi_funct3 || 
							  		 funct3 == `slti_funct3 ||
							  		 funct3 == `xori_funct3 ||
							  		 funct3 == `ori_funct3  ||
							  		 funct3 == `andi_funct3))?{{20{I_type_imm[11]}}, I_type_imm}:(
							  (opcode == `I_type_opcode && funct3 == `sltiu_funct3)?{20'b0, I_type_imm}:
							{{20{Instruction_Register[31]}}, Instruction_Register[31:20]})))));//如果是lui指令则做左移，否则符号拓展

//下面这堆assign是给右上角的数据选择器用的
	assign Branch_after_AND = Branch & Zero_input_to_alu2;
	assign Zero_input_to_alu2 = (opcode == `B_type_opcode && funct3 == `bne_funct3)?~Zero_raw:(//Zero_raw对于bne需要处理一下
								(opcode == `B_type_opcode && funct3 == `bltu_funct3)?alu1_result[0]:(
								(opcode == `B_type_opcode && funct3 == `blt_funct3)?alu1_result[0]:(
								(opcode == `B_type_opcode && funct3 == `bge_funct3)?~alu1_result[0]:(
								(opcode == `B_type_opcode && funct3 == `bgeu_funct3)?~alu1_result[0]:
									Zero_raw))));
	assign PC_input_before_jump = (Branch_after_AND == 1)?alu2_result:add_result;

//下面这个是样例图左边的加法器
	assign add_result = PC_reg + 4;

//下面这个是样例图最右边主存旁边的数据选择器
	assign RF_wdata = (opcode == `jal_opcode || opcode == `jalr_opcode)?(PC_reg+4):(
						(MemtoReg == 1)?(
						((opcode == `L_type_opcode && funct3 == `lb_funct3) || 
						 (opcode == `L_type_opcode && funct3 == `lh_funct3))?Read_data_symbol_extension:(

						((opcode == `L_type_opcode && funct3 == `lbu_funct3) || 
						 (opcode == `L_type_opcode && funct3 == `lhu_funct3))?Read_data_logical_extension:Read_data_reg)):alu1_result);//先判断是否是直接将PC+8塞进去的指令，然后再判断别的

	assign Read_data_symbol_extension = (opcode == `L_type_opcode && funct3 == `lb_funct3)?(
											(vAddr10 == 2'b00)?{{24{Read_data_reg[7]}}, Read_data_reg[7:0]}:(
											(vAddr10 == 2'b01)?{{24{Read_data_reg[15]}}, Read_data_reg[15:8]}:(
											(vAddr10 == 2'b10)?{{24{Read_data_reg[23]}}, Read_data_reg[23:16]}:{{24{Read_data_reg[31]}}, Read_data_reg[31:24]}))):(
										(opcode == `L_type_opcode && funct3 == `lh_funct3)?(
											(vAddr10[1] == 1'b1)?{{16{Read_data_reg[31]}}, Read_data_reg[31:16]}:{{16{Read_data_reg[15]}}, Read_data_reg[15:0]}):Read_data_reg);//将8位/16位Read_data符号扩展
										

	assign Read_data_logical_extension = (opcode == `L_type_opcode && funct3 == `lbu_funct3)?(
											(vAddr10 == 2'b00)?{24'b0, Read_data_reg[7:0]}:(
											(vAddr10 == 2'b01)?{24'b0, Read_data_reg[15:8]}:(
											(vAddr10 == 2'b10)?{24'b0, Read_data_reg[23:16]}:{24'b0, Read_data_reg[31:24]}))):(
										 (opcode == `L_type_opcode && funct3 == `lhu_funct3)?(
											(vAddr10[1] == 1'b1)?{16'b0, Read_data_reg[31:16]}:{16'b0, Read_data_reg[15:0]}):Read_data_reg);//将8位/16位Read_data高位加0拓展为32位


	//下面几个assign是为了实现lwl/lwr而设置的
	assign Write_strb_for_reg_file = 4'b1111;
	assign vAddr10 = Address_raw[1:0];


//下面是样例图右边主存的一堆输出信号
	assign Address_raw = alu1_result;
	assign Address_align = Address_raw - vAddr10;
	assign Address_before_always =
					 ((opcode == `S_type_opcode && funct3 == `sb_funct3) ||
					  (opcode == `S_type_opcode && funct3 == `sh_funct3) ||
					  (opcode == `L_type_opcode && funct3 == `lb_funct3) ||
					  (opcode == `L_type_opcode && funct3 == `lh_funct3)
					  )?Address_align:Address_raw;


	assign Write_data = (opcode == `S_type_opcode && funct3 == `sb_funct3)?(
							(vAddr10 == 2'b00)?{24'b0, RF_rdata2[7:0]}:(
							(vAddr10 == 2'b01)?{16'b0, RF_rdata2[7:0], 8'b0}:(
							(vAddr10 == 2'b10)?{8'b0, RF_rdata2[7:0], 16'b0}:{RF_rdata2[7:0], 24'b0}))):(
						(opcode == `S_type_opcode && funct3 == `sh_funct3)?(
							(vAddr10[1] == 1'b1)?{RF_rdata2[15:0], 16'b0}:{16'b0, RF_rdata2}):RF_rdata2);


	assign Write_strb = (opcode == `S_type_opcode && funct3 == `sb_funct3 )?(
							(vAddr10 == 2'b00)?4'b0001:(
							(vAddr10 == 2'b01)?4'b0010:(
							(vAddr10 == 2'b10)?4'b0100:4'b1000))):(
						(opcode == `S_type_opcode && funct3 == `sh_funct3)?(
							(vAddr10[1] == 1'b1)?4'b1100:4'b0011):(4'b1111));//阶段1保持全1即可


	assign jal_offset_ex = {{11{jal_imm[19]}}, jal_imm, 1'b0};
	assign jump_address = PC_reg + jal_offset_ex;//jmp的地址拼接

	
	assign PC_input_after_jump =(DonotJump)?(
								(opcode == `jalr_opcode)?{alu1_result[31:1], 1'b0}:PC_input_before_jump):
								jump_address;//这个地方实现多个信号选择，jump=1表示不用j类地址，而funct为jr时直接使用alu1的结果


	assign PC = PC_reg;
	assign RF_wen = RF_wen_reg;
	
	assign RF_wdata_final = (opcode == `jalr_opcode || opcode == `jal_opcode)?RF_wdata_just_for_jalr:RF_wdata;//考虑jalr这个奇葩指令之后的最终信号

//*****************************sub_modules************************************************************************
	ALU_controller act1(.funct3(funct3), .ALUop_raw(ALUop_raw), .ALUop(ALUop), .funct7(funct7));//书上样例的“ALU控制”模块
	shifter s1(.funct3(funct3), .shamt(shamt), .alu_a_raw(alu1_a_raw), .alu_b_raw(alu1_b_raw), .typecode(opcode), .alu_a(alu1_a), .alu_b(alu1_b), .funct7(funct7));//最下面新增的移位模块


	alu alu1(.A(alu1_a), .B(alu1_b), .ALUop(ALUop), .Zero(Zero_raw),  .Result(alu1_result), .Overflow(alu1_overflow), .CarryOut(alu1_carryout));//overflow 和 carryout的信号暂时没引出
	//alu alu2(.A_raw(alu2_a), .B_raw(alu2_b), .ALUop(`ADD),   .Zero(alu2_zero), .Result(alu2_result), .Overflow(alu2_overflow), .CarryOut(alu2_carryout));//Zero, overflow 和 carryout的信号暂时没引出, 此alu一直当做加法器使用
	assign alu2_result = alu2_a + alu2_b;
	//上面两个alu，第一个是样例图里面右下方的alu，第二个是样例图右上方的alu

	reg_file r1(.clk(clk), .rst(rst), .waddr(RF_waddr), .raddr1(RF_raddr1), .raddr2(RF_raddr2), .wen(RF_wen), .wdata(RF_wdata_final), .rdata1(RF_rdata1), .rdata2(RF_rdata2));    //, .Write_strb(Write_strb_for_reg_file));
	//此为样例图里面的寄存器堆



//*****************************state_machines************************************************************************


	//always @(clk)
		//clk_past <= ~clk;//人为实现上升沿

	always @(posedge clk) //always1
	begin
		if (rst) 
		begin
			cpu_status_now <= `IF; // reset
			//cpu_status_next <= `IF;
			
			
		end
		else 
		begin
			cpu_status_now <= cpu_status_next;	
		end
	end


	always @* //always2_for_nextstatus
	begin
		cpu_status_next = cpu_status_now;//default
		 
		
		case(cpu_status_now)
			`IF:
			begin
				if (Inst_Req_Ack)
					cpu_status_next = `IW;
				else 
					cpu_status_next = cpu_status_now;
			end
			`IW:
			begin
				if (Inst_Valid)
					cpu_status_next = `ID;
				else 
					cpu_status_next = cpu_status_now;
			end
			`ID:
			begin
				cpu_status_next = `EX;
			end
			`EX:
			begin
				if (opcode == `L_type_opcode)//Load
					cpu_status_next = `LD;
				else if (opcode == `S_type_opcode)//Store
				 	cpu_status_next = `ST;
				else if (opcode == `B_type_opcode)//Branch
					cpu_status_next = `IF;
				else
					cpu_status_next = `WB;//其他指令

			end

			`ST:
			begin
				if (Mem_Req_Ack)
					cpu_status_next = `IF;
				else 
					cpu_status_next = cpu_status_now;

			end
			`LD:
			begin
				if (Mem_Req_Ack)
					cpu_status_next = `RDW;
				else 
					cpu_status_next = cpu_status_now;
			end
			`RDW:
			begin
				if (Read_data_Valid)
				begin
					cpu_status_next = `WB;
				end
				else 
					cpu_status_next = cpu_status_now;
				
			end
			`WB:
			begin
				cpu_status_next = `IF;
				
			end
			default:
			begin
				cpu_status_next = `IF;
				
			end
		endcase	
	end



	always @(posedge clk) 
	begin
		if (rst) 
		begin
			RF_wen_reg <= 0	// reset			
		end
		else  
		begin
			case(cpu_status_next)
			`WB:
				begin
					RF_wen_reg <= RF_wen_before_always;			
				end
			default:				
				RF_wen_reg <= 1'b0;	
			endcase
		end
	end




	always @(posedge clk) //always3_for_PC
	begin
		if (rst) 
		begin
			PC_reg <= 32'b0;// reset			
		end
		else 
		begin
			if (cpu_status_now == `EX)
				PC_reg <= PC_input_after_jump;
		end
	end

	always @(posedge clk) //always3_for_Inst_Req_Valid
	begin
		if (rst) 
		begin
			Inst_Req_Valid <= 1'b0;// reset			
		end
		else 
		begin
			case(cpu_status_now)
			`IF:
			begin
				if (Inst_Req_Ack)
				begin
					Inst_Req_Valid <= 1'b0;					
				end
				else
				begin
					Inst_Req_Valid <= 1'b1;					
				end	
			end
			`EX:
			begin
				if (cpu_status_next == `IF)
				begin
					Inst_Req_Valid <= 1'b1;
				end
			end
			`ST:
			begin
				if (Mem_Req_Ack)//说明是上升沿
				begin
					Inst_Req_Valid <= 1'b1;				
				end	
			end
			
			`WB:
				Inst_Req_Valid <= 1'b1;
			default:
				;
			endcase
		end
	end

	always @(posedge clk) //always3_Inst_Ack
	begin
		if (rst) 
		begin			
			Inst_Ack <= 1'b1;			
			//Address <= Address_before_always;
		end
		else 
		begin
			case(cpu_status_now)
			`IF:
			begin
				if (Inst_Req_Ack)
				begin					
					Inst_Ack <= 1'b1;
				end
				else
				begin					
					Inst_Ack <= 1'b0;//在这里加这个是为了避免和always3里面的赋值出现竞争
				end	
			end
			`IW:
			begin
				if (Inst_Valid)//说明是上升沿
				begin
				//Instruction_Register = Instruction_Register;
					Inst_Ack <= 1'b0;						
				end	
			end			
			default:
				;
			endcase
		end
	end

	always @(posedge clk) //always3_for_MemWrite
	begin
		if (rst) 
		begin
			MemWrite <= 1'b0;			
			//Address <= Address_before_always;
		end
		else 
		begin
			case(cpu_status_now)			
			`EX:
			begin				
				if (cpu_status_next == `ST)		
					MemWrite <= MemWrite_wire;			
			end
			`ST:
			begin
				if (Mem_Req_Ack)//说明是上升沿
				begin
					MemWrite <= 1'b0;						
				end	
			end			
			default:
				;
			endcase
		end
	end

	always @(posedge clk) //always3_for_MemRead
	begin
		if (rst) 
		begin
			MemRead <= 1'b0;			
			//Address <= Address_before_always;
		end
		else 
		begin
			case(cpu_status_now)			
			`EX:
			begin				
				if (cpu_status_next == `LD)
					MemRead <= MemRead_wire;
			end			
			`LD:
			begin
				if (Mem_Req_Ack)//说明是上升沿
				begin					
					MemRead <= 1'b0;	
				end	
			end			
			default:
				;
			endcase
		end
	end

	always @(posedge clk) //always3_for_Read_data_Ack
	begin
		if (rst) 
		begin			
			Read_data_Ack <= 1'b0;			
			//Address <= Address_before_always;
		end
		else 
		begin
			case(cpu_status_now)		
			`LD:
			begin
				if (Mem_Req_Ack)//说明是上升沿
				begin
					Read_data_Ack <= 1'b1;						
				end	
			end
			`RDW:
			begin
				if (Read_data_Valid)//说明是上升沿
				begin
					Read_data_Ack <= 1'b0;					
				end
			end
			default:
				;
			endcase
		end
	end

	always @(posedge clk) //always3_for_IR
	begin
		if (rst) 
		begin			
			Instruction_Register <= 0;			
			//Address <= Address_before_always;
		end
		else 
		begin
			if (cpu_status_now == `IW)			
				if (Inst_Valid)				
					Instruction_Register <= Instruction;			
		end
	end

	always @(posedge clk) //always3_for_Read_data_reg
	begin
		if (rst) 
		begin			
			Read_data_reg <= 0;			
			//Address <= Address_before_always;
		end
		else 
		begin
			if (cpu_status_now == `RDW)			
				if (Read_data_Valid)				
					Read_data_reg <= Read_data;			
		end
	end

	always @(posedge clk) //always3_for_address
	begin
		if (rst) 
		begin			
			Address <= Address_before_always;			
		end
		else 
		begin
			if (cpu_status_now == `EX)			
				Address <= Address_before_always;		
		end
	end

	always @(posedge clk) //for jalr
	begin
		if (rst) 
		begin
			RF_wdata_just_for_jalr <= RF_wdata;
		end
		else
		begin 
			if (cpu_status_next == `EX)//如果下一个状态是EX，那么马上更新专属RF_Wdata，等到EX的时候就晚了
			begin
				RF_wdata_just_for_jalr <= RF_wdata;
			end
		end
	end





endmodule



module ALU_controller(
	input [2:0] funct3,
	input [6:0] funct7,
	input [3:0]	ALUop_raw,
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
						
					((funct3 == `add_sub_funct3 && funct7 == `add_funct7)|| 
					 funct3 == `sll_funct3  ||
				 	 funct3 == `srl_sra_funct3
					 )?`ADD:(
					//(funct[3:0] == 4'b0010)?`SUB:(
					(funct3 == `add_sub_funct3 && funct7 == `sub_funct7)?`SUB:(
					(funct3 == `and_funct3)?`AND:(
					(funct3 == `or_funct3)?`OR :(					
					(funct3 == `xor_funct3)?`XOR:(
					(funct3 == `sltu_funct3)?`SLTU:(
					(funct3 == `slt_funct3)?`SLT:4'b1111))))))):(

					(ALUop_raw == `B_type_aluop_raw)?(

					(funct3 == `beq_funct3 || funct3 == `bne_funct3)?`SUB:(
					(funct3 == `blt_funct3)?`SLT:(
					(funct3 == `bltu_funct3)?`SLTU:(
					(funct3 == `bge_funct3)?`SLT:(
					(funct3 == `bgeu_funct3)?`SLTU:
					4'b1111))))):
					4'b1111))))))));

endmodule


module shifter(
	input [2:0] funct3,
	input [4:0] shamt,
	input [31:0] alu_a_raw,
	input [31:0] alu_b_raw,
	input [6:0] typecode,
	input [6:0] funct7,
	output [31:0] alu_a,
	output [31:0] alu_b
);
	//wire [31:0] shift_number;

	wire [31:0] sll_answer;
	wire [31:0] srl_answer;
	wire [31:0] sra_answer;

	wire [31:0] slli_answer;
	wire [31:0] srli_answer;
	wire [31:0] srai_answer;
					

	assign sll_answer  = alu_a_raw << alu_b_raw[4:0];
	assign srl_answer  = alu_a_raw >> alu_b_raw[4:0];
	//assign sra_answer  = {{shamt{alu_b_raw[31]}}, alu_b_raw[31:32-shamt]};
	assign sra_answer = (alu_a_raw[31])?(~((~alu_a_raw) >> alu_b_raw[4:0])):srl_answer;//取反逻辑右移之后再取反就行了
	//assign srav_answer = (alu_b_raw[31])?(~((~alu_b_raw) >> alu_a_raw[4:0])):srlv_answer;
	//assign srav_answer = {{alu_a_raw{alu_b_raw[31]}}, alu_b_raw[31:32 - alu_a_raw]};
	
	assign slli_answer = alu_a_raw << shamt;
	assign srli_answer = alu_a_raw >> shamt;
	assign srai_answer = (alu_a_raw[31])?(~((~alu_a_raw) >> shamt)):srli_answer;//取反逻辑右移之后再取反就行了

	







	assign alu_a = (typecode == `R_type_opcode)?(
				    (funct3 == `sll_funct3)?  sll_answer:(
					(funct3 == `srl_sra_funct3 && funct7 == `srl_funct7)?  srl_answer:(
					(funct3 == `srl_sra_funct3 && funct7 == `sra_funct7)?  sra_answer:alu_a_raw))):(//如果是Rtype的这6种功能的话，alu的a端口不输入加数
				   (typecode == `I_type_opcode)?(
					   (funct3 == `slli_funct3)? slli_answer:(
					   (funct3 == `srli_srai_funct3 && funct7 == `srli_imm)? srli_answer:(
					   (funct3 == `srli_srai_funct3 && funct7 == `srai_imm)? srai_answer:
					   alu_a_raw))):alu_a_raw);



	assign alu_b = (typecode == `R_type_opcode)?
					(
					   (funct3 == `sll_funct3 || funct3 == `srl_sra_funct3)?
					   32'b0
					   :
					   alu_b_raw
					)
					:
					(
						
				   		(typecode == `I_type_opcode)?
						(	
							(funct3 == `slli_funct3 || funct3 == `srli_srai_funct3)?
								32'b0
							:
								alu_b_raw
						)
						:
						alu_b_raw
					); 

	

	

endmodule


