module regfile(
    input         clk,
    // READ PORT 1
    input  [ 4:0] raddr1,
    output [31:0] rdata1,
    // READ PORT 2
    input  [ 4:0] raddr2,
    output [31:0] rdata2,
    // WRITE PORT
    input  [ 3:0] wen,       //write enable, HIGH valid
    input  [ 4:0] waddr,
    input  [31:0] wdata
);
reg [31:0] rf[31:0];

//WRITE
/*always @(posedge clk) begin
    if (we) rf[waddr]<= wdata;
end*/

always @(posedge clk) 
begin
    if(wen[0] || wen[1] || wen[2] || wen[3])
    begin
        rf[waddr][ 7: 0] <= wen[0]? wdata[ 7: 0] : rf[waddr][ 7: 0];
        rf[waddr][15: 8] <= wen[1]? wdata[15: 8] : rf[waddr][15: 8];
        rf[waddr][23:16] <= wen[2]? wdata[23:16] : rf[waddr][23:16];
        rf[waddr][31:24] <= wen[3]? wdata[31:24] : rf[waddr][31:24];        
    end
end

//READ OUT 1
assign rdata1 = (raddr1==5'b0) ? 32'b0 : rf[raddr1];

//READ OUT 2
assign rdata2 = (raddr2==5'b0) ? 32'b0 : rf[raddr2];

endmodule