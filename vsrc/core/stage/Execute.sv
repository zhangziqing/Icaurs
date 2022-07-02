`include "vsrc/include/width_param.sv"
`include "vsrc/include/opreation.sv"

module Execute(
    //stage info
    id_stage_if.i id_info,
    ex_stage_if.o ex_info
);

    wire [`ALU_OP_WIDTH - 1 : 0] alu_op;//TODO
    // always@(*)
    //     begin
    //         case(id_info.inst[`INST_WIDTH-12:`INST_WIDTH-17])
    //             6'b100000:alu_op=8'h00;//add
    //             6'b100010:alu_op=8'h01;//sub
    //             6'b101001:alu_op=8'h05;//and
    //             6'b101010:alu_op=8'h06;//or
    //             6'b101011:alu_op=8'h07;//xor
    //             6'b101000:alu_op=8'h04;//nor
    //             6'b101110:alu_op=8'h08;//sll.w
    //             6'b101111:alu_op=8'h09;//srl.w
    //             6'b110000:alu_op=8'h0a;//sra.w
    //             6'b100100:alu_op=8'h02;//slt
    //             6'b100101:alu_op=8'h03;//sltu
    //         default:alu_op=0;
    //         endcase
    //     end
    wire [`DATA_WIDTH - 1 : 0 ]alu_res;
    wire cout;
    ALU alu_0 (
    .op(alu_op),
    .oprand1(id_info.oprand1),
    .oprand2(id_info.oprand2),
    .result(alu_res)
    );
    assign ex_info.inst = id_info.inst;
    assign ex_info.inst = id_info.pc;
    assign ex_info.lsu_data = id_info.lsu_data;
    assign ex_info.lsu_op = id_info.lsu_op;
    assign ex_info.rw_en = id_info.rw_en;
    assign ex_info.rw_addr = id_info.rw_addr;
    assign ex_info.ex_result = alu_res;//TODO
endmodule

module ALU(
    input [`ALU_OP_WIDTH-1:0] op,
    input [`DATA_WIDTH - 1 : 0] oprand1,
    input [`DATA_WIDTH - 1 : 0] oprand2,
    output logic [`DATA_WIDTH - 1 : 0] result
);
    always_comb begin:ALU
        case (op)
            `ALU_ADD_W   : {cout,result} = oprand1 + oprand2;
            `ALU_SUB_W   : {cout,result} = oprand1 - oprand2 + 1;
            `ALU_AND     : result = oprand1 & oprand2;//and
            `ALU_OR      : result = oprand1 | oprand2;//or
            `ALU_XOR     : result = oprand1 ^ oprand2;//xor
            `ALU_NOR     : result = ~(oprand1|oprand2);//nor
            `ALU_SLL_W   : result = oprand1 << oprand2;//sll.w
            `ALU_SRL_W   : result = oprand1 >> oprand2;//srl.w
            `ALU_SRA_W   : result = oprand1 >>> oprand2;//sra.w
            `ALU_SLT     : result = alu_res[31] ? 1'b1 : 1'b0;//slt
            `ALU_SLTU    : result = cout ? 1'b0 : 1'b1;//sltu
            `ALU_MUL_W   : result = oprand1 * oprand2;
            `ALU_MULH_W  : result = oprand1 * oprand2;
            `ALU_MULH_WU : result = oprand1 * oprand2;
            `ALU_DIV_W   : result = oprand1 / oprand2;
            `ALU_DIV_WU  : result = oprand1 / oprand2;
            `ALU_MOD_W   : result = oprand1 % oprand2;
            `ALU_MOD_WU  : result = oprand1 % oprand2;
        default:
                result = 0;
        endcase
    end
endmodule