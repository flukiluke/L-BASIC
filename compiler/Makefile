# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for compiler binary

OUTPUT_BINARY := $(OUT_DIR)/lbasic

.PHONY: all
all: $(OUTPUT_BINARY)

TS_FILES := parser/ts_data.bi parser/ts_data.bm
TOKEN_FILES := parser/token_data.bi parser/token_registrations.bm

$(TS_FILES): parser/ts.rules $(TOOLS_DIR)/tsgen.tool
	$(TOOLS_DIR)/tsgen.tool parser/ts.rules $(TS_FILES)

$(TOKEN_FILES): parser/tokens.list $(TOOLS_DIR)/tokgen.tool
	$(TOOLS_DIR)/tokgen.tool parser/tokens.list $(TOKEN_FILES)

$(OUTPUT_BINARY): lbasic.bas $(TS_FILES) $(TOKEN_FILES) $(shell find . -type f -name '*.bm' -o -name '*.bi') $(TOOLS_DIR)/incmerge.tool $(TOOLS_DIR)/prep.py
	$(eval temp1 := $(shell mktemp))
	$(eval temp2 := $(shell mktemp))
	$(TOOLS_DIR)/incmerge.tool lbasic.bas $(temp1)
	$(TOOLS_DIR)/prep.py $(temp1) $(temp2)
	$(QB64) $(QBFLAGS) -x $(temp2) -o $@
	rm $(temp1) $(temp2)

.PHONY: clean
clean:
	rm -r $(TS_FILES) $(TOKEN_FILES) 2> /dev/null || true
