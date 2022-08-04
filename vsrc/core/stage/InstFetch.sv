`include "width_param.sv"
`include "isa_spec.sv"
module InstFetch(
    input clk,
    input rst,
    output  [`ADDR_WIDTH - 1 : 0 ]      pc,
    output                              valid,
    input                               ns_ready,
    input   [`ADDR_WIDTH - 1 : 0 ]      predict_pc,
    input                               branch,
    input                               flush,
    input   [`ADDR_WIDTH - 1 : 0 ]      flush_pc,
    input                               stall,
    output                              ready,
    if_stage_if.o                       if_info
);
    wire ts_ready = !valid || (ns_ready && !stall);
    wire stall_stage = !ts_ready;
    assign ready = ts_ready;
    reg [`ADDR_WIDTH - 1 : 0] r_pc;
    always_ff @(posedge clk)begin
        if(rst)
            r_pc <= `RESET_VECTOR;
        //ADD BRANCH INFO TEST
        else if (flush)
            r_pc <= flush_pc;
        else if (stall_stage)
            r_pc <= pc;
        else if (branch)
            r_pc <= predict_pc;
        else
            r_pc <= r_pc + 4;
    end
    
    
    reg valid_r;
    assign valid = !rst && !flush;
    assign pc = r_pc;
    assign if_info.branch = branch;
    assign if_info.pc = pc;
    assign if_info.branch_addr = predict_pc;
    
endmodule:InstFetch