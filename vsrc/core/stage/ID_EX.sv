`include "vsrc/include/constant.sv"
module ID_EX(
    input rst,
    input clk,
    //id output
    id_stage_if.i id_info,
    branch_info_if.i id_branch_info,
    //if input
    branch_info_if.o if_branch_info,
    //ex input
    id_stage_if.o ex_info
);
always_ff @(posedge clk)
begin
    if(rst==`RST_VALID)
    begin
        //if_branch_info
        if_branch_info.branch_addr<=`ADDR_INVALID;
        if_branch_info.jump_addr<=`ADDR_INVALID;
        if_branch_info.branch_en<=`EN_INVALID;
        if_branch_info.jump_en<=`EN_INVALID;
        //ex_info
        ex_info.inst<=`DATA_INVALID;
        ex_info.pc<=`ADDR_INVALID;
        ex_info.lsu_data<=`DATA_INVALID;
        ex_info.oprand1<=`DATA_INVALID;
        ex_info.oprand2<=`DATA_INVALID;
        ex_info.ex_op<=`EX_OP_INVALID;
        ex_info.lsu_op<=`LSU_OP_INVALID;
        ex_info.csr_op<=`CSR_OP_INVALID;
        ex_info.rw_addr<=`REG_DATA_INVALID;
        ex_info.rw_en<=`EN_INVALID;
    end
    else
    begin
        //if_branch_info<=id_branch_info;
        if_branch_info.branch_addr<=id_branch_info.branch_addr;
        if_branch_info.jump_addr<=id_branch_info.jump_addr;
        if_branch_info.branch_en<=id_branch_info.branch_en;
        if_branch_info.jump_en<=id_branch_info.jump_en;
        //ex_info<=id_info;
        ex_info.inst<=id_info.inst;
        ex_info.pc<=id_info.pc;
        ex_info.lsu_data<=id_info.lsu_data;
        ex_info.oprand1<=id_info.oprand1;
        ex_info.oprand2<=id_info.oprand2;
        ex_info.ex_op<=id_info.ex_op;
        ex_info.lsu_op<=id_info.lsu_op;
        ex_info.csr_op<=id_info.csr_op;
        ex_info.rw_addr<=id_info.rw_addr;
        ex_info.rw_en<=id_info.rw_en;
    end
end
endmodule:ID_EX