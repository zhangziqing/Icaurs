`include "width_param.sv"

interface id_stage_if;

    logic  [`INST_WIDTH - 1     : 0 ]   inst;
    logic  [`ADDR_WIDTH - 1     : 0 ]   pc;

    logic  [`DATA_WIDTH - 1     : 0 ]   lsu_data;//load store data
    logic  [`LSU_OP_WIDTH - 1   : 0 ]   lsu_op;


    logic  [`DATA_WIDTH - 1     : 0 ]   oprand1;
    logic  [`DATA_WIDTH - 1     : 0 ]   oprand2;
    logic  [`EXU_OP_WIDTH - 1    : 0]   ex_op;
    logic                               csr_wen;
    logic  [`DATA_WIDTH - 1     : 0 ]   csr_wdata;
    logic  [`CSRNUM_WIDTH - 1   : 0 ]   csr_waddr;
    logic  [8 : 0]                      except_type;
    logic  [`INST_WIDTH - 1 : 0]        except_pc;
    logic  [`REG_WIDTH - 1      : 0 ]   rw_addr;
    logic                               rw_en;

    logic                               is_cacop;
    logic  [4:0]                        cacop_code;
    logic  [4:0]                        is_tlb;
    logic  [4:0]                        invtlb_op;
    logic                               is_ertn;
    logic                               is_idle;

    modport i(
        input inst,
        input pc,
        input lsu_data,
        input oprand1,
        input oprand2,
        input ex_op,
        input lsu_op,
        input csr_wen,
        input csr_waddr,
        input csr_wdata,
        input except_type,
        input except_pc,
        input rw_addr,
        input rw_en,
        input is_cacop,
        input cacop_code,
        input is_tlb,
        input invtlb_op,
        input is_ertn,
        input is_idle
    );
    modport o(
        output inst,
        output pc,
        output lsu_data,
        output oprand1,
        output oprand2,
        output ex_op,
        output lsu_op,
        output csr_wen,
        output csr_waddr,
        output csr_wdata,
        output except_type,
        output except_pc,
        output rw_addr,
        output rw_en,
        output is_cacop,
        output cacop_code,
        output is_tlb,
        output invtlb_op,
        output is_ertn,
        output is_idle
    );

endinterface
