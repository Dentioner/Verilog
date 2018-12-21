`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/11 10:03:51
// Design Name: 
// Module Name: DMA
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


module DMA(
input reset, 
input clk,
input mem_to_dma_valid,  //random_input
input mem_to_dma_enable, //random_input
input cpu_to_dma_valid, //random_input
input cpu_to_dma_enable,//random_input
input [3:0]mem_data_out,
input [7:0]cpu_data_out,
output reg dma_to_mem_valid,
output reg dma_to_mem_enable,
output reg dma_to_cpu_valid,
output reg dma_to_cpu_enable,
output [3:0]mem_data_in,
output [7:0]cpu_data_in
);
localparam [1:0] M_to_C_MemtoB2_B1toCpu = 2'b00,
                 M_to_C_MemtoB1_B2toCpu = 2'b01,
                 C_to_M_CputoB1_B2toMem = 2'b10,
                 C_to_M_CputoB2_B1toMem = 2'b11;
reg work_state;
reg[7:0] BUF1[7:0];
reg[7:0] BUF2[7:0];
reg[15:0]BUF1_full = 16'b0000000000000000;
reg[15:0]BUF2_full = 16'b0000000000000000;
integer index;

always @ (posedge clk or reset)
begin
    if (reset)
    begin
        work_state = M_to_C_MemtoB2_B1toCpu;//initialize
        BUF1_full = 16'b0000000000000000;
        BUF2_full = 16'b0000000000000000;
        for (index = 0; index < 8; index = index + 1)
        begin
            BUF1[index][7:0] = 8'bzzzzzzzz;
            BUF2[index][7:0] = 8'bzzzzzzzz;
        end
    end
    else
    begin
        
    end
end


always @*
begin
    case(work_state)
        M_to_C_MemtoB2_B1toCpu:
            begin
                dma_to_mem_valid = 1'b0;
                dma_to_cpu_enable = 1'b0;
                if (BUF1_full == 16'b1111111111111111)
                    begin
                        dma_to_cpu_valid = 1'b1;
                        //input_enable = 1'b0;
                    end
                if (BUF2_full == 16'b0000000000000000)
                    begin
                        dma_to_mem_enable = 1'b1;
                        //output_valid = 1'b0;
                    end
            end
        M_to_C_MemtoB1_B2toCpu:
            begin
                dma_to_mem_valid = 1'b0;
                dma_to_cpu_enable = 1'b0;
                if (BUF2_full == 16'b1111111111111111)
                    begin
                        dma_to_cpu_valid = 1'b1;
                    end
                if (BUF1_full == 16'b0000000000000000)
                    begin
                        dma_to_mem_enable = 1'b1;
                    end
            end
        C_to_M_CputoB1_B2toMem:
            begin
                dma_to_cpu_valid = 1'b0;
                dma_to_mem_enable = 1'b0;
                if (BUF2_full == 16'b1111111111111111)
                    dma_to_mem_valid = 1'b0;
                if (BUF1_full == 16'b0000000000000000)                     
                    dma_to_cpu_enable = 1'b0;
            end
        C_to_M_CputoB2_B1toMem:
            begin
                dma_to_cpu_valid = 1'b0;
                dma_to_mem_enable = 1'b0;
                if (BUF1_full == 16'b1111111111111111)
                    dma_to_mem_valid = 1'b1;
                if (BUF2_full == 16'b0000000000000000)                     
                    dma_to_cpu_enable = 1'b1;
            end
         default:
            $display("This is an impossible case.\n");
    endcase
    
end

endmodule

/*
module buffer(
input 
);

endmodule
*/