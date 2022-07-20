`include "vsrc/include/constant.sv"
module IF_ID(
    input rst,
    input clk,
    //if output
    input [`ADDR_WIDTH - 1 : 0] if_pc,
    //id input
    output [`ADDR_WIDTH - 1 : 0] id_pc
);

always_ff @(posedge clk)
begin
    if(rst==`RST_VALID)
        id_pc<=`ADDR_INVALID;
    else
        id_pc<=if_pc;
end
endmodule:IF_ID