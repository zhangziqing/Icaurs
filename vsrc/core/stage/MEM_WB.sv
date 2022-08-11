`include "constant.sv"
module MEM_WB(
    input rst,
    input clk,
    input ls_valid,//last stage valid
    output ts_ready,//this stage ready
    input ns_ready,//next stage ready
    output ts_valid,//this stage valid
    input stall,
    input flush,
    mem_stage_if.i mem_info,
    lsu_info_if.i lsu_info,
    //regfile input
    mem_stage_if.o wb_info,
    lsu_info_if.o lsu_info_out
);

wire stall_stage = !ls_valid || !ts_ready; 
reg ts_valid_r,ts_ready_r;
always_ff @(posedge clk)begin
    if (rst || flush)begin
        ts_valid_r <= 0;
    end else if(ts_ready)begin
        ts_valid_r <= ls_valid;
    end
end
assign ts_valid = !stall && ts_valid_r;

assign ts_ready = !ts_valid_r || (ns_ready && !stall);

always_ff @(posedge clk)
begin
    if(rst || flush)
    begin
        //wb_info
        wb_info.pc          <=`ADDR_INVALID;
        wb_info.inst        <=`DATA_INVALID;
        wb_info.rw_data     <=`DATA_INVALID;
        wb_info.rw_addr     <=`REG_ADDR_INVALID;
        wb_info.rw_en       <=`EN_INVALID;
        wb_info.ram_rd_en   <= 0;
        //wb_csr_info
        wb_info.csr_wen   <=`EN_INVALID;
        wb_info.csr_waddr <=`CSR_ADDR_INVALID;
        wb_info.csr_wdata <=`DATA_INVALID;
        wb_info.except_type<=16'b0;
        wb_info.except_pc <=`ADDR_INVALID;
        //privilege info
        wb_info.is_cacop        <=0;
        wb_info.cacop_code      <=5'b0;
        wb_info.is_tlb          <=5'b0;
        wb_info.invtlb_op       <=5'b0;
        wb_info.is_ertn         <=0;
        wb_info.is_idle         <=0;
    end
    else if (stall_stage)begin
        //wb_info
        wb_info.pc          <= wb_info.pc;
        wb_info.inst        <= wb_info.inst;
        wb_info.ram_rd_en   <= wb_info.ram_rd_en;
        wb_info.rw_data     <= wb_info.rw_data;
        wb_info.rw_addr     <= wb_info.rw_addr;
        wb_info.rw_en       <= wb_info.rw_en;
        //wb_csr_info
        wb_info.csr_wen   <= wb_info.csr_wen;
        wb_info.csr_waddr <= wb_info.csr_waddr;
        wb_info.csr_wdata <= wb_info.csr_wdata;
        lsu_info_out.ld_paddr <= lsu_info_out.ld_paddr;
        lsu_info_out.ld_valid <= lsu_info_out.ld_valid;
        lsu_info_out.st_valid <= lsu_info_out.st_valid;
        lsu_info_out.st_paddr <= lsu_info_out.st_paddr;
        lsu_info_out.st_data  <= lsu_info_out.st_data;
        wb_info.except_type   <= wb_info.except_type;
        wb_info.except_pc  <= wb_info.except_pc;
        //privilege info
        wb_info.is_cacop        <= wb_info.is_cacop;
        wb_info.cacop_code      <= wb_info.cacop_code;
        wb_info.is_tlb          <= wb_info.is_tlb;
        wb_info.invtlb_op       <= wb_info.invtlb_op;
        wb_info.is_ertn         <= wb_info.is_ertn;
        wb_info.is_idle         <= wb_info.is_idle;
    end 
    else
    begin
        //wb_info<=mem_info;
        wb_info.pc          <= mem_info.pc;
        wb_info.inst        <= mem_info.inst;
        wb_info.rw_data     <= mem_info.rw_data;
        wb_info.rw_addr     <= mem_info.rw_addr;
        wb_info.rw_en       <= mem_info.rw_en;
        wb_info.ram_rd_en   <= mem_info.ram_rd_en;
        //wb_csr_info<=mem_csr_info
        wb_info.csr_wen     <= mem_info.csr_wen;
        wb_info.csr_waddr   <= mem_info.csr_waddr;
        wb_info.csr_wdata   <= mem_info.csr_wdata;
        lsu_info_out.ld_paddr <= lsu_info.ld_paddr;
        lsu_info_out.ld_valid <= lsu_info.ld_valid;
        lsu_info_out.st_valid <= lsu_info.st_valid;
        lsu_info_out.st_paddr <= lsu_info.st_paddr;
        lsu_info_out.st_data  <= lsu_info.st_data;
        wb_info.except_type <= mem_info.except_type;
        wb_info.except_pc   <= mem_info.except_pc;
        //privilege info
        wb_info.is_cacop        <= mem_info.is_cacop;
        wb_info.cacop_code      <= mem_info.cacop_code;
        wb_info.is_tlb          <= mem_info.is_tlb;
        wb_info.invtlb_op       <= mem_info.invtlb_op;
        wb_info.is_ertn         <= mem_info.is_ertn;
        wb_info.is_idle         <= mem_info.is_idle;
    end
end
endmodule:MEM_WB