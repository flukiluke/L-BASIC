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
: "${LLVM_ROOT:=llvm}"
: "${CC:=${LLVM_ROOT}/bin/clang}"
CFLAGS="-O2 -Wall -std=c17 ${CFLAGS}"

llvm_ver=14

if [[ -z ${LLVM_LIB} ]]; then
    case $(uname) in
        MINGW*)
            llvm_lib_file="${LLVM_ROOT:-llvm}/bin/libLLVM-${llvm_ver}.dll"
            LLVM_LIB="${LLVM_ROOT:-llvm}/bin/libLLVM-${llvm_ver}"
            ;;

        Linux)
            if [[ -z ${USE_SYSTEM_LLVM} ]]; then
                llvm_lib_file=$(llvm-config --libfiles)
            else
                LLVM_LIB="${LLVM_ROOT:-llvm}/lib/libLLVM-14.so"
            fi
            ;;

        *)
            echo "Unknown system '$(uname)', edit build.sh as needed"
            exit 1
            ;;
    esac
fi

# Subdirectories to build
components="tools compiler runtime/foundation runtime/core"

export QB64 QBFLAGS OUT_DIR TOOLS_DIR LBASIC_CORE_COMPILER LLVM_LIB CC CFLAGS
echo "QB64=${QB64}"
echo "QBFLAGS=${QBFLAGS}"
echo "OUT_DIR=${OUT_DIR}"
echo "TOOLS_DIR=${TOOLS_DIR}"
echo "LBASIC_CORE_COMPILER=${LBASIC_CORE_COMPILER}"
echo "LLVM_LIB=${LLVM_LIB}"
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

#if [[ ! -f ${LLVM_LIB} ]]; then
#    echo "${LLVM_LIB} does not exist, set USE_SYSTEM_LLVM, LLVM_ROOT or LLVM_LIB as appropriate"
#    exit 1
#fi

mkdir -p "${OUT_DIR}/runtime"

# QB64 will expect libraries to exist at compile time relative to the qb64 binary, not the source file
#if [[ ! -f "${qb64_dir}/llvm/bin/libLLVM-14.dll" ]]; then
#    mkdir -p "${qb64_dir}/llvm/bin"
#    ln -s "${LLVM_ROOT}/bin/libLLVM-14.dll" "${qb64_dir}/llvm/bin/"
#fi

for component in $components; do
    make -C "${component}"
done
