`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/14 21:22:14
// Design Name: 
// Module Name: mul16
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


module mul16(
	input[15:0] x,
	input[15:0] y,
	output[31:0] result
    );



	wire[7:0] c_16bit;
	wire[31:0] p [7:0];//共使用8个booth编码器，每个booth编码器都要输出32位的p
	wire[31:0] x_symbol_extension;
	wire[5:0] c_temp[31:0];
	wire[31:0] C;
	wire[31:0] S;
	assign x_symbol_extension = {{16{x[15]}}, x};


	booth_encoder b0 (.x(x_symbol_extension), .y({y[ 1], y[ 0], 1'b0 }), .p(p[ 0]), .c(c_16bit[ 0]));

	booth_encoder b1(.x(x_symbol_extension << 2), .y({y[3], y[2], y[1]}), .p(p[1]), .c(c_16bit[1]));
	booth_encoder b2(.x(x_symbol_extension << 4), .y({y[5], y[4], y[3]}), .p(p[2]), .c(c_16bit[2]));
	booth_encoder b3(.x(x_symbol_extension << 6), .y({y[7], y[6], y[5]}), .p(p[3]), .c(c_16bit[3]));
	booth_encoder b4(.x(x_symbol_extension << 8), .y({y[9], y[8], y[7]}), .p(p[4]), .c(c_16bit[4]));
	booth_encoder b5(.x(x_symbol_extension << 10), .y({y[11], y[10], y[9]}), .p(p[5]), .c(c_16bit[5]));
	booth_encoder b6(.x(x_symbol_extension << 12), .y({y[13], y[12], y[11]}), .p(p[6]), .c(c_16bit[6]));
	booth_encoder b7(.x(x_symbol_extension << 14), .y({y[15], y[14], y[13]}), .p(p[7]), .c(c_16bit[7]));
	



	wallace_elem w0(.n({p[7][0], p[6][0], p[5][0], p[4][0], p[3][0], p[2][0], p[1][0], p[0][0]}), 
		.cin(c_16bit[5:0]), .cout(c_temp[0]), .C(C[0]), .S(S[0]));
	
	generate
		genvar j;
		for (j = 1; j < 32; j = j+1)
		begin:wallace
			wallace_elem w(.n({p[7][j], p[6][j], p[5][j], p[4][j], p[3][j], p[2][j], p[1][j], p[0][j]}), 
				.cin(c_temp[j - 1]), .cout(c_temp[j]), .C(C[j]), .S(S[j]));
		end
	endgenerate

	add_32bit a1(.a(S), .b({C[30:0], c_16bit[6]}), .cin(c_16bit[7]), .s(result));

endmodule

module add_32bit(
	input[31:0] a,
	input[31:0] b,
	input cin,
	output[31:0] s,
	output cout
	);
	assign s = a+b;

endmodule


	/*generate
		genvar i;
		for(i = 1; i < 8; i = i + 1)
		begin:encoder
			booth_encoder e(.x(x_symbol_extension), .y({y[2*i+1], y[2*i], y[2*i-1]}), .p(p[i]), .c(c_16bit[i]));
			
		end
	endgenerate*/