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
//valid是数据的给予方可以给信号，enable是数据的接收方有能力接收信号
output reg dma_to_mem_valid, //表示DMA对MEM传出的数据有效
output reg dma_to_mem_enable,//表示DMA可以对MEM传出数据了。这也就是说BUF满了
output reg dma_to_cpu_valid, //表示DMA对CPU传出的数据有效
output reg dma_to_cpu_enable,//表示DMA可以对CPU传出数据了。这也就是说BUF满了
output [3:0]mem_data_in,
output [7:0]cpu_data_in
);
localparam [1:0] M_to_C_MemtoB2_B1toCpu = 2'b00,
                 M_to_C_MemtoB1_B2toCpu = 2'b01,
                 C_to_M_CputoB1_B2toMem = 2'b10,
                 C_to_M_CputoB2_B1toMem = 2'b11,//这四个变量是状态表示, 例如MtoC表示是MEM向CPU传输数据
                 pull_information_4bit = 2'b00,//下面这四个是赋给buffer的
                 pull_information_8bit = 2'b01,
                 push_information_4bit = 2'b10,
                 push_information_8bit = 2'b11;

reg work_state, r_work_state1, r_work_state2;//储存两个buf的工作状态，用于assign的
wire w_work_state1, w_work_state2;//传递给两个BUF的工作状态
reg r_data_in1, r_data_in2;//储存两个BUF的输入数据，用于assign
wire w_data_in1, w_data_in2;//传递给两个BUF的输入数据
wire data_out1, data_out2;//两个BUF的输出数据
wire w_full1, w_full2;//两个BUF的存储状态

reg[15:0]BUF1_full;
reg[15:0]BUF2_full;




always @*
begin
    case(work_state)
        M_to_C_MemtoB2_B1toCpu:
            begin
                dma_to_mem_valid = 1'b0;//这两个变量是CPU给MEM传信号的时候才用的到的，因此一直置为0
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
                    begin//这里的begin视情况删掉
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

always @*
begin
    case(work_state)
    M_to_C_MemtoB2_B1toCpu:
    begin
        r_work_state1 = push_information_8bit;
        r_work_state2 = pull_information_4bit;
        r_data_in1 = 8'bzzzzzzzz;
        r_data_in2 = mem_data_out;
    end
    M_to_C_MemtoB1_B2toCpu:
    begin
        r_work_state1 = pull_information_4bit;
        r_work_state2 = push_information_8bit;
        r_data_in1 = mem_data_out;
        r_data_in2 = 8'bzzzzzzzz;
    end
    C_to_M_CputoB1_B2toMem:
    begin
        r_work_state1 = pull_information_8bit;
        r_work_state2 = push_information_4bit;
        r_data_in1 = cpu_data_out;
        r_data_in2 = 8'bzzzzzzzz;
    end
    C_to_M_CputoB2_B1toMem:
    begin
        r_work_state1 = push_information_4bit;
        r_work_state2 = pull_information_8bit;
        r_data_in1 = 8'bzzzzzzzz;
        r_data_in2 = cpu_data_out;
    end
    endcase
end

always @*
begin
    BUF1_full = w_full1;
    BUF2_full = w_full2;
end


assign w_work_state1 = r_work_state1;
assign w_work_state2 = r_work_state2;
assign w_data_in1 = r_data_in1;
assign w_data_in2 = r_data_in2;

assign mem_data_in = (work_state == C_to_M_CputoB2_B1toMem)? data_out1[3:0] :
                    ((work_state == C_to_M_CputoB1_B2toMem)? data_out2[3:0] : 4'bzzzz);
assign cpu_data_in = (work_state == M_to_C_MemtoB1_B2toCpu)? data_out2[7:0] :
                    ((work_state == M_to_C_MemtoB2_B1toCpu)? data_out1[7:0] : 8'bzzzzzzzz);

buffer BUF1(w_work_state1, w_data_in1, reset, clk, data_out1, w_full1);
buffer BUF2(w_work_state2, w_data_in2, reset, clk, data_out2, w_full2);
endmodule


