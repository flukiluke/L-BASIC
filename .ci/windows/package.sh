#!/bin/bash
set -x

UNUSED_ARCHES="aarch64-w64-mingw32 armv7-w64-mingw32 i686-w64-mingw32"

for arch in $UNUSED_ARCHES; do
    rm -r "out/llvm/${arch}"
done
rm -r out/llvm/{include,python,lib/libear,lib/libscanbuild} out/{lbasic.bas,llvm.h}

version=$GITHUB_REF_NAME

mv out "lbasic-${version}"
mkdir release
7z a "release/lbasic-${version}-windows-x86_64.7z" "lbasic-${version}"
