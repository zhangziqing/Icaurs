`include "vsrc/include/width_param.sv"

interface csr_except_info;

    logic [`DATA_WIDTH-1:0] crmd;
    logic [`DATA_WIDTH-1:0] ecfg;
    logic [`DATA_WIDTH-1:0] estat;
    logic [`DATA_WIDTH-1:0] era;

    modport i(
        input crmd,
        input ecfg,
        input estat,
        input era
    );

    modport o(
        output crmd,
        output ecfg,
        output estat,
        output era
    );

endinterface