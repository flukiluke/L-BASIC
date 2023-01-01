# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# Makefile for helper tools

.PHONY: all
all: tsgen.tool tokgen.tool incmerge.tool ffigen.tool

%.tool: %.bas
	$(QB64) $(QBFLAGS) -x "$(realpath $<)" -o "$(realpath .)/$@.tool"

.PHONY: clean
clean:
	rm *.tool 2> /dev/null || true
