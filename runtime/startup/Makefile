# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for runtime startup code

OBJECTS := main
OUTPUT_LIBRARY := $(OUT_DIR)/runtime/startup.a

.PHONY: all
all: $(OUTPUT_LIBRARY)

$(OUTPUT_LIBRARY): $(addsuffix .o, $(OBJECTS))
	$(AR) rcs $@ $^

.PHONY: clean
clean:
	rm *.o *.a 2> /dev/null

