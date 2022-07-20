`include "vsrc/include/constant.sv"
module MEM_WB(
    input rst,
    input clk,
    //mem output
    mem_stage_if.i mem_info,
    //regfile input
    mem_stage_if.o wb_info
);
always_ff @(posedge clk)
begin
    if(rst==`RST_VALID)
    begin
        wb_info.pc<=`ADDR_INVALID;
        wb_info.inst<=`DATA_INVALID;
        wb_info.rw_data<=`DATA_INVALID;
        wb_info.rw_addr<=`REG_ADDR_INVALID;
        wb_info.rw_en<=`EN_INVALID;
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