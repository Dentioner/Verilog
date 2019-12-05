`include "mycpu.h"

module if_stage#
(
    parameter TLBNUM = 16
)
(

    input                          clk            ,
    input                          reset          ,
    //allwoin
    input                          ds_allowin     ,
    //brbus
    input  [`BR_BUS_WD       -1:0] br_bus         ,
    //to ds
    output                         fs_to_ds_valid ,
    output [`FS_TO_DS_BUS_WD -1:0] fs_to_ds_bus   ,
    // inst sram interface
    //output        inst_sram_en   , 
    //output [ 3:0] inst_sram_wen  ,
   
    output  reg   inst_sram_req, // �����źŵ�valid��      
    output        inst_sram_wr,
    output [ 3:0] inst_sram_wstrb,
    output [ 1:0] inst_sram_size ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    input  [`EXECEPTION_BUS_WD - 1:0] exception_bus,
    input         inst_sram_addr_ok,
    input         inst_sram_data_ok,

    input  [`WS_CP0_BUS_WD -1:0] ws_cp0_bus, //prj13 added
    
    //tlb
    // search port 0
    output [              18:0] s0_vpn2    ,
    output                      s0_odd_page,
    output [               7:0] s0_asid    ,
    input                       s0_found   ,
    input  [$clog2(TLBNUM)-1:0] s0_index   ,
    input  [              19:0] s0_pfn     ,
    input  [               2:0] s0_c       ,
    input                       s0_d       ,
    input                       s0_v       

);

reg         fs_valid;
wire        fs_ready_go;
//reg         fs_ready_go;

wire        fs_allowin;
wire        to_fs_valid;

reg         fs_ready_go_buf;
//wire        fs_ready_go_raw;

wire [31:0] seq_pc;
wire [31:0] nextpc;

wire         br_taken;
wire [ 31:0] br_target;

// exception
wire        fs_flush;
wire [31:0] fs_ex_pc; // pc of exception
wire        fs_has_int; 

wire        exception_adel;


//nextpc buffer
reg         buf_npc_valid;
reg  [31:0] buf_npc;
wire [31:0] true_npc;

//rdata buffer
reg         buf_rdata_valid;
reg  [31:0] buf_rdata;
wire [31:0] true_rdata;

reg         pre_valid;
wire        pre_ready_go;

reg [`BR_BUS_WD-1:0]  br_bus_r;
wire        ds_valid;

//prj13
wire [31:0] ws_cp0_entryhi;
wire [31:0] true_physical_npc;
wire        ws_valid;       
wire        ws_inst_mtc0;   
wire        ws_cp0_addr;     


always @(posedge clk) 
begin
    if (reset) 
    begin
        // reset
        br_bus_r <= 0;
    end

    else if (fs_flush)
    begin
        br_bus_r <= 0;
    end

    else if (ds_valid) 
    begin
        br_bus_r <= br_bus;
    end

    
end

assign {fs_flush, fs_ex_pc, fs_has_int} = exception_bus;


//wire [`BR_BUS_WD - 2 : 0] br_target;
//assign {br_taken,br_target} = br_bus;//?????�����bug��br_bus�����32λ����Ҫ�ָ�1λ��taken��32λ��target���ֲ�������
//assign {br_taken, br_target} = br_bus_r;
assign ds_valid = br_bus[33];


assign br_taken = br_bus_r[32];
assign br_target = br_bus_r[31:0];


wire [31:0] fs_inst;//instruction��ָ��
reg  [31:0] fs_pc;
assign fs_to_ds_bus = {fs_valid,
                       true_npc,
                       exception_adel,
                       fs_inst ,
                       fs_pc   };//�����������instruction��PC

/****************************************pre-IF stage****************************************/
//assign to_fs_valid  = ~reset;//����reset��˵�����Ը�IF������
assign to_fs_valid  = ~reset && inst_sram_addr_ok;// prj11 added



assign seq_pc       = fs_pc + 3'h4; //PC+4������˳�����һ��ָ��
assign nextpc       = (fs_flush)? fs_ex_pc  :
                      (br_taken)? br_target : seq_pc; //������һ��ָ���ǲ���PC+4��

/****************************************IF stage****************************************/
//assign fs_ready_go    = 1'b1; //������ID�׶δ���������
//assign fs_ready_go    = inst_sram_data_ok; // prj11 added 

assign fs_ready_go = (inst_sram_data_ok)? 1 : fs_ready_go_buf;

always @(posedge clk) 
begin
    if (reset) begin
        // reset
        fs_ready_go_buf <= 1'b0;
    end
    else if (fs_to_ds_valid && ds_allowin) 
    begin
        fs_ready_go_buf <= 1'b0;
    end
    else if(inst_sram_data_ok)
    begin
        fs_ready_go_buf <= 1'b1;    
    end
end

assign fs_allowin     = !fs_valid || fs_ready_go && ds_allowin;//��������ϼ��źŵ�����
assign fs_to_ds_valid =  fs_valid && fs_ready_go;
always @(posedge clk) begin
    if (reset) begin
        fs_valid <= 1'b0;
    end
    else if (fs_allowin) begin
        fs_valid <= to_fs_valid;
    end

    if (reset) begin
        fs_pc <= 32'hbfbffffc;  //trick: to make nextpc be 0xbfc00000 during reset 
    end
    else if (to_fs_valid && fs_allowin) begin
        //fs_pc <= nextpc;
        fs_pc <= true_npc;
    end
end

//assign inst_sram_en    = to_fs_valid && fs_allowin;//�������instruction������
//assign inst_sram_req    = to_fs_valid && fs_allowin;//�������instruction������

always @(posedge clk) 
begin
    if (reset) 
    begin
        // reset
        inst_sram_req <= 1'b0;
    end
    else if (fs_allowin && inst_sram_req != 1'b1) 
    begin
        inst_sram_req <= 1'b1;
    end
    else if (inst_sram_req && inst_sram_addr_ok)
    begin
        inst_sram_req <= 1'b0;
    end
end


//assign inst_sram_wen   = 4'h0;                      //��дIRAM�����ָ�ֻ�Ƕ�ָ��
assign inst_sram_wr     = 1'b0;
assign inst_sram_wstrb  = 4'b0;
//assign inst_sram_addr   = nextpc;

//assign inst_sram_addr   = true_npc;
assign inst_sram_addr   = true_physical_npc;


assign inst_sram_wdata  = 32'b0;
assign inst_sram_size   = 2'b10; // prj11 added

//assign fs_inst         = inst_sram_rdata; //��IRAM��������ľ���ָ��
assign fs_inst = true_rdata;

//assign exception_adel = (nextpc[1:0] == 2'b00)? 0 : 1;  // IF�׶ε�AdEL������



assign exception_adel = (fs_pc[1:0] == 2'b00)? 0 : 1;  // IF�׶ε�AdEL������


//nextpc�ױ䴦��
//assign true_npc = buf_npc_valid ? buf_npc : nextpc;
assign true_npc =   fs_flush?       fs_ex_pc:
                    buf_npc_valid ? buf_npc : nextpc;
  
    
always @(posedge clk)
begin
    if(reset)
    begin
        buf_npc_valid <= 1'b0;
    end
    else if(to_fs_valid && fs_allowin)
    begin
        buf_npc_valid <= 1'b0;
    end

    /*else if(br_taken)
    begin
        buf_npc_valid <= 1'b0;
    end*/
    
    else if(!buf_npc_valid)
    begin
        buf_npc_valid <= 1'b1;
    end    
end


always @(posedge clk) 
begin
    if (reset) 
    begin
        // reset
        buf_npc <= 32'b0;
    end
    else if(!buf_npc_valid)
    begin
        buf_npc <= nextpc;
    end

    else if (fs_flush)
    begin
        buf_npc <= fs_ex_pc;
    end
    /*else if (br_taken)
    begin
        buf_npc <= nextpc;
    end*/
end

//rdata �ױ䴦��
//assign true_rdata = buf_rdata_valid ? buf_rdata : inst_sram_rdata;
assign true_rdata = inst_sram_data_ok? inst_sram_rdata : buf_rdata;

 
always @(posedge clk)
begin
    if(reset)
    begin
        buf_rdata_valid <= 1'b0;
    end
    else if(ds_allowin && fs_to_ds_valid)
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
    //else if(!buf_rdata_valid)
    else if (inst_sram_data_ok)
    begin
        buf_rdata <= inst_sram_rdata;
    end
end


//tlb
/*
    output [              18:0] s0_vpn2    ,
    output                      s0_odd_page,
    output [               7:0] s0_asid    ,
    input                       s0_found   ,
    input  [$clog2(TLBNUM)-1:0] s0_index   ,
    input  [              19:0] s0_pfn     ,
    input  [               2:0] s0_c       ,
    input                       s0_d       ,
    input                       s0_v       
*/

assign {ws_cp0_entryhi, //41:10
        ws_valid,       //9:9
        ws_inst_mtc0,   //8:8
        ws_cp0_addr     //7:0
       } = ws_cp0_bus;

assign s0_vpn2      = true_npc[31:13];
assign s0_odd_page  = true_npc[12];
assign s0_asid      = ws_cp0_entryhi[7:0];

assign true_physical_npc = (true_npc[31:30] == 2'b10)? {3'b0, true_npc[28:0]}       // �����ַ���2λΪ10��˵����kseg0/1����
                                                     : {s0_pfn, true_npc[11:0]};    // �����������ַת���ķ�ʽ����ʵ��ַ


endmodule