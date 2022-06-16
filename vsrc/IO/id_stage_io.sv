`include "width_param.sv"


interface id_stage
    logic  [`DATA_WIDTH - 1]   ls_data,//load store data
    logic  [`DATA_WIDTH - 1]   oprand1,
    logic  [`DATA_WIDTH - 1]   oprand2,
    logic  [`EX_OP_WIDTH - 1]  ex_op,
    logic  [`EX_OP_WIDTH - 1]  ls_op,
    logic  [`EX_OP_WIDTH - 1]  csr_op    

    modport i(
        input  ls_data,
        input  oprand1,
        input  oprand2,
        input  ex_op,
        input  ls_op,
        input  csr_op
    )
    modport o(
        output ls_data,
        output oprand1,
        output oprand2,
        output ex_op,
        output ls_op,
        output csr_op
    )

endinterface