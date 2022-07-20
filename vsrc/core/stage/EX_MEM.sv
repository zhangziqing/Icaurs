`include "vsrc/include/constant.sv"
module EX_MEM(
    input rst,
    input clk,
    //ex output
    ex_stage_if.i ex_info,
    //mem input
    ex_stage_if.o mem_info
);
always_ff @(posedge clk)
begin
    if(rst==`RST_VALID)
    begin
        mem_info.inst<=`DATA_INVALID;
        mem_info.pc<=`ADDR_INVALID;
        mem_info.ex_result<=`DATA_INVALID;
        mem_info.rw_en<=`EN_INVALID;
        mem_info.rw_addr<=`ADDR_INVALID;
        mem_info.lsu_data<=`DATA_INVALID;
        mem_info.lsu_op<=`LSU_OP_INVALID;
    end
    else
    begin
        //mem_info<=ex_info;
        mem_info.inst<=ex_info.inst;
        mem_info.pc<=ex_info.pc;
        mem_info.ex_result<=ex_info.ex_result;
        mem_info.rw_en<=ex_info.rw_en;
        mem_info.rw_addr<=ex_info.rw_addr;
        mem_info.lsu_data<=ex_info.lsu_data;
        mem_info.lsu_op<=ex_info.lsu_op;
    end
end
endmodule:EX_MEM