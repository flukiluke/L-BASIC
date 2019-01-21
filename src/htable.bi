' Hash table entry: _OFFSET, LONG, LONG
$IF 64BIT THEN
    CONST HTABLE_KEY_OFFSET = 0
    CONST HTABLE_KEYLEN_OFFSET = 8
    CONST HTABLE_DATA_OFFSET = 12
    CONST HTABLE_ENTRY_SIZE = 16
$ELSE
    CONST HTABLE_KEY_OFFSET = 0
    CONST HTABLE_KEYLEN_OFFSET = 4
    CONST HTABLE_DATA_OFFSET = 8
    CONST HTABLE_ENTRY_SIZE = 12
$END IF

TYPE htable_t
    table AS _MEM
    buckets AS LONG
    elements AS LONG
END TYPE

TYPE hentry_t
    id AS LONG
    typ AS LONG
    'The vn are generic parameters whose meaning depends on typ.
    v1 AS LONG
    v2 AS LONG
END TYPE

'A generic entry. No vn parameters are used.
CONST HE_GENERIC = 1
'A function with infix notation.
'v1 -> binding power (controls precedence)
'v2 -> associativity (1/0 = right/left)
CONST HE_INFIX = 2
'A function with prefix notation (and parentheses are not required)
'v1 -> binding power (controls precedence)
CONST HE_PREFIX = 3
'A variable.
'v1 -> the data type as far as can be determined
CONST HE_VARIABLE = 4

DIM SHARED htable AS htable_t
DIM SHARED htable_entries(100) AS hentry_t
DIM SHARED htable_names(100) AS STRING

htable_create htable, 127
