## Available Data Types
 - INTEGER (%), a signed 16 bit integer
 - LONG (&), a signed 32 bit integer
 - INTEGER64 (&&), a signed 64 bit integer
 - SINGLE (!), a single-precision floating-point number
 - DOUBLE (#), a double-precision floating-point number
 - QUAD (##), a quadruple-precision floating-point number
 - STRING ($), a variable-length sequence of bytes
 - User Defined Types

## Definitions
* The types INTEGER, LONG, INTEGER64, SINGLE, DOUBLE and QUAD are considered NUMBER types.
* All types are considered ANY types.
* ANY and NUMBER are abstract types; all other types are concrete types.
* An expression is considered a function call or a constant.

## Casts
The following functions cast from any NUMBER type:
* CINT%()
* CLNG&()
* CINT64&&()
* CSNG!()
* CDBL#()
* CQUAD##()

These functions may throw an Overflow error (ERR 6) at runtime if the value is outside the bounds of the desired type. Alternatively, the value may be wrapped or truncated without notice, depending on the implementation.

### Implicit Casts
An implicit cast takes place when assigning to a variable with a different type, between NUMBER types only. The compiler will automatically insert the appropriate casting function. For example:
* `x% = y&` becomes `x% = CINT(y&)`
* `x# = y% + z%` becomes `x# = CDBL(y% + z%)`
* `x# = y#` remains as-is
* `x$ = y%` is illegal

## Constants
The type of non-NUMBER types is obvious (a string literal is of STRING type). If a type suffix is present then that determines the type. Otherwise:
* If the number has no decimal point or exponent, then its type is the smallest of INTEGER, LONG or INTEGER64 that can hold it. If no type can hold it, the next rule applies.
* If the number has a decimal point or an exponent (e.g. 3E8) or does not fit an INTEGER64, then its type is the smallest of SINGLE, DOUBLE or QUAD that can hold it (with respect to magnitude). If no type can hold it, the number is illegal.
A type suffix may not specify a type smaller than what would be determined by the above rules.

## Function arguments
A function has 0 or more arguments and a return type (or a not-considered return type if it is a SUB). A function declaration specifies the type of each argument and the return type. When called, arguments are passed in one of two ways:
* If an argument is specified as a single variable, it is passed _by reference_. The type of the variable must exactly match the declared type of the argument.
* If an argument is specified as an expression or constant, it is passed _by value_. If the expression and argument declaration are both NUMBER types, an implicit cast will be added.

### Binary Operators
The operators `\`, `AND`, `OR`, `EQV`, `IMP` and `XOR` behave as follows:
* If both arguments are of type INTEGER, LONG or INTEGER64, the return type is the larger of the two arguments.
* If one or both arguments are of type SINGLE, DOUBLE or QUAD, the arguments are cast to the smallest integral type that is lossless. Note that this has the potential to cause an Overflow error with QUAD values.

The operators `/` and `^` behave as follows:
* First, any arguments of type
    * INTEGER are cast to SINGLE
    * LONG are cast to DOUBLE
    * INTEGER64 are cast to QUAD
* Then the return type is the larger of the two arguments (one of SINGLE, DOUBLE or QUAD).

The operators `+`, `-` and `*` have a return type that is the larger of the two arguments.

### BYVAL and BYREF arguments
A function argument may be declared as BYVAL or BYREF (but not both). This forces calls to pass the argument by value or reference, respectively. This means a BYREF argument must be passed a single variable of the correct type, never an expression or constant.

### Multi-typed functions
A function may be declared multiple times with the same name, as long as the arguments are identical except for the types of BYREF arguments and their return types. The compiler will select the correct function to call based on the type of variables passed to those BYREF arguments. Multiple declarations must not differ only on their return type.


