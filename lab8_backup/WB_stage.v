`include "mycpu.h"

module wb_stage(
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

wire        ws_exception; // prj8 added
wire        ws_in_slot;   // prj8 added
wire        flush;        // prj8 added
//reg         flush;        // prj8 added
wire [31:0] new_pc;       // prj8 added
wire [4:0]  wb_exccode;   // prj8 added
wire        mtc0_we;      // prj8 added

assign exception_bus = {flush,
                        new_pc
                        };

assign flush = (!ws_valid)? 0 :
               (ws_exception)? 1 : 
               (ws_inst_eret)? 1 : 0;

assign new_pc = (ws_exception)? 32'hbfc00380 : ws_cp0_rdata;

assign {ws_in_slot     ,            //82:82
        ws_exception   ,            //81:81
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

assign rf_we    = ws_gr_we && ws_valid;
assign rf_waddr = ws_dest;
assign rf_wdata = ws_final_result;

// debug info generate
assign debug_wb_pc       = ws_pc;
assign debug_wb_rf_wen   = {4{rf_we}};
assign debug_wb_rf_wnum  = ws_dest;
assign debug_wb_rf_wdata = ws_final_result;


// cp0 signal

assign wb_exccode = (ws_exception)? 5'b01000 : 5'b00000; // 0x08 => syscall
assign mtc0_we    = ws_valid && ws_inst_mtc0;//&& ws_exception; // 暂时先不考虑WB阶段的例外试试

assign ws_cp0_wdata = ws_final_result;

cp0 c0(
    .clk(clk),
    .rst(reset),
    .mtc0_we(mtc0_we),
    .cp0_wdata(ws_cp0_wdata),
    .cp0_addr(ws_cp0_addr),
    .eret_flush(ws_inst_eret),
    .wb_ex(ws_exception),
    .wb_exccode(wb_exccode),
    .wb_bd(ws_in_slot),
    .wb_pc(ws_pc),
    .ext_int_in(6'b0),  // 暂时用不到
    .cp0_rdata(ws_cp0_rdata)
    );


endmodule