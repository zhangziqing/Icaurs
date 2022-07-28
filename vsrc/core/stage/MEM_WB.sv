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
    //mem output
    mem_stage_if.i mem_info,
    //regfile input
    mem_stage_if.o wb_info
);

wire stall_stage = stall | !ls_valid | !ns_ready; 
reg ts_valid_r,ts_ready_r;
always_ff @(posedge clk)begin
    if (rst)begin
        ts_valid_r <= 0;
    end else begin
        ts_valid_r <= ls_valid & !flush;
    end
end
assign ts_valid = ts_valid_r & !stall;

assign ts_ready = !stall & ns_ready;


always_ff @(posedge clk)
begin
    if(rst || flush)
    begin
        wb_info.pc<=`ADDR_INVALID;
        wb_info.inst<=`DATA_INVALID;
        wb_info.rw_data<=`DATA_INVALID;
        wb_info.rw_addr<=`REG_ADDR_INVALID;
        wb_info.rw_en<=`EN_INVALID;
    end
    else if (stall_stage)begin
        wb_info.pc <= wb_info.pc;
        wb_info.inst <= wb_info.inst;
        wb_info.rw_data <= wb_info.rw_data;
        wb_info.rw_addr <= wb_info.rw_addr;
        wb_info.rw_en <= wb_info.rw_en;
    end 
    else
    begin
        //regfile_info<=mem_info;
        wb_info.pc<=mem_info.pc;
        wb_info.inst<=mem_info.inst;
        wb_info.rw_data<=mem_info.rw_data;
        wb_info.rw_addr<=mem_info.rw_addr;
        wb_info.rw_en<=mem_info.rw_en;
    end
end
endmodule:MEM_WB