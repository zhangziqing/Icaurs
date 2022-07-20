`include "vsrc/include/width_param.sv"
import "DPI-C" function void dpi_pmem_read(output int data, input int addr, input bit en);
import "DPI-C" function void dpi_pmem_write(input int data, input int addr, input bit en, input bit[3:0] wr_mask);
import "DPI-C" function void trap(input int inst,input int res);
import "DPI-C" function void npc_update(input int inst,input int pc);
import "DPI-C" function void reg_connect(input int a[]);

module Core(
    input clock,
    input reset
);
    logic [`ADDR_WIDTH - 1 : 0] pc;//if_pc
    logic [`DATA_WIDTH - 1 : 0]inst;

    branch_info_if if_branch_info;
    
    InstFetch ifu_0(
        .clk(clock),
        .rst(reset),
        .pc(pc),
        .branch_info(if_branch_info)
    );
    always_comb dpi_pmem_read(inst, pc, !reset);

    logic [`ADDR_WIDTH - 1 : 0] id_pc; 
    IF_ID if_id(
        .rst(reset),
        .clk(clock),
        .if_pc(pc),
        .id_pc(id_pc)
    );

    logic r1_en,r2_en,rw_en;
    logic [`REG_WIDTH - 1 : 0 ] r1_addr,r2_addr,rw_addr;
    logic [`DATA_WIDTH - 1 : 0] r1_data,r2_data,rw_data;

    branch_info_if id_branch_info;
    id_stage_if id_info;
    InstDecode idu_0(
        .inst(inst),
        .pc(id_pc),
        .r1_en(r1_en),
        .r1_addr(r1_addr),
        .r1_data(r1_data),
        .r2_en(r2_en),
        .r2_addr(r2_addr),
        .r2_data(r2_data),

        .id_info(id_info),
        .branch_info(id_branch_info)
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

    id_stage_if id_info_ex; 
    ID_EX id_ex(
        .rst(reset),
        .clk(clock),
        .id_info(id_info),
        .id_branch_info(id_branch_info),
        .if_branch_info(if_branch_info),
        .ex_info(id_info_ex)
    );

    ex_stage_if ex_info;
    Execute exu_0(
        .id_info(id_info_ex),
        .ex_info(ex_info)
    );

    ex_stage_if ex_info_mem;
    EX_MEM ex_mem(
        .rst(reset),
        .clk(clock),
        .ex_info(ex_info),
        .mem_info(ex_info_mem)
    );

    mem_stage_if mem_info;
    MemoryAccess mem_0(
        .ex_info(ex_info_mem),
        .mem_info(mem_info)
    );

    mem_stage_if wb_info;
    MEM_WB mem_wb(
        .rst(reset),
        .clk(clock),
        .mem_info(mem_info),
        .wb_info(wb_info)
    );

    WriteBack wb_0(
        .mem_info(wb_info),
        .rw_en(rw_en),
        .rw_addr(rw_addr),
        .rw_data(rw_data)
    );





    always_ff@(clock)
        trap(inst,reg_0.reg_file[4]);
    always_ff@(clock)
        npc_update(inst,pc);
    initial begin
      reg_connect(reg_0.reg_file);
    end
endmodule:Core
