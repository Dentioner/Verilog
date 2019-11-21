`ifndef MYCPU_H
    `define MYCPU_H

    //`define BR_BUS_WD       32
    `define BR_BUS_WD       33
    `define FS_TO_DS_BUS_WD 65
    `define DS_TO_ES_BUS_WD 161
    `define ES_TO_MS_BUS_WD 121
    `define MS_TO_WS_BUS_WD 90
    `define WS_TO_RF_BUS_WD 38

    `define EXECEPTION_BUS_WD 34

    `define EXECEPTION_TYPE 7

    `define STATUS_ADDR   96  //1100_000
    `define CAUSE_ADDR	  104 //1101_000
    `define EPC_ADDR	  112 //1110_000
    `define COMPARE_ADDR  88  //1011_000   
    `define COUNT_ADDR    72  //1001_000
    `define BADVADDR_ADDR 64  //1000_000
`endif