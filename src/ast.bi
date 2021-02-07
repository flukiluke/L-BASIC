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
'The ast optionally supports transactions; calling ast_rollback will
'remove all items added since the last call to ast_commit.
'WARNING: transaction rollbacks only undo adding nodes. Node changes
'are always immediately permanent.
dim shared ast_last_commit_id
dim shared ast_last_constant_commit_id

const AST_FALSE = 1
const AST_TRUE = 2
const AST_ONE = 3

'This is an AST_PROCEDURE added by ast_init.
dim shared AST_MAIN_PROCEDURE

'The types of node.
'Note: an "expression"/"expr" is a CALL, CONSTANT, CAST, any of the lvalue types or NONE (if allowed).

'Every SUB and FUNCTION is rooted in an AST_PROCEDURE (including the main program).
'First child is AST_BLOCK. Remaining children are AST_VAR for formal parameters, left to right.
const AST_PROCEDURE = 1
'group of statements
const AST_BLOCK = 2
'assign lvalue expr => lvalue = expr
const AST_ASSIGN = 3
'if expr1 block1 [expr2 block2 ...] [block-n] => IF expr1 THEN block1 ELSEIF expr2 THEN block2 ... ELSE block-n
const AST_IF = 4
'while expr block => WHILE expr: block: WEND
'Can't be an AST_DO_PRE because of EXIT
const AST_WHILE = 5
'do expr block => DO WHILE expr: block: LOOP
const AST_DO_PRE = 6
'do expr block => DO: block: LOOP WHILE expr
const AST_DO_POST = 7
'for lvalue expr1 expr2 expr3 block => FOR lvalue = expr1 TO expr2 STEP expr3
const AST_FOR = 8
'select expr1 (expr block)* block? => SELECT CASE expr1: CASE expr: block: CASE expr: block: CASE ELSE: block
const AST_SELECT = 9
'call param* => A function call to ref with type signature ref2 and parameters as children
const AST_CALL = 10
'ref is a reference to an entry in the constants table
const AST_CONSTANT = 11
'For now casts are first-class AST elements instead of just CALLs. We'll see if this is a good idea or not. ref is a type, child is a CALL, CONSTANT or VAR.
const AST_CAST = 12
'ref is an integer. Used to pass extra data to some functions that have behaviour set by syntax (e.g. INPUT)
const AST_FLAGS = 13
'If the goto is resolved, ref is the node to jump to. If unresolved, the label symtab. A fully-parsed program will have no unresolved labels.
const AST_GOTO = 14
'Used for empty optional arguments to functions
const AST_NONE = 15
'The EXIT statement. ref is the loop statement we're exiting.
const AST_EXIT = 16

'These nodes may appear where-ever an lvalue is required
'ref is reference to symtab
const AST_VAR = 16
'Access to a UDT element. First child is the lvalue we're accessing an element of, ref is the UDT element symbol.
const AST_UDT_ACCESS = 17
'Access to an array element. First child is the lvalue to be indexed. Second child is expression for the index in leftmost dimension, then so on for other dimensions.
const AST_ARRAY_ACCESS = 18

'Emitted by DIM/REDIM statements. first child is lvalue to be resized, then each pair of children after are expr for the lower and upper bound of each dimension.
const AST_ARRAY_RESIZE = 19
