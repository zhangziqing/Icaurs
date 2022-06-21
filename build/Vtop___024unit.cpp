// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop___024unit.h"
#include "Vtop__Syms.h"

#include "verilated_dpi.h"

//==========

VL_INLINE_OPT void Vtop___024unit::__Vdpiimwrap_dpi_pmem_read_TOP____024unit(QData/*63:0*/ (&data), QData/*63:0*/ addr, CData/*0:0*/ en, CData/*3:0*/ rd_size) {
    VL_DEBUG_IF(VL_DBG_MSGF("+        Vtop___024unit::__Vdpiimwrap_dpi_pmem_read_TOP____024unit\n"); );
    // Body
    long long data__Vcvt;
    long long addr__Vcvt;
    for (size_t addr__Vidx = 0; addr__Vidx < 1; ++addr__Vidx) addr__Vcvt = addr;
    svBit en__Vcvt;
    for (size_t en__Vidx = 0; en__Vidx < 1; ++en__Vidx) en__Vcvt = en;
    svBitVecVal rd_size__Vcvt[1];
    for (size_t rd_size__Vidx = 0; rd_size__Vidx < 1; ++rd_size__Vidx) VL_SET_SVBV_I(4, rd_size__Vcvt + 1 * rd_size__Vidx, rd_size);
    dpi_pmem_read(&data__Vcvt, addr__Vcvt, en__Vcvt, rd_size__Vcvt);
    data = data__Vcvt;
}

VL_INLINE_OPT void Vtop___024unit::__Vdpiimwrap_dpi_pmem_write_TOP____024unit(QData/*63:0*/ data, QData/*63:0*/ addr, CData/*0:0*/ en, CData/*3:0*/ wr_size) {
    VL_DEBUG_IF(VL_DBG_MSGF("+        Vtop___024unit::__Vdpiimwrap_dpi_pmem_write_TOP____024unit\n"); );
    // Body
    long long data__Vcvt;
    for (size_t data__Vidx = 0; data__Vidx < 1; ++data__Vidx) data__Vcvt = data;
    long long addr__Vcvt;
    for (size_t addr__Vidx = 0; addr__Vidx < 1; ++addr__Vidx) addr__Vcvt = addr;
    svBit en__Vcvt;
    for (size_t en__Vidx = 0; en__Vidx < 1; ++en__Vidx) en__Vcvt = en;
    svBitVecVal wr_size__Vcvt[1];
    for (size_t wr_size__Vidx = 0; wr_size__Vidx < 1; ++wr_size__Vidx) VL_SET_SVBV_I(4, wr_size__Vcvt + 1 * wr_size__Vidx, wr_size);
    dpi_pmem_write(data__Vcvt, addr__Vcvt, en__Vcvt, wr_size__Vcvt);
}
