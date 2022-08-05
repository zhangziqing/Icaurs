`include "width_param.sv"
`include "opcode.sv"
`include "operation.sv"

/**
    There are four functions of Instruction decode module
    1. Generate the oprands
    2. Generate the opcode for execution unit 
    3. Generate the ls_data and ls_op
    4. Generate the branch info and jump info
*/


module InstDecode(
    input [`INST_WIDTH - 1 : 0]     inst,
    input inst_valid,
    //register interface

    /*
        r1 : regRead1;
        r2 : regRead2;
        rw : regWrite
    */
    output  logic                         r1_en,
    output  logic [`REG_WIDTH - 1 : 0]    r1_addr,
    input   logic [`DATA_WIDTH - 1: 0]    r1_data,
    output  logic                         r2_en,
    output  logic [`REG_WIDTH - 1 : 0]    r2_addr,
    input   logic [`DATA_WIDTH - 1: 0]    r2_data,


    //stage interface
    if_stage_if.o                   if_info,
    id_stage_if.o                   id_info,
    branch_info_if.o                branch_info, 

    //branch info
    output predict_miss,
    //2.csr reg data
    input  logic [`DATA_WIDTH-1:0]    csr_data,
    output logic [`CSRNUM_WIDTH-1:0]  csr_addr,

    //time 64 from csr
    input [63:0] timer_64,
    input [31:0] csr_tid
);
    wire [`ADDR_WIDTH - 1 : 0 ]pc = if_info.pc;
    //generate the oprands
    wire [`REG_WIDTH - 1 : 0] rd_addr;
    wire [`REG_WIDTH - 1 : 0] rj_addr;
    wire [`REG_WIDTH - 1 : 0] rk_addr;
    assign rd_addr = inst[4:0];
    assign rj_addr = inst[9:5];
    assign rk_addr = inst[14:10];


    wire [11:0] si12;
    wire [13:0] si14;
    wire [19:0] si20;
    assign si12 = inst[21:10];
    assign si14 = inst[23:10];
    assign si20 = inst[24:5];

    wire [`DATA_WIDTH - 1 : 0] si12_ext;
    wire [`DATA_WIDTH - 1 : 0] si20_ext;
    wire si12_ext_sign;
    assign si12_ext_sign=is_load_store||(is_si12&&((alu_op==`ALU_ADD)||(alu_op==`ALU_SLT)||(alu_op == `ALU_SLTU)));
    assign si12_ext=si12_ext_sign ? {{20{si12[11]}},si12} : {20'b0,si12};
    assign si20_ext={si20,12'b0};


    //except
    wire except_type_break,except_type_syscall;
    logic inst_invaild;
    assign except_type_break=~|(inst[31:15]^`BREAK);
    assign except_type_syscall=~|(inst[31:15]^`SYSCALL);
    assign id_info.except_pc=if_info.pc;
    assign id_info.except_type={16'b0,except_type_break,except_type_syscall,inst_invaild,13'b0};

    //operation inst
    wire is_3r,is_ui5,is_si12,is_csr,is_rdcnt;
    assign is_3r = (~|(inst[31:22]^10'b0000000000)) && (inst[21]||inst[20]) && (!except_type_break) && (!except_type_syscall);
    assign is_ui5 = (~|(inst[31:20]^12'b000000000100)) && (~|(inst[17:15]^3'b001));
    assign is_si12 = ~|(inst[31:25]^7'b0000001);
    assign is_csr = ~|(inst[31:24]^8'b00000100);
    assign is_rdcnt=~|(inst[31:11]^21'b000000000000000001100);

    //rdcnt
    wire is_rdcntid,is_rdcntvl,is_rdcntvh;
    assign is_rdcntid=is_rdcnt&&(inst[10]==1'b0)&&(inst[4:0]==5'b00000);
    assign is_rdcntvl=is_rdcnt&&(inst[10]==1'b0)&&(inst[9:5]==5'b00000);
    assign is_rdcntvh=is_rdcnt&&(inst[10]==1'b1)&&(inst[9:5]==5'b00000);

    //csr inst
    wire is_csrrd,is_csrwr,is_csrxchg;
    assign is_csrrd = is_csr&&(~|(inst[9:5]^5'b00000));
    assign is_csrwr = is_csr&&(~|(inst[9:5]^5'b00001));
    assign is_csrxchg = is_csr&&(!is_csrrd)&&(!is_csrwr);

    wire is_si20,is_lu12i,is_pcaddu12i;
    assign is_si20=~|(inst[31:28]^4'b0001);
    assign is_lu12i=is_si20&&~|(inst[27:25]^`LU12I);
    assign is_pcaddu12i=is_si20&&~|(inst[27:25]^`PCADDU12I);

    wire is_branch_jump;
    assign is_branch_jump = ~|(inst[31:30] ^ 2'b01);

    wire is_load_store,is_store,is_load;
    assign is_load_store = ~|(inst[31:29] ^ 3'b001);
    assign is_store = is_load_store && ~|(inst[28:24] ^ 5'b01001);
    assign is_load = is_load_store && (!is_store);

    //alu_op
    logic [`ALU_OP_WIDTH - 1 : 0] alu_op;
    always @(*)
    begin
        if(is_3r)
        case(inst[20:15])
        `ADD_W:  begin alu_op=`ALU_ADD;  end
        `SUB_W:  begin alu_op=`ALU_SUB;  end
        `SLT:    begin alu_op=`ALU_SLT;  end
        `SLTU:   begin alu_op=`ALU_SLTU; end
        `NOR:    begin alu_op=`ALU_NOR;  end
        `AND:    begin alu_op=`ALU_AND;  end
        `OR:     begin alu_op=`ALU_OR;   end
        `XOR:    begin alu_op=`ALU_XOR;  end
        `SLL_W:  begin alu_op=`ALU_SLL;  end
        `SRL_W:  begin alu_op=`ALU_SRL;  end
        `SRA_W:  begin alu_op=`ALU_SRA;  end
        `MUL_W:  begin alu_op=`ALU_MUL;  end
        `MULH_W: begin alu_op=`ALU_MULH; end
        `MULH_WU:begin alu_op=`ALU_MULHU; end
        `DIV_W:  begin alu_op=`ALU_DIV;  end 
        `MOD_W:  begin alu_op=`ALU_MOD;  end
        `DIV_WU: begin alu_op=`ALU_DIVU;  end
        `MOD_WU: begin alu_op=`ALU_MODU;  end
        default: begin alu_op=`ALU_INVALID;  end
        endcase
        else if(is_ui5)
        case(inst[19:18])
        `SLLI_W:begin alu_op=`ALU_SLL;  end
        `SRLI_W:begin alu_op=`ALU_SRL;  end
        `SRAI_W:begin alu_op=`ALU_SRA;  end
        default:alu_op=`ALU_INVALID;
        endcase
        else if(is_si12)
        case(inst[24:22])
        `SLTI:  begin alu_op=`ALU_SLT;  end
        `SLTUI: begin alu_op=`ALU_SLTU; end
        `ADDI_W:begin alu_op=`ALU_ADD;  end
        `ANDI:  begin alu_op=`ALU_AND;  end
        `ORI:   begin alu_op=`ALU_OR;   end
        `XORI:  begin alu_op=`ALU_XOR;  end
        default:begin alu_op=`ALU_INVALID;  end
        endcase
    end

    /*
    *   register:0
    *   I12:1
    *   I20:2
    */

    wire [`DATA_WIDTH - 1 : 0] branch_oprand1;
    wire [`DATA_WIDTH - 1 : 0] branch_oprand2;
    assign branch_oprand1=r1_data;
    assign branch_oprand2=r2_data;

    wire is_branch;
    logic branch_en;
    wire [`ADDR_WIDTH - 1 : 0 ] branch_addr;
    wire is_jump; 
    wire jump_en;
    wire [`ADDR_WIDTH - 1 : 0 ] jump_addr;

    wire is_beq,is_bne,is_blt,is_bge,is_bltu,is_bgeu;
    wire is_b,is_bl,is_jirl;
    assign is_beq=~|(inst[29:26]^`BEQ);
    assign is_bne=~|(inst[29:26]^`BNE);
    assign is_blt=~|(inst[29:26]^`BLT);
    assign is_bge=~|(inst[29:26]^`BGE);
    assign is_bltu=~|(inst[29:26]^`BLTU);
    assign is_bgeu=~|(inst[29:26]^`BGEU);
    assign is_b=~|(inst[29:26]^`B);
    assign is_bl=~|(inst[29:26]^`BL);
    assign is_jirl=~|(inst[29:26]^`JIRL);

    assign is_branch=(is_branch_jump)&&(is_beq||is_bne||is_blt||is_bge||is_bltu||is_bgeu);
    assign is_jump=(is_branch_jump)&&(is_b||is_bl||is_jirl);
    assign branch_addr=pc+{{14{inst[25]}},inst[25:10],2'b00};
    assign jump_addr=(is_b||is_bl)?pc+{{4{inst[9]}},{inst[9:0], inst[25:10]},2'b0}:branch_oprand1+{{14{inst[25]}},inst[25:10],2'b00};
    assign jump_en=is_jump;

    wire [`DATA_WIDTH - 1: 0] branch_sub;
    wire branch_cout; 
    assign {branch_cout, branch_sub } = branch_oprand1 + ~branch_oprand2 + 1;
    wire branch_lt = (branch_oprand1[`DATA_WIDTH - 1] & ~branch_oprand2[`DATA_WIDTH - 1]) |
            |(~(branch_oprand1[`DATA_WIDTH - 1] ^ branch_oprand2[`DATA_WIDTH - 1]) & branch_sub[`DATA_WIDTH - 1]);
    wire branch_ltu = branch_oprand1 < branch_oprand2;
    always @(*)
    begin
        if(is_branch)
        begin
            case(inst[29:26])
            `BEQ: branch_en = ~|branch_sub;
            `BNE: branch_en = |branch_sub;
            `BLT: branch_en = branch_lt;
            `BGE: branch_en = ~branch_lt;
            `BLTU:branch_en = branch_ltu;
            `BGEU:branch_en = ~branch_ltu;
            default:branch_en=0;
            endcase
        end
        else
            branch_en=0;
    end

    //control signal
    //1.branch_info
    wire bran_flag = branch_en || jump_en;
    wire dir_pred_miss = bran_flag != if_info.branch;
    wire target_pred_miss = bran_flag & ~|(branch_info.branch_addr ^ if_info.branch_addr);
    assign predict_miss = (dir_pred_miss | target_pred_miss) & inst_valid;

    assign branch_info.taken = bran_flag;
    assign branch_info.branch_addr = jump_en ? jump_addr : branch_addr;
    assign branch_info.pc = pc;
    assign branch_info.branch_flag = is_branch_jump; 

    //2.regfile + id_info
    assign id_info.inst=inst;
    assign id_info.pc=pc;
    assign id_info.lsu_op=is_load_store?inst[25:22]:4'b1111;
    assign id_info.lsu_data=r2_data;

    logic [`DATA_WIDTH - 1 : 0 ] oprand1;
    logic [`DATA_WIDTH - 1 : 0 ] oprand2;
    assign id_info.oprand1=oprand1;
    assign id_info.oprand2=oprand2;

    always @(*)
    begin
        if(is_3r||is_ui5||is_si12)
        begin
            r1_en=1;
            r1_addr=rj_addr;
            r2_en=is_3r;
            r2_addr=rk_addr;
        end
        else if(is_branch)
        begin
            r1_en=1;
            r1_addr=rj_addr;
            r2_en=1;
            r2_addr=rd_addr;
        end
        else if(is_jump)
        begin
            r1_en=is_jirl;
            r1_addr=rj_addr;
            r2_en=0;
            r2_addr=5'b0;
        end
        else if(is_load_store)
        begin
            r1_en=1;
            r1_addr=rj_addr;
            r2_en=is_store;
            r2_addr=rd_addr;
        end
        else if(is_si20)
        begin
            r1_en=0;
            r1_addr=5'b0;
            r2_en=0;
            r2_addr=5'b0;
        end
        else if(is_csr)
        begin
            r1_en=is_csrxchg;
            r1_addr=rj_addr;
            r2_en=1;
            r2_addr=rd_addr;
        end
        else if(except_type_break||except_type_syscall)
        begin
            r1_en=0;
            r1_addr=5'b0;
            r2_en=0;
            r2_addr=5'b0;
        end
        else if(is_rdcnt)
        begin
            r1_en=0;
            r1_addr=5'b0;
            r2_en=0;
            r2_addr=5'b0;
        end
        else 
        begin
            r1_en=0;
            r1_addr=5'b0;
            r2_en=0;
            r2_addr=5'b0;
        end
    end
    always @(*)
    begin
        if(is_3r||is_ui5||is_si12)
        begin
            oprand1=r1_data;
            oprand2=is_3r?r2_data:(is_ui5?{27'b0,inst[14:10]}:(is_si12?si12_ext:32'b0));
            id_info.ex_op=alu_op;
            id_info.rw_en=1;
            id_info.rw_addr=rd_addr;
            inst_invaild=0;
        end
        else if(is_branch)
        begin
            oprand1 = 0;
            oprand2 = 0;
            id_info.ex_op = `ALU_XOR;
            id_info.rw_en = 0;
            id_info.rw_addr = 0;
            inst_invaild=0;
        end
        else if(is_jump)
        begin
            oprand1=pc;
            oprand2=32'b100;
            id_info.ex_op=`ALU_ADD;
            id_info.rw_en=is_bl||is_jirl;
            inst_invaild=1;
            id_info.rw_addr=is_bl?5'b1:rd_addr;
        end
        else if(is_load_store)
        begin
            oprand1=r1_data;
            oprand2=si12_ext;
            id_info.ex_op=`ALU_ADD;
            id_info.rw_en=is_load;
            id_info.rw_addr=rd_addr;
            inst_invaild=0;
        end
        else if(is_si20)
        begin
            oprand1=si20_ext;
            oprand2=is_pcaddu12i?pc:32'b0;
            id_info.ex_op=`ALU_ADD;
            id_info.rw_en=1;
            id_info.rw_addr=rd_addr;
            inst_invaild=0;
        end
        else if(is_csr)
        begin
            oprand1=id_info.csr_wdata;
            oprand2=0;
            id_info.ex_op=`ALU_OR;
            id_info.rw_en=1;
            id_info.rw_addr=rd_addr;
            inst_invaild=0;
        end
        else if(except_type_break||except_type_syscall)
        begin
            oprand1 = 0;
            oprand2 = 0;
            id_info.rw_en = 0;
            id_info.ex_op = `ALU_INVALID;
            id_info.rw_addr=rd_addr;
            inst_invaild=0;
        end
        else if(is_rdcnt)
        begin
            oprand1 = is_rdcntid?csr_tid:(is_rdcntvh?timer_64[63:32]:timer_64[31:0]);
            oprand2 = 0;
            id_info.rw_en = 1;
            id_info.ex_op = `ALU_OR;
            id_info.rw_addr=is_rdcntid?rj_addr:rd_addr;
            inst_invaild=0;
        end
        else 
        begin
            oprand1 = 0;
            oprand2 = 0;
            id_info.rw_en = 0;
            id_info.ex_op = `ALU_INVALID;
            id_info.rw_addr=rd_addr;
            inst_invaild=1;
        end
    end

    //csr
    logic [`DATA_WIDTH-1:0] csr_read_result;
    assign csr_addr=inst[23:10];
    assign csr_read_result = csr_data;
    //1.write csr reg data
    always @(*)
    begin
        if(is_csrrd)//csrrd
        begin
            id_info.csr_wen=0;
            id_info.csr_waddr=14'b0;
            id_info.csr_wdata=32'b0;
        end
        else if(is_csrwr)//csrwr
        begin
            id_info.csr_wen=1;
            id_info.csr_waddr=csr_addr;
            id_info.csr_wdata=r2_data;
        end
        else if(is_csrxchg)//csrxchg
        begin
            id_info.csr_wen=1;
            id_info.csr_waddr=csr_addr;
            id_info.csr_wdata=(r2_data & r1_data) | (csr_data & ~r1_data);
        end
        else
        begin
            id_info.csr_wen=0;
            id_info.csr_waddr=14'b0;
            id_info.csr_wdata=32'b0;
        end
    end
    

endmodule