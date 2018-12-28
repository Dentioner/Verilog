`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/28 23:46:45
// Design Name: 
// Module Name: buffer
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


module buffer(
input [1:0]work_state,//workstate是啥，由高层模块定义，因此要在DMA里面讨论赋给buffer的workstate随那四种状态如何变化
input [7:0] data_in,
input rst,
input clk,
output [7:0] data_out,
output [15:0] buffer_state
);
localparam [1:0] pull_information_4bit = 2'b00,
                 pull_information_8bit = 2'b01,
                 push_information_4bit = 2'b10,
                 push_information_8bit = 2'b11;
                
localparam [3:0] null = 4'bzzzz;
reg[7:0] BUF[7:0];
reg[15:0]BUF_full = 16'b0000000000000000;
integer index;

always @(posedge clk or rst) 
begin
	if (rst) //reset
	begin
		BUF_full = 16'b0000000000000000;
		for (index = 0; index < 8; index = index + 1)
			BUF[index] = 8'bzzzzzzzz;
	end
	else 
	begin
		case(BUF_full)
		16'b00_00_00_00_00_00_00_00:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[0][3:0] <= data_in[3:0];
				BUF_full[0] <= 1'b1;
			end
			pull_information_8bit:
			begin
				BUF[0][7:0] <= data_in[7:0];
				BUF_full[1:0] <= 2'b11;
			end
			push_information_4bit:
				$display("BUF is empty now.\n");
			push_information_8bit:
				$display("BUF is empty now.\n");
			endcase
		end
		16'b00_00_00_00_00_00_00_01:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[0][7:4] <= data_in[3:0];
				BUF_full[1] <= 1'b1;
			end
			pull_information_8bit:
				$display("impossible state.\n");
			push_information_4bit:
			begin
				data_out <= {null, BUF[7][3:0]};
				BUF_full[0] <= 1'b0;
			end
			push_information_8bit:
				$display("impossible state.\n");
			endcase
		end
		16'b00_00_00_00_00_00_00_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[1][3:0] <= data_in[3:0];
				BUF_full[2] <= 1'b1;
			end
			pull_information_8bit:
			begin
				BUF[1][7:0] <= data_in[7:0];
				BUF_full[3:2] <= 2'b11;
			end
			push_information_4bit:
			begin
				data_out <= {null, BUF[7][7:4]};
				BUF_full[1] <= 1'b0;
			end
			push_information_8bit:
			begin
				data_out <= BUF[7][7:0];
				BUF_full[1:0] <= 2'b00;
			end
			endcase
		end
		16'b00_00_00_00_00_00_01_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[1][7:4] <= data_in[3:0];
				BUF_full[3] <= 1'b1;
			end
			pull_information_8bit:
				$display("impossible state.\n");
			push_information_4bit:
			begin
				data_out <= {null, BUF[6][3:0]};
				BUF_full[2] <= 1'b0;
			end
			push_information_8bit:
				$display("impossible state.\n");
			endcase
		end
		16'b00_00_00_00_00_00_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[2][3:0] <= data_in[3:0];
				BUF_full[4] <= 1'b1;
			end
			pull_information_8bit:
			begin
				BUF[2][7:0] <= data_in[7:0];
				BUF_full[5:4] <= 2'b11;
			end	
			push_information_4bit:
			begin
				data_out <= {null, BUF[6][7:4]};
				BUF_full[3] <= 1'b0;
			end
			push_information_8bit:
			begin
				data_out <= BUF[6][7:0];
				BUF_full[3:2] <= 2'b00;
			end
			endcase
		end
		16'b00_00_00_00_00_01_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[2][7:4] <= data_in[3:0];
				BUF_full[5] <= 1'b1;
			end
			pull_information_8bit:
				$display("impossible state.\n");
			push_information_4bit:
			begin
				data_out <= {null, BUF[5][3:0]};
				BUF_full[4] <= 1'b0;
			end
			push_information_8bit:
				$display("impossible state.\n");
			endcase
		end
		16'b00_00_00_00_00_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[3][3:0] <= data_in[3:0];
				BUF_full[6] <= 1'b1;
			end
			pull_information_8bit:
			begin
				BUF[3][7:0] <= data_in[7:0];
				BUF_full[7:6] <= 2'b11;
			end	
			push_information_4bit:
			begin
				data_out <= {null, BUF[5][7:4]};
				BUF_full[5] <= 1'b0;
			end
			push_information_8bit:
			begin
				data_out <= BUF[5][7:0];
				BUF_full[5:4] <= 2'b00;
			end
			endcase
		end
		16'b00_00_00_00_01_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[3][7:4] <= data_in[3:0];
				BUF_full[7] <= 1'b1;
			end
			pull_information_8bit:
				$display("impossible state.\n");
			push_information_4bit:
			begin
				data_out <= {null, BUF[4][3:0]};
				BUF_full[6] <= 1'b0;
			end
			push_information_8bit:
				$display("impossible state.\n");
			endcase
		end
		16'b00_00_00_00_11_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[4][3:0] <= data_in[3:0];
				BUF_full[8] <= 1'b1;
			end
			pull_information_8bit:
			begin
				BUF[4][7:0] <= data_in[7:0];
				BUF_full[9:8] <= 2'b11;
			end	
			push_information_4bit:
			begin
				data_out <= {null, BUF[4][7:4]};
				BUF_full[7] <= 1'b0;
			end
			push_information_8bit:
			begin
				data_out <= BUF[4][7:0];
				BUF_full[7:6] <= 2'b00;
			end
			endcase
		end
		16'b00_00_00_01_11_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[4][7:4] <= data_in[3:0];
				BUF_full[9] <= 1'b1;
			end
			pull_information_8bit:
				$display("impossible state.\n");
			push_information_4bit:
			begin
				data_out <= {null, BUF[3][3:0]};
				BUF_full[8] <= 1'b0;
			end
			push_information_8bit:
				$display("impossible state.\n");
			endcase
		end
		16'b00_00_00_11_11_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[5][3:0] <= data_in[3:0];
				BUF_full[10] <= 1'b1;
			end
			pull_information_8bit:
			begin
				BUF[5][7:0] <= data_in[7:0];
				BUF_full[11:10] <= 2'b11;
			end
			push_information_4bit:
			begin
				data_out <= {null, BUF[3][7:4]};
				BUF_full[9] <= 1'b0;
			end
			push_information_8bit:
			begin
				data_out <= BUF[3][7:0];
				BUF_full[9:8] <= 2'b00;
			end
			endcase
		end
		16'b00_00_01_11_11_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[5][7:4] <= data_in[3:0];
				BUF_full[11] <= 1'b1;
			end
			pull_information_8bit:
				$display("impossible state.\n");
			push_information_4bit:
			begin
				data_out <= {null, BUF[2][3:0]};
				BUF_full[10] <= 1'b0;
			end
			push_information_8bit:
				$display("impossible state.\n");
			endcase
		end
		16'b00_00_11_11_11_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[6][3:0] <= data_in[3:0];
				BUF_full[12] <= 1'b1;
			end
			pull_information_8bit:
			begin
				BUF[6][7:0] <= data_in[7:0];
				BUF_full[13:12] <= 2'b11;
			end
			push_information_4bit:
			begin
				data_out <= {null, BUF[2][7:4]};
				BUF_full[11] <= 1'b0;
			end
			push_information_8bit:
			begin
				data_out <= BUF[2][7:0];
				BUF_full[11:10] <= 2'b00;
			end
			endcase
		end
		16'b00_01_11_11_11_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[6][7:4] <= data_in[3:0];
				BUF_full[13] <= 1'b1;
			end
			pull_information_8bit:
				$display("impossible state.\n");
			push_information_4bit:
			begin
				data_out <= {null, BUF[1][3:0]};
				BUF_full[12] <= 1'b0;
			end
			push_information_8bit:
				$display("impossible state.\n");
			endcase
		end
		16'b00_11_11_11_11_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[7][3:0] <= data_in[3:0];
				BUF_full[14] <= 1'b1;
			end
			pull_information_8bit:
			begin
				BUF[7][7:0] <= data_in[7:0];
				BUF_full[15:14] <= 2'b11;
			end
			push_information_4bit:
			begin
				data_out <= {null, BUF[1][7:4]};
				BUF_full[13] <= 1'b0;
			end
			push_information_8bit:
			begin
				data_out <= BUF[1][7:0];
				BUF_full[13:12] <= 2'b00;
			end
			endcase
		end
		16'b01_11_11_11_11_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
			begin
				BUF[7][7:4] <= data_in[3:0];
				BUF_full[15] <= 1'b1;
			end
			pull_information_8bit:
				$display("impossible state.\n");
			push_information_4bit:
			begin
				data_out <= {null, BUF[0][3:0]};
				BUF_full[14] <= 1'b0;
			end
			push_information_8bit:
				$display("impossible state.\n");
			endcase
		end
		16'b11_11_11_11_11_11_11_11:
		begin
			case(work_state)
			pull_information_4bit:
				$display("BUF is full now.\n");
			pull_information_8bit:
				$display("BUF is full now.\n");
			push_information_4bit:
			begin
				data_out <= {null, BUF[0][7:4]};
				BUF_full[15] <= 1'b0;
			end
			push_information_8bit:
			begin
				data_out <= BUF[0][7:0];
				BUF_full[15:14] <= 2'b00;
			end
			endcase
		end
		endcase
	end
end


assign buffer_state = BUF_full;

endmodule
