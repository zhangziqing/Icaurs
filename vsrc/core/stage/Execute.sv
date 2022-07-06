`include "vsrc/include/width_param.sv"
`include "vsrc/include/opreation.sv"

module Execute(
    //stage info
    id_stage_if.i id_info,
    ex_stage_if.o ex_info
);

    logic [`ALU_OP_WIDTH - 1 : 0] alu_op=id_info.ex_op;//TODO
    logic [`DATA_WIDTH - 1 : 0 ]alu_res;
    ALU alu_0 (
    .op(alu_op),
    .oprand1(id_info.oprand1),
    .oprand2(id_info.oprand2),
    .result(alu_res)
    );
    always_comb $display("alu_res %x",alu_res);
    assign ex_info.inst = id_info.inst;
    assign ex_info.inst = id_info.pc;
    assign ex_info.lsu_data = id_info.lsu_data;
    assign ex_info.lsu_op = id_info.lsu_op;
    assign ex_info.rw_en = id_info.rw_en;
    assign ex_info.rw_addr = id_info.rw_addr;
    assign ex_info.ex_result = alu_res;
    assign ex_info.pc = id_info.pc;
    assign ex_info.inst = id_info.pc;
endmodule

module ALU(
    input [`ALU_OP_WIDTH-1:0] op,
    input [`DATA_WIDTH - 1 : 0] oprand1,
    input [`DATA_WIDTH - 1 : 0] oprand2,
    output logic [`DATA_WIDTH - 1 : 0] result
);
    logic cout;
    logic [31:0]subres;
    logic [63:0] mulres;
    logic signed [31:0] temp_oper;   //带符号数的临时变量
    assign temp_oper = oprand1;    //方便后面对oprand1进行算数右移
    always_comb begin:ALU
        case (op)
            `ALU_ADD  : {cout,result} = oprand1 + oprand2;
            `ALU_SUB  : {cout,result} = oprand1 - oprand2;
            `ALU_AND  : result = oprand1 & oprand2;//and
            `ALU_OR   : result = oprand1 | oprand2;//or
            `ALU_XOR  : result = oprand1 ^ oprand2;//xor
            `ALU_NOR  : result = ~(oprand1|oprand2);//nor
            `ALU_SLL  : result = oprand1 << oprand2[4:0];//sll.w
            `ALU_SRL  : result = oprand1 >> oprand2[4:0];//srl.w
            `ALU_SRA  : result = temp_oper >>> oprand2[4:0];//sra.w
            `ALU_SLT  : 
                begin
                    {cout,subres} = oprand1 - oprand2 ;
                    result = (subres[31] && !cout) ? 1 : 0;//slt
                end
            `ALU_SLTU : 
                begin
                    {cout,result} = oprand1 - oprand2 + 1;
                    result = cout ? 0 : 1;//sltu
                end
            `ALU_MUL  : 
                begin
                    mulres = oprand1 * oprand2;
                    result=mulres[31:0];
                end
            `ALU_MULH :
                begin
                    mulres = oprand1 * oprand2;
                    result=mulres[63:32];
                end
            `ALU_DIV  : result = oprand1 / oprand2;
            `ALU_MOD  : result = oprand1 % oprand2;
            default:begin
                result = 0;
            end
        endcase
    end
endmodule