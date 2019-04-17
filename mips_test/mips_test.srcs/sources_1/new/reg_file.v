`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2,
	input [3:0] Write_strb 
);

	// TODO: Please add your logic code here
	reg [`DATA_WIDTH - 1:0] register_file [`DATA_WIDTH - 1:0];
	//integer index;


	always @(posedge clk or posedge rst) 
	begin
		if (rst) 
		begin
			// reset
			
			//method1
			//for (index = 0; index < `DATA_WIDTH; index = index + 1)
				//register_file[index] <= `DATA_WIDTH'b0;
			
			//method2
			//register_file[0] <= `DATA_WIDTH'b0;
			
			//method3
			register_file[0] <= `DATA_WIDTH'b0;
			register_file[1] <= `DATA_WIDTH'b0;
			register_file[2] <= `DATA_WIDTH'b0;
			register_file[3] <= `DATA_WIDTH'b0;
			register_file[4] <= `DATA_WIDTH'b0;
			register_file[5] <= `DATA_WIDTH'b0;
			register_file[6] <= `DATA_WIDTH'b0;
			register_file[7] <= `DATA_WIDTH'b0;
			register_file[8] <= `DATA_WIDTH'b0;
			register_file[9] <= `DATA_WIDTH'b0;
			register_file[10] <= `DATA_WIDTH'b0;
			register_file[11] <= `DATA_WIDTH'b0;
			register_file[12] <= `DATA_WIDTH'b0;
			register_file[13] <= `DATA_WIDTH'b0;
			register_file[14] <= `DATA_WIDTH'b0;
			register_file[15] <= `DATA_WIDTH'b0;
			register_file[16] <= `DATA_WIDTH'b0;
			register_file[17] <= `DATA_WIDTH'b0;
			register_file[18] <= `DATA_WIDTH'b0;
			register_file[19] <= `DATA_WIDTH'b0;
			register_file[20] <= `DATA_WIDTH'b0;
			register_file[21] <= `DATA_WIDTH'b0;
			register_file[22] <= `DATA_WIDTH'b0;
			register_file[23] <= `DATA_WIDTH'b0;
			register_file[24] <= `DATA_WIDTH'b0;
			register_file[25] <= `DATA_WIDTH'b0;
			register_file[26] <= `DATA_WIDTH'b0;
			register_file[27] <= `DATA_WIDTH'b0;
			register_file[28] <= `DATA_WIDTH'b0;
			register_file[29] <= `DATA_WIDTH'b0;
			register_file[30] <= `DATA_WIDTH'b0;
			register_file[31] <= `DATA_WIDTH'b0;


		end
		else if (wen && waddr != `ADDR_WIDTH'b0) 
		begin
			case(Write_strb)
				4'b0000: register_file[waddr]			<= register_file[waddr];
				4'b0001: register_file[waddr][7:0]		<= wdata[31:24];
				4'b0011: register_file[waddr][15:0]		<= wdata[31:16];
				4'b0111: register_file[waddr][23:0]		<= wdata[31:8];
				//上：lwr，下：lwl
				4'b1000: register_file[waddr][31:24]	<= wdata[7:0];
				4'b1100: register_file[waddr][31:16]	<= wdata[15:0];
				4'b1110: register_file[waddr][31:8]		<= wdata[23:0];
				default: register_file[waddr]			<= wdata; //4'b1111
			endcase
		end
	end



	assign rdata1 = register_file[raddr1];
	assign rdata2 = register_file[raddr2];


endmodule
