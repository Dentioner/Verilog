`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/15 15:29:26
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


`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file_test
();

	reg clk;
	reg rst;
	reg [`ADDR_WIDTH - 1:0] waddr;
	reg wen;
	reg [`DATA_WIDTH - 1:0] wdata;

	reg [`ADDR_WIDTH - 1:0] raddr1;
	reg [`ADDR_WIDTH - 1:0] raddr2;
	wire [`DATA_WIDTH - 1:0] rdata1;
	wire [`DATA_WIDTH - 1:0] rdata2;

	initial 
	begin
		// TODO: Please add your testbench here
		rst = 1'b1;
		clk = 1'b0;
		wen = 1'b0;
		waddr = `ADDR_WIDTH'b0;
		wdata = `DATA_WIDTH'b0;
		raddr1 = `ADDR_WIDTH'b0;
		raddr2 = `ADDR_WIDTH'b0;
		
		#1 rst = 1'b0;

	end


	always @(posedge clk) 
	begin
		wen <= {$random}%2;
		waddr <= {$random}%`ADDR_WIDTH;
		wdata <= {$random}%`DATA_WIDTH;
		raddr1 <= {$random}%`ADDR_WIDTH;
		raddr2 <= {$random}%`ADDR_WIDTH;
		
	end

	always begin
		#5 clk = ~clk;
	end

	always begin
		
	end

	reg_file u_reg_file(
		.clk(clk),
		.rst(rst),
		.waddr(waddr),
		.raddr1(raddr1),
		.raddr2(raddr2),
		.wen(wen),
		.wdata(wdata),
		.rdata1(rdata1),
		.rdata2(rdata2)
	);

endmodule
