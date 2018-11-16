`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/13 10:11:30
// Design Name: 
// Module Name: state
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


module state(A, B, clk, reset,out, bug);
input A, B, clk, reset;
output reg out, bug;

reg [3:0] state;

wire [1:0]in;
assign in = {A,B};



parameter S0 = 3'b000;
parameter S1 = 3'b001;
parameter S2 = 3'b010;
parameter S3 = 3'b011;
parameter S4 = 3'b100;
parameter S5 = 3'b101;
//parameter S6 = 3'b110;
//parameter S7 = 3'b111;

parameter in0 = 2'b00;
parameter in1 = 2'b01;
parameter in2 = 2'b10;
parameter in3 = 2'b11;

always@(posedge clk)
begin
    if(reset == 1)
        state = S0;
    else
    begin
        case(state)
            S0:
                begin
                    if (in == in3)
                    begin
                        
                        bug = 0;
                        state = S1;                       
                    end
                    else if (in == in0)
                    begin
                        
                        bug = 0;
                        state = S5;
                    end
                    else
                    begin
                        $display("Here!\n");
                        bug = 1;
                        state = S0;
                    end
                end
            S1:
                begin
                    if (in == in1)
                    begin

                        bug = 0; 
                        state = S3;                      
                    end
                    else if (in == in2)
                    begin
                        
                        bug = 0;
                        state = S4;
                    end
                    else
                    begin
                         $display("Here!\n");
                        bug = 1;
                        state = S1;
                    end
                end
            S2:
                begin
                    if (in == in2)
                    begin
                        
                        bug = 0; 
                        state = S5;                      
                    end
                    else if (in == in0)
                    begin
                        
                        bug = 0;
                        state = S1;
                    end
                    else
                    begin
                         $display("Here!\n");
                        bug = 1;
                        state = S2;
                    end
                end
            S3:
                begin
                    if (in == in0)
                    begin
                        
                        bug = 0;   
                        state = S2;                    
                    end
                    else if (in == in2)
                    begin
                        
                        bug = 0;
                        state = S4;
                    end
                    else
                    begin
                         $display("Here!\n");
                        bug = 1;
                        state = S3;
                    end
                end
            S4:
                begin
                    if (in == in2)
                    begin
                        
                        bug = 0;   
                        state = S3;                    
                    end
                    else if (in == in1)
                    begin
                       
                        bug = 0;
                        state = S5;
                    end
                    else
                    begin
                         $display("Here!\n");
                        bug = 1;
                        state = S4;
                    end
                end
            S5:
                begin
                    if (in == in0)
                    begin
                        
                        bug = 0;   
                        state = S5;                    
                    end
                    else if (in == in2)
                    begin
                        
                        bug = 0;
                        state = S0;
                    end
                    else
                    begin
                         $display("Here!\n");
                        bug = 1;
                        state = S5;
                    end
                end

        endcase
    end
        
end

always@(state or in)
begin
    if(reset == 1)
        state = S0;
    else
    begin
        case(state)
            S0:
                begin
                    if (in == in3)
                    begin
                        out = 0;
                      
                    end
                    else if (in == in0)
                    begin
                        out = 1;

                    end
                    else
                    begin
                        out = 0;

                    end
                end
            S1:
                begin
                    if (in == in1)
                    begin
                        out = 0;
                     
                    end
                    else if (in == in2)
                    begin
                        out = 1;
          
                    end
                    else
                    begin
                        out = 0;
                   
                    end
                end
            S2:
                begin
                    if (in == in2)
                    begin
                        out = 0;
                                 
                    end
                    else if (in == in0)
                    begin
                        out = 1;
                     
                    end
                    else
                    begin
                        out = 0;
                     
                    end
                end
            S3:
                begin
                    if (in == in0)
                    begin
                        out = 0;
                                          
                    end
                    else if (in == in2)
                    begin
                        out = 1;
                      
                    end
                    else
                    begin
                        out = 0;
                    
                    end
                end
            S4:
                begin
                    if (in == in2)
                    begin
                        out = 0;
                                       
                    end
                    else if (in == in1)
                    begin
                        out = 1;
                   
                    end
                    else
                    begin
                        out = 0;
                  
                    end
                end
            S5:
                begin
                    if (in == in0)
                    begin
                        out = 0;
                                        
                    end
                    else if (in == in2)
                    begin
                        out = 1;
                   
                    end
                    else
                    begin
                        out = 0;
                   
                    end
                end

        endcase
    end
        
end

endmodule
