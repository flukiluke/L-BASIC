'tokgen - Token generator
'Generate declarations of tokens and the TS's that map to them.
'
'Don't worry, this one's simpler than tsgen :)
'The next layer above TS's are tokens, which are actual language keywords and elements.
'
'The input file is considered a list of tokens, one per line. These are declared as the token name
'uppercased and prefixed with TOK_.
'Optionally, the token may be followed by a space and a TS name, to indicate that that TS maps directly
'to that token.
'
'Blank lines are ignored, comments are given by # on their own line.
$console:only
_dest _console
on error goto ehandler

if _commandcount <> 3 then
    print "Usage: "; command$(0); " "; "<input file> <token output file> <mapping output file>"
    system 1
end if

if not _fileexists(command$(1)) then
    print command$(0); ": Cannot open "; command$(1)
    system 1
end if

open command$(1) for input as #1
open command$(2) for output as #2
open command$(3) for output as #3

do while not eof(1)
    linenum = linenum + 1
    line input #1, l$
    l$ = ltrim$(rtrim$(l$))
    if not (left$(l$, 1) = "#" or l$ = "") then
        if instr(l$, " ") then
        tsname$ = mid$(l$, instr(l$, " ") + 1)
        l$ = left$(l$, instr(l$, " ") - 1)
        print #3, "ts_mappings&(TS_" + ucase$(tsname$) + ") = TOK_" + ucase$(l$)
        end if
        print #2, "CONST TOK_" + ucase$(l$) + " =" + str$(toknum&)
        toknum& = toknum& + 1
    end if
loop        
system

ehandler:
    print err; _errorline
    system 1

fatalerror:
    print command$(0); ": "; command$(1); ":"; ltrim$(str$(linenum)); ": "; e$
    system 1
    return
