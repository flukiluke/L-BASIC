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
ast_dump_pretty block, 0
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
        case is < 0
            fatalerror "Unexpected literal " + tok_content$
        case TOK_IF
            ps_stmt = ps_if
        case TOK_DO
            ps_stmt = ps_do
        case TOK_WHILE
            ps_stmt = ps_while
        case TOK_ELSE, TOK_LOOP, TOK_WEND, TOK_EOF
            'These all end a block in some fashion. Repeat so that the
            'block-specific code can assert the ending token
            ps_stmt = 0
            tok_please_repeat
        case TOK_END 'As in END IF, END SUB etc.
            'Like above, but no repeat so the block-specific ending token
            'can be asserted
            ps_stmt = 0
        case TOK_UNKNOWN
            he.typ = HE_VARIABLE
            htable_add_hentry ucase$(tok_content$), he
            'It's not really an existing variable, is it.
            ps_stmt = ps_assignment(ps_existing_variable(htable.elements))
        case else
            he = htable_entries(token)
            select case he.typ
            case HE_VARIABLE
                ps_stmt = ps_assignment(ps_existing_variable(he.id))
            case else
                tok_please_repeat
                ps_stmt = ps_stmtreg
            end select
    end select
    print "Completed statement"
end function

function ps_while
    print "Start WHILE block"
    root = ast_add_node(AST_DO_PRE)
    ast_attach root, ps_expr
    ps_assert_token tok_next_token, TOK_NEWLINE
    ast_attach root, ps_block
    ps_assert_token tok_next_token, TOK_WEND
    ps_while = root
end function

function ps_do
    print "Start DO block"
    check = tok_next_token
    if check = TOK_WHILE or check = TOK_UNTIL then
        ps_do = ps_do_pre(check)
    elseif check = TOK_NEWLINE then
        ps_do = ps_do_post
    else
        fatalerror "Unexpected " + tok_content$
    end if
    print "Completed DO block"
end function

function ps_do_pre(check)
    print "Start DO-PRE"
    root = ast_add_node(AST_DO_PRE)
    'Condition is WHILE guard; UNTIL will need the guard to be negated
    raw_guard = ps_expr
    if check = TOK_UNTIL then
        guard = ast_add_node(AST_CALL)
        ast_nodes(guard).ref = TOK_EQUALS
        false_const = ast_add_node(AST_CONSTANT)
        false_const.ref = AST_FALSE
        ast_attach guard, false_const
        ast_attach guard, raw_guard
    else
        'TOK_WHILE guaranteed by ps_do
        guard = raw_guard
    end if
    ast_attach root, guard
    ps_assert_token tok_next_token, TOK_NEWLINE
    ast_attach root, ps_block
    ps_assert_token tok_next_token, TOK_LOOP
    ps_do_pre = root
    print "Completed DO-PRE"
end function

function ps_do_post
    print "Start DO-POST"
    root = ast_add_node(AST_DO_POST)
    block = ps_block
    ps_assert_token tok_next_token, TOK_LOOP

    check = tok_next_token
    if check = TOK_NEWLINE then
        'Oh boy, infinite loop!
        guard = ast_add_node(AST_CONSTANT)
        ast_nodes(guard).ref = AST_TRUE
    elseif check = TOK_WHILE then
        guard = ps_expr
    elseif check = TOK_UNTIL then
        guard = ast_add_node(AST_CALL)
        ast_nodes(guard).ref = TOK_EQUALS
        false_const = ast_add_node(AST_CONSTANT)
        false_const.ref = AST_FALSE
        ast_attach guard, false_const
        ast_attach guard, ps_expr
    else
        fatalerror "Unexpected " + tok_content$
    end if
    ast_attach root, guard
    ast_attach root, block
    ps_do_post = root
    print "Completed DO-POST"
end function

function ps_if
    print "Start conditional"
    root = ast_add_node(AST_IF)
    'Condition
    ast_attach root, ps_expr
    ps_assert_token tok_next_token, TOK_THEN

    token = tok_next_token
    if token = TOK_NEWLINE then 'Multi-line if
        ast_attach root, ps_block
        t = tok_next_token
        if t = TOK_ELSE then
            ps_assert_token tok_next_token, TOK_NEWLINE
            ast_attach root, ps_block
            t = tok_next_token
        end if
        'END IF, with the END being eaten by ps_block
        ps_assert_token t, TOK_IF
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
    pt_token = tok_next_token
    pt_content$ = tok_content$
    ps_expr = pt_expr(0)
    tok_please_repeat
    print "Completed expr"
end function
        
function ps_existing_variable(token)
    print "Start existing variable"
    'Always called after parsing base variable name, passed in as token
    'Check for type suffixes
    t = tok_next_token
    select case t
    case TOK_BYTE_SFX, TOK_INTEGER_SFX, TOK_LONG_SFX, TOK_INTEGER64_SFX, TOK_UBYTE_SFX, TOK_UINTEGER_SFX, TOK_ULONG_SFX, TOK_UINTEGER64_SFX, TOK_SINGLE_SFX, TOK_DOUBLE_SFX, TOK_FLOAT_SFX, TOK_STRING_SFX
        'Assert type is as recorded
        print "Type check OK"
    case else
        tok_please_repeat
    end select
    ps_existing_variable = token
    print "Completed existing variable"
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
