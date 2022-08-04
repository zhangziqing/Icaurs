//=============================================================================
//
//Module Name:					AXI_Arbiter_R.sv
module AXI_Arbiter_R (
	input                       ACLK,
	input      	                ARESETn,
    input                       m0_ARVALID,
    input                       m0_RREADY,
    input                       m1_ARVALID,
    input                       m1_RREADY,
    input                       m_RVALID,
    input                       m_RLAST,
    output reg                  m0_rgrnt,
	output reg	                m1_rgrnt

);

    //=========================================================
    //常量定义
    parameter   TCO     =   1;  //寄存器延时


    //=========================================================
    //写地址通道仲裁状态机

    //---------------------------------------------------------
    //枚举所有状态（logic四状态）
    enum logic [1:0] {
        AXI_MASTER_0,    //0号主机占用总线状态
        AXI_MASTER_1    //1号主机占用总线状态

    } state,next_state;

    //---------------------------------------------------------
    //状态译码
    always_comb begin
        case (state)
            AXI_MASTER_0: begin                 //0号主机占用总线状态，响应请求优先级为：0>1>2>3
                if(m0_ARVALID)                  //如果0号主机请求总线
                    next_state = AXI_MASTER_0;  //保持0号主机占用总线状态
                else if(m_RVALID||m0_RREADY)    //如果还在写入数据
                    next_state = AXI_MASTER_0;  //保持0号主机占用总线状态
                else if(m_RLAST&&m_RVALID)      //读取完成
                    next_state = AXI_MASTER_1;  //更换优先级
                else if(m1_ARVALID)             //如果1号主机请求总线
                    next_state = AXI_MASTER_1;  //下一状态为1号主机占用总线
                else                            //都未请求总线
                    next_state = AXI_MASTER_0;  //保持0号主机占用总线状态
            end
            AXI_MASTER_1: begin                 //1号主机占用总线状态，响应请求优先级为：1>2>3>0
                if(m1_ARVALID)                  //与上一部分类似
                    next_state = AXI_MASTER_1;
                else if(m_RVALID||m1_RREADY)
                    next_state = AXI_MASTER_1;
                else
                    next_state = AXI_MASTER_0;
            end

            default:
                next_state = AXI_MASTER_0;      //默认状态为0号主机占用总线
        endcase
    end


    always_ff@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            state <= AXI_MASTER_0;        
        else
            state <= next_state;
    end

    //---------------------------------------------------------
    //利用状态寄存器输出控制结果
    always_comb begin
        case (state)
            AXI_MASTER_0: {m0_rgrnt,m1_rgrnt} = 2'b10;
            AXI_MASTER_1: {m0_rgrnt,m1_rgrnt} = 2'b01;
            default:      {m0_rgrnt,m1_rgrnt} = 2'b00;
        endcase
    end
endmodule