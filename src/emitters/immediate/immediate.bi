type imm_value_t
    n as _float
    s as string
end type

'Stack holds objects with fixed memory size. Note a single element can
'hold a variable length string, and all UDTs are of fixed size (because
'any variable-size components like arrays are in fact pointers).
'Begins at 1 so we can catch null pointer errors, and so all pointers have
'SGN = 1.
dim shared imm_stack(1) as imm_value_t
dim shared imm_stack_last

'Heap holds dynamically allocated objects i.e. arrays. See heap.bm
'for the allocation strategy. Note that pointers to heap locations are
'always stored as negative values, to distinguish them from stack addresses
'(but are made positive just before heap access, so the array below grows
'in the positive direction). We'd like to grow the array negatively too, but
'that would force a copy on each reallocation which isn't desired.
dim shared imm_heap(1) as imm_value_t
dim shared imm_heap_next_free
const IMM_HEAP_HEADER_SIZE = 2

'Instead of executing the next statement, execution should begin at
'this node if it is > 0 (used to support GOTO)
dim shared imm_jump_path$

'If > 0, an EXIT command is in effect and imm_exit_node is the node to exit
dim shared imm_exit_node

'Allow for input code to use file handles without clashing with internally
'opened files
dim shared imm_filehandle_offset
