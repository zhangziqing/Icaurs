`include "vsrc/include/width_param.sv"

interface except_info;

    logic [`DATA_WIDTH-1:0] except_type;
    logic [`INST_WIDTH-1:0] except_pc;

    modport i(
        input except_type,
        input except_pc
    );

    modport o(
        output except_type,
        output except_pc
    );

endinterface