`include "width_param.sv"

interface if_stage_if;
    
    logic [`ADDR_WIDTH - 1 : 0 ] pc;
    logic [`ADDR_WIDTH - 1 : 0 ] branch_addr;
    logic                        branch;

    logic [3:0]                  except_type;

    modport o(
       output pc,
       output branch_addr,
       output branch,
       output except_type
    );
    
    modport i(
       input pc,
       input branch_addr,
       input branch ,
       input except_type
    );
    
endinterface
