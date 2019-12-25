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
    typ as long
    ' Treat this as a union
    f as double
    i as long
    s as string
end type

exec root
system

'$include: '../../common/util.bm'

sub exec(root)
    select case ast_nodes(root).typ
    case AST_BLOCK
        for i = 1 to ast_num_children(root)
            exec ast_get_child(root, i)
        next i
    case AST_ASSIGN
        print "Assignment"
    case AST_CALL
        do_call root
    case AST_IF
        print "Conditional; assuming true"
        exec ast_get_child(root, 2)
    case AST_DO_PRE
        print "DO WHILE; executing once"
        exec ast_get_child(root, 2)
    case AST_DO_POST
        print "LOOP WHILE; executing once"
        exec ast_get_child(root, 2)
    case AST_FOR
        print "FOR; skipping"
    case AST_SELECT
        print "SELECT; skipping"
    end select
end sub

sub do_call(node)
    dim v1 as value_t
    select case ast_nodes(node).ref
    case TOK_PRINT
        eval ast_get_child(node, 1), v1
        sub_print v1
    end select
end sub

sub eval(node, result as value_t)
    ref = ast_nodes(node).ref
    select case ast_nodes(node).typ
    case AST_CONSTANT
        result.typ = ast_constant_types(ref)
        select case result.typ
        case TYPE_INTEGER
            result.i = val(ast_constants(ref))
        case TYPE_SINGLE
            result.f = val(ast_constants(ref))
        case TYPE_STRING
            result.s = ast_constants(ref)
        case TYPE_OFFSET, TYPE_BIGINTEGER
            print "Unimplemented"
        case else
            fatalerror "Evaluation of non-concrete type"
        end select
    end select
end sub

sub sub_print(v as value_t)
    select case v.typ
    case TYPE_INTEGER
        print v.i
    case TYPE_SINGLE
        print v.f
    case TYPE_STRING
        print v.s
    end select
end sub

'$include: '../../common/type.bm'
'$include: '../../common/ast.bm'
'$include: '../../common/htable.bm'
'$include: '../../common/sif.bm'
