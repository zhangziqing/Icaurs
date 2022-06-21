// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Prototypes for DPI import and export functions.
//
// Verilator includes this file in all generated .cpp files that use DPI functions.
// Manually include this file where DPI .c import functions are declared to ensure
// the C functions match the expectations of the DPI imports.

#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif


    // DPI IMPORTS
    // DPI import at vsrc/core/Core.sv:2:30
    extern void dpi_pmem_read(long long* data, long long addr, svBit en, const svBitVecVal* rd_size);
    // DPI import at vsrc/core/Core.sv:3:30
    extern void dpi_pmem_write(long long data, long long addr, svBit en, const svBitVecVal* wr_size);

#ifdef __cplusplus
}
#endif
