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
dim shared ast_last as long

'The types of node. Note the regex-like notation with ? for optionality.

'assign sref expr => sref = expr
const AST_ASSIGN = 1
'if expr block1 block2 => IF expr THEN block1 ELSE block2
const AST_IF = 2
'do expr block => DO WHILE expr: block: LOOP
const AST_DO_PRE = 3
'do expr block => DO: block: LOOP WHILE expr
const AST_DO_POST = 4
'do sref expr1 expr2 expr3 block => FOR sref = expr1 TO expr2 STEP expr3
const AST_FOR = 5
'select expr1 (expr block)* block? => SELECT CASE expr1: CASE expr: block: CASE expr: block: CASE ELSE: block
const AST_SELECT = 6
'call sref param* => A function call to sref with parameters
const AST_CALL = 7
'sref.id is a reference to an entry in the symbol table
const AST_SREF = 8
const AST_EXPR = 9
'(assign | if | do_pre | do_post | for | select | call)*
const AST_BLOCK = 10
'param.reference is a boolean. If true our child is sref otherwise expr
const AST_PARAM = 11
