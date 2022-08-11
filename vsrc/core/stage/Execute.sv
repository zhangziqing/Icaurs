`include "width_param.sv"
`include "operation.sv"

module Execute(
    //stage info
    id_stage_if.i id_info,
    ex_stage_if.o ex_info
);
    //except 
    //TODO
    logic except_type_ale;
    assign ex_info.except_type  = {except_type_ale,id_info.except_type};
    assign ex_info.except_pc    = id_info.except_pc;
    //csr
    assign ex_info.csr_wen=id_info.csr_wen;
    assign ex_info.csr_waddr=id_info.csr_waddr;
    assign ex_info.csr_wdata=id_info.csr_wdata;

    logic [`ALU_OP_WIDTH - 1 : 0] alu_op=id_info.ex_op;
    logic [`DATA_WIDTH - 1 : 0 ] alu_res;
    ALU alu_0 (
        .op(alu_op),
        .oprand1(id_info.oprand1),
        .oprand2(id_info.oprand2),
        .result(alu_res)
    );

    logic [`DATA_WIDTH - 1 : 0 ]mdu_res;
    MDU mdu_0 (
        .op(alu_op),
        .oprand1(id_info.oprand1),
        .oprand2(id_info.oprand2),
        .result(mdu_res)
        // .valid()
    );
    assign ex_info.inst = id_info.inst;
    assign ex_info.pc = id_info.pc;
    assign ex_info.lsu_data = id_info.lsu_data;
    assign ex_info.lsu_op = id_info.lsu_op;
    assign ex_info.rw_en = id_info.rw_en;
    assign ex_info.rw_addr = id_info.rw_addr;
    assign ex_info.ex_result = alu_op[5] ? mdu_res : alu_res;

    assign ex_info.is_cacop     = id_info.is_cacop;
    assign ex_info.cacop_code   = id_info.cacop_code;
    assign ex_info.is_tlb       = id_info.is_tlb;
    assign ex_info.invtlb_op    = id_info.invtlb_op;
    assign ex_info.is_ertn      = id_info.is_ertn;
    assign ex_info.is_idle      = id_info.is_idle;

endmodule

module ALU(
    input [`ALU_OP_WIDTH-1:0] op,
    input [`DATA_WIDTH - 1 : 0] oprand1,
    input [`DATA_WIDTH - 1 : 0] oprand2,
    output logic [`DATA_WIDTH - 1 : 0] result
);
    logic cout;
    logic signed [31:0] temp_oper;   //带符号数的临时变量
    logic [31:0] add_res; 
    assign temp_oper = oprand1;    //方便后面对oprand1进行算数右移

    logic [31:0] alu_oprand2;
    
    assign alu_oprand2 = op[0] ? ~oprand2 : oprand2; 
    assign {cout ,add_res } = oprand1 + alu_oprand2 + op[0];

    wire slt = oprand1[31] & ~oprand2[31] //op1 neg and op2 pos
                | (~(oprand1[31] ^ oprand2[31]) & add_res[31]);
    wire sltu = !cout;
    always_comb begin:ALU
        case (op)
            `ALU_ADD,`ALU_SUB  : result = add_res;
            `ALU_AND  : result = oprand1 & oprand2;//and
            `ALU_OR   : result = oprand1 | oprand2;//or
            `ALU_XOR  : result = oprand1 ^ oprand2;//xor
            `ALU_NOR  : result = ~(oprand1|oprand2);//nor
            `ALU_SLL  : result = oprand1 << oprand2[4:0];//sll.w
            `ALU_SRL  : result = oprand1 >> oprand2[4:0];//srl.w
            `ALU_SRA  : result = temp_oper >>> oprand2[4:0];//sra.w
            `ALU_SLT  : result = {30'b0, slt};//slt
            `ALU_SLTU : result = {30'b0, sltu};//sltu
            default: result = 0;
        endcase
    end
endmodule

module MDU(
    input [`ALU_OP_WIDTH-1:0] op,
    input [`DATA_WIDTH - 1 : 0] oprand1,
    input [`DATA_WIDTH - 1 : 0] oprand2,
    output logic [`DATA_WIDTH - 1 : 0] result 
    // output logic vaild
);
    logic [63: 0 ] mulres;
    wire  [63: 0 ] umul = oprand1 * oprand2;
    wire  [63: 0 ] smul = $signed(oprand1) * $signed(oprand2);
    assign mulres = op[4] ? umul : smul; 
    always_comb
        case(op)
            `ALU_MUL  : 
                begin
                    result=mulres[31:0];
                end
            `ALU_MULH,`ALU_MULHU:
                begin
                    result=mulres[63:32];
                end
            `ALU_DIVU : result = oprand1 / oprand2;
            `ALU_MODU : result = oprand1 % oprand2;
            `ALU_DIV  : result = $signed(oprand1) / $signed(oprand2);
            `ALU_MOD  : result = $signed(oprand1) % $signed(oprand2);
            default:result = 0;
        endcase

    // assign valid  = 1;
endmodule