`include "mycpu.h"

module mem_stage(
    input                          clk           ,
    input                          reset         ,
    //allowin
    input                          ws_allowin    ,
    output                         ms_allowin    ,
    //from es
    input                          es_to_ms_valid,
    input  [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus  ,
    //to ws
    output                         ms_to_ws_valid,
    output [`MS_TO_WS_BUS_WD -1:0] ms_to_ws_bus  ,
    //from data-sram
    input  [31                 :0] data_sram_rdata,
    output [`MS_TO_DS_BUS_WD -1:0] back_to_id_stage_bus_from_mem
    //output [36:0]   mem_forwarding
);

reg         ms_valid;
wire        ms_ready_go;

reg [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus_r;
wire        ms_res_from_mem;
wire [ 3:0] ms_gr_wen;
wire [ 4:0] ms_dest;
wire [31:0] ms_alu_result;
wire [31:0] ms_pc;

wire [1:0] last_2_bits_of_address;  // prj7 added
wire ms_inst_lb;    // prj7 added
wire ms_inst_lbu;   // prj7 added
wire ms_inst_lh;    // prj7 added
wire ms_inst_lhu;   // prj7 added
wire ms_inst_lwl;   // prj7 added
wire ms_inst_lwr;   // prj7 added


assign {last_2_bits_of_address,  //81:80
        ms_inst_lwl    ,         //79:79
        ms_inst_lwr    ,         //78:78 
        ms_inst_lh     ,         //77:77
        ms_inst_lhu    ,         //76:76
        ms_inst_lb     ,         //75:75
        ms_inst_lbu    ,         //74:74
        ms_res_from_mem,         //73:73
        ms_gr_wen      ,         //72:69
        ms_dest        ,         //68:64
        ms_alu_result  ,         //63:32
        ms_pc                    //31:0
       } = es_to_ms_bus_r; //译码

wire [31:0] mem_result;
wire [31:0] ms_final_result;

wire [31:0] mem_result_lb;      // prj7 added
wire [31:0] mem_result_lbu;     // prj7 added
wire [31:0] mem_result_lh;      // prj7 added
wire [31:0] mem_result_lhu;     // prj7 added
wire [31:0] mem_result_lwl;     // prj7 added
wire [31:0] mem_result_lwr;     // prj7 added

assign ms_to_ws_bus = {ms_gr_wen      ,  //72:69
                       ms_dest        ,  //68:64
                       ms_final_result,  //63:32
                       ms_pc             //31:0
                      };

assign ms_ready_go    = 1'b1;
assign ms_allowin     = !ms_valid || ms_ready_go && ws_allowin;
assign ms_to_ws_valid = ms_valid && ms_ready_go;
always @(posedge clk) begin
    if (reset) begin
        ms_valid <= 1'b0;
    end
    else if (ms_allowin) begin
        ms_valid <= es_to_ms_valid;
    end

    if (es_to_ms_valid && ms_allowin) begin
        es_to_ms_bus_r  <= es_to_ms_bus; //bug？？？阻塞赋值？？
    end
end

//assign mem_result = data_sram_rdata;
assign mem_result = (ms_inst_lb) ? mem_result_lb :
                    (ms_inst_lbu)? mem_result_lbu:
                    (ms_inst_lh) ? mem_result_lh :
                    (ms_inst_lhu)? mem_result_lhu:
                    (ms_inst_lwl)? mem_result_lwl:
                    (ms_inst_lwr)? mem_result_lwr:data_sram_rdata;



assign mem_result_lb  = (last_2_bits_of_address == 2'b00)? {{24{data_sram_rdata[ 7]}}, data_sram_rdata[ 7: 0]} :
                        (last_2_bits_of_address == 2'b01)? {{24{data_sram_rdata[15]}}, data_sram_rdata[15: 8]} :
                        (last_2_bits_of_address == 2'b10)? {{24{data_sram_rdata[23]}}, data_sram_rdata[23:16]} : 
                                                           {{24{data_sram_rdata[31]}}, data_sram_rdata[31:24]};

// 虽然说lh的地址实际上只有00和10两种情况，但是由于不熟悉此cpu的例外处理机制，为了方便起见将异常的01和11也用00和10处理
assign mem_result_lh  = (last_2_bits_of_address == 2'b00)? {{16{data_sram_rdata[15]}}, data_sram_rdata[15: 0]} :  
                        (last_2_bits_of_address == 2'b01)? {{16{data_sram_rdata[15]}}, data_sram_rdata[15: 0]} :
                        (last_2_bits_of_address == 2'b10)? {{16{data_sram_rdata[31]}}, data_sram_rdata[31:16]} : 
                                                           {{16{data_sram_rdata[31]}}, data_sram_rdata[31:16]};



assign mem_result_lbu = (last_2_bits_of_address == 2'b00)? {{24{1'b0}}, data_sram_rdata[ 7: 0]} :
                        (last_2_bits_of_address == 2'b01)? {{24{1'b0}}, data_sram_rdata[15: 8]} :
                        (last_2_bits_of_address == 2'b10)? {{24{1'b0}}, data_sram_rdata[23:16]} : 
                                                           {{24{1'b0}}, data_sram_rdata[31:24]};

// 虽然说lhu的地址实际上只有00和10两种情况，但是由于不熟悉此cpu的例外处理机制，为了方便起见将异常的01和11也用00和10处理
assign mem_result_lhu = (last_2_bits_of_address == 2'b00)? {{16{1'b0}}, data_sram_rdata[15: 0]} :  
                        (last_2_bits_of_address == 2'b01)? {{16{1'b0}}, data_sram_rdata[15: 0]} :
                        (last_2_bits_of_address == 2'b10)? {{16{1'b0}}, data_sram_rdata[31:16]} : 
                                                           {{16{1'b0}}, data_sram_rdata[31:16]};

assign mem_result_lwl = (last_2_bits_of_address == 2'b00)? {4{data_sram_rdata[ 7:0]}} : 
                        (last_2_bits_of_address == 2'b01)? {2{data_sram_rdata[15:0]}} :
                        (last_2_bits_of_address == 2'b10)? {data_sram_rdata[24:0], 8'b0} : data_sram_rdata;

assign mem_result_lwr = (last_2_bits_of_address == 2'b11)? {4{data_sram_rdata[31:24]}} :
                        (last_2_bits_of_address == 2'b10)? {2{data_sram_rdata[31:16]}} :
                        (last_2_bits_of_address == 2'b01)? {8'b0, data_sram_rdata[31:8]} : data_sram_rdata;


assign ms_final_result = ms_res_from_mem ? mem_result //判断写回的数据到底是从mem里面来的，还是alu算出来的
                                         : ms_alu_result;//res的意思应该就是result


assign back_to_id_stage_bus_from_mem = {ms_final_result,    //41:10
                                        ms_valid,           //9
                                        ms_gr_wen,          //8:5
                                        ms_dest             //4:0
                                        };
/*
assign mem_forwarding = {ms_final_result,   //36:5
                         ms_dest            //4:0
                        };
*/

endmodule
