module AXI_Interconnect#(
    parameter   DATA_WIDTH  = 32,             //数据位宽
                ADDR_WIDTH  = 32,               //地址位宽              
                ID_WIDTH    = 1,               //ID位宽
                USER_WIDTH  = 1,             //USER位宽
                STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
	/********* 时钟&复位 *********/
	input                       ACLK,
	input      	                ARESETn,
    /********** 0号主控 **********/
    //写地址通道
	input      [ID_WIDTH-1:0]   m0_AWID,
    input	   [ADDR_WIDTH-1:0] m0_AWADDR,
    input      [7:0]            m0_AWLEN,
    input      [2:0]            m0_AWSIZE,
    input      [1:0]            m0_AWBURST,
    input                       m0_AWLOCK,
    input      [3:0]            m0_AWCACHE,
    input      [2:0]            m0_AWPROT,
    input      [3:0]            m0_AWQOS,
    input      [3:0]            m0_AWREGION,
    input      [USER_WIDTH-1:0] m0_AWUSER,
    input                       m0_AWVALID,
    output                      m0_AWREADY,
    //写数据通道
    input      [ID_WIDTH-1:0]   m0_WID,
    input      [DATA_WIDTH-1:0] m0_WDATA,
    input      [STRB_WIDTH-1:0] m0_WSTRB,
    input                       m0_WLAST,
    input      [USER_WIDTH-1:0] m0_WUSER,
    input                       m0_WVALID,
    output                      m0_WREADY,
    //写响应通道
    output                      m0_BVALID,
    input                       m0_BREADY,
    //读地址通道
    input      [ID_WIDTH-1:0]   m0_ARID,
    input      [ADDR_WIDTH-1:0] m0_ARADDR,
    input      [7:0]            m0_ARLEN,
    input      [2:0]            m0_ARSIZE,
    input      [1:0]            m0_ARBURST,
    input                       m0_ARLOCK,
    input      [3:0]            m0_ARCACHE,
    input      [2:0]            m0_ARPROT,
    input      [3:0]            m0_ARQOS,
    input      [3:0]            m0_ARREGION,
    input      [USER_WIDTH-1:0] m0_ARUSER,
    input                       m0_ARVALID,
    output                      m0_ARREADY,
    //读数据通道
    output                      m0_RVALID,
    input                       m0_RREADY,
    /********** 1号主控 **********/
    //写地址通道
    input      [ID_WIDTH-1:0]   m1_AWID,
    input	   [ADDR_WIDTH-1:0]	m1_AWADDR,
    input      [7:0]            m1_AWLEN,
    input      [2:0]            m1_AWSIZE,
    input      [1:0]            m1_AWBURST,
    input                       m1_AWLOCK,
    input      [3:0]            m1_AWCACHE,
    input      [2:0]            m1_AWPROT,
    input      [3:0]            m1_AWQOS,
    input      [3:0]            m1_AWREGION,
    input      [USER_WIDTH-1:0] m1_AWUSER,
    input                       m1_AWVALID,
    output                      m1_AWREADY,
    //写数据通道
    input      [ID_WIDTH-1:0]   m1_WID,
    input      [DATA_WIDTH-1:0] m1_WDATA,
    input      [STRB_WIDTH-1:0] m1_WSTRB,
    input                       m1_WLAST,
    input      [USER_WIDTH-1:0] m1_WUSER,
    input                       m1_WVALID,
    output                      m1_WREADY,
    //写响应通道
    output                      m1_BVALID,
    input                       m1_BREADY,
    //读地址通道
    input      [ID_WIDTH-1:0]   m1_ARID,
    input      [ADDR_WIDTH-1:0] m1_ARADDR,
    input      [7:0]            m1_ARLEN,
    input      [2:0]            m1_ARSIZE,
    input      [1:0]            m1_ARBURST,
    input                       m1_ARLOCK,
    input      [3:0]            m1_ARCACHE,
    input      [2:0]            m1_ARPROT,
    input      [3:0]            m1_ARQOS,
    input      [3:0]            m1_ARREGION,
    input      [USER_WIDTH-1:0] m1_ARUSER,
    input                       m1_ARVALID,
    output                      m1_ARREADY,
    //读数据通道
    output                      m1_RVALID,
    input                       m1_RREADY,

    /******** 主控通用信号 ********/
    //写响应通道
	output     [ID_WIDTH-1:0]	m_BID,
	output     [1:0]	        m_BRESP,
	output     [USER_WIDTH-1:0] m_BUSER,
    //读数据通道
	output     [ID_WIDTH-1:0]   m_RID,
	output     [DATA_WIDTH-1:0] m_RDATA,
	output     [1:0]	        m_RRESP,
    output                      m_RLAST,
	output     [USER_WIDTH-1:0]	m_RUSER,
    /********** 0号从机 **********/
    //写地址通道
    output                      s0_AWVALID,
    input	   	                s0_AWREADY,
    //写数据通道
    output                      s0_WVALID,
    input	  		            s0_WREADY,
    //写响应通道
	input	   [ID_WIDTH-1:0]	s0_BID,
	input	   [1:0]	        s0_BRESP,
	input	   [USER_WIDTH-1:0] s0_BUSER,
	input	     		        s0_BVALID,
    output                      s0_BREADY,
    //读地址通道
    output                      s0_ARVALID,
	input	  		            s0_ARREADY,
    //读数据通道
	input	   [ID_WIDTH-1:0]   s0_RID,
	input	   [DATA_WIDTH-1:0] s0_RDATA,
	input	   [1:0]	        s0_RRESP,
	input	  		            s0_RLAST,
	input	   [USER_WIDTH-1:0]	s0_RUSER,
	input	 		            s0_RVALID, 
    output                      s0_RREADY, 
   
    /******** 从机通用信号 ********/
    //写地址通道
    output     [ID_WIDTH-1:0]   s_AWID,
    output     [ADDR_WIDTH-1:0]	s_AWADDR,
    output     [7:0]            s_AWLEN,
    output     [7:0]            s_AWSIZE,
    output     [2:0]            s_AWBURST,
    output                      s_AWLOCK,
    output     [3:0]            s_AWCACHE,
    output     [2:0]            s_AWPROT,
    output     [3:0]            s_AWQOS,
    output     [3:0]            s_AWREGION,
    output     [USER_WIDTH-1:0] s_AWUSER,  
    //写数据通道
    output     [ID_WIDTH-1:0]   s_WID,
    output     [DATA_WIDTH-1:0] s_WDATA,
    output     [STRB_WIDTH-1:0] s_WSTRB,
    output                      s_WLAST,
    output     [USER_WIDTH-1:0] s_WUSER,
    //读地址通道
    output     [ID_WIDTH-1:0]   s_ARID,    
    output     [ADDR_WIDTH-1:0] s_ARADDR,
    output     [7:0]            s_ARLEN,
    output     [2:0]            s_ARSIZE,
    output     [1:0]            s_ARBURST,
    output                      s_ARLOCK,
    output     [3:0]            s_ARCACHE,
    output     [2:0]            s_ARPROT,
    output     [3:0]            s_ARQOS,
    output     [3:0]            s_ARREGION,
    output     [USER_WIDTH-1:0] s_ARUSER   
);


    //=========================================================
    //中建信号
    logic       m0_wgrnt;
    logic       m1_wgrnt;

    logic       m0_rgrnt;
    logic       m1_rgrnt;


    logic       m_AWREADY;
    logic       m_WREADY;
    logic       m_BVALID;
    logic       m_ARREADY;
    logic       m_RVALID;

    logic       s_AWVALID;
    logic       s_WVALID;
    logic       s_BREADY; 
    logic       s_ARVALID;
    logic       s_RREADY;  

    //=========================================================
    //写通道仲裁器例化
    AXI_Arbiter_W u_AXI_Arbiter_W(.*);

    //=========================================================
    //读通道仲裁器例化
    AXI_Arbiter_R u_AXI_Arbiter_R(.*);

    //=========================================================
    //写通道主机用多路复用器
    AXI_Master_Mux_W #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .USER_WIDTH(USER_WIDTH),
        .STRB_WIDTH(STRB_WIDTH)
    )u_AXI_Master_Mux_W(.*);

    //=========================================================
    //读通道主机用多路复用器
    AXI_Master_Mux_R #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .USER_WIDTH(USER_WIDTH)
    )u_AXI_Master_Mux_R(.*);

    //=========================================================
    //写通道从机用多路复用器
    AXI_Slave_Mux_W #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .USER_WIDTH(USER_WIDTH)
    )u_AXI_Slave_Mux_W(.*);

    //=========================================================
    //读通道从机用多路复用器
    AXI_Slave_Mux_R #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .USER_WIDTH(USER_WIDTH)
    )u_AXI_Slave_Mux_R(.*);

endmodule