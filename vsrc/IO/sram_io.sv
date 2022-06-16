interface sram;

    //read
    logic [DATA_WIDTH - 1:0] sram_rd_data;
    logic [ADDR_WIDTH - 1:0] sram_rd_addr;
    logic sram_rd_en;
    logic sram_rd_valid

    //write
    logic sram_wr_en;
    logic [ADDR_WIDTH - 1:0] sram_wr_addr;
    logic [DATA_WIDTH - 1:0] sram_wr_data;
    logic [`NUM_OF_BYTES - 1 : 0] w_mask;

    modport m (
        output sram_rd_addr,
        output sram_rd_en,
        input   sram_rd_valid,
        input   sram_rd_data,

        output sram_wr_addr,
        output sram_wr_en,
        output sram_wr_data,
        output sram_mask
    )



endinterface:sram