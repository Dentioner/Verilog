-makelib ies_lib/xil_defaultlib -sv \
  "D:/software/vivado/Vivado/2018.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/software/vivado/Vivado/2018.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/software/vivado/Vivado/2018.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/blk_mem_gen_v8_4_1 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../../../rtl/xilinx_ip/data_ram/sim/data_ram.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

