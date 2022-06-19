`include "width_param.sv"
module InstFecth(
    intput clk,
    input rst,
    output  [`ADDR_WIDTH - 1 : 0 ]   pc,
    branch_info.i branch_info,
)
    reg [ADDR_WIDTH - 1 : 0] r_pc;
    always_ff @(posedge clk)begin
        if(rst)
            r_pc <= 0;
        else
            r_pc <= r_pc + 4;
    end

    assign pc = r_pc;
endmodule:InstFecth