`include "width_param.sv"  

module PipelineController(
    input predict_miss,
    input  [`ADDR_WIDTH - 1 : 0]    real_addr,

    input exp_en,
    input e_ret,
    input  [`ADDR_WIDTH - 1 : 0]    epc,
    input  [`ADDR_WIDTH - 1 : 0]    trap_entry,

    output [ 4  : 0 ] flush,
    output [ `ADDR_WIDTH - 1 : 0 ]  flush_pc
);

    assign flush = predict_miss ? 5'b11000 : 5'b0;

    assign flush_pc = predict_miss  ?   real_addr :
                      exp_en        ?   trap_entry:
                      e_ret         ?   epc :
                      0;

endmodule