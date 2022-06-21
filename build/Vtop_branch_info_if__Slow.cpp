// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop_branch_info_if.h"
#include "Vtop__Syms.h"

#include "verilated_dpi.h"

//==========

Vtop_branch_info_if::Vtop_branch_info_if(const char* _vcname__)
    : VerilatedModule(_vcname__)
 {
    // Reset internal values
    // Reset structure values
    _ctor_var_reset(this);
}

void Vtop_branch_info_if::__Vconfigure(Vtop__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
}

Vtop_branch_info_if::~Vtop_branch_info_if() {
}

void Vtop_branch_info_if::_ctor_var_reset(Vtop_branch_info_if* self) {
    VL_DEBUG_IF(VL_DBG_MSGF("+          Vtop_branch_info_if::_ctor_var_reset\n"); );
    // Body
    if (false && self) {}  // Prevent unused
    self->__PVT__branch_addr = VL_RAND_RESET_I(32);
    self->__PVT__jump_addr = VL_RAND_RESET_I(32);
    self->__PVT__branch_en = VL_RAND_RESET_I(1);
    self->__PVT__jump_en = VL_RAND_RESET_I(1);
}
