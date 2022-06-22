`include "vsrc/include/width_param.sv"

interface mem_stage_if;
    logic [`ADDR_WIDTH - 1 : 0 ] pc;
    logic [`INST_WIDTH - 1 : 0 ] inst;
 
    logic [`DATA_WIDTH - 1 : 0 ] rw_data;
    logic [`REG_WIDTH - 1 : 0 ] rw_addr;
    logic                        rw_en;


    modport o(
        output pc,
        output inst,
        output rw_data,
        output rw_addr,
        output rw_en
    );

    modport i(
        input pc,
        input inst,
        input rw_data,
        input rw_addr,
        input rw_en
    );
    endinterface:mem_stage
