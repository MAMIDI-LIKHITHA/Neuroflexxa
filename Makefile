IVERILOG ?= iverilog
VVP ?= vvp
BUILD_DIR := build
RTL := rtl/neuroflexxa_core.v
TB := tests/tb_neuroflexxa_core.v
SIM := $(BUILD_DIR)/neuroflexxa_tb

.PHONY: all test clean
all: test

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(SIM): $(RTL) $(TB) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s tb_neuroflexxa_core -o $(SIM) $(RTL) $(TB)

test: $(SIM)
	$(VVP) $(SIM)

clean:
	rm -rf $(BUILD_DIR)
