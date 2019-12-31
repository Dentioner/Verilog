#### myCPU-lab16文件简述

|<font face="微软雅黑">文件名</font>|<font face="微软雅黑">功能</font>|
|:-:|:-:|
|<font face="consolas">alu.v</font>|CPU的alu模块|
|<font face="consolas">cache.v</font>|CPU的cache模块|
|<font face="consolas">cp0.v</font>|CPU的0号协处理器寄存器模块|
|<font face="consolas">cpu_axi_interface.v</font>|类SRAM接口的CPU接入AXI总线的转接桥|
|<font face="consolas">divide_controller.v</font>|CPU的除法器控制器|
|<font face="consolas">EXE_stage.v</font>|CPU的流水线执行级|
|<font face="consolas">ID_stage.v</font>|CPU的流水线译码级|
|<font face="consolas">IF_stage.v</font>|CPU的流水线取指级|
|<font face="consolas">MEM_stage.v</font>|CPU的流水线访存级|
|<font face="consolas">mutiplier.v</font>|CPU的乘法器|
|<font face="consolas">mycpu.h</font>|头文件，用于总线宽度的宏定义|
|<font face="consolas">mycpu_top.v</font>|CPU的顶层模块，包含5级流水模块以及转接桥的集成|
|<font face="consolas">regfile.v</font>|CPU的寄存器堆|
|<font face="consolas">soc_axi_lite_top.bit</font>|上板的比特流文件|
|<font face="consolas">tlb.v</font>|TLB模块，用于将mapped虚拟地址区段映射为实地址|
|<font face="consolas">tools.v</font>|译码器模块，用于ID模块中的译码过程|
|<font face="consolas">WB_stage.v</font>|CPU的流水线写回级|


