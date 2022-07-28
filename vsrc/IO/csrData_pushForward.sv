`include "vsrc/include/width_param.sv"

interface csrData_pushForwward;

    logic                       rw_en;
    logic [`CSR_REG_WIDTH-1:0]  rw_addr;
    logic [`DATA_WIDTH-1:0]     rw_data;

    modport i(
        input rw_en;
        input rw_addr;
        input rw_data;
    );

    modport o(
        output rw_en;
        output rw_addr;
        output rw_data;
    );

endinterface