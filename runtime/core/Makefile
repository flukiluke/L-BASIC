# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for runtime core

OUTPUT_LIBRARY := $(OUT_DIR)/runtime/core
OUT_HEADER := $(OUTPUT_LIBRARY).bh
OUT_BINARY := $(OUTPUT_LIBRARY).a

.PHONY: all
all: $(OUT_HEADER) $(OUT_BINARY)

OBJ := $(addsuffix .o, $(basename $(wildcard *.bm)))
HEADERS := $(addsuffix .bh, $(basename $(wildcard *.bm)))

%.o %.bh: %.bm
	$(LBASIC_CORE_COMPILER) -t --no-core -e obj -o $*.o $<

$(OUT_HEADER): $(HEADERS)
	cat *.bh > $@

$(OUT_BINARY): $(OBJ)
	$(AR) rcs $@ $(OBJ)

.PHONY: clean
clean:
	rm *.o 2> /dev/null || true
	rm *.bh 2> /dev/null || true
