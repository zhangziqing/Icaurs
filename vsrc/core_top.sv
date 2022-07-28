module core_top(
    input           aclk,
    input           aresetn,
    input    [ 7:0] intrpt, 
    //AXI interface 
    //read reqest
    output   [ 3:0] arid,
    output   [31:0] araddr,
    output   [ 7:0] arlen,
    output   [ 2:0] arsize,
    output   [ 1:0] arburst,
    output   [ 1:0] arlock,
    output   [ 3:0] arcache,
    output   [ 2:0] arprot,
    output          arvalid,
    input           arready,
    //read back
    input    [ 3:0] rid,
    input    [31:0] rdata,
    input    [ 1:0] rresp,
    input           rlast,
    input           rvalid,
    output          rready,
    //write request
    output   [ 3:0] awid,
    output   [31:0] awaddr,
    output   [ 7:0] awlen,
    output   [ 2:0] awsize,
    output   [ 1:0] awburst,
    output   [ 1:0] awlock,
    output   [ 3:0] awcache,
    output   [ 2:0] awprot,
    output          awvalid,
    input           awready,
    //write data
    output   [ 3:0] wid,
    output   [31:0] wdata,
    output   [ 3:0] wstrb,
    output          wlast,
    output          wvalid,
    input           wready,
    //write back
    input    [ 3:0] bid,
    input    [ 1:0] bresp,
    input           bvalid,
    output          bready,
    //debug info
    output [31:0] debug0_wb_pc,
    output [ 3:0] debug0_wb_rf_wen,
    output [ 4:0] debug0_wb_rf_wnum,
    output [31:0] debug0_wb_rf_wdata
);

    sram_io iram,dram;
    Core core_inst(
        .iram(iram),
        .dram(dram),
        .clock(aclk),
        .reset(!aresetn),
        .debug0_wb_pc(debug0_wb_pc),
        .debug0_wb_rf_wdata(debug0_wb_rf_wdata),
        .debug0_wb_rf_wen(debug0_wb_rf_wen),
        .debug0_wb_rf_wnum(debug0_wb_rf_wnum)
    );

    axi4_if i_axi_port, d_axi_port;
    axi4_master_data d_axi_bridge(
        .data_sram_slave(dram),
        .axi4_master(d_axi_port)
    );

    axi4_master_inst i_axi_bridge(
        .axi4_master(i_axi_port),
        .inst_sram_slave(iram)
    );
endmodule