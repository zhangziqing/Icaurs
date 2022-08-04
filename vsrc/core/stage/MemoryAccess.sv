`include "width_param.sv"

module MemoryAccess(
    input     stall,
    sram_if.m sram_io,
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

    lsu_info_if.o lsu_info

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
    

    //TODO:  
//     assign mem_info.rw_data = 0;
    // always_comb dpi_pmem_read(mem_read_result_aligned,mem_addr,mem_read_en);
    assign sram_io.sram_rd_en = mem_read_en & ~stall;
    assign sram_io.sram_rd_addr = mem_addr;
    assign mem_read_result_aligned = sram_io.sram_rd_data;

    logic [`DATA_WIDTH - 1 : 0 ] mem_wr_data;
    logic mem_wr_en;
    logic [`NUM_OF_BYTES - 1 : 0] mem_wr_mask;
    
    assign sram_io.sram_wr_en   = mem_wr_en;
    assign sram_io.sram_wr_addr = mem_addr;
    assign sram_io.sram_wr_data = mem_wr_data;
    assign sram_io.sram_wr_mask = mem_wr_mask;
    always_comb begin
        case (ex_info.lsu_op)
            4'b0100:begin  //ST.B
                case(ex_info.ex_result[1:0])
                    2'b00:begin
                        mem_wr_data = ex_info.lsu_data;
                        mem_wr_en   = 1;
                        mem_wr_mask = 4'b0001;
                    end 
                    // dpi_pmem_write(ex_info.lsu_data,mem_addr,1,4'b0001);
                    2'b01:begin 
                        mem_wr_data = ex_info.lsu_data << 8;
                        mem_wr_en   = 1;
                        mem_wr_mask = 4'b0010;
                    end
                    // dpi_pmem_write(ex_info.lsu_data<<8,mem_addr,1,4'b0010);
                    2'b10:begin
                        mem_wr_data = ex_info.lsu_data << 16;
                        mem_wr_en   = 1;
                        mem_wr_mask = 4'b0100;    
                    end
                    // dpi_pmem_write(ex_info.lsu_data<<16,mem_addr,1,4'b0100);
                    2'b11:begin
                        mem_wr_data = ex_info.lsu_data << 24;
                        mem_wr_en   = 1;
                        mem_wr_mask = 4'b1000;    
                    end
                    // dpi_pmem_write(ex_info.lsu_data<<24,mem_addr,1,4'b1000);
                endcase
            end
            4'b0101:begin  //ST.H
                case(ex_info.ex_result[1:0])
                    2'b00:begin
                        mem_wr_data = ex_info.lsu_data;
                        mem_wr_en   = 1;
                        mem_wr_mask = 4'b0011;    
                    end 
                    // dpi_pmem_write(ex_info.lsu_data,mem_addr,1,4'b0011);
                    2'b01:begin
                        mem_wr_data = ex_info.lsu_data << 8;
                        mem_wr_en   = 1;
                        mem_wr_mask = 4'b0110;    
                    end
                    // dpi_pmem_write(ex_info.lsu_data,mem_addr,1,4'b0110);
                    2'b10:begin 
                        mem_wr_data = ex_info.lsu_data << 16;
                        mem_wr_en   = 1;
                        mem_wr_mask = 4'b1100;
                    end
                    // dpi_pmem_write(ex_info.lsu_data<<16,mem_addr,1,4'b1100);
                    default:begin 
                        mem_wr_data = ex_info.lsu_data;
                        mem_wr_en   = 0;
                        mem_wr_mask = 4'b0000;
                    end
                    // dpi_pmem_write(32'h00000000,mem_addr,0,4'b0000);
                endcase
            end
            4'b0110:begin  //ST.W
                case(ex_info.ex_result[1:0])
                    2'b00:begin 
                        mem_wr_data = ex_info.lsu_data;
                        mem_wr_en   = 1;
                        mem_wr_mask = 4'b1111;
                    end
                    // dpi_pmem_write(ex_info.lsu_data,mem_addr,1,4'b1111);
                    default:begin
                        mem_wr_data = ex_info.lsu_data;
                        mem_wr_en   = 0;
                        mem_wr_mask = 4'b0000;
                    end
                    // dpi_pmem_write(32'h00000000,mem_addr,0,4'b0000);
                endcase
            end
            default:begin
                mem_wr_data = 0;
                mem_wr_en   = 0;    
                mem_wr_mask = 0;
            end
        endcase
    end
    assign mem_info.rw_data = ex_info.ex_result;
    assign mem_info.ram_rd_en = mem_read_en;

    wire ld_w = 4'b0010 == ex_info.lsu_op;
    wire ld_b = 4'b0000 == ex_info.lsu_op;
    wire ld_h = 4'b0001 == ex_info.lsu_op;
    wire ld_bu = 4'b1000 == ex_info.lsu_op;
    wire ld_hu = 4'b1001 == ex_info.lsu_op;
    assign lsu_info.ld_valid =  {2'b0,1'b0, ld_w, ld_hu, ld_h, ld_bu, ld_b};

    wire st_b = 4'b0100 == ex_info.lsu_op;
    wire st_h = 4'b0101 == ex_info.lsu_op;
    wire st_w = 4'b0110 == ex_info.lsu_op;
    assign lsu_info.st_valid = {4'b0, 1'b0, st_w, st_h, st_b};

    assign lsu_info.ld_paddr = ex_info.ex_result;
    assign lsu_info.st_paddr = ex_info.ex_result;
    wire [`DATA_WIDTH - 1: 0]mask;
    genvar i;
    generate
    for (i = 0; i < 4; i = i + 1)begin
        assign mask[i*8+7:i*8] = mem_wr_mask[i] ? 8'b1111_1111 : 0;
    end
    endgenerate
    assign lsu_info.st_data = mem_wr_data & mask;
endmodule:MemoryAccess
