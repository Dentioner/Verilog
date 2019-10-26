`ifndef MYCPU_H
    `define MYCPU_H

    //`define BR_BUS_WD       32
    `define BR_BUS_WD       33
    `define FS_TO_DS_BUS_WD 64
    `define DS_TO_ES_BUS_WD 156
    `define ES_TO_MS_BUS_WD 114
    `define MS_TO_WS_BUS_WD 83
    `define WS_TO_RF_BUS_WD 38

    `define EXECEPTION_BUS_WD 33

    `define STATUS_ADDR 96  //1100_000
    `define CAUSE_ADDR	104 //1101_000
    `define EPC_ADDR	112 //1110_000
     
`endif