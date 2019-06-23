'$include: '../../build/ts_data.bi'
'$include: '../../build/token_data.bi'

type tokeniser_state_t
    index as long
    curstate as long
    has_data as long
    linestart as long
    prefill as long
end type

dim shared tokeng_state as tokeniser_state_t
dim shared tokeng_repeat_token as long
dim shared tokeng_repeat_literal$

tok_init
