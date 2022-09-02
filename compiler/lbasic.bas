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
const ERR_CTX_LLVM = 6 'LLVM processing

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
    rtlib_dir as string
    linker as string
    link_opts as string
end type
dim shared as platform_t runtime_platform_settings, target_platform_settings
if instr(_os$, "[WINDOWS]") then
    runtime_platform_settings.id = "Windows"
    runtime_platform_settings.posix_paths = FALSE
    runtime_platform_settings.executable_extension = ".exe"
    runtime_platform_settings.rtlib_dir = _cwd$ + "/runtime"
    runtime_platform_settings.linker = "clang"
    runtime_platform_settings.link_opts = ""
elseif instr(_os$, "[MACOSX]") then
    runtime_platform_settings.id = "MacOS"
    runtime_platform_settings.posix_paths = TRUE
    runtime_platform_settings.executable_extension = ""
    runtime_platform_settings.rtlib_dir = _cwd$ + "/runtime"
    runtime_platform_settings.linker = "clang"
    runtime_platform_settings.link_opts = ""
elseif instr(_os$, "[LINUX]") then
    runtime_platform_settings.id = "Linux"
    runtime_platform_settings.posix_paths = TRUE
    runtime_platform_settings.executable_extension = ""
    runtime_platform_settings.rtlib_dir = _cwd$ + "/runtime"
    runtime_platform_settings.linker = "clang"
    runtime_platform_settings.link_opts = ""
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
const MODE_EXEC = 4

'Various build stages that may be disabled to control the final product
const BUILD_PARSE = 1  'Internal data tables
const BUILD_IR = 2     'LLVM IR
const BUILD_ASM = 4    'Platform-specific assembly
const BUILD_OBJ = 8    'Object file
const BUILD_LINK = 16    'Final linked executable

'Various global options read from the command line
type options_t
    mainarg as string
    preload as string
    outputfile as string
    terminal_mode as integer
    oper_mode as integer
    build_stages as long
    debug as integer
end type
dim shared options as options_t

'Allow immediate mode to access COMMAND$() without picking up interpreter options
dim shared input_file_command_offset

'Ensure that file accesses are relative to the user's working directory
chdir _startdir$

$include: 'cmdflags.bi'
$include: 'type.bi'
$include: 'symtab.bi'
$include: 'ast.bi'
$include: 'parser/parser.bi'
''$include: 'emitters/immediate/immediate.bi'
$include: 'emitters/llvm/llvm.bi'

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
    case MODE_BUILD
        build_mode
end select

if options.terminal_mode then system else end

interactive_recovery:
    system

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
        'imm_show_eval_stack
        if Error_context = ERR_CTX_REPL then resume interactive_recovery
    case ERR_CTX_DUMP
        print "Dump: ";
        if err <> 101 then goto internal_error
        print Error_message$
    case ERR_CTX_FILE 'File access check
        _dest old_dest
        resume next
    case ERR_CTX_LLVM
        print "codegen: ";
        if err <> 101 then goto internal_error
        print Error_message$
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
    Error_context = ERR_CTX_PARSING
    ps_prepass
    add_input_file options.mainarg, FALSE
    tok_reinit
    ps_init
    ast_rollback
    AST_ENTRYPOINT = ps_main
    Error_context = ERR_CTX_UNKNOWN
end sub

sub build_mode
    if options.outputfile = "" then
        basename$ = remove_ext$(options.mainarg)
        if options.build_stages and BUILD_LINK then
            options.outputfile = basename$ + target_platform_settings.executable_extension
        elseif options.build_stages and BUILD_OBJ then
            options.outputfile = basename$ + ".o"
        elseif options.build_stages and BUILD_ASM then
            options.outputfile = basename$ + ".s"
        elseif options.build_stages and BUILD_IR then
            options.outputfile = basename$ + ".bc"
        else
            options.outputfile = basename$ + ".parse"
        end if
    end if
    ingest_initial_file
    if options.build_stages = BUILD_PARSE then
        open_file options.outputfile, logging_file_handle, TRUE
        Error_context = ERR_CTX_DUMP
        dump_program
        close #1
    else
        Error_context = ERR_CTX_LLVM
        ll_build
    end if
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

function shell_protect$(s$)
    r$ = ""
    for i = 1 to len(s$)
        c$ = mid$(s$, i, 1)
        if c$ = "'" then
            r$ = r$ + "'\''"
        else
            r$ = r$ + c$
        end if
    next i
    shell_protect$ = "'" + r$ + "'"
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
    'print "Usage: " + command$(0) + " COMMAND [OPTIONS] [FILE]"
    print "Usage: " + command$(0) + " [OPTIONS] [FILE]"
    print '                                                                                '80 columns
    print "Options:"
    print "  -o, --output                     Compilation output"
    print "  -t, --terminal                   Do not open a graphical window"
    print "  --preload FILE                   Load FILE before parsing main program"
    if Debug_features$ <> "" then
        print "  -d, --debug                      Output internal debugging info"
    end if
    print "  -e, --emit STAGE                 Emit result of STAGE, one of:"
    print "                                     parse   Syntax check, AST and symbols"
    print "                                     ir      LLVM IR"
    print "                                     asm     Platform-specific assembly file"
    print "                                     obj     Compiled object file"
    print "  -h, --help                       Print this help message"
    print "  --version                        Print version information"
    exit sub
    print
    print "Commands:"
    print "  repl        Interactive read-evaluate-print loop"
    print "  run         Run a program immediately, without compilation"
    print "  build       Compile a program to a binary executable"
    print "  exec        Run a code fragment supplied on the command line"
    print "  dump        Output a textual representation of the read program"
    print
    print "The interactive repl may also be entered by supplying no command."
    print "A file may be run by supplying just the file name without the 'run' command."
end sub

'The error handling here fakes terminal_mode on the assumption that if you're
'using command line arguments you don't want a graphical window popping up.
sub parse_cmd_line_args()
    options.build_stages = BUILD_PARSE or BUILD_IR or BUILD_ASM or BUILD_OBJ or BUILD_LINK
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
            case "-e", "--emit"
                if i = _commandcount then
                    options.terminal_mode = TRUE
                    fatalerror arg$ + " requires argument"
                end if
                select case command$(i + 1)
                    case "parse"
                        options.build_stages = BUILD_PARSE
                    case "ir"
                        options.build_stages = BUILD_PARSE or BUILD_IR
                    case "asm"
                        options.build_stages = BUILD_PARSE or BUILD_IR or BUILD_ASM
                    case "obj"
                        options.build_stages = BUILD_PARSE or BUILD_IR or BUILD_ASM or BUILD_OBJ
                    case else
                        options.terminal_mode = TRUE
                        fatalerror arg$ + " expects one of parse, ir, asm, obj"
                end select
                i = i + 1
            case else
                if left$(arg$, 1) = "-" then
                    options.terminal_mode = TRUE
                    fatalerror "Unknown option " + arg$
                end if
                if options.mainarg = "" then options.mainarg = arg$
        end select
    next i
    options.oper_mode = MODE_BUILD
    if options.mainarg = "" then
        options.terminal_mode = TRUE
        fatalerror "File name required"
    end if
end sub

$include: 'type.bm'
$include: 'ast.bm'
$include: 'symtab.bm'
$include: 'parser/parser.bm'
$include: 'emitters/dump/dump.bm'
''$include: 'emitters/immediate/immediate.bm'
$include: 'emitters/llvm/llvm.bm'
