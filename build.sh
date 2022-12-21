#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Main build script
set -e

# This script is responsible for building all components of L-BASIC.
# The result is output to the out/ directory, which can then be
# combined with clang, MinGW or similar for distribution.

# Platform specific configuration
case $(uname) in
    linux)
        : ${QB64_CXX:=$(command -v g++)}
        : ${STATIC_LIB_PREFIX:=lib}
        ;;
    MINGW*)
        : ${QB64_CXX:="$(dirname "$QB64")/internal/c/c_compiler/bin/g++"}
        : ${STATIC_LIB_PREFIX:=}
        ;;
    *)
        echo Unknown platform "'$(uname)'". Edit build.sh to add.
        exit 1
        ;;
esac

# General configuration
: ${QB64:=$(command -v qb64)}
QBFLAGS="-w -q ${QBFLAGS}"
: ${OUT_DIR:=out}
OUT_DIR=$(realpath "${OUT_DIR}")
: ${CC:=clang}
CFLAGS="-O2 -Wall -std=c17 ${CFLAGS}"
CXXFLAGS="-O2 -Wall -std=c++17 ${CXXFLAGS}"
: ${LBASIC_CORE_COMPILER:=${OUT_DIR}/lbasic}
TOOLS_DIR=$(realpath tools)

# Subdirectories to build
components="tools compiler runtime/foundation runtime/core"

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

if ! command -v "$QB64_CXX" > /dev/null; then
    echo Cannot locate C++ compiler used by QB64, set the QB64_CXX environment variable.
    exit 1
fi

export QB64 QBFLAGS QB64_CXX CC CFLAGS CXXFLAGS OUT_DIR TOOLS_DIR LBASIC_CORE_COMPILER STATIC_LIB_PREFIX
echo "QB64=${QB64}"
echo "QBFLAGS=${QBFLAGS}"
echo "QB64_CXX=${QB64_CXX}"
echo "CC=${CC}"
echo "CFLAGS=${CFLAGS}"
echo "CXXFLAGS=${CXXFLAGS}"
echo "OUT_DIR=${OUT_DIR}"
echo "TOOLS_DIR=${TOOLS_DIR}"
echo "LBASIC_CORE_COMPILER=${LBASIC_CORE_COMPILER}"
echo "STATIC_LIB_PREFIX=${STATIC_LIB_PREFIX}"

mkdir -p "${OUT_DIR}/runtime"
for component in $components; do
    make -C "${component}"
done
