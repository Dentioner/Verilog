module mycpu_top(
    input [ 5:0] int    ,   //high active

    input aclk   ,   
    input aresetn,

    output [ 3:0] arid,   
    output [31:0] araddr ,
    output [ 7:0] arlen  ,
    output [ 2:0] arsize ,
    output [ 1:0] arburst,
    output [ 1:0] arlock ,
    output [ 3:0] arcache,
    output [ 2:0] arprot ,
    output        arvalid,
    input         arready,
           
    input  [ 3:0] rid    ,
    input  [31:0] rdata  ,
    input  [ 1:0] rresp  ,
    input         rlast  ,
    input         rvalid ,
    output        rready ,
           
    output [ 3:0] awid   ,
    output [31:0] awaddr ,
    output [ 7:0] awlen  ,
    output [ 2:0] awsize ,
    output [ 1:0] awburst,
    output [ 1:0] awlock ,
    output [ 3:0] awcache,
    output [ 2:0] awprot ,
    output        awvalid,
    input         awready,
    
    output [ 3:0] wid    ,
    output [31:0] wdata  ,
    output [ 3:0] wstrb  ,
    output        wlast  ,
    output        wvalid ,
    input         wready ,
    
    input  [ 3:0] bid    ,
    input  [ 1:0] bresp  ,
    input         bvalid ,
    output        bready ,

    //debug interface
    output [31:0] debug_wb_pc,
    output [ 3:0] debug_wb_rf_wen,
    output [ 4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata




    );

wire        inst_sram_req      ;
wire        inst_sram_wr       ;
wire [ 1:0] inst_sram_size     ;
wire [31:0] inst_sram_addr     ;
wire [ 3:0] inst_sram_wstrb    ;
wire [31:0] inst_sram_wdata    ;
wire [31:0] inst_sram_rdata    ;
wire        inst_sram_addr_ok  ;
wire        inst_sram_data_ok  ;
//data sram-like
wire        data_sram_req      ;
wire        data_sram_wr       ;
wire [ 1:0] data_sram_size     ;
wire [31:0] data_sram_addr     ;
wire [ 3:0] data_sram_wstrb    ;
wire [31:0] data_sram_wdata    ;
wire [31:0] data_sram_rdata    ;
wire        data_sram_addr_ok  ;
wire        data_sram_data_ok  ;



    mycpu_core cpu1(
    .int(int),
    .clk(aclk),
    .resetn(aresetn),

    .inst_sram_req      (inst_sram_req)     ,
    .inst_sram_wr       (inst_sram_wr)      ,
    .inst_sram_size     (inst_sram_size)    ,
    .inst_sram_wstrb    (inst_sram_wstrb)   ,
    .inst_sram_addr     (inst_sram_addr)    ,
    .inst_sram_wdata    (inst_sram_wdata)   ,
    .inst_sram_rdata    (inst_sram_rdata)   ,
    .inst_sram_addr_ok  (inst_sram_addr_ok) , 
    .inst_sram_data_ok  (inst_sram_data_ok) , 

    .data_sram_req      (data_sram_req)     ,
    .data_sram_wr       (data_sram_wr)      ,
    .data_sram_size     (data_sram_size)    ,
    .data_sram_wstrb    (data_sram_wstrb)   ,
    .data_sram_addr     (data_sram_addr)    ,
    .data_sram_wdata    (data_sram_wdata)   ,
    .data_sram_rdata    (data_sram_rdata)   ,
    .data_sram_addr_ok  (data_sram_addr_ok) , 
    .data_sram_data_ok  (data_sram_data_ok) , 

    .debug_wb_pc        (debug_wb_pc)       ,
    .debug_wb_rf_wen    (debug_wb_rf_wen)   ,
    .debug_wb_rf_wnum   (debug_wb_rf_wnum)  ,
    .debug_wb_rf_wdata  (debug_wb_rf_wdata)
        );



    cpu_axi_interface itf1(
    .clk(aclk)           ,
    .resetn(aresetn)     ,

    //inst sram-like
    .inst_req    (inst_sram_req    ),
    .inst_wr     (inst_sram_wr     ),
    .inst_size   (inst_sram_size   ),
    .inst_addr   (inst_sram_addr   ),
    .inst_wstrb  (inst_sram_wstrb  ),// 此信号Lab10好像用不到 
    .inst_wdata  (inst_sram_wdata  ),
    .inst_rdata  (inst_sram_rdata  ),
    .inst_addr_ok(inst_sram_addr_ok),
    .inst_data_ok(inst_sram_data_ok),
    
    //data sram-like
    .data_req    (data_sram_req    ),
    .data_wr     (data_sram_wr     ),
    .data_size   (data_sram_size   ),
    .data_addr   (data_sram_addr   ),
    .data_wstrb  (data_sram_wstrb  ),// 此信号Lab10好像用不到 
    .data_wdata  (data_sram_wdata  ),
    .data_rdata  (data_sram_rdata  ),
    .data_addr_ok(data_sram_addr_ok),
    .data_data_ok(data_sram_data_ok),

    //axi
    //ar
    .arid   (arid   ),
    .araddr (araddr ),
    .arlen  (arlen  ),
    .arsize (arsize ),
    .arburst(arburst),
    .arlock (arlock ),
    .arcache(arcache),
    .arprot (arprot ),
    .arvalid(arvalid), 
    .arready(arready),
    //r        
    .rid   (rid   ), // 这个信号不知道在prj10里面能干啥
    .rdata (rdata ),
    .rresp (rresp ),
    .rlast (rlast ),
    .rvalid(rvalid),
    .rready(rready),
    

    //aw       
    .awid   (awid   ),
    .awaddr (awaddr ),
    .awlen  (awlen  ),
    .awsize (awsize ),
    .awburst(awburst),
    .awlock (awlock ),
    .awcache(awcache),
    .awprot (awprot ),
    .awvalid(awvalid),
    .awready(awready),
    //w        
    .wid   (wid   ),
    .wdata (wdata ),
    .wstrb (wstrb ),
    .wlast (wlast ),
    .wvalid(wvalid),
    .wready(wready),
    //b        
    .bid   (bid   ), // 这个信号好像在prj10里面没用到
    .bresp (bresp ),
    .bvalid(bvalid),  
    .bready(bready) 





        );

endmodule


module mycpu_core(
    input  [ 5:0] int,
    input         clk,
    input         resetn,
    // inst sram interface
    //output        inst_sram_en,
    //output [ 3:0] inst_sram_wen,
    output        inst_sram_req,
    output        inst_sram_wr,
    output [ 1:0] inst_sram_size,
    output [ 3:0] inst_sram_wstrb,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    input         inst_sram_addr_ok, // prj11 added
    input         inst_sram_data_ok, // prj11 added
    // data sram interface
    //output        data_sram_en,
    //output [ 3:0] data_sram_wen,
    output        data_sram_req,
    output        data_sram_wr,
    output [ 1:0] data_sram_size,
    output [ 3:0] data_sram_wstrb,
    output [31:0] data_sram_addr,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,
    input         data_sram_addr_ok, // prj11 added
    input         data_sram_data_ok, // prj11 added
    // trace debug interface
    output [31:0] debug_wb_pc,
    output [ 3:0] debug_wb_rf_wen,
    output [ 4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);
reg         reset;
always @(posedge clk) reset <= ~resetn;
//流水级交互信号
wire         ds_allowin;
wire         es_allowin;
wire         ms_allowin;
wire         ws_allowin;
wire         fs_to_ds_valid;
wire         ds_to_es_valid;
wire         es_to_ms_valid;
wire         ms_to_ws_valid;
wire [`FS_TO_DS_BUS_WD -1:0] fs_to_ds_bus;//64  bit
wire [`DS_TO_ES_BUS_WD -1:0] ds_to_es_bus;//137 bit
wire [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus;//71  bit
wire [`MS_TO_WS_BUS_WD -1:0] ms_to_ws_bus;//70  bit
wire [`WS_TO_RF_BUS_WD -1:0] ws_to_rf_bus;//38  bit
wire [`BR_BUS_WD       -1:0] br_bus;      //32  bit

//阻塞&前递
wire [40:0] back_to_id_stage_bus_from_exe;
wire [40:0] back_to_id_stage_bus_from_mem;
wire [36:0] back_to_mem_stage_bus_from_wb;

//异常
wire [`EXECEPTION_BUS_WD -1:0] exception_bus;
wire                           mem_has_exception;

wire ds_valid; //test

// IF stage
if_stage if_stage(
    .clk            (clk            ),
    .reset          (reset          ),
    //allowin
    .ds_allowin     (ds_allowin     ),
    //brbus
    .br_bus         (br_bus         ),
    //outputs
    .fs_to_ds_valid (fs_to_ds_valid ),
    .fs_to_ds_bus   (fs_to_ds_bus   ),
    // inst sram interface
    //.inst_sram_en   (inst_sram_en   ),
    //.inst_sram_wen  (inst_sram_wen  ),
    .inst_sram_req   (inst_sram_req  ),
    .inst_sram_wr    (inst_sram_wr   ),
    .inst_sram_wstrb (inst_sram_wstrb),
    .inst_sram_size (inst_sram_size),
    .inst_sram_addr (inst_sram_addr ),
    .inst_sram_wdata(inst_sram_wdata),
    .inst_sram_rdata(inst_sram_rdata),
    .exception_bus  (exception_bus),
    .inst_sram_addr_ok(inst_sram_addr_ok),
    .inst_sram_data_ok(inst_sram_data_ok)
);
// ID stage
id_stage id_stage(
    .clk            (clk            ),
    .reset          (reset          ),
    //allowin
    .es_allowin     (es_allowin     ),
    .ds_allowin     (ds_allowin     ),
    //from fs
    .fs_to_ds_valid (fs_to_ds_valid ),
    .fs_to_ds_bus   (fs_to_ds_bus   ),
    //to es
    .ds_to_es_valid (ds_to_es_valid ),
    .ds_valid       (ds_valid       ),  // test 
    .ds_to_es_bus   (ds_to_es_bus   ),
    //to fs
    .br_bus         (br_bus         ),
    //to rf: for write back
    .ws_to_rf_bus   (ws_to_rf_bus   ),

    .back_to_id_stage_bus_from_exe(back_to_id_stage_bus_from_exe),
    .back_to_id_stage_bus_from_mem(back_to_id_stage_bus_from_mem),
    .exception_bus(exception_bus)
);
// EXE stage
exe_stage exe_stage(
    .clk            (clk            ),
    .reset          (reset          ),
    //allowin
    .ms_allowin     (ms_allowin     ),
    .es_allowin     (es_allowin     ),
    //from ds
    .ds_to_es_valid (ds_to_es_valid ),
    .ds_valid       (ds_valid       ), //test
    .ds_to_es_bus   (ds_to_es_bus   ),
    //to ms
    .es_to_ms_valid (es_to_ms_valid ),
    .es_to_ms_bus   (es_to_ms_bus   ),
    // data sram interface
    //.data_sram_en   (data_sram_en   ),
    //.data_sram_wen  (data_sram_wen  ),
    .data_sram_req  (data_sram_req),
    .data_sram_wr   (data_sram_wr),
    .data_sram_size (data_sram_size),
    .data_sram_wstrb(data_sram_wstrb),
    .data_sram_addr (data_sram_addr ),
    .data_sram_wdata(data_sram_wdata),
    .data_sram_addr_ok(data_sram_addr_ok),

    .back_to_id_stage_bus_from_exe(back_to_id_stage_bus_from_exe),
    .exception_bus(exception_bus),
    .mem_has_exception(mem_has_exception)
);
// MEM stage
mem_stage mem_stage(
    .clk            (clk            ),
    .reset          (reset          ),
    //allowin
    .ws_allowin     (ws_allowin     ),
    .ms_allowin     (ms_allowin     ),
    //from es
    .es_to_ms_valid (es_to_ms_valid ),
    .es_to_ms_bus   (es_to_ms_bus   ),
    //to ws
    .ms_to_ws_valid (ms_to_ws_valid ),
    .ms_to_ws_bus   (ms_to_ws_bus   ),
    //from data-sram
    .data_sram_rdata(data_sram_rdata),
    .data_sram_data_ok(data_sram_data_ok),

    .back_to_mem_stage_bus_from_wb(back_to_mem_stage_bus_from_wb),
    .back_to_id_stage_bus_from_mem(back_to_id_stage_bus_from_mem),
    .exception_bus(exception_bus),
    .mem_has_exception(mem_has_exception)
);
// WB stage
wb_stage wb_stage(
    .ext_int_in     (int            ),
    .clk            (clk            ),
    .reset          (reset          ),
    //allowin
    .ws_allowin     (ws_allowin     ),
    //from ms
    .ms_to_ws_valid (ms_to_ws_valid ),
    .ms_to_ws_bus   (ms_to_ws_bus   ),
    //to rf: for write back
    .ws_to_rf_bus   (ws_to_rf_bus   ),
    //trace debug interface
    .back_to_mem_stage_bus_from_wb(back_to_mem_stage_bus_from_wb),
    .debug_wb_pc      (debug_wb_pc      ),
    .debug_wb_rf_wen  (debug_wb_rf_wen  ),
    .debug_wb_rf_wnum (debug_wb_rf_wnum ),
    .debug_wb_rf_wdata(debug_wb_rf_wdata),
    .exception_bus(exception_bus)
);

endmodule