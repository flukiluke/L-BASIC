'Copyright 2020 Luke Ceddia
'
'Licensed under the Apache License, Version 2.0 (the "License");
'you may not use this file except in compliance with the License.
'You may obtain a copy of the License at
'
'  http://www.apache.org/licenses/LICENSE-2.0
'
'Unless required by applicable law or agreed to in writing, software
'distributed under the License is distributed on an "AS IS" BASIS,
'WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'See the License for the specific language governing permissions and
'limitations under the License.
'
'lbasic.bas - Main file for L-BASIC Compiler

'$dynamic
$console
$screenhide
option _explicitarray
_dest _console
deflng a-z
const FALSE = 0, TRUE = not FALSE
on error goto error_handler

dim shared VERSION$
VERSION$ = "0.0.5"

'If an error occurs, we use this to know where we came from so we can
'give a more meaningful error message.
'0 => Unknown location
'1 => Parsing code; parser line number is valid
'2 => Immediate runtime
'3 => Dump code
dim shared Error_context
'Because we can only throw a numeric error code, this holds a more
'detailed explanation.
dim shared Error_message$

'$include: 'cmdflags.bi'
'$include: 'type.bi'
'$include: 'symtab.bi'
'$include: 'ast.bi'
'$include: 'parser/parser.bi'
'$include: 'emitters/immediate/immediate.bi'

dim shared input_file_handle

type options_t
    mainarg as string
    outputfile as string
    run_mode as integer
    interactive_mode as integer
    terminal_mode as integer
    command_mode as integer
    compile_mode as integer
    debug as integer
end type

dim shared options as options_t
dim shared input_file_command_offset

chdir _startdir$
parse_cmd_line_args

if instr(_os$, "[WINDOWS]") then
    exe_suffix$ = ".exe"
else
    exe_suffix$ = ""
end if

if not options.terminal_mode then
    _screenshow
    _dest 0
end if

if options.interactive_mode then
    interactive_mode FALSE
elseif options.command_mode then
    command_mode
elseif options.compile_mode then
    'Output file defaults to input file with .bas changed to .exe (or nothing on Unix)
    if options.outputfile = "" then options.outputfile = remove_ext$(options.mainarg) + exe_suffix$
    if instr("/", left$(options.mainarg, 1)) = 0 then options.mainarg = _startdir$ + "/" + options.mainarg
    if instr("/", left$(options.outputfile, 1)) = 0 then options.outputfile = _startdir$ + "/" + options.outputfile
    compile_mode
else
    run_mode
end if

if options.terminal_mode then system else end

interactive_recovery:
    interactive_mode TRUE

error_handler:
    select case Error_context
    case 1 'Parsing code
        print "Parser: ";
        if err <> 101 then goto internal_error
        if options.interactive_mode then
            print Error_message$
            Error_message$ = ""
            resume interactive_recovery
        else
            print "Line" + str$(ps_actual_linenum) + ": " + Error_message$
        end if
    case 2 'Immediate mode
        'We have no good way of distinguishing between user program errors and internal errors
        'Of course, the internal code is perfect so it *must* be a user program error
        print "Runtime error: ";
        if err = 101 then print Error_message$; else print lookup_builtin_error$(err);
        print " ("; _trim$(str$(err)); "/"; _inclerrorfile$; ":"; _trim$(str$(_inclerrorline)); ")"
        resume interactive_recovery
    case 3 'Dump mode
        print "Dump: ";
        if err <> 101 then goto internal_error
        print Error_message$
    case 4 'Run mode
        print "Runtime error: ";
        if err = 101 then print Error_message$; else print lookup_builtin_error$(err);
        print " ("; _trim$(str$(err)); "/"; _inclerrorfile$; ":"; _trim$(str$(_inclerrorline)); ")"
    case else
        internal_error:
        if _inclerrorline then
            print "Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
        else
            print "Internal error" + str$(err) + " on line" + str$(_errorline)
        end if
        print Error_message$
    end select
    if options.terminal_mode then system 1 else end 1

'This one's solely for basic user error like input file not found, bad command line etc.
sub fatalerror(msg$)
    print "Error: " + msg$
    if options.terminal_mode then system 1 else end 1
end sub

sub debuginfo(msg$)
    if options.debug then print msg$
end sub

'This function and the next are called from tokeng.
'They provide a uniform way of loading the next line.
function general_next_line$
    if options.interactive_mode then
        print "> ";
        line input s$
    elseif options.command_mode then
        s$ = options.mainarg
        options.mainarg = ""
    else
        line input #input_file_handle, s$
    end if
    general_next_line$ = s$
end function

function general_eof
    if options.interactive_mode then
        'Hopefully one day we'll be able to handle ^D/^Z here
        general_eof = FALSE
    elseif options.command_mode then
        general_eof = options.mainarg = ""
    else
        general_eof = eof(input_file_handle)
    end if
end function

sub interactive_mode(recovery)
    if recovery then
        do until tok_token = TOK_NEWLINE
            tok_advance
        loop
    else
        open "SCRN:" for output as #1
        imm_init
        ast_init
        Error_context = 1
        tok_init
    end if
    do
        Error_context = 1
        node = ps_stmt
        select case node
        case -2
            'A SUB or FUNCTION was defined, we want to keep that.
            symtab_commit
            ast_commit
        case -1
            '-1 is an end block, this should never happen
            ps_error "Block end at top-level"
        case 0
            'No ast nodes were generated (DIM etc.), but save any
            'symbols created.
            symtab_commit
        case else
            Error_context = 0
            ast_attach ast_get_child(AST_MAIN_PROCEDURE, 1), node
            if options.debug then
                Error_context = 3
                ast_dump_pretty AST_MAIN_PROCEDURE, 0
                Error_context = 0
                print #1,
            end if
            imm_reinit
            Error_context = 2
            imm_run ast_get_child(AST_MAIN_PROCEDURE, 1)
            'Keep any symbols that were defined
            symtab_commit
            'But don't keep any nodes generated
            ast_rollback
            'And clear the main program
            ast_clear_main_procedure
        end select
        Error_context = 1
        ps_consume TOK_NEWLINE
    loop
end sub

sub command_mode
    open "SCRN:" for output as #1
    ast_init
    Error_context = 1
    tok_init
    root = ps_block
    Error_context = 0
    if options.debug then
        Error_context = 3
        ast_dump_pretty root, 0
        Error_context = 0
        print #1,
    end if
    imm_init
    Error_context = 2
    imm_run root
    Error_context = 0
end sub
    
sub compile_mode
    ast_init
    if options.mainarg = "" then fatalerror "No input file"
    input_file_handle = freefile
    open options.mainarg for input as #input_file_handle
    tok_init
    Error_context = 1
    root = ps_block
    Error_context = 0
    close #input_file_handle
    open options.outputfile for output as #1
    Error_context = 3
    dump_program root
    Error_context = 0
    close #1
end sub

sub run_mode
    ast_init
    if options.mainarg = "" then fatalerror "No input file"
    input_file_handle = freefile
    open options.mainarg for input as #input_file_handle
    tok_init
    Error_context = 1
    root = ps_block
    ps_finish_labels root
    Error_context = 0
    close #input_file_handle
    imm_init
    Error_context = 4
    imm_run root
    Error_context = 0
end sub

'Strip the .bas extension if present
function remove_ext$(fullname$)
    dot = _instrrev(fullname$, ".")
    if mid$(fullname$, dot + 1) = "bas" then
        remove_ext$ = left$(fullname$, dot - 1)
    else
        remove_ext$ = fullname$
    end if
end function

sub show_version
    print "The L-BASIC compiler version " + VERSION$
end sub

sub show_help
    print "The L-BASIC compiler"
    print "Usage: " + command$(0) + " [OPTIONS] [FILE]"
    print "Execute FILE if given, otherwise launch an interactive session."
    print '                                                                                '80 columns
    print "Options:"
    print "  -t, --terminal                   Run in terminal mode (no graphical window)"
    print "  -c FILE, --compile FILE          Compile FILE instead of executing"
    print "  -o OUTPUT, --output OUTPUT       Place compilation output into OUTPUT"
    print "  -e CMD, --execute CMD            Execute the statement CMD then exit"
    print "  -d, --debug                      For internal debugging"
    print "  -h, --help                       Print this help message"
    print "  --version                        Print version information"
end sub

'The error handling here fakes terminal_mode on the assumption that if you're
'using command line arguments you don't want a graphical window popping up.
sub parse_cmd_line_args()
    for i = 1 TO _commandcount
        arg$ = command$(i)
        select case arg$
            case "--version"
                show_version
                system
            case "-h", "--help"
                show_help
                system
            case "-o", "--output"
                if i = _commandcount then
                    options.terminal_mode = TRUE
                    fatalerror arg$ + " requires argument"
                end if
                options.outputfile = command$(i + 1)
                i = i + 1
            case "-d", "--debug"
                options.debug = TRUE
            case "-c", "--compile"
                options.compile_mode = TRUE
            case "-t", "--terminal"
                options.terminal_mode = TRUE
            case "-e", "--execute"
                options.command_mode = TRUE
            case else
                if left$(arg$, 1) = "-" then
                    options.terminal_mode = TRUE
                    fatalerror "Unknown option " + arg$
                end if
                if options.mainarg = "" then
                    options.mainarg = arg$
                    input_file_command_offset = i
                    exit for
                end if
        end select
    next i
    if options.mainarg = "" then options.interactive_mode = TRUE
end sub

'$include: 'type.bm'
'$include: 'ast.bm'
'$include: 'symtab.bm'
'$include: 'errors.bm'
'$include: 'parser/parser.bm'
'$include: 'emitters/dump/dump.bm'
'$include: 'emitters/immediate/immediate.bm'

