'$include: '../../common/util.bi'
'$include: '../../common/type.bi'
'$include: '../../common/ast.bi'
'$include: '../../common/htable.bi'
'$include: '../../common/sif.bi'
'$include: 'writer.bi'

if _commandcount <> 2 then
    print "Usage: " + command$(0) + " <input file> <output file>"
    print "65 target backend: compiles to native binaries via a C compiler"
    print "In almost all cases you don't want to run this program directly; you want to run 65 instead"
    system
end if
inputfile$ = command$(1)
outputfile$ = command$(2)

root = sif_read(inputfile$)

dim shared Output_handle
' For these early stages of development, the "output" file is just C code
Output_handle = freefile
open outputfile$ for output as #Output_handle

generate_variable_declarations

process_node root




cleanup
system

'$include: '../../common/util.bm'

sub generate_variable_declarations
    for i = 1 to htable.elements
        if htable_entries(i).typ = HE_VARIABLE then
            write_vardec_local mk_var_mangle$(htable_names(i)), mk_ctyp$(htable_entries(i).v1)
        end if
    next i
end sub

sub process_node(node)
    select case ast_nodes(node).typ
    case AST_BLOCK
        for i = 1 to ast_num_children(node)
            process_node ast_get_child(node, i)
        next i
    case AST_ASSIGN
        rhs$ = mk_expr$(ast_get_child(node, 1))
        write_assignment mk_lvalue_ref$(ast_nodes(node).ref), rhs$
    case AST_IF
        write_open_if mk_expr$(ast_get_child(node, 1))
        process_node ast_get_child(node, 2)
        if ast_num_children(node) > 2 then
            write_if_else
            process_node ast_get_child(node, 3)
        end if
        write_close_if
    end select
end sub

function mk_expr$(node)
    select case ast_nodes(node).typ
    case AST_CONSTANT
        if type_of_constant(node) = TYPE_STRING then
            mk_expr$ = chr$(34) + ast_constants(ast_nodes(node).ref) + chr$(34)
        else
            mk_expr$ = ast_constants(ast_nodes(node).ref)
        end if
    case AST_VAR
        mk_expr$ = mk_var_mangle$(htable_names(ast_nodes(node).ref))
    case AST_CALL
        expr$ = writer_call$(mk_call_mangle$(htable_names(ast_nodes(node).ref)))
        for i = 1 to ast_num_children(node)
            expr$ = writer_add_callarg$(expr$, mk_expr$(ast_get_child(node, i)))
        next i
        mk_expr$ = writer_end_call$(expr$)
    end select
end function

function mk_lvalue_ref$(ref)
    mk_lvalue_ref$ = mk_var_mangle$(htable_names(ref))
end function

function mk_var_mangle$(src$)
    mk_var_mangle$ = "b6u" + src$
end function

function mk_ctyp$(typ)
    select case typ
    case TYPE_INTEGER
        mk_ctyp$ = "int"
    case TYPE_BIGINTEGER
        ' This is not a conformant implementation; BIGINTEGER should be
        ' arbitrary-sized integers (using something like GMP).
        mk_ctyp$ = "long int"
    case TYPE_OFFSET
        mk_ctyp$ = "void *"
    case TYPE_SINGLE
        mk_ctyp$ = "double"
    case TYPE_STRING
        mk_ctyp$ = "char *"
    case else
        fatalerror type_human_readable$(typ) + " is unusable here"
    end select
end function

function mk_call_mangle$(src$)
    select case src$
    case "="
        mk_call_mangle$ = "b6aEQUALITY"
    case "+"
        mk_call_mangle$ = "b6aADD"
    case "-"
        mk_call_mangle$ = "b6aSUBTRACT"
    case "*"
        mk_call_mangle$ = "b6aMULTIPLY"
    case "/"
        mk_call_mangle$ = "b6aDIVIDE"
    case else
        mk_call_mangle$ = "b6c" + src$
    end select
end function

'$include: 'writer.bm'
'$include: '../../common/type.bm'
'$include: '../../common/ast.bm'
'$include: '../../common/htable.bm'
'$include: '../../common/sif.bm'
