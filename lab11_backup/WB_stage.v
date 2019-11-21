`include "mycpu.h"

module wb_stage(
    input  [ 5:0]                   ext_int_in    ,
    input                           clk           ,
    input                           reset         ,
    //allowin
    output                          ws_allowin    ,
    //from ms
    input                           ms_to_ws_valid,
    input  [`MS_TO_WS_BUS_WD -1:0]  ms_to_ws_bus  ,
    //to rf: for write back
    output [`WS_TO_RF_BUS_WD -1:0]  ws_to_rf_bus  ,
    //trace debug interface
    output [36:0]                   back_to_mem_stage_bus_from_wb,
    output [31:0]                   debug_wb_pc     ,
    output [ 3:0]                   debug_wb_rf_wen ,
    output [ 4:0]                   debug_wb_rf_wnum,
    output [31:0]                   debug_wb_rf_wdata,
    output [`EXECEPTION_BUS_WD-1:0] exception_bus 
);

reg         ws_valid;
wire        ws_ready_go;

reg [ 4:0]  ws_dest_r;
reg [31:0]  ws_final_result_r;

reg [`MS_TO_WS_BUS_WD -1:0] ms_to_ws_bus_r;
wire        ws_gr_we;
wire [ 4:0] ws_dest;
wire [31:0] ws_final_result_from_mem;
wire [31:0] ws_final_result;
wire [31:0] ws_pc;

wire        ws_inst_mfc0; // prj8 added
wire        ws_inst_mtc0; // prj8 added
wire        ws_inst_eret; // prj8 added

wire [7:0]  ws_cp0_addr;  // prj8 added
wire [31:0] ws_cp0_wdata; // prj8 added
wire [31:0] ws_cp0_rdata; // prj8 added

wire [ 7:0] ws_exception;       // prj9 added


/*
wire        exception_adel_if;  // prj9 added
wire        exception_adel_exe; // prj9 added
wire        exception_syscall;  // prj9 added
wire        exception_break;    // prj9 added
wire        exception_ades;     // prj9 added
wire        exception_overflow; // prj9 added
wire        exception_rsv;      // prj9 added
wire        exception_int;      // prj9 added
*/

wire        ws_in_slot;   // prj8 added
wire        flush;        // prj8 added
//reg         flush;        // prj8 added
wire [31:0] new_pc;       // prj8 added
wire [4:0]  wb_exccode;   // prj8 added
wire        mtc0_we;      // prj8 added
wire        wb_ex;        // prj9 added
wire        wb_has_int;   // prj9 added

wire [31:0] bad_vaddr_from_mem; //prj9 added
wire [31:0] wb_BadVaddr;

assign exception_bus = {flush,
                        new_pc,
                        wb_has_int
                        };
/*
assign ws_exception = {exception_int,
                       exception_adel_if,
                       exception_adel_exe,
                       exception_rsv,
                       exception_overflow,   
                       exception_syscall,
                       exception_break,
                       exception_ades
                      };
*/

assign flush = (!ws_valid)? 0 :
               (ws_exception != 7'b0)? 1 : 
               (ws_inst_eret)? 1 : 0;

assign new_pc = (ws_exception != 7'b0)? 32'hbfc00380 : ws_cp0_rdata;

/*
assign {bad_vaddr_from_mem,         //121:90
        ws_in_slot     ,            //89:89
        exception_int,              //88:88
        exception_adel_if,          //87:87
        exception_adel_exe,         //86:86
        exception_rsv,              //85:85
        exception_overflow,         //84:84
        exception_syscall,          //83:83
        exception_break,            //82:82
        exception_ades,             //81:81
        ws_cp0_addr    ,            //80:73
        ws_inst_eret   ,            //72:72
        ws_inst_mfc0   ,            //71:71
        ws_inst_mtc0   ,            //70:70
        ws_gr_we       ,            //69:69
        ws_dest        ,            //68:64
        ws_final_result_from_mem,   //63:32
        ws_pc                       //31:0
       } = ms_to_ws_bus_r;
*/


assign {//bad_vaddr_from_mem,         //121:90
        ws_in_slot     ,            //89:89
        ws_exception   ,            //88:81
        ws_cp0_addr    ,            //80:73
        ws_inst_eret   ,            //72:72
        ws_inst_mfc0   ,            //71:71
        ws_inst_mtc0   ,            //70:70
        ws_gr_we       ,            //69:69
        ws_dest        ,            //68:64
        ws_final_result_from_mem,   //63:32
        ws_pc                       //31:0
       } = ms_to_ws_bus_r;


assign ws_final_result = (ws_inst_mfc0)? ws_cp0_rdata : ws_final_result_from_mem;


wire        rf_we;
wire [4 :0] rf_waddr;
wire [31:0] rf_wdata;
assign ws_to_rf_bus = {rf_we   ,  //37:37
                       rf_waddr,  //36:32
                       rf_wdata   //31:0
                      };//给寄存器堆的总线信号

assign ws_ready_go = 1'b1;
assign ws_allowin  = !ws_valid || ws_ready_go;
/*
always @(posedge clk) begin
    if (reset) begin
        ws_valid <= 1'b0;
    end
    else if (ws_allowin) begin
        ws_valid <= ms_to_ws_valid;
    end

    if (ms_to_ws_valid && ws_allowin) begin
        ms_to_ws_bus_r <= ms_to_ws_bus;
    end
end
*/
always @(posedge clk) begin
    if (reset) begin
        ws_valid <= 1'b0;
    end
    else if (flush) begin
        ws_valid <= 1'b0;
    end

    else if (ws_allowin) begin
        ws_valid <= ms_to_ws_valid;
    end
end

always @(posedge clk) begin
    if (ms_to_ws_valid && ws_allowin) begin
        ms_to_ws_bus_r <= ms_to_ws_bus;
    end
end


always @(posedge clk) begin
    if (reset) begin
        ws_dest_r <= 5'b0;
        ws_final_result_r <= 32'b0;
    end
    else if (ws_valid) begin
        ws_dest_r <= (ws_dest & {5{ws_gr_we}});
        ws_final_result_r <= ws_final_result;
    end
end

assign back_to_mem_stage_bus_from_wb = (ws_valid) ? {(ws_dest & {5{ws_gr_we}}), ws_final_result} :
                                                    {ws_dest_r, ws_final_result_r} ;

assign rf_we    = (flush)? 0 : ws_gr_we && ws_valid; // 如果本级已经查出了例外，不要写寄存器
assign rf_waddr = ws_dest;
assign rf_wdata = ws_final_result;

// debug info generate
assign debug_wb_pc       = ws_pc;
assign debug_wb_rf_wen   = {4{rf_we}};
assign debug_wb_rf_wnum  = ws_dest;
assign debug_wb_rf_wdata = ws_final_result;


// cp0 signal
/*
exception:
| interrput | AdEL | reserved | integer overflow | syscall | break | AdES |
*/
//assign wb_exccode = (ws_exception)? 5'b01000 : 5'b00000; // 0x08 => syscall
assign wb_exccode = (ws_exception[7])? 5'b00000 :               //0x00 => interrupt
                    (ws_exception[6])? 5'b00100 :               //0x04 => AdEL(from if)
                    (ws_exception[5])? 5'b01010 :               //0x0a => reserved instruction
                    (ws_exception[4])? 5'b01100 :               //0x0c => integer overflow
                    (ws_exception[3])? 5'b01000 :               //0x08 => syscall
                    (ws_exception[2])? 5'b01001 :               //0x09 => break
                    (ws_exception[1])? 5'b00100 :               //0x04 => AdEL(from exe)
                    (ws_exception[0])? 5'b00101 : 5'b00000;     //0x05 => AdES

assign mtc0_we     = ws_valid && ws_inst_mtc0;//&& ws_exception; // 暂时先不考虑WB阶段的例外试试
assign wb_ex       = (!ws_valid)? 0 :               // 如果失效的话，例外信号也失效了
                     (ws_exception == 7'b0)? 0 : 1; // 只要有1位出现例外错误就触发wb_ex
assign wb_BadVaddr = (ws_exception[6])? ws_pc : ws_final_result_from_mem; // bad_vaddr的俩个来源。优先级高点的是if级产生的badvaddr，其次再考虑exe级产生的badvaddr

assign ws_cp0_wdata = ws_final_result;

cp0 c0(
    .clk(clk),
    .rst(reset),
    .mtc0_we(mtc0_we),
    .cp0_wdata(ws_cp0_wdata),
    .cp0_addr(ws_cp0_addr),
    .eret_flush(ws_inst_eret),
    .wb_ex(wb_ex),
    .wb_exccode(wb_exccode),
    .wb_bd(ws_in_slot),
    .wb_pc(ws_pc),
    .ext_int_in(ext_int_in),  // 暂时用不到
    .wb_BadVaddr(wb_BadVaddr),
    .cp0_rdata(ws_cp0_rdata),
    .has_int(wb_has_int)
    );


endmodule