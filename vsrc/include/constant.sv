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
`define ecode_non      6'h3e
`define ecode_int      6'h00
`define ecode_pil      6'h01
`define ecode_pis      6'h02
`define ecode_pif      6'h03
`define ecode_pme      6'h04
`define ecode_ppi      6'h07
`define ecode_adef     6'h08
`define ecode_adem     6'h08
`define ecode_ale      6'h09
`define ecode_sys      6'h0b
`define ecode_brk      6'h0c
`define ecode_ine      6'h0d
`define ecode_ipe      6'h0e
`define ecode_fpd      6'h0f
`define ecode_fpe      6'h12
`define ecode_tlbr     6'h3f
