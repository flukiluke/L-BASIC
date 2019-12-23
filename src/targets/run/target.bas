'$include: '../../common/util.bi'
'$include: '../../common/type.bi'
'$include: '../../common/ast.bi'
'$include: '../../common/htable.bi'
'$include: '../../common/sif.bi'

if _commandcount <> 1 then
    print "Usage: " + command$(0) + " <input file>"
    print "65 target backend: runs program immediately"
    print "In almost all cases you don't want to run this program directly; you want to run 65 instead"
    system
end if

inputfile$ = command$(1)
root = sif_read(inputfile$)

exec root

'$include: '../../common/util.bm'

sub exec(root)
    select case ast_nodes(root).typ
    case AST_BLOCK
        for i = 1 to ast_num_children(root)
            exec ast_get_child(root, i)
        next i
    case AST_CALL
        print ast_nodes(root).ref
    end select
end sub

'$include: '../../common/type.bm'
'$include: '../../common/ast.bm'
'$include: '../../common/htable.bm'
'$include: '../../common/sif.bm'
