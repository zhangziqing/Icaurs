module AXI_Slave_Mux_R#(
    parameter   DATA_WIDTH  = 32,
                ADDR_WIDTH  = 32,
                ID_WIDTH    = 1,
                USER_WIDTH  = 1
)(
	/********* 时钟&复位 *********/
	input                       ACLK,
	input      	                ARESETn,
    /********** 0号从机 **********/
    //读地址通道
    output reg                  s0_ARVALID,
	input	  		            s0_ARREADY,
    //读数据通道
	input	   [ID_WIDTH-1:0]   s0_RID,
	input	   [DATA_WIDTH-1:0] s0_RDATA,
	input	   [1:0]	        s0_RRESP,
	input	  		            s0_RLAST,
	input	   [USER_WIDTH-1:0]	s0_RUSER,
	input	 		            s0_RVALID, 
    output reg                  s0_RREADY, 

    /******** 主控通用信号 ********/
    //读地址通道
	output reg	  		        m_ARREADY,
    //读数据通道
	output reg [ID_WIDTH-1:0]   m_RID,
	output reg [DATA_WIDTH-1:0] m_RDATA,
	output reg [1:0]	        m_RRESP,
	output reg		            m_RLAST,
	output reg [USER_WIDTH-1:0]	m_RUSER,
	output reg	                m_RVALID, 
    /******** 从机通用信号 ********/
    //写地址通道
    input     [ADDR_WIDTH-1:0]	s_ARADDR,
    input                       s_ARVALID,
    //写数据通道
    input                       s_RREADY  
);

    //=========================================================
    //常量定义
    parameter   TCO     =   1;  //寄存器延时


    //=========================================================
    //读地址寄存
    logic [31:0]    araddr;     //读地址寄存器

    always_ff@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            araddr <= #TCO '0;
        else if(s_ARVALID)                  //读地址握手信号启动时寄存写地址
            araddr <= #TCO s_ARADDR;
        else
            araddr <= #TCO araddr;
    end



    //=========================================================
    //读取通路的多路复用从机信号

    //---------------------------------------------------------
    //其他信号复用
    always_comb begin
        m_ARREADY   = s0_ARREADY;
        m_RID       = s0_RID;
        m_RDATA     = s0_RDATA;
        m_RRESP     = s0_RRESP;
        m_RLAST     = s0_RLAST;
        m_RUSER     = s0_RUSER;
        m_RVALID    = s0_RVALID;
    end

    //---------------------------------------------------------
    //ARVALID信号复用
    always_comb begin
        s0_ARVALID  = s_ARVALID;

    end

    //---------------------------------------------------------
    //RREADY信号复用
    always_comb begin
        s0_RREADY  = s_RREADY;
    end

endmodule