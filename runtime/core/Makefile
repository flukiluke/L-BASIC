# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for runtime core

OUTPUT_LIBRARY := $(OUT_DIR)/runtime/core.a

.PHONY: all
all: $(OUTPUT_LIBRARY)

OBJ := $(addsuffix .o, $(basename $(wildcard *.bm)))
HEADERS := $(addsuffix .bh, $(basename $(wildcard *.bm)))

%.o %.bh: %.bm
	$(LBASIC_CORE_COMPILER) -t --no-core -e obj -o $@ $<

LBINDEX: $(HEADERS)
	cat *.bh > LBINDEX

$(OUTPUT_LIBRARY): $(OBJ) LBINDEX
	$(AR) rcs $@ $(OBJ) LBINDEX

.PHONY: clean
clean:
	rm *.o 2> /dev/null
	rm *.bh 2> /dev/null
	rm LBINDEX 2> /dev/null
