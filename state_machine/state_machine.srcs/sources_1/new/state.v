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


module state(A, B, clk, out);
input A, B, clk;
output wire out;

reg [3:0] state = 3'b000;
reg re_out;
wire [1:0]in;
assign in = {A,B};
assign out = re_out;


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
     //$display("0000");
    //ok
        
    if(state == S0)
    begin
        $display("111111");
        if (in == in3)
        begin
            state <= S1;
            $display("%d", state);
            //re_out <= 0;
            
        end
        else if (in == in0)
        begin
            state <= S5;
            $display("%d", state);
            //re_out <= 1;
        end
        else
        begin
            state <= S0;
            $display ("The state is %d and the input is %d, this is not a valid input.\n", state, in);//bugs
        end
    end
    
    
    else if (state == S1)
    begin
     $display("111111");
        if (in == in2)
            begin
                state <= S4;
                $display("%d", state);
               //re_out <= 1;
                
            end
            else if (in == in1)
            begin
                state <= S3;
                $display("%d", state);
                //re_out <= 0;
            end
            else
            begin
            state <= S1;
            $display ("The state is %d and the input is %d, this is not a valid input.\n", state, in);//bugs
            end
    end
    
    else if (state == S2)
    
       begin
        $display("111111");
           if (in == in0)
               begin
                   state <= S1;
                   $display("%d", state);
                   //re_out <= 1;
                   
               end
               else if (in == in2)
               begin
                   state <= S5;
                   $display("%d", state);
                  // re_out <= 0;
               end
               else
               begin
               state <= S2;
               $display ("The state is %d and the input is %d, this is not a valid input.\n", state, in);//bugs
               end
       end
       
    else if (state == S3)
          begin
              if (in == in0)
                  begin
                      state <= S2;
                      $display("%d", state);
                     //re_out <= 0;
                      
                  end
                  else if (in == in2)
                  begin
                      state <= S4;
                      $display("%d", state);
                      //re_out <= 1;
                  end
                  else
                  begin
                  state <= S3;
                  $display ("The state is %d and the input is %d, this is not a valid input.\n", state, in);//bugs
                    end
          end
       
    else if (state == S4)
             begin
                 if (in == in2)
                     begin
                         state <= S3;
                         $display("%d", state);
                        // re_out <= 0;
                         
                     end
                     else if (in == in1)
                     begin
                         state <= S5;
                         $display("%d", state);
                         //re_out <= 1;
                     end
                     else
                     begin
                     state <= S4;
                     $display ("The state is %d and the input is %d, this is not a valid input.\n", state, in);//bugs
                    end
             end
       
    else if (state == S5)
                begin
                    if (in == in0)
                        begin
                            state <= S5;
                            $display("iii%d", state);
                           // re_out <= 0;
                            
                        end
                        else if (in == in2)
                        begin
                            state <= S0;
                            $display("%d", state);
                           // re_out <= 1;
                        end
                        else
                        begin
                        state <= S5;
                        $display ("The state is %d and the input is %d, this is not a valid input.\n", state, in);//bugs
                        end
                end
       
end

always@(state or in)
begin
    if(state == S0)
    begin
            if (in == in3)               
                re_out <= 0;
                
          
            else if (in == in0)
          
               
                re_out <= 1;
           
            else
            re_out <= 0;//bugs
            
    end
    
    else if(state == S1)
        begin
                if (in == in1)               
                    re_out<= 0;
                    
              
                else if (in == in2)
              
                   
                    re_out <= 1;
               
                else
                re_out <= 0;//bugs
                
        end
        
    else if(state == S2)
            begin
                    if (in == in2)               
                        re_out <= 0;
                        
                  
                    else if (in == in0)
                  
                       
                        re_out <= 1;
                   
                    else
                    re_out <= 0;//bugs
                    
            end
            
    else if(state == S3)
                begin
                        if (in == in2)               
                            re_out <= 1;
                            
                      
                        else if (in == in0)
                      
                           
                            re_out <= 0;
                       
                        else
                        re_out <= 0;//bugs
                        
                end
                
    else if(state == S4)
                    begin
                            if (in == in1)               
                                re_out <= 1;
                                
                          
                            else if (in == in2)
                          
                               
                                re_out <= 0;
                           
                            else
                            re_out <= 0;//bugs
                            
                    end
                    
    else if(state == S5)
                begin
                        if (in == in2)               
                            re_out <= 1;
                            
                      
                        else if (in == in0)
                      
                           
                            re_out <= 0;
                       
                        else
                        re_out <= 0;//bugs
                        
                end
    //else bug
                
        
end

endmodule
