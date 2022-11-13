module MMU(
    input clk,
    //inst addr trans from IF
    input  [31:0]   inst_vaddr,
    input           inst_dmw0_en,
    input           inst_dmw1_en,
    output [ 7:0]   inst_index,
    output [19:0]   inst_tag,
    output [ 3:0]   inst_offest,
    //from csr
    input           csr_crmd_da,
    input           csr_crmd_pg,
    input  [31:0]   csr_dmw0,
    input  [31:0]   csr_dmw1,

);

    wire pg_mode = !csr_crmd_da &&  csr_crmd_pg;
    wire da_mode =  csr_crmd_da && !csr_crmd_pg;

    wire [31:0] inst_paddr;
    assign inst_paddr = (pg_mode && inst_dmw0_en) ? {csr_dmw0[27:25], inst_vaddr[28:0]} :
                        (pg_mode && inst_dmw1_en) ? {csr_dmw1[27:25], inst_vaddr[28:0]} :
                        inst_vaddr;
    assign inst_tag     = inst_paddr[31:12];
    assign inst_index   = inst_paddr[11:4];
    assign inst_offest  = inst_paddr[3:0];

endmodule