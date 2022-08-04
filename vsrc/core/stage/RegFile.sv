`include "width_param.sv"

module RegFile(
    input clk,
    input rst,
    input                           r1_en,
    input   [`REG_WIDTH-1:0]        r1_addr,
    output  [`DATA_WIDTH-1:0]       r1_data,
    input                           r2_en,
    input   [`REG_WIDTH-1:0]        r2_addr,
    output  [`DATA_WIDTH-1:0]       r2_data,

    input                           rw_en,
    input   [`REG_WIDTH-1:0]        rw_addr,
    input   [`DATA_WIDTH-1:0]       rw_data
);

    reg [`DATA_WIDTH - 1 : 0] reg_file [`REG_NUM-1:0];
    always_ff @(posedge clk ) begin : reg_write
        if ( rst ) begin
            integer i;
            for (i = 0; i < `REG_NUM; i = i + 1) begin
                reg_file[i] <= 0;
            end
        end else begin
            if ( rw_en && rw_addr != 0) begin
                reg_file[rw_addr] <= rw_data;
            end
        end
    end

    assign r1_data = r1_en ? reg_file[r1_addr] : 0;
    assign r2_data = r2_en ? reg_file[r2_addr] : 0;

endmodule
