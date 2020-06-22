'type_signatures() is a linked list.
'A function token points to a single type_signature_t, and that element may point to alternative signatures for that function.
'This allows us to support declaring a function multiple times with different signatures by chaining each declaration's signature together.

'type_signature_t.sig is an mkl$-encoded string. Its format is mkl$(return type) + mkl$(argument 1 type) + mkl$(argument 1 flags) + mkl$(argument 2 type) + mkl$(argument 2 flags) + ...
'Don't access them directly, use the type_sig_* functions.
type type_signature_t
    sig as string
    succ as long 'Can't call this "next" :(
end type

redim shared type_signatures(10) as type_signature_t
dim shared type_last_signature as long

'Variable data types
'This element is not typed and attempting to give it a type in as error
const TYPE_NONE = 0

'16 bits
const TYPE_INTEGER = 1
'32 bits
const TYPE_LONG = 2
'64 bits
const TYPE_INTEGER64 = 3
'Not yet used, but intended for pointers
const TYPE_OFFSET = 4
'binary32 floating-point
const TYPE_SINGLE = 5
'binary64 floating-point
const TYPE_DOUBLE = 6
'binary128 floating-point
const TYPE_QUAD = 7

'Everyone's favourite non-numeric type
const TYPE_STRING = 8

'Flags for type signature flags
const TYPE_REQUIRED = 1
const TYPE_BYREF = 2
const TYPE_BYVAL = 4
