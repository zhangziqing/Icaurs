`include "width_param.sv"
`include "csr_reg.sv"
`include "constant.sv"

`define n 5

module CSR(
    input                               clk,
    input                               rst,
    //read data
    input   [`CSRNUM_WIDTH - 1 : 0 ]    csr_raddr,
    output  logic [`DATA_WIDTH - 1   : 0 ]    csr_rdata,
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
    input   [`DATA_WIDTH - 1   : 0 ]    etype,
    input   [`DATA_WIDTH - 1   : 0 ]    epc,

    input                           is_ertn,
    //interrupt 
    input                           ipi,
    input [7:0]                     hwi,
    output                          is_interrupt,
    //timer 64
    output logic [63:0]             timer_64,
    output logic [31:0]             timer_id
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

    //except
    logic [`DATA_WIDTH - 1 : 0] except_type;
    always @(*)
    begin
        if(csr_crmd[2]==1'b1)
        begin
            if(csr_estat[12:0]&csr_ecfg[12:0])
                except_type=`excepttype_int;
            else
                except_type=`excepttype_non;
        end
        else if(csr_crmd[2]==1'b0)
        begin
            if(etype[13]==1'b1)
                except_type=`excepttype_ine;
            else if(etype[14]==1'b1)
                except_type=`excepttype_sys;
            else if(etype[15]==1'b1)
                except_type=`excepttype_brk;
        end
        else
            except_type=`excepttype_non;
    end
    logic is_except;
    always @(*)
    begin
        case(except_type)
        `excepttype_int ,
        `excepttype_pil ,
        `excepttype_pis ,
        `excepttype_pif ,
        `excepttype_pme ,
        `excepttype_ppi ,
        `excepttype_adef,
        `excepttype_adem,
        `excepttype_ale ,
        `excepttype_sys ,
        `excepttype_brk ,
        `excepttype_ine ,
        `excepttype_ipe ,
        `excepttype_fpd ,
        `excepttype_fpe ,
        `excepttype_tlbr:is_except=1'b1;
        default:is_except=1'b0;
        endcase
    end

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
    //2.1 timer
    wire tcfg_wen,tval_wen,ticlr_wen;
    assign tcfg_wen=csr_wen&&(csr_waddr==`CSR_TCFG);
    assign tval_wen=csr_wen&&(csr_waddr==`CSR_TVAL);
    assign ticlr_wen=csr_wen&&(csr_waddr==`CSR_TICLR);
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
            csr_tval<={csr_wdata[31:2],2'b00};
        else if (timer_en)
        begin
            if(csr_tval!=32'b0)
                csr_tval<=csr_tval-32'b1;
            else if(csr_tval==32'b0)
                csr_tval<=csr_tcfg[1]?{csr_tcfg[31:2],2'b00}:32'hffffffff;
        end 
    end
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
    //2.2 crmdi
    wire crmd_wen;
    assign crmd_wen=csr_wen&&(csr_waddr==`CSR_CRMD);
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
        else 
        begin
            csr_crmd<=csr_crmd;
        end
    end
    //2.3 prmd
    wire prmd_wen;
    assign prmd_wen=csr_wen&&(csr_waddr==`CSR_PRMD);
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
        else
        begin
            csr_prmd<=csr_prmd;
        end
    end
    //2.4 estat
    wire estat_wen;
    assign estat_wen=csr_wen&&(csr_waddr==`CSR_ESTAT);
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
            else if(is_ertn)
            begin
                csr_estat[1:0]<=csr_wdata[1:0];
            end
        end
    end
    //2.5 era
    wire era_wen;
    assign era_wen=csr_wen&&(csr_waddr==`CSR_ERA);
    always @(posedge clk)
    begin
        if(is_except)
            csr_era<=epc;
        else if(era_wen)
            csr_era<=csr_wdata;
    end
    //2.6 others
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_euen[0]     <=1'b0;
            csr_euen[31:1]  <=31'b0;

            csr_ecfg[12:0]  <=13'b0;
            csr_ecfg[31:13] <=19'b0;

            csr_eentry[5:0] <=6'b0;

            csr_cpuid       <=32'b0;

            csr_tcfg[0]    <=1'b0;
            csr_llbctl[2]  <=1'b0;

            csr_tlbehi[12:0]<=13'b0;

            csr_tlbelo0[7]<=1'b0;

            csr_tlbelo1[7]<=1'b0;

            csr_asid[15:10]<=6'b0;
            csr_asid[31:24]<=8'b0;

            csr_pgdl[11:0]<=12'b0;

            csr_pgdh[11:0]<=12'b0;

            csr_pgd[11:0]<=12'b0;
            
            csr_tlbrentry[5:0]<=6'b0;

            csr_dmw0[0]    <=1'b0;
            csr_dmw0[2:1]  <=2'b0;
            csr_dmw0[3]    <=1'b0;
            csr_dmw0[24:6] <=19'b0;
            csr_dmw0[28]   <=1'b0;

            csr_dmw1[0]    <=1'b0;
            csr_dmw1[2:1]  <=2'b0;
            csr_dmw1[3]    <=1'b0;
            csr_dmw1[24:6] <=19'b0;
            csr_dmw1[28]   <=1'b0;

            csr_tid<=32'b0;

            csr_tcfg[0]<=1'b0;
            
            csr_ticlr[31:0]<=32'b0;
        end
        else if(csr_wen)
        begin
            case(csr_waddr)  
            `CSR_EUEN:
            begin
                csr_euen[0]<=csr_wdata[0];
            end      
            `CSR_ECFG:
            begin
                csr_ecfg[12:0]<=csr_wdata[12:0];
            end           
            `CSR_BADV:
            begin
                csr_badv[31:0]<=csr_wdata[31:0];
            end      
            `CSR_EENTRY:
            begin
                csr_eentry[31:6]<=csr_wdata[31:6];
            end   
            `CSR_TLBIDX:
            begin
                csr_tlbidx[`n-1:0]<=csr_wdata[`n-1:0];
                csr_tlbidx[29:24]<=csr_wdata[29:24];
                csr_tlbidx[31]<=csr_wdata[31];
            end    
            `CSR_TLBEHI:
            begin
                csr_tlbehi[31:13]<=csr_wdata[31:13];
            end  
            `CSR_TLBELO0:
            begin
                csr_tlbelo0[6:0]<=csr_wdata[6:0];
                csr_tlbelo0[31:8]<=csr_wdata[31:8];
            end   
            `CSR_TLBELO1:
            begin
                csr_tlbelo1[6:0]<=csr_wdata[6:0];
                csr_tlbelo1[31:8]<=csr_wdata[31:8];
            end   
            `CSR_ASID:
            begin
                csr_asid[9:0]<=csr_wdata[9:0];
            end     
            `CSR_PGDL:
            begin
                csr_pgdl[31:12]<=csr_wdata[31:12];
            end      
            `CSR_PGDH:
            begin
                csr_pgdh[31:12]<=csr_wdata[31:12];
            end      
            `CSR_PGD:
            begin
                csr_pgd[31:12]<=csr_wdata[31:12];
            end    
            `CSR_CPUID:
            begin
                //cann't write
            end    
            `CSR_SAVE0:
            begin
                csr_save0[31:0]<=csr_wdata[31:0];
            end   
            `CSR_SAVE1:
            begin
                csr_save1[31:0]<=csr_wdata[31:0];
            end  
            `CSR_SAVE2:
            begin
                csr_save2[31:0]<=csr_wdata[31:0];
            end    
            `CSR_SAVE3:
            begin
                csr_save3[31:0]<=csr_wdata[31:0];
            end    
            `CSR_TID:
            begin
                csr_tid[31:0]<=csr_wdata[31:0];
            end      
            `CSR_TCFG:
            begin
                csr_tcfg[31:0]<=csr_wdata[31:0];
            end      
            `CSR_TICLR:
            begin
                csr_ticlr[31:0]<=32'b0;
            end     
            `CSR_LLBCTL:
            begin
                csr_llbctl[1]<=(csr_wdata[1] <= 1) ? 1'b1 : csr_llbctl[1];
            end    
            `CSR_TLBRENTRY:
            begin
                csr_tlbrentry[31:6]<=csr_wdata[31:6];
            end 
            `CSR_CTAG:
            begin
                //cann't find it!
            end    
            `CSR_DMW0:
            begin
                csr_dmw0[0]<=csr_wdata[0];
                csr_dmw0[5:3]<=csr_wdata[5:3];
                csr_dmw0[27:25]<=csr_wdata[27:25];
                csr_dmw0[31:29]<=csr_wdata[31:29];
            end      
            `CSR_DMW1:
            begin
                csr_dmw1[0]<=csr_wdata[0];
                csr_dmw1[5:3]<=csr_wdata[5:3];
                csr_dmw1[27:25]<=csr_wdata[27:25];
                csr_dmw1[31:29]<=csr_wdata[31:29];
            end
            default:
            begin
            end      
            endcase
        end
    end
endmodule