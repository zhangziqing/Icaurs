`include "operation.sv"    
`define RST_VALID 1'b1
`define RST_INVALID 1'b0

`define EN_VALID 1'b1
`define EN_INVALID 1'b0

`define DATA_INVALID 32'b0
`define ADDR_INVALID 32'b0

`define REG_ADDR_INVALID 5'b0

//id_stage_if
`define LSU_OP_INVALID 4'b1111
`define EX_OP_INVALID `ALU_INVALID
`define CSR_OP_INVALID 3'b000

//csr 
`define CSR_ADDR_INVALID 14'hffff
//1.csr except ecode
`define excepttype_non      32'h00000000
`define excepttype_int      32'h00000000
`define excepttype_pil      32'h00000001
`define excepttype_pis      32'h00000002
`define excepttype_pif      32'h00000003
`define excepttype_pme      32'h00000004
`define excepttype_ppi      32'h00000007
`define excepttype_adef     32'h00000008
`define excepttype_adem     32'h00000108
`define excepttype_ale      32'h00000009
`define excepttype_sys      32'h0000000b
`define excepttype_brk      32'h0000000c
`define excepttype_ine      32'h0000000d
`define excepttype_ipe      32'h0000000e
`define excepttype_fpd      32'h0000000f
`define excepttype_fpe      32'h00000012
`define excepttype_tlbr     32'h0000003f