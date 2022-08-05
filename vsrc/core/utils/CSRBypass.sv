`include "width_param.sv"

module CSRBypass(
    input ex_csr_wen,
    input [`CSRNUM_WIDTH - 1 : 0 ] ex_csr_waddr,
    input [`DATA_WIDTH - 1   : 0 ] ex_csr_wdata,

    input mem_csr_wen,
    input [`CSRNUM_WIDTH - 1 : 0 ] mem_csr_waddr,
    input [`DATA_WIDTH - 1   : 0 ] mem_csr_wdata,

    input wb_csr_wen,
    input [`CSRNUM_WIDTH - 1 : 0 ] wb_csr_waddr,
    input [`DATA_WIDTH - 1   : 0 ] wb_csr_wdata,

    input csr_rd_en,
    input [`CSRNUM_WIDTH - 1 : 0 ] csr_rd_addr,
    output [`DATA_WIDTH - 1   : 0 ] csr_rd_data,

    output [`CSRNUM_WIDTH - 1 : 0] csrfile_rd_addr,
    input [`CSRNUM_WIDTH - 1 : 0] csrfile_rd_data
);

    wire ex_wr_csrf = ~|(ex_csr_waddr ^ csr_rd_addr) & ex_csr_wen;
    wire mem_wr_csrf = ~|(mem_csr_waddr ^ csr_rd_addr) & mem_csr_wen;
    wire wb_wr_csrf = ~|(wb_csr_waddr ^ csr_rd_addr) & wb_csr_wen;

    wire [`DATA_WIDTH - 1 : 0 ] csr_bypass_data;
    assign csr_bypass_data =    ex_wr_csrf  ? ex_csr_wdata  :
                                mem_wr_csrf ? mem_csr_wdata :
                                wb_wr_csrf  ? wb_csr_wdata  :
                                csrfile_rd_data;
                                
    assign csr_rd_data  =   csr_rd_en ? csr_bypass_data : 0;
    assign csrfile_rd_addr = csr_rd_addr;

endmodule