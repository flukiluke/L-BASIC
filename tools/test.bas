'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'test.bas - Run test suite

deflng a-z
$console:only
_dest _console
randomize timer

type test_unit_t
    title as string
    program as string
    expect as string
    expected_output as string
end type
redim tests(0) as test_unit_t
dim active_section '0 = none, 1 = program, 2 = output

on error goto ehandler

if _commandcount < 2 then
    print "Usage: "; command$(0); " <test program> <test files>"
    system 1
end if

if instr(_os$, "WINDOWS") then
    tmpdir$ = environ$("TEMP") + "\"
else
    tmpdir$ = "/tmp/"
end if

testbinary$ = command$(1)
chdir _startdir$
for cmdline_index = 2 to _commandcount
    open command$(cmdline_index) for binary as #1
    while not eof(1)
        line input #1, l$
        lt$ = ltrim$(l$)
        if left$(lt$, 7) = "$title:" then
            active_test = ubound(tests) + 1
            redim _preserve tests(1 to active_test) as test_unit_t
            tests(active_test).title = basename$(command$(cmdline_index)) + ":" + ltrim$(mid$(lt$, 8))
            active_section = 1
        elseif left$(lt$, 8) = "$expect:" then
            tests(active_test).expect = ltrim$(mid$(lt$, 9))
            active_section = 2
        elseif left$(lt$, 7) = "$finish" then
            active_section = 0
        elseif active_section = 1 then
            tests(active_test).program = tests(active_test).program + l$ + chr$(10)
        elseif active_section = 2 then
            tests(active_test).expected_output = tests(active_test).expected_output + l$ + chr$(10)
        elseif lt$ = "" or left$(lt$, 1) = "#" or left$(lt$, 1) = "'" then
            'Blank line or comment, do nothing
        else
            print "Must start with $title"
            system 1
        end if
    wend
    close #1
next cmdline_index

starttime! = timer(0.001)
for active_test = 1 to ubound(tests)
    'print "TITLE: "; tests(active_test).title
    'print "PROGRAM"
    'print "-------"
    'print tests(active_test).program;
    'print "EXPECT: "; tests(active_test).expect
    'print tests(active_test).expected_output;
    
    print tests(active_test).title; ": ";
    filename$ = tmpdir$ + "test-" + rndhex$(4)
    open filename$ + ".bas" for output as #1
    print #1, tests(active_test).program
    close #1
    retcode = shell(testbinary$ + " " + filename$ + ".bas > " + filename$ + ".output")
    select case tests(active_test).expect
    case "error"
        if retcode > 0 then
            print "OK"
            successes = successes + 1
        else
            print "Failed, expected error but ran successfully."
        end if
    case "silence"
        open filename$ + ".output" for binary as #1
        actual_output$ = space$(lof(1))
        get #1, , actual_output$
        close #1
        actual_output$ = remove_char$(actual_output$, chr$(13))
        if retcode > 0 then
            print "Failed with error, output was: "; actual_output$
        elseif len(actual_output$) = 0 then
            print "OK"
            successes = successes + 1
        else
            print "Failed!"
            print "Expected silence, actual: "; actual_output$
        end if
        
    case "stdout", "stdout_exact"
        open filename$ + ".output" for binary as #1
        actual_output$ = space$(lof(1))
        get #1, , actual_output$
        close #1
        actual_output$ = remove_char$(actual_output$, chr$(13))
        tests(active_test).expected_output = remove_char$(tests(active_test).expected_output, chr$(13))
        if tests(active_test).expect <> "stdout_exact" then
            actual_output$ = strip$(actual_output$)
            tests(active_test).expected_output = strip$(tests(active_test).expected_output)
        end if
        if retcode > 0 then
            print "Failed with error, output was: "; actual_output$
        elseif actual_output$ = tests(active_test).expected_output then
            print "OK"
            successes = successes + 1
        else
            print "Failed!"
            print "Expected: "; tests(active_test).expected_output
            print "  Actual: "; actual_output$
        end if
    case else
        print "Unknown condition"
    end select
    kill filename$ + ".bas"
    kill filename$ + ".output"
next active_test
endtime! = timer(0.001)

print "Total"; str$(successes); "/"; ltrim$(str$(ubound(tests))); " OK in"; int((endtime! - starttime!) * 10) / 10; "seconds"

system

ehandler:
    print "Error"; err; "on line"; _errorline
    system 2

function basename$(path$)
    dot = _instrrev(path$, ".")
    slash = _instrrev(path$, "/")
    basename$ = mid$(path$, slash + 1, dot - slash - 1)
end function

function rndhex$(length)
    for i = 1 to length
        result$ = result$ + hex$(int(rnd * 256))
    next i
    rndhex$ = result$
end function

'Courtesy Ed Davis
function remove_char$(s$, c$)
  dim s2$
  dim i as integer

  s2$ = ""
  for i = 1 to len(s$)
    if mid$(s$, i, 1) <> c$ then
      s2$ = s2$ + mid$(s$, i, 1)
    end if
  next
  remove_char$ = s2$
end function

'Remove whitespace from start and end of every line
function strip$ (s$)
    whitespace$ = chr$(9) + chr$(32)
    redim lines(0) as string
    split s$, chr$(10), lines()
    for i = lbound(lines) to ubound(lines)
        start = 0
        do
            start = start + 1
        loop while start <= len(lines(i)) and instr(whitespace$, mid$(lines(i), start, 1))
        finish = len(lines(i)) + 1
        do
            finish = finish - 1
        loop while finish >=1 and instr(whitespace$, mid$(lines(i), finish, 1))
        lines(i) = mid$(lines(i), start, finish - start + 1)
    next i
    strip$ = join(lines(), chr$(10))
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

'Combine all elements of in$() into a single string with delimiter$ separating the elements.
function join$(in$(), delimiter$)
    result$ = in$(lbound(in$))
    for i = lbound(in$) + 1 to ubound(in$)
        result$ = result$ + delimiter$ + in$(i)
    next i
    join$ = result$
end function
