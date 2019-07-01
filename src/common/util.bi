'$dynamic
$console:only
_dest _console
deflng a-z
const FALSE = 0, TRUE = not FALSE
randomize timer
on error goto generic_error

dim shared temp_files$(0)

$if win = 0 then
    declare library
        function getpid&
    end declare
$else
    declare library
        function getpid& alias _getpid&
    end declare
$end if

dim shared exesuffix$
dim shared tmpdir$

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
