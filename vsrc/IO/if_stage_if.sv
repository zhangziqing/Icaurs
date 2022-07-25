`include "vsrc/include/width_param.sv"

interface if_stage_if;
    
    logic [`ADDR_WIDTH - 1 : 0 ] pc;
    logic [`ADDR_WIDTH - 1 : 0 ] branch_addr;
    logic branch;

    modport o(
       output pc,
       output branch_addr,
       output branch 
    );
    
    modport i(
       input pc,
       input branch_addr,
       input branch 
    );
    
endinterface
