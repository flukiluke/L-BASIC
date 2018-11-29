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

ps_file
'ignore = tok_next_token(he, literal$)
'ast_nodes(0).typ = AST_BLOCK
'ast_attach 0, pt_expr(0)
ast_dump 0
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

sub ps_file
    root = 0 'Treat node 0 as the root of the AST
    ast_nodes(root).typ = AST_BLOCK
    do
        stmt = ps_stmt
        if stmt = 0 then exit do 'use 0 to signal the end
        ast_attach root, stmt
    loop
end sub

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
        case TOK_EOF
            ps_stmt = 0
        case else
            fatalerror "Syntax error: unexpected " + tok_human_readable$(he.typ)
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

    'block of code
    ast_attach root, ps_stmt

    ps_assert_token tok_next_token(he, literal$), TOK_NEWLINE
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
    ps_expr = pt_expr(0)
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
