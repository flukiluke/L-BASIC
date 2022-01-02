'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'type.bi - Declarations for type management routines

'type_signatures() is a linked list.
'A function token points to a single type_signature_t, and that element may point to alternative signatures for that function.
'This allows us to support declaring a function multiple times with different signatures by chaining each declaration's signature together.

'type_signature_t.sig is an mkl$-encoded string. Its format is mkl$(return type) + mkl$(argument 1 type) + mkl$(argument 1 flags) + mkl$(argument 2 type) + mkl$(argument 2 flags) + ...
'For each flag, the low 16 bits are one or more TYPE_* flags as defined below. If TYPE_TOKEN is set, the high 16 bits
'of the flag contain the value that will be passed as an AST_FLAGS value in this position in the argument list.
'Don't access them directly, use the type_sig_* functions.
type type_signature_t
    sig as string
    succ as long 'Can't call this "next" :(
end type

redim shared type_signatures(10) as type_signature_t
dim shared type_last_signature as long

'Note: constants for actual data types (TYPE_LONG etc.) are defined in tokens.list
'for greater ease of handling UDTs.

'Flags for type signature flags
const TYPE_OPTIONAL = 1
const TYPE_BYREF = 2
const TYPE_BYVAL = 4
const TYPE_FILEHANDLE = 8
