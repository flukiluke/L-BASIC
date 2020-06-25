'$include: 'common/start.bi'
'$include: 'common/type.bi'
'$include: 'common/htable.bi'
'$include: 'common/ast.bi'
'$include: 'parser/parser.bi'

basedir$ = _startdir$ 'Data files relative to here

type options_t
    inputfile as string
    outputfile as string
    verbose as integer
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
    print "Output file: "; options.outputfile
end if

ast_init
open options.inputfile for input as #1
root = ps_block
close #1

open options.outputfile for output as #1
dump_program root
close #1

system

'$include: 'common/error.bm'

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
    print "  -v, --verbose                    Be descriptive about what is happening"
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
            case else
                if left$(arg$, 1) = "-" then fatalerror "Unknown option " + arg$
                if options.inputfile <> "" then fatalerror "Unexpected argument " + arg$
                options.inputfile = arg$
        end select
    next i
end sub

'$include: 'common/ast.bm'
'$include: 'common/htable.bm'
'$include: 'common/type.bm'
'$include: 'parser/parser.bm'
'$include: 'emitters/dump/dump.bm'

