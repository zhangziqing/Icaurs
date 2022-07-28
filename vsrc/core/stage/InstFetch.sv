`include "width_param.sv"
`include "isa_spec.sv"
module InstFetch(
    input clk,
    input rst,
    output  [`ADDR_WIDTH - 1 : 0 ]      pc,
    input   [`ADDR_WIDTH - 1 : 0 ]      predict_pc,
    input                               branch,
    input                               flush,
    input   [`ADDR_WIDTH - 1 : 0 ]      flush_pc,
    input                               stall,
    if_stage_if.o                       if_info
);
    reg [`ADDR_WIDTH - 1 : 0] r_pc;
    always_ff @(posedge clk)begin
        if(rst)
            r_pc <= `RESET_VECTOR;
        //ADD BRANCH INFO TEST
        else if (branch)
            r_pc <= predict_pc;
        else if (flush)
            r_pc <= flush_pc;
        else if (stall)
            r_pc <= pc;
        else
            r_pc <= r_pc + 4;
    end

    assign pc = r_pc;
    assign if_info.branch = branch;
    assign if_info.pc = pc;
    assign if_info.branch_addr = predict_pc;
    
endmodule:InstFetch