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
END TYPE

DIM SHARED htable AS htable_t
DIM SHARED htable_entries(100) AS hentry_t
DIM SHARED htable_names(100) AS STRING

htable_create htable, 127
