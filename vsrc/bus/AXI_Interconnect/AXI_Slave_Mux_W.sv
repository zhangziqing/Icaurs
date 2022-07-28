//=============================================================================
//
//Module Name:					AXI_Slave_Mux_W.sv
//Department:					Xidian University
//Function Description:	        AXI总线写通道从机用多路复用器
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

module AXI_Slave_Mux_W#(
    parameter   DATA_WIDTH  = 32,
                ADDR_WIDTH  = 32,
                ID_WIDTH    = 1,
                USER_WIDTH  = 1
)(
	/********* 时钟&复位 *********/
	input                       ACLK,
	input      	                ARESETn,
    /********** 0号从机 **********/
    //写地址通道
    output reg                  s0_AWVALID,
    input	   	                s0_AWREADY,
    //写数据通道
    output reg                  s0_WVALID,
    input	  		            s0_WREADY,
    //写响应通道
	input	   [ID_WIDTH-1:0]	s0_BID,
	input	   [1:0]	        s0_BRESP,
	input	   [USER_WIDTH-1:0] s0_BUSER,
	input	     		        s0_BVALID,
    output reg                  s0_BREADY,
    
    /******** 主控通用信号 ********/
    //写地址通道
    output reg 	                m_AWREADY,
    //写数据通道
    output reg		            m_WREADY,
    //写响应通道
	output reg [ID_WIDTH-1:0]	m_BID,
	output reg [1:0]	        m_BRESP,
	output reg [USER_WIDTH-1:0] m_BUSER,
	output reg   		        m_BVALID,
    /******** 从机通用信号 ********/
    //写地址通道
    input     [ADDR_WIDTH-1:0]	s_AWADDR,
    input                       s_AWVALID,
    //写数据通道
    input                       s_WVALID,
    //写响应通道
    input                       s_BREADY    
);

    //=========================================================
    //常量定义
    parameter   TCO     =   1;  //寄存器延时

    //=========================================================
    //写地址寄存
    logic [31:0]    awaddr;     //写地址寄存器

    always_ff@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            awaddr <= #TCO '0;
        else if(s_AWVALID)                  //写地址握手信号启动时寄存写地址
            awaddr <= #TCO s_AWADDR;
        else
            awaddr <= #TCO awaddr;
    end



    //=========================================================
    //写入通路的多路复用从机信号

    //---------------------------------------------------------
    //其他信号复用
    always_comb begin
        m_AWREADY   = s0_AWREADY;
        m_WREADY    = s0_WREADY;
        m_BID       = s0_BID;
        m_BRESP     = s0_BRESP;
        m_BUSER     = s0_BUSER;
        m_BVALID    = s0_BVALID;
    end

    //---------------------------------------------------------
    //AWVALID信号复用
    always_comb begin
        s0_AWVALID  = s_AWVALID;
    end

    //---------------------------------------------------------
    //BREADY信号复用
    always_comb begin
        s0_BREADY  = s_BREADY;

    end

    //---------------------------------------------------------
    //WVALID信号复用
    always_comb begin
        s0_WVALID  = s_WVALID;
    end


endmodule