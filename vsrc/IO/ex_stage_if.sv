`include "width_param.sv"

interface ex_stage_if;
    logic [`INST_WIDTH - 1:0]           inst;
    logic [`ADDR_WIDTH - 1:0]           pc;

    logic [`DATA_WIDTH - 1 : 0]         ex_result;
    logic [`REG_WIDTH - 1 : 0]          rw_addr;
    logic                               rw_en;
    logic                               csr_wen;
    logic  [`DATA_WIDTH - 1     : 0 ]   csr_wdata;
    logic  [`CSRNUM_WIDTH - 1   : 0 ]   csr_waddr;
    logic  [9 : 0]                      except_type;
    logic  [`INST_WIDTH - 1 : 0]        except_pc;
    logic [`DATA_WIDTH - 1 : 0]         lsu_data;
    logic [`LSU_OP_WIDTH - 1 : 0]       lsu_op;

    logic                               is_cacop;
    logic  [4:0]                        cacop_code;
    logic  [4:0]                        is_tlb;
    logic  [4:0]                        invtlb_op;
    logic                               is_ertn;
    logic                               is_idle;

    modport i(
        input inst,
        input pc,
        
        input ex_result,

        input rw_en,
        input rw_addr,
        input csr_wen,
        input csr_waddr,
        input csr_wdata,
        input except_type,
        input except_pc,
        input lsu_data,
        input lsu_op,

        input is_cacop,
        input cacop_code,
        input is_tlb,
        input invtlb_op,
        input is_ertn,
        input is_idle
    );

    modport o(
        output  inst,
        output  pc,

        output  ex_result,
        output  csr_wen,
        output  csr_waddr,
        output  csr_wdata,

        output  except_type,
        output  except_pc,
        output  rw_en,
        output  rw_addr,

        output  lsu_data,
        output  lsu_op,

        output is_cacop,
        output cacop_code,
        output is_tlb,
        output invtlb_op,
        output is_ertn,
        output is_idle
    );

endinterface:ex_stage_if
