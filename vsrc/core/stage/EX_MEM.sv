`include "constant.sv"
module EX_MEM(
    input rst,
    input clk,
    input ls_valid,//last stage valid
    output ts_ready,//this stage ready
    input ns_ready,//next stage ready
    output ts_valid,//this stage valid
    input flush,
    input stall,
    //ex output
    ex_stage_if.i ex_info,
    //mem input
    ex_stage_if.o mem_info
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
    if(rst | flush)
    begin
        //mem_info
        mem_info.inst       <=`DATA_INVALID;
        mem_info.pc         <=`ADDR_INVALID;
        mem_info.ex_result  <=`DATA_INVALID;
        mem_info.rw_en      <=`EN_INVALID;
        mem_info.rw_addr    <=`REG_ADDR_INVALID;
        mem_info.lsu_data   <=`DATA_INVALID;
        mem_info.lsu_op     <=`LSU_OP_INVALID;
        //mem_csr_info
        mem_info.csr_wen  <=`EN_INVALID;
        mem_info.csr_waddr<=`CSR_ADDR_INVALID;
        mem_info.csr_wdata<=`DATA_INVALID;
        //mem_except_info
        mem_info.except_type <= 10'b0;
        mem_info.except_pc   <=`ADDR_INVALID;
        //privilege info
        mem_info.is_cacop        <=0;
        mem_info.cacop_code      <=5'b0;
        mem_info.is_tlb          <=5'b0;
        mem_info.invtlb_op       <=5'b0;
        mem_info.is_ertn         <=0;
        mem_info.is_idle         <=0;
    end
    else if (stall_stage)
    begin
        //mem_info
        mem_info.inst       <= mem_info.inst;
        mem_info.pc         <= mem_info.pc;
        mem_info.ex_result  <= mem_info.ex_result;
        mem_info.rw_en      <= mem_info.rw_en;
        mem_info.rw_addr    <= mem_info.rw_addr;
        mem_info.lsu_data   <= mem_info.lsu_data;
        mem_info.lsu_op     <= mem_info.lsu_op;
        //mem_csr_info
        mem_info.csr_wen   <= mem_info.csr_wen;
        mem_info.csr_waddr <= mem_info.csr_waddr;
        mem_info.csr_wdata <= mem_info.csr_wdata;
        //mem_except_info
        mem_info.except_type <= mem_info.except_type;
        mem_info.except_pc   <= mem_info.except_pc;
        //privilege info
        mem_info.is_cacop        <= mem_info.is_cacop;
        mem_info.cacop_code      <= mem_info.cacop_code;
        mem_info.is_tlb          <= mem_info.is_tlb;
        mem_info.invtlb_op       <= mem_info.invtlb_op;
        mem_info.is_ertn         <= mem_info.is_ertn;
        mem_info.is_idle         <= mem_info.is_idle;
    end
    else
    begin
        //mem_info<=ex_info;
        mem_info.inst       <= ex_info.inst;
        mem_info.pc         <= ex_info.pc;
        mem_info.ex_result  <= ex_info.ex_result;
        mem_info.rw_en      <= ex_info.rw_en;
        mem_info.rw_addr    <= ex_info.rw_addr;
        mem_info.lsu_data   <= ex_info.lsu_data;
        mem_info.lsu_op     <= ex_info.lsu_op;
        //mem_csr_info<=ex_csr_info
        mem_info.csr_wen   <= ex_info.csr_wen;
        mem_info.csr_waddr <= ex_info.csr_waddr;
        mem_info.csr_wdata <= ex_info.csr_wdata;
        //mem_except_info
        mem_info.except_type <= ex_info.except_type;
        mem_info.except_pc   <= ex_info.except_pc;
        //privilege info
        mem_info.is_cacop        <= ex_info.is_cacop;
        mem_info.cacop_code      <= ex_info.cacop_code;
        mem_info.is_tlb          <= ex_info.is_tlb;
        mem_info.invtlb_op       <= ex_info.invtlb_op;
        mem_info.is_ertn         <= ex_info.is_ertn;
        mem_info.is_idle         <= ex_info.is_idle;
    end
end
endmodule:EX_MEM