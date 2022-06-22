`include "vsrc/include/width_param.sv"
`include "vsrc/include/isa_spec.sv"
module InstFetch(
    input clk,
    input rst,
    output  [`ADDR_WIDTH - 1 : 0 ]   pc,
    branch_info_if.i branch_info
);
    reg [`ADDR_WIDTH - 1 : 0] r_pc;
    always_ff @(posedge clk)begin
        if(rst)
            r_pc <= `RESET_VECTOR;
        //ADD BRANCH INFO TEST
        else if (branch_info.branch_en)
            r_pc <= branch_info.branch_addr;
        else if (branch_info.jump_en)
            r_pc <= branch_info.jump_addr;
        else
            r_pc <= r_pc + 4;
    end

    assign pc = r_pc;
endmodule:InstFetch