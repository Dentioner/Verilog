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


module wallace_elem(
	input[7:0] n,
	input[5:0] cin,

	output[5:0] cout,
	output C,
	output S
	);
	
	wire[5:0] s_temp;

	full_adder f0(.a(n[0]), .b(n[1]), .cin(n[2]), .cout(cout[0]), .s(s_temp[0]));//第一层左下角
	full_adder f1(.a(n[3]), .b(n[4]), .cin(n[5]), .cout(cout[1]), .s(s_temp[1]));//第一层中间
	full_adder f2(.a(n[6]), .b(n[7]), .cin(1'b0), .cout(cout[2]), .s(s_temp[2]));//第一层右下角
	
	full_adder f3(.a(s_temp[0]), .b(s_temp[1]), .cin(s_temp[2]), .cout(cout[3]), .s(s_temp[3]));//第二层左边
	full_adder f4(.a(cin[0]), .b(cin[1]), .cin(cin[2]), .cout(cout[4]), .s(s_temp[4]));//第二层右边

	full_adder f5(.a(s_temp[3]), .b(s_temp[4]), .cin(cin[3]), .cout(cout[5]), .s(s_temp[5]));//第三层

	full_adder f6(.a(s_temp[5]), .b(cin[4]), .cin(cin[5]), .cout(C), .s(S));//第四层

	

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
