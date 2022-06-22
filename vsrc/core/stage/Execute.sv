`include "vsrc/include/width_param.sv"
`include "vsrc/include/opreation.sv"

module Execute(
    //stage info
    id_stage_if.i id_info,
    ex_stage_if.o ex_info
);

    wire [`ALU_OP_WIDTH - 1 : 0] alu_op = 0;//TODO
    wire [`DATA_WIDTH - 1 : 0 ]alu_res;
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
    assign ex_info.ex_result = 0;//TODO
endmodule

module ALU(
    input [`ALU_OP_WIDTH-1:0] op,
    input [`DATA_WIDTH - 1 : 0] oprand1,
    input [`DATA_WIDTH - 1 : 0] oprand2,
    output logic [`DATA_WIDTH - 1 : 0] result
);
    always_comb begin:ALU
        case (op)
            `ALU_ADD : result = oprand1 + oprand2;
            `ALU_SUB : result = oprand1 - oprand2;
            default:
                result = 0;
        endcase
    end
endmodule