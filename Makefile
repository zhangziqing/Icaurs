CC = gcc
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj
CSRC := $(shell find lac_tracer/csrc/src -name "*.c")
CCSRC := $(shell find lac_tracer/csrc/ -name "*.cpp" -or -name "*.cc")
OBJS=$(CSRC:%.c=$(OBJ_DIR)/%.o)
INC_PATH := $(abspath ./lac_tracer/csrc/include/)
COMMON_FLAGS = $(addprefix -I, $(INC_PATH))  -MMD -Wall -g -O2 
CFLAGS += $(COMMON_FLAGS) -Werror
CXXFLAGS +=
LIBS += -lreadline -ldl

ARGS += 
IMG += 
TESTCASE = func/func_lab3 


VERILATOR = verilator
VER_INCLUDE = vsrc \
			vsrc/IO/ \
			vsrc/core/ \
			vsrc/core/stage/ \
			vsrc/core/utils/ \
			vsrc/core/bpu/ \
			vsrc/include/
VER_FLAGS = $(addprefix -I,$(VER_INCLUDE)) --cc --exe --build --trace \
			--top Core --prefix Vtop -Mdir $(BUILD_DIR)

$(OBJ_DIR)/%.o:%.c
	@echo + CC $<
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c -o $@ $<


.PHONY:  clean all run build

all:run

run:build
	$(BUILD_DIR)/Vtop $(ARGS) $(IMG)

gdb:build
	gdb $(BUILD_DIR)/Vtop
build:$(OBJS)
	@mkdir -p $(BUILD_DIR)
	$(VERILATOR) vsrc/core/Core.sv $(VER_FLAGS) $(CCSRC) $(abspath $(OBJS)) \
	$(addprefix -CFLAGS ,$(CXXFLAGS)) $(addprefix -CFLAGS ,$(COMMON_FLAGS)) $(addprefix -LDFLAGS , $(LIBS))
difftest:
	ln -sf ${LAC_HOME}/vsrc/ ${CHIPLAB_HOME}/IP/Icarus
	cd ${CHIPLAB_HOME}/sims/verilator/run_prog/ && ./configure.sh --run $(TESTCASE) $(ARGS)
	make -C ${CHIPLAB_HOME}/sims/verilator/run_prog
run_sim:
	make -C ${CHIPLAB_HOME}/sims/verilator/run_prog run
clean_sim_env:
	rm -f ${CHIPLAB_HOME}/IP/Icarus
	make -C ${CHIPLAB_HOME}/sims/verilator/run_prog clean


clean:
	rm -rf build
