`include "vsrc/include/width_param.sv"
import "DPI-C" function void dpi_pmem_read(output longint data, input longint addr, input bit en, input bit[3:0] rd_size);
import "DPI-C" function void dpi_pmem_write(input longint data, input longint addr, input bit en, input bit[3:0] wr_size);

module Core(
    input clock,
    input reset
);
    logic [`ADDR_WIDTH - 1 : 0] pc;

    branch_info_if br_info_if_0;
    InstFetch ifu_0(
        .clk(clock),
        .rst(reset),
        .pc(pc),
        .branch_info(br_info_if_0)
    );

endmodule:Core
