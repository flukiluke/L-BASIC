'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'parser.bi - Declarations for parser module

'$include: 'tokeng.bi'
'$include: 'token_registrations.bm'

'Next available slot for variables, used to know how many data slots to allocate.
'This applies to the current scope - the parser for subs/functions will save and
'restore this value so it is preserved for the main program.
dim shared ps_next_var_index as long
ps_next_var_index = 1

'actual as opposed to any explicit old-timey line numbers/labels in the program
dim shared ps_actual_linenum as long
ps_actual_linenum = 1

dim shared ps_default_type as long
ps_default_type = TYPE_SINGLE

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
dim shared ps_scope_identifier$