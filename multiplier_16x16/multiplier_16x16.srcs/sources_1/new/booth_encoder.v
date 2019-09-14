`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/14 21:22:29
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
	input[31:0] x,
	input[2:0] y,//y0 为yi-1， y1为yi，y2为yi+1
	output[31:0] p,
	output c
    );


	wire [3:0] s;//s0 为S+2x，s1为S-2x，s2为S+x，s3为S-x
	//假设x[-1] = 0
	wire [31:0] p_temp;

	//assign p = p_temp + c;
	assign p = p_temp;
	assign c = s[3]|s[1];

	booth_select b0 (.s(s), .x({x[ 0], 1'b0 }), .p(p_temp[ 0]));
	generate
		genvar i;
		for(i = 1; i < 32; i = i+1)
		begin:booth
			booth_select b(.s(s), .x({x[i], x[i-1]}), .p(p_temp[i]));			
		end		
	endgenerate

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