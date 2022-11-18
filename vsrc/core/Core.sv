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
    //sram_if.m iram,
    sram_if.m dram,
    cache_if.m icachePort,
    //output sram_cancel_rd,
    input  [8 : 0] hw_int,
    output [31:0] debug0_wb_pc,
    output [ 3:0] debug0_wb_rf_wen,
    output [ 4:0] debug0_wb_rf_wnum,
    output [31:0] debug0_wb_rf_wdata,
);
    logic [`ADDR_WIDTH - 1 : 0] pc;//if_pc
    logic [`ADDR_WIDTH - 1 : 0] flush_pc;
    logic [`ADDR_WIDTH - 1 : 0] predict_pc;
    logic flush;
    logic stall;
    branch_info_if branch_info;
    if_stage_if if_info_id,if_info;
    logic [63 : 0] timer_val;
    logic [31 : 0] timer_id;
    logic                         is_except;
    logic [`ADDR_WIDTH - 1  : 0 ] epc;
    logic                         exception_en;
    logic                         is_ertn;
    logic [5:0]                   Ecode;
    logic [8:0]                   EsubCode;
    logic [`DATA_WIDTH - 1  : 0 ] trap_entry;
    logic [`CSRNUM_WIDTH - 1 : 0] csr_rd_addr;
    logic [`CSRNUM_WIDTH - 1 : 0] csrfile_rd_addr;
    logic [`CSRNUM_WIDTH - 1 : 0] csrfile_wr_addr;
    logic [`DATA_WIDTH - 1  : 0 ] csr_rd_data;
    logic [`DATA_WIDTH - 1  : 0 ] csrfile_rd_data;
    logic [`DATA_WIDTH - 1  : 0 ] csrfile_wr_data;
    logic  csr_rd_en;
    logic  csrfile_wr_en;
    logic           is_va_error;
    logic [31:0]    va_error_in;
    logic           etype_tlb;
    logic [18:0]    etype_tlb_vppn;
    logic           is_tlbsrch;
    logic           tlbsrch_found;
    logic [4:0]     tlbsrch_index;
    logic           is_tlbrd;
    logic [31:0]    tlbidx_in;
    logic [31:0]    tlbehi_in;
    logic [31:0]    tlbelo0_in;
    logic [31:0]    tlbelo1_in;
    logic [9:0]     asid_in;
    logic           disable_cache;

    logic  [`DATA_WIDTH - 1   : 0 ]    era_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    dmw0_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    dmw1_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    tlbidx_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    tlbehi_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    tlbelo0_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    tlbelo1_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    asid_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    pgdl_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    pgdh_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    pgd_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    tlbrentry_out;
    logic  [`DATA_WIDTH - 1   : 0 ]    crmd_out;

    //IF<->MMU
    logic [31:0]    inst_addr;
    logic           dmw0_en;
    logic           dmw1_en;
    logic [ 7:0]    inst_index;
    logic [19:0]    inst_tag;
    logic [ 3:0]    inst_offest;

    //if<->icache
    logic                               inst_addr_ok;
    logic                               inst_data_ok;
    logic                               icache_miss;
    logic                               icache_valid;
    logic                               inst_uncache_en;
    logic  [`DATA_WIDTH - 1   : 0 ]     inst_rdata;
    
    //read inst
    logic  [`ADDR_WIDTH - 1   : 0 ]     inst;
    logic                               inst_valid;

    logic [  2:0] rd_type   ;
    logic [  2:0] wr_type   ;

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
        .pc(pc),
        .valid(if_valid),
        .ns_ready(id_ready),
        .predict_pc(predict_pc),
        .branch(predict_branch),
        .flush(glo_flush[4]),
        .flush_pc(flush_pc),
        .stall(if_stall),
        .ready(if_ready),
        
        .if_info(if_info),
        //from csr
        .csr_crmd(crmd_out),
        .csr_dmw0(dmw0_out),
        .csr_dmw1(dmw1_out),
        .disable_cache(disable_cache),
        //to MMU
        .inst_addr(inst_addr),
        .dmw0_en(dmw0_en),
        .dmw1_en(dmw1_en),
        //inst cache
        .inst_addr_ok(inst_addr_ok),
        .inst_data_ok(inst_data_ok),
        .inst_rdata(inst_rdata),
        .icache_miss(icache_miss),
        .icache_valid(icache_valid),
        .inst_uncache_en(inst_uncache_en),
        //read inst
        .inst_valid(inst_valid),
        .inst(inst)
    );
    cache icache(
        .clk(clock),
        .reset(reset),
        //to from cpu
        .valid(icache_valid),
        .uncache_en(inst_uncache_en),
        .op(1'b0),
        .index(inst_index),
        .tag(inst_tag),
        .offset(inst_offest),
        .wstrb(4'b0),
        .wdata(32'b0),
        .addr_ok(inst_addr_ok),
        .data_ok(inst_data_ok),
        .rdata(inst_rdata),
        // to from axi  
        .rd_req   (icachePort.rd_req),
        .rd_type  (icachePort.rd_type),
        .rd_addr  (icachePort.rd_addr),
        .rd_rdy   (icachePort.rd_rdy),
        .ret_valid(icachePort.ret_valid),
        .ret_last (icachePort.ret_last),
        .ret_data (icachePort.ret_data),
        .wr_req   (icachePort.wr_req),
        .wr_type  (icachePort.wr_type),
        .wr_addr  (icachePort.wr_addr),
        .wr_wstrb (icachePort.wr_wstrb),
        .wr_data  (icachePort.wr_data),
        .wr_rdy   (icachePort.wr_rdy)
    );
    //assign sram_cancel_rd = 0;
    MMU mmu(
        .clk(clock),
        //inst addr trans from IF
        .inst_vaddr(inst_addr),
        .inst_dmw0_en(dmw0_en),
        .inst_dmw1_en(dmw1_en),
        .inst_index(inst_index),
        .inst_tag(inst_tag),
        .inst_offest(inst_offest),
        //from csr
        .csr_crmd_da(crmd_out[3]),
        .csr_crmd_pg(crmd_out[4]),
        .csr_dmw0(dmw0_out),
        .csr_dmw1(dmw1_out)
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
    // assign iram.sram_rd_en = if_valid & if_ready;
    // assign iram.sram_rd_addr = pc;
    // assign inst = iram.sram_rd_data;
    // assign iram.sram_cancel_rd = 0;
    // wire iram_data_valid = iram.sram_rd_valid;

    // assign iram.sram_wr_en = 0;
    // assign iram.sram_wr_addr = 0;
    // assign iram.sram_wr_data = 0;
    // assign iram.sram_wr_mask = 0;
    
    //logic [`ADDR_WIDTH - 1 : 0] id_pc; 
    //logic bypass_valid1,bypass_valid2;
    //logic inst_valid_sm;
    
    // always @(posedge clock)begin
    //     if (reset)
    //         inst_valid_sm <= 0;
    //     else if (reset || if_flush || (if_valid && id_ready))
    //         inst_valid_sm <= 0;
    //     else if(iram_data_valid)
    //         inst_valid_sm <= 1;
    // end
    // wire inst_valid = inst_valid_sm ? inst_valid_sm : iram_data_valid;
    logic load_flag1,load_flag2;
    assign id_stall = (~inst_valid) | load_flag1 | load_flag2;
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
        .inst_valid(inst_valid),

        .r1_en(r1_en),
        .r1_addr(r1_addr),
        .r1_data(r1_data),
        .r2_en(r2_en),
        .r2_addr(r2_addr),
        .r2_data(r2_data),
        .csr_addr(csr_rd_addr),
        .csr_data(csr_rd_data),
        .is_interrupt(exception_en),
        .timer_64(timer_val),
        .csr_tid(timer_id),
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
        .ex_data_valid(ex_valid),
        .ex_stall(ex_stall),

        .mem_rw_addr(mem_info.rw_addr),
        .mem_rw_en(mem_info.rw_en),
        .mem_rw_data(mem_info.rw_data),
        .mem_data_valid(mem_valid),
        .mem_stall(mem_stall),

        .wb_rw_addr(rw_addr),
        .wb_rw_en(rw_en),
        .wb_rw_data(rw_data),
        .wb_data_valid(wb_valid),
        .wb_stall(wb_stall),

        .reg_en(r1_rf_en),
        .reg_addr(r1_rf_addr),
        .reg_data(r1_rf_data),

        .ex_lsu_op(ex_info.lsu_op),
        .mem_ram_rd_en(mem_info.ram_rd_en),
        .hazard_flag(load_flag1)
    );

    RegFileBypass reg2_bypass(
        .reg_req_addr(r2_addr),
        .reg_req_data(r2_data),
        .reg_req_en(r2_en),

        .ex_rw_addr(ex_info.rw_addr),
        .ex_rw_en(ex_info.rw_en),
        .ex_rw_data(ex_info.ex_result),
        .ex_data_valid(ex_valid),
        .ex_stall(ex_stall),

        .mem_rw_addr(mem_info.rw_addr),
        .mem_rw_en(mem_info.rw_en),
        .mem_rw_data(mem_info.rw_data),
        .mem_data_valid(mem_valid),
        .mem_stall(mem_stall),

        .wb_rw_addr(rw_en),
        .wb_rw_en(rw_addr),
        .wb_rw_data(rw_data),
        .wb_data_valid(wb_valid),
        .wb_stall(wb_stall),

        .reg_en(r2_rf_en),
        .reg_addr(r2_rf_addr),
        .reg_data(r2_rf_data),
        
        .ex_lsu_op(ex_info.lsu_op),
        .mem_ram_rd_en(mem_info.ram_rd_en),
        .hazard_flag(load_flag2)
    );
    CSRBypass csr_bypass_0(
        .ex_csr_wen(ex_info.csr_wen),
        .ex_csr_waddr(ex_info.csr_waddr),
        .ex_csr_wdata(ex_info.csr_wdata),
        .mem_csr_wen(mem_info.csr_wen),
        .mem_csr_waddr(mem_info.csr_waddr),
        .mem_csr_wdata(mem_info.csr_wdata),
        .wb_csr_wen(wb_info.csr_wen),
        .wb_csr_waddr(wb_info.csr_waddr),
        .wb_csr_wdata(wb_info.csr_wdata),

        .csr_rd_addr(csr_rd_addr),
        .csr_rd_data(csr_rd_data),
        .csr_rd_en(csr_rd_en),

        .csrfile_rd_addr(csrfile_rd_addr),
        .csrfile_rd_data(csrfile_rd_data)
    );

    assign ex_stall = 0;
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
    logic exmem_stall;
    assign mem_stall = dram.sram_wr_en& dram.sram_wr_busy;
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
    lsu_info_if lsu_info_mem,lsu_info_wb;
    logic mem_wb_stall;
    MemoryAccess mem_0(
        .stall(exmem_stall),
        .ex_info(ex_info_mem),
        .mem_info(mem_info),
        .sram_io(dram),
        .lsu_info(lsu_info_mem)
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
        .wb_info(wb_info),
        .lsu_info(lsu_info_mem),
        .lsu_info_out(lsu_info_wb)
    );

    WriteBack wb_0(
        .mem_info(wb_info),
        .ram_rd_data(dram.sram_rd_data),
        .rw_en(rw_en),
        .rw_addr(rw_addr),
        .rw_data(rw_data),
        .csr_wen(csr_wen),
        .csr_waddr(csr_waddr),
        .csr_wdata(csr_wdata),
        .lsu_info(lsu_info_wb),
        .debug0_wb_rf_wdata(debug0_wb_rf_wdata),
        .debug0_wb_rf_wnum(debug0_wb_rf_wnum),
        .debug0_wb_rf_wen(debug0_wb_rf_wen),
        .debug0_wb_pc(debug0_wb_pc),
        .is_except(is_except),
        .is_ertn(is_ertn),
        .epc(epc),
        .Ecode(Ecode),
        .EsubCode(EsubCode),
        .is_va_error(is_va_error),
        .va_error_in(va_error_in),
        .etype_tlb(etype_tlb),
        .etype_tlb_vppn(etype_tlb_vppn),
        .is_tlbsrch(is_tlbsrch),
        .tlbsrch_found(tlbsrch_found),
        .tlbsrch_index(tlbsrch_index)
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

    CSR csrfile_0 (
        .clk(clock),
        .rst(reset),
        .csr_raddr(csrfile_rd_addr),
        .csr_rdata(csrfile_rd_data),
        .csr_wen(csr_wen),
        .csr_waddr(csr_waddr),
        .csr_wdata(csr_wdata),
        .is_except(is_except),
        .epc(epc),
        .is_ertn(is_ertn),
        .Ecode(Ecode),
        .EsubCode(EsubCode),
        //interrupt 
        .ipi(hw_int[0]),
        .hwi(hw_int[8:1]),
        .is_interrupt(exception_en),
        //timer 64
        .timer_64(timer_val),
        .timer_id(timer_id),
        //badv va error
        .is_va_error(is_va_error),
        .va_error_in(va_error_in),
        //tlb
        .etype_tlb(etype_tlb),
        .etype_tlb_vppn(etype_tlb_vppn),
        .is_tlbsrch(is_tlbsrch),
        .tlbsrch_found(tlbsrch_found),
        .tlbsrch_index(tlbsrch_index),
        .is_tlbrd(is_tlbrd),
        .tlbidx_in(tlbidx_in),
        .tlbehi_in(tlbehi_in),
        .tlbelo0_in(tlbelo0_in),
        .tlbelo1_in(tlbelo1_in),
        .asid_in(asid_in),
        //to if
        .disable_cache(disable_cache),
        //csr reg out
        .trap_entry(trap_entry),
        .era_out(era_out),
        .dmw0_out(dmw0_out),
        .dmw1_out(dmw1_out),
        .tlbidx_out(tlbidx_out),
        .tlbehi_out(tlbehi_out),
        .tlbelo0_out(tlbelo0_out),
        .tlbelo1_out(tlbelo1_out),
        .asid_out(asid_out),
        .pgdl_out(pgdl_out),
        .pgdh_out(pgdh_out),
        .pgd_out(pgd_out),
        .tlbrentry_out(tlbrentry_out)
    );
    PipelineController pipctl_0(
        .predict_miss(predict_miss),
        .real_addr(branch_info.branch_addr),
        .exp_en(exception_en),
        .e_ret(0),
        .era(era_out),
        .trap_entry(trap_entry),
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
