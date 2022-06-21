// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtop.h for the primary calling header

#ifndef VERILATED_VTOP_BRANCH_INFO_IF_H_
#define VERILATED_VTOP_BRANCH_INFO_IF_H_  // guard

#include "verilated_heavy.h"
#include "Vtop__Dpi.h"

//==========

class Vtop__Syms;
class Vtop_VerilatedVcd;


//----------

VL_MODULE(Vtop_branch_info_if) {
  public:

    // LOCAL SIGNALS
    CData/*0:0*/ __PVT__branch_en;
    CData/*0:0*/ __PVT__jump_en;
    IData/*31:0*/ __PVT__branch_addr;
    IData/*31:0*/ __PVT__jump_addr;

    // INTERNAL VARIABLES
  private:
    Vtop__Syms* __VlSymsp;  // Symbol table
  public:

    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vtop_branch_info_if);  ///< Copying not allowed
  public:
    Vtop_branch_info_if(const char* name = "TOP");
    ~Vtop_branch_info_if();

    // INTERNAL METHODS
    void __Vconfigure(Vtop__Syms* symsp, bool first);
  private:
    static void _ctor_var_reset(Vtop_branch_info_if* self) VL_ATTR_COLD;
    static void traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
