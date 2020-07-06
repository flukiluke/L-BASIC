'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'ast.bi - Declarations for Abstract Syntax Tree

'This is a tree structure in a convoluted way
'The node definition
type ast_node_t
    typ as long
    ref as long
    ref2 as long 'It pains me to add this, but I needed to put type signature references somewhere for dumping and I don't want to make a new node for that
    num_children as long
end type

'The nodes themselves
dim shared ast_nodes(0) as ast_node_t
'The children of a given node as a mkl$-encoded string
dim shared ast_children(0) as string
'The id of the last node registered
dim shared ast_last_node as long

'Every number and string appearing in the program gets an entry here
dim shared ast_constants(0) as string
dim shared ast_constant_types(0) as long
dim shared ast_last_constant as long

const AST_FALSE = 1
const AST_TRUE = 2
const AST_ONE = 3

'The types of node. Note the regex-like notation with ? for optionality.

'assign  expr => ref = expr
const AST_ASSIGN = 1
'if expr1 block1 [expr2 block2 ...] [block-n] => IF expr1 THEN block1 ELSEIF expr2 THEN block2 ... ELSE block-n
const AST_IF = 2
'do expr block => DO WHILE expr: block: LOOP
const AST_DO_PRE = 3
'do expr block => DO: block: LOOP WHILE expr
const AST_DO_POST = 4
'for expr1 expr2 expr3 block => FOR ref = expr1 TO expr2 STEP expr3
const AST_FOR = 5
'select expr1 (expr block)* block? => SELECT CASE expr1: CASE expr: block: CASE expr: block: CASE ELSE: block
const AST_SELECT = 6
'call param* => A function call to ref with type signature ref2 and parameters as children
const AST_CALL = 7
'ref is a reference to an entry in the constants table
const AST_CONSTANT = 8
'(assign | if | do_pre | do_post | for | select | call)*
const AST_BLOCK = 9
'ref is reference to symtab
const AST_VAR = 10
'For now casts are first-class AST elements instead of just CALLs. We'll see if this is a good idea or not. ref is a type, child is a CALL, CONSTANT or VAR.
const AST_CAST = 11
'ref is an integer. Used to pass extra data to some functions that have behaviour set by syntax (e.g. INPUT)
const AST_FLAGS = 12
