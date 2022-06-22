`include "vsrc/include/width_param.sv"
/**
    There are four functions of Instruction decode module
    1. Generate the oprands
    2. Generate the opcode for execution unit 
    3. Generate the ls_data and ls_op
    4. Generate the branch info and jump info
*/


module InstDecode(
    input [`INST_WIDTH - 1 : 0]     inst,
    input [`ADDR_WIDTH - 1 : 0]     pc,

    //register interface

    /*
        r1 : regRead1;
        r2 : regRead2;
        rw : regWrite
    */
    output                          r1_en,
    output  [`REG_WIDTH - 1 : 0]    r1_addr,
    input   [`DATA_WIDTH - 1: 0]    r1_data,
    output                          r2_en,
    output  [`REG_WIDTH - 1 : 0]    r2_addr,
    input   [`DATA_WIDTH - 1: 0]    r2_data,


    //stage interface
    id_stage_if.o                 id_info,

    //branch info
    branch_info_if.o               branch_info
);

    //generate the oprands
    wire [`REG_WIDTH - 1 : 0] rd_addr = inst[4:0];
    wire [`REG_WIDTH - 1 : 0] rj_addr = inst[9:5];
    wire [`REG_WIDTH - 1 : 0] rk_addr = inst[14:10];


    wire [19:0] si20 = inst[24:5];
    wire [11:0] si12 = inst[21:10];
    wire [13:0] si14 = inst[23:10];

    wire [`DATA_WIDTH - 1 : 0] si20_ext = {si20,12'b0};
    wire [`DATA_WIDTH - 1 : 0] si12_ext = {20'b0, si12};
    
    assign id_info.oprand1 = 0;


    //oprand type
    wire [13:0] csr_code = inst[23:10];

    wire is_branch = ~|(inst[31:30] ^ 2'b01);
    wire is_load_store = ~|(inst[31:29] ^ 3'b001);
    wire is_store = is_load_store && ~|(inst[28:24] == 5'b01001);

    /**
    *   register:0
    *   I12:1
    *   I20:2
    */
    wire op_rand_type ;

    wire [`DATA_WIDTH - 1 : 0] branch_oprand1 = r1_data;
    wire [`DATA_WIDTH - 1 : 0] branch_oprand2 = r2_data;

    wire branch_en;//TODO
    wire branch_addr = 0; //TODO

    wire jump_en;//TODO
    wire jump_addr = 0;//TODO

endmodule



