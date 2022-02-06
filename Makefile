# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for project

# This should point to your QB64 installation
QB64 := /home/luke/comp/git_qb64/qb64 -q -w
OUTPUT_BINARY := $(CURDIR)/lbasic
MERGED_SOURCE := $(CURDIR)/lbasic-merged.bas

SRC_DIR := $(CURDIR)/src
TOOLS_DIR := $(CURDIR)/tools
TEST_DIR := $(CURDIR)/tests

.PHONY: all
all: $(OUTPUT_BINARY) $(MERGED_SOURCE)

.PHONY: test
TESTS := $(shell find $(TEST_DIR) -type f -name '*.test')
test: $(TESTS:.test=.testresult)
%.testresult: $(TOOLS_DIR)/test.tool $(OUTPUT_BINARY) %.test
	$(TOOLS_DIR)/test.tool "$(OUTPUT_BINARY) -t" $(word 3,$^)

$(TOOLS_DIR)/%.tool: $(TOOLS_DIR)/%.bas
	$(QB64) -x $< -o $@.tool

TS_FILES := $(SRC_DIR)/parser/ts_data.bi $(SRC_DIR)/parser/ts_data.bm
TOKEN_FILES := $(SRC_DIR)/parser/token_data.bi $(SRC_DIR)/parser/token_registrations.bm

$(TS_FILES): $(SRC_DIR)/parser/ts.rules $(TOOLS_DIR)/tsgen.tool
	$(TOOLS_DIR)/tsgen.tool $(SRC_DIR)/parser/ts.rules $(TS_FILES)

$(TOKEN_FILES): $(SRC_DIR)/parser/tokens.list $(TOOLS_DIR)/tokgen.tool
	$(TOOLS_DIR)/tokgen.tool $(SRC_DIR)/parser/tokens.list $(TOKEN_FILES)

# Main binary
$(OUTPUT_BINARY): $(SRC_DIR)/lbasic.bas $(TS_FILES) $(TOKEN_FILES) $(shell find $(SRC_DIR) -type f -name '*.bm' -o -name '*.bi')
	$(QB64) -x $< -o $@

# Source for distribution
$(MERGED_SOURCE): $(OUTPUT_BINARY) $(TOOLS_DIR)/incmerge.tool
	$(TOOLS_DIR)/incmerge.tool $(SRC_DIR)/lbasic.bas $(MERGED_SOURCE)

DOCKER_TAG?=lbasic
.PHONY: docker
docker: $(MERGED_SOURCE)
	#if ! grep --silent 'console:only' $(SRC_DIR)/buildinfo.bi; then echo '$$console:only' >> $(SRC_DIR)/buildinfo.bi; fi
	docker build -t $(DOCKER_TAG) .

.PHONY: clean
clean:
	rm -r $(TS_FILES) $(TOKEN_FILES) $(TOOLS_DIR)/*.tool $(OUTPUT_BINARY) $(MERGED_SOURCE) 2> /dev/null || true
