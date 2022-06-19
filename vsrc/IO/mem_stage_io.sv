`include "width_param.sv"

interface mem_stage;
    logic [`DATA_WIDTH - 1 : 0 ] rd_wr_data;
    logic [`ADDR_WIDTH - 1 : 0 ] rd_wr_addr;
    logic                        rd_wr_en;
endinterface:mem_stage