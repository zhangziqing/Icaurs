`include "width_param.sv"
interface cache_if;

    //read
    logic                        rd_req;
    logic [  2:0]                rd_typ;
    logic [`ADDR_WIDTH - 1:0]    rd_addr;
    logic                        rd_rdy;
    logic                        ret_valid;
    logic                        ret_last;
    logic  [`DATA_WIDTH - 1:0]   ret_data;
    
    //write
    logic                        wr_req;
    logic [  2:0]                wr_type;
    logic [`ADDR_WIDTH - 1:0]    wr_addr;
    logic [`NUM_OF_BYTES - 1 :0] wr_wstrb;
    logic [127:0]                wr_data;
    logic                        wr_rdy;

    modport m (
        output         rd_req,
        output         rd_type,
        output         rd_addr,
        input          rd_rdy,
        input          ret_valid,
        input          ret_last,
        input          ret_data,

        output         wr_req,
        output         wr_type,
        output         wr_addr,
        output         wr_wstrb,
        output         wr_data, 
        input          wr_rdy
    );
    modport s (
        input          rd_req,
        input          rd_type,
        input          rd_addr,
        output         rd_rdy,
        output         ret_valid,
        output         ret_last,
        output         ret_data,
        input          wr_req,
        input          wr_type,
        input          wr_addr,
        input          wr_wstrb,
        input          wr_data, 
        output         wr_rdy
    );


endinterface:cache
