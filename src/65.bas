const FALSE = 0, TRUE = NOT FALSE
deflng a-z
$console:only
_dest _console
on error goto generic_error

'$include: 'htable.bi'
'$include: 'tokeng.bi'
'$include: 'pratt.bi'
'$include: 'ast.bi'

dim he as hentry_t

he.typ = TOK_STMTREG
ignore = htable_add_hentry("_AUTODISPLAY", he)
ignore = htable_add_hentry("BEEP", he)
ignore = htable_add_hentry("CLS", he)
he.typ = TOK_IF
ignore = htable_add_hentry("IF", he)
he.typ = TOK_THEN
ignore = htable_add_hentry("THEN", he)
he.typ = TOK_ENDIF
ignore = htable_add_hentry("ENDIF", he)
he.typ = TOK_PLUS
ignore = htable_add_hentry("+", he)

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

ast_dump_pretty ps_block
system

file_error:
    fatalerror inputfile$ + ": Does not exist or inaccessible."

generic_error:
    if _inclerrorline then
        fatalerror "Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
    else
        fatalerror "Internal error" + str$(err) + " on line" + str$(_errorline)
    end if

sub ps_gobble(token)
    dim he as hentry_t
    do
        t = tok_next_token(he, literal$)
    loop until t <> token or t = TOK_EOF
    tok_please_repeat
end sub
    

function ps_block
    print "Start block"
    dim he as hentry_t
    root = ast_add_node(AST_BLOCK)
    do
        ps_gobble(TOK_NEWLINE)
        stmt = ps_stmt
        if stmt = 0 then exit do 'use 0 to signal the end of a block
        ast_attach root, stmt
    loop
    ps_block = root
    print "End block"
end function

function ps_stmt
    print "Start statement"
    dim he as hentry_t
    token = tok_next_token(he, literal$)
    select case token
        case TOK_GENERIC, TOK_VARIABLE
            ' Assume implicit variable declaration
            if token = TOK_GENERIC then
                he.typ = TOK_VARIABLE
                sref = htable_add_hentry(ucase$(literal$), he)
            end if
            ps_stmt = ps_assignment(sref)
        case TOK_STMTREG
            ps_stmt = ps_stmtreg(he)
        case TOK_IF
            ps_stmt = ps_if
        case TOK_EOF, TOK_ENDIF
            ps_stmt = 0
            tok_please_repeat
        case else
            fatalerror "Syntax error: unexpected " + tok_human_readable$(token)
    end select
    print "Completed statement"
end function

function ps_if
    print "Start conditional"
    dim he as hentry_t
    root = ast_add_node(AST_IF)
    
    'Condition
    ast_attach root, ps_expr

    'the THEN
    ps_assert_token tok_next_token(he, literal$), TOK_THEN

    token = tok_next_token(he, literal$)
    if token = TOK_NEWLINE then 'Multi-line if
        ast_attach root, ps_block
        ps_assert_token tok_next_token(he, literal$), TOK_ENDIF
    else
        tok_please_repeat
        ast_attach root, ps_stmt
        ps_assert_token tok_next_token(he, literal$), TOK_NEWLINE
    end if
    ps_if = root
    print "Completed conditional"
end function
    
function ps_assignment (sref)
    print "Start assignment"
    dim he as hentry_t
    root = ast_add_node(AST_ASSIGN)
    dest = ast_add_node(AST_SREF)
    ast_nodes(dest).ref = sref
    ast_attach root, dest

    ps_assert_token tok_next_token(he, literal$), TOK_EQUALS

    ast_attach root, ps_expr
    ps_assignment = root

    ps_assert_token tok_next_token(he, literal$), TOK_NEWLINE
    print "Completed assignment"
end function

function ps_stmtreg(he as hentry_t)
    print "Start stmtreg"
    root = ast_add_node(AST_CALL)
    ast_nodes(root).ref = he.id
    ps_stmtreg = root
    print "Completed stmtreg"
end function

function ps_expr
    print "Start expr"
    pt_token = 0 'Reset pratt parser
    ps_expr = pt_expr(1)
    tok_please_repeat
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

'$include: 'pratt.bm'
'$include: 'htable.bm'
'$include: 'tokeng.bm'
'$include: 'ast.bm'
