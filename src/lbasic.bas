''Copyright Luke Ceddia
''
''Licensed under the Apache License, Version 2.0 (the "License");
''you may not use this file except in compliance with the License.
''You may obtain a copy of the License at
''
''  http://www.apache.org/licenses/LICENSE-2.0
''
''Unless required by applicable law or agreed to in writing, software
''distributed under the License is distributed on an "AS IS" BASIS,
''WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
''See the License for the specific language governing permissions and
''limitations under the License.
'
'lbasic.bas - Main file for L-BASIC Compiler

$if VERSION < 2.0 then
    'We use zero-place predicate recursion which is only available in 2.0
    $error QB64 V2.0 or greater required
$end if

$include: 'debugging_options.bm'

dim shared VERSION$
VERSION$ = "0.1.2"

$dynamic
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
const ERR_CTX_UNKNOWN = 0 'Unknown location
const ERR_CTX_PARSING = 1 'Implies parser line number is valid
const ERR_CTX_REPL = 2 'Immediate runtime (interactive)
const ERR_CTX_DUMP = 3 'Dump code
const ERR_CTX_FILE = 4 'Trying to open a file
const ERR_CTX_RUN = 5 'Immediate runtime (non-interactive)
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
'The current "reading" file is input_files(input_files_current).
'Note that unlike other arrays, we never remove entries from this one. This allows
'us to use the index as a reference to the file for generating diagnostics later on.
'input_files(1) is used to represent user input.
type input_file_t
    handle as long
    'Directory containing the file, further includes are relative to this
    dirname as string
    'To be used only for diagnostic messages
    filename as string
    'Set TRUE if we have finished reading the file
    finished as long
    'The index of the file that triggered the inclusion of this one
    included_by as long
end type
redim shared input_files(1) as input_file_t
input_files(1).filename = "[interactive]"
dim shared input_files_current
'The logging output is used for debugging output
dim shared logging_file_handle

const MODE_REPL = 1
const MODE_RUN = 2
const MODE_BUILD = 3
const MODE_FORMAT = 4
const MODE_EXEC = 5
const MODE_DUMP = 6

'Various global options read from the command line
type options_t
    mainarg as string
    preload as string
    outputfile as string
    terminal_mode as integer
    oper_mode as integer
    debug as integer
end type
dim shared options as options_t

'Allow immediate mode to access COMMAND$() without picking up interpreter options
dim shared input_file_command_offset

'Ensure that file accesses are relative to the users's working directory
chdir _startdir$

$include: 'cmdflags.bi'
$include: 'type.bi'
$include: 'symtab.bi'
$include: 'ast.bi'
$include: 'parser/parser.bi'
$include: 'emitters/immediate/immediate.bi'

parse_cmd_line_args
if not options.terminal_mode then
    _screenshow
    _dest 0
end if

'Send out debugging info to the screen
logging_file_handle = freefile
open_file "SCRN:", logging_file_handle, TRUE

'Setup AST, constants and parser settings. These must be done before
'preloading any files which is why they are here and not in
'ingest_initial_file.
ast_init
ps_init

'Preload files can override built-in commands; handle that now
if options.preload <> "" then preload_file

'Dispatch based on desired mode of operation
select case options.oper_mode
    case MODE_REPL
        interactive_mode FALSE
    case MODE_RUN
        run_mode
    case MODE_BUILD
        build_mode
    case MODE_FORMAT
        format_mode
    case MODE_EXEC
        exec_mode
    case MODE_DUMP
    $if DEBUG_DUMP then
        dump_mode
    $end if
end select

if options.terminal_mode then system else end

interactive_recovery:
    interactive_mode TRUE

error_handler:
    Error_occurred = TRUE
    old_dest = _dest
    if not options.terminal_mode then
        _dest 0
    else
        _dest _console
    end if
    select case Error_context
    case ERR_CTX_PARSING
        print "Parser: ";
        if err <> 101 then goto internal_error
        if options.oper_mode = MODE_REPL and options.preload = "" then
            print Error_message$
            Error_message$ = ""
            _dest old_dest
            resume interactive_recovery
        else
            if options.preload <> "" then print "In preload file: ";
            print "Line" + str$(ps_actual_linenum) + ": " + Error_message$
        end if
    case ERR_CTX_REPL, ERR_CTX_RUN
        'We have no good way of distinguishing between user program errors and internal errors
        'Of course, the internal code is perfect so it *must* be a user program error
        print "Runtime error: ";
        if err = 101 then print Error_message$; else print _errormessage$(err);
        print " ("; _trim$(str$(err)); "/"; _inclerrorfile$; ":"; _trim$(str$(_inclerrorline)); ")"
        imm_show_eval_stack
        if Error_context = ERR_CTX_REPL then resume interactive_recovery
    case ERR_CTX_DUMP
        print "Dump: ";
        if err <> 101 then goto internal_error
        print Error_message$
    case ERR_CTX_FILE 'File access check
        _dest old_dest
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
    if options.debug then
        old_dest = _dest
        if not options.terminal_mode then
            _dest 0
        else
            _dest _console
        end if
        print msg$
        _dest old_dest
    end if
end sub

'This function and the next are called from tokeng.
'They provide a uniform way of loading the next line.
function general_next_line$
    if input_files_current = 1 then
        old_dest = _dest
        if not options.terminal_mode then
            _dest 0
        else
            _dest _console
        end if
        print "> ";
        line input s$
        _dest old_dest
    else
        line input #input_files(input_files_current).handle, s$
    end if
    general_next_line$ = s$
end function

function general_eof
    if input_files_current = 0 then
        'nothing is open
        general_eof = TRUE
    elseif input_files_current = 1 then
        'reading from console
        general_eof = FALSE
    else
        do
            finished = eof(input_files(input_files_current).handle)
            if finished then
                close #input_files(input_files_current).handle
                input_files_current = input_files(input_files_current).included_by
            end if
        loop while input_files(input_files_current).finished and input_files_current
        general_eof = input_files_current = 0
    end if
end function

sub add_input_file(filename$, as_include)
    redim _preserve input_files(ubound(input_files) + 1) as input_file_t
    u = ubound(input_files)
    input_files(u).handle = freefile
    input_files(u).filename = filename$
    if as_include then
        input_files(u).included_by = input_files_current
    else
        input_files(u).included_by = 0
    end if
    input_files(u).finished = FALSE
    input_files(u).dirname = dirname$(filename$)
    open_file filename$, input_files(u).handle, FALSE
    input_files_current = u
end sub

sub preload_file
    add_input_file options.preload, FALSE
    tok_init
    Error_context = ERR_CTX_PARSING
    ps_preload_file
    options.preload = ""
    Error_context = ERR_CTX_UNKNOWN
end sub

'Open a file and trigger a fatal error if we couldn't
sub open_file(filename$, handle, is_output)
    old_ctx = Error_context
    Error_context = ERR_CTX_FILE
    Error_occurred = FALSE
    if is_output then
        open filename$ for output as #handle
    else
        open filename$ for input as #handle
    end if
    if Error_occurred then fatalerror "Could not open file " + filename$
    Error_context = old_ctx
end sub

'This extracts a common prologue from the modes below
sub ingest_initial_file
    add_input_file options.mainarg, FALSE
    tok_init
    Error_content = ERR_CTX_PARSING
    ps_prepass
    add_input_file options.mainarg, FALSE
    tok_reinit
    ps_init
    ast_rollback
    AST_ENTRYPOINT = ps_block
    ps_finish_labels AST_ENTRYPOINT
    Error_context = ERR_CTX_UNKNOWN
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
        input_files_current = 1 'interactive input
        imm_init
        AST_ENTRYPOINT = ast_add_node(AST_BLOCK)
        ast_commit
        tok_init
        ps_init
    end if
    do
        Error_context = ERR_CTX_PARSING
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
            Error_context = ERR_CTX_UNKNOWN
            ast_attach AST_ENTRYPOINT, node
            $if DEBUG_PARSE_RESULT then
            if options.debug then
                Error_context = ERR_CTX_DUMP
                ast_dump_pretty AST_ENTRYPOINT, 0
                Error_context = ERR_CTX_UNKNOWN
                print #1,
            end if
            $end if
            'TODO remove this next line by adding the logic to imm_run or similar
            imm_reinit ps_scope_frame_size
            Error_context = ERR_CTX_REPL
            imm_run AST_ENTRYPOINT
            'Keep any symbols that were defined
            symtab_commit
            'But don't keep any nodes generated
            ast_rollback
            'And clear the main program
            ast_clear_entrypoint
        end select
        Error_context = ERR_CTX_PARSING
        ps_consume TOK_NEWLINE
    loop
end sub

sub run_mode
    ingest_initial_file
    imm_init
    Error_context = ERR_CTX_RUN
    imm_run AST_ENTRYPOINT
    Error_context = ERR_CTX_UNKNOWN
    $if DEBUG_HEAP then
    if options.debug then imm_heap_stats
    $end if
end sub

sub build_mode
    if options.outputfile = "" then
        options.outputfile = remove_ext$(options.mainarg) + target_platform_settings.executable_extension
    end if
    ingest_initial_file
    print "Parse finished but building currently unsupported."
end sub

sub format_mode
    ingest_initial_file
end sub

sub exec_mode
    tok_init
    Error_content = ERR_CTX_PARSING
    root = ps_block
    Error_context = ERR_CTX_UNKNOWN
    $if DEBUG_PARSE_RESULT then
    if options.debug then
        Error_context = ERR_CTX_DUMP
        dump_ast root, 0
        Error_context = ERR_CTX_UNKNOWN
        print #1,
    end if
    $end if
    imm_init
    Error_context = ERR_CTX_RUN
    imm_run root
    Error_context = ERR_CTX_UNKNOWN
end sub

$if DEBUG_DUMP then
sub dump_mode
    ingest_initial_file
    close #logging_file_handle
    logging_file_handle = freefile
    open_file options.outputfile, logging_file_handle, TRUE
    Error_context = ERR_CTX_DUMP
    dump_program
    Error_context = ERR_CTX_UNKNOWN
    close #1
end sub
$end if

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

'Split in$ into pieces, chopping at every occurrence of delimiter$. Multiple consecutive occurrences
'of delimiter$ are treated as a single instance. The chopped pieces are stored in result$().
'
'result$() must have been REDIMmed previously.
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

sub show_version
    print "The L-BASIC compiler version " + VERSION$
    if Debug_features$ <> "" then print "Debug features enabled: " + Debug_features$
end sub

sub show_help
    show_version
    print "Usage: " + command$(0) + " COMMAND [OPTIONS] [FILE]"
    print '                                                                                '80 columns
    print "Options:"
    print "  -o, --output                     Compilation or format output"
    print "  -t, --terminal                   Do not open a graphical window"
    print "  --preload FILE                   Load FILE before parsing main program"
    if Debug_features$ <> "" then
        print "  -d, --debug                      Output internal debugging info"
    end if
    print "  -h, --help                       Print this help message"
    print "  --version                        Print version information"
    print
    print "Commands:"
    print "  repl        Interactive read-evaluate-print loop"
    print "  run         Run a program immediately, without compilation"
    print "  build       Compile a program to a binary executable"
    print "  format      Format and prettify a source code file"
    print "  exec        Run a code fragment supplied on the command line"
    $if DEBUG_DUMP then
    print "  dump        Output a textual representation of the read program"
    $end if
    print
    print "The interactive repl may also be entered by supplying no command."
    print "A file may be run by supplying just the file name without the 'run' command."
    print
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
            case "-t", "--terminal"
                options.terminal_mode = TRUE
            case "--preload"
                if i = _commandcount then
                    options.terminal_mode = TRUE
                    fatalerror arg$ + " requires argument"
                end if
                options.preload = locate_path$(command$(i + 1), _startdir$)
                i = i + 1
            case "repl", "run", "build", "format", "exec"
                if cmd$ = "" then
                    cmd$ = arg$
                else
                    options.mainarg = arg$
                end if
            case else
                $if DEBUG_DUMP then
                if arg$ = "dump" then
                    if cmd$ = "" then
                        cmd$ = arg$
                    else
                        options.mainarg = arg$
                    end if
                    exit select
                end if
                $end if
                if left$(arg$, 1) = "-" then
                    options.terminal_mode = TRUE
                    fatalerror "Unknown option " + arg$
                end if
                if options.mainarg = "" then
                    options.mainarg = arg$
                    if cmd$ = "" or cmd$ = "run" or cmd$ = "exec" then
                        'If we are going to execute this now, we will interpret the rest
                        'of the command line as arguments to the program itself.
                        input_file_command_offset = i
                        exit for
                    end if
                else
                    options.terminal_mode = TRUE
                    fatalerror "Unknown command " + arg$
                end if
        end select
    next i
    select case cmd$
        case ""
            if options.mainarg = "" then
                options.oper_mode = MODE_REPL
            else
                options.oper_mode = MODE_RUN
            end if
        case "repl"
            if options.mainarg <> "" then e$ = "Unknown command " + options.mainarg
            options.oper_mode = MODE_REPL
        case "run"
            if options.mainarg = "" then e$ = "File name required"
            options.oper_mode = MODE_RUN
        case "build"
            if options.mainarg = "" then e$ = "File name required"
            options.oper_mode = MODE_BUILD
        case "format"
            if options.outputfile = "" then e$ = "Output file required"
            if options.mainarg = "" then e$ = "File name required"
            options.oper_mode = MODE_FORMAT
        case "dump"
            if options.outputfile = "" then e$ = "Output file required"
            if options.mainarg = "" then e$ = "File name required"
            options.oper_mode = MODE_DUMP
        case "exec"
            options.oper_mode = MODE_EXEC
    end select
    if e$ <> "" then
        options.terminal_mode = TRUE
        fatalerror e$
    end if
end sub

$include: 'type.bm'
$include: 'ast.bm'
$include: 'symtab.bm'
$include: 'parser/parser.bm'
$if DEBUG_DUMP then
$include: 'emitters/dump/dump.bm'
$end if
$include: 'emitters/immediate/immediate.bm'

