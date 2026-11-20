IVERILOG ?= iverilog
VVP ?= vvp
BUILD_DIR := build
RTL := rtl/neuroflexxa_core.v
CORE_TB := tests/tb_neuroflexxa_core.v
EEG_TB := tests/tb_eeg_synthetic.v
CORE_SIM := $(BUILD_DIR)/neuroflexxa_core_tb
EEG_SIM := $(BUILD_DIR)/neuroflexxa_eeg_tb

.PHONY: all test test-core test-eeg clean
all: test

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(CORE_SIM): $(RTL) $(CORE_TB) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s tb_neuroflexxa_core -o $(CORE_SIM) $(RTL) $(CORE_TB)

$(EEG_SIM): $(RTL) $(EEG_TB) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s tb_eeg_synthetic -o $(EEG_SIM) $(RTL) $(EEG_TB)

test-core: $(CORE_SIM)
	$(VVP) $(CORE_SIM)

test-eeg: $(EEG_SIM)
	$(VVP) $(EEG_SIM)

test: test-core test-eeg

clean:
	rm -rf $(BUILD_DIR)
