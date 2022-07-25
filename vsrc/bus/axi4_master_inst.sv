module axi4_master_inst(
    axi4_if.m axi4_master,
    sram_if.s inst_sram_slave
);



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
                inst_sram_slave.sram_rd_valid <= 0;
                inst_sram_slave.sram_rd_data <= 32'b0;
                if(inst_sram_slave.sram_rd_en)begin
                    read_state <= STATE_RADDR;
                    
                end
                else
                    read_state <= STATE_IDLE_R;
                
            end
            STATE_RADDR:begin
                axi4_master.ARVALID <= 1'b1;
                axi4_master.ARADDR <= inst_sram_slave.sram_rd_addr;
                axi4_master.ARID <= 0;
                if(axi4_master.ARVALID && axi4_master.ARREADY && inst_sram_slave.sram_rd_en)begin
                    
                    read_state <= STATE_RDATA;
                    
                end
                else
                    read_state <= STATE_WADDR;
            end
            STATE_RDATA:begin
                axi4_master.ARVALID <= 1'b0;
                axi4_master.rid <= 1'b0;
                if(axi4_master.RVALID && axi4_master.RLAST && inst_sram_slave.sram_rd_en)begin
                        axi4_master.RREADY <= 1'b1;
                        inst_sram_slave.sram_rd_valid <=1'b1;
                        read_state <= STATE_IDLE_R;
                        inst_sram_slave.sram_rd_data <= RDATA;
                    end
                else
                    read_state <= STATE_RDATA;
                    
            end
            default: read_state <= STATE_IDLE_R;
        endcase
end


endmodule:axi4_master_inst