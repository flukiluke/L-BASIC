'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'incmerge.bas - Include Merger
'Merge a .bas file and all its $include files into one.
'Updated to run from a bin directory (ie: /usr/bin)
'Added terminal display and switch (-s) for silent mode
'Updated to allow search for include and INCLUDE in source code

$CONSOLE:ONLY
_DEST _CONSOLE

DEFLNG A-Z
DIM SHARED AS INTEGER inclCount, silentSW
DIM SHARED pwd$
inclCount = 0: silentSW = 0

ON ERROR GOTO ehandler

IF _COMMANDCOUNT < 2 OR _COMMANDCOUNT > 3 THEN
    PRINT "Usage: "; COMMAND$(0); " "; "<input file> <output file> OR "; COMMAND$(0); " "; "-s <input file> <output file>"
    SYSTEM 1
END IF

IF _COMMANDCOUNT = 3 THEN
	IF COMMAND$(1) = "-s" OR COMMAND$(1) = "-S" THEN silentSW = -1
END IF

IF NOT silentSW THEN PRINT "incmerge - QB64 Include Merger v1.0"

pwd$ = _STARTDIR$
CHDIR pwd$

IF _COMMANDCOUNT = 3 THEN
	OPEN COMMAND$(3) FOR OUTPUT AS #1
	process COMMAND$(2)
	CLOSE #1
ELSE
	OPEN COMMAND$(2) FOR OUTPUT AS #1
	process COMMAND$(1)
	CLOSE #1
END IF

SYSTEM

ehandler:
	PRINT USING "Error ### at line ## - &"; err; _ERRORLINE; _ERRORMESSAGE$
    SYSTEM 1

SUB process (filename$)
	inclCount = inclCount + 1
	IF NOT silentSW THEN
		IF inclCount > 1 THEN PRINT "    Include File Found: "; filename$
	END IF
    fh = FREEFILE
    IF _FILEEXISTS(filename$) THEN
		OPEN filename$ FOR BINARY AS #fh
		DO
			LINE INPUT #fh, l$
			IF INSTR(LTRIM$(l$), "'$include") = 1 OR INSTR(LTRIM$(l$), "'$INCLUDE") THEN
				t$ = LTRIM$(l$)
				q1 = INSTR(2, t$, "'")
				q2 = INSTR(q1 + 1, t$, "'")
				process MID$(t$, q1 + 1, q2 - q1 - 1)
			ELSE
				PRINT #1, l$
			END IF
		LOOP UNTIL EOF(fh)
	ELSE
		PRINT USING "Error - File: & Not Found."; filename$
		CLOSE #fh
		KILL COMMAND$(2)
		SYSTEM 1
	END IF	
    CLOSE #fh
    
END SUB

