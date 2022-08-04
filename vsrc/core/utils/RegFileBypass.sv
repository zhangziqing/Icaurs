`include "width_param.sv"

// Module data bypass

module RegFileBypass(
    input   reg_req_en,
    input   [`REG_WIDTH - 1 : 0]    reg_req_addr,
    output  [`DATA_WIDTH - 1 : 0]   reg_req_data,

    input   ex_rw_en,
    input   [`REG_WIDTH - 1 : 0]    ex_rw_addr,
    input   [`DATA_WIDTH - 1 : 0]   ex_rw_data,
    input   ex_data_valid,
    input   ex_stall,

    input   mem_rw_en,
    input   [`REG_WIDTH - 1 : 0]    mem_rw_addr,
    input   [`DATA_WIDTH - 1 : 0] mem_rw_data,
    input   mem_data_valid,
    input   mem_stall,

    input   wb_rw_en,
    input   [`REG_WIDTH - 1 : 0]    wb_rw_addr,
    input   [`DATA_WIDTH - 1 : 0]   wb_rw_data,
    input   wb_data_valid,
    input   wb_stall,

    output  reg_en,
    output  [`REG_WIDTH - 1 : 0]    reg_addr,
    input   [`DATA_WIDTH - 1 : 0]   reg_data,

    input   [`LSU_OP_WIDTH - 1:0]   ex_lsu_op,
    input   mem_ram_rd_en,
    output  hazard_flag
);

    assign reg_en = reg_req_en;
    assign reg_addr = reg_req_addr;

    wire ex_wr_rf = ex_rw_en & (~|(reg_req_addr ^ ex_rw_addr)) & (ex_data_valid || ex_stall);
    wire mem_wr_rf = mem_rw_en & (~|(reg_req_addr ^ mem_rw_addr)) & (mem_data_valid || mem_stall);
    wire wb_wr_rf = wb_rw_en & (~|(reg_req_addr ^ wb_rw_addr)) & (wb_data_valid || wb_stall);
    wire read_zero  = ~|reg_req_addr;
    wire [`DATA_WIDTH - 1 : 0] bypass_data;
    wire stage_hazard_flag;
    wire load_flag;
    assign bypass_data =    read_zero  ? 0                  :   
                            ex_wr_rf   ? ex_rw_data         :
                            mem_wr_rf  ? mem_rw_data        :
                            wb_wr_rf   ? wb_rw_data         :
                            reg_data;
    assign stage_hazard_flag =    read_zero  ? 0                  :   
                            ex_wr_rf   ? ex_stall         :
                            mem_wr_rf  ? mem_stall        :
                            wb_wr_rf   ? wb_stall         :
                            0;


    assign reg_req_data = reg_req_en ? bypass_data : 32'b0;

    wire ex_mem_read_en = ex_lsu_op[2] == 0;
    assign load_flag = ((ex_wr_rf & ex_mem_read_en)|(mem_ram_rd_en & mem_wr_rf) & ~read_zero);
    assign hazard_flag = load_flag || stage_hazard_flag;
endmodule