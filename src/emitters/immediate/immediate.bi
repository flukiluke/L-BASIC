type imm_value_t
    n as _float
    s as string
end type

'Since we only have one scope for now, the stack is static in size
dim shared imm_stack(0) as imm_value_t
dim shared imm_stack_last

'Instead of executing the next statement, execution should begin at
'this node if it is > 0 (used to support GOTO)
dim shared imm_jump_path$
