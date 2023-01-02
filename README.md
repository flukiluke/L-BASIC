The L-BASIC programming language
======================

As you may imagine, this is a BASIC compiler. The language variant is reasonably close to QB64 but we're willing to break compatibility with programs from 1985 when needed.

## Building
Building L-BASIC is more complex than a regular QB64 program, particularly because of the need to link against LLVM. Also, **neither the L-BASIC source tree or any prerequisites can be installed in a path containing spaces** - this is a limitation of `make`. L-BASIC itself can handle paths with spaces though.

### Windows
Install prerequisites:
 - QB64 (Phoenix edition), version 3.4.1: https://github.com/QB64-Phoenix-Edition/QB64pe/releases/download/v3.4.1/qb64pe_win-x64-3.4.1.7z [SHA-256: 41ba1d4da734c2c2ac309d923b48a9ccf3afbf936b1d23a3be9a885840a7f95d]
 - MSYS2: https://www.msys2.org/
 - LLVM-mingw (ucrt edition), version 20220323/14.0.0: https://github.com/mstorsjo/llvm-mingw/releases/download/20220323/llvm-mingw-20220323-ucrt-x86_64.zip [SHA-256: https://github.com/mstorsjo/llvm-mingw/releases/download/20220323/llvm-mingw-20220323-ucrt-x86_64.zip]

Inside an MSYS environment:
 - Install git and make: `pacman -S git make`
 - Extract LLVM-mingw to `~`
 - Extract QB64 to to `~`
 - Configure environment:
    ```
    export QB64=~/qb64pe/qb64pe.exe
    export LLVM_INSTALL=~/llvm-mingw-20220323-ucrt-x86_64
    export PYTHON=$LLVM_INSTALL/python/bin/python3.exe
    ```
 - Build: `./build.sh`

 The output binary is `out/lbasic.exe`. To compile a program:
 ```
 ./out/lbasic.exe -t hello.bas
 ./hello.exe
 ```

### Linux
Install prerequisites:
 - QB64 (Phoenix edition), version 3.4.1: https://github.com/QB64-Phoenix-Edition/QB64pe/releases/download/v3.4.1/qb64pe_lnx-3.4.1.tar.gz [SHA-256: a47213e0a2e6d01e2fdf0db53e20dfb86131511230cf242ea7b372c90aa8d553]
 - clang, version 14. On apt based systems: `sudo apt install clang-14`
 - Configure environment:
    ```
    export QB64=~/qb64pe/qb64pe
    ```
 - Build: `./build.sh`

 The output binary is `out/lbasic`. To compile a program:
 ```
 ./out/lbasic -t hello.bas
 ./hello
 ```

 ### Build options
 These may be set as environment variables before running build.sh:
  - `QB64`: Path to QB64 compiler program
  - `QBFLAGS`: QB64 compilation flags to use
  - `OUT_DIR`: Directory to place final output binaries
  - `LBASIC_CORE_COMPILER`: L-BASIC compiler used to build internal libraries. Defaults to the just-built lbasic in OUT_DIR.
  - `TOOLS_DIR`: Location of the tools source directory
  - `LLVM_INSTALL`: Directory containing the bin and lib folder for the LLVM installation. If empty or set to `system`, expect programs to be on the PATH.
  - `CC`: C compiler used to build foundation library
  - `AR`: Archiver used to build internal libraries
  - `CFLAGS`: C compiler flags used to build foundation library
  - `PYTHON`: Path to python program used to run python build steps
