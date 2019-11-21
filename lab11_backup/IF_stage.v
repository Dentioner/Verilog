`include "mycpu.h"

module if_stage(
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
   
    output        inst_sram_req, // �����źŵ�valid��      
    output        inst_sram_wr,
    output [ 3:0] inst_sram_wstrb,
    output [ 1:0] inst_sram_size ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    input  [`EXECEPTION_BUS_WD - 1:0] exception_bus,
    input         inst_sram_addr_ok,
    input         inst_sram_data_ok

);

reg         fs_valid;
wire        fs_ready_go;
wire        fs_allowin;
wire        to_fs_valid;

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

assign {fs_flush, fs_ex_pc, fs_has_int} = exception_bus;


//wire [`BR_BUS_WD - 2 : 0] br_target;
assign {br_taken,br_target} = br_bus;//?????�����bug��br_bus�����32λ����Ҫ�ָ�1λ��taken��32λ��target���ֲ�������

wire [31:0] fs_inst;//instruction��ָ��
reg  [31:0] fs_pc;
assign fs_to_ds_bus = {exception_adel,
                       fs_inst ,
                       fs_pc   };//�����������instruction��PC

// pre-IF stage
//assign to_fs_valid  = ~reset;//����reset��˵�����Ը�IF������
assign to_fs_valid  = ~reset && inst_sram_addr_ok;// prj11 added
assign seq_pc       = fs_pc + 3'h4; //PC+4������˳�����һ��ָ��
assign nextpc       = (fs_flush)? fs_ex_pc  :
                      (br_taken)? br_target : seq_pc; //������һ��ָ���ǲ���PC+4��

// IF stage
//assign fs_ready_go    = 1'b1; //������ID�׶δ���������
assign fs_ready_go    = inst_sram_data_ok; // prj11 added 

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
        fs_pc <= nextpc;
    end
end

//assign inst_sram_en    = to_fs_valid && fs_allowin;//�������instruction������
assign inst_sram_req    = to_fs_valid && fs_allowin;//�������instruction������
//assign inst_sram_wen   = 4'h0;                      //��дIRAM�����ָ�ֻ�Ƕ�ָ��
assign inst_sram_wr     = 1'b0;
assign inst_sram_wstrb  = 4'b0;
assign inst_sram_addr   = nextpc;
assign inst_sram_wdata  = 32'b0;
assign inst_sram_size   = 2'b10; // prj11 added

//assign fs_inst         = inst_sram_rdata; //��IRAM��������ľ���ָ��
assign fs_inst = true_rdata;

//assign exception_adel = (nextpc[1:0] == 2'b00)? 0 : 1;  // IF�׶ε�AdEL������



assign exception_adel = (fs_pc[1:0] == 2'b00)? 0 : 1;  // IF�׶ε�AdEL������


//nextpc�ױ䴦��
assign true_npc = buf_npc_valid ? buf_npc : nextpc;
    
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
    else if(!buf_npc_valid)
    begin
        buf_npc_valid <= 1'b1;
    end
    
    if(!buf_npc_valid)
    begin
        buf_npc <= nextpc;
    end
end

//rdata �ױ䴦��
assign true_rdata = buf_rdata_valid ? buf_rdata : inst_sram_rdata;
   
always @(posedge clk)
begin
    if(reset)
    begin
        buf_rdata_valid <= 1'b0;
    end
    else if(ds_allowin)
    begin
        buf_npc_valid <= 1'b0;
    end
    else if(!buf_rdata_valid)
    begin
        buf_rdata_valid <= 1'b1;
    end
    
    if(!buf_rdata_valid)
    begin
        buf_rdata <= inst_sram_rdata;
    end
end

endmodule