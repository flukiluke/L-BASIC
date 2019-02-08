'This compiler is a one-man effort, so by Conway's Law, it is a one pass compiler.
const FALSE = 0, TRUE = NOT FALSE
deflng a-z
$console:only
_dest _console
on error goto generic_error

'$include: 'type.bi'
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
print "Function type signatures:"
type_dump_functions
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
        case TOK_FOR
            ps_stmt = ps_for
        case TOK_ELSE, TOK_LOOP, TOK_WEND, TOK_NEXT, TOK_EOF
            'These all end a block in some fashion. Repeat so that the
            'block-specific code can assert the ending token
            ps_stmt = 0
            tok_please_repeat
        case TOK_END 'As in END IF, END SUB etc.
            'Like above, but no repeat so the block-specific ending token
            'can be asserted
            ps_stmt = 0
        case TOK_UNKNOWN
            ps_stmt = ps_assignment(ps_variable(token, tok_content$))
        case else
            he = htable_entries(token)
            select case he.typ
            case HE_VARIABLE
                ps_stmt = ps_assignment(ps_variable(token, tok_content$))
            case HE_FUNCTION
                tok_please_repeat
                ps_stmt = ps_stmtreg
            case else
                fatalerror tok_content$ + " doesn't belong here"
            end select
    end select
    print "Completed statement"
end function

function ps_for
    print "Start FOR block"
    dim he as hentry_t
    root = ast_add_node(AST_FOR)
    t = tok_next_token
    if t = TOK_UNKNOWN then
        iterator = ps_variable(t, tok_content$)
    else
        fatalerror "Expected new variable as iterator"
    end if
    ps_assert_token tok_next_token, TOK_EQUALS

    start_val = ps_expr
    ps_assert_token tok_next_token, TOK_TO
    end_val = ps_expr
    t = tok_next_token
    if t = TOK_STEP then
        step_val = ps_expr
        ps_assert_token tok_next_token, TOK_NEWLINE
    elseif t = TOK_NEWLINE then
        'Default is STEP 1
        step_val = ast_add_node(AST_CONSTANT)
        ast_nodes(step_val).ref = AST_ONE
    else
        fatalerror "Unexpected " + tok_content$
    end if

    block = ps_block

    'This section aaaaaaall error checking
    ps_assert_token tok_next_token, TOK_NEXT
    t = tok_next_token
    if t < 0 then
        fatalerror "Expected variable reference, not a literal"
    elseif t = TOK_UNKNOWN then
        fatalerror "Unknown variable"
    end if
    he = htable_entries(t)
    if he.typ <> HE_VARIABLE then fatalerror "Unexpected " + tok_content$
    if iterator <> ps_variable(t, tok_content$) then fatalerror "Variable in NEXT does not match variable in FOR"
    ps_assert_token tok_next_token, TOK_NEWLINE

    ast_nodes(root).ref = iterator
    ast_attach root, start_val
    ast_attach root, end_val
    ast_attach root, step_val
    ast_attach root, block
    ps_for = root
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
    end if
    ps_if = root
    print "Completed conditional"
end function
    
function ps_assignment(ref)
    print "Start assignment"
    root = ast_add_node(AST_ASSIGN)
    ast_nodes(root).ref = ref
    ps_assert_token tok_next_token, TOK_EQUALS
    expr = ps_expr
    ast_attach root, expr
    'Assignment restricts lvalue's type to that of rvalue's.
    type_restrict ref, type_of_expr(expr)
    ps_assignment = root
    ps_assert_token tok_next_token, TOK_NEWLINE
    print "Completed assignment"
end function

function ps_stmtreg
    print "Start stmtreg"
    dim sig as type_signature_t

    root = ast_add_node(AST_CALL)
    token = tok_next_token
    ast_nodes(root).ref = htable_entries(token).id

    type_return_sig token, sig
    if sig.value <> TYPE_NONE then
        fatalerror "Function returning value used as statement"
    end if

    ps_funcargs root

    ps_stmtreg = root
    print "Completed stmtreg"
end function

sub ps_stmtarg(root)
    ast_attach root, ps_expr
end sub

function ps_expr
    print "Start expr"
    pt_token = tok_next_token
    pt_content$ = tok_content$
    ps_expr = pt_expr(0)
    tok_please_repeat
    print "Completed expr"
end function
        
function ps_funccall(func)
    print "Start function call"
    root = ast_add_node(AST_CALL)
    ast_nodes(root).ref = func
    t = tok_next_token
    if t = TOK_OPAREN then
        ps_funcargs root
        ps_assert_token tok_next_token, TOK_CPAREN
    else
        'No arguments
        tok_please_repeat
    end if
    ps_funccall = root
    print "Completed function call"
end function

sub ps_funcargs(root)
    dim sig as type_signature_t
    func = ast_nodes(root).ref
    type_return_sig func, sig
    t = TOK_COMMA
    while t = TOK_COMMA
        if type_next_sig(sig) = 0 then
            fatalerror "Function passed more arguments than expected"
        end if
        expr = ps_expr
        type_restrict_expr expr, sig.value
        ast_attach root, expr
        t = tok_next_token
    wend
    if type_next_sig(sig) then
        fatalerror "Function expected more arguments"
    end if
    tok_please_repeat
end sub

function ps_variable(token, content$)
    print "Start variable"
    dim he as hentry_t
    'Do array & udt element stuff here.
    'For now only support simple variables.
  
    'New variable?
    if token = TOK_UNKNOWN then
        he.typ = HE_VARIABLE
        htable_add_hentry ucase$(content$), he
        var = htable_last_id
        htable_entries(var).v1 = TYPE_ANY
    else
        var = token
    end if

    'Check for type suffixes
    t = tok_next_token
    if type_sfx2type(t) then
        type_restrict var, type_sfx2type(t)
    else
        tok_please_repeat
    end if
    ps_variable = var
    print "End variable"
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
'$include: 'type.bm'
