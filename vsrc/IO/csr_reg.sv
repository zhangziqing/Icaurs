`include "vsrc/include/width_param.sv"

interface csr_reg;

    logic [`DATA_WIDTH-1:0] crmd;
    logic [`DATA_WIDTH-1:0] prmd;
    logic [`DATA_WIDTH-1:0] euen;
    logic [`DATA_WIDTH-1:0] ecfg;
    logic [`DATA_WIDTH-1:0] estat;
    logic [`DATA_WIDTH-1:0] era;
    logic [`DATA_WIDTH-1:0] badv;
    logic [`DATA_WIDTH-1:0] eentry;
    logic [`DATA_WIDTH-1:0] tlbidx;
    logic [`DATA_WIDTH-1:0] tlbehi;
    logic [`DATA_WIDTH-1:0] tlbelo0;
    logic [`DATA_WIDTH-1:0] tlbelo1;
    logic [`DATA_WIDTH-1:0] asid;
    logic [`DATA_WIDTH-1:0] pgdl;
    logic [`DATA_WIDTH-1:0] pgdh;
    logic [`DATA_WIDTH-1:0] pgd;
    logic [`DATA_WIDTH-1:0] cpuid;
    logic [`DATA_WIDTH-1:0] save0;
    logic [`DATA_WIDTH-1:0] save1;
    logic [`DATA_WIDTH-1:0] save2;
    logic [`DATA_WIDTH-1:0] save3;
    logic [`DATA_WIDTH-1:0] tid;
    logic [`DATA_WIDTH-1:0] tcfg;
    logic [`DATA_WIDTH-1:0] tval;
    logic [`DATA_WIDTH-1:0] ticlr;
    logic [`DATA_WIDTH-1:0] llbctl;
    logic [`DATA_WIDTH-1:0] tlbrentry;
    logic [`DATA_WIDTH-1:0] ctag;
    logic [`DATA_WIDTH-1:0] dmw0;
    logic [`DATA_WIDTH-1:0] dmw1;

    modport i(
    input crmd,
    input prmd,
    input euen,
    input ecfg,
    input estat,
    input era,
    input badv,
    input eentry,
    input tlbidx,
    input tlbehi,
    input tlbelo0,
    input tlbelo1,
    input asid,
    input pgdl,
    input pgdh,
    input pgd,
    input cpuid,
    input save0,
    input save1,
    input save2,
    input save3,
    input tid,
    input tcfg,
    input tval,
    input ticlr,
    input llbctl,
    input tlbrentry,
    input ctag,
    input dmw0,
    input dmw1
    );

    modport o(
    output crmd,
    output prmd,
    output euen,
    output ecfg,
    output estat,
    output era,
    output badv,
    output eentry,
    output tlbidx,
    output tlbehi,
    output tlbelo0,
    output tlbelo1,
    output asid,
    output pgdl,
    output pgdh,
    output pgd,
    output cpuid,
    output save0,
    output save1,
    output save2,
    output save3,
    output tid,
    output tcfg,
    output tval,
    output ticlr,
    output llbctl,
    output tlbrentry,
    output ctag,
    output dmw0,
    output dmw1
    );

endinterface