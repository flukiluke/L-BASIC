const FALSE = 0, TRUE = NOT FALSE
deflng a-z
$console:only
_dest _console
on error goto generic_error

'$include: 'htable.bi'
'$include: 'tokeng.bi'
'$include: 'pratt.bi'
'$include: 'ast.bi'
'$include: '../build/token_registrations.bm'

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

block = ps_block
print "Parsing complete"
print
print "Table of identifiers:"
htable_dump
print
print "Table of constants:"
ast_dump_constants
print
print "Program:"
ast_dump_pretty block
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
    do
        t = tok_next_token
    loop until t <> token or t = 0 '0 indicates EOF
    tok_please_repeat
end sub
    
function ps_block
    print "Start block"
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
    dim he as hentry_t
    print "Start statement"
    token = tok_next_token
    select case token
        case TOK_IF
            ps_stmt = ps_if
        case TOK_END 'As in END IF, END SUB etc.
            ps_stmt = 0
        case TOK_EOF
            ps_stmt = 0
            tok_please_repeat
        case TOK_UNKNOWN
            he.typ = HE_VARIABLE
            htable_add_hentry ucase$(tok_content$), he
            ps_stmt = ps_assignment(htable.elements)
        case else
            tok_please_repeat
            ps_stmt = ps_stmtreg
    end select
    print "Completed statement"
end function

function ps_if
    print "Start conditional"
    root = ast_add_node(AST_IF)
    
    'Condition
    ast_attach root, ps_expr

    'the THEN
    ps_assert_token tok_next_token, TOK_THEN

    token = tok_next_token
    if token = TOK_NEWLINE then 'Multi-line if
        ast_attach root, ps_block
        ps_assert_token tok_next_token, TOK_IF
    else
        tok_please_repeat
        ast_attach root, ps_stmt
        ps_assert_token tok_next_token, TOK_NEWLINE
    end if
    ps_if = root
    print "Completed conditional"
end function
    
function ps_assignment(ref)
    print "Start assignment"
    root = ast_add_node(AST_ASSIGN)
    ast_nodes(root).ref = ref

    ps_assert_token tok_next_token, TOK_EQUALS

    ast_attach root, ps_expr
    ps_assignment = root

    ps_assert_token tok_next_token, TOK_NEWLINE
    print "Completed assignment"
end function

function ps_stmtreg
    print "Start stmtreg"
    root = ast_add_node(AST_CALL)
    token = tok_next_token
    ast_nodes(root).ref = htable_entries(token).id
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
