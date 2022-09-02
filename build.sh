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
: ${CFLAGS:=-O2 -Wall -std=c17}

# Subdirectories to build
components="tools compiler runtime/startup runtime/foundation"

OUT_DIR=$(realpath "${OUT_DIR}")
TOOLS_DIR=$(realpath tools)
export QB64 QBFLAGS OUT_DIR TOOLS_DIR CFLAGS
echo "QB64=${QB64}"
echo "QBFLAGS=${QBFLAGS}"
echo "CFLAGS=${CFLAGS}"
echo "OUT_DIR=${OUT_DIR}"
echo "TOOLS_DIR=${TOOLS_DIR}"

if [[ $1 = clean ]]; then
    rm -r "${OUT_DIR}"
    for component in $components; do
        make -C "${component}" clean
    done
    exit 0
fi

if ! command -v "$QB64" > /dev/null; then
    echo Cannot locate QB64, either modify PATH or set the QB64 environment variable to point to the qb64 binary.
    exit 1
fi

mkdir -p "${OUT_DIR}/runtime"
for component in $components; do
    make -C "${component}"
done
