module axi4_master_data(
    axi4_if.m axi4_master,
    sram_if.s data_sram_slave
);

//write address channel
assign axi4_master.AWID = 1;
assign axi4_master.AWREGION = 4'b0000;
assign axi4_master.AWLEN = 0;
assign axi4_master.AWSIZE = 3'b010;
assign axi4_master.AWBURST = 2'b01;
assign axi4_master.AWLOCK  = 0;
assign axi4_master.AWCACHE = 0;
assign axi4_master.AWPROT  = 0;
assign axi4_master.AWQOS =4'b0000;

//write data channel
assign axi4_master.WID = 1;

parameter STATE_IDLE_W = 3'b000;
parameter STATE_WADDR = 3'b001;
parameter STATE_WDATA = 3'b010;
parameter STATE_WRESP = 3'b011;

logic [2:0] write_state;

wire hazard = (~|(axi4_master.AWADDR ^ axi4_master.ARADDR)) & data_sram_slave.sram_wr_busy;
always_ff @(posedge axi4_master.ACLK) begin
    if (!axi4_master.ARESETn) begin
        write_state <= STATE_IDLE_W;
    end
    else 
        case(write_state)
            STATE_IDLE_W:begin
                if(data_sram_slave.sram_wr_en)begin
                    axi4_master.AWADDR <= data_sram_slave.sram_wr_addr;
                    axi4_master.WDATA  <= data_sram_slave.sram_wr_data;
                    axi4_master.WSTRB  <= data_sram_slave.sram_wr_mask;
                    write_state <=  STATE_WADDR;
                end
                else
                    write_state <=  STATE_IDLE_W;
            end
            STATE_WADDR:begin
                if(axi4_master.AWREADY && axi4_master.AWVALID)begin    
                    write_state <= STATE_WDATA;
                end
                else
                    write_state <= STATE_WADDR;
            end
            STATE_WDATA:begin
                if(axi4_master.WREADY && axi4_master.WVALID)begin
                    write_state <= STATE_WRESP;
                end
                else
                    write_state <= STATE_WDATA;
            end
            STATE_WRESP:begin
                if(axi4_master.BVALID)begin
                    write_state <= STATE_IDLE_W;
                end
                else
                    write_state <= STATE_WRESP;
            end
            default: write_state <= STATE_IDLE_W;
        endcase
end
assign data_sram_slave.sram_wr_busy = write_state != STATE_IDLE_W;
assign axi4_master.AWVALID = write_state == STATE_WADDR;
assign axi4_master.WVALID = write_state == STATE_WDATA;
assign axi4_master.BREADY = write_state == STATE_WRESP;
assign axi4_master.WLAST  = axi4_master.WVALID;

parameter STATE_IDLE_R = 3'b100;
parameter STATE_RADDR = 3'b101;
parameter STATE_RDATA = 3'b110;
parameter STATE_RWAIT = 3'b111;

logic [2:0]read_state;

/// read channels
assign axi4_master.ARREGION = 4'b0000;
assign axi4_master.ARLEN = 0;
assign axi4_master.ARSIZE = 3'b010;
assign axi4_master.ARBURST = 2'b01;
assign axi4_master.ARLOCK  = 0;
assign axi4_master.ARCACHE = 0;
assign axi4_master.ARPROT  = 0;
assign axi4_master.ARQOS = 4'b0000;

always_ff @(posedge axi4_master.ACLK)begin
    if (!axi4_master.ARESETn) begin
        read_state <= STATE_IDLE_R;
    end
    else
        case(read_state)
            STATE_IDLE_R:begin
                data_sram_slave.sram_rd_valid <= 0;
                if(data_sram_slave.sram_rd_en)begin
                    read_state <= hazard ? STATE_RWAIT : STATE_RADDR;
                    axi4_master.ARADDR <= data_sram_slave.sram_rd_addr;
                end
                else
                    read_state <= STATE_IDLE_R;
            end
            STATE_RADDR:begin
                if(axi4_master.ARREADY)begin
                    read_state <= STATE_RDATA;
                end
                else
                    read_state <= STATE_RADDR;
            end
            STATE_RDATA:begin
                if(axi4_master.RVALID && axi4_master.RLAST)begin
                        data_sram_slave.sram_rd_valid <=1'b1;
                        read_state <= STATE_IDLE_R;
                        data_sram_slave.sram_rd_data <= axi4_master.RDATA;
                    end
                else
                    read_state <= STATE_RDATA;
            end
            STATE_RWAIT:begin
                if(!hazard)
                    read_state <= STATE_RADDR;
            end
            default: read_state <= STATE_IDLE_R;
        endcase
end
assign axi4_master.ARVALID  = read_state == STATE_RADDR;
assign axi4_master.RREADY   = read_state == STATE_RDATA; 
endmodule:axi4_master_data