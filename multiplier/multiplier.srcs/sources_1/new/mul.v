`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/13 20:38:30
// Design Name: 
// Module Name: mul
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


module mul(
	input[31:0] x,
	input[31:0] y,
	output[63:0] result
    );
//32位乘法，共16个booth编码器，64个 16个数相加华莱士树单元，最后是一个64位加法器

	wire[15:0] c_16bit;
	wire[63:0] p [15:0];//共使用16个booth编码器，每个booth编码器都要输出64位的p
	wire[63:0] x_symbol_extension;
	wire[15:0] c_temp[63:0];
	wire[63:0] C;
	wire[63:0] S;
	assign x_symbol_extension = {{32{x[31]}}, x};



	booth_encoder b0 (.x(x_symbol_extension), .y({y[ 1], y[ 0], 1'b0 }), .p(p[ 0]), .c(c_16bit[ 0]));
	booth_encoder b1 (.x(x_symbol_extension << 2 ), .y({y[ 3], y[ 2], y[ 1]}), .p(p[ 1]), .c(c_16bit[ 1]));
	booth_encoder b2 (.x(x_symbol_extension << 4 ), .y({y[ 5], y[ 4], y[ 3]}), .p(p[ 2]), .c(c_16bit[ 2]));
	booth_encoder b3 (.x(x_symbol_extension << 6 ), .y({y[ 7], y[ 6], y[ 5]}), .p(p[ 3]), .c(c_16bit[ 3]));
	booth_encoder b4 (.x(x_symbol_extension << 8 ), .y({y[ 9], y[ 8], y[ 7]}), .p(p[ 4]), .c(c_16bit[ 4]));
	booth_encoder b5 (.x(x_symbol_extension << 10), .y({y[11], y[10], y[ 9]}), .p(p[ 5]), .c(c_16bit[ 5]));
	booth_encoder b6 (.x(x_symbol_extension << 12), .y({y[13], y[12], y[11]}), .p(p[ 6]), .c(c_16bit[ 6]));
	booth_encoder b7 (.x(x_symbol_extension << 14), .y({y[15], y[14], y[13]}), .p(p[ 7]), .c(c_16bit[ 7]));
	booth_encoder b8 (.x(x_symbol_extension << 16), .y({y[17], y[16], y[15]}), .p(p[ 8]), .c(c_16bit[ 8]));
	booth_encoder b9 (.x(x_symbol_extension << 18), .y({y[19], y[18], y[17]}), .p(p[ 9]), .c(c_16bit[ 9]));
	booth_encoder b10(.x(x_symbol_extension << 20), .y({y[21], y[20], y[19]}), .p(p[10]), .c(c_16bit[10]));
	booth_encoder b11(.x(x_symbol_extension << 22), .y({y[23], y[22], y[21]}), .p(p[11]), .c(c_16bit[11]));
	booth_encoder b12(.x(x_symbol_extension << 24), .y({y[25], y[24], y[23]}), .p(p[12]), .c(c_16bit[12]));
	booth_encoder b13(.x(x_symbol_extension << 26), .y({y[27], y[26], y[25]}), .p(p[13]), .c(c_16bit[13]));
	booth_encoder b14(.x(x_symbol_extension << 28), .y({y[29], y[28], y[27]}), .p(p[14]), .c(c_16bit[14]));
	booth_encoder b15(.x(x_symbol_extension << 30), .y({y[31], y[30], y[29]}), .p(p[15]), .c(c_16bit[15]));
	


/*	generate
		genvar i;
		for(i = 1; i < 16; i = i + 1)
		begin:encoder
			booth_encoder e(.x(x_symbol_extension), .y({y[2*i+1], y[2*i], y[2*i-1]}), .p(p[i]), .c(c_16bit[i]));
		end
	endgenerate
*/
/*
	booth_encoder b1 (.x(x), .y({y[ 3], y[ 2], y[ 1]}), .p(p[ 1]), .c(c_16bit[ 1]));
	booth_encoder b2 (.x(x), .y({y[ 5], y[ 4], y[ 3]}), .p(p[ 2]), .c(c_16bit[ 2]));
	booth_encoder b3 (.x(x), .y({y[ 7], y[ 6], y[ 5]}), .p(p[ 3]), .c(c_16bit[ 3]));
	booth_encoder b4 (.x(x), .y({y[ 9], y[ 8], y[ 7]}), .p(p[ 4]), .c(c_16bit[ 4]));
	booth_encoder b5 (.x(x), .y({y[11], y[10], y[ 9]}), .p(p[ 5]), .c(c_16bit[ 5]));
	booth_encoder b6 (.x(x), .y({y[13], y[12], y[11]}), .p(p[ 6]), .c(c_16bit[ 6]));
	booth_encoder b7 (.x(x), .y({y[15], y[14], y[13]}), .p(p[ 7]), .c(c_16bit[ 7]));
	booth_encoder b8 (.x(x), .y({y[17], y[16], y[15]}), .p(p[ 8]), .c(c_16bit[ 8]));
	booth_encoder b9 (.x(x), .y({y[19], y[18], y[17]}), .p(p[ 9]), .c(c_16bit[ 9]));
	booth_encoder b10(.x(x), .y({y[21], y[20], y[19]}), .p(p[10]), .c(c_16bit[10]));
	booth_encoder b11(.x(x), .y({y[23], y[22], y[21]}), .p(p[11]), .c(c_16bit[11]));
	booth_encoder b12(.x(x), .y({y[25], y[24], y[23]}), .p(p[12]), .c(c_16bit[12]));
	booth_encoder b13(.x(x), .y({y[27], y[26], y[25]}), .p(p[13]), .c(c_16bit[13]));
	booth_encoder b14(.x(x), .y({y[29], y[28], y[27]}), .p(p[14]), .c(c_16bit[14]));
	booth_encoder b15(.x(x), .y({y[31], y[30], y[29]}), .p(p[15]), .c(c_16bit[15]));
*/

	//switch
	//switch负责收集16个booth核心生成的16个64位数，转化为64组16个1位数相加的格式，给华莱士树
	wallace_elem w0(.n({p[15][0], p[14][0], p[13][0], p[12][0], p[11][0], p[10][0], p[9][0], p[8][0],
				p[7][0], p[6][0], p[5][0], p[4][0], p[3][0], p[2][0], p[1][0], p[0][0]}), .cin(c_16bit),
				.cout(c_temp[0]), .C(C[0]), .S(S[0]));
	
	generate
		genvar j;
		for (j = 1; j < 64; j = j+1)
		begin:wallace
			wallace_elem w(.n({p[15][j], p[14][j], p[13][j], p[12][j], p[11][j], p[10][j], p[9][j], p[8][j],
				p[7][j], p[6][j], p[5][j], p[4][j], p[3][j], p[2][j], p[1][j], p[0][j]}), .cin(c_temp[j - 1]),
				.cout(c_temp[j]), .C(C[j]), .S(S[j]));
		end
	endgenerate

	add_64bit a1(.a(S), .b({C[62:0], 1'b0}), .cin(1'b0), .s(result));


endmodule


module add_64bit(
	input[63:0] a,
	input[63:0] b,
	input cin,
	output[63:0] s,
	output cout
	);
	//assign s = a+b;

	wire [63:0] tmp;
	full_adder a0(.a(a[0]), .b(b[0]), .cin(cin), .s(s[0]), .cout(tmp[0]));

	generate
		genvar i;
		for(i = 1; i < 64; i = i+1)
		begin:full_adder
			full_adder a(.a(a[i]), .b(b[i]), .s(s[i]), .cin(tmp[i - 1]), .cout(tmp[i]));
		end
	endgenerate

	assign cout = tmp[63];


endmodule



