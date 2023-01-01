# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for runtime foundation

OUTPUT_LIBRARY := $(OUT_DIR)/runtime/foundation.a

.PHONY: all
all: $(OUTPUT_LIBRARY)

OBJ := $(addsuffix .o, $(basename $(wildcard *.c)))

%.o: %.c $(wildcard *.h)
	$(CC) $(CFLAGS) -c -o $@ $<

$(OUTPUT_LIBRARY): $(OBJ)
	$(AR) rcs $@ $(OBJ)

.PHONY: clean
clean:
	rm *.o 2> /dev/null || true
