`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/13 20:58:58
// Design Name: 
// Module Name: booth_encoder
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


module booth_encoder(
	input[63:0] x,
	input[2:0] y,//y0 为yi-1， y1为yi，y2为yi+1
	output[31:0] p,
	output c
	);
	

	wire [3:0] s;//s0 为S+2x，s1为S-2x，s2为S+x，s3为S-x
	//假设x[-1] = 0

	booth_select b0 (.s(s), .x({x[ 0], 1'b0 }), .p(p[ 0]));
	booth_select b1 (.s(s), .x({x[ 1], x[ 0]}), .p(p[ 1]));
	booth_select b2 (.s(s), .x({x[ 2], x[ 1]}), .p(p[ 2]));
	booth_select b3 (.s(s), .x({x[ 3], x[ 2]}), .p(p[ 3]));
	booth_select b4 (.s(s), .x({x[ 4], x[ 3]}), .p(p[ 4]));
	booth_select b5 (.s(s), .x({x[ 5], x[ 4]}), .p(p[ 5]));
	booth_select b6 (.s(s), .x({x[ 6], x[ 5]}), .p(p[ 6]));
	booth_select b7 (.s(s), .x({x[ 7], x[ 6]}), .p(p[ 7]));
	booth_select b8 (.s(s), .x({x[ 8], x[ 7]}), .p(p[ 8]));
	booth_select b9 (.s(s), .x({x[ 9], x[ 8]}), .p(p[ 9]));
	booth_select b10(.s(s), .x({x[10], x[ 9]}), .p(p[10]));
	booth_select b11(.s(s), .x({x[11], x[10]}), .p(p[11]));
	booth_select b12(.s(s), .x({x[12], x[11]}), .p(p[12]));
	booth_select b13(.s(s), .x({x[13], x[12]}), .p(p[13]));
	booth_select b14(.s(s), .x({x[14], x[13]}), .p(p[14]));
	booth_select b15(.s(s), .x({x[15], x[14]}), .p(p[15]));
	booth_select b16(.s(s), .x({x[16], x[15]}), .p(p[16]));
	booth_select b17(.s(s), .x({x[17], x[16]}), .p(p[17]));
	booth_select b18(.s(s), .x({x[18], x[17]}), .p(p[18]));
	booth_select b19(.s(s), .x({x[19], x[18]}), .p(p[19]));
	booth_select b20(.s(s), .x({x[20], x[19]}), .p(p[20]));
	booth_select b21(.s(s), .x({x[21], x[20]}), .p(p[21]));
	booth_select b22(.s(s), .x({x[22], x[21]}), .p(p[22]));
	booth_select b23(.s(s), .x({x[23], x[22]}), .p(p[23]));
	booth_select b24(.s(s), .x({x[24], x[23]}), .p(p[24]));
	booth_select b25(.s(s), .x({x[25], x[24]}), .p(p[25]));
	booth_select b26(.s(s), .x({x[26], x[25]}), .p(p[26]));
	booth_select b27(.s(s), .x({x[27], x[26]}), .p(p[27]));
	booth_select b28(.s(s), .x({x[28], x[27]}), .p(p[28]));
	booth_select b29(.s(s), .x({x[29], x[28]}), .p(p[29]));
	booth_select b30(.s(s), .x({x[30], x[29]}), .p(p[30]));
	booth_select b31(.s(s), .x({x[31], x[30]}), .p(p[31]));



	
	
	
	
	
	





	booth_gen bg1(.y(y), .s(s));

endmodule



module booth_gen(
	input[2:0] y,//y0 为yi-1， y1为yi，y2为yi+1
	output[3:0] s//s0 为S+2x，s1为S-2x，s2为S+x，s3为S-x
	);//Booth选择信号生成逻辑

	assign s[3] = ~(~( y[2] &  y[1] & ~y[0]) & ~( y[2] & ~y[1] & y[0]));
	assign s[2] = ~(~(~y[2] &  y[1] & ~y[0]) & ~(~y[2] & ~y[1] & y[0]));
	assign s[1] = ~(~( y[2] & ~y[1] & ~y[0]));
	assign s[0] = ~(~(~y[2] &  y[1] &  y[0]));

endmodule

module booth_select(
	input[3:0] s,//s0 为S+2x，s1为S-2x，s2为S+x，s3为S-x
	input[1:0] x,//x0为xi-1，x1为xi
	output p
	);//booth结果选择逻辑

	assign p = ~(~(s[3] & ~x[1]) & ~(s[1] & ~x[0]) & ~(s[2] & x[1]) & ~(s[0] & x[0]));

endmodule