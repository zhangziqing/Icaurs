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
        mem_info.inst<=`DATA_INVALID;
        mem_info.pc<=`ADDR_INVALID;
        mem_info.ex_result<=`DATA_INVALID;
        mem_info.rw_en<=`EN_INVALID;
        mem_info.rw_addr<=`REG_ADDR_INVALID;
        mem_info.lsu_data<=`DATA_INVALID;
        mem_info.lsu_op<=`LSU_OP_INVALID;
    end
    else if (stall_stage)begin
        mem_info.inst       <= mem_info.inst;
        mem_info.pc         <= mem_info.pc;
        mem_info.ex_result  <= mem_info.ex_result;
        mem_info.rw_en      <= mem_info.rw_en;
        mem_info.rw_addr    <= mem_info.rw_addr;
        mem_info.lsu_data   <= mem_info.lsu_data;
        mem_info.lsu_op     <= mem_info.lsu_op;
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