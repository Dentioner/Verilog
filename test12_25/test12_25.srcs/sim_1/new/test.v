`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/25 20:52:32
// Design Name: 
// Module Name: test
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/23 23:23:15
// Design Name: 
// Module Name: test
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


module test();
reg w, Clock, Reset;
reg [14:0] cpu_in;
wire [10:0] display_out;
initial
    begin
    Clock = 1'b0;
    Reset = 1'b1;
    w = 1'b0;
    cpu_in=15'b00000000_00_00_00_1;
    #10 Reset = 1'b0;
    cpu_in=15'b00000001_00_00_00_1;
    w = 1'b1;
    #30000000
    w = 1'b0;
    #50000000
    cpu_in=15'b00000001_00_01_00_1;
    w = 1'b1;
    #30000000
    w = 1'b0;
    #50000000
    cpu_in=15'b00000000_00_01_10_1;
    w = 1'b1;
    #30000000
    w = 1'b0;
    #50000000
    cpu_in=15'b00000000_00_00_00_1;
    end
    always #10 Clock=~Clock;
main m1(cpu_in,w,Clock,Reset,display_out);
endmodule
