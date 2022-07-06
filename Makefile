CC = gcc
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj
CSRC := $(shell find lac_tracer/csrc/src -name "*.c")
CCSRC := $(shell find lac_tracer/csrc/ -name "*.cpp" -or -name "*.cc")
OBJS=$(CSRC:%.c=$(OBJ_DIR)/%.o)
INC_PATH := $(abspath ./lac_tracer/csrc/include/)
CFLAGS += $(addprefix -I, $(INC_PATH))  -MMD -Wall -Werror -g -O2
CXXFLAGS +=
LIBS += -lreadline -ldl

ARGS += 
IMG += 

VERILATOR = verilator
VER_INCLUE = vsrc \
			vsrc/IO/ \
			vsrc/core/ \
			vsrc/core/stage/ 
VER_FLAGS = $(addprefix -I,$(VER_INCLUE)) --cc --exe --build --trace -Wno-fatal \
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
	-CFLAGS "-I$(INC_PATH)" $(addprefix -CFLAGS ,$(CXXFLAGS)) $(addprefix -CFLAGS ,$(CFLAGS)) $(addprefix -LDFLAGS , $(LIBS))





clean:
	rm -rf build