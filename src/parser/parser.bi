'Copyright 2020 Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'parser.bi - Declarations for parser module

'$include: 'tokeng.bi'
'$include: '../../rules/token_registrations.bm'

'This is the number of local variables
'Eventually this will need to be per-scope, but for now it's just going here
dim shared ps_last_var_index as long

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
