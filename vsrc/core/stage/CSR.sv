`include "width_param.sv"
`include "csr_reg.sv"
`include "constant.sv"

`define n 5

module CSR(
    input                               clk,
    input                               rst,
    //read data
    input           [`CSRNUM_WIDTH - 1 : 0 ]    csr_raddr,
    output  logic   [`DATA_WIDTH - 1   : 0 ]    csr_rdata,
    //write data
    input                               csr_wen,
    input   [`CSRNUM_WIDTH - 1 : 0 ]    csr_waddr,
    input   [`DATA_WIDTH - 1   : 0 ]    csr_wdata,
    //output csr reg info
    //asid
    //dmw0
    //dmw1
    //etc
    output  [`DATA_WIDTH - 1   : 0 ]   era,
    output  [`DATA_WIDTH - 1   : 0 ]   trap_entry,
    
    //except
    input                               is_except,
    input   [`DATA_WIDTH - 1   : 0 ]    epc,

    input                           is_ertn,
    //interrupt 
    input                           ipi,
    input [7:0]                     hwi,
    output                          is_interrupt,
    //timer 64
    output logic [63:0]             timer_64,
    output logic [31:0]             timer_id,
    //badv va error
    input           is_va_error,
    input [31:0]    va_error_in
);
    logic [`DATA_WIDTH-1:0] csr_crmd;
    logic [`DATA_WIDTH-1:0] csr_prmd;
    logic [`DATA_WIDTH-1:0] csr_euen;
    logic [`DATA_WIDTH-1:0] csr_ecfg;
    logic [`DATA_WIDTH-1:0] csr_estat;
    logic [`DATA_WIDTH-1:0] csr_era;
    logic [`DATA_WIDTH-1:0] csr_badv;
    logic [`DATA_WIDTH-1:0] csr_eentry;
    logic [`DATA_WIDTH-1:0] csr_tlbidx;
    logic [`DATA_WIDTH-1:0] csr_tlbehi;
    logic [`DATA_WIDTH-1:0] csr_tlbelo0;
    logic [`DATA_WIDTH-1:0] csr_tlbelo1;
    logic [`DATA_WIDTH-1:0] csr_asid;
    logic [`DATA_WIDTH-1:0] csr_pgdl;
    logic [`DATA_WIDTH-1:0] csr_pgdh;
    logic [`DATA_WIDTH-1:0] csr_pgd;
    logic [`DATA_WIDTH-1:0] csr_cpuid;
    logic [`DATA_WIDTH-1:0] csr_save0;
    logic [`DATA_WIDTH-1:0] csr_save1;
    logic [`DATA_WIDTH-1:0] csr_save2;
    logic [`DATA_WIDTH-1:0] csr_save3;
    logic [`DATA_WIDTH-1:0] csr_tid;
    logic [`DATA_WIDTH-1:0] csr_tcfg;
    logic [`DATA_WIDTH-1:0] csr_tval;
    logic [`DATA_WIDTH-1:0] csr_ticlr;
    logic [`DATA_WIDTH-1:0] csr_llbctl;
    logic [`DATA_WIDTH-1:0] csr_tlbrentry;
    logic [`DATA_WIDTH-1:0] csr_ctag;
    logic [`DATA_WIDTH-1:0] csr_dmw0;
    logic [`DATA_WIDTH-1:0] csr_dmw1;
    
    //timer 64
    always @(posedge clk)
    begin
        if(rst)
        begin
            timer_64<=64'b0;
        end
        else
        begin
            timer_64<=timer_64+1'b1;
        end
    end
    assign timer_id=csr_tid;

    //interrupt
    assign is_interrupt=csr_crmd[2]&(|(csr_estat[12:0]&csr_ecfg[12:0]));

    // //except
    // logic [`DATA_WIDTH - 1 : 0] except_type;
    // always @(*)
    // begin
    //     if(csr_crmd[2]==1'b1)
    //     begin
    //         if(csr_estat[12:0]&csr_ecfg[12:0])
    //             except_type=`excepttype_int;
    //         else
    //             except_type=`excepttype_non;
    //     end
    //     else if(csr_crmd[2]==1'b0)
    //     begin
    //         if(etype[13]==1'b1)
    //             except_type=`excepttype_ine;
    //         else if(etype[14]==1'b1)
    //             except_type=`excepttype_sys;
    //         else if(etype[15]==1'b1)
    //             except_type=`excepttype_brk;
    //     end
    //     else
    //         except_type=`excepttype_non;
    // end
    // logic is_except;
    // always @(*)
    // begin
    //     case(except_type)
    //     `excepttype_int ,
    //     `excepttype_pil ,
    //     `excepttype_pis ,
    //     `excepttype_pif ,
    //     `excepttype_pme ,
    //     `excepttype_ppi ,
    //     `excepttype_adef,
    //     `excepttype_adem,
    //     `excepttype_ale ,
    //     `excepttype_sys ,
    //     `excepttype_brk ,
    //     `excepttype_ine ,
    //     `excepttype_ipe ,
    //     `excepttype_fpd ,
    //     `excepttype_fpe ,
    //     `excepttype_tlbr:is_except=1'b1;
    //     default:is_except=1'b0;
    //     endcase
    // end

    //1.read csr reg data
    always @(*)
    begin
        case(csr_raddr)
        `CSR_CRMD:      csr_rdata=csr_crmd;
        `CSR_PRMD:      csr_rdata=csr_prmd;   
        `CSR_EUEN:      csr_rdata=csr_euen;     
        `CSR_ECFG:      csr_rdata=csr_ecfg;  
        `CSR_ESTAT:     csr_rdata=csr_estat;
        `CSR_ERA:       csr_rdata=csr_era;
        `CSR_BADV:      csr_rdata=csr_badv; 
        `CSR_EENTRY:    csr_rdata=csr_eentry;
        `CSR_TLBIDX:    csr_rdata=csr_tlbidx; 
        `CSR_TLBEHI:    csr_rdata=csr_tlbehi;  
        `CSR_TLBELO0:   csr_rdata=csr_tlbelo0;   
        `CSR_TLBELO1:   csr_rdata=csr_tlbelo1;   
        `CSR_ASID:      csr_rdata=csr_asid;      
        `CSR_PGDL:      csr_rdata=csr_pgdl;   
        `CSR_PGDH:      csr_rdata=csr_pgdh;    
        `CSR_PGD:       csr_rdata=csr_pgd;      
        `CSR_CPUID:     csr_rdata=csr_cpuid;   
        `CSR_SAVE0:     csr_rdata=csr_save0;
        `CSR_SAVE1:     csr_rdata=csr_save1;  
        `CSR_SAVE2:     csr_rdata=csr_save2;  
        `CSR_SAVE3:     csr_rdata=csr_save3;  
        `CSR_TID:       csr_rdata=csr_tid;       
        `CSR_TCFG:      csr_rdata=csr_tcfg;     
        `CSR_TVAL:      csr_rdata=csr_tval;      
        `CSR_TICLR:     csr_rdata=csr_ticlr;  
        `CSR_LLBCTL:    csr_rdata=csr_llbctl;  
        `CSR_TLBRENTRY: csr_rdata=csr_tlbrentry; 
        `CSR_CTAG:      csr_rdata=csr_ctag;     
        `CSR_DMW0:      csr_rdata=csr_dmw0;   
        `CSR_DMW1:      csr_rdata=csr_dmw1;
        default:        csr_rdata=32'b0;     
        endcase
    end

    //2.write csr reg data
    //csr reg write signal
    logic crmd_wen      = csr_wen && (csr_waddr == `CSR_CRMD        );
    logic prmd_wen      = csr_wen && (csr_waddr == `CSR_PRMD        );
    logic euen_wen      = csr_wen && (csr_waddr == `CSR_EUEN        );
    logic ecfg_wen      = csr_wen && (csr_waddr == `CSR_ECFG        );
    logic estat_wen     = csr_wen && (csr_waddr == `CSR_ESTAT       );
    logic era_wen       = csr_wen && (csr_waddr == `CSR_ERA         );
    logic badv_wen      = csr_wen && (csr_waddr == `CSR_BADV        );
    logic eentry_wen    = csr_wen && (csr_waddr == `CSR_EENTRY      );
    logic tlbidx_wen    = csr_wen && (csr_waddr == `CSR_TLBIDX      );
    logic tlbehi_wen    = csr_wen && (csr_waddr == `CSR_TLBEHI      );
    logic tlbelo0_wen   = csr_wen && (csr_waddr == `CSR_TLBELO0     );
    logic tlbelo1_wen   = csr_wen && (csr_waddr == `CSR_TLBELO1     );
    logic asid_wen      = csr_wen && (csr_waddr == `CSR_ASID        );
    logic pgdl_wen      = csr_wen && (csr_waddr == `CSR_PGDL        );
    logic pgdh_wen      = csr_wen && (csr_waddr == `CSR_PGDH        );
    logic pgd_wen       = csr_wen && (csr_waddr == `CSR_PGD         );
    logic cpuid_wen     = csr_wen && (csr_waddr == `CSR_CPUID       );
    logic save0_wen     = csr_wen && (csr_waddr == `CSR_SAVE0       );
    logic save1_wen     = csr_wen && (csr_waddr == `CSR_SAVE1       );
    logic save2_wen     = csr_wen && (csr_waddr == `CSR_SAVE2       );
    logic save3_wen     = csr_wen && (csr_waddr == `CSR_SAVE3       );
    logic tid_wen       = csr_wen && (csr_waddr == `CSR_TID         );
    logic tcfg_wen      = csr_wen && (csr_waddr == `CSR_TCFG        );
    logic tval_wen      = csr_wen && (csr_waddr == `CSR_TVAL        );
    logic ticlr_wen     = csr_wen && (csr_waddr == `CSR_TICLR       );
    logic llbctl_wen    = csr_wen && (csr_waddr == `CSR_LLBCTL      );
    logic tlbrentry_wen = csr_wen && (csr_waddr == `CSR_TLBRENTRY   );
    logic ctag_wen      = csr_wen && (csr_waddr == `CSR_CTAG        );
    logic dmw0_wen      = csr_wen && (csr_waddr == `CSR_DMW0        );
    logic dmw1_wen      = csr_wen && (csr_waddr == `CSR_DMW1        );

    //2.1 Basic control status register
    //2.1.1 crmd
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_crmd[8:0]  <=9'b000001000;
            csr_crmd[31:9] <=23'b0;
        end
        else if(is_except)
        begin
            csr_crmd[2:0]  <=3'b0;
        end
        else if(is_ertn)
        begin
            csr_crmd[2:0]  <=csr_prmd[2:0];
        end
        else if(crmd_wen)
        begin
            csr_crmd[8:0]  <=csr_wdata[8:0];
        end
    end
    //2.1.2 prmd
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_prmd[31:3]<=29'b0;
        end
        else if(is_except)
        begin
            csr_prmd[2:0]<=csr_crmd[2:0];
        end
        else if(prmd_wen)
        begin
            csr_prmd[2:0]<=csr_wdata[2:0];
        end
    end
    //2.1.3 euen
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_euen[31:1]<=31'b0;
        end
        else if(euen_wen)
        begin
            csr_euen[0]<=csr_wdata[0];
        end
    end
    //2.1.4 ecfg
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_ecfg[31:13]<=19'b0;
        end
        else if(ecfg_wen)
        begin
            csr_ecfg[12:0]<=csr_wdata[12:0];
        end
    end
    //2.1.5 estat
    logic timer_interrupt;
    always @(posedge clk)
    begin
        if(rst)
            timer_interrupt<=1'b0;
        else if(ticlr_wen&&csr_wdata[0]==1'b1)
            timer_interrupt<=1'b0;
        else if(timer_en&&csr_tval==32'b0)
            timer_interrupt<=1'b1;
    end
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_estat[1:0]<=2'b0;
            csr_estat[15:13]<=3'b0;
            csr_estat[31]<=1'b0;
        end
        else 
        begin
            csr_estat[12:2]<={ipi,timer_interrupt,hwi};
            if(is_except)
            begin
                csr_estat[21:16]<=except_type[5:0];
                csr_estat[30:22]<=except_type[16:8];
            end
            else if(estat_wen)
            begin
                csr_estat[1:0]<=csr_wdata[1:0];
            end
        end
    end
    //2.1.6 era
    always @(posedge clk)
    begin
        if(is_except)
            csr_era<=epc;
        else if(era_wen)
            csr_era<=csr_wdata;
    end
    //2.1.7 badv
    always @(posedge clk)
    begin
        if(is_va_error)
        begin
            csr_badv<=va_error_in;
        end
        else if(badv_wen)
        begin
            csr_badv<=csr_wdata;
        end
    end
    //2.1.8 eentry
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_eentry[5:0]<=6'b0;
        end
        else if(eentry_wen)
        begin
            csr_eentry[31:6]<=csr_wdata[31:6];
        end
    end
    //2.1.9 cpuid
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_cpuid<=32'b0;
        end
    end
    //2.1.10.0 save0
    always @(posedge clk)
    begin
        if(save0_wen)
        begin
            csr_save0<=csr_wdata;
        end
    end
    //2.1.10.1 save1
    always @(posedge clk)
    begin
        if(save1_wen)
        begin
            csr_save1<=csr_wdata;
        end
    end
    //2.1.10.2 save2
    always @(posedge clk)
    begin
        if(save2_wen)
        begin
            csr_save2<=csr_wdata;
        end
    end
    //2.1.10.3 save3
    always @(posedge clk)
    begin
        if(save3_wen)
        begin
            csr_save3<=csr_wdata;
        end
    end
    //2.1.11 llbctl
    reg llbit;
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_llbctl[31:2]<=30'b0;
            llbit<=1'b0;
        end
        else if(llbctl_wen)
        begin
            csr_llbctl[2]<=csr_wdata[2];
            if(csr_wdata[1]==1'b1)
            begin
                llbit=1'b0;
            end
        end
        else if(is_ertn)
        begin
            if(csr_llbctl[2]==1'b1)
            begin
                csr_llbctl[2]<=1'b0;
            end
            else
            begin
                llbit<=1'b0;
            end
        end
    end

    //2.2 Mapping address translation related control status register
    //2.2.1 tlbidx

    //2.2.2 tlbehi

    //2.2.3.0 tlbelo0

    //2.2.3.1 tlbelo1

    //2.2.4 asid

    //2.2.5 pgdl
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_pgdl[11:0]<=12'b0;
        end
        else if(pgdl_wen)
        begin
            csr_pgdl[31:12]<=csr_wdata[31:12];
        end
    end
    //2.2.6 pgdh
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_pgdh[11:0]<=12'b0;
        end
        else if(pgdh_wen)
        begin
            csr_pgdh[31:12]<=csr_wdata[31:12];
        end
    end
    //2.2.7 pgd
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_pgd[11:0]<=12'b0;
        end
        else 
        begin
            if(csr_badv[31]==1'b0)
            begin
                csr_pgd[31:12]<=csr_pgdl[31:12];
            end
            else
            begin
                csr_pgd[31:12]<=csr_pgdh[31:12];
            end
        end
    end
    //2.2.8 tlbrentry
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_tlbrentry[5:0]<=6'b0;
        end
        else if(tlbrentry_wen)
        begin
            csr_tlbrentry[31:6]<=csr_wdata[31:6];
        end
    end
    //2.2.9.0 dmw0
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_dmw0[2:1]<=2'b0;
            csr_dmw0[24:6]<=19'b0;
            csr_dmw0[28]<=1'b0;
        end
        else if(dmw0_wen)
        begin
            csr_dmw0[0]<=csr_wdata[0];
            csr_dmw0[5:3]<=csr_wdata[5:3];
            csr_dmw0[27:25]<=csr_wdata[27:25];  
            csr_dmw0[31:29]<=csr_wdata[31:29];          
        end
    end
    //2.2.9.1 dmw1
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_dmw1[2:1]<=2'b0;
            csr_dmw1[24:6]<=19'b0;
            csr_dmw1[28]<=1'b0;
        end
        else if(dmw1_wen)
        begin
            csr_dmw1[0]<=csr_wdata[0];
            csr_dmw1[5:3]<=csr_wdata[5:3];
            csr_dmw1[27:25]<=csr_wdata[27:25];  
            csr_dmw1[31:29]<=csr_wdata[31:29];          
        end
    end

    //2.3 Timer related control status register
    //2.3.1 tid
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_tid<=32'b0;
        end
        else if(tid_wen)
        begin
            csr_tid<=csr_wdata;
        end
    end
    //2.3.2 tcfg
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_tcfg[0]<=1'b0;
        end
        else if(tcfg_wen)
        begin
            csr_tcfg<=csr_wdata;
        end
    end
    //2.3.3 tval
    logic timer_en;
    always @(posedge clk)
    begin
        if(rst)
            timer_en<=1'b0;
        else if(tcfg_wen)
            timer_en<=csr_wdata[0];
        else if(timer_en&&csr_tval==32'b0)
            timer_en<=csr_tcfg[1];
    end
    always @(posedge clk)
    begin
        if(tcfg_wen)
        begin
            csr_tval<={csr_wdata[31:2],2'b00};
        end
        else if (timer_en)
        begin
            if(csr_tval!=32'b0)
            begin
                csr_tval<=csr_tval-32'b1;
            end
            else if(csr_tval==32'b0)
            begin
                csr_tval<=csr_tcfg[1]?{csr_tcfg[31:2],2'b00}:32'hffffffff;
            end
        end 
    end
    //2.3.4 ticlr
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_ticlr<=32'b0;
        end
    end
    
endmodule