//=============================================================================
//
//Module Name:					AXI_Slave_Mux_R.sv
//Department:					Xidian University
//Function Description:	        AXI总线读通道从机用多路复用器
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana	Verdvana	Verdvana		  			2020-3-13
//V1.1		Verdvana	Verdvana	Verdvana		  			2020-3-16
//V1.2		Verdvana	Verdvana	Verdvana		  			2020-3-18
//
//------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		4个AXI4总线主设备接口；
//          8个AXI4总线从设备接口；
//          从设备地址隐藏与读写地址的高三位；
//          主设备仲裁优先级随上一次总线所有者向后顺延；
//          Cyclone IV EP4CE30F29C8上综合后最高时钟频率可达80MHz+。
//
//V1.1      优化电路结构，状态机判断主设备握手请求信号后直接输出到对应从设备，省去一层MUX；
//          数据、地址、ID、USER位宽可设置;
//          时序不变，综合后最高时钟频率提高至100MHz+。	
//
//V1.2      进一步优化电路结构，精简状态机的状态；
//          时序不变，综合后最高时钟频率提高至400MHz。
//
//=============================================================================

`timescale 1ns/1ns

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