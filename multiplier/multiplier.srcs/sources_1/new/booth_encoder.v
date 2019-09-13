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
	input 
	);


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