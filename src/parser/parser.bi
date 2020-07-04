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
