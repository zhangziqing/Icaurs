module RegFile(
    input clk,
    input reset,
    input                       rs_en,
    input [`REG_WIDTH-1:0]      rs_addr,
    output [`DATA_WIDTH-1:0]    rs_data,
    input                       rt_en,
    input [`REG_WIDTH-1:0]      rt_addr,
    output [`DATA_WIDTH-1:0]    rt_data,

    input                       rd_en
    input [`REG_WIDTH-1:0]      rd_addr,
    input [`DATA_WIDTH-1:0]     rd_data
);

    reg [`REG_WIDTH-1:0] reg_file [`REG_NUM-1:0];
    always_ff @(posedge clk ) begin : reg_write
        if ( reset ) begin
            integer i;
            for (i = 0; i < `REG_NUM; i = i + 1) begin
                reg_file[i] <= 0;
            end
        end else begin
            if ( rd_en && rd_addr != 0) begin
                reg_file[rd_addr] <= rd_data;
            end
        end
    end

    assgin rs_data = rs_en ? reg_file[rs_addr] : 0;
    assgin rt_data = rt_en ? reg_file[rt_addr] : 0;

endmodule