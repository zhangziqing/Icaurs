`include "vsrc/include/width_param.sv"
`include "vsrc/include/operation.sv"

module Execute(
    //stage info
    id_stage_if.i id_info,
    ex_stage_if.o ex_info,
    //data relate
    csrData_pushForwward.i mem_csr_info,
    csrData_pushForwward.i wb_csr_info,
    //csr reg data
    input  [`DATA_WIDTH-1:0]    csr_reg_data,
    output [`CSR_REG_WIDTH-1:0] csr_reg_addr,
    csrData_pushForwward.o ex_csr_info
);
    //csr
    logic [`DATA_WIDTH-1:0] csr_read_result;
    assign csr_reg_addr=id_info.inst[23:10];
    //1.write csr reg data
    always @(*)
    begin
        if(id_info.csr_op==3'b100)//csrrd
        begin
            ex_csr_info.rw_en=0;
            ex_csr_info.rw_addr=14'b0;
            ex_csr_info.rw_data=32'b0;
        end
        else if(id_info.csr_op==3'b010)//csrwr
        begin
            ex_csr_info.rw_en=1;
            ex_csr_info.rw_addr=csr_reg_addr;
            ex_csr_info.rw_data=oprand2;
        end
        else if(id_info.csr_op==3'b001)//csrxchg
        begin
            ex_csr_info.rw_en=1;
            ex_csr_info.rw_addr=csr_reg_addr;
            ex_csr_info.rw_data=(oprand2&oprand1)|(csr_read_result&~oprand1);//TODO
        end
        else
        begin
            ex_csr_info.rw_en=0;
            ex_csr_info.rw_addr=14'b0;
            ex_csr_info.rw_data=32'b0;
        end
    end
    //2.read csr reg data
    always @(*)
    begin
        //data is related to mem
        if(mem_csr_info.rw_en==1&&mem_csr_info.rw_addr==csr_reg_addr)
            csr_read_result=mem_csr_info.rw_data;
        //data is related to wb
        else if(wb_csr_info.rw_en==1&&wb_csr_info.rw_addr==csr_reg_addr)
            csr_read_result=wb_csr_info.rw_data;
        else 
            csr_read_result=csr_reg_data;
    end


    logic [`ALU_OP_WIDTH - 1 : 0] alu_op=id_info.ex_op;//TODO
    logic [`DATA_WIDTH - 1 : 0 ]alu_res;
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
    assign ex_info.ex_result = alu_op[5] ? mdu_res : (alu_op!=`ALU_CSR?alu_res:csr_read_result);
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
    
    assign alu_oprand2 = op[0] ? (~oprand2 + 1) : oprand2; 
    assign {cout ,add_res } = oprand1 + alu_oprand2;
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
            `ALU_SLT  : result = (add_res[31] && !cout) ? 1 : 0;//slt
            `ALU_SLTU : result = cout ? 0 : 1;//sltu
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
    logic [63: 0 ]mulres;
    assign mulres = oprand1 * oprand2;
    always_comb
        case(op)
            `ALU_MUL  : 
                begin
                    result=mulres[31:0];
                end
            `ALU_MULH :
                begin
                    result=mulres[63:32];
                end
            `ALU_DIV  : result = oprand1 / oprand2;
            `ALU_MOD  : result = oprand1 % oprand2;
            default:result = 0;
        endcase

    // assign valid  = 1;
endmodule