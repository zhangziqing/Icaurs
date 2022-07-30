`include "width_param.sv"
// import "DPI-C" function void dpi_pmem_read(output int data, input int addr, input bit en);
// import "DPI-C" function void dpi_pmem_write(input int data, input int addr, input bit en, input bit[3:0] wr_mask);
// import "DPI-C" function void dpi_pmem_fetch(output int data, input int addr, input bit en);
// import "DPI-C" function void trap(input int inst,input int res);
// import "DPI-C" function void npc_update(input int inst,input int pc);
// import "DPI-C" function void reg_connect(input int a[]);

module Core(
    input clock,
    input reset,
    sram_if.m iram,
    sram_if.m dram,
    output [31:0] debug0_wb_pc,
    output [ 3:0] debug0_wb_rf_wen,
    output [ 4:0] debug0_wb_rf_wnum,
    output [31:0] debug0_wb_rf_wdata
);
    logic [`ADDR_WIDTH - 1 : 0] pc;//if_pc
    logic [`ADDR_WIDTH - 1 : 0] flush_pc;
    logic [`ADDR_WIDTH - 1 : 0] predict_pc;
    logic flush;
    logic stall;
    branch_info_if branch_info;
    if_stage_if if_info_id,if_info;
    
    logic predict_branch;

    logic [4 : 0] glo_flush;

    logic if_ready,if_valid,if_stall,if_flush;
    logic id_ready,id_valid,id_stall,id_flush;
    logic ex_ready,ex_valid,ex_stall,ex_flush;
    logic mem_ready,mem_valid,mem_stall,mem_flush;
    logic wb_ready,wb_valid,wb_stall,wb_flush;
    InstFetch ifu_0(
        .clk(clock),
        .rst(reset),
        .flush(glo_flush[4]),
        .flush_pc(flush_pc),
        .branch(predict_branch),
        .predict_pc(predict_pc),
        .stall(if_stall),
        .pc(pc),
        .valid(if_valid),
        .ns_ready(id_ready),
        .if_info(if_info)
    );
    BPU bpu_0(
        .clk(clock),
        .rst(reset),
        .pc(pc),
        .ppc(predict_pc),
        .branch(predict_branch),
        .branch_info(branch_info)
    );
    wire [`INST_WIDTH - 1 : 0] inst;

    // always_comb dpi_pmem_fetch(inst_if, pc, !reset);
    assign iram.sram_rd_en = if_valid;
    assign iram.sram_rd_addr = pc;
    assign inst = iram.sram_rd_data;
    assign iram.sram_cancel_rd = 0;
    wire iram_data_valid = iram.sram_rd_valid;

    assign iram.sram_wr_en = 0;
    assign iram.sram_wr_addr = 0;
    assign iram.sram_wr_data = 0;
    assign iram.sram_wr_mask = 0;
    
    logic [`ADDR_WIDTH - 1 : 0] id_pc; 
    logic load_flag1,load_flag2;
    assign id_stall = !iram_data_valid;
    IF_ID if_id(
        .rst(reset),
        .clk(clock),
        .ls_valid(if_valid),
        .ts_ready(id_ready),
        .ts_valid(id_valid),
        .ns_ready(ex_ready),
        .stall(id_stall),
        .flush(if_flush),
        .if_info(if_info),
        .id_info(if_info_id)
    );
    assign if_flush = glo_flush[3];

    logic r1_en,r2_en,rw_en,r1_rf_en,r2_rf_en;
    logic [`REG_WIDTH - 1 : 0 ] r1_addr,r2_addr,rw_addr,r1_rf_addr,r2_rf_addr;
    logic [`DATA_WIDTH - 1 : 0] r1_data,r2_data,rw_data,r1_rf_data,r2_rf_data;

    logic predict_miss;

    id_stage_if id_info;

    InstDecode idu_0(
        .inst(inst),

        .r1_en(r1_en),
        .r1_addr(r1_addr),
        .r1_data(r1_data),
        .r2_en(r2_en),
        .r2_addr(r2_addr),
        .r2_data(r2_data),

        .if_info(if_info_id),
        .id_info(id_info),
        .branch_info(branch_info),

        .predict_miss(predict_miss)
    );

    RegFileBypass reg1_bypass(
        .reg_req_addr(r1_addr),
        .reg_req_data(r1_data),
        .reg_req_en(r1_en),

        .ex_rw_addr(ex_info.rw_addr),
        .ex_rw_en(ex_info.rw_en),
        .ex_rw_data(ex_info.ex_result),

        .mem_rw_addr(mem_info.rw_addr),
        .mem_rw_en(mem_info.rw_en),
        .mem_rw_data(mem_info.rw_data),

        .wb_rw_addr(wb_info.rw_addr),
        .wb_rw_en(wb_info.rw_en),
        .wb_rw_data(wb_info.rw_data),

        .reg_en(r1_rf_en),
        .reg_addr(r1_rf_addr),
        .reg_data(r1_rf_data),

        .lsu_op(ex_info.lsu_op),
        .load_flag(load_flag1)
    );

    RegFileBypass reg2_bypass(
        .reg_req_addr(r2_addr),
        .reg_req_data(r2_data),
        .reg_req_en(r2_en),

        .ex_rw_addr(ex_info.rw_addr),
        .ex_rw_en(ex_info.rw_en),
        .ex_rw_data(ex_info.ex_result),

        .mem_rw_addr(mem_info.rw_addr),
        .mem_rw_en(mem_info.rw_en),
        .mem_rw_data(mem_info.rw_data),

        .wb_rw_addr(wb_info.rw_addr),
        .wb_rw_en(wb_info.rw_en),
        .wb_rw_data(wb_info.rw_data),

        .reg_en(r2_rf_en),
        .reg_addr(r2_rf_addr),
        .reg_data(r2_rf_data),
        
        .lsu_op(ex_info.lsu_op),
        .load_flag(load_flag2)
    );

    assign ex_stall = load_flag1 | load_flag2;
    id_stage_if id_info_ex; 
    ID_EX id_ex(
        .rst(reset),
        .clk(clock),
        .stall(ex_stall),
        .flush(0),
        .ls_valid(id_valid),
        .ts_valid(ex_valid),
        .ts_ready(ex_ready),
        .ns_ready(mem_ready),
        .id_info(id_info),
        .ex_info(id_info_ex)
    );

    ex_stage_if ex_info;
    Execute exu_0(
        .id_info(id_info_ex),
        .ex_info(ex_info)
    );

    ex_stage_if ex_info_mem;
    assign mem_stall = dram.sram_wr_en & dram.sram_wr_busy;
    EX_MEM ex_mem(
        .rst(reset),
        .clk(clock),
        .stall(mem_stall),
        .flush(0),
        .ls_valid(ex_valid),
        .ts_valid(mem_valid),
        .ts_ready(mem_ready),
        .ns_ready(wb_ready),
        .ex_info(ex_info),
        .mem_info(ex_info_mem)
    );

    mem_stage_if mem_info;
    MemoryAccess mem_0(
        .ex_info(ex_info_mem),
        .mem_info(mem_info),
        .sram_io(dram)
    );
    assign wb_stall = wb_info.ram_rd_en && !dram.sram_rd_valid;
    mem_stage_if wb_info;
    MEM_WB mem_wb(
        .rst(reset),
        .clk(clock),
        .stall(wb_stall),
        .flush(0),
        .ts_ready(wb_ready),
        .ts_valid(wb_valid),
        .ls_valid(mem_valid),
        .ns_ready(1),
        .mem_info(mem_info),
        .wb_info(wb_info)
    );

    WriteBack wb_0(
        .mem_info(wb_info),
        .ram_rd_data(dram.sram_rd_data),
        .rw_en(rw_en),
        .rw_addr(rw_addr),
        .rw_data(rw_data)
    );

    RegFile reg_0 (
        .clk(clock),
        .rst(reset),
        .r1_en(r1_rf_en),
        .r1_addr(r1_rf_addr),
        .r1_data(r1_rf_data),
        .r2_en(r2_rf_en),
        .r2_addr(r2_rf_addr),
        .r2_data(r2_rf_data),
        .rw_en(rw_en),
        .rw_addr(rw_addr),
        .rw_data(rw_data)
    );
    PipelineController pipctl_0(
        .predict_miss(predict_miss),
        .real_addr(branch_info.branch_addr),
        .exp_en(0),
        .e_ret(0),
        .epc(0),
        .trap_entry(),
        .flush(glo_flush),
        .flush_pc(flush_pc)
    );



    // always_ff@(clock)
    //     trap(inst,reg_0.reg_file[4]);
    // always_ff@(clock)
    //     npc_update(inst,id_info.pc);
    // initial begin
    //     reg_connect(reg_0.reg_file);
    // end
endmodule:Core
