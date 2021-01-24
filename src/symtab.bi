'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'symtab.bi - Declarations for symbol table

type symtab_entry_t
    identifier as string
    typ as long
    'the vn are generic parameters whose meaning depends on typ.
    v1 as long
    v2 as long
    v3 as long
    v4 as long
end type

'A generic entry. No vn parameters are used.
const SYM_GENERIC = 1
'A function with infix notation.
'v1 -> reference to the type signature
'v2 -> binding power (controls precedence)
'v3 -> associativity (1/0 = right/left)
const SYM_INFIX = 2
'A function with prefix notation (and parentheses are not required)
'v1 -> reference to the type signature
'v2 -> binding power (controls precedence)
const SYM_PREFIX = 3
'A variable.
'v1 -> the data type
'v2 -> index in this scope (in each scope, first variable has 1, second has 2 etc.)
'v3 -> constant (cannot be reassigned)
const SYM_VARIABLE = 4
'A function (subs too!)
'v1 -> reference to the type signature
const SYM_FUNCTION = 5
'A line number or label. Labels have the : removed.
'v1 -> AST node that is labelled.
'v2 -> Label has been located (if false, label has only been referenced)
const SYM_LABEL = 6
'Both internal types and UDTs
'v1 -> Fixed size of data type
'v2 -> One of SYM_TYPE_*, see below
'v3 -> If SYM_TYPE_ARRAY, type of the array element
'v4 -> If SYM_TYPE_ARRAY, number of dimensions
const SYM_TYPE = 7
'An element of a udt, stored with the name "udt_name.element_name"
'v1 -> the data type
'v2 -> position of element in udt (first is 0, then incrementing by the fixed size of previous values)
const SYM_UDT_ELEMENT = 8
'A metacommand, stored with its characteristic leading $ in the name
const SYM_META = 9

'Further categorisation of SYM_TYPE
'e.g. INTEGER, STRING
const SYM_TYPE_INTERNAL = 0
'Stored as the UDT name
const SYM_TYPE_UDT = 1
'Stored as the element type followed by parentheses and the number of dimensions, e.g. INTEGER(2)
const SYM_TYPE_ARRAY = 2

dim shared symtab(1000) as symtab_entry_t
dim shared symtab_last_entry
dim shared symtab_map(1750)

'The symtab optionally supports transactions; calling symtab_rollback will
'remove all items added since the last call to symtab_commit.
dim shared symtab_last_commit_id
