`include "include/width_param.sv"

module InstDecode(
    input [`INST_WITDH - 1]     inst,
    input [`ADDR_WIDTH - 1]     pc,

    //register interface

    /*
        rs : regRead1;
        rt : regRead2;
        rd : regWrite
    */
    output                      rs_en,
    output  [`REG_WIDTH - 1]    rs_addr,
    input   [`DATA_WIDTH - 1]   rs_data,
    output                      rt_en,
    output  [`REG_WIDTH - 1]    rt_addr,
    input   [`DATA_WIDTH - 1]   rt_data,
    output                      rd_en,
    output  [`REG_WIDTH - 1]    rd_addr,
    output  [`DATA_WIDTH - 1]   rd_data,


    //stage interface
    id_stage.o                 id_info,

    //branch info
    branch_info.o               branch_info,
);
    wire [`REG_WIDTH - 1 : 0] reg1_addr = inst[4:0];
    wire [`REG_WIDTH - 1 : 0] reg2_addr = inst[9:5];
    wire [`REG_WIDTH - 1 : 0] regW_addr = inst[14:10];


    wire [19:0] si20 = inst[24:5];
    wire [11:0] si12 = inst[21:10];
    wire [13:0] si14 = inst[23:10];

    wire [13:0] csr_code = inst[23:10];

    wire is_branch = inst[31:30] == 2'b01;
    wire is_load_store = inst[31:29] == 3'b001;

    always_comb begin : ex_op
        
    end

endmodule



