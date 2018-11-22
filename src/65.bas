const FALSE = 0, TRUE = NOT FALSE
deflng a-z
$console:only
_dest _console
on error goto generic_error

'$include: 'htable.bi'
'$include: 'tokeng.bi'
'$include: 'ast.bi'

dim mainht as htable_t
htable_create mainht, 49

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
on error goto generic_error

dim t_state as tokeniser_state_t
tok_init t_state

ps_file t_state, mainht
system

file_error:
    fatalerror inputfile$ + ": Does not exist or inaccessible."

generic_error:
    if _inclerrorline then
        fatalerror "Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
    else
        fatalerror "Internal error" + str$(err) + " on line" + str$(_errorline)
    end if

sub ps_file (t_state as tokeniser_state_t, mainht as htable_t)
    root = 0 'Treat node 0 as the root of the AST
    ast_nodes(root).typ = AST_BLOCK
    do
        stmt = ps_stmt(t_state, mainht)
        if stmt = 0 then exit do 'use 0 to signal the end
        ast_attach root, stmt
    loop
end sub

function ps_stmt (t_state as tokeniser_state_t, ht as htable_t)
    print "Start statement"
    dim he as hentry_t
    result = tok_next_token(t_state, ht, he, literal$)
    select case he.typ
        case TOK_GENERIC, TOK_VARIABLE
            ' Assume implicit variable declaration
            if he.typ = TOK_GENERIC then
                he.typ = TOK_VARIABLE
                htable_add_hentry ht, literal$, he
            end if
            ps_stmt = ps_assignment(t_state, ht, he.id)
        case TOK_EOF
            ps_stmt = 0
        case else
            fatalerror "Syntax error: unexpected " + tok_human_readable$(he.typ)
    end select
    print "Completed statement"
end function

function ps_assignment (t_state as tokeniser_state_t, ht as htable_t, dest_id)
    print "Start assignment"
    dim he as hentry_t
    root = ast_add_node(AST_ASSIGN)
    dest = ast_add_node(AST_SREF)
    ast_nodes(dest).id = dest_id
    ast_attach root, dest

    result = tok_next_token(t_state, ht, he, literal$)
    ps_assert_token he.typ, TOK_EQUALS

    ast_attach root, ps_expr(t_state, ht)

    ps_assignment = root

    result = tok_next_token(t_state, ht, he, literal$)
    ps_assert_token he.typ, TOK_NEWLINE
    print "Completed assignment"
end function

function ps_expr(t_state as tokeniser_state_t, ht as htable_t)
    print "Start expr"
    dim he as hentry_t
    result = tok_next_token(t_state, ht, he, literal$)
    root = ast_add_node(AST_EXPR)
    ps_expr = root
    print "Completed expr"
end function
        
sub ps_assert_token(actual, expected)
    if actual <> expected then
        fatalerror "Syntax error: expected " + tok_human_readable(expected) + " got " + tok_human_readable(actual)
    else
        print "Assert " + tok_human_readable(expected)
    end if
end sub

sub fatalerror(msg$)
    print command$(0) + ": " + msg$
    system
end sub

'$include: 'htable.bm'
'$include: 'tokeng.bm'
'$include: 'ast.bm'
