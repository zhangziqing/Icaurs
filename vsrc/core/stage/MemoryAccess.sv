`include "width_param.sv"
`include "constant.sv"
`include "csr_reg.sv"

module MemoryAccess(
    input     stall,
    sram_if.m sram_io,
    mem_stage_if.o mem_info,
    ex_stage_if.i ex_info,
    lsu_info_if.o lsu_info
);
    //except
    //TODO
    wire [15:0] except_type;
    logic except_type_pil,except_type_pis,except_type_ppi,except_type_pme,except_type_tlbr,except_type_adem;
    assign except_type={except_type_pil,except_type_pis,except_type_ppi,except_type_pme,except_type_tlbr,except_type_adem,ex_info.except_type};
    assign mem_info.except_type=except_type;

    assign mem_info.is_cacop     = ex_info.is_cacop;
    assign mem_info.cacop_code   = ex_info.cacop_code;
    assign mem_info.is_tlb       = ex_info.is_tlb;
    assign mem_info.invtlb_op    = ex_info.invtlb_op;
    assign mem_info.is_ertn      = ex_info.is_ertn;
    assign mem_info.is_idle      = ex_info.is_idle;
    //csr
    assign mem_info.csr_wen     = ex_info.csr_wen;
    assign mem_info.csr_waddr   = ex_info.csr_waddr;
    assign mem_info.csr_wdata   = ex_info.csr_wdata;

    assign mem_info.pc = ex_info.pc;
    assign mem_info.inst = ex_info.inst;
    assign mem_info.rw_en = ex_info.rw_en;
    assign mem_info.rw_addr = ex_info.rw_addr;

    logic [`DATA_WIDTH - 1 : 0 ] mem_read_result_aligned;
    logic [`DATA_WIDTH - 1 : 0 ] mem_read_result;
    logic mem_read_en;
    logic [`ADDR_WIDTH - 1 : 0 ] mem_addr;
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
