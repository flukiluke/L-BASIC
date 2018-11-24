const FALSE = 0, TRUE = NOT FALSE
deflng a-z
$console:only
_dest _console
on error goto generic_error

'$include: 'htable.bi'
'$include: 'tokeng.bi'
'$include: 'ast.bi'

dim he as hentry_t

he.typ = TOK_STMTREG
ignore = htable_add_hentry("_AUTODISPLAY", he)
ignore = htable_add_hentry("BEEP", he)
ignore = htable_add_hentry("CLS", he)

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

ps_file t_state
system

file_error:
    fatalerror inputfile$ + ": Does not exist or inaccessible."

generic_error:
    if _inclerrorline then
        fatalerror "Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
    else
        fatalerror "Internal error" + str$(err) + " on line" + str$(_errorline)
    end if

sub ps_file (t_state as tokeniser_state_t)
    root = 0 'Treat node 0 as the root of the AST
    ast_nodes(root).typ = AST_BLOCK
    do
        stmt = ps_stmt(t_state)
        if stmt = 0 then exit do 'use 0 to signal the end
        ast_attach root, stmt
    loop
end sub

function ps_stmt (t_state as tokeniser_state_t)
    print "Start statement"
    dim he as hentry_t
    token = tok_next_token(t_state, he, literal$)
    select case token
        case TOK_GENERIC, TOK_VARIABLE
            ' Assume implicit variable declaration
            if token = TOK_GENERIC then
                he.typ = TOK_VARIABLE
                sref = htable_add_hentry(ucase$(literal$), he)
            end if
            ps_stmt = ps_assignment(t_state, sref)
        case TOK_STMTREG
            print literal$
            
        case TOK_EOF
            ps_stmt = 0
        case else
            fatalerror "Syntax error: unexpected " + tok_human_readable$(he.typ)
    end select
    print "Completed statement"
end function

function ps_assignment (t_state as tokeniser_state_t, sref)
    print "Start assignment"
    dim he as hentry_t
    root = ast_add_node(AST_ASSIGN)
    dest = ast_add_node(AST_SREF)
    ast_nodes(dest).ref = sref
    ast_attach root, dest

    ps_assert_token tok_next_token(t_state, he, literal$), TOK_EQUALS

    ast_attach root, ps_expr(t_state)
    ps_assignment = root

    ps_assert_token tok_next_token(t_state, he, literal$), TOK_NEWLINE
    print "Completed assignment"
end function

function ps_expr(t_state as tokeniser_state_t)
    print "Start expr"
    dim he as hentry_t
    ignore = tok_next_token(t_state, he, literal$)
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
