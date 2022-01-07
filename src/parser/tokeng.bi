'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'tokeng.bi - Delcarations for tokeniser engine

'$include: 'ts_data.bi'
'$include: 'token_data.bi'

type tokeniser_state_t
    index as long
    curstate as long
    has_data as long
    linestart as long
    recovery_mode as long
    raw_line_in as string
end type

dim shared tokeng_state as tokeniser_state_t

dim shared tok_content$
dim shared tok_token as long
dim shared tok_next_content$
dim shared tok_next_token as long

'Used to map TS_ to TOK_
dim shared tok_direct(1 to TS_MAX)
