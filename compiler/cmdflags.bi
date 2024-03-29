'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'cmdflags.bi - Flags for specifying aspects of a runtime function's behaviour.

const STMT_INPUT_NO_NEWLINE = 1 'Semicolon after INPUT
const STMT_INPUT_PROMPT = 2 'A prompt is given
const STMT_INPUT_NO_QUESTION = 4 'Comma after prompt string
const STMT_INPUT_LINEMODE = 8 'Actually a LINE INPUT command

const PRINT_NEXT_FIELD = 1 'A comma used after a variable moves to the next 14-char-wide field
const PRINT_NEWLINE = 2 'No comma or semicolon at the end of the list
'Note: a semicolon sets no flag

const PUTIMAGE_STEP_SRC1 = 1
const PUTIMAGE_STEP_SRC2 = 2
const PUTIMAGE_STEP_DEST1 = 4
const PUTIMAGE_STEP_DEST2 = 8
const PUTIMAGE_SMOOTH = 16

const OPEN_INPUT = 1
const OPEN_OUTPUT = 2
const OPEN_BINARY = 4
const OPEN_RANDOM = 8
'Concurrency options, not currently used
const OPEN_READ = 16
const OPEN_WRITE = 32
const OPEN_SHARED = 64
const OPEN_LOCK = 128
