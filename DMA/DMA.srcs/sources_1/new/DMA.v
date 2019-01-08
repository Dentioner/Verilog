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
input reset, //初始化信号
input clk,
input exchange,//这个信号是用来让DMA传输数据的方向颠倒过来的
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
localparam [1:0] M_to_C_MemtoB2_B1toCpu = 2'b00,//这样安排顺序有格雷码的意思，不同状态之间只有一个参数在变
                 M_to_C_MemtoB1_B2toCpu = 2'b01,
                 C_to_M_CputoB1_B2toMem = 2'b10,
                 C_to_M_CputoB2_B1toMem = 2'b11,//这四个变量是状态表示, 例如MtoC表示是MEM向CPU传输数据
                 pull_information_4bit  = 2'b00,//下面这四个是赋给buffer的
                 pull_information_8bit  = 2'b01,
                 push_information_4bit  = 2'b10,
                 push_information_8bit  = 2'b11;

reg  [1:0]  work_state;
reg  [1:0]  r_work_state1, r_work_state2;//储存两个buf的工作状态，用于assign的
wire [1:0]  w_work_state1, w_work_state2;//传递给两个BUF的工作状态

reg  [7:0]  r_data_in1, r_data_in2;//储存两个BUF的输入数据，用于assign
wire [7:0]  w_data_in1, w_data_in2;//传递给两个BUF的输入数据
wire [7:0]  data_out1,  data_out2;//两个BUF的输出数据
wire [15:0] w_full1,    w_full2;//两个BUF的存储状态

wire w_input_enable1,  w_input_enable2;//两个BUF的input enable信号
wire w_output_valid1,  w_output_valid2;//两个BUF的output valid信号
wire w_input_valid1,   w_input_valid2;//两个BUF的input valid信号
reg  r_input_valid1,   r_input_valid2;
wire w_output_enable1, w_output_enable2;//两个BUF的output enable信号
reg  r_output_enable1, r_output_enable2;

reg [15:0] BUF1_full;
reg [15:0] BUF2_full;


always @*//这个always是用来将DMA的四种工作状态翻译给BUF，并将外界输入的信号传递给buf
begin
    case(work_state)
    M_to_C_MemtoB2_B1toCpu:
    begin
        r_work_state1 = push_information_8bit;
        r_work_state2 = pull_information_4bit;
        r_data_in1 = 8'bzzzzzzzz;
        r_data_in2 = mem_data_out;

        r_input_valid1    = 1'b0;
        r_input_valid2    = mem_to_dma_valid;
        dma_to_mem_enable = w_input_enable2;

        r_output_enable1  = cpu_to_dma_enable;
        r_output_enable2  = 1'b0;
        dma_to_cpu_valid  = w_output_valid1;

        dma_to_mem_valid  = 1'b0;//这两个变量是CPU给MEM传信号的时候才用的到的，因此一直置为0
        dma_to_cpu_enable = 1'b0;
    end
    M_to_C_MemtoB1_B2toCpu:
    begin
        r_work_state1 = pull_information_4bit;
        r_work_state2 = push_information_8bit;
        r_data_in1 = mem_data_out;
        r_data_in2 = 8'bzzzzzzzz;

        r_input_valid2    = 1'b0;
        r_input_valid1    = mem_to_dma_valid;
        dma_to_mem_enable = w_input_enable1;

        r_output_enable2  = cpu_to_dma_enable;
        r_output_enable1  = 1'b0;
        dma_to_cpu_valid  = w_output_valid2;

        dma_to_mem_valid  = 1'b0;//这两个变量是CPU给MEM传信号的时候才用的到的，因此一直置为0
        dma_to_cpu_enable = 1'b0;
    end
    C_to_M_CputoB1_B2toMem:
    begin
        r_work_state1 = pull_information_8bit;
        r_work_state2 = push_information_4bit;
        r_data_in1 = cpu_data_out;
        r_data_in2 = 8'bzzzzzzzz;

        r_input_valid1    = cpu_to_dma_valid;
        r_input_valid2    = 1'b0;
        dma_to_cpu_enable = w_input_enable1;

        r_output_enable1  = 1'b0;
        r_output_enable2  = mem_to_dma_enable;
        dma_to_mem_valid  = w_output_valid2;

        dma_to_cpu_valid  = 1'b0;
        dma_to_mem_enable = 1'b0;

    end
    C_to_M_CputoB2_B1toMem:
    begin
        r_work_state1 = push_information_4bit;
        r_work_state2 = pull_information_8bit;
        r_data_in1 = 8'bzzzzzzzz;
        r_data_in2 = cpu_data_out;

        r_input_valid2    = cpu_to_dma_valid;
        r_input_valid1    = 1'b0;
        dma_to_cpu_enable = w_input_enable2;

        r_output_enable2  = 1'b0;
        r_output_enable1  = mem_to_dma_enable;
        dma_to_mem_valid  = w_output_valid1;

        dma_to_cpu_valid  = 1'b0;
        dma_to_mem_enable = 1'b0;
    end
    default:
            $display("This is an impossible case.\n");
    endcase
end

always @*
begin
    BUF1_full = w_full1;
    BUF2_full = w_full2;
end


always @*//这个always是用来在DMA的四种work state之间切换的
begin
    case(work_state)
    M_to_C_MemtoB2_B1toCpu:
        if(BUF1_full == 16'b0000000000000000 && BUF2_full == 16'b1111111111111111)
            work_state = M_to_C_MemtoB1_B2toCpu;
    M_to_C_MemtoB1_B2toCpu:
        if(BUF2_full == 16'b0000000000000000 && BUF1_full == 16'b1111111111111111)
            work_state = M_to_C_MemtoB2_B1toCpu;
    C_to_M_CputoB1_B2toMem:
        if(BUF2_full == 16'b0000000000000000 && BUF1_full == 16'b1111111111111111)
            work_state = C_to_M_CputoB2_B1toMem;
    C_to_M_CputoB2_B1toMem:
        if(BUF1_full == 16'b0000000000000000 && BUF2_full == 16'b1111111111111111)
            work_state = C_to_M_CputoB1_B2toMem;
    endcase
     
end

always @(posedge exchange)
    work_state[1] = ~ work_state[1];

always @(posedge reset) 
    work_state = M_to_C_MemtoB1_B2toCpu;
    //work_state = C_to_M_CputoB1_B2toMem;

assign w_work_state1    = r_work_state1;
assign w_work_state2    = r_work_state2;
assign w_data_in1       = r_data_in1;
assign w_data_in2       = r_data_in2;
assign w_input_valid1   = r_input_valid1;
assign w_input_valid2   = r_input_valid2;
assign w_output_enable1 = r_output_enable1;
assign w_output_enable2 = r_output_enable2;


assign mem_data_in = (work_state == C_to_M_CputoB2_B1toMem)? data_out1[3:0] :
                    ((work_state == C_to_M_CputoB1_B2toMem)? data_out2[3:0] : 4'bzzzz);
assign cpu_data_in = (work_state == M_to_C_MemtoB1_B2toCpu)? data_out2[7:0] :
                    ((work_state == M_to_C_MemtoB2_B1toCpu)? data_out1[7:0] : 8'bzzzzzzzz);



buffer BUF1(w_work_state1, w_data_in1, reset, exchange, clk, w_input_valid1, w_output_enable1, data_out1, w_full1, w_input_enable1, w_output_valid1);
buffer BUF2(w_work_state2, w_data_in2, reset, exchange, clk, w_input_valid2, w_output_enable2, data_out2, w_full2, w_input_enable2, w_output_valid2);
endmodule


