# Immediate Mode
Immediate mode executes the current program or program fragment by walking the AST directly. Its initial purpose was to help verify the correctness of the produced AST, but also serves as a way to have an interactive interpreter session. Execution is significantly slower than compiled code.

## Memory Layout
Memory is divided into two separate regions, a stack and a heap. The stack is used for storing local variables, passing parameter to and returning values from procedures. The heap holds array data. Heap memory is managed using a pair of calls equivalent to C's malloc()/free().

When a procedure is started, sufficient slots are allocated on the stack to store its local variables, passed parameters and a return value (if needed). For the main procedure, "local" variables here also includes STATIC and SHARED variables as they need to exist for the entire program's lifetime and putting them on the heap would complicate matters.

### Arrays
Arrays consist of a descriptor with the following layout:
* Address of data
* Number of dimensions
* Lbound of leftmost dimension
* Ubound of leftmost dimension
* etc.
* Lbound of rightmost dimension
* Ubound of rightmost dimension

Generally the descriptor exists on the stack, and the actual data exists as a heap allocation. This allows freely resizing arrays without moving around stack positions.

## Calling Convention
Intrinsic procedures are free to each do their own thing. This only applies to user-defined procedures.

When a procedure is called, a new stack frame is created to hold:
* All the procedure's local, non-STATIC variables
* Each of the procedure's arguments
* Any shadow arguments as needed
* The procedure return value as needed

Each argument is evaluated. In the simplest case, the parameter is declared BYVAL and so the argument is copied straight to the stack position allocated for it. If it is BYREF (either explicitly or because the argument is an lvalue), the address of the passed variable is passed. Note in either case the procedure knows whether it is receiving a value or an address by how it was declared initially.

If the parameter is implicitly BYREF and the argument is not an lvalue, we make use of a shadow argument. Because the procedure is expecting an address but we only have the evaluation result, the result is written to the shadow location and the address of the shadow is passed.

If the procedure is a function, a stack position for the return value is allocated.

### Arrays
Arrays are always passed by reference. Specifically, the address of the descriptor is passed.
