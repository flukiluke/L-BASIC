'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'ast.bi - Declarations for Abstract Syntax Tree

'This is a tree structure in a convoluted way
'The node definition
type ast_node_t
    parent as long
    typ as long
    ref as long
    ref2 as long
    linenum as long 'File line this node started to appear
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

'Accessor macros
$macro: @@->parent | ast_nodes(@1).parent
$macro: @@->atype | ast_nodes(@1).typ
$macro: @@->ref | ast_nodes(@1).ref
$macro: @@->ref2 | ast_nodes(@1).ref2
$macro: @@->linenum | ast_nodes(@1).linenum
$macro: @@->cast(@@) | ast_add_cast(@1, @2)
$macro: @@->attach(@@) | ast_attach @1, @2
$macro: @@->pre_attach(@@) | ast_pre_attach @1, @2
$macro: @@->attach_none | ast_attach @1, ast_add_node(AST_NONE)

const AST_FALSE = 1
const AST_TRUE = 2
const AST_ONE = 3
const AST_NEWLINE_STRING = 4
const AST_TAB_STRING = 5

'This is an AST_BLOCK that is the main program.
dim shared AST_ENTRYPOINT

'The types of node.
'Note: an "expression"/"expr" is a CALL, CONSTANT, CAST, SELECT_VALUE, any of the lvalue
'types or NONE (if allowed).

'Every SUB and FUNCTION is rooted in an AST_PROCEDURE.
'First child is AST_BLOCK. Remaining children are AST_VAR for formal parameters, left to
'right. ref is the symtab entry for the function name, ref2 is the type signature.
const AST_PROCEDURE = 1
'group of statements
const AST_BLOCK = 2
'assign lvalue expr => lvalue = expr
const AST_ASSIGN = 3
'if expr1 block1 [expr2 block2 ...] [block-n] => IF expr1 THEN block1 ELSEIF expr2 THEN
'block2 ... ELSE block-n
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
'select expr [AST_SELECT_LIST]* AST_SELECT_ELSE? => SELECT CASE expr CASE AST_SELECT_LIST... AST_SELECT_ELSE
const AST_SELECT = 9
'Children are AST_SELECT_IS or AST_SELECT_RANGE. Last child is block.
const AST_SELECT_LIST = 10
'ref is comparison function, ref2 is type sig. First child is AST_SELECT_VALUE, second
'child is expr to compare against (second argument to function). Note that this is
'the same format as AST_CALL.
const AST_SELECT_IS = 11
'ref is comparison function, ref2 is type sig. Left & right bounding expr are first and
'second children respectively.
const AST_SELECT_RANGE = 12
'First child is block
const AST_SELECT_ELSE = 13
'When evaluated, returns the base expression value of the inner-most SELECT CASE. ref is
'the type of the expression.
const AST_SELECT_VALUE = 14
'call param* => A function call to ref with type signature ref2 and parameters as children
const AST_CALL = 15
'ref is a reference to an entry in the constants table
const AST_CONSTANT = 16
'Casts are first-class AST elements instead of just CALLs to a cast function. ref is a
'type, child is a CALL, CONSTANT or VAR.
const AST_CAST = 17
'Used to pass extra data to some functions that have behaviour set by syntax (e.g. INPUT, LINE).
'ref is one of AST_FLAG_* defined below. ref2 is the corresponding value.
const AST_FLAGS = 18
'If the goto is resolved, ref is the node to jump to. If unresolved, the label symtab. A
'fully-parsed program will have no unresolved labels.
const AST_GOTO = 19
'Used for empty optional arguments to functions
const AST_NONE = 20
'The EXIT statement. ref is the loop statement or function we're exiting.
const AST_EXIT = 21

'These nodes may appear where-ever an lvalue is required
'ref is reference to symtab
const AST_VAR = 22
'Access to a UDT element. First child is the lvalue we're accessing an element of, ref is
'the UDT element symbol.
const AST_UDT_ACCESS = 23
'Access to an array element. First child is the lvalue to be indexed. Second child is
'expression for the index in leftmost dimension, then so on for other dimensions.
const AST_ARRAY_ACCESS = 24

'Emitted by DIM statements to initialise an array. First child is lvalue to be
'initialised, then each pair of children after are expr for the lower and upper
'bound of each dimension. The array is zeroed out.
const AST_ARRAY_CREATE = 25
'Like above, but preserve the contents of the array if any.
const AST_ARRAY_RESIZE = 26
'Free an array's heap allocation, effectively a destructor. First child is an lvalue.
const AST_ARRAY_DELETE = 27
'Like _CREATE, with the exception that the array is not touched if memory is already
'allocated. Added to support STATIC arrays.
const AST_ARRAY_ESTABLISH = 28
'Try to claim ownership of an array. If unowned, the owner becomes the current scope.
'If already owned, does nothing.
const AST_ARRAY_CLAIM = 29

'Sets the return value of the current function. first child is expr to return, ref
'is the return type.
const AST_SET_RETURN = 30

'Flag is a value defined in cmdflags.bi.
const AST_FLAG_MANUAL = 1
'Flag is a contextual argument and value is the index into the list of alternates.
const AST_FLAG_CONTEXTUAL = 2
'Flag is a token.
const AST_FLAG_TOKEN = 3
