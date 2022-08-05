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
    logic  [`DATA_WIDTH - 1 : 0]        except_type;
    logic  [`INST_WIDTH - 1 : 0]        except_pc;
    logic  [`REG_WIDTH - 1      : 0 ]   rw_addr;
    logic                               rw_en;

    modport i(
        input inst,
        input pc,

        input  lsu_data,
        input  oprand1,
        input  oprand2,
        input  ex_op,
        input  lsu_op,
        input  csr_wen,
        input  csr_waddr,
        input  csr_wdata,
        input  except_type,
        input  except_pc,
        input  rw_addr,
        input  rw_en
    );
    modport o(
        output inst,
        output pc,

        output lsu_data,
        output oprand1,
        output oprand2,
        output ex_op,
        output lsu_op,
        output  csr_wen,
        output  csr_waddr,
        output  csr_wdata,

        output  except_type,
        output  except_pc,
        output rw_addr,
        output rw_en
    );

endinterface
