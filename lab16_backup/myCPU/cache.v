module cache(
	input clk	,
	input resetn,

	// to CPU core
	input 				valid		,
	input 				op 			,
	input  [ 7:0]		index		,
	input  [19:0]		tlb_tag		,
	input  [ 3:0]		offset 		,
	input  [ 3:0]		wstrb 		,
	input  [31:0]		wdata 		,
	
	output 				addr_ok 	,
	output    			data_ok 	,
	output [31:0]		rdata		,
	
	// to bridge	
	output reg			rd_req 		,
	output [ 2:0]		rd_type 	,	
	output [31:0]		rd_addr 	,
	input 				rd_rdy 		,
	input 				ret_valid	,
	//input  [ 1:0] 		ret_last 	,
	input 				ret_last	,
	input  [31:0] 		ret_data 	,

	output reg			wr_req 		,
	output [ 2:0]		wr_type 	,	
	output [31:0]		wr_addr 	,
	output [ 3:0] 		wr_wstrb 	,
	output [127:0]		wr_data 	,
	input 				wr_rdy 		



	);
wire [31:0]		way0_tagv_r;
wire [19:0] 	way0_tag_r;
wire 			way0_v_r;

wire [31:0]		way0_tagv_w;
wire [19:0] 	way0_tag_w;
wire 			way0_v_w;
wire 			way0_tagv_we;
wire [ 7:0]		way0_tagv_addr;

wire 			way0_d_r;
wire 			way0_d_w;
wire 			way0_d_we;
wire [ 7:0]		way0_d_addr;

wire [127:0] 	way0_rdata;
wire [31:0]		way0_bank0_rdata;
wire [31:0]		way0_bank1_rdata;
wire [31:0]		way0_bank2_rdata;
wire [31:0]		way0_bank3_rdata;

//wire [127:0] 	way0_wdata;
//wire [31:0]		way0_bank0_wdata;
//wire [31:0]		way0_bank1_wdata;
//wire [31:0]		way0_bank2_wdata;
//wire [31:0]		way0_bank3_wdata;
//wire [31:0]		way0_bank_wdata; // we用于区分不同bank就可以了，这个信号通用即可




wire 			way0_bank0_we;
wire 			way0_bank1_we;
wire 			way0_bank2_we;
wire 			way0_bank3_we;

wire [3:0] 		way0_bank0_wen;
wire [3:0] 		way0_bank1_wen;
wire [3:0] 		way0_bank2_wen;
wire [3:0] 		way0_bank3_wen;


wire [ 7:0]		way0_bank_addr;


wire [31:0]		way1_tagv_r;
wire [19:0] 	way1_tag_r;
wire 			way1_v_r;

wire [31:0]		way1_tagv_w;
wire [19:0] 	way1_tag_w;
wire 			way1_v_w;
wire 			way1_tagv_we;
wire [ 7:0]		way1_tagv_addr;

wire 			way1_d_r;
wire 			way1_d_w;
wire 			way1_d_we;
wire [ 7:0]		way1_d_addr;

wire [127:0] 	way1_rdata;
wire [31:0]		way1_bank0_rdata;
wire [31:0]		way1_bank1_rdata;
wire [31:0]		way1_bank2_rdata;
wire [31:0]		way1_bank3_rdata;

//wire [127:0] 	way1_wdata;
//wire [31:0]		way1_bank0_wdata;
//wire [31:0]		way1_bank1_wdata;
//wire [31:0]		way1_bank2_wdata;
//wire [31:0]		way1_bank3_wdata;
//wire [31:0]		way1_bank_wdata; // we用于区分不同bank就可以了，这个信号通用即可

wire 			way1_bank0_we;
wire 			way1_bank1_we;
wire 			way1_bank2_we;
wire 			way1_bank3_we;

wire [3:0] 		way1_bank0_wen;
wire [3:0] 		way1_bank1_wen;
wire [3:0] 		way1_bank2_wen;
wire [3:0] 		way1_bank3_wen;

wire [ 7:0]		way1_bank_addr;

wire [31:0]		bank0_wdata;
wire [31:0] 	bank1_wdata;
wire [31:0] 	bank2_wdata;
wire [31:0] 	bank3_wdata;


// tag compare
wire way0_hit;
wire way1_hit;
wire cache_hit;

// data select
wire [31:0] way0_load_word;
wire [31:0] way1_load_word;

wire [31:0] load_res; // lookup，命中的时候从Cache里面读出的数据


wire [127:0] replace_data; // replace，未命中的时候从Cache里面读出的一整行数据
wire 		 replace_way;
wire 		 this_way_is_dirty;
wire 		 this_way_is_valid;

//request buffer
reg  [ 7:0] request_index;
reg  		request_op;
reg  [31:0] request_wdata;
reg  [ 3:0] request_wstrb;
reg  [ 3:0] request_offset;
reg  [19:0] request_tag;

reg  [ 1:0] miss_word_counter; // 记录已经从AXI总线返回了几个32位数据
reg 		miss_replace_way ; // 记录缺失Cache行准备要替换的路信息


//state machine

reg       addr_ok_reg;
reg 	  data_ok_reg;

reg [2:0] cache_state_now;
reg [2:0] cache_state_next;

//wire [1:0] request_type;

wire 	  lookup_mode;
wire 	  hitstore_mode;
wire 	  replace_mode;
wire 	  refill_mode;

reg 	  wr_handshake_buffer;

reg  [31:0] rdata_buffer;

// Cache states
localparam IDLE    = 3'b000;	// Cache 模块当前没有任何操作
localparam LOOKUP  = 3'b001;	// Cache 模块当前正在执行一个操作且得到了它的查询结果
localparam MISS    = 3'b010;	// Cache 模块当前处理的操作Cache 缺失
localparam REPLACE = 3'b011;	// 待替换的Cache 行已经从Cache 中读出
localparam REFILL  = 3'b100;	// Cache 缺失的访存请求已发出，准备/正在将缺失的Cache 行数据写入Cache 中



/****************************************Default Output****************************************/
assign rd_type 	= 3'b100; // cache miss时替换一整行
//assign rd_addr 	= {request_tag, request_index, request_offset};
assign rd_addr 	= {request_tag, request_index, 4'b0000};



assign wr_type 	= 3'b100;
assign wr_addr 	= (miss_replace_way)? {way1_tag_r, request_index, request_offset} : 
								 	  {way0_tag_r, request_index, request_offset};

// wr_addr ≠ rd_addr
assign wr_wstrb = wstrb;
assign wr_data 	= replace_data;

always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		rdata_buffer <= 32'b0;
	end
	//else if ((cache_state_now == LOOKUP) && cache_hit && (!op)) // read hit 
	else if ((cache_state_now == LOOKUP) && cache_hit) // read hit 
	begin
		rdata_buffer <= load_res;
	end
	else if ((cache_state_now == REFILL) && (request_offset[3:2] == miss_word_counter)) // read miss
	begin
		rdata_buffer <= ret_data;
	end
end
//assign rdata = ((cache_state_now == REFILL) && (request_offset[3:2] == miss_word_counter) && (ret_valid))? ret_data : load_res;

assign rdata = rdata_buffer;

/****************************************Tag Compare****************************************/

//assign way0_hit 	= way0_v && (way0_tag == paddr[31:12]);
//assign way1_hit 	= way1_v && (way1_tag == paddr[31:12]);

//assign way0_hit 	= way0_v_r && (way0_tag_r == tlb_tag);
//assign way1_hit 	= way1_v_r && (way1_tag_r == tlb_tag);

assign way0_hit 	= way0_v_r && (way0_tag_r == request_tag);
assign way1_hit 	= way1_v_r && (way1_tag_r == request_tag);


assign cache_hit 	= (way0_hit || way1_hit) && (cache_state_now != IDLE);


//debug
/*
wire 	way0_hit_next;
wire 	way1_hit_next;
wire 	cache_hit_next;

assign way0_hit_next = way0_v_r && (way0_tag_r == tlb_tag);
assign way1_hit_next = way1_v_r && (way1_tag_r == tlb_tag);
assign cache_hit_next = way0_hit_next || way1_hit_next;
*/



/****************************************Data Select****************************************/

//assign way0_load_word = way0_data[pa[3:2]*32 +: 32];
//assign way1_load_word = way1_data[pa[3:2]*32 +: 32];

//assign way0_load_word = way0_rdata[offset[3:2]*32 +: 32];
//assign way1_load_word = way1_rdata[offset[3:2]*32 +: 32];

assign way0_load_word = way0_rdata[request_offset[3:2]*32 +: 32];
assign way1_load_word = way1_rdata[request_offset[3:2]*32 +: 32];


assign load_res = {32{way0_hit}} & way0_load_word
				| {32{way1_hit}} & way1_load_word;			// load_res用于传给 cpu

assign replace_data = miss_replace_way ? way1_rdata : way0_rdata; // replace_data 用于传给AXI（如果是dirty的话）


//assign rdata = ((cache_state_now == REFILL) && (request_offset[3:2] == miss_word_counter) && (ret_valid))? ret_data : load_res;



//debug
wire rdata_debugger_3;
assign rdata_debugger_3 = ((cache_state_now == REFILL) && (request_offset[3:2] == miss_word_counter) && (ret_valid))? 0 : 1;



assign this_way_is_dirty = miss_replace_way? way1_d_r : way0_d_r;
assign this_way_is_valid = miss_replace_way? way1_v_r : way0_v_r;

/****************************************Request Buffer****************************************/

// always-part 3
always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		request_index <= 8'b0;
	end
// Request Buffer 中记录来自流水线方向的请求信息的域的写使能,
// 就是Cache 模块状态机IDLE→LOOKUP 和LOOKUP→LOOKUP 两组状态转换发生条件的并集 
// 这两个的并集就是，next state 为lookup，下同
	else if (cache_state_next == LOOKUP) 
	begin
		request_index <= index;
	end
end

always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		request_op <= 1'b0;
	end
	else if (cache_state_next == LOOKUP) 
	begin
		request_op <= op;
	end
end

always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		request_wdata <= 31'b0;	
	end
	else if ((cache_state_next == LOOKUP) && (op == 1'b1)) 
	begin
		request_wdata <= wdata;
	end
end

always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		request_wstrb <= 4'b0;	
	end
	else if ((cache_state_next == LOOKUP) && (op == 1'b1)) 
	begin
		request_wstrb <= wstrb;
	end
end

always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		request_offset <= 4'b0;	
	end
	else if (cache_state_next == LOOKUP) 
	begin
		request_offset <= offset;
	end
end

always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		request_tag <= 20'b0;	
	end
	else if (cache_state_next == LOOKUP) 
	begin
		request_tag <= tlb_tag;
	end
end


always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		miss_replace_way <= 1'b0;
	end
	//else if ((cache_state_next == REPLACE) && (cache_state_now == MISS)) 
	else if ((cache_state_next == MISS) && (cache_state_now == LOOKUP)) 
	begin
		miss_replace_way <= replace_way;
		//miss_replace_way <= 1'b1; // debug
	end
end

always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		miss_word_counter <= 2'b0;
	end
	else if ((cache_state_next == REFILL) && (cache_state_now == REPLACE)) 
	begin
		miss_word_counter <= 2'b0;
	end
	else if (ret_valid) // 讲义，p194, 1.3.3
	begin
		miss_word_counter <= miss_word_counter + 1;
	end
end
/****************************************LFSR****************************************/
reg [ 22:0] pseudo_random_23;

always @ (posedge clk)
begin
   if (!resetn)
       pseudo_random_23 <= {7'b1010101,16'h00FF};
   else 
       pseudo_random_23 <= {pseudo_random_23[21:0],pseudo_random_23[22] ^ pseudo_random_23[17]};
end

assign replace_way = pseudo_random_23[0];

/****************************************State Machine****************************************/

// request states
/*
localparam REQ_LOOKUP 	= 2'b00;
localparam REQ_HITSTORE = 2'b01;
localparam REQ_REPLACE 	= 2'b10;
localparam REQ_REFILL  	= 2'b11;
*/

assign lookup_mode 		= (cache_state_now == LOOKUP);
assign hitstore_mode 	= (cache_state_now == LOOKUP) && (cache_hit) && (op == 1'b1);
assign replace_mode 	= (cache_state_now == MISS);
assign refill_mode 		= (cache_state_now == REFILL) && (ret_valid);

//always-part 1
always @(posedge clk) 
begin
	if (!resetn) begin
		// reset
		cache_state_now <= IDLE;
	end
	else 
	begin
		cache_state_now <= cache_state_next;	
	end
end


//always-part 2
always @*
begin
	//cache_state_next = cache_state_now;

	case(cache_state_now)
		IDLE:
		begin
			if(valid) // 这一拍Cache 接收了流水线发来的一个新的操作请求
			begin
				cache_state_next = LOOKUP;
			end
			else 
			begin
				cache_state_next = cache_state_now;	
			end
		end

		LOOKUP:
		begin
			if (!valid && cache_hit) //这一拍流水线没有新的操作请求
			begin
				cache_state_next = IDLE;
			end

			else if (cache_hit && (request_op == 1'b1) && (request_offset[3:2] == offset[3:2]) && (op == 1'b0) && (valid)) 
			begin
				cache_state_next = IDLE;
			end

			else if (cache_hit && valid) //当前处理的操作是Cache 命中的，且这一拍Cache 接收了流水线发来的一个新的操作请求。
			begin
				cache_state_next = LOOKUP;
			end

			else if (!cache_hit) //当前处理的操作是Cache 缺失的
			begin
				cache_state_next = MISS;
			end

			else 
			begin
				cache_state_next = cache_state_now;	
			end
		end

		MISS:
		begin
			//if ((wr_rdy == 1'b1) && (valid) && (op == 1'b0) && (replace_mode) ) //AXI 总线接口模块反馈回来的wr_rdy 为1，且这一拍对Cache 发起了替换的读请求。 
			//if ((valid) && (op == 1'b0) && (replace_mode))
			if ((this_way_is_dirty) && (wr_rdy & wr_req) &&  (replace_mode) ) //AXI 总线接口模块反馈回来的wr_rdy 为1，且这一拍对Cache 发起了替换的读请求。 
			begin
				cache_state_next = REPLACE;
			end
			else if ((!this_way_is_dirty) && (replace_mode))
			begin
				cache_state_next = REPLACE;
			end
			else 
			begin
				cache_state_next = cache_state_now;	
			end
		end

		REPLACE:
		begin
			if ((rd_rdy & rd_req)) // 缺失Cache 行的访存读请求已经被AXI 总线接口模块接收 
			begin
				cache_state_next = REFILL;
			end
			else 
			begin
				cache_state_next = cache_state_now;	
			end
		end

		REFILL:
		begin
			if (ret_last && ret_valid)
			//if (ret_last) // 缺失Cache 行的最后一个32 位数据（ret_last=1）从AXI 总线接口模块返回 
			//if (data_ok)
			begin
				cache_state_next = IDLE;
			end

			else 
			begin
				cache_state_next = cache_state_now;	
			end
		end

		default:
		begin
			cache_state_next = IDLE;
		end
	endcase
end


//always-part 3
//assign addr_ok = addr_ok_reg & (cache_state_next == LOOKUP);
assign addr_ok = (cache_state_next == LOOKUP); // debug

//assign data_ok = data_ok_reg & (cache_state_next == LOOKUP);
assign data_ok = data_ok_reg;


always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		addr_ok_reg <= 1'b0;
	end
	else if ((cache_state_next == IDLE)) 
	begin
		addr_ok_reg <= 1'b1;
	end
	else if ((cache_state_now == LOOKUP) && cache_hit && (request_op == 1'b0))	 
	begin // 读后读
		addr_ok_reg <= 1'b1;
	end
	else if ((cache_state_now == LOOKUP) && cache_hit && (request_op == 1'b1) && (op == 1'b1) && (valid)) 
	begin // 写后写
		addr_ok_reg <= 1'b1;
	end
	else if ((cache_state_now == LOOKUP) && cache_hit && (request_op == 1'b1) && (request_offset[3:2] != offset[3:2]) && (op == 1'b0) && (valid)) 
	begin // 写后读，但是地址不冲突
		addr_ok_reg <= 1'b1;
	end
	else if (valid & addr_ok) // handshake
	begin 
		addr_ok_reg <= 1'b0;	
	end
end











// debug
/*
reg [3:0] test_addr_ok;
always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		test_addr_ok <= 0;
	end
	else if (cache_state_next == IDLE) 
	begin
		test_addr_ok <= 1;
	end
	else if ((cache_state_next == LOOKUP) && cache_hit && (request_op == 1'b0))	 
	begin // 读后读
		test_addr_ok <= 2;
	end
	else if ((cache_state_next == LOOKUP) && cache_hit && (request_op == 1'b1) && (op == 1'b1) && (valid)) 
	begin // 写后写
		test_addr_ok <= 3;
	end
	else if ((cache_state_next == LOOKUP) && cache_hit && (request_op == 1'b1) && (request_offset[3:2] != offset[3:2]) && (op == 1'b0) && (valid)) 
	begin // 写后读，但是地址不冲突
		test_addr_ok <= 4;
	end
	else if (valid & addr_ok) // handshake
	begin 
		test_addr_ok <= 5;	
	end
end
*/









always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		data_ok_reg <= 1'b0;
	end
	else if ((cache_state_now == LOOKUP) && cache_hit)// && (data_ok == 1'b0)) 
	begin
		data_ok_reg <= 1'b1;
	end
	/*else if ((cache_state_next != IDLE) && (cache_state_next != LOOKUP) && (request_op == 1'b1))// && (data_ok == 1'b0)) 
	begin
		data_ok <= 1'b1;
	end*/

	/*else if ((cache_state_now == REFILL) && (ret_valid == 1) && (miss_word_counter == request_offset[3:2])) 
	begin
		data_ok <= 1'b1;
	end*/

	else if ((ret_last & ret_valid)) 
	begin
		data_ok_reg <= 1'b1;
	end
	else 
	begin
		data_ok_reg <= 1'b0;	
	end
end



//debug
/*
reg [3:0] test_data_ok;
always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		test_data_ok <= 0;
	end
	else if ((cache_state_next == LOOKUP) && cache_hit)// && (data_ok == 1'b0)) 
	begin
		test_data_ok <= 1;
	end


	else if ((ret_last & ret_valid)) 
	begin
		test_data_ok <= 2;
	end
	else 
	begin
		test_data_ok <= 3;	
	end
end
*/







always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		rd_req <= 1'b0;
	end
	else if ((cache_state_now == REPLACE) && (rd_req == 1'b0) )
	begin
		rd_req <= 1'b1;
	end
	else if (rd_req & rd_rdy) // handshake
	begin
		rd_req <= 1'b0;	
	end
end

always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		wr_req <= 1'b0;
	end
	//else if ((cache_state_now == MISS) && (cache_state_next == REPLACE) && (this_way_is_dirty)) 
	else if ((cache_state_now == MISS) &&  (this_way_is_dirty) && (wr_req == 1'b0)) 
	// 这里不能改成cache_state_next，因为this way is dirty信号依赖的miss_replace_way信号是用这个条件非阻塞变化的
	begin
		wr_req <= 1'b1;
	end
	else if (wr_rdy & wr_req) // handshake
	begin
		wr_req <= 1'b0;
	end
end

/*
always @(posedge clk) 
begin
	if (~resetn) 
	begin
		// reset
		wr_handshake_buffer <= 1'b0;	
	end
	else if ((cache_state_now == MISS) &&  (this_way_is_dirty)) // 在wr_req再次拉高的时候重置此buffer
	begin
		wr_handshake_buffer <= 1'b0;
	end
	else if (wr_rdy & wr_req) 
	begin
		wr_handshake_buffer <= 1'b1;		
	end
end
*/


/****************************************Submodule****************************************/

// Tag & V
assign way0_tag_r  		= way0_tagv_r[20:1];
assign way0_v_r 		= way0_tagv_r[0];

assign way1_tag_r  		= way1_tagv_r[20:1];
assign way1_v_r 		= way1_tagv_r[0];

assign way0_tagv_w = {way0_tag_w, way0_v_w};
assign way1_tagv_w = {way1_tag_w, way1_v_w};

assign way0_tag_w = request_tag;
assign way1_tag_w = request_tag;

assign way0_v_w = (refill_mode && ret_valid && ret_last); // 当访问cache的时候是refill mode的时候就说明该更新cache了，这时候一定是valid的
assign way1_v_w = (refill_mode && ret_valid && ret_last);

//assign way0_tagv_addr = (lookup_mode)? index : request_index;
//assign way1_tagv_addr = (lookup_mode)? index : request_index;
assign way0_tagv_addr = (cache_state_next == LOOKUP)? index : request_index;
assign way1_tagv_addr = (cache_state_next == LOOKUP)? index : request_index;

assign way0_tagv_we = (refill_mode)? (miss_replace_way == 1'b0) : 0; 
assign way1_tagv_we = (refill_mode)? (miss_replace_way == 1'b1) : 0;


tag_v_block_ram way0_tag_v(.addra(way0_tagv_addr)	,	
						   .clka(clk)				,
						   .dina (way0_tagv_w)		,
						   .douta(way0_tagv_r)		,
						   .ena(1'b1)			,
						   .wea({4{way0_tagv_we}})			
							);

tag_v_block_ram way1_tag_v(.addra(way0_tagv_addr)	,
						   .clka(clk)				,
						   .dina (way1_tagv_w)		,
						   .douta(way1_tagv_r)		,
						   .ena(1'b1)			,
						   .wea({4{way1_tagv_we}})			
							);

// D
assign way0_d_we 	= (hitstore_mode)? way0_hit :				
					  (refill_mode)? (miss_replace_way == 1'b0): 1'b0;
assign way1_d_we 	= (hitstore_mode)? way1_hit :				
					  (refill_mode)? (miss_replace_way == 1'b1): 1'b0;
// dirty写使能的三种情况：
//当cpu是写cache、且命中的时候会变成1
//当cpu是读cache，且miss的时候，refill之后会更新为0
//当cpu是写cache，且miss的时候，refill之后会更新为1
//因此写使能的条件，要么是op=1（无论miss与否都会dirty），或者是op=0且miss，这时候当refill的时候就会更新dirty

/*
assign way0_d_addr  = (lookup_mode)? index : request_index;
assign way1_d_addr  = (lookup_mode)? index : request_index;

assign way0_d_w 	= (lookup_mode)? op : request_op;
assign way1_d_w 	= (lookup_mode)? op : request_op;
*/
assign way0_d_addr  = request_index;
assign way1_d_addr  = request_index;

assign way0_d_w 	= request_op;
assign way1_d_w 	= request_op;

dirty_cache way0_d(.clk(clk)			,
				   .rst(~resetn)		,
				   .addr(way0_d_addr)	,
				   .we(way0_d_we)		,
				   .wdata(way0_d_w)		,
				   .rdata(way0_d_r)			
				   );

dirty_cache way1_d(.clk(clk)			,
				   .rst(~resetn)		,
				   .addr(way1_d_addr)	,
				   .we(way1_d_we)		,
				   .wdata(way1_d_w)		,
				   .rdata(way1_d_r)			
				   );

// Bank
wire 			way0_bank0_we_hit;
wire 			way0_bank1_we_hit;
wire 			way0_bank2_we_hit;
wire 			way0_bank3_we_hit;

wire 			way1_bank0_we_hit;
wire 			way1_bank1_we_hit;
wire 			way1_bank2_we_hit;
wire 			way1_bank3_we_hit;

wire [31:0]		wdata_from_axi;


assign way0_rdata = {way0_bank3_rdata, way0_bank2_rdata, way0_bank1_rdata, way0_bank0_rdata};
assign way1_rdata = {way1_bank3_rdata, way1_bank2_rdata, way1_bank1_rdata, way1_bank0_rdata};
/*
assign way0_bank0_we_hit = op && (way0_hit) && (offset[3:2] == 2'b00);
assign way0_bank1_we_hit = op && (way0_hit) && (offset[3:2] == 2'b01);
assign way0_bank2_we_hit = op && (way0_hit) && (offset[3:2] == 2'b10);
assign way0_bank3_we_hit = op && (way0_hit) && (offset[3:2] == 2'b11);

assign way1_bank0_we_hit = op && (way1_hit) && (offset[3:2] == 2'b00);
assign way1_bank1_we_hit = op && (way1_hit) && (offset[3:2] == 2'b01);
assign way1_bank2_we_hit = op && (way1_hit) && (offset[3:2] == 2'b10);
assign way1_bank3_we_hit = op && (way1_hit) && (offset[3:2] == 2'b11);
*/
assign way0_bank0_we_hit = request_op && (way0_hit) && (request_offset[3:2] == 2'b00);
assign way0_bank1_we_hit = request_op && (way0_hit) && (request_offset[3:2] == 2'b01);
assign way0_bank2_we_hit = request_op && (way0_hit) && (request_offset[3:2] == 2'b10);
assign way0_bank3_we_hit = request_op && (way0_hit) && (request_offset[3:2] == 2'b11);

assign way1_bank0_we_hit = request_op && (way1_hit) && (request_offset[3:2] == 2'b00);
assign way1_bank1_we_hit = request_op && (way1_hit) && (request_offset[3:2] == 2'b01);
assign way1_bank2_we_hit = request_op && (way1_hit) && (request_offset[3:2] == 2'b10);
assign way1_bank3_we_hit = request_op && (way1_hit) && (request_offset[3:2] == 2'b11);



assign way0_bank0_we = (hitstore_mode)? way0_bank0_we_hit :	// 由于 Refill的时候是将本路的4个bank全部换掉，因此we全部为1，下同
					   (refill_mode)  ? ((miss_replace_way == 1'b0) && (miss_word_counter == 2'b00)) : 1'b0 ; // ret_valid信号藏在 replace_mode里面，这里就没判断了

assign way0_bank1_we = (hitstore_mode)? way0_bank1_we_hit :
					   (refill_mode)  ? ((miss_replace_way == 1'b0) && (miss_word_counter == 2'b01)) : 1'b0 ;

assign way0_bank2_we = (hitstore_mode)? way0_bank2_we_hit :
					   (refill_mode)  ? ((miss_replace_way == 1'b0) && (miss_word_counter == 2'b10)) : 1'b0 ;

assign way0_bank3_we = (hitstore_mode)? way0_bank3_we_hit :
					   (refill_mode)  ? ((miss_replace_way == 1'b0) && (miss_word_counter == 2'b11)) : 1'b0 ;

assign way1_bank0_we = (hitstore_mode)? way1_bank0_we_hit :
					   (refill_mode)  ? ((miss_replace_way == 1'b1) && (miss_word_counter == 2'b00)) : 1'b0 ;

assign way1_bank1_we = (hitstore_mode)? way1_bank1_we_hit :
					   (refill_mode)  ? ((miss_replace_way == 1'b1) && (miss_word_counter == 2'b01)) : 1'b0 ;

assign way1_bank2_we = (hitstore_mode)? way1_bank2_we_hit :
					   (refill_mode)  ? ((miss_replace_way == 1'b1) && (miss_word_counter == 2'b10)) : 1'b0 ;

assign way1_bank3_we = (hitstore_mode)? way1_bank3_we_hit :
					   (refill_mode)  ? ((miss_replace_way == 1'b1) && (miss_word_counter == 2'b11)) : 1'b0 ;

/*
assign way0_bank0_wen = (way0_bank0_we) ? request_wstrb : 4'b0000;
assign way0_bank1_wen = (way0_bank1_we) ? request_wstrb : 4'b0000;
assign way0_bank2_wen = (way0_bank2_we) ? request_wstrb : 4'b0000;
assign way0_bank3_wen = (way0_bank3_we) ? request_wstrb : 4'b0000;

assign way1_bank0_wen = (way1_bank0_we) ? request_wstrb : 4'b0000;
assign way1_bank1_wen = (way1_bank1_we) ? request_wstrb : 4'b0000;
assign way1_bank2_wen = (way1_bank2_we) ? request_wstrb : 4'b0000;
assign way1_bank3_wen = (way1_bank3_we) ? request_wstrb : 4'b0000;
*/

assign way0_bank0_wen = (way0_bank0_we && request_op) 	? request_wstrb :
						(way0_bank0_we && (!request_op))? 4'b1111 : 4'b0000;
assign way0_bank1_wen = (way0_bank1_we && request_op) 	? request_wstrb :
						(way0_bank1_we && (!request_op))? 4'b1111 : 4'b0000;
assign way0_bank2_wen = (way0_bank2_we && request_op) 	? request_wstrb :
						(way0_bank2_we && (!request_op))? 4'b1111 : 4'b0000;
assign way0_bank3_wen = (way0_bank3_we && request_op) 	? request_wstrb :
						(way0_bank3_we && (!request_op))? 4'b1111 : 4'b0000;
assign way1_bank0_wen = (way1_bank0_we && request_op) 	? request_wstrb :
						(way1_bank0_we && (!request_op))? 4'b1111 : 4'b0000;
assign way1_bank1_wen = (way1_bank1_we && request_op) 	? request_wstrb :
						(way1_bank1_we && (!request_op))? 4'b1111 : 4'b0000;
assign way1_bank2_wen = (way1_bank2_we && request_op) 	? request_wstrb :
						(way1_bank2_we && (!request_op))? 4'b1111 : 4'b0000;
assign way1_bank3_wen = (way1_bank3_we && request_op) 	? request_wstrb :
						(way1_bank3_we && (!request_op))? 4'b1111 : 4'b0000;





//assign way0_bank_addr = (lookup_mode)? index : request_index;
//assign way1_bank_addr = (lookup_mode)? index : request_index;
assign way0_bank_addr = (cache_state_next == LOOKUP)? index : request_index;
assign way1_bank_addr = (cache_state_next == LOOKUP)? index : request_index;

/*
assign way0_bank_wdata = (hitstore_mode)? wdata  : 
						 (refill_mode && request_op == 1'b0)? ret_data  :
						 (refill_mode && request_op == 1'b1)? 			: 0;

assign way1_bank_wdata = (hitstore_mode)? wdata  : 
						 (refill_mode)? ret_data : 0;
*/
assign bank0_wdata = (hitstore_mode)? request_wdata : // 写入Data的数据有3种情况: 1.hit的时候直接写入wdata；2.miss的时候，如果是cpu是读cache，那么直接将axi获得的数据写进去
					 (refill_mode && request_op && (request_offset[3:2] == 2'b00))? request_wdata : ret_data; 
// 3.miss的时候，如果cpu是写cache，那么需要检查offset，将除了offset对应的data bank里面写入wdata外，其余部分一样写入ret_data

assign bank1_wdata = (hitstore_mode)? request_wdata :
					 (refill_mode && request_op && (request_offset[3:2] == 2'b01))? request_wdata : ret_data; 

assign bank2_wdata = (hitstore_mode)? request_wdata :
				     (refill_mode && request_op && (request_offset[3:2] == 2'b10))? request_wdata : ret_data; 

assign bank3_wdata = (hitstore_mode)? request_wdata :
					 (refill_mode && request_op && (request_offset[3:2] == 2'b11))? request_wdata : ret_data; 


data_block_ram way0_bank0(.addra(way0_bank_addr)	,
						  .clka(clk)				,
					  	  .dina(bank0_wdata)	,
					  	  .douta(way0_bank0_rdata)	,
					  	  .ena(1'b1)				,
					  	  .wea(way0_bank0_wen)					
						 );

data_block_ram way0_bank1(.addra(way0_bank_addr)	,
						  .clka(clk)				,
					  	  .dina(bank1_wdata)	,
						  .douta(way0_bank1_rdata)	,
					  	  .ena(1'b1)				,
					  	  .wea(way0_bank1_wen)
						 );

data_block_ram way0_bank2(.addra(way0_bank_addr)	,
						  .clka(clk)				,
					  	  .dina(bank2_wdata)	,
						  .douta(way0_bank2_rdata)	,
						  .ena(1'b1)				,
					  	  .wea(way0_bank2_wen)
						 );

data_block_ram way0_bank3(.addra(way0_bank_addr)	,
						  .clka(clk)				,
					  	  .dina(bank3_wdata)	,
						  .douta(way0_bank3_rdata)	,
						  .ena(1'b1)				,
					  	  .wea(way0_bank3_wen)
						 );

					 


data_block_ram way1_bank0(.addra(way1_bank_addr)	,
						  .clka(clk)				,
					  	  .dina(bank0_wdata)	,
						  .douta(way1_bank0_rdata)	,
						  .ena(1'b1)				,
					  	  .wea(way1_bank0_wen)
						 );

data_block_ram way1_bank1(.addra(way1_bank_addr)	,
						  .clka(clk)				,
					  	  .dina(bank1_wdata)	,
						  .douta(way1_bank1_rdata)	,
  						  .ena(1'b1)				,
					  	  .wea(way1_bank1_wen)
						 );

data_block_ram way1_bank2(.addra(way1_bank_addr)	,
						  .clka(clk)				,
					  	  .dina(bank2_wdata)	,
						  .douta(way1_bank2_rdata)	,
						  .ena(1'b1)				,
					  	  .wea(way1_bank2_wen)
						 );

data_block_ram way1_bank3(.addra(way1_bank_addr)	,
						  .clka(clk)				,
					  	  .dina(bank3_wdata)	,
						  .douta(way1_bank3_rdata)	,
						  .ena(1'b1)				,
					  	  .wea(way1_bank3_wen)
						 );




endmodule


module dirty_cache(
	input			clk,
	input 			rst,
	input  [7:0]	addr, 	// read or write address
	input 			we,
	input 			wdata,
	output 			rdata
	);

reg [255:0] dirty;


// write
always @(posedge clk) 
begin
	if (rst) 
	begin
		// reset
		dirty <= 256'b0;	
	end
	else if (we) 
	begin
		dirty[addr] <= wdata;
	end
end


// read

assign rdata = dirty[addr];
endmodule