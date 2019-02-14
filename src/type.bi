'A linked list to hold function type signatures
'The first element is the return type, subsequent elements are arguments.
type type_signature_t
    value as long
    flags as long
    succ as long 'Can't call this "next" :(
end type

redim shared type_signatures(10) as type_signature_t
dim shared type_last_signature as long

'Variable data types
'This element is not typed and attempting to give it a type in as error
const TYPE_NONE = 0
'This element is typed, but haven't restricted its type at all
const TYPE_ANY = 1
'Restricted to be numeric, but no further detail
const TYPE_NUMBER = 2
'One byte
const TYPE_BYTE = 3
'Two bytes
const TYPE_INTEGER = 4
'Four bytes
const TYPE_LONG = 5
'Eight bytes
const TYPE_INTEGER64 = 6
'Unsigned versions of above
const TYPE_UBYTE = 7
const TYPE_UINTEGER = 8
const TYPE_ULONG = 9
const TYPE_UINTEGER64 = 10
'Floating point numbers of various size
const TYPE_SINGLE = 11
const TYPE_DOUBLE = 12
const TYPE_FLOAT = 13
'Everyone's favourite non-numeric type
const TYPE_STRING = 14

'Flags for type_signature_t.flags
const TYPE_REQUIRED = 1
