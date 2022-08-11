`include "constant.sv"
module ID_EX(
    input rst,
    input clk,
    input  ls_valid,//last stage valid
    output ts_ready,//this stage ready
    input  ns_ready,//next stage ready
    output ts_valid,//this stage valid
    input  stall,
    input  flush,
    //id output
    id_stage_if.i id_info,
    //ex input
    id_stage_if.o ex_info
);


wire stall_stage = !ls_valid || !ts_ready; 
reg ts_valid_r,ts_ready_r;
always_ff @(posedge clk)begin
    if (rst || flush)begin
        ts_valid_r <= 0;
    end else if(ts_ready)begin
        ts_valid_r <= ls_valid;
    end
end
assign ts_valid = !stall && ts_valid_r;

assign ts_ready = !ts_valid_r || (ns_ready && !stall);

always_ff @(posedge clk)
begin
    if(rst || flush)
    begin
        //ex_info
        ex_info.inst        <=`DATA_INVALID;
        ex_info.pc          <=`ADDR_INVALID;
        ex_info.lsu_data    <=`DATA_INVALID;
        ex_info.oprand1     <=`DATA_INVALID;
        ex_info.oprand2     <=`DATA_INVALID;
        ex_info.ex_op       <=`EX_OP_INVALID;
        ex_info.rw_addr     <=`REG_ADDR_INVALID;
        ex_info.rw_en       <=`EN_INVALID;
        //ex_csr_info
        ex_info.csr_wen   <=`EN_INVALID;
        ex_info.csr_waddr <=`CSR_ADDR_INVALID;
        ex_info.csr_wdata <=`DATA_INVALID;
        //ex_except_info
        ex_info.except_type  <=9'b0;
        ex_info.except_pc    <=`ADDR_INVALID;
        //privilege info
        ex_info.is_cacop        <=0;
        ex_info.cacop_code      <=5'b0;
        ex_info.is_tlb          <=5'b0;
        ex_info.invtlb_op       <=5'b0;
        ex_info.is_ertn         <=0;
        ex_info.is_idle         <=0;
    end
    else if (stall_stage)begin 
        //ex_info
        ex_info.inst        <= ex_info.inst;
        ex_info.pc          <= ex_info.pc;
        ex_info.lsu_data    <= ex_info.lsu_data;
        ex_info.oprand1     <= ex_info.oprand1;
        ex_info.oprand2     <= ex_info.oprand2;
        ex_info.ex_op       <= ex_info.ex_op;
        ex_info.lsu_op      <= ex_info.lsu_op;
        ex_info.rw_addr     <= ex_info.rw_addr;
        ex_info.rw_en       <= ex_info.rw_en;
        //ex_csr_info
        ex_info.csr_wen   <= ex_info.csr_wen;
        ex_info.csr_waddr <= ex_info.csr_waddr;
        ex_info.csr_wdata <= ex_info.csr_wdata;
        //ex_except_info
        ex_info.except_type  <= ex_info.except_type;
        ex_info.except_pc    <= ex_info.except_pc;
        //privilege info
        ex_info.is_cacop        <= ex_info.is_cacop;
        ex_info.cacop_code      <= ex_info.cacop_code;
        ex_info.is_tlb          <= ex_info.is_tlb;
        ex_info.invtlb_op       <= ex_info.invtlb_op;
        ex_info.is_ertn         <= ex_info.is_ertn;
        ex_info.is_idle         <= ex_info.is_idle;
    end
    else
    begin
        //ex_info<=id_info;
        ex_info.inst        <= id_info.inst;
        ex_info.pc          <= id_info.pc;
        ex_info.lsu_data    <= id_info.lsu_data;
        ex_info.oprand1     <= id_info.oprand1;
        ex_info.oprand2     <= id_info.oprand2;
        ex_info.ex_op       <= id_info.ex_op;
        ex_info.lsu_op      <= id_info.lsu_op;
        ex_info.rw_addr     <= id_info.rw_addr;
        ex_info.rw_en       <= id_info.rw_en;
        //ex_csr_info<=id_csr_info
        ex_info.csr_wen     <= id_info.csr_wen;
        ex_info.csr_waddr   <= id_info.csr_waddr;
        ex_info.csr_wdata   <= id_info.csr_wdata;
        //ex_except_info
        ex_info.except_type  <= id_info.except_type;
        ex_info.except_pc    <= id_info.except_pc;
        //privilege info
        ex_info.is_cacop        <= id_info.is_cacop;
        ex_info.cacop_code      <= id_info.cacop_code;
        ex_info.is_tlb          <= id_info.is_tlb;
        ex_info.invtlb_op       <= id_info.invtlb_op;
        ex_info.is_ertn         <= id_info.is_ertn;
        ex_info.is_idle         <= id_info.is_idle;
    end
end
endmodule:ID_EX
