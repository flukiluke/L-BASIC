#!/bin/bash
set -ex

export OUT_DIR="$(pwd)/lbasic-0.0.1"
export QB64="$(pwd)/qb64pe/qb64pe.exe"
export LLVM_INSTALL="$(pwd)/llvm-mingw"
export PYTHON="${LLVM_INSTALL}/python/bin/python3.exe"

./build.sh
