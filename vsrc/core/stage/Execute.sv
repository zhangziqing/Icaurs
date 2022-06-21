`include "vsrc/include/width_param.sv"
`include "vsrc/include/opreation.sv"

module Execute(
    //stage info
    id_stage.i id_info,
    ex_stage.o ex_info
);

    wire [`ALU_OP_WIDTH-1:0] alu_op = ex_info.ex_op;
    ALU alu_0 (
    .op(ex_op),
    .oprand1(ex_info.ex_oprand1),
    .oprand2(ex_info.ex_oprand2),
    .result(ex_info.ex_result)
    );
    assign ex_info.inst = id_info.inst;
    assign ex_info.inst = id_info.pc;
    assign ex_info.lsu_data = id_info.lsu_data;
    assign ex_info.lsu_op = id_info.lsu_op;
    assign ex_info.rd_wr_en = id_info.rd_wr_en;
    assign ex_info.rd_wr_addr = id_info.rd_wr_addr;

endmodule

module ALU(
    input [`ALU_OP_WIDTH-1:0] op,
    input [`DATA_WIDTH - 1 : 0] oprand1,
    input [`DATA_WIDTH - 1 : 0] oprand2,
    output [`DATA_WIDTH - 1 : 0] result
);


    always_comb begin:ALU
        case (op)
            `ALU_ADD : result = oprand1 + oprand2;
            `ALU_SUB : result = oprand1 - oprand2;
        endcase
    end
endmodule