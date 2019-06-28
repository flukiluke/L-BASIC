'$dynamic
$console:only
_dest _console
const FALSE = 0, TRUE = not FALSE
deflng a-z
randomize timer
on error goto generic_error

dim shared VERSION$
VERSION$ = "initial dev. version"

dim shared temp_files$(0)

$if win = 0 then
    declare library
        function getpid&
    end declare
$end if

if instr(_os$, "[WINDOWS]") then
    exesuffix$ = ".exe"
    'I have no idea if I'm doing this properly
    tmpdir$ = environ$("TEMP")
    if tmpdir$ = "" then tmpdir$ = "C:/TEMP"
else
    exesuffix$ = ""
    tmpdir$ = environ$("TMPDIR")
    if tmpdir$ = "" then tmpdir$ = "/tmp"
end if

execdir$ = _cwd$ 'Programs to be executed relative to here
basedir$ = _startdir$ 'Data files relative to here

type options_t
    inputfile as string
    outputfile as string
    target as string
    keep_intermediates as integer
    verbose as integer
end type

dim options as options_t
parse_cmd_line_args options

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
    system
end if

target_cmd$ = execdir$ + "/" + options.target + exesuffix$ + " " + escape$(parser_output$) + " " + escape$(options.outputfile)
if options.verbose then print "Executing "; target_cmd$
target_ret = shell(target_cmd$)
if target_ret <> 0 then
    if options.verbose then print "Return code"; target_ret; "; exiting"
    cleanup
    system
end if

cleanup
system

generic_error:
    cleanup
    if _inclerrorline then
        fatalerror "Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
    else
        fatalerror "Internal error" + str$(err) + " on line" + str$(_errorline)
    end if

sub cleanup
    for i = 1 to ubound(temp_files$)
        if _fileexists(temp_files$(i)) then kill temp_files$(i)
    next i
end sub

function escape$(original$)
    'The function is really not correct
    'A much better option would be to avoid using the shell entirely and use execv(3) or similar
    for i = 1 to len(original$)
        c$ = mid$(original$, i, 1)
        select case c$
            case "'"
                o$ = o$ + "\'"
            case "\"
                o$ = o$ + "\\" '"
            case else
                o$ = o$ + c$
        end select
    next i
    escape$ = o$
end function

'This would be so much easier if we could use mktemp(1)
function mktemp$(tmpdir$)
    redim _preserve temp_files$(1 to ubound(temp_files$) + 1)
    n$ = tmpdir$ + "/65-" + ltrim$(str$(getpid&)) + "-"
    for i = 1 to 8
        n$ = n$ + chr$(int(rnd * 26) + 97)
    next i
    temp_files$(ubound(temp_files$)) = n$
    mktemp$ = n$
end function

'Strip the .bas extension if present
function remove_ext$(fullname$)
    dot = _instrrev(fullname$, ".")
    if mid$(fullname$, dot + 1) = "bas" then
        remove_ext$ = left$(fullname$, dot - 1)
    else
        remove_ext$ = fullname$
    end if
end function

sub fatalerror (msg$)
    print "Error: " + msg$
    system 1
end sub
    
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

sub parse_cmd_line_args(options as options_t)
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

