'$include: '../build/ts_data.bi'
'$include: '../build/token_data.bi'

type tokeniser_state_t
    index as long
    curstate as long
    has_data as long
    linestart as long
    tok_override as long
end type
