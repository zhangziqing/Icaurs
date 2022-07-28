`include "width_param.sv"  

module BPU (
    input clk,
    input rst,
    output branch,
    input  [`ADDR_WIDTH - 1 : 0 ]pc,
    output [`ADDR_WIDTH - 1 : 0 ]ppc,
    
    branch_info_if.i branch_info
);
//

    localparam PHT_WIDTH = 6;
    localparam GHR_WIDTH = PHT_WIDTH;

    reg [GHR_WIDTH - 1 : 0] ghr;

    always_ff @(posedge clk)begin
        if (rst)
            ghr <= 0;
        else if (branch_info.branch_flag)
            ghr <= {ghr[GHR_WIDTH - 1: 1],branch_info.taken};    
    end 

    wire btb_hit;
    wire pht_branch;

    BTB #(
        .BTB_SIZE(64),
        .BTB_WIDTH(6)
    )btb_0(
        .clk(clk),
        .rst(rst),
        .lookup_addr(pc),
        .pred_addr(ppc),
        .branch(btb_hit),
        .branch_addr(branch_info.pc),
        .update_addr(branch_info.branch_addr),
        .isBranch(branch_info.branch_flag)
    );


    wire [PHT_WIDTH - 1 : 0] pht_lookup_addr = ghr ^ (pc[PHT_WIDTH + 1 : 2]);
    wire [PHT_WIDTH - 1 : 0] pht_update_addr = ghr ^ (branch_info.pc[PHT_WIDTH + 1 : 2]);
    PHT #(
        .PHT_WIDTH(PHT_WIDTH)
    )pth_0(
        .clk(clk),
        .rst(rst),
        .lookup_addr(pht_lookup_addr),
        .pred_taken(pht_branch),

        .branch_en(branch_info.branch_flag),
        .update_addr(pht_update_addr),
        .taken(branch_info.taken)
    );

    assign branch = pht_branch & btb_hit;

endmodule