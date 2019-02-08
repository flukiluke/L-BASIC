'This is a tree structure in a convoluted way

'The node definition
type ast_node_t
    typ as long
    ref as long
    num_children as long
end type

'The nodes themselves
'Why 100? No particular reason.
dim shared ast_nodes(100) as ast_node_t
'The children of a given node as a mkl$-encoded string
dim shared ast_children(100) as string
'The id of the last node registered
dim shared ast_last_node as long

'Every number and string appearing in the program gets an entry here
dim shared ast_constants(100) as string
'This array also manipulated by the type module
dim shared ast_constant_types(100) as long
dim shared ast_last_constant as long

const AST_FALSE = 0
const AST_TRUE = 1
const AST_ONE = 2
ast_constants(AST_FALSE) = "0"
ast_constant_types(AST_FALSE) = TYPE_NUMBER
ast_constants(AST_TRUE) = "-1"
ast_constant_types(AST_TRUE) = TYPE_NUMBER
ast_constants(AST_ONE) = "1"
ast_constant_types(AST_ONE) = TYPE_NUMBER
ast_last_constant = 2

'The types of node. Note the regex-like notation with ? for optionality.

'assign  expr => ref = expr
const AST_ASSIGN = 1
'if expr block1 block2 => IF expr THEN block1 ELSE block2
const AST_IF = 2
'do expr block => DO WHILE expr: block: LOOP
const AST_DO_PRE = 3
'do expr block => DO: block: LOOP WHILE expr
const AST_DO_POST = 4
'for expr1 expr2 expr3 block => FOR ref = expr1 TO expr2 STEP expr3
const AST_FOR = 5
'select expr1 (expr block)* block? => SELECT CASE expr1: CASE expr: block: CASE expr: block: CASE ELSE: block
const AST_SELECT = 6
'call param* => A function call to ref with parameters
const AST_CALL = 7
'ref is a reference to an entry in the constants table
const AST_CONSTANT = 8
'(assign | if | do_pre | do_post | for | select | call)*
const AST_BLOCK = 9
'ref is reference to htable
const AST_VAR = 10
