IVERILOG ?= iverilog
VVP ?= vvp
PYTHON ?= python3
BUILD_DIR := build
RTL := rtl/neuroflexxa_fir3.v rtl/neuroflexxa_core.v
CORE_TB := tests/tb_neuroflexxa_core.v
EEG_TB := tests/tb_eeg_synthetic.v
FIR_TB := tests/tb_neuroflexxa_fir3.v
ADAPTER_TB := tests/tb_neuroflexxa_eeg_stream_adapter.v
MULTICHANNEL_TB := tests/tb_neuroflexxa_eeg_multichannel_fir.v
CORE_SIM := $(BUILD_DIR)/neuroflexxa_core_tb
EEG_SIM := $(BUILD_DIR)/neuroflexxa_eeg_tb
FIR_SIM := $(BUILD_DIR)/neuroflexxa_fir3_tb
ADAPTER_SIM := $(BUILD_DIR)/neuroflexxa_eeg_stream_adapter_tb
MULTICHANNEL_SIM := $(BUILD_DIR)/neuroflexxa_eeg_multichannel_fir_tb
FIR_VECTORS := $(BUILD_DIR)/fir_reference_vectors.txt

.PHONY: all test test-core test-eeg test-fir test-eeg-adapter test-eeg-multichannel clean
all: test

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(CORE_SIM): $(RTL) $(CORE_TB) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s tb_neuroflexxa_core -o $(CORE_SIM) $(RTL) $(CORE_TB)

$(EEG_SIM): $(RTL) $(EEG_TB) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s tb_eeg_synthetic -o $(EEG_SIM) $(RTL) $(EEG_TB)

$(FIR_VECTORS): tools/fir_reference.py | $(BUILD_DIR)
	$(PYTHON) tools/fir_reference.py --output $(FIR_VECTORS) --count 2048

$(FIR_SIM): rtl/neuroflexxa_fir3.v $(FIR_TB) $(FIR_VECTORS) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s tb_neuroflexxa_fir3 -o $(FIR_SIM) rtl/neuroflexxa_fir3.v $(FIR_TB)

$(ADAPTER_SIM): rtl/neuroflexxa_eeg_stream_adapter.v $(ADAPTER_TB) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s tb_neuroflexxa_eeg_stream_adapter -o $(ADAPTER_SIM) rtl/neuroflexxa_eeg_stream_adapter.v $(ADAPTER_TB)

test-eeg-adapter: $(ADAPTER_SIM)
	$(VVP) $(ADAPTER_SIM)

$(MULTICHANNEL_SIM): rtl/neuroflexxa_fir3.v rtl/neuroflexxa_eeg_multichannel_fir.v $(MULTICHANNEL_TB) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s tb_neuroflexxa_eeg_multichannel_fir -o $(MULTICHANNEL_SIM) rtl/neuroflexxa_fir3.v rtl/neuroflexxa_eeg_multichannel_fir.v $(MULTICHANNEL_TB)

test-eeg-multichannel: $(MULTICHANNEL_SIM)
	$(VVP) $(MULTICHANNEL_SIM)

test-core: $(CORE_SIM)
	$(VVP) $(CORE_SIM)

test-eeg: $(EEG_SIM)
	$(VVP) $(EEG_SIM)

test-fir: $(FIR_SIM)
	$(VVP) $(FIR_SIM) +VECTORS=$(FIR_VECTORS)

test: test-core test-eeg test-fir test-eeg-adapter test-eeg-multichannel

clean:
	rm -rf $(BUILD_DIR)
