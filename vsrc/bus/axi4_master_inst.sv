module axi4_master_inst(
    axi4_if.m axi4_master,
    cache_if.s icache_slave,
    input sram_cancel_rd
);



parameter STATE_IDLE_R = 3'b100;
parameter STATE_RADDR = 3'b101;
parameter STATE_RDATA = 3'b110;
parameter STATE_RREPAIR = 3'b111;

logic [2:0]read_state;
reg ram_rd_valid;
reg cancel_op;
reg [31 : 0] cancel_op_addr;
reg cancel_lock;
logic inst_rd_cache_line;
assign inst_rd_cache_line = icache_slave.rd_type==3'b100;   
/// read channels
assign axi4_master.ARREGION = 4'b0000;
assign axi4_master.ARLEN = inst_rd_cache_line ? 8'b11:8'b0;
assign axi4_master.ARSIZE = 3'b010;
assign axi4_master.ARBURST = 2'b01;
assign axi4_master.ARLOCK  = 0;
assign axi4_master.ARCACHE = 0;
assign axi4_master.ARPROT  = 0;
assign axi4_master.ARQOS = 4'b0000;

always_ff @(posedge axi4_master.ACLK)begin
    if (!axi4_master.ARESETn) begin
        read_state <= STATE_IDLE_R;
        axi4_master.ARID <=0;
        ram_rd_valid <= 0;
    end
    else
        case(read_state)
            STATE_IDLE_R:begin
                ram_rd_valid <= 0;
                 if(icache_slave.rd_req)begin
                    read_state <= STATE_RADDR;
                    axi4_master.ARADDR <= icache_slave.rd_addr;
                end
                else
                    read_state <= STATE_IDLE_R;
                
            end
            STATE_RADDR:begin
                axi4_master.ARID <= 0;
                if(axi4_master.ARVALID && axi4_master.ARREADY)begin
                    read_state <= STATE_RDATA;
                end
                else
                    read_state <= STATE_RADDR;
            end
            STATE_RDATA:begin
                if(axi4_master.RVALID && axi4_master.RLAST)begin
                        ram_rd_valid <=1'b1;
                        read_state <= cancel_op ? STATE_IDLE_R : STATE_RREPAIR;
                        icache_slave.ret_data <= axi4_master.RDATA;
                    end
                else if(axi4_master.RVALID)begin
                        ram_rd_valid <=1'b1;
                        read_state <= cancel_op ? STATE_RDATA : STATE_RREPAIR;
                        icache_slave.ret_data <= axi4_master.RDATA;
                    end
                else
                    read_state <= STATE_RDATA;

            end
            STATE_RREPAIR:begin
                ram_rd_valid <= 0;
                axi4_master.ARADDR <= icache_slave.rd_addr;
                read_state <= STATE_RADDR; 
            end
            default: read_state <= STATE_IDLE_R;
        endcase
end

wire clk = axi4_master.ACLK;
wire rst = !axi4_master.ARESETn;
always_ff@(posedge clk)begin
    if (rst)
        cancel_lock <= 0;
    else if (!cancel_op && !cancel_lock)begin
        cancel_lock <= 1;
        cancel_op_addr <= icache_slave.rd_addr;
    end if (cancel_op && cancel_lock)begin
        cancel_lock <= 0;
    end
end

always_ff@(posedge axi4_master.ACLK)begin
    if (!axi4_master.ARESETn)begin
        cancel_op <= 1;
    end else if(sram_cancel_rd)
        cancel_op <= 0;
    else if (ram_rd_valid)
        cancel_op <= 1;
end
assign axi4_master.ARVALID = read_state == STATE_RADDR;
assign axi4_master.RREADY = read_state == STATE_RDATA;

assign icache_slave.ret_last=axi4_master.RLAST;
assign icache_slave.ret_valid = cancel_op & ram_rd_valid;
assign icache_slave.rd_rdy = axi4_master.ARREADY;
endmodule:axi4_master_inst
