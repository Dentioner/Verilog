`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/13 20:58:19
// Design Name: 
// Module Name: wallace_elem
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


module wallace_elem(//按照自己画的图编号
	input[15:0] n,
	input[15:0] cin,

	output[15:0] cout,
	output C,
	output S
	);
	
	wire[15:0] s_temp;

	//第一层
	full_adder f0(.a(n[ 0]), .b(n[ 1]), .cin(n[ 2]), .cout(cout[ 0]), .s(s_temp[ 0]));
	full_adder f1(.a(n[ 3]), .b(n[ 4]), .cin(n[ 5]), .cout(cout[ 1]), .s(s_temp[ 1]));
	full_adder f2(.a(n[ 6]), .b(n[ 7]), .cin(n[ 8]), .cout(cout[ 2]), .s(s_temp[ 2]));
	full_adder f3(.a(n[ 9]), .b(n[10]), .cin(n[11]), .cout(cout[ 3]), .s(s_temp[ 3]));
	full_adder f4(.a(n[12]), .b(n[13]), .cin( 1'b0), .cout(cout[ 4]), .s(s_temp[ 4]));
	full_adder f5(.a(n[14]), .b(n[15]), .cin( 1'b0), .cout(cout[ 5]), .s(s_temp[ 5]));

	//第二层
	full_adder f6(.a(s_temp[0]), .b(s_temp[1]), .cin(s_temp[2]), .cout(cout[6]), .s(s_temp[6]));
	full_adder f7(.a(s_temp[3]), .b(s_temp[4]), .cin(s_temp[5]), .cout(cout[7]), .s(s_temp[7]));
	full_adder f8(.a(cin[0]), .b(cin[1]), .cin(cin[2]), .cout(cout[8]), .s(s_temp[8]));
	full_adder f9(.a(cin[3]), .b(cin[4]), .cin(cin[5]), .cout(cout[9]), .s(s_temp[9]));

	//第三层
	full_adder f10(.a(s_temp[6]), .b(s_temp[7]), .cin(s_temp[8]), .cout(cout[10]), .s(s_temp[10]));
	full_adder f11(.a(s_temp[9]), .b(cin[6]), .cin(cin[7]), .cout(cout[11]), .s(s_temp[11]));
	full_adder f12(.a(cin[8]), .b(cin[9]), .cin(1'b0), .cout(cout[12]), .s(s_temp[12]));

	//第四层
	full_adder f13(.a(s_temp[10]), .b(s_temp[11]), .cin(s_temp[12]), .cout(cout[13]), .s(s_temp[13]));
	full_adder f14(.a(cin[10]), .b(cin[11]), .cin(cin[12]), .cout(cout[14]), .s(s_temp[14]));

	//第五层
	full_adder f15(.a(s_temp[13]), .b(s_temp[14]), .cin(cin[13]), .cout(cout[15]), .s(s_temp[15]));

	//第六层
	full_adder f16(.a(s_temp[15]), .b(cin[14]), .cin(cin[15]), .cout(C), .s(S));


endmodule


module full_adder(
	input a,
	input b,
	input cin,
	output s,
	output cout
	);

	assign s = (~a&~b&cin)|(~a&b&~cin)|(a&~b&~cin)|(a&b&cin);
	assign cout = (a&b)|(a&cin)|(b&cin);

endmodule
