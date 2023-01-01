# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for compiler binary

OUTPUT_BINARY := $(OUT_DIR)/lbasic
OUTPUT_SOURCE := $(OUT_DIR)/lbasic.bas

.PHONY: all
all: $(OUTPUT_BINARY)

TS_FILES := parser/ts_data.bi parser/ts_data.bm
TOKEN_FILES := parser/token_data.bi parser/token_registrations.bm
LLVM_BINDING_FILES := emitters/llvm/llvm_bindings.bi $(OUT_DIR)/llvm.h

$(TS_FILES): parser/ts.rules $(TOOLS_DIR)/tsgen.tool
	$(TOOLS_DIR)/tsgen.tool parser/ts.rules $(TS_FILES)

$(TOKEN_FILES): parser/tokens.list $(TOOLS_DIR)/tokgen.tool
	$(TOOLS_DIR)/tokgen.tool parser/tokens.list $(TOKEN_FILES)

$(LLVM_BINDING_FILES): emitters/llvm/llvm.ffi $(TOOLS_DIR)/ffigen.tool
	$(TOOLS_DIR)/ffigen.tool $< $(LLVM_BINDING_FILES)

$(OUTPUT_SOURCE): lbasic.bas \
					$(TS_FILES) $(TOKEN_FILES) \
					$(LLVM_BINDING_FILES) \
					$(TOOLS_DIR)/incmerge.tool $(TOOLS_DIR)/prep.py \
					$(shell find . -type f -name '*.bm' -o -name '*.bi')
	$(eval temp := $(shell mktemp))
	$(TOOLS_DIR)/incmerge.tool lbasic.bas $(temp)
	$(TOOLS_DIR)/prep.py -D '@LLVM_DYLIB@|$(LLVM_ROOT)/lib/LLVM-14' $(temp) $@
	rm $(temp)

$(OUTPUT_BINARY): $(OUTPUT_SOURCE)
	$(QB64) $(QBFLAGS) -x $< -o $@

.PHONY: clean
clean:
	rm -r $(TS_FILES) $(TOKEN_FILES) 2> /dev/null || true
	rm $(LLVM_BINDING_FILES) 2> /dev/null || true
