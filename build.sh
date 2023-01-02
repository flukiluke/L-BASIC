#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Main build script
set -e

# Defaults
: "${QB64:=qb64}"
: "${QBFLAGS:="-w -q"}"
: "${OUT_DIR:=out}"
OUT_DIR=$(realpath "${OUT_DIR}")
: "${LBASIC_CORE_COMPILER:=${OUT_DIR}/lbasic}"
TOOLS_DIR=$(realpath tools)
: "${LLVM_INSTALL:=system}"
CFLAGS="-O2 -Wall -std=c17 ${CFLAGS}"

llvm_ver=14
case $(uname) in
    MINGW*)
        if [[ ${LLVM_INSTALL} = "system" ]]; then
            LLVM_LIB=libLLVM-${llvm_ver}.dll
            : "${CC:=clang.exe}"
        else
            LLVM_LIB="$(cygpath -m "${LLVM_INSTALL}/bin/libunwind.dll") $(cygpath -m "${LLVM_INSTALL}/bin/libc++.dll") $(cygpath -m "${LLVM_INSTALL}/bin/libLLVM-${llvm_ver}.dll")"
            : "${CC:=$(realpath "${LLVM_INSTALL}/bin/clang.exe")}"
        fi
        ;;
    Linux)
        if [[ ${LLVM_INSTALL} = "system" ]]; then
            LLVM_LIB=libLLVM-${llvm_ver}.so
            : "${CC:=clang}"
        else
            LLVM_LIB=${LLVM_INSTALL}/lib/libLLVM-${llvm_ver}.so
            : "${CC:=$(realpath "${LLVM_INSTALL}/bin/clang")}"
        fi
        ;;
    *)
        echo "Unknown system '$(uname)'"
        exit 1
        ;;
esac

# Subdirectories to build
components="tools compiler runtime/foundation runtime/core"

export QB64 QBFLAGS OUT_DIR TOOLS_DIR LBASIC_CORE_COMPILER LLVM_INSTALL LLVM_LIB CC CFLAGS
echo "QB64=${QB64}"
echo "QBFLAGS=${QBFLAGS}"
echo "OUT_DIR=${OUT_DIR}"
echo "TOOLS_DIR=${TOOLS_DIR}"
echo "LBASIC_CORE_COMPILER=${LBASIC_CORE_COMPILER}"
echo "LLVM_INSTALL=${LLVM_INSTALL}"
echo "LLVM_LIB=${LLVM_LIB}"
echo "CC=${CC}"
echo "CFLAGS=${CFLAGS}"

if [[ $1 = clean ]]; then
    set +e
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
