'$include: '../../common/util.bi'
'$include: '../../common/type.bi'
'$include: '../../common/ast.bi'
'$include: '../../common/htable.bi'
'$include: '../../common/sif.bi'

if _commandcount <> 2 then
    print "Usage: " + command$(0) + " <input file> <output file>"
    print "65 target backend: prints out program content is a human readable fashion."
    print "In almost all cases you don't want to run this program directly; you want to run 65 instead"
    system
end if
inputfile$ = command$(1)
outputfile$ = command$(2)

open outputfile$ for output as #1
root = sif_read(inputfile$)
print #1, "Table of identifiers:"
htable_dump
print #1,
print #1, "Function type signatures:"
type_dump_functions
print #1,
print #1, "Table of constants:"
ast_dump_constants
print #1,
print #1, "Program:"
ast_dump_pretty root, 0

cleanup
system

'$include: '../../common/util.bm'

sub type_dump_functions
    for i = 1 to htable.elements
        typ = htable_entries(i).typ
        if typ = HE_FUNCTION or typ = HE_INFIX or typ = HE_PREFIX then
            sig_index = htable_entries(i).v1
            do
                print #1, htable_names(i); " "; type_human_readable$(type_sig_return(sig_index)); " (";
                for i = 1 to type_sig_numargs(sig_index)
                    flags = type_sig_argflags(sig_index, i)
                    if flags and TYPE_BYREF then print "BYREF ";
                    if flags and TYPE_BYVAL then print "BYVAL ";
                    if flags and TYPE_REQUIRED = 0 then print "OPTION ";
                    print type_human_readable$(type_sig_argtype(sig_index, i));
                    if i <> type_sig_numargs(sig_index) then print ", ";
                next i
                sig_index = type_signatures(sig_index).succ
            loop while sig_index <> 0
            print #1, ")"
        end if
    next i
end sub

sub htable_dump
    print #1, " ID          Name     Typ     v1     v2     v3"
    for i = 1 to htable.elements
        print #1, using "###    \            \ ###    ###    ###    ###"; i; htable_names(i); htable_entries(i).typ,htable_entries(i).v1; htable_entries(i).v2; htable_entries(i).v3
    next i
end sub

sub ast_dump_pretty(root, indent_level)
    indent$ = space$(indent_level * 4)
    if ast_nodes(root).typ = 0 then
        fatalerror "Node" + str$(root) + " is invalid"
    end if
    select case ast_nodes(root).typ
    case AST_ASSIGN
        print #1, htable_names(ast_nodes(root).ref); " = ";
        ast_dump_pretty cvl(ast_children(root)), 0
    case AST_IF
        print #1, "IF ";
        ast_dump_pretty ast_get_child(root, 1), 0
        print #1, " THEN ";
        if ast_nodes(ast_get_child(root, 2)).typ = AST_BLOCK then
            print #1,
            ast_dump_pretty ast_get_child(root, 2), indent_level + 1
            if ast_num_children(root) > 2 then
                print #1, indent$; "ELSE"
                ast_dump_pretty ast_get_child(root, 3), indent_level + 1
            end if
            print #1, indent$; "END IF";
        else
            ast_dump_pretty ast_get_child(root, 2), 0
        end if
    case AST_DO_PRE
        print #1, indent$; "DO WHILE ";
        ast_dump_pretty ast_get_child(root, 1), 0
        print #1,
        ast_dump_pretty ast_get_child(root, 2), indent_level + 1
        print #1, indent$; "LOOP";
    case AST_DO_POST
        print #1, indent$; "DO"
        ast_dump_pretty ast_get_child(root, 2), indent_level + 1
        print #1, indent$; "LOOP WHILE ";
        ast_dump_pretty ast_get_child(root, 1), 0
    case AST_FOR
        print #1, "FOR ";
        print #1, htable_names(ast_nodes(root).ref); " = ";
        ast_dump_pretty ast_get_child(root, 1), 0
        print #1, " TO ";
        ast_dump_pretty ast_get_child(root, 2), 0
        print #1, " STEP ";
        ast_dump_pretty ast_get_child(root, 3), 0
        print #1,
        ast_dump_pretty ast_get_child(root,  4), indent_level + 1
        print #1, indent$; "NEXT "; htable_names(ast_nodes(root).ref);
    case AST_SELECT
        print #1, indent$; "SELECT CASE ";
        ast_dump_pretty ast_get_child(root, 1), 0
        print #1,
        for i = 2 to ast_num_children(root) step 2
            print #1, indent$; "CASE ";
            ast_dump_pretty ast_get_child(root, i), 0
            print #1,
            ast_dump_pretty ast_get_child(root, i + 1), indent_level + 1
        next i
        print #1, indent$; "END SELECT";
    case AST_CALL
        print #1, "call(";
        print #1, htable_names(ast_nodes(root).ref);
        if len(ast_children(root)) then print #1, ", ";
        for i = 1 to ast_num_children(root)
            ast_dump_pretty ast_get_child(root, i), 0
            if i <> ast_num_children(root) then print #1, ", ";
        next i
        print #1, ")";
    case AST_CONSTANT
        if type_of_constant(root) = TYPE_STRING then
            print #1, chr$(34); ast_constants(ast_nodes(root).ref); chr$(34);
        else
            print #1, ast_constants(ast_nodes(root).ref);
        end if
    case AST_BLOCK
        for i = 1 to ast_num_children(root)
            print #1, indent$;
            ast_dump_pretty ast_get_child(root, i), indent_level
            print #1,
        next i
    case AST_VAR
        print #1, "var("; htable_names(ast_nodes(root).ref); ")";
    case AST_CAST
        print #1, "cast("; type_human_readable$(type_of_cast(root)); ", ";
        ast_dump_pretty ast_get_child(root, 1), 0
        print #1, ")";
    end select
end sub

sub ast_dump_constants
    print #1, " ID    Type      Value"
    for i = 1 to ast_last_constant
        print #1, using "###    &    &"; i; type_human_readable(ast_constant_types(i)); ast_constants(i)
    next i
end sub

'$include: '../../common/type.bm'
'$include: '../../common/ast.bm'
'$include: '../../common/htable.bm'
'$include: '../../common/sif.bm'
