# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for compiler binary

OUTPUT_BINARY := $(OUT_DIR)/lbasic
OUTPUT_SOURCE := $(OUT_DIR)/lbasic.bas

.PHONY: all
all: $(OUTPUT_BINARY)

TS_FILES := parser/ts_data.bi parser/ts_data.bm
TOKEN_FILES := parser/token_data.bi parser/token_registrations.bm

$(TS_FILES): parser/ts.rules $(TOOLS_DIR)/tsgen.tool
	$(TOOLS_DIR)/tsgen.tool parser/ts.rules $(TS_FILES)

$(TOKEN_FILES): parser/tokens.list $(TOOLS_DIR)/tokgen.tool
	$(TOOLS_DIR)/tokgen.tool parser/tokens.list $(TOKEN_FILES)

$(OUT_DIR)/$(STATIC_LIB_PREFIX)archive.o: emitters/llvm/archive.cpp
	$(QB64_CXX) $(CXXFLAGS) -c $^ -o $@

$(OUTPUT_SOURCE): lbasic.bas $(TS_FILES) $(TOKEN_FILES) $(shell find . -type f -name '*.bm' -o -name '*.bi') $(OUT_DIR)/$(STATIC_LIB_PREFIX)archive.o $(TOOLS_DIR)/incmerge.tool $(TOOLS_DIR)/prep.py
	$(eval temp := $(shell mktemp))
	$(TOOLS_DIR)/incmerge.tool lbasic.bas $(temp)
	$(TOOLS_DIR)/prep.py $(temp) $@
	rm $(temp)

$(OUTPUT_BINARY): $(OUTPUT_SOURCE)
	$(QB64) $(QBFLAGS) -x $^ -o $@

.PHONY: clean
clean:
	rm -r $(TS_FILES) $(TOKEN_FILES) 2> /dev/null || true
