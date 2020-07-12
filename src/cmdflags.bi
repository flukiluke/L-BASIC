'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'cmdflags.bi - Flags for specifying aspects of a runtime function's behaviour.

const STMT_INPUT_NO_NEWLINE = 1 'Semicolon after INPUT
const STMT_INPUT_PROMPT = 2 'A prompt is given
const STMT_INPUT_NO_QUESTION = 4 'Comma after prompt string

const PRINT_NEXT_FIELD = 1 'A comma used after a variable moves to the next 14-char-wide field
const PRINT_NEWLINE = 2 'No comma or semicolon at the end of the list
'Note: a semicolon sets no flag

const GRAPHICS_STEP = 1 'Next args are coordinate that is relative
