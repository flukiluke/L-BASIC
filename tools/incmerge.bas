'incmerge - Include Merger
'Merge a .bas file and all its $include files into one.

$console:only
_dest _console
deflng a-z
on error goto ehandler

if _commandcount <> 2 then
    print "Usage: "; command$(0); " "; "<input file> <output file>"
    system 1
end if

open command$(2) for output as #1
process command$(1)
close #1

system

ehandler:
    print err; _errorline
    system 1

sub process (filename$)
    fh = freefile
    print "Now in "; _cwd$
    print "Processing {"; filename$; "}"
    open filename$ for binary as #fh
    olddir$ = _cwd$
    chdir dirname$(filename$)
    do
        line input #fh, l$
        if instr(ltrim$(l$), "'$include") = 1 then
            t$ = ltrim$(l$)
            q1 = instr(2, t$, "'")
            q2 = instr(q1 + 1, t$, "'")
            process mid$(t$, q1 + 1, q2 - q1 - 1)
        else
            print #1, l$
        end if
    loop until eof(fh)
    close #fh
    chdir olddir$
end sub

function dirname$(filename$)
    slash = _instrrev(filename$, "/")
    if slash = 0 then
        dirname$ = "."
    else
        dirname$ = left$(filename$, slash - 1)
    end if
end function
