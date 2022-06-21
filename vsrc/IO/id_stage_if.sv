`include "vsrc/include/width_param.sv"

interface id_stage_if;

    logic  [`INST_WIDTH - 1     : 0 ]   inst;
    logic  [`ADDR_WIDTH - 1     : 0 ]   pc;

    logic  [`DATA_WIDTH - 1     : 0 ]   ls_data;//load store data
    logic  [`LSU_OP_WIDTH - 1   : 0 ]   ls_op;


    logic  [`DATA_WIDTH - 1     : 0 ]   oprand1;
    logic  [`DATA_WIDTH - 1     : 0 ]   oprand2;
    logic  [`EXU_OP_WIDTH - 1    : 0 ]   ex_op;
    logic  [`CSR_OP_WIDTH - 1   : 0 ]   csr_op;   
    logic  [`REG_WIDTH - 1      : 0 ]   rd_wr_addr;
    logic                               rd_wr_en;

    modport i(
        input inst,
        input pc,

        input  ls_data,
        input  oprand1,
        input  oprand2,
        input  ex_op,
        input  ls_op,
        input  csr_op,
        input  rd_wr_addr,
        input  rd_wr_en
    );
    modport o(
        output inst,
        output pc,

        output ls_data,
        output oprand1,
        output oprand2,
        output ex_op,
        output ls_op,
        output csr_op,

        output rd_wr_addr,
        output rd_wr_en
    );

endinterface