#### myCPU-lab5文件简述

|<font face="微软雅黑">文件名</font>|<font face="微软雅黑">功能</font>|
|:-:|:-:|
|<font face="consolas">alu.v</font>|CPU的alu模块|
|<font face="consolas">EXE_stage.v</font>|CPU的流水线执行级|
|<font face="consolas">ID_stage.v</font>|CPU的流水线译码级|
|<font face="consolas">IF_stage.v</font>|CPU的流水线取指级|
|<font face="consolas">MEM_stage.v</font>|CPU的流水线访存级|
|<font face="consolas">mycpu.h</font>|头文件，用于总线宽度的宏定义|
|<font face="consolas">mycpu_top.v</font>|CPU的顶层模块，下级模块为5级流水的各个模块|
|<font face="consolas">regfile.v</font>|CPU的寄存器堆|
|<font face="consolas">tools.v</font>|译码器模块，用于ID模块中的译码过程|
|<font face="consolas">WB_stage.v</font>|CPU的流水线写回级|


