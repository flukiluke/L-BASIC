'Copyright Luke Ceddia
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

$macro: @@->identifier | symtab(@1).identifier
$macro: @@-identifier | @1.identifier
$macro: @@->stype | symtab(@1).typ
$macro: @@-stype | @1.typ
$macro: @@->sig | symtab(@1).v1
$macro: @@-sig | @1.v1
$macro: @@->precedence | symtab(@1).v2
$macro: @@-precedence | @1.v2
$macro: @@->associativity | symtab(@1).v3
$macro: @@-associativity | @1.v3
$macro: @@->type | symtab(@1).v1
$macro: @@-type | @1.v1
$macro: @@->stack_offset | symtab(@1).v2
$macro: @@-stack_offset | @1.v2
$macro: @@->vflags | symtab(@1).v3
$macro: @@-vflags | @1.v3
$macro: @@->func_kind | symtab(@1).v2
$macro: @@-func_kind | @1.v2
$macro: @@->proc_node | symtab(@1).v3
$macro: @@-proc_node | @1.v3
$macro: @@->stack_size | symtab(@1).v4
$macro: @@-stack_size | @1.v4
$macro: @@->label_node | symtab(@1).v1
$macro: @@-label_node | @1.v1
$macro: @@->label_found | symtab(@1).v2
$macro: @@-label_found | @1.v2
$macro: @@->fixed_size | symtab(@1).v1
$macro: @@-fixed_size | @1.v1
$macro: @@->tflags | symtab(@1).v2
$macro: @@-tflags | @1.v2
$macro: @@->array_type | symtab(@1).v3
$macro: @@-array_type | @1.v3
$macro: @@->array_dims | symtab(@1).v4
$macro: @@-array_dims | @1.v4
$macro: @@->udt_element_offset | symtab(@1).v2
$macro: @@-udt_element_offset | @1.v2


'A generic entry. No vn parameters are used.
const SYM_GENERIC = 1
'A function with infix notation.
'v1 ->sig | reference to the type signature
'v2 ->precedence | binding power (controls precedence)
'v3 ->associativity | associativity (1/0 = right/left)
const SYM_INFIX = 2
'A function with prefix notation (and parentheses are not required)
'v1 ->sig | reference to the type signature
'v2 ->precedence | binding power (controls precedence)
const SYM_PREFIX = 3
'A variable.
'v1 ->type | the data type
'v2 ->stack_offset | stack offset in the scope. Simple variables and references each take 
'up 1 slot, arrays and UDTs take up multiple.
'v3 ->vflags | various SYM_VARIABLE_* flags
const SYM_VARIABLE = 4
'A function (subs too!)
'v1 ->sig | reference to the type signature
'v2 ->func_kind | One of SYM_FUNCTION_*, see below
'v3 ->proc_node | If SYM_FUNCTION_USER, the AST_PROCEDURE holding the executable code
'v4 ->stack_size | IF SYM_FUNCTION_USER, the stack frame size required to hold locals,
'including arguments
const SYM_FUNCTION = 5
'A line number or label. Labels have the : removed.
'v1 ->label_node | AST node that is labelled.
'v2 ->label_found | Label has been located (if false, label has only been referenced)
const SYM_LABEL = 6
'Both internal types and UDTs
'v1 ->fixed_size | Fixed size of data type
'v2 ->tflags | One of SYM_TYPE_*, see below
'v3 ->array_type | If SYM_TYPE_ARRAY, type of the array element
'v4 ->array_dims | If SYM_TYPE_ARRAY, number of dimensions
const SYM_TYPE = 7
'An element of a udt, stored with the name "udt_name.element_name"
'v1 ->type | the data type
'v2 ->udt_element_offset | position of element in udt (first is 0, then incrementing by the fixed size of previous values)
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

'Settings for SYM_VARIABLE
'This variable is a constant and cannot be reassigned
const SYM_VARIABLE_CONST = 1
'This variable must be dereferenced before access (to support pass-by-reference)
const SYM_VARIABLE_DEREF = 2
'This variable is stored in the main program's stack frame, not the frame of any scoping function (SHARED or STATIC)
const SYM_VARIABLE_MAINFRAME = 4

'Further categorisation of SYM_FUNCTION
'Functions that are handled directly based on their name
const SYM_FUNCTION_INTRINSIC = 1
'SUBs and FUNCTIONs defined by the processed source code
const SYM_FUNCTION_USER = 2

dim shared symtab(1000) as symtab_entry_t
dim shared symtab_last_entry
dim shared symtab_map(1750)

'The symtab optionally supports transactions; calling symtab_rollback will
'remove all items added since the last call to symtab_commit.
'WARNING: transaction rollbacks only undo adding entries. Changes to entries
'are always immediately permanent.
dim shared symtab_last_commit_id
