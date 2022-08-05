

module AXI_Arbiter_W (
	/**********时钟&复位**********/
	input           ACLK,
	input      	    ARESETn,
	/********** 0号主控 **********/
    input                       m0_AWVALID,
    input                       m0_WVALID,
    input                       m0_BREADY,
	/********** 1号主控 **********/
    input                       m1_AWVALID,
    input                       m1_WVALID,
    input                       m1_BREADY,


    input                       m_AWREADY,
    input                       m_WREADY,
    input                       m_BVALID,
    
    output reg                  m0_wgrnt,
	output reg	                m1_wgrnt
);

    enum logic [1:0] {
        AXI_MASTER_0,    //0号主机占用总线状态
        AXI_MASTER_1    //1号主机占用总线状态

    } state,next_state;

    always_comb begin
        case (state)
            AXI_MASTER_0: begin                 //0号主机占用总线状态，响应请求优先级为：0>1>2>3
                if(m0_AWVALID)                  //如果0号主机请求总线
                    next_state = AXI_MASTER_0;  //保持0号主机占用总线状态
                else if(m0_WVALID||m_WREADY)    //如果还在写入数据
                    next_state = AXI_MASTER_0;  //保持0号主机占用总线状态
                else if(m_BVALID&&m0_BREADY)    //写回应完成
                    next_state = AXI_MASTER_1;  //更换优先级
                else if(m1_AWVALID)             //如果1号主机请求总线
                    next_state = AXI_MASTER_1;  //下一状态为1号主机占用总线
                
                else                            //都未请求总线
                    next_state = AXI_MASTER_0;  //保持0号主机占用总线状态
            end
            AXI_MASTER_1: begin                 //1号主机占用总线状态，响应请求优先级为：1>2>3>0
                if(m1_AWVALID)                  //与上一部分类似
                    next_state = AXI_MASTER_1;
                else if(m1_WVALID||m_WREADY)
                    next_state = AXI_MASTER_1;
                
                else if(m0_AWVALID)
                    next_state = AXI_MASTER_0;
                else
                    next_state = AXI_MASTER_1;
            end

            
            default:
                next_state = AXI_MASTER_0;      //默认状态为0号主机占用总线
        endcase
    end


    //---------------------------------------------------------
    //更新状态寄存器
    always_ff@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            state <= AXI_MASTER_0;         //默认状态为0号主机占用总线
        else
            state <= next_state;
    end

    //---------------------------------------------------------
    //利用状态寄存器输出控制结果
    always_comb begin
        case (state)
            AXI_MASTER_0: {m0_wgrnt,m1_wgrnt} = 2'b10;
            AXI_MASTER_1: {m0_wgrnt,m1_wgrnt} = 2'b01;
            default:      {m0_wgrnt,m1_wgrnt} = 2'b00;
        endcase
    end

endmodule