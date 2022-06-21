// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VTOP__SYMS_H_
#define VERILATED_VTOP__SYMS_H_  // guard

#include "verilated_heavy.h"

// INCLUDE MODULE CLASSES
#include "Vtop.h"
#include "Vtop___024unit.h"
#include "Vtop_branch_info_if.h"

// DPI TYPES for DPI Export callbacks (Internal use)

// SYMS CLASS
class Vtop__Syms : public VerilatedSyms {
  public:

    // LOCAL STATE
    const char* __Vm_namep;
    bool __Vm_activity;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode;  ///< Used by trace routines when tracing multiple models
    bool __Vm_didInit;

    // SUBCELL STATE
    Vtop*                          TOPp;
    Vtop_branch_info_if            TOP__Core__DOT__br_info_if_0;
    Vtop___024unit                 TOP____024unit;

    // CREATORS
    Vtop__Syms(VerilatedContext* contextp, Vtop* topp, const char* namep);
    ~Vtop__Syms();

    // METHODS
    inline const char* name() { return __Vm_namep; }

} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
