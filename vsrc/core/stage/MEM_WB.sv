`include "vsrc/include/constant.sv"
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
    mem_stage_if.o wb_info,
    //csr
    csrData_pushForwward.i mem_csr_info,
    csrData_pushForwward.o wb_csr_info
);

wire stall_stage = stall | !ls_valid | !ns_ready; 
reg ts_valid_r,ts_ready_r;
always_ff @(posedge clk)begin
    if (rst)begin
        ts_valid_r <= 0;
        ts_ready_r <= 1;
    end else begin
        ts_valid_r <= !stall & ls_valid;
        ts_ready_r <= !stall & ns_ready;
    end
end
assign ts_valid = ts_valid_r;
assign ts_ready = ts_ready_r;

always_ff @(posedge clk)
begin
    if(rst==`RST_VALID)
    begin
        //wb_info
        wb_info.pc          <=`ADDR_INVALID;
        wb_info.inst        <=`DATA_INVALID;
        wb_info.rw_data     <=`DATA_INVALID;
        wb_info.rw_addr     <=`REG_ADDR_INVALID;
        wb_info.rw_en       <=`EN_INVALID;
        //wb_csr_info
        wb_csr_info.rw_en   <=`EN_INVALID;
        wb_csr_info.rw_addr <=`CSR_ADDR_INVALID;
        wb_csr_info.rw_data <=`DATA_INVALID;
    end
    else if (stall_stage)begin
        //wb_info
        wb_info.pc          <= wb_info.pc;
        wb_info.inst        <= wb_info.inst;
        wb_info.rw_data     <= wb_info.rw_data;
        wb_info.rw_addr     <= wb_info.rw_addr;
        wb_info.rw_en       <= wb_info.rw_en;
        //wb_csr_info
        wb_csr_info.rw_en   <= wb_csr_info.rw_en;
        wb_csr_info.rw_addr <= wb_csr_info.rw_addr;
        wb_csr_info.rw_data <= wb_csr_info.rw_data;
    end 
    else
    begin
        //wb_info<=mem_info;
        wb_info.pc          <= mem_info.pc;
        wb_info.inst        <= mem_info.inst;
        wb_info.rw_data     <= mem_info.rw_data;
        wb_info.rw_addr     <= mem_info.rw_addr;
        wb_info.rw_en       <= mem_info.rw_en;
        //wb_csr_info<=mem_csr_info
        wb_csr_info.rw_en   <= mem_csr_info.rw_en;
        wb_csr_info.rw_addr <= mem_csr_info.rw_addr;
        wb_csr_info.rw_data <= mem_csr_info.rw_data;
    end
end
endmodule:MEM_WB