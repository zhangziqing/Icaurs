`define ALU_OP_WIDTH 6
`define ALU_ADD  6'b000000
`define ALU_SUB  6'b000001
`define ALU_AND  6'b000010
`define ALU_OR   6'b000100
`define ALU_NOR  6'b000110
`define ALU_XOR  6'b001000
`define ALU_SLL  6'b001010
`define ALU_SRL  6'b001110
`define ALU_SRA  6'b011110
`define ALU_SLT  6'b001101
`define ALU_SLTU 6'b000101

`define ALU_DIV  6'b100011
`define ALU_MOD  6'b100111
`define ALU_MUL  6'b100110
`define ALU_MULH 6'b100010

`define ALU_INVALID 6'b011111