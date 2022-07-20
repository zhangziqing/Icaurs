module axi4_master_data(

    axi4_if.m axi4_master,
    sram_if.s data_sram_slave,
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
assign axi4_master.BID = 1;

parameter STATE_IDLE_W = 3'b000;
parameter STATE_WADDR = 3'b001;
parameter STATE_WDATA = 3'b010;
parameter STATE_WRESP = 3'b011;

logic [2:0] write_state;

always_ff @(posedge axi4_master.ACLK) begin
    if (!axi4_master.ARESETn) begin
        write_state <= STATE_IDLE_W;
        axi4_master.AWVALID <= 1'b0;
        axi4_master.WVALID <= 1'b0;
        axi4_master.WLAST <= 1'b0;
        axi4_master.BREADY <= 1'b0;
    end
    
    else 
        case(write_state)
            STATE_IDLE_W:begin
                axi4_master.AWVALID <= 1'b0;
                axi4_master.WVALID <= 1'b0;
                axi4_master.BREADY <= 1'b0;
                axi4_master.AWADDR <=32'b0;
                axi4_master.WDATA <=32'b0;
                if(data_sram_slave.sram_wr_en)begin
                    write_state <=  STATE_WADDR;
                end
                else
                    write_state <=  STATE_IDLE_W;
            end
            STATE_WADDR:begin
                axi4_master.AWVALID <= 1'b1;
                axi4_master.AWADDR <= data_sram_slave.sram_wr_addr;
                if(axi4_master.AWREADY && axi4_master.AWVALID && data_sram_slave.sram_wr_en)begin
                    
                    write_state <= STATE_WDATA;
                    
                end
                else
                    write_state <= STATE_WADDR;
            end
            STATE_WDATA:begin
                axi4_master.WVALID <= 1'b1;
                axi4_master.AWVALID <= 1'b0;
                axi4_master.AWADDR <=32'b0;
                axi4_master.WDATA <= data_sram_slave.sram_wr_data;
                if(axi4_master.WREADY && axi4_master.WVALID && data_sram_slave.sram_wr_en)begin
                    axi4_master.WLAST <= 1'b1;
                    
                    axi4_master.WSTRB <= data_sram_slave.sram_mask;
                    write_state <= STATE_WRESP;
                end
                else
                    write_state <= STATE_WDATA;
            end
            STATE_WRESP:begin
                axi4_master.WDATA <=32'b0;
                axi4_master.WVALID <=0;
                axi4_master.WLAST <=0;
                if(axi4_master.BVALID)begin
                    axi4_master.BREADY <= 1'b1;
                    write_state <= STATE_IDLE_W;
                end
                else
                    write_state <= STATE_WRESP;
            end
            default: write_state <= STATE_IDLE_W;
        endcase
end

parameter STATE_IDLE_R = 3'b100;
parameter STATE_RADDR = 3'b101;
parameter STATE_RDATA = 3'b110;

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
assign axi4_master.RREADY = 1'b1;

always_ff @(posedge axi4_master.ACLK)begin
    if (!axi4_master.ARESETn) begin
        read_state <= STATE_IDLE_R;
        axi4_master.ARVALID <= 1'b0;
        axi4_master.ARVALID<= 0;
        axi4_master.ARID <=0;
        axi4_master.ARVALID <= 1'b0;
        axi4_master.RREADY<=0;
    end
    else
        case(read_state)
            STATE_IDLE_R:begin
                axi4_master.RREADY <= 1'b0;
                data_sram_slave.sram_rd_valid <= 0;
                data_sram_slave.sram_rd_data <= 32'b0;
                if(data_sram_slave.sram_rd_en)begin
                    read_state <= STATE_RADDR;
                    
                end
                else
                    read_state <= STATE_IDLE_R;
                
            end
            STATE_RADDR:begin
                axi4_master.ARVALID <= 1'b1;
                axi4_master.ARADDR <= data_sram_slave.sram_rd_addr;
                axi4_master.ARID <= 1;
                if(axi4_master.ARVALID && axi4_master.ARREADY && data_sram_slave.sram_rd_en)begin
                    
                    read_state <= STATE_RDATA;
                    
                end
                else
                    read_state <= STATE_WADDR;
            end
            STATE_RDATA:begin
                axi4_master.ARVALID <= 1'b0;
                axi4_master.rid <= 1'b1;
                if(axi4_master.RVALID && axi4_master.RLAST && data_sram_slave.sram_rd_en)begin
                        axi4_master.RREADY <= 1'b1;
                        data_sram_slave.sram_rd_valid <=1'b1;
                        read_state <= STATE_IDLE_R;
                        data_sram_slave.sram_rd_data <= RDATA;
                    end
                else
                    read_state <= STATE_RDATA;
                    
            end
            default: read_state <= STATE_IDLE_R;
        endcase
end


endmodule:axi4_master_data