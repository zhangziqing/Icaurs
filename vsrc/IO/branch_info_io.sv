`include "width_param.sv"
interface branch_info;
    logic   [`ADDR_WIDTH - 1 : 0 ] branch_addr,
    logic   [`ADDR_WIDTH - 1 : 0 ] jump_addr,
    logic                          branch_en,
    logic                          jump_en,

    modport i(
        input  [`ADDR_WIDTH - 1 : 0 ] branch_addr,
        input  [`ADDR_WIDTH - 1 : 0 ] jump_addr,
        input                         branch_en,
        input                         jump_en
    )

    modport o(
        output [`ADDR_WIDTH - 1 : 0 ] branch_addr,
        output [`ADDR_WIDTH - 1 : 0 ] jump_addr,
        output                        branch_en,
        output                        jump_en
    )

endinterface
