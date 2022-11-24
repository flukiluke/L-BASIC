# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for runtime core

OUTPUT_LIBRARY := $(OUT_DIR)/runtime/core.a

.PHONY: all
all: $(OUTPUT_LIBRARY)

OBJ := $(addsuffix .o, $(basename $(wildcard *.bm)))

%.o: %.bm
	$(LBASIC_CORE_COMPILER) -t -e obj -o $@ $<

$(OUTPUT_LIBRARY): $(OBJ)
	$(AR) rcs $@ $(OBJ)

.PHONY: clean
clean:
	rm *.o 2> /dev/null
