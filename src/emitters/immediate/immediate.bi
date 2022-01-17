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

'Used as an offset for stack value access, allowing support for
'stack frames.
dim shared imm_stack_base

'Heap holds dynamically allocated objects i.e. arrays. See heap.bm
'for the allocation strategy. Note that pointers to heap locations are
'always stored as negative values, to distinguish them from stack addresses
'(but are made positive just before heap access, so the array below grows
'in the positive direction). We'd like to grow the array negatively too, but
'that would force a copy on each reallocation which isn't desired.
dim shared imm_heap(1) as imm_value_t
dim shared imm_heap_next_free
const IMM_HEAP_HEADER_SIZE = 2
'some extra values worth tracking
dim shared imm_heap_current_blocks
dim shared imm_heap_max_blocks
dim shared imm_heap_current_bytes
dim shared imm_heap_max_bytes

'Instead of executing the next statement, execution should begin at
'this node if it is > 0 (used to support GOTO)
dim shared imm_jump_path$

'If > 0, an EXIT command is in effect and imm_exit_node is the node to exit
dim shared imm_exit_node

'Allow for input code to use file handles without clashing with internally
'opened files
dim shared imm_filehandle_offset

'When evaluating a SELECT CASE, this holds the base value which is returned
'when AST_SELECT_VALUE is evaluated
dim shared imm_select_value as imm_value_t

'Maintain a eval stack that can be printed for debugger purposes. Each element
'is an ast node
dim shared imm_eval_stack(0)
dim shared imm_eval_stack_last
