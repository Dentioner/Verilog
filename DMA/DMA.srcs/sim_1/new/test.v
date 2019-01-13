`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/30 10:46:50
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


module test();
reg reset; 				// 初始化信号
reg clk;
reg exchange;			// 这个信号是用来让DMA传输数据的方向颠倒过来的
reg mem_to_dma_valid; 	// random_input
reg mem_to_dma_enable; 	// random_input
reg cpu_to_dma_valid; 	// random_input
reg cpu_to_dma_enable;	// random_input
reg [3:0] mem_data_out;
reg [7:0] cpu_data_out;

wire dma_to_mem_valid; 	// 表示DMA对MEM传出的数据有效
wire dma_to_mem_enable;	// 表示DMA可以对MEM传出数据了。这也就是说BUF满了
wire dma_to_cpu_valid; 	// 表示DMA对CPU传出的数据有效
wire dma_to_cpu_enable;	// 表示DMA可以对CPU传出数据了。这也就是说BUF满了
wire [3:0] mem_data_in;
wire [7:0] cpu_data_in;

initial
begin
	reset    = 1'b1;
	clk      = 1'b0;
	exchange = 1'b0;

	mem_to_dma_valid  = 1'b0;
	mem_to_dma_enable = 1'b0;
	cpu_to_dma_enable = 1'b0;
	cpu_to_dma_valid  = 1'b0;

	mem_data_out = 4'b0000;
	cpu_data_out = 8'b00000000;

	#1 reset       = 1'b0;
	#5000 exchange = 1'b1;
	#1 exchange    = 1'b0;
end

always #10 clk = ~clk;

always @(posedge clk) 
begin
	mem_to_dma_valid  <= {$random}%2;
	mem_to_dma_enable <= {$random}%2;
	cpu_to_dma_enable <= {$random}%2;
	cpu_to_dma_valid  <= {$random}%2;
	mem_data_out      <= {$random}%16;
	cpu_data_out      <= {$random}%256;
end

always @(posedge clk)
begin
	if (mem_to_dma_enable == 1'b1 && dma_to_mem_valid  == 1'b1)
		$display("mem_in:%h", mem_data_in[3:0]);
	if (mem_to_dma_valid  == 1'b1 && dma_to_mem_enable == 1'b1)
		$display("mem_out:%h", mem_data_out[3:0]);
	if (cpu_to_dma_valid  == 1'b1 && dma_to_cpu_enable == 1'b1)
		$display("cpu_out:%h", cpu_data_out[7:0]);
	if (cpu_to_dma_enable == 1'b1 && dma_to_cpu_valid  == 1'b1)
		$display("cpu_in:%h", cpu_data_in[7:0]);
end


DMA d1(reset, clk, exchange, 
		mem_to_dma_valid, mem_to_dma_enable, cpu_to_dma_valid, cpu_to_dma_enable,
		mem_data_out, cpu_data_out,
		dma_to_mem_valid, dma_to_mem_enable, dma_to_cpu_valid, dma_to_cpu_enable,
		mem_data_in, cpu_data_in);

endmodule
