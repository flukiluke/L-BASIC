'$include: '../build/ts_data.bi'
'$include: '../build/token_data.bi'

type tokeniser_state_t
    index as long
    curstate as long
    has_data as long
    linestart as long
    tok_override as long
end type

'These are return codes from tok_next_token
'NOT_FOUND => Not in scope, we filled out hentry as best as we could
'FOUND => In scope, hentry is properly filled
'LITERAL => hentry.typ is set to the token type, but there is no further info that this token has associated with it (so we didn't bother doing a lookup).
const TOKENG_NOT_FOUND = 0
const TOKENG_FOUND = 1
const TOKENG_LITERAL = 2
