CC = gcc
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj
CSRC := $(shell find csrc/src -name "*.c")
CCSRC := $(shell find csrc/ -name "*.cpp" -or -name "*.cc")
OBJS=$(CSRC:%.c=$(OBJ_DIR)/%.o)
INC_PATH := $(abspath ./csrc/include/)
CFLAGS += $(addprefix -I, $(INC_PATH))  -MMD -Wall -Werror
CXXFLAGS += $(shell llvm-config --cxxflags)
LIBS += $(shell llvm-config --libs) -lreadline -ldl

VER_INCLUE = vsrc \
			vsrc/IO/ \
			vsrc/core/ \
			vsrc/core/stage/ 
VER_FLAGS = $(addprefix -I,$(VER_INCLUE)) --cc --exe --build --trace \
			--top Core --prefix Vtop -Mdir $(BUILD_DIR)

$(OBJ_DIR)/%.o:%.c
	@echo + CC $<
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<


.PHONY: sim clean all

all : sim
	$(BUILD_DIR)/Vtop
sim:$(OBJS)
	@mkdir -p $(BUILD_DIR)
	verilator vsrc/core/Core.sv $(VER_FLAGS) $(CCSRC) $(abspath $(OBJS)) \
	-CFLAGS "-I$(INC_PATH)" $(addprefix -CFLAGS ,$(CXXFLAGS)) $(addprefix -LDFLAGS , $(LIBS))





clean:
	rm -rf build