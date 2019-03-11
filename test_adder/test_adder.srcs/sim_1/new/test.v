`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/09 21:34:28
// Design Name: 
// Module Name: test
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


module adder_test
();

	reg	[7:0]			operand0;
    reg	[7:0]			operand1;

    wire [7:0]          result;

	initial
	begin
		operand0 = 0;
		operand1 = 0;
		forever begin
			#10
			operand0 = {$random} % 128;
			operand1 = {$random} % 128;
		end
	end


    adder    u_adder (
        .operand0       (operand0),
        .operand1     (operand1),

        .result    (result)
    );

endmodule