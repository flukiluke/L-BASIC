The '65 BASIC Compiler
======================
(Decent name coming soon)

As you may imagine, this is a BASIC compiler. The language variant is reasonably close to QB64 (https://qb64.org) but we're willing to break compatibility with programs from 1985 when needed.

The project is itself implemented in QB64, which you will need installed to compile this project.

Currently this is only the barebones of a parser.

Build Instructions
------------------
- Edit the top of Makefile to point to your QB64 installation
- Run make

The final binaries are in out/, with 65 being the executable to run. Tested on Linux only but should work on Windows, more or less.
