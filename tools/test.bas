'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'test.bas - Run test programs though 65

deflng a-z
$console:only
_dest _console

type test_unit_t
    title as string
    program as string
    expect as string
    expected_output as string
    success as long
end type
redim shared tests(0) as test_unit_t
dim shared active_test
dim shared active_section '0 = none, 1 = program, 2 = output

on error goto ehandler

if _commandcount < 1 then
    print "Usage: "; command$(0); " "; "<test files>"
    system 1
end if

for cmdline_index = 1 to _commandcount
    open command$(cmdline_index) for binary as #1
    while not eof(1)
        line input #1, l$
        lt$ = ltrim$(l$)
        if left$(lt$, 7) = "$title:" then
            new_test_unit
            tests(active_test).title = ltrim$(mid$(lt$, 8))
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
next cmdline_index

for active_test = 1 to ubound(tests)
    print "TITLE: "; tests(active_test).title
    print "PROGRAM"
    print "-------"
    print tests(active_test).program;
    print "EXPECT: "; tests(active_test).expect
    print tests(active_test).expected_output;
next active_test

system

ehandler:
    print "Error"; err; "on line"; _errorline
    system 2

sub new_test_unit
    active_test = ubound(tests) + 1
    redim _preserve tests(1 to active_test) as test_unit_t
    tests(active_test).success = 0
end sub
