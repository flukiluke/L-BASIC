'$include: '../../common/util.bi'
'$include: '../../common/type.bi'
'$include: '../../common/ast.bi'
'$include: '../../common/htable.bi'
'$include: '../../common/sif.bi'
'$include: '../../../build/token_data.bi'

' Allow two parameters to comply with the calling format used by other targets
' (this one is special because there's no output file)
if _commandcount > 2 or _commandcount < 1 then
    print "Usage: " + command$(0) + " <input file>"
    print "65 target backend: runs program immediately"
    print "In almost all cases you don't want to run this program directly; you want to run 65 instead"
    system
end if

inputfile$ = command$(1)
root = sif_read(inputfile$)

type value_t
    t as long
    n as _float
    s as string
end type

'Since we only have one scope for now, the stack is static in size
redim shared stack(ast_last_var_index) as value_t
dim shared stack_last as long

dim dummy_result as value_t
on error goto runtime_error
eval root, dummy_result
system

runtime_error:
if err = 6 then
    print "Overflow"
    system
end if
'Error falls through to generic_error otherwise
'$include: '../../common/util.bm'

sub eval(node, result as value_t)
    ref = ast_nodes(node).ref
    select case ast_nodes(node).typ
    case AST_ASSIGN
        do_assign node
    case AST_IF
        print "Conditional; assuming true"
        eval ast_get_child(node, 2), result
    case AST_DO_PRE
        print "DO WHILE; executing once"
        eval ast_get_child(node, 2), result
    case AST_DO_POST
        print "LOOP WHILE; executing once"
        eval ast_get_child(node, 2), result
    case AST_FOR
        print "FOR; skipping"
    case AST_SELECT
        print "SELECT; skipping"
    case AST_CALL
        do_call node, result
    case AST_CONSTANT
        result.t = ast_constant_types(ref)
        if result.t = TYPE_STRING then result.s = ast_constants(ref) else result.n = val(ast_constants(ref))
    case AST_BLOCK
        for i = 1 to ast_num_children(node)
            eval ast_get_child(node, i), result
        next i
    case AST_VAR
        sp = var_stack_pos(ref)
        result.s = stack(sp).s
        result.n = stack(sp).n
    case AST_CAST
        do_cast node, result
    end select
end sub

sub do_cast(node, result as value_t)
    eval ast_get_child(node, 1), result
    result.t = ast_nodes(node).ref
    enforce_type result
end sub

sub do_assign(node)
    dim rvalue as value_t
    eval ast_get_child(node, 1), rvalue
    sp = var_stack_pos(ast_nodes(node).ref)
    stack(sp).t = type_of_var(node)
    if type_of_var(node) = TYPE_STRING then
        stack(sp).s = rvalue.s
    else
        stack(sp).n = rvalue.n
    end if
end sub

sub enforce_type(result as value_t)
    select case result.t
    case TYPE_INTEGER
        result.n = cint(result.n)
    case TYPE_LONG
        result.n = clng(result.n)
    case TYPE_INTEGER64
        result.n = _round(result.n)
    case TYPE_SINGLE
        result.n = csng(result.n)
    case TYPE_DOUBLE
        result.n = cdbl(result.n)
    case TYPE_QUAD, TYPE_STRING
        'Nothing to do here
    end select
end sub

function var_stack_pos(var)
    var_stack_pos = htable_entries(var).v2
end function

sub do_call(node, result as value_t)
    dim v1 as value_t
    dim v2 as value_t
    result.t = type_of_call(node)
    select case ast_nodes(node).ref
    case TOK_PRINT
        eval ast_get_child(node, 1), v1
        if v1.t = TYPE_STRING then print v1.s else print v1.n
    case TOK_PLUS
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        if result.t = TYPE_STRING then result.s = v1.s + v2.s else result.n = v1.n + v2.n
    case TOK_DASH
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n - v2.n
    case TOK_STAR
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n * v2.n
    case TOK_SLASH
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n / v2.n
    case TOK_POWER
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n ^ v2.n
    case TOK_NOT
        eval ast_get_child(node, 1), v1
        result.n = not v1.n
    case TOK_AND
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n and v2.n
    case TOK_OR
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n or v2.n
    case TOK_XOR
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n xor v2.n
    case TOK_EQV
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n eqv v2.n
    case TOK_IMP
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n imp v2.n
    case TOK_EQUALS
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        if result.t = TYPE_STRING then result.n = v1.s = v2.s else result.n = v1.n = v2.n
    case TOK_CMP_LT
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n < v2.n
    case TOK_CMP_GT
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n > v2.n
    case TOK_CMP_LTEQ
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n <= v2.n
    case TOK_CMP_GTEQ
        eval ast_get_child(node, 1), v1
        eval ast_get_child(node, 2), v2
        result.n = v1.n >= v2.n
    end select
    enforce_type result
end sub

'$include: '../../common/type.bm'
'$include: '../../common/ast.bm'
'$include: '../../common/htable.bm'
'$include: '../../common/sif.bm'
