`timescale 10 ns / 1 ns

`define DATA_WIDTH 32

module alu(
	input [`DATA_WIDTH - 1:0] A_raw,
	input [`DATA_WIDTH - 1:0] B_raw,
	input [3:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output [`DATA_WIDTH - 1:0] Result
);
 
	// TODO: Please add your logic code here
	localparam AND  = 4'b0000;
	localparam OR   = 4'b0001;
	localparam ADD  = 4'b0010;
	localparam SUB  = 4'b0110;
	localparam SLT  = 4'b0111;
	localparam SLTU = 4'b0011;//无符号数的比较
	localparam NOR  = 4'b1100;


	wire [`DATA_WIDTH - 1:0] CarryIn;

	wire set;//NOT define
	wire less0;
	wire Binvert;
	wire [1:0]Operation;
	wire [`DATA_WIDTH-1 : 0]before_set;
	wire tmp_CarryOut;

	wire [`DATA_WIDTH-1 : 0]A;
	wire [`DATA_WIDTH-1 : 0]B;
	//这里定义的A和B是为了实现无符号数比较的时候而设定的，下面的result_raw也一样
	wire [`DATA_WIDTH-1 : 0]Result_raw;

	assign Zero = (Result == `DATA_WIDTH'b0)?1:0;
	assign Overflow = CarryIn[`DATA_WIDTH-1] ^ tmp_CarryOut;
	assign CarryOut = CarryIn[0] ^ tmp_CarryOut;

	assign less0 = Overflow ^ set;
	assign Binvert = ((ALUop == SUB)||(ALUop == SLT)||(ALUop == SLTU))?1:0;
	assign CarryIn[0] = ((ALUop == SUB)||(ALUop == SLT)||(ALUop == SLTU))?1:0;
	assign Operation = (ALUop == AND)?2'b00:
						((ALUop == OR || ALUop == NOR)?2'b01:
						((ALUop == ADD)?2'b10:
						((ALUop == SUB)?2'b10:
						((ALUop == SLTU)?2'b11:
						((ALUop == SLT)?2'b11:2'b00)))));

	assign set = before_set[31];


//下面这3个assign是为了将无符号数的比较转化为有符号数的比较
	assign A = (ALUop == SLTU)?{1'b0, A_raw[`DATA_WIDTH-1:1]}:A_raw;//如果是无符号数比较，则不输入全部位数的A，而是将A逻辑右移一位，变成正的有符号数
	assign B = (ALUop == SLTU)?{1'b0, B_raw[`DATA_WIDTH-1:1]}:B_raw;//B和上面的做法一样
	assign Result = (ALUop == SLTU)?(		//当前操作是无符号数比较吗？
		(Result_raw == 32'b1)?Result_raw:(	//如果是，那么当前的Result_raw是1吗？如果是，说明操作数A的高位比B小，也就是A<B
		(Zero == 1'b0)?32'b0:(				//如果Result_raw=0，则说明高位的比较结果是A≥B，还要看Zero位。如果Zero为0，说明A的高31位大于B，则A>B
		(A_raw[0]<B_raw[0])?32'b1:32'b0 	//如果Zero=1，说明A_raw与B_raw的高31位完全一样，则需要比较A_raw与B_raw的最低位了
		))):(								//如果当前操作不是无符号数操作比较，则执行其他指令的判断
		(ALUop == NOR)?~Result_raw:			//如果当前操作是NOR，则将用OR实现的结果取个反即可
		Result_raw);						



	ALU_element a0(A[0], B[0], CarryIn[0], less0, Binvert, Operation, Result_raw[0], CarryIn[1], before_set[0]);
	
	ALU_element a1(A[1], B[1], CarryIn[1], 1'b0, Binvert, Operation, Result_raw[1], CarryIn[2], before_set[1]);
	ALU_element a2(A[2], B[2], CarryIn[2], 1'b0, Binvert, Operation, Result_raw[2], CarryIn[3], before_set[2]);
	ALU_element a3(A[3], B[3], CarryIn[3], 1'b0, Binvert, Operation, Result_raw[3], CarryIn[4], before_set[3]);
	ALU_element a4(A[4], B[4], CarryIn[4], 1'b0, Binvert, Operation, Result_raw[4], CarryIn[5], before_set[4]);
	ALU_element a5(A[5], B[5], CarryIn[5], 1'b0, Binvert, Operation, Result_raw[5], CarryIn[6], before_set[5]);
	ALU_element a6(A[6], B[6], CarryIn[6], 1'b0, Binvert, Operation, Result_raw[6], CarryIn[7], before_set[6]);
	ALU_element a7(A[7], B[7], CarryIn[7], 1'b0, Binvert, Operation, Result_raw[7], CarryIn[8], before_set[7]);
	ALU_element a8(A[8], B[8], CarryIn[8], 1'b0, Binvert, Operation, Result_raw[8], CarryIn[9], before_set[8]);
	ALU_element a9(A[9], B[9], CarryIn[9], 1'b0, Binvert, Operation, Result_raw[9], CarryIn[10], before_set[9]);
	ALU_element a10(A[10], B[10], CarryIn[10], 1'b0, Binvert, Operation, Result_raw[10], CarryIn[11], before_set[10]);
	ALU_element a11(A[11], B[11], CarryIn[11], 1'b0, Binvert, Operation, Result_raw[11], CarryIn[12], before_set[11]);
	ALU_element a12(A[12], B[12], CarryIn[12], 1'b0, Binvert, Operation, Result_raw[12], CarryIn[13], before_set[12]);
	ALU_element a13(A[13], B[13], CarryIn[13], 1'b0, Binvert, Operation, Result_raw[13], CarryIn[14], before_set[13]);
	ALU_element a14(A[14], B[14], CarryIn[14], 1'b0, Binvert, Operation, Result_raw[14], CarryIn[15], before_set[14]);
	ALU_element a15(A[15], B[15], CarryIn[15], 1'b0, Binvert, Operation, Result_raw[15], CarryIn[16], before_set[15]);
	ALU_element a16(A[16], B[16], CarryIn[16], 1'b0, Binvert, Operation, Result_raw[16], CarryIn[17], before_set[16]);
	ALU_element a17(A[17], B[17], CarryIn[17], 1'b0, Binvert, Operation, Result_raw[17], CarryIn[18], before_set[17]);
	ALU_element a18(A[18], B[18], CarryIn[18], 1'b0, Binvert, Operation, Result_raw[18], CarryIn[19], before_set[18]);
	ALU_element a19(A[19], B[19], CarryIn[19], 1'b0, Binvert, Operation, Result_raw[19], CarryIn[20], before_set[19]);
	ALU_element a20(A[20], B[20], CarryIn[20], 1'b0, Binvert, Operation, Result_raw[20], CarryIn[21], before_set[20]);
	ALU_element a21(A[21], B[21], CarryIn[21], 1'b0, Binvert, Operation, Result_raw[21], CarryIn[22], before_set[21]);
	ALU_element a22(A[22], B[22], CarryIn[22], 1'b0, Binvert, Operation, Result_raw[22], CarryIn[23], before_set[22]);
	ALU_element a23(A[23], B[23], CarryIn[23], 1'b0, Binvert, Operation, Result_raw[23], CarryIn[24], before_set[23]);
	ALU_element a24(A[24], B[24], CarryIn[24], 1'b0, Binvert, Operation, Result_raw[24], CarryIn[25], before_set[24]);
	ALU_element a25(A[25], B[25], CarryIn[25], 1'b0, Binvert, Operation, Result_raw[25], CarryIn[26], before_set[25]);
	ALU_element a26(A[26], B[26], CarryIn[26], 1'b0, Binvert, Operation, Result_raw[26], CarryIn[27], before_set[26]);
	ALU_element a27(A[27], B[27], CarryIn[27], 1'b0, Binvert, Operation, Result_raw[27], CarryIn[28], before_set[27]);
	ALU_element a28(A[28], B[28], CarryIn[28], 1'b0, Binvert, Operation, Result_raw[28], CarryIn[29], before_set[28]);
	ALU_element a29(A[29], B[29], CarryIn[29], 1'b0, Binvert, Operation, Result_raw[29], CarryIn[30], before_set[29]);
	ALU_element a30(A[30], B[30], CarryIn[30], 1'b0, Binvert, Operation, Result_raw[30], CarryIn[31], before_set[30]);

	ALU_element a31(A[31], B[31], CarryIn[31], 1'b0, Binvert, Operation, Result_raw[31], tmp_CarryOut, before_set[31]);//符号位



endmodule




module ALU_element(
	input a,
	input b,
	input carryin,
	input less,
	input binvert,
	input [1:0]operation,
	output result,
	output carryout,
	output set
); 
	wire a1, b1, sum_result, and_result, or_result;

	assign a1 = a;
	assign b1 = (binvert)?~b:b;
	assign and_result = a1&b1;
	assign or_result  = a1|b1;


	fulladder f0(a1, b1, sum_result, carryin, carryout);

	assign  result = (operation == 2'b00)? and_result:
					((operation == 2'b01)? or_result :
					((operation == 2'b10)?sum_result :  less   //SLT here
						));

	assign set = sum_result;
endmodule



module fulladder(a, b, result, cin, cout);

input a, b, cin;
output result, cout;

wire t_result, t_cout1, t_cout2;

xor x1(t_result, a, b);
xor x2(result, t_result, cin);
and a1(t_cout1, a, b);
and a2(t_cout2, cin, t_result);
or o1(cout, t_cout1, t_cout2);

endmodule

