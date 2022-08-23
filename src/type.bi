'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'type.bi - Declarations for type management routines

'type_signatures() is a linked list.
'A function token points to a single type_signature_t, and that element may point to
'alternative signatures for that function.  This allows us to support declaring a
'function multiple times with different signatures by chaining each declaration's
'signature together.

'type_signature_t.sig is an mkl$-encoded string. Its format is mkl$(return type) +
'mkl$(argument 1 type) + mkl$(argument 1 flags) + mkl$(argument 2 type) +
'mkl$(argument 2 flags) + ...
'For each flag, one or more TYPE_* flags as defined below are set.
'Don't access things directly, use the type_sig_* functions.
type type_signature_t
    sig as string
    succ as long 'Can't call this "next" :(
end type

redim shared type_signatures(10) as type_signature_t
dim shared type_last_signature as long

'Note: constants for actual data types (TYPE_LONG etc.) are defined in tokens.list
'for greater ease of handling UDTs.

'Flags for type signature flags.
'This argument can be omitted.
const TYPE_OPTIONAL = 1
'This argument is passed by reference *and* cannot be an expression, it must be a
'reference to an lvalue. Used when the callee passes information back to the caller
'through this argument.
const TYPE_BYREF = 2
'This argument is passed by value. The callee does not expect modifications to pass
'back to the caller.
const TYPE_BYVAL = 4
'Note: BYVAL and BYREF are not entirely opposite. BYVAL is purely a description of the
'calling convention, i.e. values are passed directly not as a reference. BYREF requires
'the call to use a reference, but also enforces a requirement on the kind of value the
'caller supplies. The default (neither BYREF not BYVAL) is in between: values are passed
'by reference, but may be non-lvalues.

'This argument can have a leading # to indicate a file handle
const TYPE_FILEHANDLE = 8
'This argument is a literal token and the type refers to that token id
const TYPE_TOKEN = 16
'This argument is only a syntax element and should not have an ast node generated for it
const TYPE_SYNTAX_ONLY = 32
'This argument needs to be matched by textual name. This allows parameters
'that have meaning only in a specific context, like LINE's B/BF. The argument 'type'
'is the index of a constant that contains a | separated list of allowable values.
const TYPE_CONTEXTUAL = 64
