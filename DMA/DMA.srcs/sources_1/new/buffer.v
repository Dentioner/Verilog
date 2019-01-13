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
input [1:0] work_state,// workstate是啥，由高层模块定义，因此要在DMA里面讨论赋给buffer的workstate随那四种状态如何变化
input [7:0] data_in,
input rst,
input exchange,
input clk,
input input_valid,
input output_enable,

output [7:0]  w_data_out,
output [15:0] buffer_state,
output w_input_enable,
output w_output_valid
);

localparam [1:0] pull_information_4bit = 2'b00,
                 pull_information_8bit = 2'b01,
                 push_information_4bit = 2'b10,
                 push_information_8bit = 2'b11;
                
localparam [3:0] null = 4'bzzzz;

reg [7:0]  BUF[7:0];
reg [15:0] BUF_full = 16'b0000000000000000;
reg [7:0]  data_out;
reg input_enable, output_valid;

integer index;

always @(posedge clk or posedge rst or posedge exchange) 
begin
	if (rst || exchange) // reset
	begin
		BUF_full = 16'b0000000000000000;
		input_enable = 1'b1;
		output_valid = 1'b0;
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
			if (input_valid && input_enable) 
			begin
				BUF[0][3:0] <= data_in[3:0];
				BUF_full[0] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
			begin
				BUF[0][7:0] <= data_in[7:0];
				BUF_full[1:0] <= 2'b11;
			end

			default:;
			endcase
		end

		16'b00_00_00_00_00_00_00_01:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[0][7:4] <= data_in[3:0];
				BUF_full[1] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
				$display("impossible state.\n");

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF[7][7:4] <= null;				
				BUF_full[0] <= 1'b0;
			end

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");
			endcase
		end

		16'b00_00_00_00_00_00_00_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[1][3:0] <= data_in[3:0];
				BUF_full[2] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
			begin
				BUF[1][7:0] <= data_in[7:0];
				BUF_full[3:2] <= 2'b11;
			end

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[1] <= 1'b0;
				BUF[7][3:0] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
			begin
				BUF_full[1:0] <= 2'b00;
				BUF[7][7:0] <= {null, null};
			end
			endcase
		end

		16'b00_00_00_00_00_00_01_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[1][7:4] <= data_in[3:0];
				BUF_full[3] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
				$display("impossible state.\n");

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[2] <= 1'b0;
				BUF[6][7:4] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");
			endcase
		end

		16'b00_00_00_00_00_00_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[2][3:0] <= data_in[3:0];
				BUF_full[4] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
			begin
				BUF[2][7:0] <= data_in[7:0];
				BUF_full[5:4] <= 2'b11;
			end	

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[3] <= 1'b0;
				BUF[6][3:0] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
			begin
				BUF_full[3:2] <= 2'b00;
				BUF[6][7:0] <= {null, null};
			end
			endcase
		end

		16'b00_00_00_00_00_01_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[2][7:4] <= data_in[3:0];
				BUF_full[5] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
				$display("impossible state.\n");

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[4] <= 1'b0;
				BUF[5][7:4] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");
			endcase
		end

		16'b00_00_00_00_00_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[3][3:0] <= data_in[3:0];
				BUF_full[6] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
			begin
				BUF[3][7:0] <= data_in[7:0];
				BUF_full[7:6] <= 2'b11;
			end	

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[5] <= 1'b0;
				BUF[5][3:0] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
			begin
				BUF_full[5:4] <= 2'b00;
				BUF[5][7:0] <= {null, null};
			end
			endcase
		end

		16'b00_00_00_00_01_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[3][7:4] <= data_in[3:0];
				BUF_full[7] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
				$display("impossible state.\n");

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[6] <= 1'b0;
				BUF[4][7:4] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");
			endcase
		end

		16'b00_00_00_00_11_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[4][3:0] <= data_in[3:0];
				BUF_full[8] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
			begin
				BUF[4][7:0] <= data_in[7:0];
				BUF_full[9:8] <= 2'b11;
			end	

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[7] <= 1'b0;
				BUF[4][3:0] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
			begin
				BUF_full[7:6] <= 2'b00;
				BUF[4][7:0] <= {null, null};
			end
			endcase
		end

		16'b00_00_00_01_11_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[4][7:4] <= data_in[3:0];
				BUF_full[9] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
				$display("impossible state.\n");

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[8] <= 1'b0;
				BUF[3][7:4] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");
			endcase
		end

		16'b00_00_00_11_11_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[5][3:0] <= data_in[3:0];
				BUF_full[10] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
			begin
				BUF[5][7:0] <= data_in[7:0];
				BUF_full[11:10] <= 2'b11;
			end

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[9] <= 1'b0;
				BUF[3][3:0] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
			begin
				BUF_full[9:8] <= 2'b00;
				BUF[3][7:0] <= {null, null};
			end
			endcase
		end

		16'b00_00_01_11_11_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[5][7:4] <= data_in[3:0];
				BUF_full[11] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
				$display("impossible state.\n");

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[10] <= 1'b0;
				BUF[2][7:4] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");
			endcase
		end

		16'b00_00_11_11_11_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[6][3:0] <= data_in[3:0];
				BUF_full[12] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
			begin
				BUF[6][7:0] <= data_in[7:0];
				BUF_full[13:12] <= 2'b11;
			end

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[11] <= 1'b0;
				BUF[2][3:0] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
			begin
				BUF_full[11:10] <= 2'b00;
				BUF[2][7:0] <= {null, null};
			end
			endcase
		end

		16'b00_01_11_11_11_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[6][7:4] <= data_in[3:0];
				BUF_full[13] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
				$display("impossible state.\n");

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[12] <= 1'b0;
				BUF[1][7:4] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");
			endcase
		end

		16'b00_11_11_11_11_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[7][3:0] <= data_in[3:0];
				BUF_full[14] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
			begin
				BUF[7][7:0] <= data_in[7:0];
				BUF_full[15:14] <= 2'b11;
			end

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[13] <= 1'b0;
				BUF[1][3:0] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
			begin
				BUF_full[13:12] <= 2'b00;
				BUF[1][7:0] <= {null, null};
			end
			endcase
		end

		16'b01_11_11_11_11_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
			begin
				BUF[7][7:4] <= data_in[3:0];
				BUF_full[15] <= 1'b1;
			end

			pull_information_8bit:
			if (input_valid && input_enable) 
				$display("impossible state.\n");

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[14] <= 1'b0;
				BUF[0][7:4] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");
			endcase
		end

		16'b11_11_11_11_11_11_11_11:
		begin
			case(work_state)

			pull_information_4bit:
			if (input_valid && input_enable) 
				$display("BUF is full now.\n");

			pull_information_8bit:
			if (input_valid && input_enable) 
				$display("BUF is full now.\n");

			push_information_4bit:
			if (output_valid && output_enable)
			begin
				BUF_full[15] <= 1'b0;
				BUF[0][3:0] <= null;
			end

			push_information_8bit:
			if (output_valid && output_enable)
			begin
				BUF_full[15:14] <= 2'b00;
				BUF[0][7:0] <= {null, null};
			end
			endcase
		end
		endcase
	end
end

always @*
begin
	if (!rst && !exchange) 
	begin
		case(BUF_full)

		16'b00_00_00_00_00_00_00_00:
		begin
			case(work_state)

			push_information_4bit:
			if (output_enable)
				data_out = {null, null};

			push_information_8bit:
			if (output_enable)
				data_out = {null, null};

			default:;
			endcase
		end

		16'b00_00_00_00_00_00_00_01:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[7][7:4]};

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");

			default:;
			endcase
		end

		16'b00_00_00_00_00_00_00_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[7][3:0]};

			push_information_8bit:
			if (output_valid && output_enable)
				data_out = BUF[7][7:0];

			default:;
			endcase
		end

		16'b00_00_00_00_00_00_01_11:
		begin
			case(work_state)
			
			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[6][7:4]};

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");

			default:;
			endcase
		end

		16'b00_00_00_00_00_00_11_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[6][3:0]};

			push_information_8bit:
			if (output_valid && output_enable)
				data_out = BUF[6][7:0];

			default:;
			endcase
		end

		16'b00_00_00_00_00_01_11_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[5][7:4]};

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");

			default:;
			endcase
		end

		16'b00_00_00_00_00_11_11_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[5][3:0]};

			push_information_8bit:
			if (output_valid && output_enable)
				data_out = BUF[5][7:0];

			default:;
			endcase
		end

		16'b00_00_00_00_01_11_11_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[4][7:4]};

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");

			default:;
			endcase
		end

		16'b00_00_00_00_11_11_11_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[4][3:0]};

			push_information_8bit:
			if (output_valid && output_enable)
				data_out = BUF[4][7:0];

			default:;
			endcase
		end

		16'b00_00_00_01_11_11_11_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[3][7:4]};

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");

			default:;
			endcase
		end

		16'b00_00_00_11_11_11_11_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[3][3:0]};

			push_information_8bit:
			if (output_valid && output_enable)
				data_out = BUF[3][7:0];

			default:;
			endcase
		end

		16'b00_00_01_11_11_11_11_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[2][7:4]};

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");

			default:;
			endcase
		end

		16'b00_00_11_11_11_11_11_11:
		begin
			case(work_state)
			
			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[2][3:0]};

			push_information_8bit:
			if (output_valid && output_enable)
				data_out = BUF[2][7:0];

			default:;
			endcase
		end

		16'b00_01_11_11_11_11_11_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[1][7:4]};

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");

			default:;
			endcase
		end

		16'b00_11_11_11_11_11_11_11:
		begin
			case(work_state)

			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[1][3:0]};

			push_information_8bit:
			if (output_valid && output_enable)
				data_out = BUF[1][7:0];

			default:;
			endcase
		end

		16'b01_11_11_11_11_11_11_11:
		begin
			case(work_state)
		
			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[0][7:4]};

			push_information_8bit:
			if (output_valid && output_enable)
				$display("impossible state.\n");

			default:;
			endcase
		end

		16'b11_11_11_11_11_11_11_11:
		begin
			case(work_state)
			
			push_information_4bit:
			if (output_valid && output_enable)
				data_out = {null, BUF[0][3:0]};

			push_information_8bit:
			if (output_valid && output_enable)
				data_out = BUF[0][7:0];

			default:;
			endcase
		end
		endcase
	end
end


always @*
begin
	if (BUF_full == 16'b1111111111111111)
        begin
        output_valid = 1'b1;
        input_enable = 1'b0;
        end
    if (BUF_full == 16'b0000000000000000)
        begin
        input_enable = 1'b1;
        output_valid = 1'b0;
        end
end

assign buffer_state = BUF_full;
assign w_output_valid = output_valid;
assign w_input_enable = input_enable;
assign w_data_out = (output_enable == 1'b0) ? {null, null} : data_out;

endmodule
