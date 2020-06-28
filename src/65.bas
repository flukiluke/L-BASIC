'$dynamic
$console:only
_dest _console
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
    verbose as integer
    immediate_mode as integer
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
if options.inputfile = "" then fatalerror "No input file"
if options.outputfile = "" then options.outputfile = remove_ext$(options.inputfile) + exe_suffix$

'Relative paths should be relative to the basedir$
if instr("/", left$(options.inputfile, 1)) = 0 then options.inputfile = basedir$ + "/" + options.inputfile
if instr("/", left$(options.outputfile, 1)) = 0 then options.outputfile = basedir$ + "/" + options.outputfile

if options.verbose then
    show_version
    print "Input file: "; options.inputfile
    if options.immediate_mode then
        print "Immediate mode"
    else
        print "Output file: "; options.outputfile
    end if
end if

open options.inputfile for input as #1
ast_init
tok_init 1
root = ps_block
close #1

if options.immediate_mode then
    on error goto runtime_error
    imm_init
    imm_run root
else
    open options.outputfile for output as #1
    dump_program root
    close #1
end if

system

'Used by immediate mode
runtime_error:
    if err = 6 then fatalerror "Overflow"
'Error handler for everything else
generic_error:
    if _inclerrorline then
        fatalerror command$(0) + ": Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
    else
        fatalerror command$(0) + ": Internal error" + str$(err) + " on line" + str$(_errorline)
    end if

sub fatalerror (msg$)
    print "Error: " + msg$
    system 1
end sub

sub debuginfo (msg$)
    if options.debug then print msg$
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
    print "  -i, --immediate                  Generate no output file, run the program now."
    print "  -v, --verbose                    Be descriptive about what is happening"
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
            case "-v", "--verbose"
                options.verbose = TRUE
            case "-d", "--debug"
                options.debug = TRUE
            case "-i", "--immediate"
                options.immediate_mode = TRUE
            case else
                if left$(arg$, 1) = "-" then fatalerror "Unknown option " + arg$
                if options.inputfile <> "" then fatalerror "Unexpected argument " + arg$
                options.inputfile = arg$
        end select
    next i
end sub

'$include: 'type.bm'
'$include: 'ast.bm'
'$include: 'htable.bm'
'$include: 'parser/parser.bm'
'$include: 'emitters/dump/dump.bm'
'$include: 'emitters/immediate/immediate.bm'

