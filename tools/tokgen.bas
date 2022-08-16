'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'tokgen.bas - Token Generator & Registerer
'Create TOK_ definitions and register them in the lookup table
'
'Nearly every element of the program can be expressed as a token, which is identified with the TOK_
'constant ID. The symtab also stores all tokens by name and can tell you their ID.
'Once you have the ID you can access the extra data defined for that token in symtab(). See
'symtab.bi for an explanation of that data.
'
'Note that because the ID's are assigned by the symtab functions in the order items are registered,
'any manual edits to the registration code will likely cause it to be out of sync with the TOK_ definitions.
'Re-run this generation program instead.
'
'The first element on the line is the type, which determines the format for the rest of the line.
'
'generic NAME ; FLAGS
'Adds a symtab entry with no extra information.
'
'type NAME SIZE ; FLAGS
'Generate the name as TYPE_ instead of TOK_ and SYM_TYPE instead of SYM_GENERIC. The fixed
'size of the type is set to SIZE bytes.
'This always emits a SYM_TYPE_INTERNAL type.
'
'arraytype NAME ELEMENTTYPE DIMENSIONS ; FLAGS
'Generate a SYM_TYPE with SYM_TYPE_ARRAY. Use DIMENSIONS = 0 to mean an unspecified number.
'
'meta NAME ; FLAGS
'Like generic, but generate the name as META_ instead of TOK_ and SYM_META instead of SYM_GENERIC.
'No need to add a leading $, this is added implicitly.

'literal NAME ; FLAGS
'Represent a literal. Does not generate a symtab entry.
'
'prefix NAME PRECEDENCE RETURN ARGS ; FLAGS
'A prefix operator.

'infix NAME PRECEDENCE ASSOCIATIVITY RETURN ARGS ; FLAGS
'An infix operator.
'
'function NAME RETURN ARGS ; FLAGS
'A function (or sub) with regular call syntax.

'NAME is the identifier for the token, and will be prefixed with TOK_. If the token contains special characters
'a safe name may be given in parentheses, e.g "+(plus)". If the token is a special character (see below), it
'should be represented as \xx where xx is the ASCII code. There must be no spaces anywhere in this field.
'
'PRECEDENCE is an integer for parsing precedence. Larger values are higher precedence.

'ASSOCIATIVTY is "left" or "right".
'
'RETURN is "none" or a type name to represent the return type of the function call.
'
'ARGS is a comma-separated string specifying the type and nature of arguments passed to a function.
'Each comma-separated element is a type name, with the following optional prefixes and suffixes:
' @ prefix: The argument must be passed BYREF and its type must match exactly
' % prefix: The argument is a file handle and may appear with a leading #
' ? suffix: The argument is optional
' " prefix: The argument is a token name, and will be represented with an AST_FLAGS
'           (or AST_NONE if optional and not present)
' ' prefix: The argument is a token name but will not be added to the AST
' $ prefix: The argument is an unquoted literal that matches the label given. The
'           label may be split into multiple alternatives with a | separator.
'
'Alternatively, any of ARGS may be a " or ' character followed by a token defined elsewhere in the file.
'This causes that token to be expected at that position. It also suppresses parsing the implicit
'following comma that would otherwise be expected in the argument list.
'If the character is ", this argument will be supplied as an AST_FLAGS argument in the call list. The value
'of the flag is the constant FLAG_[function name]_[token name] which must be defined in the cmdflags.bi file.
'A ' character supresses the generation of the AST_FLAGS and does not need a FLAG_* constant to be defined. Neither " not ' args may be marked optional.
'
'FLAGS is an optional list of modifiers. If present it must begin with a semi-colon. Valid flags:
'  DIRECT: Assume that there is a TS_ of the same name as this token that maps to it.
'  NOSYM: Prefix the token with a pipe "|" character in the symtab, preventing it from clashing with other tokens.

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

print #3, "dim sym as symtab_entry_t"
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

    if parts$(0) = "META" then toksym$ = "$" + toksym$
    if instr(parts$(-1), "NOSYM") then toksym$ = "|" + toksym$

    select case parts$(0)
    case "GENERIC"
        assertsize 2
        toknum = toknum + 1
        cur_toknum = toknum
        print #2, "CONST TOK_" + tokname$ + " =" + str$(toknum)
        if previous$(0) <> "GENERIC" then print #3, "sym.typ = SYM_GENERIC"
        print #3, "sym.identifier = "; quote$(toksym$)
        print #3, "symtab_add_entry sym"
    case "TYPE"
        assertsize 3
        toknum = toknum + 1
        cur_toknum = toknum
        print #2, "CONST TYPE_" + tokname$ + " =" + str$(toknum)
        if previous$(0) <> "TYPE" and previous$(0) <> "ARRAYTYPE" then print #3, "sym.typ = SYM_TYPE"
        if previous$(2) <> parts$(2) then print #3, "sym.v1 = "; parts$(2)
        print #3, "sym.v2 = SYM_TYPE_INTERNAL"
        print #3, "sym.identifier = "; quote$(toksym$)
        print #3, "symtab_add_entry sym"
    case "ARRAYTYPE"
        assertsize 4
        toknum = toknum + 1
        cur_toknum = toknum
        print #2, "CONST TYPE_" + tokname$ + " =" + str$(toknum)
        if previous$(0) <> "TYPE" and previous$(0) <> "ARRAYTYPE" then print #3, "sym.typ = SYM_TYPE"
        print #3, "sym.v1 = type_fixed_size(TYPE_"; ucase$(parts$(2)); ") * "; parts$(3)
        if previous$(0) <> "ARRAYTYPE" then print #3, "sym.v2 = SYM_TYPE_ARRAY"
        if previous$(2) <> parts$(2) then print #3, "sym.v3 = TYPE_"; ucase$(parts$(2))
        if previous$(3) <> parts$(3) then print #3, "sym.v4 = "; parts$(3)
        print #3, "sym.identifier = "; quote$(toksym$)
        print #3, "symtab_add_entry sym"
    case "META"
        assertsize 2
        toknum = toknum + 1
        cur_toknum = toknum
        print #2, "CONST META_" + tokname$ + " =" + str$(toknum)
        if previous$(0) <> "META" then print #3, "sym.typ = SYM_META"
        print #3, "sym.identifier = "; quote$(toksym$)
        print #3, "symtab_add_entry sym"
    case "FUNCTION"
        assertsize_range 3, 4
        if previous$(1) <> parts$(1) then
            toknum = toknum + 1
            print #2, "CONST TOK_" + tokname$ + " =" + str$(toknum)
        end if
        cur_toknum = toknum
        if previous$(0) <> "FUNCTION" then
            print #3, "sym.typ = SYM_FUNCTION"
            print #3, "sym.v2 = SYM_FUNCTION_INTRINSIC"
        end if
        process_return_type previous$(1), parts$(1), parts$(2)
        if ubound(parts$) = 3 then
            process_arg_list parts$(3)
        end if
        if previous$(1) <> parts$(1) then
            print #3, "sym.identifier = "; quote$(toksym$)
            print #3, "symtab_add_entry sym"
        end if
    case "PREFIX"
        assertsize 5
        if previous$(1) <> parts$(1) then
            toknum = toknum + 1
            print #2, "CONST TOK_" + tokname$ + "=" + str$(toknum)
        end if
        cur_toknum = toknum
        if previous$(0) <> "PREFIX" then print #3, "sym.typ = SYM_PREFIX"
        if previous$(2) <> parts$(2) then print #3, "sym.v2 = "; parts$(2)
        process_return_type previous$(1), parts$(1), parts$(3)
        process_arg_list parts$(4)
        if previous$(1) <> parts$(1) then
            print #3, "sym.identifier = "; quote$(toksym$)
            print #3, "symtab_add_entry sym"
        end if
    case "INFIX"
        assertsize 6
        if previous$(1) <> parts$(1) then
            toknum = toknum + 1
            print #2, "CONST TOK_" + tokname$ + " =" + str$(toknum)
        end if
        cur_toknum = toknum
        if previous$(0) <> "INFIX" then print #3, "sym.typ = SYM_INFIX"
        if previous$(2) <> parts$(2) then print #3, "sym.v2 = "; parts$(2)
        if previous$(3) <> parts$(3) then
            if parts$(3) = "RIGHT" then print #3, "sym.v3 = 1" else print #3, "sym.v3 = 0"
        end if
        process_return_type previous$(1), parts$(1), parts$(4)
        process_arg_list parts$(5)
        if previous$(1) <> parts$(1) then
            print #3, "sym.identifier = "; quote$(toksym$)
            print #3, "symtab_add_entry sym"
        end if
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
print #3, "ast_commit"
system

ehandler:
    print "Error"; err; _errorline
    system 1

sub process_return_type(prev_name$, cur_name$, ret_type$)
    if prev_name$ = cur_name$ then
        print #3, "sym.v1 = type_add_sig(sym.v1, type_sigt_create$(TYPE_" + ret_type$ + "))"
    else
        print #3, "sym.v1 = type_add_sig(0, type_sigt_create$(TYPE_" + ret_type$ + "))"
    end if
end sub

sub process_arg_list(arglist$)
    split_args arglist$
    const TYPE_OPTIONAL = 1
    const TYPE_BYREF = 2
    const TYPE_FILEHANDLE = 8
    const TYPE_TOKEN = 16
    const TYPE_SYNTAX_ONLY = 32
    const TYPE_CONTEXTUAL = 64
    if args$(0) = "" then exit sub 'No arguments
    for i  = 0 to ubound(args$)
        flags = 0
        if right$(args$(i), 1) = "?" then
            args$(i) = left$(args$(i), len(args$(i)) - 1)
            flags = flags OR TYPE_OPTIONAL
        end if
        if left$(args$(i), 1) = "@" then
            args$(i) = mid$(args$(i), 2)
            flags = flags OR TYPE_BYREF
        end if
        if left$(args$(i), 1) = "%" then
            args$(i) = mid$(args$(i), 2)
            flags = flags OR TYPE_FILEHANDLE
        end if
        if left$(args$(i), 1) = chr$(34) then
            args$(i) = mid$(args$(i), 2)
            flags = flags OR TYPE_TOKEN
        elseif left$(args$(i), 1) = "'" then
            args$(i) = mid$(args$(i), 2)
            flags = flags OR TYPE_TOKEN OR TYPE_SYNTAX_ONLY
        elseif left$(args$(i), 1) = "$" then
            args$(i) = mid$(args$(i), 2)
            flags = flags OR TYPE_CONTEXTUAL
        end if
        if flags AND TYPE_TOKEN then
            print #3, "type_sig_add_arg sym.v1, TOK_"; args$(i); ","; flags
        elseif flags AND TYPE_CONTEXTUAL then
            print #3, "type_sig_add_arg sym.v1,";
            print #3, "ast_add_constant(TOK_CONTEXTUAL_ARGUMENT,";
            print #3, chr$(34); args$(i); chr$(34); ",0),"; flags
        else
            print #3, "type_sig_add_arg sym.v1, TYPE_"; args$(i); ","; flags
        end if
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

function quote$(a$)
    quote$ = chr$(34) + a$ + chr$(34)
end function

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
