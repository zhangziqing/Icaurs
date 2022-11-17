`include "width_param.sv"
`include "isa_spec.sv"
module InstFetch(
    input clk,
    input rst,
    output  [`ADDR_WIDTH - 1 : 0 ]      pc,
    output                              valid,
    input                               ns_ready,
    input   [`ADDR_WIDTH - 1 : 0 ]      predict_pc,
    input                               branch,
    input                               flush,
    input   [`ADDR_WIDTH - 1 : 0 ]      flush_pc,
    input                               stall,
    output                              ready,
    if_stage_if.o                       if_info,
    //from csr
    input [31:0] csr_crmd,
    input [31:0] csr_dmw0,
    input [31:0] csr_dmw1,
    input        disable_cache,
    //to MMU
    output [31:0]   inst_addr,
    output          dmw0_en,
    output          dmw1_en,
    //inst cache
    input           inst_addr_ok,
    input           inst_data_ok,
    input [31:0]    inst_rdata,
    input           icache_miss,
    output          icache_valid,
    output          inst_uncache_en,

    //read inst
    sram_if.m iram,
    output reg inst_valid,
    output [`ADDR_WIDTH-1 : 0] inst

);
    wire ts_ready = !valid || (ns_ready && !stall);
    wire stall_stage = !ts_ready;
    assign ready = ts_ready;
    reg [`ADDR_WIDTH - 1 : 0] r_pc;
    always_ff @(posedge clk)begin
        if(rst)
            r_pc <= `RESET_VECTOR;
        //ADD BRANCH INFO TEST
        else if (flush)
            r_pc <= flush_pc;
        else if (stall_stage)
            r_pc <= pc;
        else if (branch)
            r_pc <= predict_pc;
        else
            r_pc <= r_pc + 4;
    end
    
    //TODO
    wire [3:0] except_type;
    wire except_type_ppi,except_type_pif,except_type_tlbr,except_type_adef;
    assign except_type={except_type_ppi,except_type_pif,except_type_tlbr,except_type_adef};
    
    //reg valid_r;
    assign valid = !rst && !flush ;
    assign pc = r_pc;
    assign if_info.branch = branch;
    assign if_info.pc = pc;
    assign if_info.branch_addr = predict_pc;
    assign if_info.except_type = except_type;

    //MMU
    assign inst_addr = r_pc;
    //1.csr signal
    wire csr_crmd_da = csr_crmd[3];
    wire csr_crmd_pg = csr_crmd[4];
    wire [1:0] csr_crmd_plv  = csr_crmd[1:0];
    wire [1:0] csr_crmd_datf = csr_crmd[6:5];
    //2.dmw_en
    assign dmw0_en = ((csr_dmw0[0] && csr_crmd_plv == 2'd0) || (csr_dmw0[3] && csr_crmd_plv == 2'd3)) && (csr_dmw0[31:29] == r_pc[31:29]);
    assign dmw1_en = ((csr_dmw1[0] && csr_crmd_plv == 2'd0) || (csr_dmw1[3] && csr_crmd_plv == 2'd3)) && (csr_dmw1[31:29] == r_pc[31:29]);

    //icache
    assign icache_valid = !inst_uncache_en && valid;
    //1.judge uncache
    assign da_mode = csr_crmd_da && !csr_crmd_pg;
    assign inst_uncache_en = (da_mode && (csr_datf == 2'b0))                 ||
                             (dmw0_en && (csr_dmw0[5:4] == 2'b0))            ||
                             (dmw1_en && (csr_dmw1[5:4] == 2'b0))            ||
                             disable_cache;

    //read inst
    //1.write inst signal invalid
    assign iram.sram_wr_en   = 0;
    assign iram.sram_wr_addr = 0;
    assign iram.sram_wr_data = 0;
    assign iram.sram_wr_mask = 0;
    //2.read inst signal valid
    assign iram.sram_rd_en   = inst_uncache_en & (valid & ready);
    assign iram.sram_rd_addr = pc;
    assign iram.sram_cancel_rd = 0;
    
    //judge inst valid
    always @(posedge clk)
    begin
            if(rst||flush||(valid && ns_ready))
            begin
                inst_valid <= 0;
            end
            else if(inst_data_ok)
            begin
                inst_valid <= 1;
            end
            else if(iram.sram_rd_valid)
            begin
                inst_valid <= 1;
            end
    end
    assign inst =   !inst_valid ? inst :
                    inst_data_ok ? inst_rdata : iram.sram_rd_data;

endmodule:InstFetch