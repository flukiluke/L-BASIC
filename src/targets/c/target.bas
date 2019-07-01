'$include: '../../common/util.bi'
'$include: '../../common/type.bi'
'$include: '../../common/ast.bi'
'$include: '../../common/htable.bi'
'$include: '../../common/sif.bi'

if _commandcount <> 2 then
    print "Usage: " + command$(0) + " <input file> <output file>"
    print "65 target backend: compiles to native binaries via a C compiler"
    print "In almost all cases you don't want to run this program directly; you want to run 65 instead"
    system
end if
inputfile$ = command$(1)
outputfile$ = command$(2)

root = sif_read(inputfile$)





cleanup
system

'$include: '../../common/util.bm'

'$include: '../../common/type.bm'
'$include: '../../common/ast.bm'
'$include: '../../common/htable.bm'
'$include: '../../common/sif.bm'
