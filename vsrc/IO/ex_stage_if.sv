`include "vsrc/include/width_param.sv"

interface ex_stage_if;
logic [`INST_WIDTH - 1:0] inst;
logic [`ADDR_WIDTH - 1:0] pc;
logic [`DATA_WIDTH - 1 : 0] ex_result;
logic [`REG_WIDTH - 1 : 0] rd_wr_addr;
logic rd_wr_en;
logic [`DATA_WIDTH - 1 : 0] lsu_data;
logic [`LSU_OP_WIDTH - 1 : 0] lsu_op;

modport i(
    input inst,
    input pc,
    
    input ex_result,

    input rd_wr_en,
    input rd_wr_addr,

    input lsu_data,
    input lsu_op
);

modport o(
    output  inst,
    output  pc,

    output  ex_result,

    output  rd_wr_en,
    output  rd_wr_addr,

    output  lsu_data,
    output  lsu_op
);

endinterface:ex_stage_if
