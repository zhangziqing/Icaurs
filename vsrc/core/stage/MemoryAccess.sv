`include "vsrc/include/width_param.sv"

module MemoryAccess(
    // sram_if.m sram_io,
    mem_stage_if.o mem_info,
    ex_stage_if.i ex_info
);


    assign mem_info.pc = ex_info.pc;
    assign mem_info.inst = ex_info.inst;
    assign mem_info.rw_en = ex_info.rw_en;
    assign mem_info.rw_addr = ex_info.rw_addr;
    
    //TODO:
    assign mem_info.rw_data = 0;

    always_comb dpi_pmem_write(32'hdec0de11,32'h1c000000,1,4'b0001);

endmodule:MemoryAccess