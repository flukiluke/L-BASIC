# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for runtime support code

OUTPUT_LIBRARY := $(OUT_DIR)/runtime/foundation.a
CFLAGS := $(CFLAGS) -I../include

.PHONY: all
all: $(OUTPUT_LIBRARY)

OBJ := $(addsuffix .o, $(basename $(wildcard *.c)))
$(OUTPUT_LIBRARY): $(OBJ) $(wildcard *.h)
	rm $@ 2> /dev/null || true
	$(AR) rcs $@ $(OBJ) 

.PHONY: clean
clean:
	rm *.o 2> /dev/null
