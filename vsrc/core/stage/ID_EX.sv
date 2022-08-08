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
    id_stage_if.o ex_info,
    //csr info
    csr_info.i id_csr_info,
    csr_info.o ex_csr_info
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
        ex_info.except_type  <=`DATA_INVALID;
        ex_info.except_pc    <=`ADDR_INVALID;

        //csr_info
        ex_csr_info.is_ertn <= 0;
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

        //csr_info
        ex_csr_info.is_ertn <= ex_csr_info.is_ertn;
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

        //csr_info
        ex_csr_info.is_ertn <= id_csr_info.is_ertn;
    end
end
endmodule:ID_EX
