`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/09 21:33:09
// Design Name: 
// Module Name: adder
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


module adder(
    input [7:0] operand0,
    input [7:0] operand1,
    output [7:0] result
    );
	
	/*TODO: Add your logic code here*/
wire cout[7:0];
fulladder f0(operand0[0], operand1[0], result[0], 1'b0, cout[0]);
fulladder f1(operand0[1], operand1[1], result[1], cout[0], cout[1]);
fulladder f2(operand0[2], operand1[2], result[2], cout[1], cout[2]);
fulladder f3(operand0[3], operand1[3], result[3], cout[2], cout[3]);
fulladder f4(operand0[4], operand1[4], result[4], cout[3], cout[4]);
fulladder f5(operand0[5], operand1[5], result[5], cout[4], cout[5]);
fulladder f6(operand0[6], operand1[6], result[6], cout[5], cout[6]);
fulladder f7(operand0[7], operand1[7], result[7], cout[6], cout[7]);



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
