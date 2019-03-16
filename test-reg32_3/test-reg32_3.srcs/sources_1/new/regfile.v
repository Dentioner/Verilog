`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/16 18:03:29
// Design Name: 
// Module Name: regfile
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


`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,//写口地址
	input [`ADDR_WIDTH - 1:0] raddr1,//读口地址1
	input [`ADDR_WIDTH - 1:0] raddr2,//读口地址2
	input wen,							//写使能
	input [`DATA_WIDTH - 1:0] wdata,//写数据
	output [`DATA_WIDTH - 1:0] rdata1,//读口1数据
	output [`DATA_WIDTH - 1:0] rdata2//读口2数据
);

	// TODO: Please add your logic code here
	reg [`DATA_WIDTH - 1:0] register_file [`DATA_WIDTH - 1:0];
	integer index;


	always @(posedge clk or posedge rst) //这里的posedge rst可能需要删掉
	begin
		if (rst) 
		begin
			// reset
			
			for (index = 0; index < `DATA_WIDTH; index = index + 1)
				register_file[index] <= `DATA_WIDTH'b0;

		end
		else if (wen) 
		begin
			register_file[waddr] <= wdata;
		end
	end



	assign rdata1 = register_file[raddr1];
	assign rdata2 = register_file[raddr2];


endmodule

