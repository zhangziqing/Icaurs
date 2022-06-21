// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtop__Syms.h"


//======================

void Vtop::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vtop::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vtop::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vtop::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vtop::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBit(c+1,"clock", false,-1);
        tracep->declBit(c+2,"reset", false,-1);
        tracep->declBit(c+1,"Core clock", false,-1);
        tracep->declBit(c+2,"Core reset", false,-1);
        tracep->declBus(c+3,"Core pc", false,-1, 31,0);
        tracep->declBit(c+1,"Core ifu_0 clk", false,-1);
        tracep->declBit(c+2,"Core ifu_0 rst", false,-1);
        tracep->declBus(c+3,"Core ifu_0 pc", false,-1, 31,0);
        tracep->declBus(c+3,"Core ifu_0 r_pc", false,-1, 31,0);
        vlTOPp->traceInitSub1(userp, tracep, VLT_TRACE_SCOPE_INTERFACE, "Core br_info_if_0");
        vlTOPp->traceInitSub1(userp, tracep, VLT_TRACE_SCOPE_INTERFACE, "Core ifu_0 branch_info");
    }
}

void Vtop::traceInitSub1(void* userp, VerilatedVcd* tracep, int scopet, const char* scopep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBus(c+4,Verilated::catName(scopep,"branch_addr",(int)scopet," "), false,-1, 31,0);
        tracep->declBus(c+5,Verilated::catName(scopep,"jump_addr",(int)scopet," "), false,-1, 31,0);
        tracep->declBit(c+6,Verilated::catName(scopep,"branch_en",(int)scopet," "), false,-1);
        tracep->declBit(c+7,Verilated::catName(scopep,"jump_en",(int)scopet," "), false,-1);
    }
}

void Vtop::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vtop::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vtop::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullBit(oldp+1,(vlTOPp->clock));
        tracep->fullBit(oldp+2,(vlTOPp->reset));
        tracep->fullIData(oldp+3,(vlTOPp->Core__DOT__ifu_0__DOT__r_pc),32);
        tracep->fullIData(oldp+4,(vlSymsp->TOP__Core__DOT__br_info_if_0.__PVT__branch_addr),32);
        tracep->fullIData(oldp+5,(vlSymsp->TOP__Core__DOT__br_info_if_0.__PVT__jump_addr),32);
        tracep->fullBit(oldp+6,(vlSymsp->TOP__Core__DOT__br_info_if_0.__PVT__branch_en));
        tracep->fullBit(oldp+7,(vlSymsp->TOP__Core__DOT__br_info_if_0.__PVT__jump_en));
    }
}
