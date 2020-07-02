'$dynamic
$console
$screenhide
_dest _console
deflng a-z
const FALSE = 0, TRUE = not FALSE
on error goto error_handler

dim shared VERSION$
VERSION$ = "initial dev. version"

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

'$include: 'type.bi'
'$include: 'htable.bi'
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
    debug as integer
end type

dim shared options as options_t
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
    interactive_mode
elseif options.command_mode then
    command_mode
else
    'Output file defaults to input file with .bas changed to .exe (or nothing on Unix)
    if options.outputfile = "" then options.outputfile = remove_ext$(options.mainarg) + exe_suffix$
    if instr("/", left$(options.mainarg, 1)) = 0 then options.mainarg = _startdir$ + "/" + options.mainarg
    if instr("/", left$(options.outputfile, 1)) = 0 then options.outputfile = _startdir$ + "/" + options.outputfile
    compile_mode
end if

end

error_handler:
    select case Error_context
    case 0, 3 'Unknown or dump mode
        if _inclerrorline then
            print "Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
        else
            print "Internal error" + str$(err) + " on line" + str$(_errorline)
        end if
    case 1 'Parsing code
        print "Line" + str$(ps_actual_linenum) + ": " + Error_message$
    case 2 'Immediate mode
        print "Runtime error" + str$(err)
        if _inclerrorline then
            print "Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
        else
            print "Internal error" + str$(err) + " on line" + str$(_errorline)
        end if
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

sub interactive_mode
    tok_init
    imm_init
    open "SCRN:" for output as #1
    do
        ast_init 'Clear the tree each time
        Error_context = 1
        node = ps_stmt
        Error_context = 0
        if options.debug then
            Error_context = 3
            ast_dump_pretty node, 0
            Error_context = 0
            print #1,
        end if
        imm_reinit
        Error_context = 2
        imm_run node
        Error_context = 1
        ps_consume TOK_NEWLINE
        Error_context = 0
    loop
end sub

sub command_mode
    ast_init
    tok_init
    imm_init
    open "SCRN:" for output as #1
    Error_context = 1
    root = ps_block
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
    if options.run_mode then
        imm_init
        Error_context = 2
        imm_run root
        Error_context = 0
    else
        open options.outputfile for output as #1
        Error_context = 3
        dump_program root
        Error_context = 0
        close #1
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
    print "  -c <cmd>, --command <cmd>        Execute the statement or statements <cmd>,"
    print "                                   then exit."
    print "  -d, --debug                      For debugging 65 itself"
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
            case "-r", "--run"
                options.run_mode = TRUE
            case "-t", "--terminal"
                options.terminal_mode = TRUE
            case "-c", "--command"
                options.command_mode = TRUE
            case else
                if left$(arg$, 1) = "-" then
                    options.terminal_mode = TRUE
                    fatalerror "Unknown option " + arg$
                end if
                if options.mainarg <> "" then
                    options.terminal_mode = TRUE
                    fatalerror "Unexpected argument " + arg$
                end if
                options.mainarg = arg$
        end select
    next i
    if options.mainarg = "" then options.interactive_mode = TRUE
end sub

'$include: 'type.bm'
'$include: 'ast.bm'
'$include: 'htable.bm'
'$include: 'parser/parser.bm'
'$include: 'emitters/dump/dump.bm'
'$include: 'emitters/immediate/immediate.bm'

