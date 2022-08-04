module AXI_Slave_Mux_W#(
    parameter   ADDR_WIDTH  = 32,
                ID_WIDTH    = 1,
                USER_WIDTH  = 1
)(
	/********* 时钟&复位 *********/
	input                       ACLK,
	input      	                ARESETn,
    output reg                  s0_AWVALID,
    input	   	                s0_AWREADY,
    output reg                  s0_WVALID,
    input	  		            s0_WREADY,
	input	   [ID_WIDTH-1:0]	s0_BID,
	input	   [1:0]	        s0_BRESP,
	input	   [USER_WIDTH-1:0] s0_BUSER,
	input	     		        s0_BVALID,
    output reg                  s0_BREADY,
    
    output reg 	                m_AWREADY,
    output reg		            m_WREADY,
	output reg [ID_WIDTH-1:0]	m_BID,
	output reg [1:0]	        m_BRESP,
	output reg [USER_WIDTH-1:0] m_BUSER,
	output reg   		        m_BVALID,
    input     [ADDR_WIDTH-1:0]	s_AWADDR,
    input                       s_AWVALID,
    input                       s_WVALID,
    input                       s_BREADY    
);

    logic [31:0]    awaddr;    

    always_ff@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            awaddr <= '0;
        else if(s_AWVALID)              
            awaddr <= s_AWADDR;
        else
            awaddr <= awaddr;
    end




    always_comb begin
        m_AWREADY   = s0_AWREADY;
        m_WREADY    = s0_WREADY;
        m_BID       = s0_BID;
        m_BRESP     = s0_BRESP;
        m_BUSER     = s0_BUSER;
        m_BVALID    = s0_BVALID;
    end

    always_comb begin
        s0_AWVALID  = s_AWVALID;
    end

    
    always_comb begin
        s0_BREADY  = s_BREADY;

    end

    always_comb begin
        s0_WVALID  = s_WVALID;
    end


endmodule