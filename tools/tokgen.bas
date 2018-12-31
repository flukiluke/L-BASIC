'tokgen - Token Generator & Registerer
'Create TOK_ definitions and register them in the lookup table
'
'Nearly every element of the program can be expressed as a token, which is identified with the TOK_
'constant ID. The htable system also has stores all tokens by name and can tell you their ID.
'Once you have the ID you can access the extra data defined for that token in htable_entries(). See
'htable.bi for an explanation of that data.
'
'Note that because the ID's are assigned by the htable functions in the order items are registered,
'any manual edits to the registration code will likely cause it to be out of sync with the TOK_ definitions.
'Re-run this generation program instead.
'
'The input file has one line per token definition, consisting of two or more fields separated by spaces.
'The first field is the token type, corresponding to a HE_ constant defined in htable.bi (without the HE_
' prefix) or "LITERAL" which does not get an entry in the htable.
'The next field is the the token itself. If the literal representation of the token needs to differ from
'the name used in the constant (such as for symbols), a "safe" representation can be given in parentheses
'immediately after the name. Example: "+(plus)". There must be no space between anywhere in the field.
'Depending on the token type, there may be 0 or more data fields, often refered to as vn (v1, v2, etc.).
'The format and meaning of these is specific to the token type.
'
'Blank lines are ignored. Comments may be given with # on their own line.

$console:only
_dest _console
on error goto ehandler
deflng a-z

if _commandcount <> 3 then
    print "Usage: "; command$(0); " "; "<input file> <const file> <registration file>"
    system 1
end if

if not _fileexists(command$(1)) then
    print command$(0); ": Cannot open "; command$(1)
    system 1
end if

open command$(1) for input as #1
open command$(2) for output as #2
open command$(3) for output as #3

redim shared parts$(0)
redim shared previous$(0)
dim shared linenum

print #3, "dim registration_entry as hentry_t"
do while not eof(1)
    linenum = linenum + 1
    line input #1, l$
    l$ = ucase$(ltrim$(rtrim$(l$)))
    if left$(l$, 1) = "#" or l$ = "" then _continue
    split l$
    if ubound(parts$) > ubound(previous$) then redim _preserve previous$(ubound(parts$))

    altname_start = instr(parts$(1), "(")
    if altname_start then
        tokname$ = mid$(parts$(1), altname_start + 1, len(parts$(1)) - altname_start - 1)
        toksym$ = left$(parts$(1), altname_start - 1)
    else
        tokname$ = parts$(1)
        toksym$ = tokname$
    end if
    if parts$(0) = "LITERAL" then
        literal_toknum = literal_toknum - 1
        print #2, "CONST TOK_" + tokname$ + " =" + str$(literal_toknum)
        _continue
    end if
    toknum = toknum + 1
    print #2, "CONST TOK_" + tokname$ + " =" + str$(toknum)
    select case parts$(0)
    case "GENERIC"
        assertsize  2
        if previous$(0) <> "GENERIC" then print #3, "registration_entry.typ = HE_GENERIC"
    case "PREFIX"
        assertsize 3
        if previous$(0) <> "PREFIX" then print #3, "registration_entry.typ = HE_PREFIX"
        if previous$(2) <> parts$(2) then print #3, "registration_entry.v1 = "; parts$(2)
    case "INFIX"
        assertsize 4
        if previous$(0) <> "INFIX" then print #3, "registration_entry.typ = HE_INFIX"
        if previous$(2) <> parts$(2) then print #3, "registration_entry.v1 = "; parts$(2)
        if previous$(3) <> parts$(3) then
            if parts$(3) = "right" then print #3, "registration_entry.v2 = 1" else print #3, "registration_entry.v2 = 0"
        end if
    case else
        fatalerror "Unknown token type " + parts$(0)
    end select
        for i = 0 to ubound(parts$)
            previous$(i) = parts$(i)
        next i
        print #3, "htable_add_hentry " + chr$(34) + toksym$ + chr$(34) + ", registration_entry"
loop
system

ehandler:
    print "Error"; err; _errorline
    system 1

sub split(in$)
    redim parts$(0)
    start = 1
    do
        sp = instr(start, in$, " ")
        if sp = start then
            start = start + 1
            _continue
        end if
        if sp then
            parts$(ubound(parts$)) = mid$(in$, start, sp - start)
            start = sp + 1
            redim _preserve parts$(ubound(parts$) + 1)
        else
            parts$(ubound(parts$)) = mid$(in$, start)
            exit sub
        end if
    loop
end sub

sub assertsize(expected)
    if ubound(parts$) <> expected - 1 then
        fatalerror "Expected" + str$(expected) + " components, got" + str$(ubound(parts$) + 1)
    end if
end sub

sub fatalerror(msg$)
    print command$(0); ": "; command$(1); ":"; ltrim$(str$(linenum)); ": "; msg$
    system 1
end sub
