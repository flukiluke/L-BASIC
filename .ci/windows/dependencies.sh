#!/bin/bash
set -ex

QB64_URL='https://github.com/QB64-Phoenix-Edition/QB64pe/releases/download/v3.4.1/qb64pe_win-x64-3.4.1.7z'
QB64_SHA256=41ba1d4da734c2c2ac309d923b48a9ccf3afbf936b1d23a3be9a885840a7f95d
LLVM_MINGW_URL='https://github.com/mstorsjo/llvm-mingw/releases/download/20220323/llvm-mingw-20220323-ucrt-x86_64.zip'
LLVM_MINGW_SHA256=3014a95e4ec4d5c9d31f52fbd6ff43174a0d9c422c663de7f7be8c2fcc9d837a

wget --no-verbose "${QB64_URL}" -O qb64.7z
wget --no-verbose "${LLVM_MINGW_URL}" -O llvm_mingw.zip

sha256sum --check << EOT
${QB64_SHA256} qb64.7z
${LLVM_MINGW_SHA256} llvm_mingw.zip
EOT

# Expected to extract directory 'qb64pe'
7z x qb64.7z

unzip llvm_mingw.zip
mv $(basename "${MMV_MINGW_URL}" .zip) llvm-mingw

ls -l
