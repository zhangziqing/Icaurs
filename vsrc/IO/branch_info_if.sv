`include "vsrc/include/width_param.sv"

interface branch_info_if;
    logic   [`ADDR_WIDTH - 1 : 0 ] branch_addr;
    logic                          taken;
    logic                          branch_flag;
    logic   [`ADDR_WIDTH - 1 : 0 ] pc;

    modport i(
        input   branch_addr,
        input                         taken,
        input                         branch_flag,
        input pc
    );

    modport o(
        output  branch_addr,
        output                        taken,
        output                        branch_flag,
        output  pc
    );

endinterface
