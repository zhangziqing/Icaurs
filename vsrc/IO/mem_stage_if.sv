`include "width_param.sv"

interface mem_stage_if;
    logic [`ADDR_WIDTH - 1 : 0 ] pc;
    logic [`INST_WIDTH - 1 : 0 ] inst;
    logic                        ram_rd_en;
    logic                               csr_wen;
    logic  [`DATA_WIDTH - 1     : 0 ]   csr_wdata;
    logic  [`CSRNUM_WIDTH - 1   : 0 ]   csr_waddr; 
    logic  [15 : 0]                     except_type;
    logic  [`INST_WIDTH - 1 : 0]        except_pc;
    logic [`DATA_WIDTH - 1 : 0 ] rw_data;
    logic [`REG_WIDTH - 1 : 0  ] rw_addr;
    logic                        rw_en;

    logic                               is_cacop;
    logic  [4:0]                        cacop_code;
    logic  [4:0]                        is_tlb;
    logic  [4:0]                        invtlb_op;
    logic                               is_ertn;
    logic                               is_idle;


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
        output rw_en,
        output is_cacop,
        output cacop_code,
        output is_tlb,
        output invtlb_op,
        output is_ertn,
        output is_idle
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
        input rw_en,
        input is_cacop,
        input cacop_code,
        input is_tlb,
        input invtlb_op,
        input is_ertn,
        input is_idle
    );
    endinterface:mem_stage
