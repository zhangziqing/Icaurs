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
    ex_stage_if.o mem_info,
    //csr info
    csr_info.i ex_csr_info,
    csr_info.o mem_csr_info
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
        mem_info.except_type <=`DATA_INVALID;
        mem_info.except_pc   <=`ADDR_INVALID;

        //csr_info
        mem_csr_info.is_ertn    <= 0;
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

        //csr_info
        mem_csr_info.is_ertn    <= mem_csr_info.is_ertn;
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

        //csr_info
        mem_csr_info.is_ertn    <= ex_csr_info.is_ertn;
    end
end
endmodule:EX_MEM