$let DEBUG = 0
'$include: '../common/util.bi'
'$include: '../common/type.bi'
'$include: '../common/ast.bi'
'$include: '../common/htable.bi'
'$include: '../common/sif.bi'


'We expect exactly two arguments, an input file and output file
if _commandcount <> 2 then
    print "Usage: " + command$(0) + " <input file> <output file>"
    print "65 parser: converts source code to a SIF file."
    print "In almost all cases you don't want to run this program directly; you want to run 65 instead"
    system
end if
inputfile$ = command$(1)
outputfile$ = command$(2)

on error goto file_error
open inputfile$ for input as #1
on error goto generic_error

ast_init
root = ps_block
sif_write outputfile$, root
cleanup
system

file_error:
    fatalerror inputfile$ + ": Does not exist or inaccessible."

'$include: '../common/util.bm'


'$include: '../common/type.bm'
'$include: '../common/ast.bm'
'$include: '../common/htable.bm'
'$include: '../common/sif.bm'

