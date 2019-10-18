`include "mycpu.h"

module exe_stage(
    input                          clk           ,
    input                          reset         ,
    //allowin
    input                          ms_allowin    ,
    output                         es_allowin    ,
    //from ds
    input                          ds_to_es_valid,
    input  [`DS_TO_ES_BUS_WD -1:0] ds_to_es_bus  ,
    //to ms
    output                         es_to_ms_valid,
    output [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus  ,
    // data sram interface
    output        data_sram_en   ,
    output [ 3:0] data_sram_wen  ,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,

    output [`ES_TO_DS_BUS_WD - 1:0]    back_to_id_stage_bus_from_exe  // 用于阻塞&前递机制的反馈信号
    //output [36:0]   exe_forwarding    
);

reg         es_valid      ;
wire        es_ready_go   ;

reg  [`DS_TO_ES_BUS_WD -1:0] ds_to_es_bus_r;
wire [11:0] es_alu_op     ;
wire        es_load_op    ;
wire        es_src1_is_sa ;  
wire        es_src1_is_pc ;
wire        es_src2_is_imm_symbol_extend;
wire        es_src2_is_imm_zero_extend; 
wire        es_src2_is_8  ;
wire        es_gr_we      ;
wire        es_mem_we     ;
wire        es_hi_we      ;     // prj6 added
wire        es_lo_we      ;     // prj6 added
wire        es_div_en     ;     // prj6 added
wire        es_inst_mult  ;     // prj6 added   
wire        es_inst_multu ;     // prj6 added
wire        es_inst_div   ;     // prj6 added
wire        es_inst_divu  ;     // prj6 added
wire        es_inst_mfhi  ;     // prj6 added
wire        es_inst_mflo  ;     // prj6 added
wire        es_inst_mthi  ;     // prj6 added
wire        es_inst_mtlo  ;     // prj6 added

wire        es_inst_lb    ;     // prj7 added
wire        es_inst_lbu   ;     // prj7 added
wire        es_inst_lh    ;     // prj7 added
wire        es_inst_lhu   ;     // prj7 added
wire        es_inst_lwl   ;     // prj7 added
wire        es_inst_lwr   ;     // prj7 added

wire        es_inst_sb    ;     // prj7 added
wire        es_inst_sh    ;     // prj7 added

wire [ 3:0]  gr_wen       ;     // prj7 added
wire [ 3:0]  gr_wen_lwr   ;     // prj7 added
wire [ 3:0]  gr_wen_lwl   ;     // prj7 added

wire [31:0] es_final_result;    // prj6 added

wire [ 4:0] es_dest       ;
wire [15:0] es_imm        ;
wire [31:0] es_rs_value   ;
wire [31:0] es_rt_value   ;
wire [31:0] es_pc         ;
assign {es_alu_op      ,                //152:141
        es_load_op     ,                //140:140
        es_src1_is_sa  ,                //139:139
        es_src1_is_pc  ,                //138:138
        es_src2_is_imm_symbol_extend ,  //137:137
        es_src2_is_imm_zero_extend ,    //136:136
        es_src2_is_8   ,                //135:135
        es_gr_we       ,                //134:134
        es_mem_we      ,                //133:133
        es_inst_sb     ,                //132:132
        es_inst_sh     ,                //131:131
        es_inst_lwl    ,                //130:130
        es_inst_lwr    ,                //129:129
        es_inst_lh     ,                //128:128
        es_inst_lhu    ,                //127:127
        es_inst_lb     ,                //126:126
        es_inst_lbu    ,                //125:125
        es_inst_mult   ,                //124:124
        es_inst_multu  ,                //123:123
        es_inst_div    ,                //122:122
        es_inst_divu   ,                //121:121
        es_inst_mfhi   ,                //120:120
        es_inst_mflo   ,                //119:119
        es_inst_mthi   ,                //118:118
        es_inst_mtlo   ,                //117:117        
        es_dest        ,                //116:112
        es_imm         ,                //111:96
        es_rs_value    ,                //95 :64
        es_rt_value    ,                //63 :32
        es_pc                           //31 :0
       } = ds_to_es_bus_r;

wire [31:0] es_alu_src1   ;//alu的信号
wire [31:0] es_alu_src2   ;
wire [31:0] es_alu_result ;

wire        es_res_from_mem;

//wire    this_stage_has_instruction;

reg  [31:0] hi;     // prj6 added
reg  [31:0] lo;     // prj6 added

wire [31:0] mult_result_hi;     // prj6 added
wire [31:0] mult_result_lo;     // prj6 added
wire [31:0] div_result_hi;      // prj6 added
wire [31:0] div_result_lo;      // prj6 added
wire [31:0] wdata_hi;           // prj6 added
wire [31:0] wdata_lo;           // prj6 added

wire div_finished;              // prj6 added

wire [1:0] last_2_bits_of_address;  // prj7 added

wire [3:0] data_sram_wen_sb;        // prj7 added
wire [3:0] data_sram_wen_sh;        // prj7 added

assign last_2_bits_of_address = data_sram_addr[1:0];    // prj7 added

assign es_res_from_mem = es_load_op;
assign es_to_ms_bus = {last_2_bits_of_address,  //79:78
                       es_inst_lh     ,         //77:77
                       es_inst_lhu    ,         //76:76
                       es_inst_lb     ,         //75:75
                       es_inst_lbu    ,         //74:74
                       es_res_from_mem,         //73:73 //合成给mem阶段的总线信号
                       //es_gr_we       ,         //69:69
                       gr_wen         ,         //72:69
                       es_dest        ,         //68:64
                       es_final_result,         //63:32
                       es_pc                    //31:0
                      };



assign back_to_id_stage_bus_from_exe = {es_load_op,         //42
                                        es_final_result,    //41:10
                                        es_valid,           //9
                                        //es_gr_we,           //5
                                        gr_wen,             //8:5          
                                        es_dest             //4:0
                                       };
/*
assign exe_forwarding = {es_alu_result,     //36:5
                         es_dest            //4:0
                        };
*/

//assign es_ready_go    = 1'b1;
assign es_ready_go = (!es_div_en)? 1 : div_finished;

assign es_allowin     = !es_valid || es_ready_go && ms_allowin;
assign es_to_ms_valid =  es_valid && es_ready_go;
always @(posedge clk) begin
    if (reset) begin
        es_valid <= 1'b0;
    end
    else if (es_allowin) begin
        es_valid <= ds_to_es_valid;
    end

    if (ds_to_es_valid && es_allowin) begin
        ds_to_es_bus_r <= ds_to_es_bus;
    end
end

assign es_alu_src1 = es_src1_is_sa  ? {27'b0, es_imm[10:6]} : 
                     es_src1_is_pc  ? es_pc[31:0] :
                                      es_rs_value;
assign es_alu_src2 = es_src2_is_imm_symbol_extend ? {{16{es_imm[15]}}, es_imm[15:0]} : 
                     es_src2_is_imm_zero_extend ?   {{16{1'b0}}, es_imm[15:0]} : 
                     es_src2_is_8   ? 32'd8 :
                                      es_rt_value;

alu u_alu(
    .alu_op     (es_alu_op    ),
    //.alu_src1   (es_alu_src2  ),
    .alu_src1   (es_alu_src1  ),
    .alu_src2   (es_alu_src2  ),
    .alu_result (es_alu_result)
    );

assign data_sram_en    = 1'b1;
//assign data_sram_wen   = es_mem_we&&es_valid ? 4'hf : 4'h0;//ram 字节写使能信号，高电平有效
assign data_sram_wen   = ((!es_mem_we) || (!es_valid))? 4'h0 :
                         (es_inst_sb)? data_sram_wen_sb      : 
                         (es_inst_sh)? data_sram_wen_sh      : 4'hf;


assign data_sram_wen_sb = (last_2_bits_of_address == 2'b00)? 4'b0001 : 
                          (last_2_bits_of_address == 2'b01)? 4'b0010 : 
                          (last_2_bits_of_address == 2'b10)? 4'b0100 : 4'b1000;
// 虽然说sh的地址实际上只有00和10两种情况，但是由于不熟悉此cpu的例外处理机制，为了方便起见将异常的01和11也用00和10处理
assign data_sram_wen_sh = (last_2_bits_of_address == 2'b00)? 4'b0011 : 
                          (last_2_bits_of_address == 2'b01)? 4'b0011 : 
                          (last_2_bits_of_address == 2'b10)? 4'b1100 : 4'b1100;


assign data_sram_addr  = es_alu_result; 
//assign data_sram_wdata = es_rt_value;
assign data_sram_wdata = (es_inst_sb)? {4{es_rt_value[ 7:0]}} :
                         (es_inst_sh)? {2{es_rt_value[15:0]}} : es_rt_value;



//8条特殊指令的控制信号在这里生成
assign es_hi_we    = es_inst_mult | es_inst_multu | es_inst_mthi | div_finished;
assign es_lo_we    = es_inst_mult | es_inst_multu | es_inst_mtlo | div_finished;
assign es_div_en   = es_inst_div  | es_inst_divu;



assign wdata_hi = (es_inst_mthi) ? es_rs_value :
                  (es_inst_mult | es_inst_multu) ? mult_result_hi : 
                  (es_inst_div  | es_inst_divu)  ? div_result_hi : hi; // 这里缺省条件应该不是组合环？因为hi为寄存器，用的是非阻塞赋值 

assign wdata_lo = (es_inst_mtlo) ? es_rs_value :
                  (es_inst_mult | es_inst_multu) ? mult_result_lo : 
                  (es_inst_div  | es_inst_divu)  ? div_result_lo : lo; // 这里缺省条件应该不是组合环？因为hi为寄存器，用的是非阻塞赋值 

assign es_final_result = (es_inst_mfhi)? hi :
                         (es_inst_mflo)? lo : es_alu_result;


assign gr_wen = (!gr_we)? 4'b0000 :                 // 如果不是写寄存器的指令，直接全0
                (inst_lwl) ? gr_wen_lwl :           // 如果是lwl，就按lwl的来
                (inst_lwr) ? gr_wen_lwr : 4'b1111;  // 如果是lwr，就按lwr的来
                                                    // 上述情况都不是则说明是正常的写法，全1

assign gr_wen_lwr = (last_2_bits_of_address == 2'b00)? 4'b1111 : 
                    (last_2_bits_of_address == 2'b01)? 4'b0111 :
                    (last_2_bits_of_address == 2'b10)? 4'b0011 : 4'b0001;

assign gr_wen_lwl = (last_2_bits_of_address == 2'b00)? 4'b1000 : 
                    (last_2_bits_of_address == 2'b01)? 4'b1100 :
                    (last_2_bits_of_address == 2'b10)? 4'b1110 : 4'b1111;



mutiplier m1(
    .mult1(es_alu_src1),
    .mult2(es_alu_src2),
    .has_sign(es_inst_mult),
    .mult_result_hi(mult_result_hi),
    .mult_result_lo(mult_result_lo)
    );

divide_controller dc1(
    .clk(clk),
    .reset(reset),
    .div_en(es_div_en),
    .use_sign(es_inst_div),
    .dividend(es_alu_src1),
    .divisor(es_alu_src2),
    .div_result_hi(div_result_hi),
    .div_result_lo(div_result_lo),
    .div_finished(div_finished)
    );


always @(posedge clk) 
begin
    if (es_hi_we) 
        hi<= wdata_hi;
end

always @(posedge clk) 
begin
    if (es_lo_we) 
        lo<= wdata_lo;
end

endmodule
