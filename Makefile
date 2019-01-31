QB64 = /home/luke/comp/git_qb64/qb64 -v

BUILD_DIR = $(CURDIR)/build
SRC_DIR = $(CURDIR)/src
TOOLS_DIR = $(CURDIR)/tools

SRC = $(SRC_DIR)/65.bas $(wildcard $(SRC_DIR)/*.bm) $(wildcard $(SRC_DIR)/*.bi)
TS_FILES = $(BUILD_DIR)/ts_data.bi $(BUILD_DIR)/ts_data.bm
TOKEN_FILES = $(BUILD_DIR)/token_data.bi $(BUILD_DIR)/token_registrations.bm

all: 65

65: $(TS_FILES) $(TOKEN_FILES) $(SRC_BI) $(SRC_BM)
	$(QB64) -x $(SRC_DIR)/65.bas -o $(BUILD_DIR)/65

$(TS_FILES): $(SRC_DIR)/ts.rules $(BUILD_DIR)/tsgen.tool
	$(BUILD_DIR)/tsgen.tool $(SRC_DIR)/ts.rules

$(TOKEN_FILES): $(SRC_DIR)/tokens.list $(BUILD_DIR)/tokgen.tool
	$(BUILD_DIR)/tokgen.tool $(SRC_DIR)/tokens.list $(TOKEN_FILES)

$(BUILD_DIR)/%.tool: $(TOOLS_DIR)/%.bas
	$(QB64) -x $< -o $@.tool

.PHONY: clean
clean:
	rm $(BUILD_DIR)/*
