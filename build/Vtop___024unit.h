// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtop.h for the primary calling header

#ifndef VERILATED_VTOP___024UNIT_H_
#define VERILATED_VTOP___024UNIT_H_  // guard

#include "verilated_heavy.h"
#include "Vtop__Dpi.h"

//==========

class Vtop__Syms;
class Vtop_VerilatedVcd;


//----------

VL_MODULE(Vtop___024unit) {
  public:

    // INTERNAL VARIABLES
  private:
    Vtop__Syms* __VlSymsp;  // Symbol table
  public:

    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vtop___024unit);  ///< Copying not allowed
  public:
    Vtop___024unit(const char* name = "TOP");
    ~Vtop___024unit();

    // INTERNAL METHODS
    void __Vconfigure(Vtop__Syms* symsp, bool first);
    void __Vdpiimwrap_dpi_pmem_read_TOP____024unit(QData/*63:0*/ (&data), QData/*63:0*/ addr, CData/*0:0*/ en, CData/*3:0*/ rd_size);
    void __Vdpiimwrap_dpi_pmem_write_TOP____024unit(QData/*63:0*/ data, QData/*63:0*/ addr, CData/*0:0*/ en, CData/*3:0*/ wr_size);
  private:
    static void _ctor_var_reset(Vtop___024unit* self) VL_ATTR_COLD;
    static void traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
