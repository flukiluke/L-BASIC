const FALSE = 0, TRUE = NOT FALSE
$console:only
_dest _console
'on error goto generic_error

'$include: 'htable.bi'
'$include: 'tokeng.bi'

dim mainht as htable_t
htable_create mainht, 49

type hentry_t
    typ as long
end type
dim he as hentry_t
he.typ = TOK_STMTREG
htable_add_hentry mainht, "_AUTODISPLAY", he
htable_add_hentry mainht, "BEEP", he
htable_add_hentry mainht, "CLS", he

if _commandcount < 1 then
    inputfile$ = "/dev/stdin"
elseif _commandcount > 1 then
    fatalerror "Too many arguments."
else
    inputfile$ = command$(1)
end if

on error goto file_error
open inputfile$ for input as #1
'on error goto generic_error

dim t_state as tokeniser_state_t
tok_init t_state
do
    token_type& = tok_next_token&(t_state, mainht, he, literal$)
    print token_type&;
loop while token_type& <> TOK_EOF
print
system

file_error:
    fatalerror inputfile$ + ": Does not exist or inaccessible."

generic_error:
    if _inclerrorline then
        fatalerror "Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
    else
        fatalerror "Internal error" + str$(err) + " on line" + str$(_errorline)
    end if

sub fatalerror(msg$)
    print command$(0) + ": " + msg$
    system
end sub

'$include: 'htable.bm'
'$include: 'tokeng.bm'
