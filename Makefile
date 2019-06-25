# This should point to your QB64 installation
QB64 := /home/luke/comp/git_qb64/qb64 -v

BUILD_DIR := $(CURDIR)/build
SRC_DIR := $(CURDIR)/src
TOOLS_DIR := $(CURDIR)/tools
OUT_DIR := $(CURDIR)/out
$(shell mkdir -p $(OUT_DIR) $(BUILD_DIR) &> /dev/null)

all: compiler

compiler: $(OUT_DIR)/65 $(OUT_DIR)/parser

# Main user-called binary
$(OUT_DIR)/65: $(SRC_DIR)/65.bas
	$(QB64) -x $< -o $@

TS_FILES := $(BUILD_DIR)/ts_data.bi $(BUILD_DIR)/ts_data.bm
TOKEN_FILES := $(BUILD_DIR)/token_data.bi $(BUILD_DIR)/token_registrations.bm
COMMON_SRC := $(wildcard $(SRC_DIR)/common/*.bm) $(wildcard $(SRC_DIR)/common/*.bi)

$(OUT_DIR)/parser: $(SRC_DIR)/parser/parser.bas \
                   $(wildcard $(SRC_DIR)/parser/*.bm) \
                   $(wildcard $(SRC_DIR)/parser/*.bi) \
				   $(COMMON_SRC) \
				   $(TS_FILES) \
				   $(TOKEN_FILES)
	$(QB64) -x $(SRC_DIR)/parser/parser.bas -o $(OUT_DIR)/parser

$(TS_FILES): $(SRC_DIR)/parser/ts.rules $(BUILD_DIR)/tsgen.tool
	$(BUILD_DIR)/tsgen.tool $(SRC_DIR)/parser/ts.rules

$(TOKEN_FILES): $(SRC_DIR)/parser/tokens.list $(BUILD_DIR)/tokgen.tool
	$(BUILD_DIR)/tokgen.tool $(SRC_DIR)/parser/tokens.list $(TOKEN_FILES)

$(BUILD_DIR)/%.tool: $(TOOLS_DIR)/%.bas
	$(QB64) -x $< -o $@.tool

.PHONY: clean
clean:
	rm -r $(BUILD_DIR) $(OUT_DIR)
