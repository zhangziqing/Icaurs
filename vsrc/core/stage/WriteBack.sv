`include "width_param.sv"

module WriteBack (
    mem_stage_if.i mem_info,
    input  logic [`DATA_WIDTH - 1 : 0] ram_rd_data,   
    output logic rw_en,
    output logic [`REG_WIDTH - 1 : 0 ] rw_addr,
    output logic [`DATA_WIDTH - 1 : 0 ] rw_data,

    lsu_info_if.i       lsu_info,
    output [`DATA_WIDTH - 1 : 0] debug0_wb_rf_wdata,
    output [`ADDR_WIDTH - 1 : 0] debug0_wb_pc,
    output [`REG_WIDTH - 1  : 0] debug0_wb_rf_wnum,
    output                       debug0_wb_rf_wen
);
    logic [`DATA_WIDTH - 1 : 0] mem_read_result;
    logic [`DATA_WIDTH - 1 : 0] mem_to_reg;
    logic [3 : 0] lsu_op = mem_info.inst[25:22];
    always_comb begin:shift
       case(mem_info.rw_data[1:0])
        2'b00:
            mem_read_result = ram_rd_data;
        2'b01:
            mem_read_result = {8'b0,ram_rd_data[31:8]};
        2'b10:
            mem_read_result = {16'b0,ram_rd_data[31:16]};
        2'b11:
            mem_read_result = {24'b0,ram_rd_data[31:24]};
       endcase
    end:shift

    always_comb begin
        case (lsu_op)
            4'b0010:begin  //LD.W
                mem_to_reg = mem_read_result;
            end
            4'b0000:begin //LD.B
                mem_to_reg = {{24{mem_read_result[7]}},mem_read_result[7:0]};
            end
            4'b0001:begin//LD.H
                mem_to_reg ={{16{mem_read_result[15]}},mem_read_result[15:0]};
            end
            4'b1000:begin//LD.BU
                mem_to_reg ={{24{1'b0}},mem_read_result[7:0]};
            end
            4'b1001:begin//LD.HU
                mem_to_reg = {{16{1'b0}},mem_read_result[15:0]};
            end
            default:begin//other
                mem_to_reg =mem_info.rw_data;
            end
        endcase
    end
    assign rw_en = mem_info.rw_en;
    assign rw_addr = mem_info.rw_addr;
    assign rw_data = mem_info.ram_rd_en ? mem_to_reg : mem_info.rw_data;

    assign debug0_wb_rf_wdata = rw_data;
    assign debug0_wb_rf_wen   = rw_en;
    assign debug0_wb_rf_wnum  = rw_addr;
    assign debug0_wb_pc       = mem_info.pc;
endmodule:WriteBack
