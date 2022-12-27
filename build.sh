#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Main build script
set -e

# This script is responsible for building all components of L-BASIC.
# The result is output to the out/ directory, which can then be
# combined with clang, MinGW or similar for distribution.

# Defaults
: "${QB64:=qb64}"
: "${QBFLAGS:="-w -q"}"
: "${OUT_DIR:=out}"
OUT_DIR=$(realpath "${OUT_DIR}")
: "${LBASIC_CORE_COMPILER:=${OUT_DIR}/lbasic}"
TOOLS_DIR=$(realpath tools)
: "${LLVM_ROOT:=$(realpath llvm)}"
: "${CC:=${LLVM_ROOT}/bin/clang}"
CFLAGS="-O2 -Wall -std=c17 ${CFLAGS}"

# Subdirectories to build
components="tools compiler runtime/foundation runtime/core"

export QB64 QBFLAGS OUT_DIR TOOLS_DIR LBASIC_CORE_COMPILER LLVM_ROOT CC CFLAGS
echo "QB64=${QB64}"
echo "QBFLAGS=${QBFLAGS}"
echo "OUT_DIR=${OUT_DIR}"
echo "TOOLS_DIR=${TOOLS_DIR}"
echo "LBASIC_CORE_COMPILER=${LBASIC_CORE_COMPILER}"
echo "LLVM_ROOT=${LLVM_ROOT}"
echo "CC=${CC}"
echo "CFLAGS=${CFLAGS}"

qb64_dir=$(dirname "$(command -v "${QB64}")")

if [[ $1 = clean ]]; then
    set +e
    rm -r "${OUT_DIR}"
    rm -r "${qb64_dir}/llvm"
    for component in $components; do
        make -C "${component}" clean
    done
    exit 0
fi

if ! command -v "$QB64" > /dev/null; then
    echo Cannot locate QB64, either modify PATH or set the QB64 environment variable to point to the qb64 binary.
    exit 1
fi

if [[ ! -d ${LLVM_ROOT} ]]; then
    echo "${LLVM_ROOT} does not exist, either set the LLVM_ROOT environment variable or extract LLVM to the 'llvm' directory."
    exit 1
fi

mkdir -p "${OUT_DIR}/runtime"

# QB64 will expect libraries to exist at compile time relative to the qb64 binary, not the source file
if [[ ! -f "${qb64_dir}/llvm/bin/libLLVM-14.dll" ]]; then
    mkdir -p "${qb64_dir}/llvm/bin"
    ln -s "${LLVM_ROOT}/bin/libLLVM-14.dll" "${qb64_dir}/llvm/bin/"
fi

for component in $components; do
    make -C "${component}"
done
