`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/06 08:51:04
// Design Name: 
// Module Name: distributed_ram_top
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


module ram_top (
    input         clk      ,
    input  [15:0] ram_addr ,
    input  [31:0] ram_wdata,
    input         ram_wen  ,
    output [31:0] ram_rdata		   
);
					   
distributed_ram distributed_ram(
    .clk (clk       ),
    .we  (ram_wen   ),
    .a   (ram_addr  ),
    .d   (ram_wdata ),
    .spo (ram_rdata ) 
);

endmodule

