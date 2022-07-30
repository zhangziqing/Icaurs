`include "width_param.sv"

// Module data bypass

module RegFileBypass(
    input   reg_req_en,
    input   [`REG_WIDTH - 1 : 0]    reg_req_addr,
    output  [`DATA_WIDTH - 1 : 0]   reg_req_data,

    input   ex_rw_en,
    input   [`REG_WIDTH - 1 : 0]    ex_rw_addr,
    input   [`DATA_WIDTH - 1 : 0]   ex_rw_data,

    input   mem_rw_en,
    input   [`REG_WIDTH - 1 : 0]    mem_rw_addr,
    input [`DATA_WIDTH - 1 : 0] mem_rw_data,

    input   wb_rw_en,
    input   [`REG_WIDTH - 1 : 0]    wb_rw_addr,
    input   [`DATA_WIDTH - 1 : 0]   wb_rw_data,
    
    output  reg_en,
    output  [`REG_WIDTH - 1 : 0]    reg_addr,
    input   [`DATA_WIDTH - 1 : 0]   reg_data,

    input   [`LSU_OP_WIDTH - 1:0]   lsu_op,
    output  load_flag
);

    assign reg_en = reg_req_en;
    assign reg_addr = reg_req_addr;

    wire ex_wr_rf = ex_rw_en & (~|(reg_req_addr ^ ex_rw_addr));
    wire mem_wr_rf = mem_rw_en & (~|(reg_req_addr ^ mem_rw_addr));
    wire wb_wr_rf = wb_rw_en & (~|(reg_req_addr ^ wb_rw_addr));
    wire read_zero  = ~|reg_req_addr;
    wire [`DATA_WIDTH - 1 : 0] bypass_data =    read_zero   ? 0           :   
                                                ex_wr_rf    ? ex_rw_data  :
                                                mem_wr_rf   ? mem_rw_data :
                                                wb_wr_rf    ? wb_rw_data  :
                                                reg_data;
    assign reg_req_data = reg_req_en ? bypass_data : 32'b0;

    wire mem_read_en = lsu_op[2] == 0;
    assign load_flag = ex_wr_rf & mem_read_en & ~read_zero;
endmodule