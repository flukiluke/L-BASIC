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

'All numbers are numeric; offsets are numeric but not a number (see type_can_cast)
const TYPE_NUMERIC = 2
const TYPE_NUMBER = 3

'A machine-native integer, guaranteed to be at least 32 bits wide
const TYPE_INTEGER = 4
'Note that LONG is just an alias for INTEGER
const TYPE_LONG = 4

'An arbitrary-width integer
const TYPE_BIGINTEGER = 5

'Not yet used, but intended for pointers
const TYPE_OFFSET = 6

'A floating-point number
const TYPE_SINGLE = 7
'Note that DOUBLE is just an alias for SINGLE
const TYPE_DOUBLE = 7

'Everyone's favourite non-numeric type
const TYPE_STRING = 8

'Flags for type_signature_t.flags
const TYPE_REQUIRED = 1
