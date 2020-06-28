'$dynamic
$console
$screenhide
deflng a-z
const FALSE = 0, TRUE = not FALSE
on error goto generic_error

dim shared VERSION$
VERSION$ = "initial dev. version"

'$include: 'type.bi'
'$include: 'htable.bi'
'$include: 'ast.bi'
'$include: 'parser/parser.bi'
'$include: 'emitters/immediate/immediate.bi'

basedir$ = _startdir$ 'Data files relative to here

type options_t
    inputfile as string
    outputfile as string
    run_mode as integer
    interactive_mode as integer
    terminal_mode as integer
    debug as integer
end type

dim shared options as options_t
parse_cmd_line_args

if instr(_os$, "[WINDOWS]") then
    exe_suffix$ = ".exe"
else
    exe_suffix$ = ""
end if

'Output file defaults to input file with .bas changed to .exe (or nothing on Unix)
if options.outputfile = "" then options.outputfile = remove_ext$(options.inputfile) + exe_suffix$

'Relative paths should be relative to the basedir$
if instr("/", left$(options.inputfile, 1)) = 0 then options.inputfile = basedir$ + "/" + options.inputfile
if instr("/", left$(options.outputfile, 1)) = 0 then options.outputfile = basedir$ + "/" + options.outputfile

if options.terminal_mode then
    _dest _console
else
    _screenshow
end if

if options.interactive_mode then
    interactive_mode
else
    ast_init
    if options.inputfile = "" then fatalerror "No input file"
    infh = freefile
    open options.inputfile for input as #infh
    tok_init infh
    root = ps_block
    close #infh
    if options.run_mode then
        on error goto runtime_error
        imm_init
        imm_run root
    else
        open options.outputfile for output as #1
        dump_program root
        close #1
    end if
end if

end

'Used by immediate mode
runtime_error:
    if err = 6 then fatalerror "Overflow"
'Error handler for everything else
generic_error:
    if _inclerrorline then
        fatalerror "Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
    else
        fatalerror "Internal error" + str$(err) + " on line" + str$(_errorline)
    end if

sub fatalerror (msg$)
    print "Error on line" + str$(ps_actual_linenum) + ": " + msg$
    end 1
end sub

sub debuginfo (msg$)
    if options.debug then print msg$
end sub

sub interactive_mode
    tok_init -1
    imm_init
    open "SCRN:" for output as #1
    do
        ast_init 'Clear the tree each time
        node = ps_stmt
        ast_dump_pretty node, 0
        print #1,
        imm_reinit
        imm_run node
        ps_consume TOK_NEWLINE
    loop
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
    print "The '65 compiler (" + VERSION$ + ")"
    print "This version is still under heavy development!"
end sub

sub show_help
    print "The '65 compiler (" + VERSION$ + ")"
    print "Usage: " + command$(0) + " <options> <inputfile>"
    print '                                                                                '80 columns
    print "Basic options:"
    print "  -h, --help                       Print this help message"
    print "  --version                        Print version information"
    print "  -o <file>, --output <file>       Place the output into <file>"
    print "  -t, --terminal                   Run in terminal mode (no graphical window)."
    print "  -r, --run                        Generate no output file, run the program now."
    print "  -d, --debug                      For debugging 65 itself"
end sub

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
                if i = _commandcount then fatalerror arg$ + " requires argument"
                options.outputfile = command$(i + 1)
                i = i + 1
            case "-d", "--debug"
                options.debug = TRUE
            case "-r", "--run"
                options.run_mode = TRUE
            case "-t", "--terminal"
                options.terminal_mode = TRUE
            case else
                if left$(arg$, 1) = "-" then fatalerror "Unknown option " + arg$
                if options.inputfile <> "" then fatalerror "Unexpected argument " + arg$
                options.inputfile = arg$
        end select
    next i
    if options.inputfile = "" then options.interactive_mode = TRUE
end sub

'$include: 'type.bm'
'$include: 'ast.bm'
'$include: 'htable.bm'
'$include: 'parser/parser.bm'
'$include: 'emitters/dump/dump.bm'
'$include: 'emitters/immediate/immediate.bm'

