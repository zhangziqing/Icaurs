# Verilated -*- Makefile -*-
# DESCRIPTION: Verilator output: Makefile for building Verilated archive or executable
#
# Execute this makefile from the object directory:
#    make -f Vtop.mk

default: Vtop

### Constants...
# Perl executable (from $PERL)
PERL = perl
# Path to Verilator kit (from $VERILATOR_ROOT)
VERILATOR_ROOT = /usr/share/verilator
# SystemC include directory with systemc.h (from $SYSTEMC_INCLUDE)
SYSTEMC_INCLUDE ?= 
# SystemC library directory with libsystemc.a (from $SYSTEMC_LIBDIR)
SYSTEMC_LIBDIR ?= 

### Switches...
# SystemC output mode?  0/1 (from --sc)
VM_SC = 0
# Legacy or SystemC output mode?  0/1 (from --sc)
VM_SP_OR_SC = $(VM_SC)
# Deprecated
VM_PCLI = 1
# Deprecated: SystemC architecture to find link library path (from $SYSTEMC_ARCH)
VM_SC_TARGET_ARCH = linux

### Vars...
# Design prefix (from --prefix)
VM_PREFIX = Vtop
# Module prefix (from --prefix)
VM_MODPREFIX = Vtop
# User CFLAGS (from -CFLAGS on Verilator command line)
VM_USER_CFLAGS = \
	-I/mnt/g/FileGitRepo/lac/csrc/include \
	-I/usr/lib/llvm-12/include \
	-std=c++14 \
	-fno-exceptions \
	-D_GNU_SOURCE \
	-D__STDC_CONSTANT_MACROS \
	-D__STDC_FORMAT_MACROS \
	-D__STDC_LIMIT_MACROS \

# User LDLIBS (from -LDFLAGS on Verilator command line)
VM_USER_LDLIBS = \
	/mnt/g/FileGitRepo/lac/build/obj/csrc/src/cpu/isa.o \
	/mnt/g/FileGitRepo/lac/build/obj/csrc/src/difftest/difftest.o \
	/mnt/g/FileGitRepo/lac/build/obj/csrc/src/memory/pmem.o \
	/mnt/g/FileGitRepo/lac/build/obj/csrc/src/sdb/breakpoint.o \
	/mnt/g/FileGitRepo/lac/build/obj/csrc/src/sdb/elf_resolve.o \
	/mnt/g/FileGitRepo/lac/build/obj/csrc/src/sdb/expr.o \
	/mnt/g/FileGitRepo/lac/build/obj/csrc/src/sdb/sdb.o \
	/mnt/g/FileGitRepo/lac/build/obj/csrc/src/sdb/watchpoint.o \
	-lLLVM-12 \
	-lreadline \
	-ldl \

# User .cpp files (from .cpp's on Verilator command line)
VM_USER_CLASSES = \
	dpi-c \
	main \
	nvboard_main \
	cpu_exec \
	init \
	disasm \

# User .cpp directories (from .cpp's on Verilator command line)
VM_USER_DIR = \
	csrc \
	csrc/src \
	csrc/src/utils \


### Default rules...
# Include list of all generated classes
include Vtop_classes.mk
# Include global rules
include $(VERILATOR_ROOT)/include/verilated.mk

### Executable rules... (from --exe)
VPATH += $(VM_USER_DIR)

dpi-c.o: csrc/dpi-c.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
main.o: csrc/main.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
nvboard_main.o: csrc/nvboard_main.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
cpu_exec.o: csrc/src/cpu_exec.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
init.o: csrc/src/init.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
disasm.o: csrc/src/utils/disasm.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<

### Link rules... (from --exe)
Vtop: $(VK_USER_OBJS) $(VK_GLOBAL_OBJS) $(VM_PREFIX)__ALL.a $(VM_HIER_LIBS)
	$(LINK) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) $(LIBS) $(SC_LIBS) -o $@


# Verilated -*- Makefile -*-
