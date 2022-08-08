`include "width_param.sv"

interface csr_info;

    logic is_ertn;

    modport i(
        input is_ertn
    );

    modport o(
        output is_ertn
    );

endinterface