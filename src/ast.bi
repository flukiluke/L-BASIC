'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'ast.bi - Declarations for Abstract Syntax Tree

'This is a tree structure in a convoluted way
'The node definition
type ast_node_t
    parent as long
    typ as long
    ref as long
    ref2 as long
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

'The types of node.
'Note: an "expression"/"expr" is a CALL, CONSTANT, CAST, any of the lvalue types or NONE (if allowed).

'assign lvalue expr => lvalue = expr
const AST_ASSIGN = 1
'if expr1 block1 [expr2 block2 ...] [block-n] => IF expr1 THEN block1 ELSEIF expr2 THEN block2 ... ELSE block-n
const AST_IF = 2
'while expr block => WHILE expr: block: WEND
'Can't be an AST_DO_PRE because of EXIT
const AST_WHILE = 3
'do expr block => DO WHILE expr: block: LOOP
const AST_DO_PRE = 4
'do expr block => DO: block: LOOP WHILE expr
const AST_DO_POST = 5
'for lvalue expr1 expr2 expr3 block => FOR lvalue = expr1 TO expr2 STEP expr3
const AST_FOR = 6
'select expr1 (expr block)* block? => SELECT CASE expr1: CASE expr: block: CASE expr: block: CASE ELSE: block
const AST_SELECT = 7
'call param* => A function call to ref with type signature ref2 and parameters as children
const AST_CALL = 8
'ref is a reference to an entry in the constants table
const AST_CONSTANT = 9
'(assign | if | do_pre | do_post | for | select | call)*
const AST_BLOCK = 10
'For now casts are first-class AST elements instead of just CALLs. We'll see if this is a good idea or not. ref is a type, child is a CALL, CONSTANT or VAR.
const AST_CAST = 11
'ref is an integer. Used to pass extra data to some functions that have behaviour set by syntax (e.g. INPUT)
const AST_FLAGS = 12
'If the goto is resolved, ref is the node to jump to. If unresolved, the label symtab. A fully-parsed program will have no unresolved labels.
const AST_GOTO = 13
'Used for empty optional arguments to functions
const AST_NONE = 14
'The EXIT statement. ref is the loop statement we're exiting.
const AST_EXIT = 15

'These nodes may appear where-ever an lvalue is required
'ref is reference to symtab
const AST_VAR = 16
'Access to a UDT element. First child is the lvalue we're accessing an element of, ref is the UDT element symbol.
const AST_UDT_ACCESS = 17
'Access to an array element. First child is the lvalue to be indexed. Second child is expression for the index.
const AST_ARRAY_ACCESS = 18
