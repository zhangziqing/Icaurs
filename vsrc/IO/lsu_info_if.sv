interface lsu_info_if;
    logic [7 : 0] ld_valid;
    logic [31: 0] ld_paddr;
    logic [7 : 0] st_valid;
    logic [31: 0] st_paddr;
    logic [31: 0] st_data;

    modport i(
        input ld_paddr,
        input ld_valid,
        input st_valid,
        input st_paddr,
        input st_data
    );
    modport o(
        output ld_paddr,
        output ld_valid,
        output st_valid,
        output st_paddr,
        output st_data
    );

endinterface