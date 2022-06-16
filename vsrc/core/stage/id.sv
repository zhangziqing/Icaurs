`include "include/width_param.sv"

module InstDecode(
    input [`INST_WITDH - 1]     inst,
    input [`ADDR_WIDTH - 1]     pc,

    //register interface

    /*
        rs : regRead1;
        rt : regRead2;
        rd : regWrite
    */
    output                      rs_en,
    output  [`REG_WIDTH - 1]    rs_addr,
    input   [`DATA_WIDTH - 1]   rs_data,
    output                      rt_en,
    output  [`REG_WIDTH - 1]    rt_addr,
    input   [`DATA_WIDTH - 1]   rt_data,
    output                      rd_en,
    output  [`REG_WIDTH - 1]    rd_addr,
    output  [`DATA_WIDTH - 1]   rd_data,


    //stage interface
    id_stage.o                 id_info,

    //branch info
    branch_info.o               branch_info,
)

endmodule



