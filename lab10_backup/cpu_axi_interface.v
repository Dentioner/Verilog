module cpu_axi_interface(
    input clk           ,
    input resetn        ,

    //inst sram-like
    input         inst_req      ,
    input         inst_wr       ,
    input  [ 1:0] inst_size     ,
    input  [31:0] inst_addr     ,
    input  [ 3:0] inst_wstrb    ,// 此信号Lab10好像用不到 
    input  [31:0] inst_wdata    ,
    output [31:0] inst_rdata    ,
    output        inst_addr_ok  ,
    output        inst_data_ok  ,
    
    //data sram-like
    input         data_req      ,
    input         data_wr       ,
    input  [ 1:0] data_size     ,
    input  [31:0] data_addr     ,
    input  [ 3:0] data_wstrb    ,// 此信号Lab10好像用不到 
    input  [31:0] data_wdata    ,
    output [31:0] data_rdata    ,
    output        data_addr_ok  ,
    output        data_data_ok  ,

    //axi
    //ar
    output reg [ 3:0] arid      ,
    output reg [31:0] araddr    ,
    //output     [31:0] araddr    ,// test!!!!!!!!!!!!!!!!
    output     [ 7:0] arlen     ,
    output reg [ 2:0] arsize    ,
    output     [ 1:0] arburst   ,
    output     [ 1:0] arlock    ,
    output     [ 3:0] arcache   ,
    output     [ 2:0] arprot    ,
    //output reg    arvalid   ,
    output        arvalid   , // test!!!!!!!!!!!!!!!!
    input         arready   ,
    //r        
    input  [ 3:0] rid       , // 这个信号不知道在prj10里面能干啥
    input  [31:0] rdata     ,
    input  [ 1:0] rresp     ,
    input         rlast     ,
    input         rvalid    ,
    //output reg    rready    ,
    output        rready    ,   // test!!!!!!!!!!!!!!!!
    

    //aw       
    output     [ 3:0] awid      ,
    output reg [31:0] awaddr    ,
    output     [ 7:0] awlen     ,
    output reg [ 2:0] awsize    ,
    output     [ 1:0] awburst   ,
    output     [ 1:0] awlock    ,
    output     [ 3:0] awcache   ,
    output     [ 2:0] awprot    ,
    //output reg        awvalid   ,
    output            awvalid   , // test!!!!!!!!!!!!!!!!!!!!!
    input             awready   ,
    //w        
    output     [ 3:0] wid       ,
    output reg [31:0] wdata     ,
    output reg [ 3:0] wstrb     ,
    output            wlast     ,
    //output reg        wvalid    ,
    output            wvalid , // test!!!!!!!!!!!!!!!!!!!!!!!!!!
    input         wready    ,
    //b        
    input     [ 3:0] bid       , // 这个信号好像在prj10里面没用到
    input     [ 1:0] bresp     ,
    input            bvalid    ,
    //output reg       bready    
    output           bready     // test


    );


localparam AR_not_finish = 2'b00;
localparam AR_finish   = 2'b01;
localparam AR_init  = 2'b10;

localparam R_not_finish  = 2'b00;
localparam R_finish    = 2'b01;
localparam R_finished   = 2'b10;

localparam AW_not_finish = 2'b00;
localparam AW_finish   = 2'b01;
//localparam AW_finished  = 2'b10;

localparam W_not_finish  = 2'b10;
localparam W_finish    = 2'b11;
//localparam W_finished   = 2'b10;

localparam B_not_start  = 2'b00;
localparam B_working    = 2'b01;
localparam B_finished   = 2'b10;

reg read_transaction;   //读事务
reg write_transaction;  //写事务
wire read_signal;
wire write_signal;

wire sram_data_read_handshake;
wire sram_inst_read_handshake;
wire sram_data_write_handshake;
wire sram_inst_write_handshake;


// axi握手信号标志
wire ar_handshake;
wire r_handshake;
wire aw_handshake;
wire w_handshake;
wire b_handshake;


// 给axi-slave的数据
wire [31:0] address;
wire [31:0] data_in;

//wire awvalid_wire;
//wire arvalid_wire;
//wire wvalid_wire ;

//下面几个状态机的状态
reg [1:0] state_ar;
reg [1:0] state_r;
reg [1:0] state_aw_w;
reg [1:0] state_b;

reg [31:0] rdata_buffer;
reg [31:0] araddr_buffer;


wire xxxx_data_ok;

wire [ 3:0] wstrb_wire_all;
wire [ 3:0] wstrb_wire_zero;
wire [ 3:0] wstrb_wire_one;
wire [ 3:0] wstrb_wire_two;

reg inst_req_reg;
reg data_req_reg;

//assign ar_handshake = (inst_req & inst_addr_ok) | (data_req & data_addr_ok);
assign ar_handshake = arvalid & arready;
assign r_handshake  = rvalid  & rready;
assign aw_handshake = awvalid & awready;
assign w_handshake  = wvalid  & wready;
assign b_handshake  = bvalid  & bready;

// 以下信号是根据讲义所描述的“固定不动”的信号赋值
assign arlen    = 0;
assign arburst  = 2'b01;
assign arlock   = 0;
assign arcache  = 0;
assign arprot   = 0;

//assign awid     = 4'b0001;
assign awid = 0; //test!!!!!!!!!!!!!!!!!!!!

assign awlen    = 0;
assign awburst  = 2'b01;
assign awlock   = 0;
assign awcache  = 0;
assign awprot   = 0;

assign wid      = 4'b0001;
assign wlast    = 1'b1;

/*
// 以下assign对应P169的2.2章节所指示的表达逻辑
assign arvalid_wire = //(~resetn)? 0 : // 此行的逻辑见讲义P171
                    (inst_req == 1 && inst_wr == 0)? 1 :
                    (data_req == 1 && data_wr == 0)? 1 : 0;

assign awvalid_wire = //(~resetn)? 0 : // 此行的逻辑见讲义P171
                    (inst_req == 1 && inst_wr == 1)? 1 :
                    (data_req == 1 && data_wr == 1)? 1 : 0;

assign wvalid_wire  = awvalid;

//rvalid和bvalid是input，不归这个模块管
*/

//assign inst_addr_ok = (read_transaction)?arready : 
//                      (write_transaction)?AXI 上的awready 和wready 都已经或正在为1 : 0;
/*
assign inst_addr_ok = (!inst_req)? 0 :
                      (read_transaction)?arready : 
                      (write_transaction)? ( awready | wready ) : 0; // 不知道到底怎样才算是ready信号“正在成为1”



assign data_addr_ok = (!data_req)? 0 : 
                      (read_transaction)?arready : 
                      (write_transaction)?(awready | wready): 0; // 不知道到底怎样才算是ready信号“正在成为1”
*/

assign inst_addr_ok = (read_transaction)?  0 :
                      (write_transaction)? 0 :
                      (data_req)? 0 : 1;

assign data_addr_ok = (read_transaction)?  0 :
                      (write_transaction)? 0 : 1;




assign inst_data_ok = (!inst_req_reg)? 0 : 
                      (read_transaction)?r_handshake :
                      (write_transaction)?b_handshake : 0;

assign data_data_ok = (!data_req_reg)? 0 :
                      (read_transaction)?r_handshake :
                      (write_transaction)?b_handshake : 0;


/*
assign inst_data_ok = (!inst_req)? 0 : xxxx_data_ok;

assign data_data_ok = (!data_req)? 0 : xxxx_data_ok;

assign xxxx_data_ok = (read_transaction)?(state_r == R_finish) :
                      (write_transaction)?(state_b == B_not_start) : 0;
*/

//????????????上面这俩信号没得区分？

/*assign inst_addr = (!inst_req)? 0 :
                   (read_transaction)?araddr :
                   (write_transaction)?awaddr : 0;

assign data_addr = (!data_req)? 0 :
                   (read_transaction)?araddr :
                   (write_transaction)?awaddr : 0;*/
//????????????上面这俩信号没得区分？

/*assign inst_size = (!inst_req)? 0 :
                   (read_transaction)?arsize : 
                   (write_transaction)?awsize : 0;

assign data_size = (!data_req)? 0 :
                   (read_transaction)?arsize : 
                   (write_transaction)?awsize : 0;   */              
//????????????上面这俩信号没得区分？

//assign inst_rdata = (r_handshake & inst_req)? rdata_buffer : 0;
//assign data_rdata = (r_handshake & data_req)? rdata_buffer : 0;


//assign inst_rdata = (inst_req)? rdata_buffer : 0;
//assign data_rdata = (data_req)? rdata_buffer : 0;
assign inst_rdata = (inst_req_reg)? rdata : 0;
assign data_rdata = (data_req_reg)? rdata : 0;



/*
assign inst_wstrb = (inst_req) ? wstrb : 0;
assign data_wstrb = (data_req) ? wstrb : 0;*/
//这些信号都怎么区分？？？？


    
assign read_signal  = (data_req & (~data_wr)) | (inst_req & (~inst_wr)); //读信号的逻辑：有req，且wr为0
assign write_signal = (data_req &   data_wr)  |  (inst_req &   inst_wr); //写信号的逻辑：有req，且wr为1

assign sram_data_read_handshake  = data_req & data_addr_ok & (~data_wr);
assign sram_inst_read_handshake  = inst_req & inst_addr_ok & (~inst_wr);
assign sram_data_write_handshake = data_req & data_addr_ok & data_wr;
assign sram_inst_write_handshake = inst_req & inst_addr_ok & inst_wr;



always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        read_transaction <= 1'b0;
    end
    else if ((~read_transaction) && (read_signal)) // 读事务的赋值逻辑：观测到读信号，而且读事务寄存器还没被置为1 
    begin
        read_transaction <= 1'b1;
    end
    else if(r_handshake) //握手之后，下一拍读事务结束，因此非阻塞赋值为0
    begin
        read_transaction <= 1'b0;
    end
end

always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        write_transaction <= 1'b0;
    end
    else if ((~write_transaction) && (write_signal)) // 写事务的赋值逻辑：观测到写信号，而且写事务寄存器还没被置为1 
    begin
        write_transaction <= 1'b1;
    end
    else if(b_handshake) //握手之后，下一拍写事务结束，非阻塞赋值为0
    begin
        write_transaction <= 1'b0;
    end
end


always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        inst_req_reg <= 1'b0;    
    end
    else if (sram_inst_read_handshake) 
    begin
        inst_req_reg <= inst_req;
    end

    else if (sram_inst_write_handshake)
    begin
        inst_req_reg <= inst_req;
    end

    else if (r_handshake | b_handshake)
    begin
        inst_req_reg <= 1'b0;
    end
end

always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        data_req_reg <= 1'b0;    
    end
    else if (sram_data_read_handshake) 
    begin
        data_req_reg <= data_req;
    end

    else if (sram_data_write_handshake)
    begin
        data_req_reg <= data_req;
    end

    else if (r_handshake | b_handshake)
    begin
        data_req_reg <= 1'b0;
    end
end



assign address = (data_req & data_addr_ok)? data_addr :
                 (inst_req & inst_addr_ok)? inst_addr : 0;

assign data_in = (data_req)? data_wdata :
                 (inst_req)? inst_wdata : 0;

//test
/*
assign address = (inst_req)? inst_addr :
                 (data_req)? data_addr : 0;

assign data_in = (inst_req)? inst_wdata :
                 (data_req)? data_wdata : 0;
*/
/****************************************axi-ar****************************************/
//状态机
/*
always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        state_ar <= AR_init;
    end
    else if (read_signal && (!ar_handshake) && (state_ar != AR_finish)) // 检测到读事务，或者检测到slave传递过来的arready 
    begin
        state_ar <= AR_finish;
    end
    else if (arready && (state_ar != AR_finish)) 
    begin
        state_ar <= AR_finish;
    end
    else if (ar_handshake && (state_ar == AR_finish)) // 如果握手，那么下一拍就完成了
    begin
        //state_ar <= AR_finished;
        state_ar <= AR_not_finish;
    end
end
*/
always @(posedge clk) 
begin
    if (~resetn) begin
        // reset
        state_ar <= AR_init;
    end

    else if (ar_handshake)// && (state_ar != AR_finish)) 
    begin
        state_ar <= AR_finish;
    end

    //else if (state_ar == AR_finish)
    else if (r_handshake)
    begin
        state_ar <= AR_not_finish; 
    end
end



// arvalid

assign arvalid = (state_ar != AR_finish) && read_transaction;


/*
always @(posedge clk)   
begin
    if (~resetn) 
    begin
        // reset
        arvalid <= 1'b0;
    end
    else if ((araddr == awaddr) && wvalid) //阻塞 
    begin
        arvalid <= 1'b0;
    end
    
    
    else if (read_signal && (!ar_handshake) && (!r_handshake))
    begin
        arvalid <= 1'b1;
    end
    




    else if (ar_handshake) 
    begin
        arvalid <= 1'b0;
    end




end

*/
/*
    else if (sram_data_read_handshake && (!ar_handshake))
    begin
        arvalid <= 1'b1;
    end

    else if (sram_inst_read_handshake && (!ar_handshake)) 
    begin
        arvalid <= 1'b1;
    end
*/

/*
    else if (read_signal && (!r_handshake))
    begin
        arvalid <= 1'b0;
    end
*/


// araddr
always @(posedge clk) 
begin
    if (~resetn) begin
        // reset
        //araddr_buffer <= 32'hxxxxxxxx;//test
        araddr <= 32'hxxxxxxxx;//test
    end
    /*else if (read_signal && (!ar_handshake) && (state_ar == AR_not_finish)) // buffer应该与状态机的变化保持一致 
    begin
        araddr <= address;
    end

    else if (arready && (state_ar == AR_not_finish)) // buffer应该与状态机的变化保持一致 
    begin
        araddr <= address;
    end*/

    /*else if (read_signal) 
    begin
        //araddr_buffer <= address;
        araddr <= address;    
    end*/

    else if (sram_data_read_handshake) 
    begin
        araddr <= data_addr;
    end

    else if (sram_inst_read_handshake) 
    begin
        araddr <= inst_addr;
    end
end

//assign araddr = address;

// arid
always @(posedge clk)   
begin
    if (~resetn) 
    begin
        // reset
        arid <= 0;        
    end    

    else if (sram_data_read_handshake) 
    begin
        //arid <= 4'b0001;    
        arid <= 0; //test!!!!!!!!!!!!!!!
    end

    else if (sram_inst_read_handshake) 
    begin
        arid <= 0;
    end

end

// arsize
always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        arsize <= 0;
    end
    else if (sram_data_read_handshake) 
    begin
        arsize <= data_size; 
    end

    else if (sram_inst_read_handshake) 
    begin
        arsize <= inst_size;    
    end
end

/****************************************axi-r****************************************/
//axi-r的状态机

/*
always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        state_r <= R_not_finish;
    end
    else if (state_ar == AR_not_finish && read_transaction && state_r == R_not_finish)  // 检测到rready即将上升
    begin
        state_r <= R_finish;
    end

    else if (rvalid && (state_r == R_not_finish)) // 检测到rvalid
    begin
        state_r <= R_finish;
    end
    // 为cache预留的......
    else if (r_handshake && (state_r == R_finish) && (!rlast)) //非最后一次传输
    begin 
        state_r <= R_not_finish;
    end
    else if (r_handshake && (state_r == R_finish) && rlast) //最后一次传输
    begin
        state_r <= R_finished;
    end
    else if (state_r == R_finished) 
    begin
        state_r <= R_not_finish;
    end 
end
*/


always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        state_r <= R_not_finish;
    end
    //else if (state_ar == AR_not_finish && read_transaction && state_r == R_not_finish)  // 检测到rready即将上升
    else if (r_handshake)
    begin
        state_r <= R_finish;
    end
/*
    else if (rvalid && (state_r == R_not_finish)) // 检测到rvalid
    begin
        state_r <= R_finish;
    end
    // 为cache预留的......
    else if (r_handshake && (state_r == R_finish)) 
    begin 
        state_r <= R_not_finish;
    end
*/
    else if (ar_handshake) 
    begin
        state_r <= R_not_finish;
    end

end


// rready
/*
always @(posedge clk)   
begin
    if (~resetn) 
    begin
        // reset
        rready <= 1'b0;
    end
    //else if (rvalid & read_transaction)
    //else if (state_ar == AR_not_finish && read_transaction)
    else if (ar_handshake && read_transaction)
    begin
        rready <= 1'b1;
    end


    else if (r_handshake) 
    begin
        rready <= 1'b0;
    end

end
*/

assign rready = (state_ar == AR_finish) && read_transaction;


// rdata_buffer
always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        rdata_buffer <= 0;
    end
    else if (state_ar == AR_not_finish && read_transaction && state_r == R_not_finish)  // 检测到rready即将上升
    begin
        rdata_buffer <= rdata;
    end

    else if (rvalid && (state_r == R_not_finish)) // 检测到rvalid
    begin
        rdata_buffer <= rdata;
    end
    // 为cache预留的......
    /*
    else if (r_handshake && (state_r == R_finish) && (!rlast)) //非最后一次传输
    begin 
        state_r <= R_not_finish;
    end
    else if (r_handshake && (state_r == R_finish) && rlast) //最后一次传输
    begin
        state_r <= R_finished;
    end
    else if (state_r == R_finished) 
    begin
        state_r <= R_not_finish;
    end 
    */
end


/****************************************axi-aw/w****************************************/
//axi-aw/w的状态机
always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        state_aw_w <= AW_not_finish;    
    end
    /*
    else if ((state_aw_w == AW_not_finish) && write_signal && (!aw_handshake)) // 检测到awvalid
    begin
        state_aw_w <= AW_finish;
    end

    else if ((state_aw_w == AW_not_finish) && awready) // 检测到awready 
    begin
        state_aw_w <= AW_finish;
    end

    else if ((state_aw_w == AW_finish) && aw_handshake) // 由于共用一个状态机，那么这时候进入w状态
    begin
        state_aw_w <= W_finish;
    end
    */
    else if (aw_handshake)
    begin
        state_aw_w <= AW_finish;
    end

    else if (w_handshake)
    begin
        state_aw_w <= W_finish;
    end

    else if (b_handshake)
    begin
        state_aw_w <= AW_not_finish;
    end
    /*
    else if ((state_aw_w == W_finish) && w_handshake && (!wlast))
    begin
        state_aw_w <= W_not_finish;
    end

    else if ((state_aw_w == W_finish) && w_handshake && wlast)
    begin
        state_aw_w <= W_finished;
    end

    else if (state_aw_w == W_finished)
    begin
        state_aw_w <= W_not_finish;
    end

    else if ((state_aw_w == W_not_finish) && write_transaction) // 检测到wready即将上升
    begin
        state_aw_w <= W_finish;
    end

    else if ((state_aw_w == W_not_finish) && wvalid) // 检测到了wvalid
    begin
        state_aw_w <= W_finish;
    end*/



end

//awvalid
/*
always @(posedge clk)  
begin
    if (~resetn) 
    begin
        // reset
        awvalid <= 1'b0;
    end
    else if (write_signal && (!aw_handshake) && (!w_handshake)) 
    begin
        awvalid <= 1'b1;
    end

    else if (aw_handshake) 
    begin
        awvalid <= 1'b0;    
    end
end
*/
assign awvalid = write_transaction && (state_aw_w != AW_finish) && (state_aw_w != W_finish);// && (state_b == B_not_start);

// awaddr
always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        //awaddr <= 0;    
       awaddr <= 32'hxxxxxxxx; //test
    end
/*    
    else if ((state_aw_w == AW_not_finish) && write_signal && (!aw_handshake)) // 检测到awvalid
    begin
        awaddr <= address;
    end

    else if ((state_aw_w == AW_not_finish) && awready) // 检测到awready 
    begin
        awaddr <= address;
    end
*/
    else if (sram_data_write_handshake) 
    begin
        awaddr <= data_addr;
    end

    else if (sram_inst_write_handshake) 
    begin
        awaddr <= inst_addr;
    end

end

// awsize
always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        awsize <= 0;    
    end
    else if (sram_data_write_handshake)
    begin
        awsize <= data_size;
    end

    else if (sram_inst_write_handshake) 
    begin
        awsize <= inst_size;
    end
end


/*
always @(posedge clk)   // wvalid 
begin
    if (~resetn) 
    begin
        // reset
        wvalid <= 1'b0;   
    end
    //else if (aw_handshake) // 检测到aw握手 
    else if (write_signal && aw_handshake && (!w_handshake))
    begin
        wvalid <= 1'b1;
    end

    else if (w_handshake) 
    begin
        wvalid <= 1'b0;    
    end
end
*/

assign wvalid = write_transaction && (state_aw_w != W_finish);
//assign wvalid = write_transaction && (state_aw_w == W_not_finish);

//wdata
always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        wdata <= 0;    
    end
    /*
    else if ((state_aw_w == AW_finish) && aw_handshake) // 由于共用一个状态机，那么这时候进入w状态 
    begin
        wdata <= data_in;
    end

    else if ((state_aw_w == W_not_finish) && write_transaction) // 检测到wready即将上升
    begin
        wdata <= data_in;
    end

    else if ((state_aw_w == W_not_finish) && wvalid) // 检测到了wvalid
    begin
        wdata <= data_in;
    end
    */

    else if (sram_data_write_handshake)
    begin
        wdata <= data_wdata;
    end

    else if (sram_inst_write_handshake)
    begin
        wdata <= inst_wdata;
    end

end

//wstrb
always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        wstrb <= 0;
    end
    else if (wvalid) 
    begin
        wstrb <= wstrb_wire_all;
    end
end

// size = 0
assign wstrb_wire_zero = (awaddr[1:0] == 2'b00) ? 4'b0001 :
                         (awaddr[1:0] == 2'b01) ? 4'b0010 :
                         (awaddr[1:0] == 2'b10) ? 4'b0100 :
                         (awaddr[1:0] == 2'b11) ? 4'b1000 : 4'b0000;
// size = 1
assign wstrb_wire_one  = (awaddr[1:0] == 2'b00) ? 4'b0011 :
                         (awaddr[1:0] == 2'b10) ? 4'b1100 : 4'b0000;

// size = 2
assign wstrb_wire_two  = (awaddr[1:0] == 2'b00) ? 4'b1111 : 4'b0000; // 为lwl/lwr/swl/swr预留一下......


assign wstrb_wire_all  = (awsize == 2'b00) ? wstrb_wire_zero :
                         (awsize == 2'b01) ? wstrb_wire_one  :
                         (awsize == 2'b10) ? wstrb_wire_two  : 4'b0000;

/****************************************axi-b****************************************/
//axi-b的状态机
always @(posedge clk) 
begin
    if (~resetn) 
    begin
        // reset
        state_b <= B_not_start;    
    end
    else if (wlast && w_handshake) // 看到本次W结束了 
    begin
        state_b <= B_working;
    end

    else if (b_handshake) 
    begin
        state_b <= B_not_start;
    end
end


/*
always @(posedge clk)   // bready
begin
    if (~resetn) 
    begin
        // reset
        bready <= 1'b0;    
    end
    //else if (w_handshake && wlast) // 检测到w结束了  
    else if (w_handshake && write_transaction) // 检测到w结束了  
    begin
        bready <= 1'b1;
    end

    else if(b_handshake)
    begin
        bready <= 1'b0; 
    end
end
*/

//assign bready = write_transaction && (state_aw_w == AW_finish);
assign bready = write_transaction && (state_aw_w != AW_not_finish);

endmodule


