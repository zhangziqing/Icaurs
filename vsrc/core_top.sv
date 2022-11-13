`include "width_param.sv"

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

    sram_if iram,dram;
    axi4_if i_axi_port(
        .ACLK(aclk),
        .ARESETn(aresetn)
    );
    Core core_inst(
        .iram(iram),
        .dram(dram),
	.AXI_icache(i_axi_port),
        .clock(aclk),
        .reset(!aresetn),
        .hw_int(0),
        .debug0_wb_pc(debug0_wb_pc),
        .debug0_wb_rf_wdata(debug0_wb_rf_wdata),
        .debug0_wb_rf_wen(debug0_wb_rf_wen),
        .debug0_wb_rf_wnum(debug0_wb_rf_wnum)
    );
    parameter   DATA_WIDTH  = 32,             
                ADDR_WIDTH  = 32,                             
                ID_WIDTH    = 1,               
                USER_WIDTH  = 1,             
                STRB_WIDTH  = (DATA_WIDTH/8);
    
    //写响应通道
	wire     [ID_WIDTH-1:0]	    m_BID;
	wire     [1:0]	            m_BRESP;
	wire     [USER_WIDTH-1:0]   m_BUSER;
    //读数据通道
	wire     [ID_WIDTH-1:0]     m_RID;
	wire     [DATA_WIDTH-1:0]   m_RDATA;
	wire     [1:0]	            m_RRESP;
    wire                        m_RLAST;
	wire     [USER_WIDTH-1:0]	m_RUSER;

    axi4_if d_axi_port(
        .ACLK(aclk),
        .ARESETn(aresetn)
    );
    axi4_master_data d_axi_bridge(
        .data_sram_slave(dram),
        .axi4_master(d_axi_port)
    );

    axi4_master_inst i_axi_bridge(
        .axi4_master(i_axi_port),
        .inst_sram_slave(iram)
    );

    AXI_Interconnect #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .USER_WIDTH(USER_WIDTH),
        .STRB_WIDTH(STRB_WIDTH)
    ) axi_bridge_1x2 (
        .ACLK(aclk),
        .ARESETn(aresetn),
        /////////////////////// inst
        .m0_AWID(i_axi_port.AWID),
        .m0_AWADDR(i_axi_port.AWADDR),
        .m0_AWLEN(i_axi_port.AWLEN),
        .m0_AWSIZE(i_axi_port.AWSIZE),
        .m0_AWBURST(i_axi_port.AWBURST),
        .m0_AWCACHE(i_axi_port.AWCACHE),
        .m0_AWPROT(i_axi_port.AWPROT),
        .m0_AWQOS(i_axi_port.AWQOS),
        .m0_AWREGION(i_axi_port.AWREGION),
        .m0_AWUSER(),
        .m0_AWVALID(i_axi_port.AWVALID),
        .m0_AWREADY(i_axi_port.AWREADY),
        .m0_WID(i_axi_port.WID),
        .m0_WDATA(i_axi_port.WDATA),
        .m0_WSTRB(i_axi_port.WSTRB),
        .m0_WLAST(i_axi_port.WLAST),
        .m0_WUSER(),
        .m0_WVALID(i_axi_port.WVALID),
        .m0_WREADY(i_axi_port.WREADY),
        .m0_BVALID(i_axi_port.BVALID),
        .m0_BREADY(i_axi_port.BREADY),
        .m0_ARID(i_axi_port.ARID),
        .m0_ARADDR(i_axi_port.ARADDR),
        .m0_ARLEN(i_axi_port.ARLEN),
        .m0_ARSIZE(i_axi_port.ARSIZE),
        .m0_ARBURST(i_axi_port.ARBURST),
        .m0_ARLOCK(i_axi_port.ARLOCK),
        .m0_ARCACHE(i_axi_port.ARCACHE),
        .m0_ARPROT(i_axi_port.ARPROT),
        .m0_ARQOS(i_axi_port.ARQOS),
        .m0_ARREGION(i_axi_port.ARREGION),
        .m0_ARUSER(),
        .m0_ARVALID(i_axi_port.ARVALID),
        .m0_ARREADY(i_axi_port.ARREADY),
        .m0_RVALID(i_axi_port.RVALID),
        .m0_RREADY(i_axi_port.RREADY),

        /////////////////////////////// data,
        .m1_AWID(d_axi_port.AWID),
        .m1_AWADDR(d_axi_port.AWADDR),
        .m1_AWLEN(d_axi_port.AWLEN),
        .m1_AWSIZE(d_axi_port.AWSIZE),
        .m1_AWBURST(d_axi_port.AWBURST),
        .m1_AWCACHE(d_axi_port.AWCACHE),
        .m1_AWPROT(d_axi_port.AWPROT),
        .m1_AWQOS(d_axi_port.AWQOS),
        .m1_AWREGION(d_axi_port.AWREGION),
        .m1_AWUSER(),
        .m1_AWVALID(d_axi_port.AWVALID),
        .m1_AWREADY(d_axi_port.AWREADY),
        .m1_WID(d_axi_port.WID),
        .m1_WDATA(d_axi_port.WDATA),
        .m1_WSTRB(d_axi_port.WSTRB),
        .m1_WLAST(d_axi_port.WLAST),
        .m1_WUSER(),
        .m1_WVALID(d_axi_port.WVALID),
        .m1_WREADY(d_axi_port.WREADY),
        .m1_BVALID(d_axi_port.BVALID),
        .m1_BREADY(d_axi_port.BREADY),
        .m1_ARID(d_axi_port.ARID),
        .m1_ARADDR(d_axi_port.ARADDR),
        .m1_ARLEN(d_axi_port.ARLEN),
        .m1_ARSIZE(d_axi_port.ARSIZE),
        .m1_ARBURST(d_axi_port.ARBURST),
        .m1_ARLOCK(d_axi_port.ARLOCK),
        .m1_ARCACHE(d_axi_port.ARCACHE),
        .m1_ARPROT(d_axi_port.ARPROT),
        .m1_ARQOS(d_axi_port.ARQOS),
        .m1_ARREGION(d_axi_port.ARREGION),
        .m1_ARUSER(),
        .m1_ARVALID(d_axi_port.ARVALID),
        .m1_ARREADY(d_axi_port.ARREADY),
        .m1_RVALID(d_axi_port.RVALID),
        .m1_RREADY(d_axi_port.RREADY),
        
        .m_BID(m_BID),
        .m_BRESP(m_BRESP),
        .m_BUSER(m_BUSER),
        .m_RID(m_RID),
        .m_RDATA(m_RDATA),
        .m_RRESP(m_RRESP),
        .m_RLAST(m_RLAST),
        .m_RUSER(m_RUSER),

		.s0_AWVALID(awvalid),
		.s0_AWREADY(awready),
    //写数据通道
		.s0_WVALID(wvalid),
		.s0_WREADY(wready),
    //写响应通道
		.s0_BID(bid),
		.s0_BRESP(bresp),
		.s0_BUSER(0),
		.s0_BVALID(bvalid),
		.s0_BREADY(bready),
    //读地址通道
		.s0_ARVALID(arvalid),
		.s0_ARREADY(arready),
    //读数据通道
		.s0_RID(rid),
		.s0_RDATA(rdata),
		.s0_RRESP(rresp),
		.s0_RLAST(rlast),
		.s0_RUSER(0),
		.s0_RVALID(rvalid), 
		.s0_RREADY(rready), 
   
    /******** 从机通用信号 ********/
    //写地址通道
		.s_AWID(awid),
		.s_AWADDR(awaddr),
		.s_AWLEN(awlen),
		.s_AWSIZE(awsize),
		.s_AWBURST(awburst),
		.s_AWLOCK(awlock),
		.s_AWCACHE(awcache),
		.s_AWPROT(awprot),
		.s_AWQOS(),
		.s_AWREGION(),
		.s_AWUSER(),  
    //写数据通道
		.s_WID(wid),
		.s_WDATA(wdata),
		.s_WSTRB(wstrb),
		.s_WLAST(wlast),
		.s_WUSER(),
    //读地址通道
		.s_ARID(arid),    
		.s_ARADDR(araddr),
		.s_ARLEN(arlen),
		.s_ARSIZE(arsize),
		.s_ARBURST(arburst),
		.s_ARLOCK(arlock),
		.s_ARCACHE(arcache),
		.s_ARPROT(arprot),
		.s_ARQOS(),
		.s_ARREGION(),
		.s_ARUSER()
    );

    assign i_axi_port.BID   = m_BID;
    assign i_axi_port.BRESP = m_BRESP;
    assign i_axi_port.RID   = m_RID;
    assign i_axi_port.RDATA = m_RDATA;
    assign i_axi_port.RRESP = m_RRESP;
    assign i_axi_port.RLAST = m_RLAST;

    assign d_axi_port.BID   = m_BID;
    assign d_axi_port.BRESP = m_BRESP;
    assign d_axi_port.RID   = m_RID;
    assign d_axi_port.RDATA = m_RDATA;
    assign d_axi_port.RRESP = m_RRESP;
    assign d_axi_port.RLAST = m_RLAST;

    //difftest
    reg cmt_valid ;
    reg [`ADDR_WIDTH - 1 : 0] cmt_pc   ;
    reg [`DATA_WIDTH - 1 : 0] cmt_inst ;
    reg cmt_tlbfill_en ;
    reg cmt_tlb_index ;
    reg cmt_cnt_inst ;
    reg cmt_timer_64 ;
    reg cmt_wen      ;
    reg cmt_wdest    ;
    reg cmt_wdata    ;
    reg cmt_csr_rstat_en   ;
    reg cmt_csr_data       ;

    always @(posedge aclk)begin
        cmt_valid <= core_inst.wb_valid ;
        cmt_pc    <= core_inst.wb_info.pc   ;
        cmt_inst <=  0 ;
        cmt_tlbfill_en <= 0                 ;
        cmt_tlb_index  <= 0                 ;
        cmt_cnt_inst   <= 0                 ;
        cmt_timer_64   <= 0                 ;
        cmt_wen <=  core_inst.rw_en     ;
        cmt_wdest <= core_inst.rw_addr    ;
        cmt_wdata <= core_inst.rw_data    ;
        cmt_csr_rstat_en <= 0  ;
        cmt_csr_data <=     0  ; 
    end
    
    DifftestInstrCommit DifftestInstrCommit(
    .clock              (aclk           ),
    .coreid             (0              ),
    .index              (0              ),
    .valid              (cmt_valid      ),
    .pc                 (cmt_pc         ),
    .instr              (cmt_inst       ),
    .skip               (0              ),
    .is_TLBFILL         (cmt_tlbfill_en ),
    .TLBFILL_index      (cmt_tlb_index ),
    .is_CNTinst         (cmt_cnt_inst   ),
    .timer_64_value     (cmt_timer_64   ),
    .wen                (cmt_wen        ),
    .wdest              (cmt_wdest      ),
    .wdata              (cmt_wdata      ),
    .csr_rstat          (cmt_csr_rstat_en),
    .csr_data           (cmt_csr_data   )
);

    wire cmt_excp_flush = 0;
    wire cmt_ertn       = 0;
    wire cmt_estat_diff_0   = 0;
    wire cmt_csr_ecode  = 0;

DifftestExcpEvent DifftestExcpEvent(
    .clock              (aclk           ),
    .coreid             (0              ),
    .excp_valid         (cmt_excp_flush ),
    .eret               (cmt_ertn       ),
    .intrNo             (csr_estat_diff_0[12:2]),
    .cause              (cmt_csr_ecode  ),
    .exceptionPC        (cmt_pc         ),
    .exceptionInst      (cmt_inst       )
);
    wire trap = 0;
    wire trap_code = 0;
    wire cycleCnt = 0;
    wire instrCnt = 0;
DifftestTrapEvent DifftestTrapEvent(
    .clock              (aclk           ),
    .coreid             (0              ),
    .valid              (trap           ),
    .code               (trap_code      ),
    .pc                 (cmt_pc         ),
    .cycleCnt           (cycleCnt       ),
    .instrCnt           (instrCnt       )
);

reg [`DATA_WIDTH - 1 : 0] cmt_inst_st_en;
reg [`DATA_WIDTH - 1 : 0] cmt_st_paddr;
reg [`DATA_WIDTH - 1 : 0] cmt_st_vaddr;
reg [`DATA_WIDTH - 1 : 0] cmt_st_data;

always_ff @(posedge aclk)begin
    cmt_inst_st_en = core_inst.lsu_info_wb.st_valid;
    cmt_st_paddr   = core_inst.lsu_info_wb.st_paddr;
    cmt_st_vaddr   = core_inst.lsu_info_wb.st_paddr;
    cmt_st_data    = core_inst.lsu_info_wb.st_data;
end 

DifftestStoreEvent DifftestStoreEvent(
    .clock              (aclk           ),
    .coreid             (0              ),
    .index              (0              ),
    .valid              (cmt_inst_st_en ),
    .storePAddr         (cmt_st_paddr   ),
    .storeVAddr         (cmt_st_vaddr   ),
    .storeData          (cmt_st_data    )
);

reg [7 : 0] cmt_inst_ld_en;
reg [`DATA_WIDTH - 1 : 0] cmt_ld_paddr;
reg [`DATA_WIDTH - 1 : 0] cmt_ld_vaddr;
always_ff @(posedge aclk)begin
    cmt_inst_ld_en = core_inst.lsu_info_wb.ld_valid;
    cmt_ld_paddr   = core_inst.lsu_info_wb.ld_paddr;
    cmt_ld_vaddr   = core_inst.lsu_info_wb.ld_paddr;
end 

DifftestLoadEvent DifftestLoadEvent(
    .clock              (aclk           ),
    .coreid             (0              ),
    .index              (0              ),
    .valid              (cmt_inst_ld_en ),
    .paddr              (cmt_ld_paddr   ),
    .vaddr              (cmt_ld_vaddr   )
);

	wire [`DATA_WIDTH - 1 : 0]	csr_crmd_diff_0= 32'h00000008;
	wire [`DATA_WIDTH - 1 : 0]	csr_prmd_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_ectl_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_estat_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_era_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_badv_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_eentry_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_tlbidx_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_tlbehi_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_tlbelo0_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_tlbelo1_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_asid_diff_0= 32'h000a0000;
	wire [`DATA_WIDTH - 1 : 0]	csr_pgdl_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_pgdh_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_save0_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_save1_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_save2_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_save3_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_tid_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_tcfg_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_tval_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_ticlr_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_llbctl_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_tlbrentry_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_dmw0_diff_0= 0;
	wire [`DATA_WIDTH - 1 : 0]	csr_dmw1_diff_0= 0;
DifftestCSRRegState DifftestCSRRegState(
    .clock              (aclk               ),
    .coreid             (0                  ),
    .crmd               (csr_crmd_diff_0    ),
    .prmd               (csr_prmd_diff_0    ),
    .euen               (0                  ),
    .ecfg               (csr_ectl_diff_0    ),
    .estat              (csr_estat_diff_0   ),
    .era                (csr_era_diff_0     ),
    .badv               (csr_badv_diff_0    ),
    .eentry             (csr_eentry_diff_0  ),
    .tlbidx             (csr_tlbidx_diff_0  ),
    .tlbehi             (csr_tlbehi_diff_0  ),
    .tlbelo0            (csr_tlbelo0_diff_0 ),
    .tlbelo1            (csr_tlbelo1_diff_0 ),
    .asid               (csr_asid_diff_0    ),
    .pgdl               (csr_pgdl_diff_0    ),
    .pgdh               (csr_pgdh_diff_0    ),
    .save0              (csr_save0_diff_0   ),
    .save1              (csr_save1_diff_0   ),
    .save2              (csr_save2_diff_0   ),
    .save3              (csr_save3_diff_0   ),
    .tid                (csr_tid_diff_0     ),
    .tcfg               (csr_tcfg_diff_0    ),
    .tval               (csr_tval_diff_0    ),
    .ticlr              (csr_ticlr_diff_0   ),
    .llbctl             (csr_llbctl_diff_0  ),
    .tlbrentry          (csr_tlbrentry_diff_0),
    .dmw0               (csr_dmw0_diff_0    ),
    .dmw1               (csr_dmw1_diff_0    )
);

DifftestGRegState DifftestGRegState(
    .clock              (aclk       ),
    .coreid             (0          ),
    .gpr_0              (0          ),
    .gpr_1              (core_inst.reg_0.reg_file[1]    ),
    .gpr_2              (core_inst.reg_0.reg_file[2]    ),
    .gpr_3              (core_inst.reg_0.reg_file[3]    ),
    .gpr_4              (core_inst.reg_0.reg_file[4]    ),
    .gpr_5              (core_inst.reg_0.reg_file[5]    ),
    .gpr_6              (core_inst.reg_0.reg_file[6]    ),
    .gpr_7              (core_inst.reg_0.reg_file[7]    ),
    .gpr_8              (core_inst.reg_0.reg_file[8]    ),
    .gpr_9              (core_inst.reg_0.reg_file[9]    ),
    .gpr_10             (core_inst.reg_0.reg_file[10]   ),
    .gpr_11             (core_inst.reg_0.reg_file[11]   ),
    .gpr_12             (core_inst.reg_0.reg_file[12]   ),
    .gpr_13             (core_inst.reg_0.reg_file[13]   ),
    .gpr_14             (core_inst.reg_0.reg_file[14]   ),
    .gpr_15             (core_inst.reg_0.reg_file[15]   ),
    .gpr_16             (core_inst.reg_0.reg_file[16]   ),
    .gpr_17             (core_inst.reg_0.reg_file[17]   ),
    .gpr_18             (core_inst.reg_0.reg_file[18]   ),
    .gpr_19             (core_inst.reg_0.reg_file[19]   ),
    .gpr_20             (core_inst.reg_0.reg_file[20]   ),
    .gpr_21             (core_inst.reg_0.reg_file[21]   ),
    .gpr_22             (core_inst.reg_0.reg_file[22]   ),
    .gpr_23             (core_inst.reg_0.reg_file[23]   ),
    .gpr_24             (core_inst.reg_0.reg_file[24]   ),
    .gpr_25             (core_inst.reg_0.reg_file[25]   ),
    .gpr_26             (core_inst.reg_0.reg_file[26]   ),
    .gpr_27             (core_inst.reg_0.reg_file[27]   ),
    .gpr_28             (core_inst.reg_0.reg_file[28]   ),
    .gpr_29             (core_inst.reg_0.reg_file[29]   ),
    .gpr_30             (core_inst.reg_0.reg_file[30]   ),
    .gpr_31             (core_inst.reg_0.reg_file[31]   )
);


endmodule
