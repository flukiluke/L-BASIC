'$include: 'common/util.bi'

dim shared VERSION$
VERSION$ = "initial dev. version"

execdir$ = _cwd$ 'Programs to be executed relative to here
basedir$ = _startdir$ 'Data files relative to here

type options_t
    inputfile as string
    outputfile as string
    target as string
    keep_intermediates as integer
    verbose as integer
end type

dim shared options as options_t
parse_cmd_line_args

'Output file defaults to input file with .bas changed to .exe (or nothing on Unix)
if options.inputfile = "" then fatalerror "No input files"
if options.outputfile = "" then options.outputfile = remove_ext$(options.inputfile) + exeSuffix$
if options.target = "" then options.target = "dump"

'Relative paths should be relative to the basedir$
if instr("\/", left$(options.inputfile, 1)) = 0 then options.inputfile = basedir$ + "/" + options.inputfile
if instr("\/", left$(options.outputfile, 1)) = 0 then options.outputfile = basedir$ + "/" + options.outputfile

if options.verbose then
    show_version
    print "Input file: "; options.inputfile
    print "Output file: "; options.outputfile
    print "Target: "; options.target
    print "Temporary files will be stored in "; tmpdir$
end if

parser_output$ = mktemp$(tmpdir$)
parser_cmd$ = execdir$ + "/parser" + exesuffix$ + " " + escape$(options.inputfile) + " " + escape$(parser_output$)
if options.verbose then print "Executing "; parser_cmd$
parser_ret = shell(parser_cmd$)
if parser_ret <> 0 then
    if options.verbose then print "Return code"; parser_ret; "; exiting"
    cleanup
    system 1
end if

target_cmd$ = execdir$ + "/" + options.target + exesuffix$ + " " + escape$(parser_output$) + " " + escape$(options.outputfile)
if options.verbose then print "Executing "; target_cmd$
target_ret = shell(target_cmd$)
if target_ret <> 0 then
    if options.verbose then print "Return code"; target_ret; "; exiting"
    cleanup
    system 1
end if

cleanup
system

'$include: 'common/util.bm'

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
    print "Advanced options:"
    print "  --list-targets                   List all available runtime targets"
    print "  -t <target>, --target <target>   Select a particular runtime target"
    print "  -k, --keep-intermediates         Do not delete intermediate compilation files"
    print "  -v, --verbose                    Be descriptive about what is happening"
end sub

sub list_targets
    print "Available targets:"
    print "  dump - Render program data as plain text for debugging"
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
            case "--list-targets"
                list_targets
                system
            case "-t", "--target"
                if i = _commandcount then fatalerror arg$ + " requires argument"
                options.target = command$(i + 1)
                i = i + 1
            case "-k", "--keep-intermediates"
                options.keep_intermediates = TRUE
            case "-v", "--verbose"
                options.verbose = TRUE
            case else
                if left$(arg$, 1) = "-" then fatalerror "Unknown option " + arg$
                if options.inputfile <> "" then fatalerror "Unexpected argument " + arg$
                options.inputfile = arg$
        end select
    next i
end sub

