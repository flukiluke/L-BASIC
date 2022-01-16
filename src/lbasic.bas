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

$if VERSION < 2.0 then
    'We use zero-place predicate recursion which is only available in 2.0
    $error QB64 V2.0 or greater required
$end if

'$include: 'debugging_options.bm'

$if DEBUG_TIMINGS then
debug_timing_mark# = timer(0.001)
$end if

dim shared VERSION$
VERSION$ = "0.1.1"

'$dynamic
'Setting the graphics window off by default allows running without a
'graphics environment (and prevents an annoying popup).
$console
$screenhide
option _explicitarray
_dest _console
deflng a-z
const FALSE = 0, TRUE = not FALSE
on error goto error_handler

'If an error occurs, we use this to know where we came from so we can
'give a more meaningful error message.
'0 => Unknown location
'1 => Parsing code; parser line number is valid
'2 => Immediate runtime (interactive)
'3 => Dump code
'4 => Trying to open a file
'5 => Immediate runtime (non-interactive)
dim shared Error_context
'Because we can only throw a numeric error code, this holds a more
'detailed explanation.
dim shared Error_message$
'Set TRUE whenever an error is triggered
dim shared Error_occurred

'We distinguish the runtime platform (where L-BASIC is running) from the target
'platform (where the binaries we produce are running).
type platform_t
    id as string
    posix_paths as long 'TRUE for linux/mac style paths, false for Windows style paths
    executable_extension as string
end type
dim shared as platform_t runtime_platform_settings, target_platform_settings
if instr(_os$, "[WINDOWS]") then
    runtime_platform_settings.id = "Windows"
    runtime_platform_settings.posix_paths = FALSE
    runtime_platform_settings.executable_extension = ".exe"
elseif instr(_os$, "[MACOSX]") then
    runtime_platform_settings.id = "MacOS"
    runtime_platform_settings.posix_paths = TRUE
    runtime_platform_settings.executable_extension = ""
elseif instr(_os$, "[LINUX]") then
    runtime_platform_settings.id = "Linux"
    runtime_platform_settings.posix_paths = TRUE
    runtime_platform_settings.executable_extension = ""
else
    fatalerror "Could not detect runtime platform"
end if
'For now, the target platform is always the same as the runtime platform
target_platform_settings = runtime_platform_settings

'This is an array so we can handle included files.
'The current "reading" file is input_files(input_files_last).
type input_file_t
    handle as long
    'Directory containing the file, further includes are relative to this
    dirname as string
    'To be used only for diagnostic messages
    filename as string
end type
redim shared input_files(0) as input_file_t
dim shared input_files_last
'The logging output is used for debugging output
dim shared logging_file_handle

'Various global options read from the command line
type options_t
    mainarg as string
    preload as string
    outputfile as string
    run_mode as integer
    interactive_mode as integer
    terminal_mode as integer
    command_mode as integer
    compile_mode as integer
    debug as integer
end type
dim shared options as options_t

'Allow immediate mode to access COMMAND$() without picking up interpreter options
dim shared input_file_command_offset

'$include: 'cmdflags.bi'
'$include: 'type.bi'
'$include: 'symtab.bi'
'$include: 'ast.bi'
'$include: 'parser/parser.bi'
'$include: 'emitters/immediate/immediate.bi'

parse_cmd_line_args
if not options.terminal_mode then
    _screenshow
    _dest 0
end if

'Send out debugging info to the screen
logging_file_handle = freefile
open_file "SCRN:", logging_file_handle, TRUE

'Setup AST, constants and parser settings
ast_init
ps_init

$if DEBUG_TIMINGS then
debuginfo "Boot time:" + str$(timer(0.001) - debug_timing_mark#)
$end if

'Preload files can override built-in commands; handle that now
if options.preload <> "" then preload_file

'Dispatch based on desired mode of operation
Error_context = 1
if options.interactive_mode then
    'User will type in commands
    interactive_mode FALSE
elseif options.command_mode then
    'Run some code given on the command line
    command_mode
elseif options.compile_mode then
    'Produce a binary output. Currently this just dumps the AST and symbol table.
    compile_mode
else
    run_mode
end if

if options.terminal_mode then system else end

interactive_recovery:
    interactive_mode TRUE

error_handler:
    Error_occurred = TRUE
    select case Error_context
    case 1 'Parsing code
        print "Parser: ";
        if err <> 101 then goto internal_error
        if options.interactive_mode and options.preload = "" then
            print Error_message$
            Error_message$ = ""
            resume interactive_recovery
        else
            if options.preload <> "" then print "In preload file: ";
            print "Line" + str$(ps_actual_linenum) + ": " + Error_message$
        end if
    case 2, 5 'Immediate mode
        'We have no good way of distinguishing between user program errors and internal errors
        'Of course, the internal code is perfect so it *must* be a user program error
        print "Runtime error: ";
        if err = 101 then print Error_message$; else print _errormessage$(err);
        print " ("; _trim$(str$(err)); "/"; _inclerrorfile$; ":"; _trim$(str$(_inclerrorline)); ")"
        if Error_context = 2 then resume interactive_recovery
    case 3 'Dump mode
        print "Dump: ";
        if err <> 101 then goto internal_error
        print Error_message$
    case 4 'File access check
        resume next
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
    if options.debug then print #logging_file_handle, msg$
end sub

'This function and the next are called from tokeng.
'They provide a uniform way of loading the next line.
function general_next_line$
    if options.preload <> "" then
        line input #input_files(input_files_last).handle, s$
    elseif options.interactive_mode then
        old_dest = _dest
        _dest 0
        print "> ";
        line input s$
        _dest old_dest
    elseif options.command_mode then
        s$ = options.mainarg
        options.mainarg = ""
    else
        line input #input_files(input_files_last).handle, s$
    end if
    general_next_line$ = s$
end function

function general_eof
    if options.preload <> "" then
        result = eof(input_files(input_files_last).handle)
    elseif options.interactive_mode then
        'Hopefully one day we'll be able to handle ^D/^Z here
        result = FALSE
    elseif options.command_mode then
        result = options.mainarg = ""
    else
        result = eof(input_files(input_files_last).handle)
        'An EOF in an include file just means close that and return to the
        'outer file
        if result and input_files_last > 0 then
            close #input_files(input_files_last).handle
            input_files_last = input_files_last - 1
            'Call recursively in case the outer file has also ended
            result = general_eof
        end if
    end if
    general_eof = result
end function

sub preload_file
    input_files(input_files_last).handle = freefile
    open_file options.preload, input_files(input_files_last).handle, FALSE
    tok_init
    Error_context = 1
    ps_preload_file
    close #input_files(input_files_last).handle
    options.preload = ""
end sub

'Open a file and trigger a fatal error if we couldn't
sub open_file(filename$, handle, is_output)
    old_ctx = Error_context
    Error_context = 4
    Error_occurred = FALSE
    if is_output then
        open filename$ for output as #handle
    else
        open filename$ for input as #handle
    end if
    if Error_occurred then fatalerror "Could not open file " + filename$
    Error_context = old_ctx
end sub

sub interactive_mode(recovery)
    if recovery then
        ps_nested_structures$ = ""
        ps_scope_identifier$ = ""
        tok_recover TOK_NEWLINE
        symtab_commit
        ast_rollback
        ast_clear_entrypoint
    else
        imm_init
        AST_ENTRYPOINT = ast_add_node(AST_BLOCK)
        ast_commit
        tok_init
        ps_init
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
            ast_attach AST_ENTRYPOINT, node
            $if DEBUG_PARSE_RESULT then
            if options.debug then
                Error_context = 3
                ast_dump_pretty AST_ENTRYPOINT, 0
                Error_context = 0
                print #1,
            end if
            $end if
            imm_reinit ps_next_var_index - 1
            Error_context = 2
            imm_run AST_ENTRYPOINT
            'Keep any symbols that were defined
            symtab_commit
            'But don't keep any nodes generated
            ast_rollback
            'And clear the main program
            ast_clear_entrypoint
        end select
        Error_context = 1
        ps_consume TOK_NEWLINE
    loop
end sub

sub command_mode
    tok_init
    root = ps_block
    Error_context = 0
    $if DEBUG_PARSE_RESULT then
    if options.debug then
        Error_context = 3
        ast_dump_pretty root, 0
        Error_context = 0
        print #1,
    end if
    $end if
    imm_init
    Error_context = 2
    imm_run root
    Error_context = 0
end sub
    
sub compile_mode
    if options.mainarg = "" then fatalerror "No input file"
    'Output file defaults to input file with .bas changed to .exe (or nothing on Unix)
    if options.outputfile = "" then options.outputfile = remove_ext$(options.mainarg) + target_platform_settings.executable_extension
    input_files(input_files_last).filename = options.mainarg
    options.mainarg = locate_path$(options.mainarg, _startdir$)
    input_files(input_files_last).dirname = dirname$(options.mainarg)
    input_files(input_files_last).handle = freefile
    open_file options.mainarg, input_files(input_files_last).handle, FALSE
    tok_init
    ps_prepass
    seek input_files(input_files_last).handle, 1
    tok_reinit
    ps_init
    ast_rollback
    AST_ENTRYPOINT = ps_block
    ps_finish_labels AST_ENTRYPOINT
    Error_context = 0
    close #input_files(input_files_last).handle
    close #logging_file_handle
    logging_file_handle = freefile
    open_file options.outputfile, logging_file_handle, TRUE
    Error_context = 3
    dump_program
    Error_context = 0
    close #1
end sub

sub run_mode
    if options.mainarg = "" then fatalerror "No input file"
    input_files(input_files_last).filename = options.mainarg
    options.mainarg = locate_path$(options.mainarg, _startdir$)
    input_files(input_files_last).dirname = dirname$(options.mainarg)
    input_files(input_files_last).handle = freefile
    open_file options.mainarg, input_files(input_files_last).handle, FALSE
    tok_init
    $if DEBUG_TIMINGS then
    debug_timing_mark# = timer(0.001)
    $end if
    ps_prepass
    seek input_files(input_files_last).handle, 1
    tok_reinit
    ps_init
    ast_rollback
    AST_ENTRYPOINT = ps_block
    ps_finish_labels AST_ENTRYPOINT
    $if DEBUG_TIMINGS then
    debuginfo "Parse time:" + str$(timer(0.001) - debug_timing_mark#)
    $end if
    Error_context = 0
    close #input_files(input_files_last).handle
    imm_init
    Error_context = 5
    $if DEBUG_TIMINGS then
    debug_timing_mark# = timer(0.001)
    $end if
    imm_run AST_ENTRYPOINT
    $if DEBUG_TIMINGS then
    debuginfo "Run time:" + str$(timer(0.001) - debug_timing_mark#)
    $end if
    Error_context = 0
    $if DEBUG_HEAP then
    if options.debug then imm_heap_stats
    $end if
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

'Get the path to a file relative to the prefix$ path. If prefix$ is
'absolute, then the returned path is absolute too.
function locate_path$(file$, prefix$)
    if runtime_platform_settings.posix_paths then
        if left$(file$, 1) = "/" then
            'path is already absolute
            locate_path$ = file$
        else
            locate_path$ = prefix$ + "/" + file$
        end if
    else
        'This doesn't support UNC paths or DOS device paths
        if mid$(file$, 2, 1) = ":" or left$(file$, 1) = "\" then
            'already absolute, or relative with explicit drive letter
            'that we can't meaningfully modify
            locate_path$ = file$
        else
            if right$(prefix$, 1) = "\" then sep$ = "" else sep$ = "\" '"fix syntax hilight
            locate_path$ = prefix$ + sep$ + file$
        end if
    end if
end function

'Get the directory component of a path
function dirname$(path$)
    if runtime_platform_settings.posix_paths then
        slash$ = "/"
    else
        slash$ = "\" '"
    end if
    s = _instrrev(path$, slash$)
    if s = 0 then
        dirname$ = "."
    else
        dirname$ = left$(path$, s - 1)
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
    print "  -c, --compile                    Compile FILE instead of executing"
    print "  -o OUTPUT, --output OUTPUT       Place compilation output into OUTPUT"
    print "  -e CMD, --execute CMD            Execute the statement CMD then exit"
    print "  --preload FILE                   Load FILE before parsing main program"
    print "  -d, --debug                      For internal debugging (if available)"
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
                options.outputfile = locate_path$(command$(i + 1), _startdir$)
                i = i + 1
            case "-d", "--debug"
                options.debug = TRUE
            case "-c", "--compile"
                options.compile_mode = TRUE
            case "-t", "--terminal"
                options.terminal_mode = TRUE
            case "-e", "--execute"
                options.command_mode = TRUE
            case "--preload"
                if i = _commandcount then
                    options.terminal_mode = TRUE
                    fatalerror arg$ + " requires argument"
                end if
                options.preload = locate_path$(command$(i + 1), _startdir$)
                i = i + 1
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
    if not options.interactive_mode and not options.compile_mode and _
        not options.command_mode then options.run_mode = TRUE
end sub

'$include: 'type.bm'
'$include: 'ast.bm'
'$include: 'symtab.bm'
'$include: 'parser/parser.bm'
'$include: 'emitters/dump/dump.bm'
'$include: 'emitters/immediate/immediate.bm'

