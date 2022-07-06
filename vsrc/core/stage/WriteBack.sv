`include "vsrc/include/width_param.sv"

module WriteBack (
    mem_stage_if.i mem_info,

    output logic rw_en,
    output logic [`REG_WIDTH - 1 : 0 ] rw_addr,
    output logic [`DATA_WIDTH - 1 : 0 ] rw_data
);
    assign rw_en = mem_info.rw_en;
    assign rw_addr = mem_info.rw_addr;
    assign rw_data = mem_info.rw_data;

endmodule:WriteBack
