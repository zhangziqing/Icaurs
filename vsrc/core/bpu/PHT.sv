module PHT#(
    PHT_WIDTH   = 6
)(
    input clk,
    input rst,

    input [PHT_WIDTH - 1 : 0] lookup_addr,
    output pred_taken,

    input branch_en,
    input [PHT_WIDTH - 1 : 0] update_addr,
    input taken
);


    /*
        00 : strong not take
        01 : weak not take
        10 : weak take
        11 : strong take
    */
    parameter PHT_SIZE = 1 << PHT_WIDTH;
    reg [1:0] pht_entry [0 : PHT_SIZE - 1];

    wire phte_add = ~&pht_entry[update_addr] & taken; 
    wire phte_sub = |pht_entry[update_addr] & ~taken;
    integer i;
    always_ff @(posedge clk)begin
        if (rst)begin
            for (i = 0; i < PHT_SIZE; i = i + 1 )begin
                pht_entry[i] <= 2'b00;
            end 
        end else if (branch_en)begin
            if (phte_add)begin
                pht_entry[update_addr] <= pht_entry[update_addr] + 1;
            end if (phte_sub)begin
                pht_entry[update_addr] <= pht_entry[update_addr] - 1;
            end
        end
    end 

    assign pred_taken = pht_entry[lookup_addr][1];

endmodule