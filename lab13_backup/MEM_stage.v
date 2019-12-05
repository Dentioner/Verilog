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
    input                          data_sram_data_ok,

    input  [36:0]    back_to_mem_stage_bus_from_wb,
    output [40:0]    back_to_id_stage_bus_from_mem,
    output [`MS_TO_ES_BUS_WD -1:0] ms_to_es_bus,

    //output [36:0]   mem_forwarding
    input  [`EXECEPTION_BUS_WD - 1:0] exception_bus,
    output           mem_has_exception // ���ź����ڸ�EXE�������Ƿ���MEM������������HI/LO/Storeָ������˴����ֵ

);

reg         ms_valid;
wire        ms_ready_go;

wire [4:0]  ws_dest_r;
wire [31:0] ws_final_result_r;
wire [31:0] rt_final_result;

reg [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus_r;
wire        ms_s_ext      ;     //prj7 added
wire        ms_mem_left   ;     //prj7 added
wire        ms_mem_right  ;     //prj7 added
wire        ms_mem_w      ;     //prj7 added
wire        ms_mem_h      ;     //prj7 added
wire        ms_mem_b      ;     //prj7 added
wire [ 1:0] ms_addr_low_2 ;     //prj7 added
wire        ms_res_from_mem;
wire        ms_gr_we;
wire [ 4:0] ms_dest;
wire [31:0] ms_alu_result;
wire [31:0] ms_rt_value;
wire [31:0] ms_pc;

wire        ms_inst_mfc0;
wire        ms_inst_mtc0;
wire        ms_inst_eret;
wire [7:0]  ms_cp0_addr;

wire        ms_flush;
wire [31:0] ms_ex_pc;

wire        ms_inst_tlbp;   //prj13 added
wire        ms_inst_tlbr;   //prj13 added
wire        ms_inst_tlbwi;  //prj13 added



wire        ms_in_slot;     // prj8 added
//wire [ 6:0] ms_exception;   // prj9 added
wire        exception_adel_if;      //prj9 added
wire        exception_adel_exe;     //prj9 added
wire        exception_syscall;      //prj9 added
wire        exception_break;        //prj9 added
wire        exception_ades;         //prj9 added
wire        exception_overflow;     //prj9 added
wire        exception_rsv;          //prj9 added
wire        exception_int;          //prj9 added

wire        ms_has_int;             //prj9 added




//wire [31:0] bad_vaddr;              //prj9 added

//prj11 added
//rdata buffer
reg         buf_rdata_valid;
reg  [31:0] buf_rdata;
wire [31:0] true_rdata;

wire        ms_after_tlb;

assign {ms_flush, ms_ex_pc, ms_has_int} = exception_bus;

assign {ms_after_tlb,           //124:124
        ms_in_slot     ,        //123:123
        exception_int,          //122:122
        exception_adel_if,      //121:121
        exception_adel_exe,     //120:120
        exception_rsv,          //119:119
        exception_overflow,     //118:118
        exception_syscall,      //117:117               
        exception_break,        //116:116
        exception_ades,         //115:115               
        ms_s_ext       ,        //114:114 //�ϳɸ�mem�׶ε������ź�
        ms_inst_tlbp   ,        //113:113            
        ms_inst_tlbr   ,        //112:112          
        ms_inst_tlbwi  ,        //111:111            
        ms_inst_eret   ,        //110:110
        ms_inst_mfc0   ,        //109:109
        ms_inst_mtc0   ,        //108:108
        ms_mem_left    ,        //107:107
        ms_mem_right   ,        //106:106
        ms_mem_w       ,        //105:105
        ms_mem_h       ,        //104:104
        ms_mem_b       ,        //103:103
        ms_res_from_mem,        //102:102
        ms_gr_we       ,        //101:101
        ms_dest        ,        //100:96
        ms_alu_result  ,        //95:64
        ms_rt_value    ,        //63:32
        ms_pc                   //31:0
       } = es_to_ms_bus_r; //����

assign rt_final_result = (ms_dest == ws_dest_r) ? ws_final_result_r :
                                                  ms_rt_value ;

wire [31:0] mem_result;
wire [31:0] ms_final_result;

assign ms_to_ws_bus = {ms_after_tlb   ,         //93:93
                       ms_in_slot     ,         //92:92
                       exception_int,           //91:91
                       exception_adel_if,       //90:90
                       exception_rsv,           //89:89
                       exception_overflow,      //88:88
                       exception_syscall,       //87:87
                       exception_break,         //86:86
                       exception_adel_exe,      //85:85
                       exception_ades,          //84:84
                       ms_cp0_addr    ,         //83:76
                       ms_inst_tlbp   ,         //75:75         
                       ms_inst_tlbr   ,         //74:74       
                       ms_inst_tlbwi  ,         //73:73        
                       ms_inst_eret   ,         //72:72
                       ms_inst_mfc0   ,         //71:71
                       ms_inst_mtc0   ,         //70:70
                       ms_gr_we       ,         //69:69
                       ms_dest        ,         //68:64
                       ms_final_result,         //63:32
                       ms_pc                    //31:0
                      };
assign ms_addr_low_2 = ms_alu_result[1:0];

//assign ms_ready_go    = 1'b1;
assign ms_ready_go    = (ms_res_from_mem)? data_sram_data_ok : 1'b1; //loadָ����ȵ�data_ok֮����ܼ�������store��ʱ����

assign ms_allowin     = !ms_valid || ms_ready_go && ws_allowin;
assign ms_to_ws_valid = ms_valid && ms_ready_go;
/*
always @(posedge clk) begin
    if (reset) begin
        ms_valid <= 1'b0;
    end
    else if (ms_allowin) begin
        ms_valid <= es_to_ms_valid;
    end

    if (es_to_ms_valid && ms_allowin) begin
        es_to_ms_bus_r  <= es_to_ms_bus; 
    end
end
*/
always @(posedge clk) begin
    if (reset) begin
        ms_valid <= 1'b0;
    end
    else if(ms_flush) begin
        ms_valid <= 1'b0;
    end
    else if (ms_allowin) begin
        ms_valid <= es_to_ms_valid;
    end
end

always @(posedge clk) begin
    if (es_to_ms_valid && ms_allowin) begin
        es_to_ms_bus_r  <= es_to_ms_bus; 
    end
end



//assign mem_result = data_sram_rdata;

assign mem_result = ms_mem_left  ? (ms_addr_low_2 == 2'b00 ? {true_rdata[ 7: 0], rt_final_result[23: 0]} :
                                    ms_addr_low_2 == 2'b01 ? {true_rdata[15: 0], rt_final_result[15: 0]} :
                                    ms_addr_low_2 == 2'b10 ? {true_rdata[23: 0], rt_final_result[ 7: 0]} :
                                                             true_rdata
                                   ) :
                    ms_mem_right ? (ms_addr_low_2 == 2'b11 ? {rt_final_result[31: 8], true_rdata[31:24]} :
                                    ms_addr_low_2 == 2'b10 ? {rt_final_result[31:16], true_rdata[31:16]} :
                                    ms_addr_low_2 == 2'b01 ? {rt_final_result[31:24], true_rdata[31: 8]} :
                                                             true_rdata
                                   ) :
                    ms_mem_b     ? (ms_addr_low_2 == 2'b00 ? {{24{ms_s_ext&true_rdata[ 7]}}, true_rdata[ 7: 0]} :
                                    ms_addr_low_2 == 2'b01 ? {{24{ms_s_ext&true_rdata[15]}}, true_rdata[15: 8]} :
                                    ms_addr_low_2 == 2'b10 ? {{24{ms_s_ext&true_rdata[23]}}, true_rdata[23:16]} :
                                                             {{24{ms_s_ext&true_rdata[31]}}, true_rdata[31:24]}
                                   ) :
                    ms_mem_h     ? (ms_addr_low_2 == 2'b00 ? {{16{ms_s_ext&true_rdata[15]}}, true_rdata[15: 0]} :
                                                             {{16{ms_s_ext&true_rdata[31]}}, true_rdata[31:16]}
                                   ) :
                                   true_rdata;

assign ms_final_result = (ms_res_from_mem && ~exception_adel_exe) ? mem_result  : 
                         (ms_inst_mtc0)    ? ms_rt_value : ms_alu_result;


assign back_to_id_stage_bus_from_mem = {ms_inst_mfc0,       //40
                                        ms_final_result,    //39:8
                                        ms_valid,           //7
                                        ms_to_ws_valid,     //6
                                        ms_gr_we,           //5
                                        ms_dest             //4:0
                                        };
assign {ws_dest_r, ws_final_result_r} = back_to_mem_stage_bus_from_wb;

/*
assign mem_forwarding = {ms_final_result,   //36:5
                         ms_dest            //4:0
                        };
*/

assign ms_cp0_addr = ms_alu_result[7:0];

//assign mem_has_exception = (ms_exception != 7'b0) & ms_valid; //prj9 added
assign mem_has_exception = (exception_int | exception_adel_if | exception_adel_exe | exception_rsv | exception_overflow | exception_syscall | exception_break | exception_ades | ms_inst_eret) & ms_valid; // prj9 added

//assign bad_vaddr = ms_alu_result;



//rdata �ױ䴦��
//assign true_rdata = buf_rdata_valid ? buf_rdata : data_sram_rdata;
assign true_rdata = data_sram_data_ok ? data_sram_rdata : buf_rdata;   
always @(posedge clk)
begin
    if(reset)
    begin
        buf_rdata_valid <= 1'b0;
    end
    else if(ws_allowin && ms_to_ws_valid)
    begin
        buf_rdata_valid <= 1'b0;
    end
    else if(!buf_rdata_valid)
    begin
        buf_rdata_valid <= 1'b1;
    end
    
end


always @(posedge clk) 
begin
  if (reset) 
  begin
    // reset
    buf_rdata <= 32'b0;
  end
  else if (data_sram_data_ok) 
  begin
    buf_rdata <= data_sram_rdata;
  end
end

assign ms_to_es_bus = {
                        ms_valid,     //9:9
                        ms_inst_mtc0, //8:8
                        ms_cp0_addr   //7:0
};

endmodule 