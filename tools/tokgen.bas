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
'Each line has the following format:
'
'TYPE NAME ARGS FLAGS
'
'TYPE is one of the HE_ constants defined in htable.bi (without the HE_ prefix) or "LITERAL", in which case
'no htable entry is made.
'NAME is the identifier for the token, and will be prefixed with TOK_. If the token contains special characters
'a safe name may be given in parentheses, e.g "+(plus)". If the token is a special character (see below), it
'should be represented as \xx where xx is the ASCII code. There must be no spaces anywhere in this field.
'The ARGS given depend on the TYPE chosen. Each argument correponds to the vn parameters in htable.bi.
'FLAGS is an optional list of modifiers. If present it must begin with a semi-colon. Valid flags:
'  DIRECT: Assume that there is a TS_ of the same name as this token that maps to it.
'  NOSYM: Prefix the token with a pipe "|" character in the htable, preventing it from clashing with other tokens.
'Blank lines are ignored. Comments may be given with # on their own line. Special characters are (); and must
'not appear outside of their described syntactic function.

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
redim shared args$(0)
dim shared linenum

print #3, "dim shared tok_direct(1 to TS_MAX)"
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

    if left$(toksym$, 1) = "\" then '"
        toksym$ = "chr$(" + mid$(toksym$, 2) + ")"
        if instr(parts$(-1), "NOSYM") then toksym$ = chr$(34) + "|" + chr$(34) + "+" + toksym$
    else
        if instr(parts$(-1), "NOSYM") then toksym$ = "|" + toksym$
        toksym$ = chr$(34) + toksym$ + chr$(34)
    end if
    select case parts$(0)
    case "GENERIC"
        assertsize 2
        toknum = toknum + 1
        cur_toknum = toknum
        print #2, "CONST TOK_" + tokname$ + " =" + str$(toknum)
        if previous$(0) <> "GENERIC" then print #3, "registration_entry.typ = HE_GENERIC"
        print #3, "htable_add_hentry " + toksym$ + ", registration_entry"
    case "FUNCTION"
        assertsize_range 3, 4
        toknum = toknum + 1
        cur_toknum = toknum
        print #2, "CONST TOK_" + tokname$ + " =" + str$(toknum)
        if previous$(0) <> "FUNCTION" then print #3, "registration_entry.typ = HE_FUNCTION"
        print #3, "registration_entry.v1 = type_add_signature(TYPE_" + parts$(2) + ")"
        if ubound(parts$) = 3 then
            process_arg_list parts$(3)
        end if
        print #3, "htable_add_hentry " + toksym$ + ", registration_entry"
    case "PREFIX"
        assertsize 5
        toknum = toknum + 1
        cur_toknum = toknum
        print #2, "CONST TOK_" + tokname$ + " =" + str$(toknum)
        if previous$(0) <> "PREFIX" then print #3, "registration_entry.typ = HE_PREFIX"
        print #3, "registration_entry.v1 = type_add_signature(TYPE_" + parts$(3) + ")"
        if previous$(2) <> parts$(2) then print #3, "registration_entry.v2 = "; parts$(2)
        process_arg_list parts$(4)
        print #3, "htable_add_hentry " + toksym$ + ", registration_entry"
    case "INFIX"
        assertsize 6
        toknum = toknum + 1
        cur_toknum = toknum
        print #2, "CONST TOK_" + tokname$ + " =" + str$(toknum)
        if previous$(0) <> "INFIX" then print #3, "registration_entry.typ = HE_INFIX"
        print #3, "registration_entry.v1 = type_add_signature(TYPE_" + parts$(4) + ")"
        if previous$(2) <> parts$(2) then print #3, "registration_entry.v2 = "; parts$(2)
        if previous$(3) <> parts$(3) then
            if parts$(3) = "RIGHT" then print #3, "registration_entry.v3 = 1" else print #3, "registration_entry.v3 = 0"
        end if
        process_arg_list parts$(5)
        print #3, "htable_add_hentry " + toksym$ + ", registration_entry"
    case "LITERAL"
        assertsize 2
        literal_toknum = literal_toknum - 1
        cur_toknum = literal_toknum
        print #2, "CONST TOK_" + tokname$ + " ="; literal_toknum
    case else
        fatalerror "Unknown token type " + parts$(0)
    end select
    if instr(parts$(-1), "DIRECT") then print #3, "tok_direct(TS_"; ucase$(tokname$); ") ="; cur_toknum
    for i = 0 to ubound(parts$)
        previous$(i) = parts$(i)
    next i
loop
system

ehandler:
    print "Error"; err; _errorline
    system 1

sub process_arg_list(arglist$)
    split_args arglist$
    if args$(0) = "" then exit sub 'No arguments
    for i  = 0 to ubound(args$)
        if left$(args$(i), 1) = "?" then
            args$(i) = mid$(args$(i), 2)
            required = 0 
        else
            required = -1
        end if
        print #3, "type_chain_argument registration_entry.v1, TYPE_"; args$(i); ","; required
    next i
end sub

sub split(in$)
    redim parts$(-1 to 0)
    if instr(in$, ";") then
        parts$(-1) = mid$(in$, instr(in$, ";") + 1)
        in$ = rtrim$(left$(in$, instr(in$, ";") - 1))
    end if
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
            redim _preserve parts$(-1 to ubound(parts$) + 1)
        else
            parts$(ubound(parts$)) = mid$(in$, start)
            exit sub
        end if
    loop
end sub

sub split_args(in$)
    redim args$(-1 to 0)
    start = 1
    do
        sp = instr(start, in$, ",")
        if sp = start then
            start = start + 1
            _continue
        end if
        if sp then
            args$(ubound(args$)) = mid$(in$, start, sp - start)
            start = sp + 1
            redim _preserve args$(-1 to ubound(args$) + 1)
        else
            args$(ubound(args$)) = mid$(in$, start)
            exit sub
        end if
    loop
end sub

sub assertsize_range(min_expected, max_expected)
    if ubound(parts$) < min_expected - 1 or ubound(parts$) > max_expected + 1 then
        fatalerror "Expected between " + str$(min_expected) + " and " + str$(max_expected) + " components, got" + str$(ubound(parts$) + 1)
    end if
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
