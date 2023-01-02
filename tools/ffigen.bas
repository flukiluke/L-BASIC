'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'ffigen.bas - FFI Generator
'Generate headers and functions for calling into dynamic libraries

'This program exists primarily to work around deficiencies in how QB64
'processes DECLARE DYNAMIC LIBRARY. Specifically, it avoids the library
'needing to be found at compile time, and allows loading with an unqualified
'(no path) name to pick up system libraries.

$console:only
_dest _console
deflng a-z
on error goto ehandler
chdir _startdir$
const FALSE = 0, TRUE = not FALSE
const SIGILS = "|~%%|~&&|~%&|~%|~&|%%|&&|##|%&|%|&|!|#|$|"
const ID_CHARS = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM_0123456789"

if _commandcount <> 3 then
    print "Usage: "; command$(0); " "; "<input file> <.bi output> <.h output>"
    system 1
end if

if not _fileexists(command$(1)) then
    print command$(0); ": Cannot open "; command$(1)
    system 1
end if

open command$(1) for input as #1
open command$(2) for output as #2
open command$(3) for output as #3

dim shared rootname$
dim shared linenum

do while not eof(1)
    linenum = linenum + 1
    line input #1, l$
    l$ = ltrim$(rtrim$(l$))
    if left$(l$, 1) = "#" or l$ = "" then _continue
    l$ = expand_var$(l$)
    redim parts$(0)
    split l$, " ", parts$()
    select case ucase$(parts$(0))
        case "ROOTNAME"
            declare_library parts$(1)
            rootname$ = parts$(1)
        case "LIB"
            start_library_init
            for i = 1 to ubound(parts$)
                load_library parts$(i)
            next i
            end_library_init
        case "FUNCTION"
            add_function ltrim$(mid$(l$, 9)), TRUE
        case "SUB"
            add_function ltrim$(mid$(l$, 4)), FALSE
        case "ENDLIB"
            print #2, "end declare"
        case "ENUM"
            if ubound(parts$) = 0 then
                enum_index = 0
            else
                enum_index = val(parts$(1))
            end if
            in_enum = TRUE
        case "ENDENUM"
            if not in_enum then fatalerror "ENDENUM without ENUM"
            in_enum = FALSE
        case else
            if not in_enum then fatalerror "Unknown command " + parts$(0)
            print #2, "const "; parts$(0); " ="; enum_index
            enum_index = enum_index + 1
    end select
loop
system

ehandler:
    print "Error"; err; _errorline
    system 1

function expand_var$(text$)
    s = instr(text$, "${")
    if s = 0 then
        expand_var$ = text$
        exit function
    end if
    e = instr(d, text$, "}")
    if e = 0 then fatalerror "Unmatched braces"
    var$ = mid$(text$, s + 2, e - s - 2)
    expand_var$ = left$(text$, s - 1) + environ$(var$) + expand_var$(mid$(text$, e + 1))
end sub

sub split(in$, delimiter$, result$())
    redim result$(-1)
    start = 1
    do
        while mid$(in$, start, len(delimiter$)) = delimiter$
            start = start + len(delimiter$)
            if start > len(in$) then exit sub
        wend
        finish = instr(start, in$, delimiter$)
        if finish = 0 then finish = len(in$) + 1
        redim _preserve result$(0 to ubound(result$) + 1)
        result$(ubound(result$)) = mid$(in$, start, finish - start)
        start = finish + len(delimiter$)
    loop while start <= len(in$)
end sub

sub declare_library(s$)
    dynlib$ = "DYNLIB_" + s$
    print #2, "declare library "; chr$(34); "./"; s$; chr$(34)
    print #2, space$(4); "sub dynlib_"; s$; "_init"
    if instr(_os$, "WIN") then
        print #3, "HINSTANCE "; dynlib$; " = NULL;"
    else
        print #3, "void *"; dynlib$; " = NULL;"
    end if
end sub

sub start_library_init
    dynlib$ = "DYNLIB_" + rootname$
    print #3, "void dynlib_"; rootname$; "_init() {"
    print #3, space$(4); "if ("; dynlib$; ") return;"
end sub

sub load_library(s$)
    dynlib$ = "DYNLIB_" + rootname$
    if instr(_os$, "WIN") then
        print #3, space$(4); dynlib$; " = LoadLibrary("; chr$(34); s$; chr$(34); ");"
    else
        print #3, space$(4); dynlib$; " = dlopen("; chr$(34); s$; chr$(34); ",RTLD_LAZY);"
    end if
    print #3, space$(4); "if (!"; dynlib$; ") {"
    print #3, space$(8); "fprintf(stderr, "; chr$(34); "Error: cannot load "; s$; "\n"; chr$(34); ");"
    print #3, space$(8); "exit(1);"
    print #3, space$(4); "}"
end sub

sub end_library_init
    print #3, "}"
end sub

sub add_function(s$, has_return)
    funcname$ = take_id$(s$)
    if has_return then ret$ = take_type$(s$)
    if ucase$(take_id$(s$)) = "ALIAS" then
        symname$ = take_id$(s$)
    else
        symname$ = funcname$
    end if
    if has_return then
        print #2, space$(4); "function "; funcname$; ret$;
    else
        print #2, space$(4); "sub "; funcname$;
    end if
    print #3, "typedef "; c_type$(ret$); " (CALLBACK *DYNT_"; symname$; ")(";

    redim args$(-1)
    if left$(s$, 1) = "(" then
        print #2, " (";
        if right$(s$, 1) <> ")" then fatalerror "Unbalanced parentheses"
        'Remove start and end parentheses
        s$ = mid$(s$, 2, len(s$) - 2)

        split s$, ",", args$()
        funcargs$ = ""
        for i = 0 to ubound(args$)
            args$(i) = ltrim$(args$(i))
            varname$ = "a" + ltrim$(str$(i))
            x$ = take_id$(args$(i))
            if ucase$(x$) = "BYVAL" then
                byv = TRUE
                x$ = take_id$(args$(i))
            else
                byv = FALSE
            end if
            typ$ = take_type$(args$(i))
            if byv then print #2, "byval ";
            print #2, varname$; typ$;
            c_typ$ = c_type$(typ$)
            if not byv and right$(c_typ$, 1) <> "*" then c_typ$ = c_typ$ + "*"
            print #3, c_typ$;
            funcargs$ = funcargs$ + c_typ$ + " " + varname$
            if i < ubound(args$) then
                print #2, ",";
                print #3, ",";
                funcargs$ = funcargs$ + ","
            end if
        next i
        print #2, ")";
    end if
    print #2,
    print #3, ");"

    print #3, c_type$(ret$); " "; funcname$; "("; funcargs$; ") {"
    print #3, space$(4); "static DYNT_"; symname$; " DYNCALL_"; symname$; " = NULL;"
    print #3, space$(4); "if (!DYNCALL_"; symname$; ") ";
    if instr(_os$, "WIN") then
        print #3, "DYNCALL_"; symname$; " = (DYNT_"; symname$; ")GetProcAddress(DYNLIB_"; rootname$; ","; chr$(34); symname$; chr$(34); ");"
    else
        print #3, "DYNCALL_"; symname$; " = (DYNT_"; symname$; ")dlsym(DYNLIB_"; rootname$; ","; chr$(34); symname$; chr$(34); ");"
    end if
    if has_return then
        print #3, space$(4); "return DYNCALL_"; symname$; "(";
    else
        print #3, space$(4); "DYNCALL_"; symname$; "(";
    end if
    for i = 0 to ubound(args$)
        print #3, "a" + ltrim$(str$(i));
        if i < ubound(args$) then print #3, ",";
    next i
    print #3, ");"
    print #3, "}"
end sub

function take_id$(s$)
    for i = 1 to len(s$)
        if instr(ID_CHARS, mid$(s$, i, 1)) then
            id$ = id$ + mid$(s$, i, 1)
        else
            exit for
        end if
    next i
    take_id$ = id$
    s$ = ltrim$(mid$(s$, i))
end function

function take_type$(s$)
    for l = 3 to 1 step -1
        if instr(SIGILS, "|" + left$(s$, l) + "|") then
            length = l
            exit for
        end if
    next l
    if l = 0 then fatalerror "No type sigil"
    take_type$ = left$(s$, length)
    s$ = ltrim$(mid$(s$, length + 1))
end function

function c_type$(t$)
    s$ = t$
    if left$(s$, 1) = "~" then
        unsigned$ = "u"
        s$ = mid$(s$, 2)
    end if
    if left$(s$, 2) = "%&" then
        r$ = "ptrszint"
    elseif left$(s$, 2) = "%%" then
        r$ = "int8"
    elseif left$(s$, 2) = "&&" then
        r$ = "int64"
    elseif left$(s$, 2) = "##" then
        r$ = "long double"
    elseif left$(s$, 1) = "%" then
        r$ = "int16"
    elseif left$(s$, 1) = "&" then
        r$ = "int32"
    elseif left$(s$, 1) = "!" then
        r$ = "float"
    elseif left$(s$, 1) = "#" then
        r$ = "double"
    elseif left$(s$, 1) = "$" then
        r$ = "char*"
    elseif s$ = "" then
        r$ = "void"
    end if
    c_type$ = unsigned$ + r$
end function

sub fatalerror(msg$)
    print command$(0); ": "; command$(1); ":"; ltrim$(str$(linenum)); ": "; msg$
    system 1
end sub
