`include "vsrc/include/width_param.sv"

module MemoryAccess(
    // sram_if.m sram_io,
    mem_stage_if.o mem_info,
    ex_stage_if.i ex_info,

    //csr
    csrData_pushForwward.i mem_csr_info,
    csrData_pushForwward.o wb_csr_info,

    //except
    //1.except info
    except_info.i ex_except_info,
    except_info.o mem_except_info,
    //2.data relate
    csrData_pushForwward.i wb_csr_info_relate,
    //3.csr data
    csr_except_info.i csr_except_info_mem
);
    //except
    //1.except info
    assign mem_except_info.except_pc=ex_except_info.except_pc;
    //2.csr except info data relate
    reg [`DATA_WIDTH-1:0] csr_crmd;
    always @(*)
    begin
        if(rst)
            csr_crmd=`CSR_CRMD_RST;
        else if(wb_csr_info_relate.rw_en==1&&wb_csr_info_relate.rw_addr==`CSR_CRMD)
            csr_crmd=wb_csr_info_relate.rw_data;
        else 
            csr_crmd=csr_except_info_mem.crmd;
    end
    reg [`DATA_WIDTH-1:0] csr_ecfg;
    always @(*)
    begin
        if(rst)
            csr_ecfg=`CSR_ECFG_RST;
        else if(wb_csr_info_relate.rw_en==1&&wb_csr_info_relate.rw_addr==`CSR_ECFG)
            csr_ecfg=wb_csr_info_relate.rw_data;
        else 
            csr_ecfg=csr_except_info_mem.ecfg;
    end
    reg [`DATA_WIDTH-1:0] csr_estat;
    always @(*)
    begin
        if(rst)
            csr_estat=`CSR_ESTAT_RST;
        else if(wb_csr_info_relate.rw_en==1&&wb_csr_info_relate.rw_addr==`CSR_ESTAT)
            csr_estat=wb_csr_info_relate.rw_data;
        else 
            csr_estat=csr_except_info_mem.estat;
    end
    reg [`DATA_WIDTH-1:0] csr_era;
    always @(*)
    begin
        if(rst)
            csr_era=`CSR_ERA_RST;
        else if(wb_csr_info_relate.rw_en==1&&wb_csr_info_relate.rw_addr==`CSR_ERA)
            csr_era=wb_csr_info_relate.rw_data;
        else 
            csr_era=csr_except_info_mem.era;
    end
    //3.except type judge
    always @(*)
    begin
        if(rst)
            mem_except_info.except_type=`excepttype_non;
        else if(csr_crmd[2]==1'b1)
        begin
            if(csr_estat[12:0]&csr_ecfg[12:0])
                mem_except_info.except_type=`excepttype_int;
            else
                mem_except_info.except_type=`excepttype_non;
        end
        else if(csr_crmd[2]==1'b0)
        begin
            if(ex_except_info.except_type[13]==1'b1)
                mem_except_info.except_type=`excepttype_ine;
            else if(ex_except_info.except_type[14]==1'b1)
                mem_except_info.except_type=`excepttype_sys;
            else if(ex_except_info.except_type[15]==1'b1)
                mem_except_info.except_type=`excepttype_brk;
        end
        else
            mem_except_info.except_type=`excepttype_non;
    end

    //csr
    assign wb_csr_info.rw_en=mem_csr_info.rw_en;
    assign wb_csr_info.rw_addr=mem_csr_info.rw_addr;
    assign wb_csr_info.rw_data=mem_csr_info.rw_data;

    assign mem_info.pc = ex_info.pc;
    assign mem_info.inst = ex_info.inst;
    assign mem_info.rw_en = ex_info.rw_en;
    assign mem_info.rw_addr = ex_info.rw_addr;

    logic [`DATA_WIDTH - 1 : 0 ]mem_read_result_aligned;
    logic [`DATA_WIDTH - 1 : 0 ]mem_read_result;
    logic mem_read_en;
    logic [`ADDR_WIDTH - 1 : 0 ]mem_addr;
    assign mem_read_en = ex_info.lsu_op[2] == 0;
    assign mem_addr = {ex_info.ex_result[31:2],2'b0};
    
    //assign mem_info.rw_data = 0;
    always_comb dpi_pmem_read(mem_read_result_aligned,mem_addr,mem_read_en);
    always_comb begin:shift
       case(ex_info.ex_result[1:0])
        2'b00:
            mem_read_result = mem_read_result_aligned;
        2'b01:
            mem_read_result = {8'b0,mem_read_result_aligned[31:8]};
        2'b10:
            mem_read_result = {16'b0,mem_read_result_aligned[31:16]};
        2'b11:
            mem_read_result = {24'b0,mem_read_result_aligned[31:24]};
       endcase
    end:shift
    always_comb begin
        case (ex_info.lsu_op)
            4'b0100:begin  //ST.B
                case(ex_info.ex_result[1:0])
                    2'b00:dpi_pmem_write(ex_info.lsu_data,mem_addr,1,4'b0001);
                    2'b01:dpi_pmem_write(ex_info.lsu_data<<8,mem_addr,1,4'b0010);
                    2'b10:dpi_pmem_write(ex_info.lsu_data<<16,mem_addr,1,4'b0100);
                    2'b11:dpi_pmem_write(ex_info.lsu_data<<24,mem_addr,1,4'b1000);
                endcase
            end
            4'b0101:begin  //ST.H
                case(ex_info.ex_result[1:0])
                    2'b00:dpi_pmem_write(ex_info.lsu_data,mem_addr,1,4'b0011);
                    2'b01:dpi_pmem_write(ex_info.lsu_data,mem_addr,1,4'b0110);
                    2'b10:dpi_pmem_write(ex_info.lsu_data<<16,mem_addr,1,4'b1100);
                    default:dpi_pmem_write(32'h00000000,mem_addr,0,4'b0000);
                endcase
            end
            4'b0110:begin  //ST.W
                case(ex_info.ex_result[1:0])
                    2'b00:dpi_pmem_write(ex_info.lsu_data,mem_addr,1,4'b1111);
                    default:dpi_pmem_write(32'h00000000,mem_addr,0,4'b0000);
                endcase
            end
            4'b0010:begin  //LD.W
                mem_info.rw_data = mem_read_result;
            end
            4'b0000:begin //LD.B
                mem_info.rw_data={{24{mem_info.rw_data[7]}},mem_read_result[7:0]};
            end
            4'b0001:begin//LD.H
                mem_info.rw_data={{16{mem_info.rw_data[15]}},mem_read_result[15:0]};
            end
            4'b1000:begin//LD.BU
                mem_info.rw_data={{24{1'b0}},mem_read_result[7:0]};
            end
            4'b1001:begin//LD.HU
                mem_info.rw_data={{16{1'b0}},mem_read_result[15:0]};
            end
            default:begin
                mem_info.rw_data = ex_info.ex_result;
            end
        endcase
    end


endmodule:MemoryAccess
