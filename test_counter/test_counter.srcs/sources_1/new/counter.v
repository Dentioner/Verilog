`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/09 22:19:18
// Design Name: 
// Module Name: counter
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


`define STATE_RESET 8'd0
`define STATE_RUN 8'd1
`define STATE_HALT 8'd2

module counter(
    input clk,
    input [31:0] interval,
    input [7:0] state,
    output reg [31:0] counter
	);

	/*TODO: Add your logic code here*/

reg [31:0]count_for_interval;
reg [7:0]r_state = 0;

/*
always @(posedge clk && (r_state == `STATE_RUN)) 
begin
	if (count_for_interval < interval)
		count_for_interval <= count_for_interval + 1;
	else 
	begin
		count_for_interval <= 0;
		counter <= counter + 1;	
	end
end


always @*
begin
	if (r_state == `STATE_RESET)
	begin
		counter = 0;
		count_for_interval = 0;
	end
end

always @*
begin
	r_state = state;
end
*/


always @(posedge clk or posedge state ) 
begin
	if (state == `STATE_RESET) 
	begin
		counter <= 0;// reset
		count_for_interval <=0;
	end
	else if (state == `STATE_RUN) 
	begin
		if (count_for_interval < interval)
		count_for_interval <= count_for_interval + 1;
		else 
		begin
		count_for_interval <= 0;
		counter <= counter + 1;	
		end
	end
end

endmodule

