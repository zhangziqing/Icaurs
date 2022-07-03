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
    
    //TODO:
//     assign mem_info.rw_data = 0;

//     always_comb dpi_pmem_write(32'hdec0de11,32'h1c000000,1,4'b0001);
    
    always_comb begin

        case (ex_info.lsu_op)
            4'b0100:begin  //ST.B
                case(ex_info.ex_result[1:0])
                    2'b00:dpi_pmem_write(ex_info.lsu_data,ex_info.ex_result,1,4'b0001);
                    2'b01:dpi_pmem_write(ex_info.lsu_data<<8,ex_info.ex_result,1,4'b0010);
                    2'b10:dpi_pmem_write(ex_info.lsu_data<<16,ex_info.ex_result,1,4'b0100);
                    2'b11:dpi_pmem_write(ex_info.lsu_data<<24,ex_info.ex_result,1,4'b1000);
                endcase
            end
            default: 
            4'b0101:begin  //ST.H
                case(ex_info.ex_result[1:0])
                    2'b00:dpi_pmem_write(ex_info.lsu_data,ex_info.ex_result,1,4'b0011);
                    2'b10:dpi_pmem_write(ex_info.lsu_data<<16,ex_info.ex_result,1,4'b1100);
                    default:dpi_pmem_write(32'h00000000,ex_info.ex_result,0,4'b0000);
                endcase
            end
            4'b0110:begin  //ST.W
                case(ex_info.ex_result[1:0])
                    2'b00:dpi_pmem_write(ex_info.lsu_data,ex_info.ex_result,1,4'b1111);
                    default:dpi_pmem_write(32'h00000000,ex_info.ex_result,0,4'b0000);
                endcase
            end
            4'b0010:begin  //LD.W
                dpi_pmem_read(mem_info.rw_data,ex_info.ex_result,1);
            end
            4'b0000:begin //LD.B
                dpi_pmem_read(mem_info.rw_data,ex_info.ex_result,1);
                mem_info.rw_data={{24{mem_info.rw_data[31]}},mem_info.rw_data[31:24]};
            end
            4'b0001:begin//LD.H
                dpi_pmem_read(mem_info.rw_data,ex_info.ex_result,1);
                mem_info.rw_data={{16{mem_info.rw_data[31]}},mem_info.rw_data[31:16]};
            end
            4'b1000:begin//LD.BU
                dpi_pmem_read(mem_info.rw_data,ex_info.ex_result,1);
                mem_info.rw_data={{24{1'b0}},mem_info.rw_data[31:24]};

            end
            4'b1001:begin//LD.HU
                dpi_pmem_read(mem_info.rw_data,ex_info.ex_result,1);
                mem_info.rw_data={{16{1'b0}},mem_info.rw_data[31:16]};

            end
            
        endcase
    end


endmodule:MemoryAccess
