`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/08/31 23:09:08
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


module test(

    );
	reg [7:0] switch;
	wire [7:0] led;

	led l1(.switch(switch), .led(led));

	initial
	begin
		switch = 8'h0;
		#100;
	end

	always #10 
	begin
		switch = {$random}%256;
	end
endmodule
