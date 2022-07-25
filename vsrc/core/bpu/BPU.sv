`include "vsrc/include/width_param.sv"  

module BPU #(
    GHR_WIDTH = 12
)(
    input clk,
    input rst,
    output branch,
    output [`ADDR_WIDTH - 1 : 0 ]ppc,

    branch_info_if.i branch_info
);
//

    assign branch = 0;
    assign ppc = 0; 

    reg [GHR_WIDTH - 1 : 0] ghr;

    always_ff @(posedge clk)begin
        if (rst)
            ghr <= 0;
        else if (branch_info.branch_flag)
            ghr <= {ghr[GHR_WIDTH - 1: 1],branch_info.taken};    
    end 


endmodule