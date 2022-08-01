//operation
//1.3r
`define ADD_W   6'b100000
`define SUB_W   6'b100010
`define SLT     6'b100100
`define SLTU    6'b100101
`define NOR     6'b101000
`define AND     6'b101001
`define OR      6'b101010
`define XOR     6'b101011
`define SLL_W   6'b101110
`define SRL_W   6'b101111
`define SRA_W   6'b110000
`define MUL_W   6'b111000
`define MULH_W  6'b111001
`define MULH_WU 6'b111010
`define DIV_W   6'b000000
`define MOD_W   6'b000001
`define DIV_WU  6'b000010
`define MOD_WU  6'b000011
//2.ui5
`define SLLI_W  2'b00
`define SRLI_W  2'b01
`define SRAI_W  2'b10
//3.si12
`define SLTI    3'b000
`define SLTUI   3'b001
`define ADDI_W  3'b010
`define ANDI    3'b101
`define ORI     3'b110
`define XORI    3'b111

//branch
`define JIRL 4'b0011
`define B    4'b0100
`define BL   4'b0101
`define BEQ  4'b0110
`define BNE  4'b0111
`define BLT  4'b1000
`define BGE  4'b1001
`define BLTU 4'b1010
`define BGEU 4'b1011

//si20
`define LU12I     3'b010
`define PCADDU12I 3'b110

//except
`define BREAK     17'b00000000001010100
`define SYSCALL   17'b00000000001010110