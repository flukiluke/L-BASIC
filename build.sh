#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Main build script

# This script is responsible for building all components of L-BASIC.
# The result is output to the out/ directory, which can then be
# combined with clang, MinGW or similar for distribution.

# Defaults
: ${QB64:=qb64}
: ${QBFLAGS:="-w -q"}
: ${OUT_DIR:=out}

if [[ $1 = clean ]]; then
    rm -r "${OUT_DIR}"
    make -C tools clean
    make -C compiler clean
    exit 0
fi

if ! command -v "$QB64" > /dev/null; then
    echo Cannot locate QB64, either modify PATH or set the QB64 environment variable to point to the qb64 binary.
    exit 1
fi

OUT_DIR=$(realpath "${OUT_DIR}")
mkdir -p "${OUT_DIR}"
export QB64 QBFLAGS OUT_DIR

make -C tools
export TOOLS_DIR=$(realpath tools)

make -C compiler

