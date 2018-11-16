`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/16 20:29:17
// Design Name: 
// Module Name: repeater
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module repeater();

integer count;

initial
begin
    count = 0;
    repeat(128)
    begin
        $display("count = %d\n", count);
        count = count + 1;
        
    end
end

endmodule
