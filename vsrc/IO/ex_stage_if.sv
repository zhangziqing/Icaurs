`include "width_param.sv"

interface ex_stage_if;
    logic [`INST_WIDTH - 1:0] inst;
    logic [`ADDR_WIDTH - 1:0] pc;

    logic [`DATA_WIDTH - 1 : 0] ex_result;
    logic [`REG_WIDTH - 1 : 0] rw_addr;
    logic rw_en;
    logic                               csr_wen;
    logic  [`DATA_WIDTH - 1     : 0 ]   csr_wdata;
    logic  [`CSRNUM_WIDTH - 1   : 0 ]   csr_waddr;
    logic  [`DATA_WIDTH - 1 : 0]        except_type;
    logic  [`INST_WIDTH - 1 : 0]        except_pc;
    logic [`DATA_WIDTH - 1 : 0] lsu_data;
    logic [`LSU_OP_WIDTH - 1 : 0] lsu_op;

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
        input lsu_op
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
        output  lsu_op
    );

endinterface:ex_stage_if
