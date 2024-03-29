'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'parser.bi - Declarations for parser module

$include: 'tokeng.bi'

'The symtab entry of the last local variable created, used to help build the
'linked list.
'This applies to the current scope - the parser for subs/functions will save and
'restore this value so it is preserved for the main program.
dim shared ps_scoped_last_var as long

'When in a sub/function, we make the main program's last_var available too so that
'STATIC variables can be made part of the main program's scope. This value is only
'valid when in a sub/function.
dim shared ps_main_last_var as long

'actual as opposed to any explicit old-timey line numbers/labels in the program
dim shared ps_actual_linenum as long

dim shared ps_default_type as long

'Set TRUE if processing a preload file, meaning internal functions
'can be overridden with user-supplied ones.
dim shared ps_is_preload as long

'Whether we are compiling a module, so no public main function.
dim shared ps_is_module as long

'mkl$ list of symtab labels that are not attached to an AST node.
'This occurs if you have labels on empty or non-executable lines.
dim shared ps_unattached_labels$

'mkl$ list of nodes that ref a label location but were unresolved
'because the label hadn't been positioned yet.
dim shared ps_unresolved_jumps$

'mkl$ list of nodes that are DO, WHILE, FOR, SUB/FUNCTION for the purposes of
'parsing EXIT statements.
dim shared ps_nested_structures$

'Name of the containing function, used as part of a prefix for local objects.
dim shared ps_scope_name$
'Numeric value used to disambiguate different scopes with the same name
dim shared ps_scope_id

'Sometimes we need to run cleanup code just before exiting a scope. This is
'a list of nodes to be added to the end of a scope's block.
dim shared ps_queued_cleanup_nodes$

'Like above, but for entry into a scope
dim shared ps_queued_entry_nodes$

'Set to FALSE if OPTION _EXPLICIT is in effect
dim shared ps_allow_implicit_vars
