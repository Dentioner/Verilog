`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/04 10:05:49
// Design Name: 
// Module Name: FIFO
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


module FIFO(Data_In, Data_Out, input_valid, output_enable, clk);
input input_valid, output_enable, clk;
input [3:0]Data_In;
output reg [7:0]Data_Out;
reg input_enable = 1'b1;
reg output_valid = 1'b0;
reg[7:0] buffer[7:0];
reg[15:0]full = 16'b0000000000000000;
always @ (posedge clk)
begin
   //no reset
    
        case(full)
            16'b0000000000000000: 
                if (input_valid && input_enable)
                begin
                    buffer[0][3:0] <= Data_In;
                    full[0] <= 1'b1;
                end
                else if (output_valid && output_enable)
                begin
                    $display("empty\n");
                end
            16'b0000000000000001: 
                if (input_valid && input_enable) 
                begin
                    buffer[0][7:4] <= Data_In;
                    full[1] <= 1'b1;
                end
                else if (output_valid && output_enable)
                begin
                    //$display("empty\n");
                    full[0] <= 1'b0;
                end
            16'b0000000000000011: 
               if (input_valid && input_enable)
               begin
                   buffer[1][3:0] <= Data_In;
                   full[2] <= 1'b1;
               end
               else if (output_valid && output_enable)
               begin
                   Data_Out <= buffer[7][7:0];
                   buffer[7][7:0] <= 8'b00000000;
                   full[1:0] <= 2'b00;
               end                    
            16'b0000000000000111: 
               if(input_valid && input_enable)
               begin
                   buffer[1][7:4] <= Data_In;
                   full[3] <= 1'b1;
               end
               else if (output_valid && output_enable)
                  begin
                      //buffer[1][7:0] <= 8'b00000000;
                      full[2] <= 1'b0;
                  end     
            16'b0000000000001111: 
              if(input_valid && input_enable)
              begin
                  buffer[2][3:0] <= Data_In;
                  full[4] <= 1'b1;
              end
              else if (output_valid && output_enable)
             begin
                 Data_Out <= buffer[6][7:0];
                 buffer[6][7:0] <= 8'b00000000;
                 full[3:2] <= 2'b00;
             end                     
            16'b0000000000011111: 
              if (input_valid && input_enable)
              begin
                  buffer[2][7:4] <= Data_In;
                  full[5] <= 1'b1;
              end
              else if (output_valid && output_enable)
               begin
                   //Data_Out <= buffer[1][7:0];
                   //buffer[1][7:0] <= 8'b00000000;
                   full[4] <= 1'b0;
               end 
            16'b0000000000111111: 
                if (input_valid && input_enable)
                begin
                    buffer[3][3:0] <= Data_In;
                    full[6] <= 1'b1;
                end
                else if (output_valid && output_enable)
                 begin
                     Data_Out <= buffer[5][7:0];
                     buffer[5][7:0] <= 8'b00000000;
                     full[5:4] <= 2'b00;
                 end                     
           16'b0000000001111111: 
                if(input_valid && input_enable)
                begin
                    buffer[3][7:4] <= Data_In;
                    full[7] <= 1'b1;
                end
                else if (output_valid && output_enable)
                 begin
                     //Data_Out <= buffer[2][7:0];
                     //buffer[2][7:0] <= 8'b00000000;
                     full[6] <= 1'b0;
                 end 
            16'b0000000011111111: 
                if(input_valid && input_enable)
                begin
                    buffer[4][3:0] <= Data_In;
                    full[8] <= 1'b1;
                end
                else if (output_valid && output_enable)
                 begin
                     Data_Out <= buffer[4][7:0];
                     buffer[4][7:0] <= 8'b00000000;
                     full[7:6] <= 2'b00;
                 end                      
           16'b0000000111111111: 
                if(input_valid && input_enable)
                begin
                    buffer[4][7:4] <= Data_In;
                    full[9] <= 1'b1;
                end
                else if(output_valid && output_enable)
                begin
                     //Data_Out <= buffer[3][7:0];
                     //buffer[3][7:0] <= 8'b00000000;
                     full[8] <= 1'b0;
                 end 
            16'b0000001111111111: 
                if(input_valid && input_enable)
                begin
                    buffer[5][3:0] <= Data_In;
                    full[10] <= 1'b1;
                end
                else if (output_valid && output_enable)
                 begin
                     Data_Out <= buffer[3][7:0];
                     buffer[3][7:0] <= 8'b00000000;
                     full[9:8] <= 2'b00;
                 end                     
           16'b0000011111111111: 
                if(input_valid && input_enable)
                begin
                    buffer[5][7:4] <= Data_In;
                    full[11] <= 1'b1;
                end
                else if (output_valid && output_enable)
                 begin
                     //Data_Out <= buffer[4][7:0];
                     //buffer[4][7:0] <= 8'b00000000;
                     full[10] <= 1'b0;
                 end
        16'b0000111111111111: 
             if(input_valid && input_enable)
                begin
                    buffer[6][3:0] <= Data_In;
                    full[12] <= 1'b1;
                end
             else if (output_valid && output_enable)
             begin
                 Data_Out <= buffer[2][7:0];
                 buffer[2][7:0] <= 8'b00000000;
                 full[11:10] <= 2'b00;
             end                       
       16'b0001111111111111: 
                if(input_valid && input_enable)
                begin
                    buffer[6][7:4] <= Data_In;
                    full[13] <= 1'b1;
                end
                else if (output_valid && output_enable)
                 begin
                     //Data_Out <= buffer[5][7:0];
                     //buffer[5][7:0] <= 8'b00000000;
                     full[12] <= 1'b0;
                 end
    16'b0011111111111111: 
                if(input_valid && input_enable)
                begin
                    buffer[7][3:0] <= Data_In;
                    full[14] <= 1'b1;
                end
                else if (output_valid && output_enable)
                 begin
                     Data_Out <= buffer[1][7:0];
                     buffer[1][7:0] <= 8'b00000000;
                     full[13:12] <= 2'b00;
                 end                    
       16'b0111111111111111: 
                if(input_valid && input_enable)
                begin
                    buffer[7][7:4] <= Data_In;
                    full[15] <= 1'b1;
                end
                else if (output_valid && output_enable)
                 begin
                     //Data_Out <= buffer[6][7:0];
                     //buffer[6][7:0] <= 8'b00000000;
                     full[14] <= 1'b0;
                 end
        16'b1111111111111111:
              if(input_valid && input_enable)
                begin
                    $display("full\n");
                end
            else if (output_valid && output_enable)
             begin
                 Data_Out <= buffer[0][7:0];
                 buffer[0][7:0] <= 8'b00000000;
                 full[15:14] <= 2'b00;
             end  
    endcase
end
always @*
begin
    if (full == 16'b1111111111111111)
        begin
        output_valid = 1'b1;
        input_enable = 1'b0;
        end
    if (full == 16'b0000000000000000)
        begin
        input_enable = 1'b1;
        output_valid = 1'b0;
        end
end
endmodule
