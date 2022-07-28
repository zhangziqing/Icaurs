`include "vsrc/include/width_param.sv"
`include "vsrc/include/csr_reg.sv"
`include "vsrc/IO/csr_reg.sv"

module CSR(
    input clk,
    input rst,
    input GRLEN,
    input   [`CSR_REG_WIDTH-1:0] r_addr,
    output  [`DATA_WIDTH-1:0]    r_data,
    csrData_pushForwward.i csr_rw_info,
    csr_reg.o csr_info
);
    reg [`DATA_WIDTH-1:0] csr_reg [`CSR_REG_MAX_ADDR:`CSR_REG_MIN_ADDR];

    //1.read csr reg data
    always @(*)
    begin
        if(rst)
        begin
            r_data=32'h0;
        end
        else
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
    end

    //2.write csr reg data
    always @(posedge clk)
    begin
        if(rst)
        begin

        end
        else if(csr_rw_info.rw_en)
        begin
            case(csr_rw_info.rw_addr)
            `CSR_CRMD:
            begin
                csr_info.crmd[8:0]=csr_rw_info.rw_data[8:0];
            end      
            `CSR_PRMD:
            begin
                csr_info.prmd[2:0]=csr_rw_info.rw_data[2:0];
            end      
            `CSR_EUEN:
            begin
                csr_info.euen[0]=csr_rw_info.rw_data[0];
            end      
            `CSR_ECFG:
            begin
                csr_info.ecfg[12:0]=csr_rw_info.rw_data[12:0];
            end      
            `CSR_ESTAT:
            begin
                csr_info.estat[1:0]=csr_rw_info.rw_data[1:0];
            end    
            `CSR_ERA:
            begin
                csr_info.era[GRLEN-1:0]=csr_rw_info.rw_data[GRLEN-1:0];
            end       
            `CSR_BADV:
            begin
                csr_info.badv[GRLEN-1:0]=csr_rw_info.rw_data[GRLEN-1:0];
            end      
            `CSR_EENTRY:
            begin
                csr_info.eentry[31:6]=csr_rw_info.rw_data[31:6];
            end   
            `CSR_TLBIDX:
            begin
                csr_info.tlbidx[n-1:0]=csr_rw_info.rw_data[n-1:0];
                csr_info.tlbidx[29:24]=csr_rw_info.rw_data[29:24];
                csr_info.tlbidx[31]=csr_rw_info.rw_data[31];
            end    
            `CSR_TLBEHI:
            begin
                csr_info.tlbehi[31:13]=csr_rw_info.rw_data[31:13];
            end  
            `CSR_TLBELO0:
            begin
                csr_info.tlbelo0[6:0]=csr_rw_info.rw_data[6:0];
                csr_info.tlbelo0[31:8]=csr_rw_info.rw_data[31:8];
            end   
            `CSR_TLBELO1:
            begin
                csr_info.tlbelo1[6:0]=csr_rw_info.rw_data[6:0];
                csr_info.tlbelo1[31:8]=csr_rw_info.rw_data[31:8];
            end   
            `CSR_ASID:
            begin
                csr_info.asid[9:0]=csr_rw_info.rw_data[9:0];
            end     
            `CSR_PGDL:
            begin
                csr_info.pgdl[GRLEN-1:12]=csr_rw_info.rw_data[GRLEN-1:12];
            end      
            `CSR_PGDH:
            begin
                csr_info.pgdh[GRLEN-1:12]=csr_rw_info.rw_data[GRLEN-1:12];
            end      
            `CSR_PGD:
            begin
                csr_info.pgd[GRLEN-1:12]=csr_rw_info.rw_data[GRLEN-1:12];
            end    
            `CSR_CPUID:
            begin
                //cann't write
            end    
            `CSR_SAVE0:
            begin
                csr_info.save0[GRLEN-1:0]=csr_rw_info.rw_data[GRLEN-1:0];
            end   
            `CSR_SAVE1:
            begin
                csr_info.save1[GRLEN-1:0]=csr_rw_info.rw_data[GRLEN-1:0];
            end  
            `CSR_SAVE2:
            begin
                csr_info.save2[GRLEN-1:0]=csr_rw_info.rw_data[GRLEN-1:0];
            end    
            `CSR_SAVE3:
            begin
                csr_info.save3[GRLEN-1:0]=csr_rw_info.rw_data[GRLEN-1:0];
            end    
            `CSR_TID:
            begin
                csr_info.tid[31:0]=csr_rw_info.rw_data[31:0];
            end      
            `CSR_TCFG:
            begin
                csr_info.tcfg[n-1:0]=csr_rw_info.rw_data[n-1:0];
            end      
            `CSR_TVAL:
            begin
                //cann't write
            end     
            `CSR_TICLR:
            begin
                csr_info.ticlr[0]=(csr_rw_info.rw_data[0]==1)?1'b1:csr_info.ticlr[0];
            end     
            `CSR_LLBCTL:
            begin
                csr_info.llbctl[1]=(csr_rw_info.rw_data[1]==1)?1'b1:csr_info.llbctl[1];
            end    
            `CSR_TLBRENTRY:
            begin
                csr_info.tlbrentry[31:6]=csr_rw_info.rw_data[31:6];
            end 
            `CSR_CTAG:
            begin
                //cann't find it!
            end    
            `CSR_DMW0:
            begin
                csr_info.dmw0[0]=csr_rw_info.rw_data[0];
                csr_info.dmw0[5:3]=csr_rw_info.rw_data[5:3];
                csr_info.dmw0[27:25]=csr_rw_info.rw_data[27:25];
                csr_info.dmw0[31:29]=csr_rw_info.rw_data[31:29];
            end      
            `CSR_DMW1:
            begin
                csr_info.dmw1[0]=csr_rw_info.rw_data[0];
                csr_info.dmw1[5:3]=csr_rw_info.rw_data[5:3];
                csr_info.dmw1[27:25]=csr_rw_info.rw_data[27:25];
                csr_info.dmw1[31:29]=csr_rw_info.rw_data[31:29];
            end      
            endcase
        end
    end
endmodule