`include "vsrc/include/constant.sv"
`include "vsrc/include/width_param.sv"

module IF_ID(
    input rst,
    input clk,
    input ls_valid,//last stage valid
    output ts_ready,//this stage ready
    input ns_ready,//next stage ready
    output ts_valid,//this stage valid
    input stall,
    input flush,
    //if output
    if_stage_if.i if_info,
    //id input
    if_stage_if.o id_info
);


wire stall_stage = stall | !ls_valid | !ns_ready; 
reg ts_valid_r,ts_ready_r;
always_ff @(posedge clk)begin
    if (rst)begin
        ts_valid_r <= 0;
        ts_ready_r <= 1;
    end else begin
        ts_valid_r <= !stall & ls_valid;
        ts_ready_r <= !stall & ns_ready;
    end
end
assign ts_valid = 1;
assign ts_ready = ts_ready_r;

always_ff @(posedge clk)
begin
    if(rst==`RST_VALID)begin
        id_info.pc <= `ADDR_INVALID;
        id_info.branch_addr <= `ADDR_INVALID;
        id_info.branch <= 0;
    end
    if (stall_stage)begin
        id_info.pc <= id_info.pc;
        id_info.branch_addr  <= id_info.branch_addr ;
        id_info.branch  <= id_info.branch ;
    end
    else begin
        id_info.pc <= if_info.pc;
        id_info.branch_addr  <= if_info.branch_addr ;
        id_info.branch  <= if_info.branch ;
    end
end
endmodule:IF_ID