`include "vsrc/include/width_param.sv"
import "DPI-C" function void dpi_pmem_read(output int data, input int addr, input bit en);
import "DPI-C" function void dpi_pmem_write(input int data, input int addr, input bit en, input bit[3:0] wr_mask);
import "DPI-C" function void trap(input int inst,input int res);
import "DPI-C" function void npc_update(input int inst,input int pc);

module Core(
    input clock,
    input reset
);
    logic [`ADDR_WIDTH - 1 : 0] pc;
    logic [`DATA_WIDTH - 1 : 0]inst;

    branch_info_if br_info_if_0;
    
    InstFetch ifu_0(
        .clk(clock),
        .rst(reset),
        .pc(pc),
        .branch_info(br_info_if_0)
    );
    always_comb dpi_pmem_read(inst, pc, !reset);


    logic r1_en,r2_en,rw_en;
    logic [`REG_WIDTH - 1 : 0 ] r1_addr,r2_addr,rw_addr;
    logic [`DATA_WIDTH - 1 : 0] r1_data,r2_data,rw_data;

    id_stage_if id_info_if_0;
    InstDecode idu_0(
        .inst(inst),
        .pc(pc),
        .r1_en(r1_en),
        .r1_addr(r1_addr),
        .r1_data(r1_data),
        .r2_en(r2_en),
        .r2_addr(r2_addr),
        .r2_data(r2_data),

        .id_info(id_info_if_0),
        .branch_info(br_info_if_0)
    );

    RegFile reg_0 (
        .clk(clock),
        .rst(reset),
        .r1_en(r1_en),
        .r1_addr(r1_addr),
        .r1_data(r1_data),
        .r2_en(r2_en),
        .r2_addr(r2_addr),
        .r2_data(r2_data),
        .rw_en(rw_en),
        .rw_addr(rw_addr),
        .rw_data(rw_data)
    );

    ex_stage_if ex_info_if_0;
    
    Execute exu_0(
        .id_info(id_info_if_0),
        .ex_info(ex_info_if_0)
    );

    mem_stage_if mem_stage_if_0;
    MemoryAccess mem_0(
        .ex_info(ex_info_if_0),
        .mem_info(mem_stage_if_0)
    );

    WriteBack wb_0(
        .mem_info(mem_stage_if_0),

        .rw_en(rw_en),
        .rw_addr(rw_addr),
        .rw_data(rw_data)
    );





    always_ff@(clock)
        trap(inst,reg_0.reg_file[4]);
    always_ff@(clock)
        npc_update(inst,pc);
endmodule:Core
