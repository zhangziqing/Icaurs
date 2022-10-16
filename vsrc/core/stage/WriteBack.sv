`include "width_param.sv"

module WriteBack (
    mem_stage_if.i mem_info,
    input  logic [`DATA_WIDTH - 1 : 0] ram_rd_data,   
    output logic rw_en,
    output logic [`REG_WIDTH - 1 : 0 ] rw_addr,
    output logic [`DATA_WIDTH - 1 : 0 ] rw_data,
    output                               csr_wen,
    output   [`CSRNUM_WIDTH - 1 : 0 ]    csr_waddr,
    output   [`DATA_WIDTH - 1   : 0 ]    csr_wdata,
    output   [`ADDR_WIDTH - 1   : 0 ]    epc,
    output   [`DATA_WIDTH - 1   : 0 ]    etype,


    lsu_info_if.i       lsu_info,
    output [`DATA_WIDTH - 1 : 0] debug0_wb_rf_wdata,
    output [`ADDR_WIDTH - 1 : 0] debug0_wb_pc,
    output [`REG_WIDTH - 1  : 0] debug0_wb_rf_wnum,
    output                       debug0_wb_rf_wen,

    //to csr
    output          is_except,
    output          is_ertn,
    output [5:0]    Ecode,
    output [8:0]    EsubCode,
    output          is_va_error,
    output [31:0]   va_error_in,
    output          etype_tlb,
    output [18:0]   etype_tlb_vppn,
    output          is_tlbsrch,
    output          tlbsrch_found,
    output [4:0]    tlbsrch_index
);
    //to csr
    // wire etype;
    assign etype        = mem_info.except_type;
    assign is_except    = (etype!=16'b0);
    assign is_ertn      = mem_info.is_ertn;
    assign epc          = mem_info.except_pc;
    assign is_tlbsrch   = mem_info.is_tlb[4];

    //TODO
    logic [31:0] va_error;
    always @(*)
    begin
        if(etype[0]==1'b1)
        begin
            Ecode           =`ecode_int;
            EsubCode        =9'b0;
            is_va_error     =1'b0;
            va_error_in     =32'b0;
            etype_tlb       =1'b0;
            etype_tlb_vppn  =19'b0;
        end
        else if(etype[1]==1'b1)
        begin
            Ecode           =`ecode_adef;
            EsubCode        =9'b0;
            is_va_error     =1'b1;
            va_error_in     =mem_info.pc;
            etype_tlb       =1'b0;
            etype_tlb_vppn  =19'b0;
        end
        else if(etype[2]==1'b1)
        begin
            Ecode           =`ecode_tlbr;
            EsubCode        =9'b0;
            is_va_error     =1'b1;
            va_error_in     =mem_info.pc;
            etype_tlb       =1'b1;
            etype_tlb_vppn  =mem_info.pc[31:13];
        end
        else if(etype[3]==1'b1)
        begin
            Ecode           =`ecode_pif;
            EsubCode        =9'b0;
            is_va_error     =1'b1;
            va_error_in     =mem_info.pc;
            etype_tlb       =1'b1;
            etype_tlb_vppn  =mem_info.pc[31:13];
        end
        else if(etype[4]==1'b1)
        begin
            Ecode           =`ecode_ppi;
            EsubCode        =9'b0;
            is_va_error     =1'b1;
            va_error_in     =mem_info.pc;
            etype_tlb       =1'b1;
            etype_tlb_vppn  =mem_info.pc[31:13];
        end
        else if(etype[5]==1'b1)
        begin
            Ecode           =`ecode_sys;
            EsubCode        =9'b0;
            is_va_error     =1'b0;
            va_error_in     =32'b0;
            etype_tlb       =1'b0;
            etype_tlb_vppn  =19'b0;
        end
        else if(etype[6]==1'b1)
        begin
            Ecode           =`ecode_brk;
            EsubCode        =9'b0;
            is_va_error     =1'b0;
            va_error_in     =32'b0;
            etype_tlb       =1'b0;
            etype_tlb_vppn  =19'b0;
        end
        else if(etype[7]==1'b1)
        begin
            Ecode           =`ecode_ine;
            EsubCode        =9'b0;
            is_va_error     =1'b0;
            va_error_in     =32'b0;
            etype_tlb       =1'b0;
            etype_tlb_vppn  =19'b0;
        end
        else if(etype[8]==1'b1)
        begin
            Ecode           =`ecode_ipe;
            EsubCode        =9'b0;
            is_va_error     =1'b0;
            va_error_in     =32'b0;
            etype_tlb       =1'b0;
            etype_tlb_vppn  =19'b0;
        end
        else if(etype[9]==1'b1)
        begin
            Ecode           =`ecode_ale;
            EsubCode        =9'b0;
            is_va_error     =1'b1;
            va_error_in     =va_error;
            etype_tlb       =1'b0;
            etype_tlb_vppn  =19'b0;
        end
        else if(etype[10]==1'b1)
        begin
            Ecode           =`ecode_adem;
            EsubCode        =9'b1;
            is_va_error     =1'b1;
            va_error_in     =va_error;
            etype_tlb       =1'b0;
            etype_tlb_vppn  =19'b0;
        end
        else if(etype[11]==1'b1)
        begin
            Ecode           =`ecode_tlbr;
            EsubCode        =9'b0;
            is_va_error     =1'b1;
            va_error_in     =va_error;
            etype_tlb       =1'b1;
            etype_tlb_vppn  =va_error[31:13];
        end
        else if(etype[12]==1'b1)
        begin
            Ecode           =`ecode_pme;
            EsubCode        =9'b0;
            is_va_error     =1'b1;
            va_error_in     =va_error;
            etype_tlb       =1'b1;
            etype_tlb_vppn  =va_error[31:13];
        end
        else if(etype[13]==1'b1)
        begin
            Ecode           =`ecode_ppi;
            EsubCode        =9'b0;
            is_va_error     =1'b1;
            va_error_in     =va_error;
            etype_tlb       =1'b1;
            etype_tlb_vppn  =va_error[31:13];
        end
        else if(etype[14]==1'b1)
        begin
            Ecode           =`ecode_pis;
            EsubCode        =9'b0;
            is_va_error     =1'b1;
            va_error_in     =va_error;
        end
        else if(etype[15]==1'b1)
        begin
            Ecode           =`ecode_pil;
            EsubCode        =9'b0;
            is_va_error     =1'b1;
            va_error_in     =va_error;
            etype_tlb       =1'b1;
            etype_tlb_vppn  =va_error[31:13];
        end
        else
        begin
            Ecode           =6'b0;
            EsubCode        =9'b0;
            is_va_error     =1'b0;
            va_error_in     =32'b0;
            etype_tlb       =1'b0;
            etype_tlb_vppn  =19'b0;
        end
    end


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
