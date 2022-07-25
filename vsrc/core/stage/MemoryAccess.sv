`include "vsrc/include/width_param.sv"

module MemoryAccess(
    // sram_if.m sram_io,
    mem_stage_if.o mem_info,
    ex_stage_if.i ex_info
);


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
