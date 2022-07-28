`include "width_param.sv"  

module BTB #(
    BTB_SIZE = 64,
    BTB_WIDTH = 6 
)(
    input clk,
    input rst,
    input [`ADDR_WIDTH - 1 : 0 ]lookup_addr,
    output [`ADDR_WIDTH - 1 : 0 ] pred_addr,
    output branch,

    input [`ADDR_WIDTH - 1 : 0 ] branch_addr,
    input [`ADDR_WIDTH - 1 : 0 ] update_addr,
    input isBranch
);

    ///BTB file
    reg [`ADDR_WIDTH-BTB_WIDTH - 2 - 1 : 0] btb_tag     [0 : BTB_SIZE - 1];
    reg [`ADDR_WIDTH - 2 - 1 : 0]           btb_target  [0 : BTB_SIZE - 1];
    reg [BTB_SIZE - 1 : 0]                  btb_valid   ;

    //lookup
    wire [BTB_WIDTH - 1 : 0] lookup_index   = lookup_addr[2 + BTB_WIDTH - 1 : 2];
    wire [`ADDR_WIDTH - BTB_WIDTH - 2 - 1 : 0] lookup_tag     = lookup_addr[`ADDR_WIDTH - 1 : BTB_WIDTH + 2];
    assign pred_addr    = {btb_target[lookup_index],2'b0};
    assign branch       = btb_valid[lookup_index] & ~|(btb_tag[lookup_index] ^ lookup_tag);

    //update
    wire [BTB_WIDTH - 1 : 0] update_index   = update_addr[2 + BTB_WIDTH - 1 : 2];
    wire [`ADDR_WIDTH - BTB_WIDTH - 2 - 1 : 0] update_tag     = update_addr[`ADDR_WIDTH - 1 : BTB_WIDTH + 2];

    always@(posedge clk)begin
        if (rst)
            btb_valid <= 0;
        else if (isBranch)
            btb_valid[update_index] <= 0;
    end

    always@(posedge clk)begin
        if (isBranch)
            btb_tag[update_index] <= update_tag;
    end
    
    always@(posedge clk)begin
        if (isBranch)
            btb_target[update_index] <= update_addr[`ADDR_WIDTH - 1 : 2];
    end
    

endmodule