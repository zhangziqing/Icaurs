`include "width_param.sv"

interface mem_stage_if;
    logic [`ADDR_WIDTH - 1 : 0 ] pc;
    logic [`INST_WIDTH - 1 : 0 ] inst;
    logic                        ram_rd_en;
    logic                               csr_wen;
    logic  [`DATA_WIDTH - 1     : 0 ]   csr_wdata;
    logic  [`CSRNUM_WIDTH - 1   : 0 ]   csr_waddr; 
    logic  [`DATA_WIDTH - 1 : 0]        except_type;
    logic  [`INST_WIDTH - 1 : 0]        except_pc;
    logic [`DATA_WIDTH - 1 : 0 ] rw_data;
    logic [`REG_WIDTH - 1 : 0  ] rw_addr;
    logic                        rw_en;


    modport o(
        output pc,
        output inst,
        output ram_rd_en,
        output csr_wen,
        output csr_waddr,
        output csr_wdata,
        output except_type,
        output except_pc,
        output rw_data,
        output rw_addr,
        output rw_en
    );

    modport i(
        input pc,
        input inst,
        input ram_rd_en,
        input csr_wen,
        input csr_waddr,
        input csr_wdata,
        input except_type,
        input except_pc,
        input rw_data,
        input rw_addr,
        input rw_en
    );
    endinterface:mem_stage
