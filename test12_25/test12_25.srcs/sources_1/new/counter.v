`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/25 20:42:51
// Design Name: 
// Module Name: counter
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
// Create Date: 2018/12/23 20:26:35
// Design Name: 
// Module Name: main
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
module main(cpu_in,w,Clock,Reset,display_out);//Data, Reset, w, Clock, F, Rx, Ry, Done, BusWires);
    input w, Clock, Reset;
    input [14:0] cpu_in;
    output wire [10:0] display_out;
    wire [1:0]F = cpu_in[2:1];
    wire [1:0]Rx = cpu_in[4:3];
    wire [1:0]Ry = cpu_in[6:5];
    wire [7:0]Data = cpu_in[14:7];
    wire Sw = cpu_in[0];         //显示管的开关
    wire Done;
    wire [7:0] BusWires;

    reg[1:0] current_state=0;
    reg[1:0] next_state=0;
    reg[19:0] count=0;
    reg w_state=0;
    wire sig;
    wire W;
    proc m2(Data, Reset, W, Clock, F, Rx, Ry, Done, BusWires);
    display_7seg m3(Clock,Sw,BusWires,display_out);
    // 0 for up   1 for up_wait  2 for down 3 for down_wait
    always@(posedge Clock)begin
    if(Reset)begin
       current_state <= 0;
    end
    else
       current_state <= next_state;
    end 
    always@(posedge Clock)begin
    case(current_state)
    2'd0:next_state <= w?2'd1:2'd0;
    2'd1:next_state <= (sig == 0)?2'd1:
                       (w   == 1)?2'd2:
                       2'd0;
    2'd2:next_state <= (w == 0)?2'd3:2'd2;
    2'd3:next_state <= (sig == 0)?2'd3:
                       (w   == 0)?2'd0:
                       2'd2;
    default;
    endcase
 end

    always@(posedge Clock)begin
    if((current_state == 0) || (current_state == 2))
        count <= 0;
    else 
        count <= count + 1'b1;
    end

    always@(*)begin
    if(Reset)
        w_state = 0;
    else if((current_state == 1)&&(sig)&&(w)) 
        w_state = 1;
     else if ((current_state == 3)&&(sig)&&(~w))   
        w_state = 0;
     end
assign  sig = (count == 20'hfffff );
assign  W = w_state;   

  
endmodule

module proc(Data, Reset, w, Clock, F, Rx, Ry, Done, BusWires);
    input [7:0] Data;               //输入的八位数据
    input Reset, w, Clock;          //复位，开关，时钟信号
    input [1:0]F, Rx, Ry;           //输入参数：操作类型，寄存器A，寄存器B
    output wire [7:0]BusWires;     //总线数据
    output Done;                    //表示操作完成
    reg [0:3] Rin=0, Rout=0;             //四个寄存器的输入输出开关
    reg [7:0] Sum=0;                   //加减输出结果寄存器
    wire Clear, Addsub, Extern, Ain, Gin, Gout, FRin; //清零，加or减，
    wire [1:0] Count;               //计数
    wire [0:3] T, I, Xreg, Y;       //缓存译码结果
    wire [7:0] R0, R1, R2, R3, A, G;//寄存器
    wire [1:6] Func, FuncReg;
    integer k;
    upcount counter(Clear, Clock, Count);
    dec2to4 decT(Count, 1'b1,T);
    assign Clear=Reset | Done | (~w&T[0]);
    assign Func={F,Rx,Ry};
    assign FRin= w & T[0];

    regn functionreg(Func,FRin,Clock,FuncReg);
      defparam functionreg.n=6;
    dec2to4 decI(FuncReg[1:2],1'b1,I);
    dec2to4 decX(FuncReg[3:4],1'b1,Xreg);
    dec2to4 decY(FuncReg[5:6],1'b1,Y);

    assign Extern = I[0] & T[1];
    assign Done = ((I[0] | I[1]) & T[1]) | ((I[2] | I[3]) & T[3]);
    assign Ain = (I[2] | I[3]) & T[1];
    assign Gin = (I[2] | I[3]) & T[2];
    assign Gout = (I[2] | I[3]) & T[3];
    assign AddSub = I[3];

    
    always @(I,T,Xreg,Y)
      for (k=0;k<4;k=k+1)
      begin
        Rin[k] = ((I[0] | I[1]) & T[1] & Xreg[k])|((I[2] | I[3]) & T[3] & Xreg[k]);
        Rout[k] = (I[1] & T[1] & Y[k]) | ((I[2] | I[3]) & ((T[1] & Xreg[k]) | (T[2] & Y[k])));
      end
        
     trin tri_ext(Data, Extern, BusWires);
     regn reg_0(BusWires, Rin[0], Clock, R0);
     regn reg_1(BusWires, Rin[1], Clock, R1);
     regn reg_2(BusWires, Rin[2], Clock, R2);
     regn reg_3(BusWires, Rin[3], Clock, R3);

     trin tri_0(R0, Rout[0], BusWires);
     trin tri_1(R1, Rout[1], BusWires);
     trin tri_2(R2, Rout[2], BusWires);
     trin tri_3(R3, Rout[3], BusWires);
     regn reg_A(BusWires, Ain, Clock, A);
     
     always @(AddSub, A, BusWires)
     begin
        if(!AddSub)
            Sum=A+BusWires;
        else
            Sum=A-BusWires;
    end            
     regn reg_G(Sum, Gin, Clock, G);
     trin tri_G(G, Gout, BusWires);    
endmodule

module regn (R, L, Clock, Q);    //若L=1则从n位输入端载入数据，否则保持原样
    parameter n=8;
    input [n-1:0] R;
    input L, Clock;
    output reg[n-1:0] Q;
    
    always @(posedge Clock)
    begin
    if(L)
        Q<=R;
    else
        Q<=Q;    
    end
endmodule        
        
module trin(Y,E,F);              //若E=1则输出F=Y，否则输出置于高阻态
    input [7:0]Y;
    input E;
    output wire [7:0]F;
    
    assign F=(E)?Y:8'bz;
    
 endmodule           

module upcount (Clear, Clock, Q);//计数器，每次+1或者清零
    input Clear, Clock;
    output reg [0:1]Q;
    always @(posedge Clock or Clear)
    begin
    if(Clear)
        Q<=0;
    else
        Q<=Q+1;
    end
endmodule    

module dec2to4(W, En, Y);        //2-4译码器，En是使能输入
    input [1:0]W;
    input En;
    output reg[0:3]Y;
    
    always@(W, En)
    begin
        case({En,W})
            3'b100:Y=4'b1000;
            3'b101:Y=4'b0100;
            3'b110:Y=4'b0010;
            3'b111:Y=4'b0001;
            default:Y<=4'b0000;
        endcase
    end
endmodule    

module display_7seg(CLK,Sw_in,BusWire,Result);
   input CLK,Sw_in;
   input [7:0] BusWire;
   output reg [10:0] Result;
   reg [19:0] count=0;
   reg [1:0] sel=0;
   parameter times=50000;
   always@(posedge CLK)
    begin
        if(Sw_in==0) 
            Result<=11'b1111_1111111;
        else
            begin
                if(sel==0)
                begin
                    case (BusWire[3:0])
                    0:Result<=11'b1110_0000001;
                    1:Result<=11'b1110_1001111;
                    2:Result<=11'b1110_0010010;
                    3:Result<=11'b1110_0000110;
                    4:Result<=11'b1110_0000001;
                    5:Result<=11'b1110_0100100;
                    6:Result<=11'b1110_0100000;
                    7:Result<=11'b1110_0001111;
                    8:Result<=11'b1110_0000000;
                    9:Result<=11'b1110_0000100;
                    10:Result<=11'b1110_0001000;
                    11:Result<=11'b1110_1100000;
                    12:Result<=11'b1110_0110001;
                    13:Result<=11'b1110_1000010;
                    14:Result<=11'b1110_0110000;
                    15:Result<=11'b1110_0111000;
                    default: Result<=11'b1110_1111111;
                    endcase
                end
             else    
                 begin
                     case(BusWire[7:4])
                     0:Result<=11'b1101_0000001;
                     1:Result<=11'b1101_1001111;
                     2:Result<=11'b1101_0010010;
                     3:Result<=11'b1101_0000110;
                     4:Result<=11'b1101_0000001;
                     5:Result<=11'b1101_0100100;
                     6:Result<=11'b1101_0100000;
                     7:Result<=11'b1101_0001111;
                     8:Result<=11'b1101_0000000;
                     9:Result<=11'b1101_0000100;
                     10:Result<=11'b1101_0001000;
                     11:Result<=11'b1101_1100000;
                     12:Result<=11'b1101_0110001;
                     13:Result<=11'b1101_1000010;
                     14:Result<=11'b1101_0110000;
                     15:Result<=11'b1101_0111000;
                     default: Result<=11'b1101_1111111;             
                     endcase
                  end
             end
        end
   always@(posedge CLK)
   begin
     count<=count+1'b1;
     if(count==times)
        begin
        count<=0;
        sel<=sel+1;
        end
     if(sel==2)
        begin
        sel<=0;
        end
   end
   
endmodule
