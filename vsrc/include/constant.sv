`define RST_VALID 1'b1
`define RST_INVALID 1'b0

`define EN_VALID 1'b1
`define EN_INVALID 1'b0

`define DATA_INVALID 32'h0
`define ADDR_INVALID 32'h0

//id_stage_if
`define LSU_OP_INVALID 4'b1111
`define EX_OP_INVALID `ALU_INVALID
`define CSR_OP_INVALID 3'b000