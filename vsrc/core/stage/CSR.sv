`include "vsrc/include/width_param.sv"
`include "vsrc/include/csr_reg.sv"
`include "vsrc/IO/csr_reg.sv"

`define n 5

module CSR(
    input                           clk,
    input                           rst,
    //read data
    input   [`CSR_REG_WIDTH-1:0]    r_addr,
    output  [`DATA_WIDTH-1:0]       r_data,
    //write data
    csrData_pushForwward.i          csr_rw_info,
    //output csr reg info
    csr_reg.o                       csr_info,
    //except
    except_info.i                   mem_except_info,
    input                           is_ertn,
    //interrupt 
    input                           ipi,
    input [7:0]                     hwi,
    output                          is_interrupt,
    //timer 64
    output logic [63:0]             timer_64,
    output logic [31:0]             csr_tid
);
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
    assign csr_tid=csr_info.tid;

    //interrupt
    assign is_interrupt=csr_info.crmd[2]&&((csr_info.estat[12:0]&csr_info.ecfg[12:0])!=13'b0);

    //except
    logic is_except;
    always @(*)
    begin
        case(mem_except_info.except_type)
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
        case(r_addr)
        `CSR_CRMD:      r_data=csr_info.crmd;
        `CSR_PRMD:      r_data=csr_info.prmd;   
        `CSR_EUEN:      r_data=csr_info.euen;     
        `CSR_ECFG:      r_data=csr_info.ecfg;  
        `CSR_ESTAT:     r_data=csr_info.estat;
        `CSR_ERA:       r_data=csr_info.era;
        `CSR_BADV:      r_data=csr_info.badv; 
        `CSR_EENTRY:    r_data=csr_info.eentry;
        `CSR_TLBIDX:    r_data=csr_info.tlbidx; 
        `CSR_TLBEHI:    r_data=csr_info.tlbehi;  
        `CSR_TLBELO0:   r_data=csr_info.tlbelo0;   
        `CSR_TLBELO1:   r_data=csr_info.tlbelo1;   
        `CSR_ASID:      r_data=csr_info.asid;      
        `CSR_PGDL:      r_data=csr_info.pgdl;   
        `CSR_PGDH:      r_data=csr_info.pgdh;    
        `CSR_PGD:       r_data=csr_info.pgd;      
        `CSR_CPUID:     r_data=csr_info.cpuid;   
        `CSR_SAVE0:     r_data=csr_info.save0;
        `CSR_SAVE1:     r_data=csr_info.save1;  
        `CSR_SAVE2:     r_data=csr_info.save2;  
        `CSR_SAVE3:     r_data=csr_info.save3;  
        `CSR_TID:       r_data=csr_info.tid;       
        `CSR_TCFG:      r_data=csr_info.tcfg;     
        `CSR_TVAL:      r_data=csr_info.tval;      
        `CSR_TICLR:     r_data=csr_info.ticlr;  
        `CSR_LLBCTL:    r_data=csr_info.llbctl;  
        `CSR_TLBRENTRY: r_data=csr_info.tlbrentry; 
        `CSR_CTAG:      r_data=csr_info.ctag;     
        `CSR_DMW0:      r_data=csr_info.dmw0;   
        `CSR_DMW1:      r_data=csr_info.dmw1;
        default:        r_data=32'b0;     
        endcase
    end

    //2.write csr reg data
    //2.1 timer
    wire tcfg_wen,tval_wen,ticlr_wen;
    assign tcfg_wen=csr_rw_info.rw_en&&(csr_rw_info.rw_addr==`CSR_TCFG);
    assign tval_wen=csr_rw_info.rw_en&&(csr_rw_info.rw_addr==`CSR_TVAL);
    assign ticlr_wen=csr_rw_info.rw_en&&(csr_rw_info.rw_addr==`CSR_TICLR);
    wire timer_en;
    always @(posedge clk)
    begin
        if(rst)
            timer_en<=1'b0;
        else if(tcfg_wen)
            timer_en<=csr_rw_info.rw_data[0];
        else if(timer_en&&csr_info.tval==32'b0)
            timer_en<=csr_info.tcfg[1];
    end
    always @(posedge clk)
    begin
        if(tcfg_wen)
            csr_info.tval<={csr_rw_info.rw_data[31:2],2'b00};
        else if (timer_en)
        begin
            if(csr_info.tval!=32'b0)
                csr_info.tval<=csr_info.tval-32'b1;
            else if(csr_info.tval==32'b0)
                csr_info.tval<=csr_info.tcfg[1]?{csr_info.tcfg[31:2],2'b00}:32'hffffffff;
        end 
    end
    wire timer_interrupt;
    always @(posedge clk)
    begin
        if(rst)
            timer_interrupt<=1'b0;
        else if(ticlr_wen&&csr_rw_info.rw_data[0]==1'b1)
            timer_interrupt<=1'b0;
        else if(timer_en&&csr_info.tval==32'b0)
            timer_interrupt<=1'b1;
    end
    //2.2 crmd
    wire crmd_wen;
    assign crmd_wen=csr_rw_info.rw_en&&(csr_rw_info.rw_addr==`CSR_CRMD);
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_info.crmd[8:0]  <=9'b000001000;
            csr_info.crmd[31:9] <=23'b0;
        end
        else if(is_except)
        begin
            csr_info.crmd[2:0]  <=3'b0;
        end
        else if(is_ertn)
        begin
            csr_info.crmd[2:0]  <=csr_info.prmd[2:0];
        end
        else if(crmd_wen)
        begin
            csr_info.crmd[8:0]  <=csr_rw_info.rw_data[8:0];
        end
        else 
        begin
            csr_info.crmd<=csr_info.crmd;
        end
    end
    //2.3 prmd
    wire prmd_wen;
    assign prmd_wen=csr_rw_info.rw_en&&(csr_rw_info.rw_addr==`CSR_PRMD);
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_info.prmd[31:3]<=29'b0;
        end
        else if(is_except)
        begin
            csr_info.prmd[2:0]<=csr_info.crmd[2:0];
        end
        else if(prmd_wen)
        begin
            csr_info.prmd[2:0]<=csr_rw_info.rw_data[2:0];
        end
        else
        begin
            csr_info.prmd<=csr_info.prmd;
        end
    end
    //2.4 estat
    wire estat_wen;
    assign estat_wen=csr_rw_info.rw_en&&(csr_rw_info.rw_addr==`CSR_ESTAT);
    always @(posedge clk)
    begin
        if(rst)
        begin
            csr_info.estat[1:0]<=2'b0;
            csr_info.estat[15:13]<=3'b0;
            csr_info.estat[31]<=1'b0;
        end
        else 
        begin
            csr_info.estat[12:2]<={ipi,timer_interrupt,hwi};
            if(is_except)
            begin
                csr_info.estat[21:16]<=mem_except_info.except_type[5:0];
                csr_info.estat[30:22]<=mem_except_info.except_type[16:8];
            end
            else if(is_ertn)
            begin
                csr_info.estat[1:0]<=csr_rw_info.rw_data[1:0];
            end
        end
    end
    //2.5 era
    wire era_wen;
    assign era_wen=csr_rw_info.rw_en&&(csr_rw_info.rw_addr==`CSR_ERA);
    always @(posedge)
    begin
        if(is_except)
            csr_info.era<=except_info.except_pc;
        else if(era_wen)
            csr_info.era<=csr_rw_info.rw_data;
    end
    //2.6 others
    always @(posedge clk)
    begin
        if(rst)
        begin

            csr_info.euen[0]       <=1'b0;
            csr_info.euen[31:1]    <=31'b0;

            csr_info.ecfg[12:0] <=13'b0;
            csr_info.ecfg[31:13] <=19'b0;

            csr_info.eentry[5:0]<=6'b0;

            csr_info.cpuid<=32'b0;

            csr_info.tcfg[0]    <=1'b0;
            csr_info.llbctl[2]  <=1'b0;

            csr_info.tlbehi[12:0]<=13'b0;

            csr_info.tlbelo0[7]<=1'b0;

            csr_info.tlbelo1[7]<=1'b0;

            csr_info.asid[15:10]<=6'b0;
            csr_info.asid[31:24]<=8'b0;

            csr_info.pgdl[11:0]<=12'b0;

            csr_info.pgdh[11:0]<=12'b0;

            csr_info.pgd[11:0]<=12'b0;
            
            csr_info.tlbrentry[5:0]<=6'b0;

            csr_info.dmw0[0]    <=1'b0;
            csr_info.dmw0[2:1]  <=2'b0;
            csr_info.dmw0[3]    <=1'b0;
            csr_info.dmw0[24:6] <=19'b0;
            csr_info.dmw0[28]   <=1'b0;

            csr_info.dmw1[0]    <=1'b0;
            csr_info.dmw1[2:1]  <=2'b0;
            csr_info.dmw1[3]    <=1'b0;
            csr_info.dmw1[24:6] <=19'b0;
            csr_info.dmw1[28]   <=1'b0;

            csr_info.tid<=32'b0;

            csr_info.tcfg[0]<=1'b0;
            
            csr_info.ticlr[31:0]<=32'b0;
        end
        else if(csr_rw_info.rw_en)
        begin
            case(csr_rw_info.rw_addr)  
            `CSR_EUEN:
            begin
                csr_info.euen[0]<=csr_rw_info.rw_data[0];
            end      
            `CSR_ECFG:
            begin
                csr_info.ecfg[12:0]<=csr_rw_info.rw_data[12:0];
            end           
            `CSR_BADV:
            begin
                csr_info.badv[31:0]<=csr_rw_info.rw_data[31:0];
            end      
            `CSR_EENTRY:
            begin
                csr_info.eentry[31:6]<=csr_rw_info.rw_data[31:6];
            end   
            `CSR_TLBIDX:
            begin
                csr_info.tlbidx[`n-1:0]<=csr_rw_info.rw_data[`n-1:0];
                csr_info.tlbidx[29:24]<=csr_rw_info.rw_data[29:24];
                csr_info.tlbidx[31]<=csr_rw_info.rw_data[31];
            end    
            `CSR_TLBEHI:
            begin
                csr_info.tlbehi[31:13]<=csr_rw_info.rw_data[31:13];
            end  
            `CSR_TLBELO0:
            begin
                csr_info.tlbelo0[6:0]<=csr_rw_info.rw_data[6:0];
                csr_info.tlbelo0[31:8]<=csr_rw_info.rw_data[31:8];
            end   
            `CSR_TLBELO1:
            begin
                csr_info.tlbelo1[6:0]<=csr_rw_info.rw_data[6:0];
                csr_info.tlbelo1[31:8]<=csr_rw_info.rw_data[31:8];
            end   
            `CSR_ASID:
            begin
                csr_info.asid[9:0]<=csr_rw_info.rw_data[9:0];
            end     
            `CSR_PGDL:
            begin
                csr_info.pgdl[31:12]<=csr_rw_info.rw_data[31:12];
            end      
            `CSR_PGDH:
            begin
                csr_info.pgdh[31:12]<=csr_rw_info.rw_data[31:12];
            end      
            `CSR_PGD:
            begin
                csr_info.pgd[31:12]<=csr_rw_info.rw_data[31:12];
            end    
            `CSR_CPUID:
            begin
                //cann't write
            end    
            `CSR_SAVE0:
            begin
                csr_info.save0[31:0]<=csr_rw_info.rw_data[31:0];
            end   
            `CSR_SAVE1:
            begin
                csr_info.save1[31:0]<=csr_rw_info.rw_data[31:0];
            end  
            `CSR_SAVE2:
            begin
                csr_info.save2[31:0]<=csr_rw_info.rw_data[31:0];
            end    
            `CSR_SAVE3:
            begin
                csr_info.save3[31:0]<=csr_rw_info.rw_data[31:0];
            end    
            `CSR_TID:
            begin
                csr_info.tid[31:0]<=csr_rw_info.rw_data[31:0];
            end      
            `CSR_TCFG:
            begin
                csr_info.tcfg[31:0]<=csr_rw_info.rw_data[31:0];
            end      
            `CSR_TICLR:
            begin
                csr_info.ticlr[31:0]<=32'b0;
            end     
            `CSR_LLBCTL:
            begin
                csr_info.llbctl[1]<=(csr_rw_info.rw_data[1]<=<=1)?1'b1:csr_info.llbctl[1];
            end    
            `CSR_TLBRENTRY:
            begin
                csr_info.tlbrentry[31:6]<=csr_rw_info.rw_data[31:6];
            end 
            `CSR_CTAG:
            begin
                //cann't find it!
            end    
            `CSR_DMW0:
            begin
                csr_info.dmw0[0]<=csr_rw_info.rw_data[0];
                csr_info.dmw0[5:3]<=csr_rw_info.rw_data[5:3];
                csr_info.dmw0[27:25]<=csr_rw_info.rw_data[27:25];
                csr_info.dmw0[31:29]<=csr_rw_info.rw_data[31:29];
            end      
            `CSR_DMW1:
            begin
                csr_info.dmw1[0]<=csr_rw_info.rw_data[0];
                csr_info.dmw1[5:3]<=csr_rw_info.rw_data[5:3];
                csr_info.dmw1[27:25]<=csr_rw_info.rw_data[27:25];
                csr_info.dmw1[31:29]<=csr_rw_info.rw_data[31:29];
            end
            default:
            begin
            end      
            endcase
        end
    end
endmodule