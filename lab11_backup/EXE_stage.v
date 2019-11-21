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
    //output        data_sram_en   ,
    //output [ 3:0] data_sram_wen  ,
    output        data_sram_req,
    output        data_sram_wr,
    output [ 1:0] data_sram_size,
    output [ 3:0] data_sram_wstrb,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,

    input         data_sram_addr_ok,

    output [40:0]    back_to_id_stage_bus_from_exe,  // 用于阻塞&前递机制的反馈信号
    //output [36:0]   exe_forwarding
    input  [`EXECEPTION_BUS_WD - 1:0] exception_bus,
    input         mem_has_exception    
);

reg         es_valid      ;
wire        es_ready_go   ;

wire		data_sram_wen_b;			//prj7 added
wire [1:0]	es_addr_low_2     ;			//prj7 added

reg  [`DS_TO_ES_BUS_WD -1:0] ds_to_es_bus_r;
wire        es_s_ext      ;
wire        es_mem_left   ;
wire        es_mem_right  ;
wire        es_mem_w      ;
wire        es_mem_h      ;
wire        es_mem_b      ;
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
wire        es_inst_mfc0  ;     // prj8 added
wire        es_inst_mtc0  ;     // prj8 added
wire        es_inst_eret  ;     // prj8 added

wire [31:0] es_final_result;    // prj6 added

wire [ 4:0] es_dest       ;
wire [15:0] es_imm        ;
wire [31:0] es_rs_value   ;
wire [31:0] es_rt_value   ;
wire [31:0] es_pc         ;

//wire [ 6:0] es_exception  ;     // prj9 added
wire        exception_adel_if;  //prj9 added
wire        exception_adel_exe; //prj9 added
wire        exception_syscall;  //prj9 added
wire        exception_break;    //prj9 added
wire        exception_ades;     //prj9 added
wire        exception_overflow; //prj9 added
wire        exception_rsv;      //prj9 added
wire        exception_int;      //prj9 added

//wire        exception_adel_final;   // prj9 added
wire        exception_ad_w;       // prj9 added
wire        exception_ad_h;       // prj9 added

wire        es_in_slot    ;     // prj8 added

wire        es_may_overflow;    // prj9 added

assign {es_may_overflow,                //160:160
        es_in_slot     ,                //159:159
        exception_int,                  //158:158
        exception_adel_if,              //157:157
        exception_rsv,                  //156:156
        exception_syscall,              //155:155
        exception_break,                //154:154
        es_s_ext       ,                //153:153
        es_inst_eret   ,                //152:152
        es_inst_mfc0   ,                //151:151
        es_inst_mtc0   ,                //150:150
        es_mem_left    ,                //149:149
        es_mem_right   ,                //148:148
        es_mem_w       ,                //147:147
        es_mem_h       ,                //146:146
        es_mem_b       ,                //145:145
        es_alu_op      ,                //144:133
        es_load_op     ,                //132:132
        es_src1_is_sa  ,                //131:131
        es_src1_is_pc  ,                //130:130
        es_src2_is_imm_symbol_extend,   //129:129
        es_src2_is_imm_zero_extend  ,   //128:128
        es_src2_is_8   ,                //127:127
        es_gr_we       ,                //126:126
        es_mem_we      ,                //125:125
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

wire        es_flush;           // prj8 added
wire [31:0] es_ex_pc;           // prj8 added

wire        overflow_add;       // prj9 added
wire        overflow_sub;       // prj9 added

wire        es_has_int;         // prj9 added
wire        es_has_exception;   // prj9 added

wire        data_sram_size_left;  //prj11 added
wire        data_sram_size_right; //prj11 added

assign {es_flush, es_ex_pc, es_has_int} = exception_bus;


assign es_res_from_mem = es_load_op;
assign es_to_ms_bus = {es_in_slot     ,         //120:120
                       exception_int,           //119:119
                       exception_adel_if,       //118:118
                       exception_adel_exe,      //117:117
                       exception_rsv,           //116:116
                       exception_overflow,      //115:115               
                       exception_syscall,       //114:114               
                       exception_break,         //113:113
                       exception_ades,          //112:112                 
                       es_s_ext       ,         //111:111 //合成给mem阶段的总线信号
                       es_inst_eret   ,         //110:110
                       es_inst_mfc0   ,         //109:109  
                       es_inst_mtc0   ,         //108:108
                       es_mem_left    ,         //107:107
                       es_mem_right   ,         //106:106
                       es_mem_w       ,         //105:105
                       es_mem_h       ,         //104:104
                       es_mem_b       ,         //103:103
                       es_res_from_mem,         //102:102
                       es_gr_we       ,         //101:101
                       es_dest        ,         //100:96
                       es_final_result,         //95:64
                       es_rt_value    ,         //63:32
                       es_pc                    //31:0
                      };



assign back_to_id_stage_bus_from_exe = {es_inst_mfc0,       //40
                                        es_load_op,         //39
                                        es_final_result,    //38:7
                                        es_valid,           //6
                                        es_gr_we,           //5
                                        es_dest             //4:0
                                       };
/*
assign exe_forwarding = {es_alu_result,     //36:5
                         es_dest            //4:0
                        };
*/

//assign es_ready_go    = 1'b1;
//assign es_ready_go = (es_flush)? 1 : 
//                     (!es_div_en)? 1 : div_finished;
assign es_ready_go = (es_flush)? 1 : 
                     (!es_div_en)? data_sram_addr_ok : div_finished & data_sram_addr_ok;



assign es_allowin     = !es_valid || es_ready_go && ms_allowin;
assign es_to_ms_valid =  es_valid && es_ready_go;
/*
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
*/

always @(posedge clk) begin
    if (reset) begin
        es_valid <= 1'b0;
    end
    else if (es_flush) begin
        es_valid <= 1'b0;
    end
    else if (es_allowin) begin
        es_valid <= ds_to_es_valid;
    end
end


always @(posedge clk) begin
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
assign es_addr_low_2 = es_alu_result[1:0];

//assign data_sram_en    = (es_has_exception | mem_has_exception | es_flush)? 1'b0 : 1'b1;
assign data_sram_req   = (es_has_exception | mem_has_exception | es_flush)? 1'b0 : ms_allowin;
assign data_sram_wen_b = es_mem_we&&es_valid ? 1'b1 : 1'b0;
assign data_sram_wen   =(es_has_exception)? 4'b0 : //如果本级已经查出例外，不要写mem

                        (mem_has_exception || es_flush)? 4'b0 : //如果下家发生了例外，这里写使能得打住

                         es_mem_left  ? (es_addr_low_2 == 2'b00 ? {3'b0, data_sram_wen_b} :
                                         es_addr_low_2 == 2'b01 ? {2'b0, {2{data_sram_wen_b}}} :
                                         es_addr_low_2 == 2'b10 ? {1'b0, {3{data_sram_wen_b}}} :
                                                                  {4{data_sram_wen_b}}
                                        ) :
                         es_mem_right ? (es_addr_low_2 == 2'b00 ? {4{data_sram_wen_b}} :
                                         es_addr_low_2 == 2'b01 ? {{3{data_sram_wen_b}}, 1'b0} :
                                         es_addr_low_2 == 2'b10 ? {{2{data_sram_wen_b}}, 2'b0} :
                                                                  {data_sram_wen_b, 3'b0}
                                        ) :
                         es_mem_b     ? (es_addr_low_2 == 2'b00 ? {3'b0, data_sram_wen_b} :
                                         es_addr_low_2 == 2'b01 ? {2'b0, data_sram_wen_b, 1'b0} :
                                         es_addr_low_2 == 2'b10 ? {1'b0, data_sram_wen_b, 2'b0} :
                                                                  {data_sram_wen_b, 3'b0}
                                        ) :
                         es_mem_h     ? (es_addr_low_2 == 2'b00 ? {2'b0, {2{data_sram_wen_b}}} :
                                                                  {{2{data_sram_wen_b}}, 2'b0}
                                        ) :
                         es_mem_w     ? {4{data_sram_wen_b}} :
                                        4'b0;
assign data_sram_addr  = {es_alu_result[31:2], 2'b00};
assign data_sram_wdata = es_mem_left  ? (es_addr_low_2 == 2'b00 ? {24'b0, es_rt_value[31:24]} :
                                         es_addr_low_2 == 2'b01 ? {16'b0, es_rt_value[31:16]} :
                                         es_addr_low_2 == 2'b10 ? { 8'b0, es_rt_value[31: 8]} :
                                                                  es_rt_value
                                        ) :
                         es_mem_right ? (es_addr_low_2 == 2'b00 ? es_rt_value :
                                         es_addr_low_2 == 2'b01 ? {es_rt_value[23: 0],  8'b0} :
                                         es_addr_low_2 == 2'b10 ? {es_rt_value[15: 0], 16'b0} :
                                                                  {es_rt_value[ 7: 0], 24'b0}
                                        ) :
                         es_mem_b     ? {4{es_rt_value[ 7:0]}} :
                         es_mem_h     ? {2{es_rt_value[15:0]}} :
                                        es_rt_value;

//8条特殊指令的控制信号在这里生成
assign es_hi_we    = (es_has_exception || mem_has_exception || es_flush)? 0 : 
                      es_inst_mult | es_inst_multu | es_inst_mthi | div_finished;
assign es_lo_we    = (es_has_exception || mem_has_exception || es_flush)? 0 :
                      es_inst_mult | es_inst_multu | es_inst_mtlo | div_finished;
assign es_div_en   = es_inst_div  | es_inst_divu;



assign wdata_hi = (es_inst_mthi) ? es_rs_value :
                  (es_inst_mult | es_inst_multu) ? mult_result_hi : 
                  (es_inst_div  | es_inst_divu)  ? div_result_hi : hi; // 这里缺省条件应该不是组合环？因为hi为寄存器，用的是非阻塞赋值 

assign wdata_lo = (es_inst_mtlo) ? es_rs_value :
                  (es_inst_mult | es_inst_multu) ? mult_result_lo : 
                  (es_inst_div  | es_inst_divu)  ? div_result_lo : lo; // 这里缺省条件应该不是组合环？因为hi为寄存器，用的是非阻塞赋值 

assign es_final_result = (es_inst_mfhi)? hi :
                         (es_inst_mflo)? lo : 
                         (es_inst_mfc0 || es_inst_mtc0)?{16'b0, es_imm}: es_alu_result;


//例外检测
//assign exception_adel_final = (exception_adel)? 1 :                                         // 如果本条指令已经在IF级产生了adel例外，那么不用管EXE了，反正会报错
//                              (es_mem_w && es_valid && es_load_op)? exception_ad_w :        // 否则再看本条指令是不是 lw/sw + 是不是valid + 是不是 load
//                              (es_mem_h && es_valid && es_load_op)? exception_ad_h : 0;     // 否则再看本条指令是不是 lh(u)/sh + 是不是valid + 是不是 load

assign exception_adel_exe = (es_mem_w && es_valid && es_load_op)? exception_ad_w :        // 否则再看本条指令是不是 lw/sw + 是不是valid + 是不是 load
                            (es_mem_h && es_valid && es_load_op)? exception_ad_h : 0;     // 否则再看本条指令是不是 lh(u)/sh + 是不是valid + 是不是 load;

assign exception_ades = (es_mem_w && es_valid && (~es_load_op)) ? exception_ad_w :
                        (es_mem_h && es_valid && (~es_load_op)) ? exception_ad_h : 0; // 逻辑类似于上面adel的判断，只不过这里load_op得取反，从w/h型指令中筛出store型


assign exception_ad_w = (es_addr_low_2 == 2'b00)?   0 : 1;
assign exception_ad_h = (es_addr_low_2[0] == 1'b0)? 0 : 1;

assign exception_overflow = (es_alu_op[0] && es_may_overflow) ? overflow_add :
                            (es_alu_op[1] && es_may_overflow) ? overflow_sub : 0;

assign overflow_add = ((es_alu_src1[31] == es_alu_src2[31]) && (es_alu_src2[31] != es_alu_result[31])) ? 1 : 0;
assign overflow_sub = ((es_alu_src1[31] != es_alu_src2[31]) && (es_alu_src2[31] == es_alu_result[31])) ? 1 : 0;

assign es_has_exception = (exception_int | exception_adel_if | exception_adel_exe | exception_rsv | exception_overflow | exception_syscall | exception_break | exception_ades);

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


assign data_sram_size = (mem_b)? 0 :  //  lb/lbu/sb  
                        (mem_h)? 1 :  //  lh/lhu/sh
                        (mem_w)? 2 :  //  lw/sw
                        (mem_left)?   data_sram_size_left   :     //  lwl/swl
                        (mem_right)?  data_sram_size_right  : 0;  //  lwr/swr

assign data_sram_size_left  = (data_sram_addr[1:0] == 2'b00)? 0 :
                              (data_sram_addr[1:0] == 2'b01)? 1 : 2; // 最低2位为2或3的时候size都是2

assign data_sram_size_right = (data_sram_addr[1:0] == 2'b10)? 1 :
                              (data_sram_addr[1:0] == 2'b11)? 0 : 2; // 最低2位为0或1的时候size都是2

endmodule