'--------------------------------------------------------------------------------
'vWATCH64 initialization code - version 1.105:
'--------------------------------------------------------------------------------
DECLARE LIBRARY
    FUNCTION vwatch64_GETPID& ALIAS getpid ()
END DECLARE

DECLARE LIBRARY "timers"
    SUB VWATCH64_STOPTIMERS ALIAS stop_timers
    SUB VWATCH64_STARTTIMERS ALIAS start_timers
END DECLARE

CONST vwatch64_ID = "vWATCH64"
CONST vwatch64_VERSION = "1.105"
CONST vwatch64_CHECKSUM = "58DEEE0E"
CONST vwatch64_FILENAME = "/home/luke/comp/git_qb64/vwatch64.dat"

'Breakpoint control:
CONST vwatch64_CONTINUE = 1
CONST vwatch64_NEXTSTEP = 2
CONST vwatch64_READY = 3
CONST vwatch64_SETVAR = 4
CONST vwatch64_SKIPSUB = 5
CONST vwatch64_SETNEXT = 7

TYPE vwatch64_HEADERTYPE
    CLIENT_ID AS STRING * 8
    VERSION AS STRING * 5
    CONNECTED AS _BYTE
    RESPONSE AS _BYTE
    PID AS LONG
END TYPE

TYPE vwatch64_CLIENTTYPE
    NAME AS STRING * 256
    CHECKSUM AS STRING * 8
    TOTALSOURCELINES AS LONG
    EXENAME AS STRING * 256
    LINENUMBER AS LONG
    TOTALVARIABLES AS LONG
    PID AS LONG
END TYPE

TYPE vwatch64_BREAKPOINTTYPE
    ACTION AS _BYTE
    LINENUMBER AS LONG
END TYPE


TYPE vwatch64_VARIABLESTYPE
    NAME AS STRING * 256
    SCOPE AS STRING * 50
    UDT AS STRING * 40
    DATATYPE AS STRING * 20
END TYPE

TYPE vwatch64_VARIABLEVALUETYPE
    VALUE AS STRING * 256
END TYPE

DIM SHARED vwatch64_BREAKPOINT AS vwatch64_BREAKPOINTTYPE
DIM SHARED vwatch64_WATCHPOINTCOMMAND AS vwatch64_BREAKPOINTTYPE
DIM SHARED vwatch64_WATCHPOINTCOMMANDBLOCK AS LONG
DIM SHARED vwatch64_BREAKPOINTBLOCK AS LONG
DIM SHARED vwatch64_BREAKPOINTLISTBLOCK AS LONG
DIM SHARED vwatch64_BREAKPOINTLIST AS STRING * 2332
DIM SHARED vwatch64_CLIENT AS vwatch64_CLIENTTYPE
DIM SHARED vwatch64_CLIENTBLOCK AS LONG
DIM SHARED vwatch64_CLIENTFILE AS INTEGER
DIM SHARED vwatch64_DATAINFOBLOCK AS LONG
DIM SHARED vwatch64_DATABLOCK AS LONG
DIM SHARED vwatch64_EXCHANGEBLOCK AS LONG
DIM SHARED vwatch64_WATCHPOINTLISTBLOCK AS LONG
DIM SHARED vwatch64_WATCHPOINTEXPBLOCK AS LONG
DIM SHARED vwatch64_HEADER AS vwatch64_HEADERTYPE
DIM SHARED vwatch64_HEADERBLOCK AS LONG
DIM SHARED vwatch64_USERQUIT AS _BYTE
DIM SHARED vwatch64_NEXTLINE AS LONG
DIM SHARED vwatch64_SUBLEVEL AS INTEGER
DIM SHARED vwatch64_TARGETVARINDEX AS LONG
DIM SHARED vwatch64_TIMER AS INTEGER
DIM SHARED vwatch64_EXCHANGEDATASIZE$4
DIM SHARED vwatch64_EXCHANGEDATA AS STRING
DIM SHARED vWATCH64_DUMMY%%

DIM SHARED vwatch64_VARIABLES(1 TO 12) AS vwatch64_VARIABLESTYPE
DIM SHARED vwatch64_VARIABLEDATA(1 TO 12) AS vwatch64_VARIABLEVALUETYPE
DIM SHARED vwatch64_WATCHPOINTLIST AS STRING * 12
DIM SHARED vwatch64_WATCHPOINT(1 TO 12) AS vwatch64_VARIABLEVALUETYPE
vwatch64_VARIABLES(1).NAME = "ref"
vwatch64_VARIABLES(1).SCOPE = "SUB imm_eval"
vwatch64_VARIABLES(1).DATATYPE = "LONG"
vwatch64_VARIABLES(2).NAME = "result.t"
vwatch64_VARIABLES(2).SCOPE = "SUB imm_eval"
vwatch64_VARIABLES(2).DATATYPE = "LONG"
vwatch64_VARIABLES(3).NAME = "result.s"
vwatch64_VARIABLES(3).SCOPE = "SUB imm_eval"
vwatch64_VARIABLES(3).DATATYPE = "LONG"
vwatch64_VARIABLES(4).NAME = "result.n"
vwatch64_VARIABLES(4).SCOPE = "SUB imm_eval"
vwatch64_VARIABLES(4).DATATYPE = "LONG"
vwatch64_VARIABLES(5).NAME = "i"
vwatch64_VARIABLES(5).SCOPE = "SUB imm_eval"
vwatch64_VARIABLES(5).DATATYPE = "LONG"
vwatch64_VARIABLES(6).NAME = "sp"
vwatch64_VARIABLES(6).SCOPE = "SUB imm_eval"
vwatch64_VARIABLES(6).DATATYPE = "LONG"
vwatch64_VARIABLES(7).NAME = "result.t"
vwatch64_VARIABLES(7).SCOPE = "SUB imm_do_cast"
vwatch64_VARIABLES(7).DATATYPE = "LONG"
vwatch64_VARIABLES(8).NAME = "sp"
vwatch64_VARIABLES(8).SCOPE = "SUB imm_do_assign"
vwatch64_VARIABLES(8).DATATYPE = "LONG"
vwatch64_VARIABLES(9).NAME = "result.n"
vwatch64_VARIABLES(9).SCOPE = "SUB imm_enforce_type"
vwatch64_VARIABLES(9).DATATYPE = "LONG"
vwatch64_VARIABLES(10).NAME = "result.t"
vwatch64_VARIABLES(10).SCOPE = "SUB imm_do_call"
vwatch64_VARIABLES(10).DATATYPE = "LONG"
vwatch64_VARIABLES(11).NAME = "result.s"
vwatch64_VARIABLES(11).SCOPE = "SUB imm_do_call"
vwatch64_VARIABLES(11).DATATYPE = "LONG"
vwatch64_VARIABLES(12).NAME = "result.n"
vwatch64_VARIABLES(12).SCOPE = "SUB imm_do_call"
vwatch64_VARIABLES(12).DATATYPE = "LONG"

vwatch64_HEADERBLOCK = 1
vwatch64_CLIENTBLOCK = LEN(vwatch64_HEADER) + 1
vwatch64_BREAKPOINTBLOCK = vwatch64_CLIENTBLOCK + LEN(vwatch64_CLIENT) + 1
vwatch64_BREAKPOINTLISTBLOCK = vwatch64_BREAKPOINTBLOCK + LEN(vwatch64_BREAKPOINT) + 1
vwatch64_DATAINFOBLOCK = vwatch64_BREAKPOINTLISTBLOCK + LEN(vwatch64_BREAKPOINTLIST) + 1
vwatch64_DATABLOCK = vwatch64_DATAINFOBLOCK + LEN(vwatch64_VARIABLES()) + 1
vwatch64_WATCHPOINTLISTBLOCK = vwatch64_DATABLOCK + LEN(vwatch64_VARIABLEDATA()) + 1
vwatch64_WATCHPOINTEXPBLOCK = vwatch64_WATCHPOINTLISTBLOCK + LEN(vwatch64_WATCHPOINTLIST) + 1
vwatch64_WATCHPOINTCOMMANDBLOCK = vwatch64_WATCHPOINTEXPBLOCK + LEN(vwatch64_WATCHPOINT()) + 1
vwatch64_EXCHANGEBLOCK = vwatch64_WATCHPOINTCOMMANDBLOCK + LEN(vwatch64_WATCHPOINTCOMMAND) + 1

vwatch64_CONNECTTOHOST

'Initialize the data export timer:
vwatch64_TIMER = _FREETIMER
ON TIMER(vwatch64_TIMER, .1) vwatch64_VARIABLEWATCH
TIMER(vwatch64_TIMER) ON

'--------------------------------------------------------------------------------
'End of vWATCH64 initialization code.
'--------------------------------------------------------------------------------

'$dynamic
$CONSOLE
vwatch64_LABEL_3:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(3): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_3 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_3
_dest _console
vwatch64_SKIP_3:::: 
deflng a-z
const FALSE = 0, TRUE = not FALSE
vwatch64_LABEL_6:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(6): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_6 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_6
on error goto generic_error
vwatch64_SKIP_6:::: 

dim shared VERSION$
vwatch64_LABEL_9:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(9): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_9 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_9
VERSION$ = "initial dev. version"
vwatch64_SKIP_9:::: 

'*INCLUDE file merged: 'type.bi'
'type_signatures() is a linked list.
'A function token points to a single type_signature_t, and that element may point to alternative signatures for that function.
'This allows us to support declaring a function multiple times with different signatures by chaining each declaration's signature together.

'type_signature_t.sig is an mkl$-encoded string. Its format is mkl$(return type) + mkl$(argument 1 type) + mkl$(argument 1 flags) + mkl$(argument 2 type) + mkl$(argument 2 flags) + ...
'Don't access them directly, use the type_sig_* functions.
type type_signature_t
    sig as string
    succ as long 'Can't call this "next" :(
end type

redim shared type_signatures(10) as type_signature_t
dim shared type_last_signature as long

'Variable data types
'This element is not typed and attempting to give it a type in as error
const TYPE_NONE = 0

'16 bits
const TYPE_INTEGER = 1
'32 bits
const TYPE_LONG = 2
'64 bits
const TYPE_INTEGER64 = 3
'Not yet used, but intended for pointers
const TYPE_OFFSET = 4
'binary32 floating-point
const TYPE_SINGLE = 5
'binary64 floating-point
const TYPE_DOUBLE = 6
'binary128 floating-point
const TYPE_QUAD = 7

'Everyone's favourite non-numeric type
const TYPE_STRING = 8

'Flags for type signature flags
const TYPE_REQUIRED = 1
const TYPE_BYREF = 2
const TYPE_BYVAL = 4
'*INCLUDE file merged: 'htable.bi'
' Hash table entry: _OFFSET, LONG, LONG
$IF 64BIT THEN
    CONST HTABLE_KEY_OFFSET = 0
    CONST HTABLE_KEYLEN_OFFSET = 8
    CONST HTABLE_DATA_OFFSET = 12
    CONST HTABLE_ENTRY_SIZE = 16
$ELSE
    CONST HTABLE_KEY_OFFSET = 0
    CONST HTABLE_KEYLEN_OFFSET = 4
    CONST HTABLE_DATA_OFFSET = 8
    CONST HTABLE_ENTRY_SIZE = 12
$END IF

TYPE htable_t
    table AS _MEM
    buckets AS LONG
    elements AS LONG
END TYPE

TYPE hentry_t
    id AS LONG
    typ AS LONG
    'The vn are generic parameters whose meaning depends on typ.
    v1 AS LONG
    v2 AS LONG
    v3 AS LONG
END TYPE

'A generic entry. No vn parameters are used.
CONST HE_GENERIC = 1
'A function with infix notation.
'v1 -> reference to the type signature
'v2 -> binding power (controls precedence)
'v3 -> associativity (1/0 = right/left)
CONST HE_INFIX = 2
'A function with prefix notation (and parentheses are not required)
'v1 -> reference to the type signature
'v2 -> binding power (controls precedence)
CONST HE_PREFIX = 3
'A variable.
'v1 -> the data type
'v2 -> index in scope (in each scope, first variable has 1, second has 2 etc.)
CONST HE_VARIABLE = 4
'A function (subs too!)
'v1 -> reference to the type signature
CONST HE_FUNCTION = 5

DIM SHARED htable AS htable_t
DIM SHARED htable_entries(100) AS hentry_t
DIM SHARED htable_names(100) AS STRING

vwatch64_LABEL_104:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(104): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_104 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_104
htable_create htable, 127
vwatch64_SKIP_104:::: 
'*INCLUDE file merged: 'ast.bi'
'This is a tree structure in a convoluted way

'The node definition
type ast_node_t
    typ as long
    ref as long
    ref2 as long 'It pains me to add this, but I needed to put type signature references somewhere and I don't want to make a new node for that
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
dim shared ast_constant_types(100) as long
dim shared ast_last_constant as long

const AST_NONE = 1
const AST_FALSE = 2
const AST_TRUE = 3
const AST_ONE = 4

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
'call param* => A function call to ref with type signature ref2 and parameters as children
const AST_CALL = 7
'ref is a reference to an entry in the constants table
const AST_CONSTANT = 8
'(assign | if | do_pre | do_post | for | select | call)*
const AST_BLOCK = 9
'ref is reference to htable
const AST_VAR = 10
'For now casts are first-class AST elements instead of just CALLs. We'll see if this is a good idea or not. ref is a type, child is a CALL, CONSTANT or VAR.
const AST_CAST = 11
'*INCLUDE file merged: 'parser/parser.bi'
'*INCLUDE file merged: 'tokeng.bi'
'*INCLUDE file merged: '../../rules/ts_data.bi'
CONST TS_SKIP = 1 
CONST TS_ID = 2 
CONST TS_NEWLINE = 3 
CONST TS_LINENUM = 4 
CONST TS_METACMD = 5 
CONST TS_METAPARAM = 6 
CONST TS_LINELABEL = 7 
CONST TS_STRING = 8 
CONST TS_SINGLE_SFX = 9 
CONST TS_STRING_SFX = 10 
CONST TS_POWER = 11 
CONST TS_STAR = 12 
CONST TS_OPAREN = 13 
CONST TS_CPAREN = 14 
CONST TS_DASH = 15 
CONST TS_PLUS = 16 
CONST TS_EQUALS = 17 
CONST TS_BACKSLASH = 18 
CONST TS_COLON = 19 
CONST TS_SEMICOLON = 20 
CONST TS_COMMA = 21 
CONST TS_SLASH = 22 
CONST TS_NUMINT = 23 
CONST TS_NUMDEC = 24 
CONST TS_NUMEXP = 25 
CONST TS_INTEGER_SFX = 26 
CONST TS_OFFSET_SFX = 27 
CONST TS_DOUBLE_SFX = 28 
CONST TS_QUAD_SFX = 29 
CONST TS_LONG_SFX = 30 
CONST TS_INTEGER64_SFX = 31 
CONST TS_NUMBASE = 32 
CONST TS_CMP_LT = 33 
CONST TS_CMP_LTEQ = 34 
CONST TS_CMP_NE = 35 
CONST TS_CMP_GT = 36 
CONST TS_CMP_GTEQ = 37 
CONST TS_DOT = 38 
CONST TS_MAX = 38 
CONST TS_ST_Begin = 1 
CONST TS_ST_Id = 2 
CONST TS_ST_Linenum = 3 
CONST TS_ST_Comment = 4 
CONST TS_ST_Metacmd1 = 5 
CONST TS_ST_General = 6 
CONST TS_ST_Metacmd2 = 7 
CONST TS_ST_String = 8 
CONST TS_ST_Number = 9 
CONST TS_ST_HashPfx = 10 
CONST TS_ST_PercentPfx = 11 
CONST TS_ST_AmpersandPfx = 12 
CONST TS_ST_LtPfx = 13 
CONST TS_ST_GtPfx = 14 
CONST TS_ST_Dot = 15 
CONST TS_ST_NumDec = 16 
CONST TS_ST_NumExpSgn = 17 
CONST TS_ST_NumExp = 18 
CONST TS_ST_NumBase = 19 
DIM SHARED t_states~%(127, 19)
DIM SHARED t_statenames$(19)
'*INCLUDE file merged: '../../rules/token_data.bi'
CONST TOK_UNKNOWN = 1
CONST TOK_NEWLINE = 2
CONST TOK_COMMA = 3
CONST TOK_NOT = 4
CONST TOK_AND = 5
CONST TOK_OR = 6
CONST TOK_XOR = 7
CONST TOK_EQV = 8
CONST TOK_IMP = 9
CONST TOK_EQUALS = 10
CONST TOK_CMP_LT = 11
CONST TOK_CMP_GT = 12
CONST TOK_CMP_LTEQ = 13
CONST TOK_CMP_GTEQ = 14
CONST TOK_PLUS = 15
CONST TOK_DASH = 16
CONST TOK_STAR = 17
CONST TOK_SLASH = 18
CONST TOK_NEGATIVE = 19
CONST TOK_POWER = 20
CONST TOK_OPAREN = 21
CONST TOK_CPAREN = 22
CONST TOK_NUMINT =-1 
CONST TOK_NUMDEC =-2 
CONST TOK_NUMEXP =-3 
CONST TOK_NUMBASE =-4 
CONST TOK_STRING =-5 
CONST TOK_INTEGER_SFX = 23
CONST TOK_LONG_SFX = 24
CONST TOK_INTEGER64_SFX = 25
CONST TOK_OFFSET_SFX = 26
CONST TOK_SINGLE_SFX = 27
CONST TOK_DOUBLE_SFX = 28
CONST TOK_QUAD_SFX = 29
CONST TOK_STRING_SFX = 30
CONST TOK_IF = 31
CONST TOK_THEN = 32
CONST TOK_ELSE = 33
CONST TOK_END = 34
CONST TOK_DO = 35
CONST TOK_LOOP = 36
CONST TOK_UNTIL = 37
CONST TOK_WHILE = 38
CONST TOK_WEND = 39
CONST TOK_FOR = 40
CONST TOK_TO = 41
CONST TOK_STEP = 42
CONST TOK_NEXT = 43
CONST TOK_SELECT = 44
CONST TOK_CASE = 45
CONST TOK__AUTODISPLAY = 46
CONST TOK_BEEP = 47
CONST TOK_CHR = 48
CONST TOK__COPYPALETTE = 49
CONST TOK_LEFT = 50
CONST TOK_PRINT = 51
CONST TOK_RGBA = 52
CONST TOK_INT = 53

type tokeniser_state_t
    index as long
    curstate as long
    has_data as long
    linestart as long
    prefill as long
end type

dim shared tokeng_state as tokeniser_state_t
dim shared tokeng_repeat_token as long
dim shared tokeng_repeat_literal$

vwatch64_LABEL_293:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(293): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_293 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_293
tok_init
vwatch64_SKIP_293:::: 
'*INCLUDE file merged: 'pratt.bi'
dim shared pt_token as long
dim shared pt_content$
'*INCLUDE file merged: '../../rules/token_registrations.bm'
dim shared tok_direct(1 to TS_MAX)
dim re as hentry_t
vwatch64_LABEL_300:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(300): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_300 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_300
re.typ = HE_GENERIC
vwatch64_SKIP_300:::: 
vwatch64_LABEL_301:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(301): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_301 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_301
htable_add_hentry "|UNKNOWN", re
vwatch64_SKIP_301:::: 
vwatch64_LABEL_302:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(302): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_302 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_302
htable_add_hentry "|NEWLINE", re
vwatch64_SKIP_302:::: 
vwatch64_LABEL_303:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(303): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_303 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_303
tok_direct(TS_NEWLINE) = 2 
vwatch64_SKIP_303:::: 
vwatch64_LABEL_304:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(304): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_304 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_304
htable_add_hentry "|COMMA", re
vwatch64_SKIP_304:::: 
vwatch64_LABEL_305:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(305): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_305 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_305
tok_direct(TS_COMMA) = 3 
vwatch64_SKIP_305:::: 
vwatch64_LABEL_306:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(306): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_306 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_306
re.typ = HE_PREFIX
vwatch64_SKIP_306:::: 
vwatch64_LABEL_307:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(307): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_307 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_307
re.v2 = 2
vwatch64_SKIP_307:::: 
vwatch64_LABEL_308:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(308): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_308 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_308
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_308:::: 
vwatch64_LABEL_309:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(309): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_309 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_309
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_309:::: 
vwatch64_LABEL_310:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(310): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_310 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_310
htable_add_hentry "NOT", re
vwatch64_SKIP_310:::: 
vwatch64_LABEL_311:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(311): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_311 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_311
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_311:::: 
vwatch64_LABEL_312:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(312): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_312 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_312
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_312:::: 
vwatch64_LABEL_313:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(313): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_313 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_313
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER64))
vwatch64_SKIP_313:::: 
vwatch64_LABEL_314:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(314): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_314 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_314
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_314:::: 
vwatch64_LABEL_315:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(315): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_315 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_315
re.typ = HE_INFIX
vwatch64_SKIP_315:::: 
vwatch64_LABEL_316:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(316): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_316 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_316
re.v3 = 0
vwatch64_SKIP_316:::: 
vwatch64_LABEL_317:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(317): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_317 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_317
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_317:::: 
vwatch64_LABEL_318:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(318): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_318 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_318
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_318:::: 
vwatch64_LABEL_319:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(319): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_319 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_319
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_319:::: 
vwatch64_LABEL_320:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(320): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_320 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_320
htable_add_hentry "AND", re
vwatch64_SKIP_320:::: 
vwatch64_LABEL_321:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(321): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_321 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_321
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_321:::: 
vwatch64_LABEL_322:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(322): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_322 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_322
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_322:::: 
vwatch64_LABEL_323:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(323): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_323 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_323
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_323:::: 
vwatch64_LABEL_324:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(324): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_324 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_324
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER64))
vwatch64_SKIP_324:::: 
vwatch64_LABEL_325:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(325): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_325 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_325
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_325:::: 
vwatch64_LABEL_326:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(326): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_326 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_326
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_326:::: 
vwatch64_LABEL_327:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(327): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_327 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_327
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_327:::: 
vwatch64_LABEL_328:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(328): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_328 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_328
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_328:::: 
vwatch64_LABEL_329:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(329): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_329 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_329
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_329:::: 
vwatch64_LABEL_330:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(330): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_330 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_330
htable_add_hentry "OR", re
vwatch64_SKIP_330:::: 
vwatch64_LABEL_331:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(331): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_331 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_331
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_331:::: 
vwatch64_LABEL_332:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(332): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_332 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_332
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_332:::: 
vwatch64_LABEL_333:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(333): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_333 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_333
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_333:::: 
vwatch64_LABEL_334:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(334): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_334 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_334
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER64))
vwatch64_SKIP_334:::: 
vwatch64_LABEL_335:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(335): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_335 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_335
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_335:::: 
vwatch64_LABEL_336:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(336): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_336 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_336
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_336:::: 
vwatch64_LABEL_337:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(337): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_337 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_337
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_337:::: 
vwatch64_LABEL_338:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(338): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_338 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_338
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_338:::: 
vwatch64_LABEL_339:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(339): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_339 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_339
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_339:::: 
vwatch64_LABEL_340:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(340): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_340 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_340
htable_add_hentry "XOR", re
vwatch64_SKIP_340:::: 
vwatch64_LABEL_341:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(341): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_341 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_341
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_341:::: 
vwatch64_LABEL_342:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(342): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_342 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_342
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_342:::: 
vwatch64_LABEL_343:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(343): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_343 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_343
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_343:::: 
vwatch64_LABEL_344:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(344): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_344 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_344
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER64))
vwatch64_SKIP_344:::: 
vwatch64_LABEL_345:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(345): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_345 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_345
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_345:::: 
vwatch64_LABEL_346:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(346): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_346 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_346
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_346:::: 
vwatch64_LABEL_347:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(347): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_347 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_347
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_347:::: 
vwatch64_LABEL_348:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(348): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_348 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_348
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_348:::: 
vwatch64_LABEL_349:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(349): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_349 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_349
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_349:::: 
vwatch64_LABEL_350:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(350): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_350 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_350
htable_add_hentry "EQV", re
vwatch64_SKIP_350:::: 
vwatch64_LABEL_351:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(351): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_351 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_351
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_351:::: 
vwatch64_LABEL_352:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(352): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_352 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_352
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_352:::: 
vwatch64_LABEL_353:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(353): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_353 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_353
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_353:::: 
vwatch64_LABEL_354:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(354): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_354 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_354
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER64))
vwatch64_SKIP_354:::: 
vwatch64_LABEL_355:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(355): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_355 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_355
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_355:::: 
vwatch64_LABEL_356:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(356): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_356 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_356
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_356:::: 
vwatch64_LABEL_357:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(357): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_357 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_357
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_357:::: 
vwatch64_LABEL_358:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(358): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_358 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_358
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_358:::: 
vwatch64_LABEL_359:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(359): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_359 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_359
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_359:::: 
vwatch64_LABEL_360:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(360): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_360 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_360
htable_add_hentry "IMP", re
vwatch64_SKIP_360:::: 
vwatch64_LABEL_361:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(361): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_361 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_361
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_361:::: 
vwatch64_LABEL_362:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(362): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_362 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_362
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_362:::: 
vwatch64_LABEL_363:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(363): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_363 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_363
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_363:::: 
vwatch64_LABEL_364:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(364): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_364 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_364
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER64))
vwatch64_SKIP_364:::: 
vwatch64_LABEL_365:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(365): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_365 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_365
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_365:::: 
vwatch64_LABEL_366:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(366): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_366 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_366
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_366:::: 
vwatch64_LABEL_367:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(367): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_367 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_367
re.v2 = 3
vwatch64_SKIP_367:::: 
vwatch64_LABEL_368:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(368): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_368 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_368
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_368:::: 
vwatch64_LABEL_369:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(369): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_369 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_369
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_369:::: 
vwatch64_LABEL_370:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(370): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_370 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_370
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_370:::: 
vwatch64_LABEL_371:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(371): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_371 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_371
htable_add_hentry "=", re
vwatch64_SKIP_371:::: 
vwatch64_LABEL_372:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(372): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_372 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_372
tok_direct(TS_EQUALS) = 10 
vwatch64_SKIP_372:::: 
vwatch64_LABEL_373:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(373): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_373 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_373
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_373:::: 
vwatch64_LABEL_374:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(374): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_374 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_374
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_374:::: 
vwatch64_LABEL_375:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(375): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_375 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_375
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_375:::: 
vwatch64_LABEL_376:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(376): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_376 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_376
tok_direct(TS_EQUALS) = 10 
vwatch64_SKIP_376:::: 
vwatch64_LABEL_377:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(377): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_377 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_377
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_377:::: 
vwatch64_LABEL_378:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(378): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_378 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_378
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_378:::: 
vwatch64_LABEL_379:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(379): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_379 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_379
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_379:::: 
vwatch64_LABEL_380:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(380): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_380 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_380
tok_direct(TS_EQUALS) = 10 
vwatch64_SKIP_380:::: 
vwatch64_LABEL_381:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(381): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_381 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_381
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_381:::: 
vwatch64_LABEL_382:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(382): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_382 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_382
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_382:::: 
vwatch64_LABEL_383:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(383): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_383 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_383
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_383:::: 
vwatch64_LABEL_384:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(384): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_384 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_384
tok_direct(TS_EQUALS) = 10 
vwatch64_SKIP_384:::: 
vwatch64_LABEL_385:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(385): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_385 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_385
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_385:::: 
vwatch64_LABEL_386:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(386): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_386 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_386
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_386:::: 
vwatch64_LABEL_387:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(387): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_387 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_387
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_387:::: 
vwatch64_LABEL_388:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(388): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_388 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_388
tok_direct(TS_EQUALS) = 10 
vwatch64_SKIP_388:::: 
vwatch64_LABEL_389:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(389): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_389 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_389
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_389:::: 
vwatch64_LABEL_390:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(390): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_390 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_390
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_390:::: 
vwatch64_LABEL_391:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(391): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_391 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_391
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_391:::: 
vwatch64_LABEL_392:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(392): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_392 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_392
tok_direct(TS_EQUALS) = 10 
vwatch64_SKIP_392:::: 
vwatch64_LABEL_393:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(393): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_393 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_393
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_393:::: 
vwatch64_LABEL_394:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(394): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_394 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_394
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_394:::: 
vwatch64_LABEL_395:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(395): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_395 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_395
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_395:::: 
vwatch64_LABEL_396:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(396): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_396 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_396
tok_direct(TS_EQUALS) = 10 
vwatch64_SKIP_396:::: 
vwatch64_LABEL_397:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(397): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_397 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_397
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_397:::: 
vwatch64_LABEL_398:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(398): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_398 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_398
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_398:::: 
vwatch64_LABEL_399:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(399): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_399 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_399
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_399:::: 
vwatch64_LABEL_400:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(400): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_400 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_400
htable_add_hentry "<", re
vwatch64_SKIP_400:::: 
vwatch64_LABEL_401:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(401): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_401 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_401
tok_direct(TS_CMP_LT) = 11 
vwatch64_SKIP_401:::: 
vwatch64_LABEL_402:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(402): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_402 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_402
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_402:::: 
vwatch64_LABEL_403:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(403): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_403 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_403
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_403:::: 
vwatch64_LABEL_404:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(404): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_404 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_404
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_404:::: 
vwatch64_LABEL_405:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(405): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_405 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_405
tok_direct(TS_CMP_LT) = 11 
vwatch64_SKIP_405:::: 
vwatch64_LABEL_406:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(406): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_406 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_406
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_406:::: 
vwatch64_LABEL_407:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(407): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_407 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_407
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_407:::: 
vwatch64_LABEL_408:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(408): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_408 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_408
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_408:::: 
vwatch64_LABEL_409:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(409): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_409 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_409
tok_direct(TS_CMP_LT) = 11 
vwatch64_SKIP_409:::: 
vwatch64_LABEL_410:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(410): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_410 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_410
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_410:::: 
vwatch64_LABEL_411:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(411): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_411 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_411
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_411:::: 
vwatch64_LABEL_412:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(412): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_412 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_412
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_412:::: 
vwatch64_LABEL_413:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(413): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_413 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_413
tok_direct(TS_CMP_LT) = 11 
vwatch64_SKIP_413:::: 
vwatch64_LABEL_414:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(414): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_414 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_414
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_414:::: 
vwatch64_LABEL_415:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(415): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_415 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_415
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_415:::: 
vwatch64_LABEL_416:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(416): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_416 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_416
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_416:::: 
vwatch64_LABEL_417:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(417): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_417 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_417
tok_direct(TS_CMP_LT) = 11 
vwatch64_SKIP_417:::: 
vwatch64_LABEL_418:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(418): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_418 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_418
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_418:::: 
vwatch64_LABEL_419:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(419): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_419 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_419
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_419:::: 
vwatch64_LABEL_420:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(420): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_420 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_420
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_420:::: 
vwatch64_LABEL_421:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(421): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_421 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_421
tok_direct(TS_CMP_LT) = 11 
vwatch64_SKIP_421:::: 
vwatch64_LABEL_422:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(422): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_422 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_422
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_422:::: 
vwatch64_LABEL_423:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(423): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_423 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_423
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_423:::: 
vwatch64_LABEL_424:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(424): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_424 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_424
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_424:::: 
vwatch64_LABEL_425:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(425): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_425 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_425
tok_direct(TS_CMP_LT) = 11 
vwatch64_SKIP_425:::: 
vwatch64_LABEL_426:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(426): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_426 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_426
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_426:::: 
vwatch64_LABEL_427:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(427): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_427 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_427
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_427:::: 
vwatch64_LABEL_428:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(428): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_428 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_428
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_428:::: 
vwatch64_LABEL_429:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(429): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_429 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_429
htable_add_hentry ">", re
vwatch64_SKIP_429:::: 
vwatch64_LABEL_430:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(430): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_430 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_430
tok_direct(TS_CMP_GT) = 12 
vwatch64_SKIP_430:::: 
vwatch64_LABEL_431:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(431): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_431 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_431
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_431:::: 
vwatch64_LABEL_432:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(432): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_432 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_432
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_432:::: 
vwatch64_LABEL_433:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(433): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_433 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_433
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_433:::: 
vwatch64_LABEL_434:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(434): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_434 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_434
tok_direct(TS_CMP_GT) = 12 
vwatch64_SKIP_434:::: 
vwatch64_LABEL_435:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(435): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_435 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_435
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_435:::: 
vwatch64_LABEL_436:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(436): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_436 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_436
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_436:::: 
vwatch64_LABEL_437:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(437): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_437 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_437
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_437:::: 
vwatch64_LABEL_438:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(438): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_438 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_438
tok_direct(TS_CMP_GT) = 12 
vwatch64_SKIP_438:::: 
vwatch64_LABEL_439:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(439): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_439 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_439
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_439:::: 
vwatch64_LABEL_440:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(440): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_440 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_440
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_440:::: 
vwatch64_LABEL_441:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(441): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_441 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_441
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_441:::: 
vwatch64_LABEL_442:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(442): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_442 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_442
tok_direct(TS_CMP_GT) = 12 
vwatch64_SKIP_442:::: 
vwatch64_LABEL_443:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(443): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_443 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_443
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_443:::: 
vwatch64_LABEL_444:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(444): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_444 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_444
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_444:::: 
vwatch64_LABEL_445:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(445): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_445 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_445
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_445:::: 
vwatch64_LABEL_446:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(446): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_446 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_446
tok_direct(TS_CMP_GT) = 12 
vwatch64_SKIP_446:::: 
vwatch64_LABEL_447:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(447): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_447 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_447
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_447:::: 
vwatch64_LABEL_448:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(448): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_448 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_448
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_448:::: 
vwatch64_LABEL_449:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(449): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_449 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_449
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_449:::: 
vwatch64_LABEL_450:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(450): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_450 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_450
tok_direct(TS_CMP_GT) = 12 
vwatch64_SKIP_450:::: 
vwatch64_LABEL_451:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(451): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_451 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_451
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_451:::: 
vwatch64_LABEL_452:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(452): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_452 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_452
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_452:::: 
vwatch64_LABEL_453:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(453): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_453 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_453
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_453:::: 
vwatch64_LABEL_454:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(454): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_454 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_454
tok_direct(TS_CMP_GT) = 12 
vwatch64_SKIP_454:::: 
vwatch64_LABEL_455:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(455): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_455 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_455
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_455:::: 
vwatch64_LABEL_456:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(456): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_456 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_456
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_456:::: 
vwatch64_LABEL_457:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(457): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_457 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_457
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_457:::: 
vwatch64_LABEL_458:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(458): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_458 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_458
htable_add_hentry "<=", re
vwatch64_SKIP_458:::: 
vwatch64_LABEL_459:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(459): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_459 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_459
tok_direct(TS_CMP_LTEQ) = 13 
vwatch64_SKIP_459:::: 
vwatch64_LABEL_460:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(460): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_460 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_460
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_460:::: 
vwatch64_LABEL_461:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(461): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_461 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_461
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_461:::: 
vwatch64_LABEL_462:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(462): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_462 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_462
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_462:::: 
vwatch64_LABEL_463:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(463): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_463 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_463
tok_direct(TS_CMP_LTEQ) = 13 
vwatch64_SKIP_463:::: 
vwatch64_LABEL_464:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(464): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_464 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_464
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_464:::: 
vwatch64_LABEL_465:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(465): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_465 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_465
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_465:::: 
vwatch64_LABEL_466:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(466): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_466 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_466
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_466:::: 
vwatch64_LABEL_467:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(467): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_467 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_467
tok_direct(TS_CMP_LTEQ) = 13 
vwatch64_SKIP_467:::: 
vwatch64_LABEL_468:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(468): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_468 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_468
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_468:::: 
vwatch64_LABEL_469:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(469): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_469 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_469
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_469:::: 
vwatch64_LABEL_470:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(470): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_470 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_470
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_470:::: 
vwatch64_LABEL_471:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(471): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_471 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_471
tok_direct(TS_CMP_LTEQ) = 13 
vwatch64_SKIP_471:::: 
vwatch64_LABEL_472:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(472): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_472 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_472
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_472:::: 
vwatch64_LABEL_473:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(473): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_473 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_473
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_473:::: 
vwatch64_LABEL_474:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(474): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_474 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_474
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_474:::: 
vwatch64_LABEL_475:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(475): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_475 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_475
tok_direct(TS_CMP_LTEQ) = 13 
vwatch64_SKIP_475:::: 
vwatch64_LABEL_476:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(476): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_476 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_476
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_476:::: 
vwatch64_LABEL_477:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(477): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_477 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_477
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_477:::: 
vwatch64_LABEL_478:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(478): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_478 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_478
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_478:::: 
vwatch64_LABEL_479:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(479): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_479 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_479
tok_direct(TS_CMP_LTEQ) = 13 
vwatch64_SKIP_479:::: 
vwatch64_LABEL_480:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(480): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_480 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_480
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_480:::: 
vwatch64_LABEL_481:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(481): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_481 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_481
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_481:::: 
vwatch64_LABEL_482:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(482): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_482 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_482
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_482:::: 
vwatch64_LABEL_483:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(483): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_483 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_483
tok_direct(TS_CMP_LTEQ) = 13 
vwatch64_SKIP_483:::: 
vwatch64_LABEL_484:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(484): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_484 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_484
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_484:::: 
vwatch64_LABEL_485:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(485): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_485 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_485
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_485:::: 
vwatch64_LABEL_486:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(486): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_486 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_486
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_486:::: 
vwatch64_LABEL_487:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(487): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_487 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_487
htable_add_hentry ">=", re
vwatch64_SKIP_487:::: 
vwatch64_LABEL_488:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(488): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_488 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_488
tok_direct(TS_CMP_GTEQ) = 14 
vwatch64_SKIP_488:::: 
vwatch64_LABEL_489:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(489): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_489 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_489
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_489:::: 
vwatch64_LABEL_490:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(490): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_490 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_490
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_490:::: 
vwatch64_LABEL_491:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(491): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_491 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_491
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_491:::: 
vwatch64_LABEL_492:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(492): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_492 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_492
tok_direct(TS_CMP_GTEQ) = 14 
vwatch64_SKIP_492:::: 
vwatch64_LABEL_493:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(493): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_493 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_493
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_493:::: 
vwatch64_LABEL_494:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(494): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_494 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_494
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_494:::: 
vwatch64_LABEL_495:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(495): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_495 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_495
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_495:::: 
vwatch64_LABEL_496:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(496): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_496 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_496
tok_direct(TS_CMP_GTEQ) = 14 
vwatch64_SKIP_496:::: 
vwatch64_LABEL_497:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(497): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_497 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_497
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_497:::: 
vwatch64_LABEL_498:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(498): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_498 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_498
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_498:::: 
vwatch64_LABEL_499:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(499): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_499 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_499
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_499:::: 
vwatch64_LABEL_500:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(500): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_500 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_500
tok_direct(TS_CMP_GTEQ) = 14 
vwatch64_SKIP_500:::: 
vwatch64_LABEL_501:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(501): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_501 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_501
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_501:::: 
vwatch64_LABEL_502:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(502): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_502 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_502
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_502:::: 
vwatch64_LABEL_503:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(503): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_503 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_503
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_503:::: 
vwatch64_LABEL_504:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(504): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_504 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_504
tok_direct(TS_CMP_GTEQ) = 14 
vwatch64_SKIP_504:::: 
vwatch64_LABEL_505:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(505): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_505 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_505
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_505:::: 
vwatch64_LABEL_506:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(506): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_506 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_506
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_506:::: 
vwatch64_LABEL_507:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(507): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_507 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_507
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_507:::: 
vwatch64_LABEL_508:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(508): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_508 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_508
tok_direct(TS_CMP_GTEQ) = 14 
vwatch64_SKIP_508:::: 
vwatch64_LABEL_509:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(509): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_509 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_509
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_509:::: 
vwatch64_LABEL_510:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(510): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_510 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_510
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_510:::: 
vwatch64_LABEL_511:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(511): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_511 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_511
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_511:::: 
vwatch64_LABEL_512:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(512): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_512 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_512
tok_direct(TS_CMP_GTEQ) = 14 
vwatch64_SKIP_512:::: 
vwatch64_LABEL_513:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(513): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_513 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_513
re.v2 = 4
vwatch64_SKIP_513:::: 
vwatch64_LABEL_514:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(514): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_514 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_514
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_514:::: 
vwatch64_LABEL_515:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(515): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_515 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_515
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_515:::: 
vwatch64_LABEL_516:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(516): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_516 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_516
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_516:::: 
vwatch64_LABEL_517:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(517): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_517 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_517
htable_add_hentry "+", re
vwatch64_SKIP_517:::: 
vwatch64_LABEL_518:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(518): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_518 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_518
tok_direct(TS_PLUS) = 15 
vwatch64_SKIP_518:::: 
vwatch64_LABEL_519:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(519): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_519 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_519
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_519:::: 
vwatch64_LABEL_520:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(520): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_520 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_520
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_520:::: 
vwatch64_LABEL_521:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(521): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_521 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_521
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_521:::: 
vwatch64_LABEL_522:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(522): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_522 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_522
tok_direct(TS_PLUS) = 15 
vwatch64_SKIP_522:::: 
vwatch64_LABEL_523:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(523): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_523 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_523
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER64))
vwatch64_SKIP_523:::: 
vwatch64_LABEL_524:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(524): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_524 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_524
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_524:::: 
vwatch64_LABEL_525:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(525): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_525 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_525
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_525:::: 
vwatch64_LABEL_526:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(526): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_526 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_526
tok_direct(TS_PLUS) = 15 
vwatch64_SKIP_526:::: 
vwatch64_LABEL_527:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(527): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_527 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_527
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_SINGLE))
vwatch64_SKIP_527:::: 
vwatch64_LABEL_528:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(528): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_528 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_528
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_528:::: 
vwatch64_LABEL_529:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(529): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_529 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_529
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_529:::: 
vwatch64_LABEL_530:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(530): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_530 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_530
tok_direct(TS_PLUS) = 15 
vwatch64_SKIP_530:::: 
vwatch64_LABEL_531:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(531): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_531 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_531
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_DOUBLE))
vwatch64_SKIP_531:::: 
vwatch64_LABEL_532:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(532): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_532 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_532
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_532:::: 
vwatch64_LABEL_533:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(533): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_533 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_533
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_533:::: 
vwatch64_LABEL_534:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(534): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_534 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_534
tok_direct(TS_PLUS) = 15 
vwatch64_SKIP_534:::: 
vwatch64_LABEL_535:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(535): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_535 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_535
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_QUAD))
vwatch64_SKIP_535:::: 
vwatch64_LABEL_536:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(536): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_536 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_536
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_536:::: 
vwatch64_LABEL_537:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(537): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_537 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_537
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_537:::: 
vwatch64_LABEL_538:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(538): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_538 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_538
tok_direct(TS_PLUS) = 15 
vwatch64_SKIP_538:::: 
vwatch64_LABEL_539:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(539): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_539 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_539
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_STRING))
vwatch64_SKIP_539:::: 
vwatch64_LABEL_540:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(540): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_540 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_540
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_540:::: 
vwatch64_LABEL_541:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(541): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_541 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_541
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_541:::: 
vwatch64_LABEL_542:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(542): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_542 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_542
tok_direct(TS_PLUS) = 15 
vwatch64_SKIP_542:::: 
vwatch64_LABEL_543:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(543): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_543 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_543
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_543:::: 
vwatch64_LABEL_544:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(544): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_544 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_544
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_544:::: 
vwatch64_LABEL_545:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(545): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_545 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_545
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_545:::: 
vwatch64_LABEL_546:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(546): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_546 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_546
htable_add_hentry "-", re
vwatch64_SKIP_546:::: 
vwatch64_LABEL_547:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(547): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_547 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_547
tok_direct(TS_DASH) = 16 
vwatch64_SKIP_547:::: 
vwatch64_LABEL_548:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(548): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_548 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_548
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_548:::: 
vwatch64_LABEL_549:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(549): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_549 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_549
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_549:::: 
vwatch64_LABEL_550:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(550): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_550 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_550
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_550:::: 
vwatch64_LABEL_551:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(551): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_551 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_551
tok_direct(TS_DASH) = 16 
vwatch64_SKIP_551:::: 
vwatch64_LABEL_552:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(552): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_552 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_552
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER64))
vwatch64_SKIP_552:::: 
vwatch64_LABEL_553:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(553): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_553 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_553
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_553:::: 
vwatch64_LABEL_554:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(554): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_554 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_554
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_554:::: 
vwatch64_LABEL_555:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(555): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_555 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_555
tok_direct(TS_DASH) = 16 
vwatch64_SKIP_555:::: 
vwatch64_LABEL_556:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(556): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_556 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_556
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_SINGLE))
vwatch64_SKIP_556:::: 
vwatch64_LABEL_557:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(557): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_557 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_557
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_557:::: 
vwatch64_LABEL_558:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(558): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_558 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_558
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_558:::: 
vwatch64_LABEL_559:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(559): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_559 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_559
tok_direct(TS_DASH) = 16 
vwatch64_SKIP_559:::: 
vwatch64_LABEL_560:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(560): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_560 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_560
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_DOUBLE))
vwatch64_SKIP_560:::: 
vwatch64_LABEL_561:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(561): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_561 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_561
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_561:::: 
vwatch64_LABEL_562:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(562): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_562 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_562
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_562:::: 
vwatch64_LABEL_563:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(563): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_563 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_563
tok_direct(TS_DASH) = 16 
vwatch64_SKIP_563:::: 
vwatch64_LABEL_564:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(564): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_564 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_564
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_QUAD))
vwatch64_SKIP_564:::: 
vwatch64_LABEL_565:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(565): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_565 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_565
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_565:::: 
vwatch64_LABEL_566:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(566): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_566 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_566
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_566:::: 
vwatch64_LABEL_567:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(567): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_567 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_567
tok_direct(TS_DASH) = 16 
vwatch64_SKIP_567:::: 
vwatch64_LABEL_568:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(568): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_568 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_568
re.v2 = 5
vwatch64_SKIP_568:::: 
vwatch64_LABEL_569:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(569): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_569 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_569
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_569:::: 
vwatch64_LABEL_570:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(570): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_570 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_570
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_570:::: 
vwatch64_LABEL_571:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(571): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_571 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_571
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_571:::: 
vwatch64_LABEL_572:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(572): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_572 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_572
htable_add_hentry "*", re
vwatch64_SKIP_572:::: 
vwatch64_LABEL_573:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(573): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_573 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_573
tok_direct(TS_STAR) = 17 
vwatch64_SKIP_573:::: 
vwatch64_LABEL_574:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(574): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_574 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_574
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_574:::: 
vwatch64_LABEL_575:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(575): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_575 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_575
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_575:::: 
vwatch64_LABEL_576:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(576): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_576 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_576
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_576:::: 
vwatch64_LABEL_577:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(577): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_577 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_577
tok_direct(TS_STAR) = 17 
vwatch64_SKIP_577:::: 
vwatch64_LABEL_578:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(578): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_578 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_578
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER64))
vwatch64_SKIP_578:::: 
vwatch64_LABEL_579:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(579): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_579 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_579
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_579:::: 
vwatch64_LABEL_580:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(580): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_580 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_580
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_580:::: 
vwatch64_LABEL_581:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(581): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_581 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_581
tok_direct(TS_STAR) = 17 
vwatch64_SKIP_581:::: 
vwatch64_LABEL_582:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(582): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_582 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_582
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_SINGLE))
vwatch64_SKIP_582:::: 
vwatch64_LABEL_583:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(583): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_583 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_583
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_583:::: 
vwatch64_LABEL_584:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(584): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_584 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_584
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_584:::: 
vwatch64_LABEL_585:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(585): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_585 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_585
tok_direct(TS_STAR) = 17 
vwatch64_SKIP_585:::: 
vwatch64_LABEL_586:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(586): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_586 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_586
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_DOUBLE))
vwatch64_SKIP_586:::: 
vwatch64_LABEL_587:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(587): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_587 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_587
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_587:::: 
vwatch64_LABEL_588:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(588): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_588 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_588
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_588:::: 
vwatch64_LABEL_589:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(589): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_589 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_589
tok_direct(TS_STAR) = 17 
vwatch64_SKIP_589:::: 
vwatch64_LABEL_590:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(590): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_590 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_590
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_QUAD))
vwatch64_SKIP_590:::: 
vwatch64_LABEL_591:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(591): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_591 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_591
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_591:::: 
vwatch64_LABEL_592:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(592): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_592 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_592
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_592:::: 
vwatch64_LABEL_593:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(593): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_593 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_593
tok_direct(TS_STAR) = 17 
vwatch64_SKIP_593:::: 
vwatch64_LABEL_594:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(594): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_594 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_594
re.v1 = type_add_sig(0, type_sig_create$(TYPE_SINGLE))
vwatch64_SKIP_594:::: 
vwatch64_LABEL_595:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(595): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_595 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_595
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_595:::: 
vwatch64_LABEL_596:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(596): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_596 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_596
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_596:::: 
vwatch64_LABEL_597:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(597): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_597 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_597
htable_add_hentry "/", re
vwatch64_SKIP_597:::: 
vwatch64_LABEL_598:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(598): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_598 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_598
tok_direct(TS_SLASH) = 18 
vwatch64_SKIP_598:::: 
vwatch64_LABEL_599:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(599): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_599 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_599
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_DOUBLE))
vwatch64_SKIP_599:::: 
vwatch64_LABEL_600:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(600): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_600 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_600
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_600:::: 
vwatch64_LABEL_601:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(601): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_601 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_601
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_601:::: 
vwatch64_LABEL_602:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(602): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_602 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_602
tok_direct(TS_SLASH) = 18 
vwatch64_SKIP_602:::: 
vwatch64_LABEL_603:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(603): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_603 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_603
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_QUAD))
vwatch64_SKIP_603:::: 
vwatch64_LABEL_604:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(604): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_604 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_604
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_604:::: 
vwatch64_LABEL_605:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(605): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_605 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_605
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_605:::: 
vwatch64_LABEL_606:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(606): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_606 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_606
tok_direct(TS_SLASH) = 18 
vwatch64_SKIP_606:::: 
vwatch64_LABEL_607:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(607): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_607 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_607
re.typ = HE_PREFIX
vwatch64_SKIP_607:::: 
vwatch64_LABEL_608:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(608): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_608 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_608
re.v2 = 6
vwatch64_SKIP_608:::: 
vwatch64_LABEL_609:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(609): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_609 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_609
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_609:::: 
vwatch64_LABEL_610:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(610): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_610 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_610
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_610:::: 
vwatch64_LABEL_611:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(611): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_611 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_611
htable_add_hentry "NEGATIVE", re
vwatch64_SKIP_611:::: 
vwatch64_LABEL_612:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(612): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_612 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_612
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_612:::: 
vwatch64_LABEL_613:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(613): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_613 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_613
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_613:::: 
vwatch64_LABEL_614:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(614): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_614 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_614
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER64))
vwatch64_SKIP_614:::: 
vwatch64_LABEL_615:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(615): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_615 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_615
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_615:::: 
vwatch64_LABEL_616:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(616): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_616 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_616
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_SINGLE))
vwatch64_SKIP_616:::: 
vwatch64_LABEL_617:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(617): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_617 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_617
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_617:::: 
vwatch64_LABEL_618:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(618): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_618 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_618
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_DOUBLE))
vwatch64_SKIP_618:::: 
vwatch64_LABEL_619:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(619): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_619 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_619
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_619:::: 
vwatch64_LABEL_620:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(620): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_620 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_620
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_QUAD))
vwatch64_SKIP_620:::: 
vwatch64_LABEL_621:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(621): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_621 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_621
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_621:::: 
vwatch64_LABEL_622:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(622): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_622 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_622
re.typ = HE_INFIX
vwatch64_SKIP_622:::: 
vwatch64_LABEL_623:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(623): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_623 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_623
re.v2 = 7
vwatch64_SKIP_623:::: 
vwatch64_LABEL_624:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(624): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_624 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_624
re.v3 = 0
vwatch64_SKIP_624:::: 
vwatch64_LABEL_625:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(625): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_625 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_625
re.v1 = type_add_sig(0, type_sig_create$(TYPE_SINGLE))
vwatch64_SKIP_625:::: 
vwatch64_LABEL_626:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(626): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_626 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_626
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_626:::: 
vwatch64_LABEL_627:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(627): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_627 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_627
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_627:::: 
vwatch64_LABEL_628:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(628): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_628 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_628
htable_add_hentry "^", re
vwatch64_SKIP_628:::: 
vwatch64_LABEL_629:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(629): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_629 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_629
tok_direct(TS_POWER) = 20 
vwatch64_SKIP_629:::: 
vwatch64_LABEL_630:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(630): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_630 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_630
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_DOUBLE))
vwatch64_SKIP_630:::: 
vwatch64_LABEL_631:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(631): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_631 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_631
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_631:::: 
vwatch64_LABEL_632:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(632): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_632 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_632
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_632:::: 
vwatch64_LABEL_633:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(633): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_633 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_633
tok_direct(TS_POWER) = 20 
vwatch64_SKIP_633:::: 
vwatch64_LABEL_634:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(634): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_634 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_634
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_QUAD))
vwatch64_SKIP_634:::: 
vwatch64_LABEL_635:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(635): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_635 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_635
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_635:::: 
vwatch64_LABEL_636:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(636): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_636 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_636
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_636:::: 
vwatch64_LABEL_637:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(637): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_637 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_637
tok_direct(TS_POWER) = 20 
vwatch64_SKIP_637:::: 
vwatch64_LABEL_638:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(638): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_638 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_638
re.typ = HE_GENERIC
vwatch64_SKIP_638:::: 
vwatch64_LABEL_639:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(639): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_639 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_639
htable_add_hentry "|OPAREN", re
vwatch64_SKIP_639:::: 
vwatch64_LABEL_640:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(640): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_640 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_640
tok_direct(TS_OPAREN) = 21 
vwatch64_SKIP_640:::: 
vwatch64_LABEL_641:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(641): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_641 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_641
htable_add_hentry "|CPAREN", re
vwatch64_SKIP_641:::: 
vwatch64_LABEL_642:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(642): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_642 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_642
tok_direct(TS_CPAREN) = 22 
vwatch64_SKIP_642:::: 
vwatch64_LABEL_643:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(643): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_643 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_643
tok_direct(TS_NUMINT) =-1 
vwatch64_SKIP_643:::: 
vwatch64_LABEL_644:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(644): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_644 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_644
tok_direct(TS_NUMDEC) =-2 
vwatch64_SKIP_644:::: 
vwatch64_LABEL_645:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(645): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_645 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_645
tok_direct(TS_NUMEXP) =-3 
vwatch64_SKIP_645:::: 
vwatch64_LABEL_646:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(646): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_646 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_646
tok_direct(TS_NUMBASE) =-4 
vwatch64_SKIP_646:::: 
vwatch64_LABEL_647:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(647): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_647 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_647
tok_direct(TS_STRING) =-5 
vwatch64_SKIP_647:::: 
vwatch64_LABEL_648:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(648): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_648 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_648
re.typ = HE_GENERIC
vwatch64_SKIP_648:::: 
vwatch64_LABEL_649:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(649): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_649 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_649
htable_add_hentry "|INTEGER_SFX", re
vwatch64_SKIP_649:::: 
vwatch64_LABEL_650:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(650): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_650 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_650
tok_direct(TS_INTEGER_SFX) = 23 
vwatch64_SKIP_650:::: 
vwatch64_LABEL_651:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(651): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_651 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_651
htable_add_hentry "|LONG_SFX", re
vwatch64_SKIP_651:::: 
vwatch64_LABEL_652:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(652): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_652 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_652
tok_direct(TS_LONG_SFX) = 24 
vwatch64_SKIP_652:::: 
vwatch64_LABEL_653:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(653): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_653 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_653
htable_add_hentry "|INTEGER64_SFX", re
vwatch64_SKIP_653:::: 
vwatch64_LABEL_654:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(654): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_654 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_654
tok_direct(TS_INTEGER64_SFX) = 25 
vwatch64_SKIP_654:::: 
vwatch64_LABEL_655:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(655): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_655 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_655
htable_add_hentry "|OFFSET_SFX", re
vwatch64_SKIP_655:::: 
vwatch64_LABEL_656:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(656): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_656 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_656
tok_direct(TS_OFFSET_SFX) = 26 
vwatch64_SKIP_656:::: 
vwatch64_LABEL_657:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(657): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_657 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_657
htable_add_hentry "|SINGLE_SFX", re
vwatch64_SKIP_657:::: 
vwatch64_LABEL_658:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(658): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_658 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_658
tok_direct(TS_SINGLE_SFX) = 27 
vwatch64_SKIP_658:::: 
vwatch64_LABEL_659:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(659): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_659 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_659
htable_add_hentry "|DOUBLE_SFX", re
vwatch64_SKIP_659:::: 
vwatch64_LABEL_660:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(660): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_660 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_660
tok_direct(TS_DOUBLE_SFX) = 28 
vwatch64_SKIP_660:::: 
vwatch64_LABEL_661:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(661): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_661 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_661
htable_add_hentry "|QUAD_SFX", re
vwatch64_SKIP_661:::: 
vwatch64_LABEL_662:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(662): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_662 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_662
tok_direct(TS_QUAD_SFX) = 29 
vwatch64_SKIP_662:::: 
vwatch64_LABEL_663:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(663): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_663 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_663
htable_add_hentry "|STRING_SFX", re
vwatch64_SKIP_663:::: 
vwatch64_LABEL_664:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(664): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_664 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_664
tok_direct(TS_STRING_SFX) = 30 
vwatch64_SKIP_664:::: 
vwatch64_LABEL_665:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(665): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_665 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_665
htable_add_hentry "IF", re
vwatch64_SKIP_665:::: 
vwatch64_LABEL_666:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(666): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_666 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_666
htable_add_hentry "THEN", re
vwatch64_SKIP_666:::: 
vwatch64_LABEL_667:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(667): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_667 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_667
htable_add_hentry "ELSE", re
vwatch64_SKIP_667:::: 
vwatch64_LABEL_668:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(668): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_668 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_668
htable_add_hentry "END", re
vwatch64_SKIP_668:::: 
vwatch64_LABEL_669:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(669): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_669 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_669
htable_add_hentry "DO", re
vwatch64_SKIP_669:::: 
vwatch64_LABEL_670:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(670): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_670 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_670
htable_add_hentry "LOOP", re
vwatch64_SKIP_670:::: 
vwatch64_LABEL_671:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(671): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_671 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_671
htable_add_hentry "UNTIL", re
vwatch64_SKIP_671:::: 
vwatch64_LABEL_672:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(672): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_672 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_672
htable_add_hentry "WHILE", re
vwatch64_SKIP_672:::: 
vwatch64_LABEL_673:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(673): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_673 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_673
htable_add_hentry "WEND", re
vwatch64_SKIP_673:::: 
vwatch64_LABEL_674:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(674): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_674 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_674
htable_add_hentry "FOR", re
vwatch64_SKIP_674:::: 
vwatch64_LABEL_675:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(675): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_675 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_675
htable_add_hentry "TO", re
vwatch64_SKIP_675:::: 
vwatch64_LABEL_676:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(676): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_676 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_676
htable_add_hentry "STEP", re
vwatch64_SKIP_676:::: 
vwatch64_LABEL_677:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(677): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_677 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_677
htable_add_hentry "NEXT", re
vwatch64_SKIP_677:::: 
vwatch64_LABEL_678:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(678): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_678 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_678
htable_add_hentry "SELECT", re
vwatch64_SKIP_678:::: 
vwatch64_LABEL_679:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(679): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_679 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_679
htable_add_hentry "CASE", re
vwatch64_SKIP_679:::: 
vwatch64_LABEL_680:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(680): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_680 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_680
re.typ = HE_FUNCTION
vwatch64_SKIP_680:::: 
vwatch64_LABEL_681:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(681): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_681 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_681
re.v1 = type_add_sig(0, type_sig_create$(TYPE_NONE))
vwatch64_SKIP_681:::: 
vwatch64_LABEL_682:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(682): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_682 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_682
htable_add_hentry "_AUTODISPLAY", re
vwatch64_SKIP_682:::: 
vwatch64_LABEL_683:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(683): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_683 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_683
re.v1 = type_add_sig(0, type_sig_create$(TYPE_NONE))
vwatch64_SKIP_683:::: 
vwatch64_LABEL_684:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(684): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_684 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_684
htable_add_hentry "BEEP", re
vwatch64_SKIP_684:::: 
vwatch64_LABEL_685:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(685): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_685 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_685
re.v1 = type_add_sig(0, type_sig_create$(TYPE_STRING))
vwatch64_SKIP_685:::: 
vwatch64_LABEL_686:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(686): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_686 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_686
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_686:::: 
vwatch64_LABEL_687:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(687): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_687 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_687
htable_add_hentry "CHR", re
vwatch64_SKIP_687:::: 
vwatch64_LABEL_688:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(688): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_688 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_688
re.v1 = type_add_sig(0, type_sig_create$(TYPE_NONE))
vwatch64_SKIP_688:::: 
vwatch64_LABEL_689:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(689): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_689 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_689
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_689:::: 
vwatch64_LABEL_690:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(690): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_690 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_690
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_690:::: 
vwatch64_LABEL_691:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(691): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_691 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_691
htable_add_hentry "_COPYPALETTE", re
vwatch64_SKIP_691:::: 
vwatch64_LABEL_692:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(692): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_692 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_692
re.v1 = type_add_sig(0, type_sig_create$(TYPE_STRING))
vwatch64_SKIP_692:::: 
vwatch64_LABEL_693:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(693): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_693 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_693
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_693:::: 
vwatch64_LABEL_694:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(694): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_694 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_694
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_694:::: 
vwatch64_LABEL_695:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(695): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_695 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_695
htable_add_hentry "LEFT", re
vwatch64_SKIP_695:::: 
vwatch64_LABEL_696:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(696): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_696 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_696
re.v1 = type_add_sig(0, type_sig_create$(TYPE_NONE))
vwatch64_SKIP_696:::: 
vwatch64_LABEL_697:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(697): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_697 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_697
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_697:::: 
vwatch64_LABEL_698:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(698): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_698 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_698
htable_add_hentry "PRINT", re
vwatch64_SKIP_698:::: 
vwatch64_LABEL_699:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(699): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_699 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_699
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_NONE))
vwatch64_SKIP_699:::: 
vwatch64_LABEL_700:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(700): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_700 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_700
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_700:::: 
vwatch64_LABEL_701:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(701): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_701 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_701
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_NONE))
vwatch64_SKIP_701:::: 
vwatch64_LABEL_702:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(702): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_702 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_702
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_702:::: 
vwatch64_LABEL_703:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(703): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_703 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_703
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_NONE))
vwatch64_SKIP_703:::: 
vwatch64_LABEL_704:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(704): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_704 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_704
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_704:::: 
vwatch64_LABEL_705:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(705): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_705 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_705
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_NONE))
vwatch64_SKIP_705:::: 
vwatch64_LABEL_706:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(706): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_706 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_706
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_706:::: 
vwatch64_LABEL_707:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(707): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_707 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_707
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_NONE))
vwatch64_SKIP_707:::: 
vwatch64_LABEL_708:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(708): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_708 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_708
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_708:::: 
vwatch64_LABEL_709:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(709): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_709 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_709
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_NONE))
vwatch64_SKIP_709:::: 
vwatch64_LABEL_710:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(710): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_710 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_710
type_add_sig_arg re.v1, TYPE_STRING, 1 
vwatch64_SKIP_710:::: 
vwatch64_LABEL_711:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(711): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_711 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_711
re.v1 = type_add_sig(0, type_sig_create$(TYPE_LONG))
vwatch64_SKIP_711:::: 
vwatch64_LABEL_712:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(712): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_712 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_712
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_712:::: 
vwatch64_LABEL_713:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(713): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_713 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_713
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_713:::: 
vwatch64_LABEL_714:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(714): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_714 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_714
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_714:::: 
vwatch64_LABEL_715:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(715): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_715 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_715
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_715:::: 
vwatch64_LABEL_716:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(716): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_716 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_716
htable_add_hentry "RGBA", re
vwatch64_SKIP_716:::: 
vwatch64_LABEL_717:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(717): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_717 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_717
re.v1 = type_add_sig(0, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_717:::: 
vwatch64_LABEL_718:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(718): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_718 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_718
type_add_sig_arg re.v1, TYPE_INTEGER, 1 
vwatch64_SKIP_718:::: 
vwatch64_LABEL_719:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(719): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_719 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_719
htable_add_hentry "INT", re
vwatch64_SKIP_719:::: 
vwatch64_LABEL_720:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(720): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_720 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_720
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_720:::: 
vwatch64_LABEL_721:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(721): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_721 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_721
type_add_sig_arg re.v1, TYPE_LONG, 1 
vwatch64_SKIP_721:::: 
vwatch64_LABEL_722:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(722): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_722 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_722
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_722:::: 
vwatch64_LABEL_723:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(723): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_723 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_723
type_add_sig_arg re.v1, TYPE_INTEGER64, 1 
vwatch64_SKIP_723:::: 
vwatch64_LABEL_724:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(724): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_724 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_724
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_724:::: 
vwatch64_LABEL_725:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(725): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_725 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_725
type_add_sig_arg re.v1, TYPE_SINGLE, 1 
vwatch64_SKIP_725:::: 
vwatch64_LABEL_726:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(726): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_726 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_726
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_726:::: 
vwatch64_LABEL_727:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(727): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_727 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_727
type_add_sig_arg re.v1, TYPE_DOUBLE, 1 
vwatch64_SKIP_727:::: 
vwatch64_LABEL_728:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(728): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_728 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_728
re.v1 = type_add_sig(re.v1, type_sig_create$(TYPE_INTEGER))
vwatch64_SKIP_728:::: 
vwatch64_LABEL_729:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(729): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_729 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_729
type_add_sig_arg re.v1, TYPE_QUAD, 1 
vwatch64_SKIP_729:::: 

'This is the number of local variables
'Eventually this will need to be per-scope, but for now it's just going here
dim shared ps_last_var_index as long
'*INCLUDE file merged: 'emitters/immediate/immediate.bi'
type imm_value_t
    t as long
    n as _float
    s as string
end type

'Since we only have one scope for now, the stack is static in size
redim shared imm_stack(0) as imm_value_t
dim shared imm_stack_last as long

vwatch64_LABEL_745:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(745): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_745 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_745
basedir$ = _startdir$ 'Data files relative to here
vwatch64_SKIP_745:::: 

type options_t
    inputfile as string
    outputfile as string
    verbose as integer
    immediate_mode as integer
    debug as integer
end type

dim shared options as options_t
vwatch64_LABEL_756:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(756): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_756 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_756
parse_cmd_line_args
vwatch64_SKIP_756:::: 

vwatch64_LABEL_758:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(758): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_758 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_758
if instr(_os$, "[WINDOWS]") then
vwatch64_SKIP_758:::: 
vwatch64_LABEL_759:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(759): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_759 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_759
    exe_suffix$ = ".exe"
vwatch64_SKIP_759:::: 
vwatch64_LABEL_760:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(760): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_760 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_760
else
vwatch64_SKIP_760:::: 
vwatch64_LABEL_761:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(761): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_761 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_761
    exe_suffix$ = ""
vwatch64_SKIP_761:::: 
vwatch64_LABEL_762:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(762): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_762 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_762
end if
vwatch64_SKIP_762:::: 

'Output file defaults to input file with .bas changed to .exe (or nothing on Unix)
vwatch64_LABEL_765:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(765): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_765 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_765
if options.inputfile = "" then fatalerror "No input file"
vwatch64_SKIP_765:::: 
vwatch64_LABEL_766:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(766): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_766 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_766
if options.outputfile = "" then options.outputfile = remove_ext$(options.inputfile) + exe_suffix$
vwatch64_SKIP_766:::: 

'Relative paths should be relative to the basedir$
vwatch64_LABEL_769:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(769): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_769 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_769
if instr("/", left$(options.inputfile, 1)) = 0 then options.inputfile = basedir$ + "/" + options.inputfile
vwatch64_SKIP_769:::: 
vwatch64_LABEL_770:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(770): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_770 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_770
if instr("/", left$(options.outputfile, 1)) = 0 then options.outputfile = basedir$ + "/" + options.outputfile
vwatch64_SKIP_770:::: 

vwatch64_LABEL_772:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(772): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_772 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_772
if options.verbose then
vwatch64_SKIP_772:::: 
vwatch64_LABEL_773:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(773): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_773 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_773
    show_version
vwatch64_SKIP_773:::: 
vwatch64_LABEL_774:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(774): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_774 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_774
    print "Input file: "; options.inputfile
vwatch64_SKIP_774:::: 
vwatch64_LABEL_775:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(775): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_775 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_775
    if options.immediate_mode then
vwatch64_SKIP_775:::: 
vwatch64_LABEL_776:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(776): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_776 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_776
        print "Immediate mode"
vwatch64_SKIP_776:::: 
vwatch64_LABEL_777:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(777): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_777 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_777
    else
vwatch64_SKIP_777:::: 
vwatch64_LABEL_778:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(778): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_778 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_778
        print "Output file: "; options.outputfile
vwatch64_SKIP_778:::: 
vwatch64_LABEL_779:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(779): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_779 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_779
    end if
vwatch64_SKIP_779:::: 
vwatch64_LABEL_780:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(780): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_780 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_780
end if
vwatch64_SKIP_780:::: 

vwatch64_LABEL_782:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(782): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_782 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_782
ast_init
vwatch64_SKIP_782:::: 
vwatch64_LABEL_783:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(783): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_783 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_783
open options.inputfile for input as #1
vwatch64_SKIP_783:::: 
vwatch64_LABEL_784:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(784): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_784 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_784
root = ps_block
vwatch64_SKIP_784:::: 
vwatch64_LABEL_785:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(785): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_785 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_785
close #1
vwatch64_SKIP_785:::: 

vwatch64_LABEL_787:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(787): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_787 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_787
if options.immediate_mode then
vwatch64_SKIP_787:::: 
vwatch64_LABEL_788:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(788): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_788 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_788
    on error goto runtime_error
vwatch64_SKIP_788:::: 
vwatch64_LABEL_789:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(789): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_789 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_789
    imm_init
vwatch64_SKIP_789:::: 
vwatch64_LABEL_790:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(790): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_790 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_790
    imm_run root
vwatch64_SKIP_790:::: 
vwatch64_LABEL_791:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(791): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_791 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_791
else
vwatch64_SKIP_791:::: 
vwatch64_LABEL_792:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(792): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_792 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_792
    open options.outputfile for output as #1
vwatch64_SKIP_792:::: 
vwatch64_LABEL_793:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(793): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_793 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_793
    dump_program root
vwatch64_SKIP_793:::: 
vwatch64_LABEL_794:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(794): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_794 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_794
    close #1
vwatch64_SKIP_794:::: 
vwatch64_LABEL_795:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(795): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_795 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_795
end if
vwatch64_SKIP_795:::: 

vwatch64_LABEL_797:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(797): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_797 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_797
ON ERROR GOTO vwatch64_FILEERROR
IF vwatch64_HEADER.CONNECTED THEN
    vwatch64_HEADER.CONNECTED = 0
    PUT #vwatch64_CLIENTFILE, 1, vwatch64_HEADER
END IF
CLOSE #vwatch64_CLIENTFILE
KILL "/home/luke/comp/git_qb64/vwatch64.dat"
ON ERROR GOTO 0
system
vwatch64_SKIP_797:::: 

'Used by immediate mode
vwatch64_LABEL_800:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(800): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_800 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_800
runtime_error:
vwatch64_SKIP_800:::: 
vwatch64_LABEL_801:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(801): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_801 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_801
    if err = 6 then fatalerror "Overflow"
vwatch64_SKIP_801:::: 
'Error handler for everything else
vwatch64_LABEL_803:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(803): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_803 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_803
generic_error:
vwatch64_SKIP_803:::: 
vwatch64_LABEL_804:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(804): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_804 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_804
    if _inclerrorline then
vwatch64_SKIP_804:::: 
vwatch64_LABEL_805:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(805): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_805 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_805
        fatalerror command$(0) + ": Internal error" + str$(err) + " on line" + str$(_inclerrorline) + " of " + _inclerrorfile$ + " (called from line" + str$(_errorline) + ")"
vwatch64_SKIP_805:::: 
vwatch64_LABEL_806:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(806): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_806 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_806
    else
vwatch64_SKIP_806:::: 
vwatch64_LABEL_807:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(807): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_807 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_807
        fatalerror command$(0) + ": Internal error" + str$(err) + " on line" + str$(_errorline)
vwatch64_SKIP_807:::: 
vwatch64_LABEL_808:::: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(808): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_808 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_808
    end if
vwatch64_SKIP_808:::: 

IF vwatch64_HEADER.CONNECTED THEN
    vwatch64_HEADER.CONNECTED = 0
    PUT #vwatch64_CLIENTFILE, 1, vwatch64_HEADER
END IF
CLOSE #vwatch64_CLIENTFILE
ON ERROR GOTO vwatch64_FILEERROR
KILL vwatch64_FILENAME

END
vwatch64_FILEERROR:
RESUME NEXT

vwatch64_CLIENTFILEERROR:
IF vwatch64_HEADER.CONNECTED THEN OPEN vwatch64_FILENAME FOR BINARY AS vwatch64_CLIENTFILE
RESUME

vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 3: GOTO vwatch64_LABEL_3
    CASE 6: GOTO vwatch64_LABEL_6
    CASE 9: GOTO vwatch64_LABEL_9
    CASE 104: GOTO vwatch64_LABEL_104
    CASE 293: GOTO vwatch64_LABEL_293
    CASE 300: GOTO vwatch64_LABEL_300
    CASE 301: GOTO vwatch64_LABEL_301
    CASE 302: GOTO vwatch64_LABEL_302
    CASE 303: GOTO vwatch64_LABEL_303
    CASE 304: GOTO vwatch64_LABEL_304
    CASE 305: GOTO vwatch64_LABEL_305
    CASE 306: GOTO vwatch64_LABEL_306
    CASE 307: GOTO vwatch64_LABEL_307
    CASE 308: GOTO vwatch64_LABEL_308
    CASE 309: GOTO vwatch64_LABEL_309
    CASE 310: GOTO vwatch64_LABEL_310
    CASE 311: GOTO vwatch64_LABEL_311
    CASE 312: GOTO vwatch64_LABEL_312
    CASE 313: GOTO vwatch64_LABEL_313
    CASE 314: GOTO vwatch64_LABEL_314
    CASE 315: GOTO vwatch64_LABEL_315
    CASE 316: GOTO vwatch64_LABEL_316
    CASE 317: GOTO vwatch64_LABEL_317
    CASE 318: GOTO vwatch64_LABEL_318
    CASE 319: GOTO vwatch64_LABEL_319
    CASE 320: GOTO vwatch64_LABEL_320
    CASE 321: GOTO vwatch64_LABEL_321
    CASE 322: GOTO vwatch64_LABEL_322
    CASE 323: GOTO vwatch64_LABEL_323
    CASE 324: GOTO vwatch64_LABEL_324
    CASE 325: GOTO vwatch64_LABEL_325
    CASE 326: GOTO vwatch64_LABEL_326
    CASE 327: GOTO vwatch64_LABEL_327
    CASE 328: GOTO vwatch64_LABEL_328
    CASE 329: GOTO vwatch64_LABEL_329
    CASE 330: GOTO vwatch64_LABEL_330
    CASE 331: GOTO vwatch64_LABEL_331
    CASE 332: GOTO vwatch64_LABEL_332
    CASE 333: GOTO vwatch64_LABEL_333
    CASE 334: GOTO vwatch64_LABEL_334
    CASE 335: GOTO vwatch64_LABEL_335
    CASE 336: GOTO vwatch64_LABEL_336
    CASE 337: GOTO vwatch64_LABEL_337
    CASE 338: GOTO vwatch64_LABEL_338
    CASE 339: GOTO vwatch64_LABEL_339
    CASE 340: GOTO vwatch64_LABEL_340
    CASE 341: GOTO vwatch64_LABEL_341
    CASE 342: GOTO vwatch64_LABEL_342
    CASE 343: GOTO vwatch64_LABEL_343
    CASE 344: GOTO vwatch64_LABEL_344
    CASE 345: GOTO vwatch64_LABEL_345
    CASE 346: GOTO vwatch64_LABEL_346
    CASE 347: GOTO vwatch64_LABEL_347
    CASE 348: GOTO vwatch64_LABEL_348
    CASE 349: GOTO vwatch64_LABEL_349
    CASE 350: GOTO vwatch64_LABEL_350
    CASE 351: GOTO vwatch64_LABEL_351
    CASE 352: GOTO vwatch64_LABEL_352
    CASE 353: GOTO vwatch64_LABEL_353
    CASE 354: GOTO vwatch64_LABEL_354
    CASE 355: GOTO vwatch64_LABEL_355
    CASE 356: GOTO vwatch64_LABEL_356
    CASE 357: GOTO vwatch64_LABEL_357
    CASE 358: GOTO vwatch64_LABEL_358
    CASE 359: GOTO vwatch64_LABEL_359
    CASE 360: GOTO vwatch64_LABEL_360
    CASE 361: GOTO vwatch64_LABEL_361
    CASE 362: GOTO vwatch64_LABEL_362
    CASE 363: GOTO vwatch64_LABEL_363
    CASE 364: GOTO vwatch64_LABEL_364
    CASE 365: GOTO vwatch64_LABEL_365
    CASE 366: GOTO vwatch64_LABEL_366
    CASE 367: GOTO vwatch64_LABEL_367
    CASE 368: GOTO vwatch64_LABEL_368
    CASE 369: GOTO vwatch64_LABEL_369
    CASE 370: GOTO vwatch64_LABEL_370
    CASE 371: GOTO vwatch64_LABEL_371
    CASE 372: GOTO vwatch64_LABEL_372
    CASE 373: GOTO vwatch64_LABEL_373
    CASE 374: GOTO vwatch64_LABEL_374
    CASE 375: GOTO vwatch64_LABEL_375
    CASE 376: GOTO vwatch64_LABEL_376
    CASE 377: GOTO vwatch64_LABEL_377
    CASE 378: GOTO vwatch64_LABEL_378
    CASE 379: GOTO vwatch64_LABEL_379
    CASE 380: GOTO vwatch64_LABEL_380
    CASE 381: GOTO vwatch64_LABEL_381
    CASE 382: GOTO vwatch64_LABEL_382
    CASE 383: GOTO vwatch64_LABEL_383
    CASE 384: GOTO vwatch64_LABEL_384
    CASE 385: GOTO vwatch64_LABEL_385
    CASE 386: GOTO vwatch64_LABEL_386
    CASE 387: GOTO vwatch64_LABEL_387
    CASE 388: GOTO vwatch64_LABEL_388
    CASE 389: GOTO vwatch64_LABEL_389
    CASE 390: GOTO vwatch64_LABEL_390
    CASE 391: GOTO vwatch64_LABEL_391
    CASE 392: GOTO vwatch64_LABEL_392
    CASE 393: GOTO vwatch64_LABEL_393
    CASE 394: GOTO vwatch64_LABEL_394
    CASE 395: GOTO vwatch64_LABEL_395
    CASE 396: GOTO vwatch64_LABEL_396
    CASE 397: GOTO vwatch64_LABEL_397
    CASE 398: GOTO vwatch64_LABEL_398
    CASE 399: GOTO vwatch64_LABEL_399
    CASE 400: GOTO vwatch64_LABEL_400
    CASE 401: GOTO vwatch64_LABEL_401
    CASE 402: GOTO vwatch64_LABEL_402
    CASE 403: GOTO vwatch64_LABEL_403
    CASE 404: GOTO vwatch64_LABEL_404
    CASE 405: GOTO vwatch64_LABEL_405
    CASE 406: GOTO vwatch64_LABEL_406
    CASE 407: GOTO vwatch64_LABEL_407
    CASE 408: GOTO vwatch64_LABEL_408
    CASE 409: GOTO vwatch64_LABEL_409
    CASE 410: GOTO vwatch64_LABEL_410
    CASE 411: GOTO vwatch64_LABEL_411
    CASE 412: GOTO vwatch64_LABEL_412
    CASE 413: GOTO vwatch64_LABEL_413
    CASE 414: GOTO vwatch64_LABEL_414
    CASE 415: GOTO vwatch64_LABEL_415
    CASE 416: GOTO vwatch64_LABEL_416
    CASE 417: GOTO vwatch64_LABEL_417
    CASE 418: GOTO vwatch64_LABEL_418
    CASE 419: GOTO vwatch64_LABEL_419
    CASE 420: GOTO vwatch64_LABEL_420
    CASE 421: GOTO vwatch64_LABEL_421
    CASE 422: GOTO vwatch64_LABEL_422
    CASE 423: GOTO vwatch64_LABEL_423
    CASE 424: GOTO vwatch64_LABEL_424
    CASE 425: GOTO vwatch64_LABEL_425
    CASE 426: GOTO vwatch64_LABEL_426
    CASE 427: GOTO vwatch64_LABEL_427
    CASE 428: GOTO vwatch64_LABEL_428
    CASE 429: GOTO vwatch64_LABEL_429
    CASE 430: GOTO vwatch64_LABEL_430
    CASE 431: GOTO vwatch64_LABEL_431
    CASE 432: GOTO vwatch64_LABEL_432
    CASE 433: GOTO vwatch64_LABEL_433
    CASE 434: GOTO vwatch64_LABEL_434
    CASE 435: GOTO vwatch64_LABEL_435
    CASE 436: GOTO vwatch64_LABEL_436
    CASE 437: GOTO vwatch64_LABEL_437
    CASE 438: GOTO vwatch64_LABEL_438
    CASE 439: GOTO vwatch64_LABEL_439
    CASE 440: GOTO vwatch64_LABEL_440
    CASE 441: GOTO vwatch64_LABEL_441
    CASE 442: GOTO vwatch64_LABEL_442
    CASE 443: GOTO vwatch64_LABEL_443
    CASE 444: GOTO vwatch64_LABEL_444
    CASE 445: GOTO vwatch64_LABEL_445
    CASE 446: GOTO vwatch64_LABEL_446
    CASE 447: GOTO vwatch64_LABEL_447
    CASE 448: GOTO vwatch64_LABEL_448
    CASE 449: GOTO vwatch64_LABEL_449
    CASE 450: GOTO vwatch64_LABEL_450
    CASE 451: GOTO vwatch64_LABEL_451
    CASE 452: GOTO vwatch64_LABEL_452
    CASE 453: GOTO vwatch64_LABEL_453
    CASE 454: GOTO vwatch64_LABEL_454
    CASE 455: GOTO vwatch64_LABEL_455
    CASE 456: GOTO vwatch64_LABEL_456
    CASE 457: GOTO vwatch64_LABEL_457
    CASE 458: GOTO vwatch64_LABEL_458
    CASE 459: GOTO vwatch64_LABEL_459
    CASE 460: GOTO vwatch64_LABEL_460
    CASE 461: GOTO vwatch64_LABEL_461
    CASE 462: GOTO vwatch64_LABEL_462
    CASE 463: GOTO vwatch64_LABEL_463
    CASE 464: GOTO vwatch64_LABEL_464
    CASE 465: GOTO vwatch64_LABEL_465
    CASE 466: GOTO vwatch64_LABEL_466
    CASE 467: GOTO vwatch64_LABEL_467
    CASE 468: GOTO vwatch64_LABEL_468
    CASE 469: GOTO vwatch64_LABEL_469
    CASE 470: GOTO vwatch64_LABEL_470
    CASE 471: GOTO vwatch64_LABEL_471
    CASE 472: GOTO vwatch64_LABEL_472
    CASE 473: GOTO vwatch64_LABEL_473
    CASE 474: GOTO vwatch64_LABEL_474
    CASE 475: GOTO vwatch64_LABEL_475
    CASE 476: GOTO vwatch64_LABEL_476
    CASE 477: GOTO vwatch64_LABEL_477
    CASE 478: GOTO vwatch64_LABEL_478
    CASE 479: GOTO vwatch64_LABEL_479
    CASE 480: GOTO vwatch64_LABEL_480
    CASE 481: GOTO vwatch64_LABEL_481
    CASE 482: GOTO vwatch64_LABEL_482
    CASE 483: GOTO vwatch64_LABEL_483
    CASE 484: GOTO vwatch64_LABEL_484
    CASE 485: GOTO vwatch64_LABEL_485
    CASE 486: GOTO vwatch64_LABEL_486
    CASE 487: GOTO vwatch64_LABEL_487
    CASE 488: GOTO vwatch64_LABEL_488
    CASE 489: GOTO vwatch64_LABEL_489
    CASE 490: GOTO vwatch64_LABEL_490
    CASE 491: GOTO vwatch64_LABEL_491
    CASE 492: GOTO vwatch64_LABEL_492
    CASE 493: GOTO vwatch64_LABEL_493
    CASE 494: GOTO vwatch64_LABEL_494
    CASE 495: GOTO vwatch64_LABEL_495
    CASE 496: GOTO vwatch64_LABEL_496
    CASE 497: GOTO vwatch64_LABEL_497
    CASE 498: GOTO vwatch64_LABEL_498
    CASE 499: GOTO vwatch64_LABEL_499
    CASE 500: GOTO vwatch64_LABEL_500
    CASE 501: GOTO vwatch64_LABEL_501
    CASE 502: GOTO vwatch64_LABEL_502
    CASE 503: GOTO vwatch64_LABEL_503
    CASE 504: GOTO vwatch64_LABEL_504
    CASE 505: GOTO vwatch64_LABEL_505
    CASE 506: GOTO vwatch64_LABEL_506
    CASE 507: GOTO vwatch64_LABEL_507
    CASE 508: GOTO vwatch64_LABEL_508
    CASE 509: GOTO vwatch64_LABEL_509
    CASE 510: GOTO vwatch64_LABEL_510
    CASE 511: GOTO vwatch64_LABEL_511
    CASE 512: GOTO vwatch64_LABEL_512
    CASE 513: GOTO vwatch64_LABEL_513
    CASE 514: GOTO vwatch64_LABEL_514
    CASE 515: GOTO vwatch64_LABEL_515
    CASE 516: GOTO vwatch64_LABEL_516
    CASE 517: GOTO vwatch64_LABEL_517
    CASE 518: GOTO vwatch64_LABEL_518
    CASE 519: GOTO vwatch64_LABEL_519
    CASE 520: GOTO vwatch64_LABEL_520
    CASE 521: GOTO vwatch64_LABEL_521
    CASE 522: GOTO vwatch64_LABEL_522
    CASE 523: GOTO vwatch64_LABEL_523
    CASE 524: GOTO vwatch64_LABEL_524
    CASE 525: GOTO vwatch64_LABEL_525
    CASE 526: GOTO vwatch64_LABEL_526
    CASE 527: GOTO vwatch64_LABEL_527
    CASE 528: GOTO vwatch64_LABEL_528
    CASE 529: GOTO vwatch64_LABEL_529
    CASE 530: GOTO vwatch64_LABEL_530
    CASE 531: GOTO vwatch64_LABEL_531
    CASE 532: GOTO vwatch64_LABEL_532
    CASE 533: GOTO vwatch64_LABEL_533
    CASE 534: GOTO vwatch64_LABEL_534
    CASE 535: GOTO vwatch64_LABEL_535
    CASE 536: GOTO vwatch64_LABEL_536
    CASE 537: GOTO vwatch64_LABEL_537
    CASE 538: GOTO vwatch64_LABEL_538
    CASE 539: GOTO vwatch64_LABEL_539
    CASE 540: GOTO vwatch64_LABEL_540
    CASE 541: GOTO vwatch64_LABEL_541
    CASE 542: GOTO vwatch64_LABEL_542
    CASE 543: GOTO vwatch64_LABEL_543
    CASE 544: GOTO vwatch64_LABEL_544
    CASE 545: GOTO vwatch64_LABEL_545
    CASE 546: GOTO vwatch64_LABEL_546
    CASE 547: GOTO vwatch64_LABEL_547
    CASE 548: GOTO vwatch64_LABEL_548
    CASE 549: GOTO vwatch64_LABEL_549
    CASE 550: GOTO vwatch64_LABEL_550
    CASE 551: GOTO vwatch64_LABEL_551
    CASE 552: GOTO vwatch64_LABEL_552
    CASE 553: GOTO vwatch64_LABEL_553
    CASE 554: GOTO vwatch64_LABEL_554
    CASE 555: GOTO vwatch64_LABEL_555
    CASE 556: GOTO vwatch64_LABEL_556
    CASE 557: GOTO vwatch64_LABEL_557
    CASE 558: GOTO vwatch64_LABEL_558
    CASE 559: GOTO vwatch64_LABEL_559
    CASE 560: GOTO vwatch64_LABEL_560
    CASE 561: GOTO vwatch64_LABEL_561
    CASE 562: GOTO vwatch64_LABEL_562
    CASE 563: GOTO vwatch64_LABEL_563
    CASE 564: GOTO vwatch64_LABEL_564
    CASE 565: GOTO vwatch64_LABEL_565
    CASE 566: GOTO vwatch64_LABEL_566
    CASE 567: GOTO vwatch64_LABEL_567
    CASE 568: GOTO vwatch64_LABEL_568
    CASE 569: GOTO vwatch64_LABEL_569
    CASE 570: GOTO vwatch64_LABEL_570
    CASE 571: GOTO vwatch64_LABEL_571
    CASE 572: GOTO vwatch64_LABEL_572
    CASE 573: GOTO vwatch64_LABEL_573
    CASE 574: GOTO vwatch64_LABEL_574
    CASE 575: GOTO vwatch64_LABEL_575
    CASE 576: GOTO vwatch64_LABEL_576
    CASE 577: GOTO vwatch64_LABEL_577
    CASE 578: GOTO vwatch64_LABEL_578
    CASE 579: GOTO vwatch64_LABEL_579
    CASE 580: GOTO vwatch64_LABEL_580
    CASE 581: GOTO vwatch64_LABEL_581
    CASE 582: GOTO vwatch64_LABEL_582
    CASE 583: GOTO vwatch64_LABEL_583
    CASE 584: GOTO vwatch64_LABEL_584
    CASE 585: GOTO vwatch64_LABEL_585
    CASE 586: GOTO vwatch64_LABEL_586
    CASE 587: GOTO vwatch64_LABEL_587
    CASE 588: GOTO vwatch64_LABEL_588
    CASE 589: GOTO vwatch64_LABEL_589
    CASE 590: GOTO vwatch64_LABEL_590
    CASE 591: GOTO vwatch64_LABEL_591
    CASE 592: GOTO vwatch64_LABEL_592
    CASE 593: GOTO vwatch64_LABEL_593
    CASE 594: GOTO vwatch64_LABEL_594
    CASE 595: GOTO vwatch64_LABEL_595
    CASE 596: GOTO vwatch64_LABEL_596
    CASE 597: GOTO vwatch64_LABEL_597
    CASE 598: GOTO vwatch64_LABEL_598
    CASE 599: GOTO vwatch64_LABEL_599
    CASE 600: GOTO vwatch64_LABEL_600
    CASE 601: GOTO vwatch64_LABEL_601
    CASE 602: GOTO vwatch64_LABEL_602
    CASE 603: GOTO vwatch64_LABEL_603
    CASE 604: GOTO vwatch64_LABEL_604
    CASE 605: GOTO vwatch64_LABEL_605
    CASE 606: GOTO vwatch64_LABEL_606
    CASE 607: GOTO vwatch64_LABEL_607
    CASE 608: GOTO vwatch64_LABEL_608
    CASE 609: GOTO vwatch64_LABEL_609
    CASE 610: GOTO vwatch64_LABEL_610
    CASE 611: GOTO vwatch64_LABEL_611
    CASE 612: GOTO vwatch64_LABEL_612
    CASE 613: GOTO vwatch64_LABEL_613
    CASE 614: GOTO vwatch64_LABEL_614
    CASE 615: GOTO vwatch64_LABEL_615
    CASE 616: GOTO vwatch64_LABEL_616
    CASE 617: GOTO vwatch64_LABEL_617
    CASE 618: GOTO vwatch64_LABEL_618
    CASE 619: GOTO vwatch64_LABEL_619
    CASE 620: GOTO vwatch64_LABEL_620
    CASE 621: GOTO vwatch64_LABEL_621
    CASE 622: GOTO vwatch64_LABEL_622
    CASE 623: GOTO vwatch64_LABEL_623
    CASE 624: GOTO vwatch64_LABEL_624
    CASE 625: GOTO vwatch64_LABEL_625
    CASE 626: GOTO vwatch64_LABEL_626
    CASE 627: GOTO vwatch64_LABEL_627
    CASE 628: GOTO vwatch64_LABEL_628
    CASE 629: GOTO vwatch64_LABEL_629
    CASE 630: GOTO vwatch64_LABEL_630
    CASE 631: GOTO vwatch64_LABEL_631
    CASE 632: GOTO vwatch64_LABEL_632
    CASE 633: GOTO vwatch64_LABEL_633
    CASE 634: GOTO vwatch64_LABEL_634
    CASE 635: GOTO vwatch64_LABEL_635
    CASE 636: GOTO vwatch64_LABEL_636
    CASE 637: GOTO vwatch64_LABEL_637
    CASE 638: GOTO vwatch64_LABEL_638
    CASE 639: GOTO vwatch64_LABEL_639
    CASE 640: GOTO vwatch64_LABEL_640
    CASE 641: GOTO vwatch64_LABEL_641
    CASE 642: GOTO vwatch64_LABEL_642
    CASE 643: GOTO vwatch64_LABEL_643
    CASE 644: GOTO vwatch64_LABEL_644
    CASE 645: GOTO vwatch64_LABEL_645
    CASE 646: GOTO vwatch64_LABEL_646
    CASE 647: GOTO vwatch64_LABEL_647
    CASE 648: GOTO vwatch64_LABEL_648
    CASE 649: GOTO vwatch64_LABEL_649
    CASE 650: GOTO vwatch64_LABEL_650
    CASE 651: GOTO vwatch64_LABEL_651
    CASE 652: GOTO vwatch64_LABEL_652
    CASE 653: GOTO vwatch64_LABEL_653
    CASE 654: GOTO vwatch64_LABEL_654
    CASE 655: GOTO vwatch64_LABEL_655
    CASE 656: GOTO vwatch64_LABEL_656
    CASE 657: GOTO vwatch64_LABEL_657
    CASE 658: GOTO vwatch64_LABEL_658
    CASE 659: GOTO vwatch64_LABEL_659
    CASE 660: GOTO vwatch64_LABEL_660
    CASE 661: GOTO vwatch64_LABEL_661
    CASE 662: GOTO vwatch64_LABEL_662
    CASE 663: GOTO vwatch64_LABEL_663
    CASE 664: GOTO vwatch64_LABEL_664
    CASE 665: GOTO vwatch64_LABEL_665
    CASE 666: GOTO vwatch64_LABEL_666
    CASE 667: GOTO vwatch64_LABEL_667
    CASE 668: GOTO vwatch64_LABEL_668
    CASE 669: GOTO vwatch64_LABEL_669
    CASE 670: GOTO vwatch64_LABEL_670
    CASE 671: GOTO vwatch64_LABEL_671
    CASE 672: GOTO vwatch64_LABEL_672
    CASE 673: GOTO vwatch64_LABEL_673
    CASE 674: GOTO vwatch64_LABEL_674
    CASE 675: GOTO vwatch64_LABEL_675
    CASE 676: GOTO vwatch64_LABEL_676
    CASE 677: GOTO vwatch64_LABEL_677
    CASE 678: GOTO vwatch64_LABEL_678
    CASE 679: GOTO vwatch64_LABEL_679
    CASE 680: GOTO vwatch64_LABEL_680
    CASE 681: GOTO vwatch64_LABEL_681
    CASE 682: GOTO vwatch64_LABEL_682
    CASE 683: GOTO vwatch64_LABEL_683
    CASE 684: GOTO vwatch64_LABEL_684
    CASE 685: GOTO vwatch64_LABEL_685
    CASE 686: GOTO vwatch64_LABEL_686
    CASE 687: GOTO vwatch64_LABEL_687
    CASE 688: GOTO vwatch64_LABEL_688
    CASE 689: GOTO vwatch64_LABEL_689
    CASE 690: GOTO vwatch64_LABEL_690
    CASE 691: GOTO vwatch64_LABEL_691
    CASE 692: GOTO vwatch64_LABEL_692
    CASE 693: GOTO vwatch64_LABEL_693
    CASE 694: GOTO vwatch64_LABEL_694
    CASE 695: GOTO vwatch64_LABEL_695
    CASE 696: GOTO vwatch64_LABEL_696
    CASE 697: GOTO vwatch64_LABEL_697
    CASE 698: GOTO vwatch64_LABEL_698
    CASE 699: GOTO vwatch64_LABEL_699
    CASE 700: GOTO vwatch64_LABEL_700
    CASE 701: GOTO vwatch64_LABEL_701
    CASE 702: GOTO vwatch64_LABEL_702
    CASE 703: GOTO vwatch64_LABEL_703
    CASE 704: GOTO vwatch64_LABEL_704
    CASE 705: GOTO vwatch64_LABEL_705
    CASE 706: GOTO vwatch64_LABEL_706
    CASE 707: GOTO vwatch64_LABEL_707
    CASE 708: GOTO vwatch64_LABEL_708
    CASE 709: GOTO vwatch64_LABEL_709
    CASE 710: GOTO vwatch64_LABEL_710
    CASE 711: GOTO vwatch64_LABEL_711
    CASE 712: GOTO vwatch64_LABEL_712
    CASE 713: GOTO vwatch64_LABEL_713
    CASE 714: GOTO vwatch64_LABEL_714
    CASE 715: GOTO vwatch64_LABEL_715
    CASE 716: GOTO vwatch64_LABEL_716
    CASE 717: GOTO vwatch64_LABEL_717
    CASE 718: GOTO vwatch64_LABEL_718
    CASE 719: GOTO vwatch64_LABEL_719
    CASE 720: GOTO vwatch64_LABEL_720
    CASE 721: GOTO vwatch64_LABEL_721
    CASE 722: GOTO vwatch64_LABEL_722
    CASE 723: GOTO vwatch64_LABEL_723
    CASE 724: GOTO vwatch64_LABEL_724
    CASE 725: GOTO vwatch64_LABEL_725
    CASE 726: GOTO vwatch64_LABEL_726
    CASE 727: GOTO vwatch64_LABEL_727
    CASE 728: GOTO vwatch64_LABEL_728
    CASE 729: GOTO vwatch64_LABEL_729
    CASE 745: GOTO vwatch64_LABEL_745
    CASE 756: GOTO vwatch64_LABEL_756
    CASE 758: GOTO vwatch64_LABEL_758
    CASE 759: GOTO vwatch64_LABEL_759
    CASE 760: GOTO vwatch64_LABEL_760
    CASE 761: GOTO vwatch64_LABEL_761
    CASE 762: GOTO vwatch64_LABEL_762
    CASE 765: GOTO vwatch64_LABEL_765
    CASE 766: GOTO vwatch64_LABEL_766
    CASE 769: GOTO vwatch64_LABEL_769
    CASE 770: GOTO vwatch64_LABEL_770
    CASE 772: GOTO vwatch64_LABEL_772
    CASE 773: GOTO vwatch64_LABEL_773
    CASE 774: GOTO vwatch64_LABEL_774
    CASE 775: GOTO vwatch64_LABEL_775
    CASE 776: GOTO vwatch64_LABEL_776
    CASE 777: GOTO vwatch64_LABEL_777
    CASE 778: GOTO vwatch64_LABEL_778
    CASE 779: GOTO vwatch64_LABEL_779
    CASE 780: GOTO vwatch64_LABEL_780
    CASE 782: GOTO vwatch64_LABEL_782
    CASE 783: GOTO vwatch64_LABEL_783
    CASE 784: GOTO vwatch64_LABEL_784
    CASE 785: GOTO vwatch64_LABEL_785
    CASE 787: GOTO vwatch64_LABEL_787
    CASE 788: GOTO vwatch64_LABEL_788
    CASE 789: GOTO vwatch64_LABEL_789
    CASE 790: GOTO vwatch64_LABEL_790
    CASE 791: GOTO vwatch64_LABEL_791
    CASE 792: GOTO vwatch64_LABEL_792
    CASE 793: GOTO vwatch64_LABEL_793
    CASE 794: GOTO vwatch64_LABEL_794
    CASE 795: GOTO vwatch64_LABEL_795
    CASE 797: GOTO vwatch64_LABEL_797
    CASE 800: GOTO vwatch64_LABEL_800
    CASE 801: GOTO vwatch64_LABEL_801
    CASE 803: GOTO vwatch64_LABEL_803
    CASE 804: GOTO vwatch64_LABEL_804
    CASE 805: GOTO vwatch64_LABEL_805
    CASE 806: GOTO vwatch64_LABEL_806
    CASE 807: GOTO vwatch64_LABEL_807
    CASE 808: GOTO vwatch64_LABEL_808
END SELECT

vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
ON ERROR GOTO 0
RETURN

sub fatalerror (msg$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_811:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(811): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_811 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_811
    print "Error: " + msg$
vwatch64_SKIP_811:::: 
vwatch64_LABEL_812:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(812): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_812 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_812
    system 1
vwatch64_SKIP_812:::: 
vwatch64_LABEL_813:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(813): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_813
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 811: GOTO vwatch64_LABEL_811
    CASE 812: GOTO vwatch64_LABEL_812
    CASE 813: GOTO vwatch64_LABEL_813
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub debuginfo (msg$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_816:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(816): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_816 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_816
    if options.debug then print msg$
vwatch64_SKIP_816:::: 
vwatch64_LABEL_817:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(817): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_817
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 816: GOTO vwatch64_LABEL_816
    CASE 817: GOTO vwatch64_LABEL_817
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

'Strip the .bas extension if present
function remove_ext$(fullname$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_821:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(821): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_821 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_821
    dot = _instrrev(fullname$, ".")
vwatch64_SKIP_821:::: 
vwatch64_LABEL_822:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(822): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_822 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_822
    if mid$(fullname$, dot + 1) = "bas" then
vwatch64_SKIP_822:::: 
vwatch64_LABEL_823:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(823): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_823 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_823
        remove_ext$ = left$(fullname$, dot - 1)
vwatch64_SKIP_823:::: 
vwatch64_LABEL_824:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(824): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_824 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_824
    else
vwatch64_SKIP_824:::: 
vwatch64_LABEL_825:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(825): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_825 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_825
        remove_ext$ = fullname$
vwatch64_SKIP_825:::: 
vwatch64_LABEL_826:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(826): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_826 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_826
    end if
vwatch64_SKIP_826:::: 
vwatch64_LABEL_827:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(827): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_827
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 821: GOTO vwatch64_LABEL_821
    CASE 822: GOTO vwatch64_LABEL_822
    CASE 823: GOTO vwatch64_LABEL_823
    CASE 824: GOTO vwatch64_LABEL_824
    CASE 825: GOTO vwatch64_LABEL_825
    CASE 826: GOTO vwatch64_LABEL_826
    CASE 827: GOTO vwatch64_LABEL_827
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

sub show_version
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_830:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(830): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_830 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_830
    print "The '65 compiler (" + VERSION$ + ")"
vwatch64_SKIP_830:::: 
vwatch64_LABEL_831:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(831): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_831 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_831
    print "This version is still under heavy development!"
vwatch64_SKIP_831:::: 
vwatch64_LABEL_832:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(832): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_832
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 830: GOTO vwatch64_LABEL_830
    CASE 831: GOTO vwatch64_LABEL_831
    CASE 832: GOTO vwatch64_LABEL_832
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub show_help
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_835:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(835): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_835 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_835
    print "The '65 compiler (" + VERSION$ + ")"
vwatch64_SKIP_835:::: 
vwatch64_LABEL_836:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(836): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_836 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_836
    print "Usage: " + command$(0) + " <options> <inputfile>"
vwatch64_SKIP_836:::: 
vwatch64_LABEL_837:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(837): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_837 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_837
    print '                                                                                '80 columns
vwatch64_SKIP_837:::: 
vwatch64_LABEL_838:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(838): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_838 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_838
    print "Basic options:"
vwatch64_SKIP_838:::: 
vwatch64_LABEL_839:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(839): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_839 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_839
    print "  -h, --help                       Print this help message"
vwatch64_SKIP_839:::: 
vwatch64_LABEL_840:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(840): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_840 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_840
    print "  --version                        Print version information"
vwatch64_SKIP_840:::: 
vwatch64_LABEL_841:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(841): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_841 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_841
    print "  -o <file>, --output <file>       Place the output into <file>"
vwatch64_SKIP_841:::: 
vwatch64_LABEL_842:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(842): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_842 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_842
    print "  -i, --immediate                  Generate no output file, run the program now."
vwatch64_SKIP_842:::: 
vwatch64_LABEL_843:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(843): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_843 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_843
    print "  -v, --verbose                    Be descriptive about what is happening"
vwatch64_SKIP_843:::: 
vwatch64_LABEL_844:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(844): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_844 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_844
    print "  -d, --debug                      For debugging 65 itself"
vwatch64_SKIP_844:::: 
vwatch64_LABEL_845:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(845): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_845
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 835: GOTO vwatch64_LABEL_835
    CASE 836: GOTO vwatch64_LABEL_836
    CASE 837: GOTO vwatch64_LABEL_837
    CASE 838: GOTO vwatch64_LABEL_838
    CASE 839: GOTO vwatch64_LABEL_839
    CASE 840: GOTO vwatch64_LABEL_840
    CASE 841: GOTO vwatch64_LABEL_841
    CASE 842: GOTO vwatch64_LABEL_842
    CASE 843: GOTO vwatch64_LABEL_843
    CASE 844: GOTO vwatch64_LABEL_844
    CASE 845: GOTO vwatch64_LABEL_845
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub parse_cmd_line_args()
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_848:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(848): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_848 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_848
    for i = 1 TO _commandcount
vwatch64_SKIP_848:::: 
vwatch64_LABEL_849:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(849): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_849 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_849
        arg$ = command$(i)
vwatch64_SKIP_849:::: 
vwatch64_LABEL_850:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(850): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_850 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_850
        select case arg$
vwatch64_SKIP_850:::: 
            case "--version"
vwatch64_LABEL_852:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(852): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_852 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_852
                show_version
vwatch64_SKIP_852:::: 
vwatch64_LABEL_853:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(853): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_853 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_853
ON ERROR GOTO vwatch64_FILEERROR
IF vwatch64_HEADER.CONNECTED THEN
    vwatch64_HEADER.CONNECTED = 0
    PUT #vwatch64_CLIENTFILE, 1, vwatch64_HEADER
END IF
CLOSE #vwatch64_CLIENTFILE
KILL "/home/luke/comp/git_qb64/vwatch64.dat"
ON ERROR GOTO 0
                system
vwatch64_SKIP_853:::: 
            case "-h", "--help"
vwatch64_LABEL_855:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(855): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_855 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_855
                show_help
vwatch64_SKIP_855:::: 
vwatch64_LABEL_856:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(856): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_856 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_856
ON ERROR GOTO vwatch64_FILEERROR
IF vwatch64_HEADER.CONNECTED THEN
    vwatch64_HEADER.CONNECTED = 0
    PUT #vwatch64_CLIENTFILE, 1, vwatch64_HEADER
END IF
CLOSE #vwatch64_CLIENTFILE
KILL "/home/luke/comp/git_qb64/vwatch64.dat"
ON ERROR GOTO 0
                system
vwatch64_SKIP_856:::: 
            case "-o", "--output"
vwatch64_LABEL_858:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(858): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_858 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_858
                if i = _commandcount then fatalerror arg$ + " requires argument"
vwatch64_SKIP_858:::: 
vwatch64_LABEL_859:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(859): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_859 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_859
                options.outputfile = command$(i + 1)
vwatch64_SKIP_859:::: 
vwatch64_LABEL_860:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(860): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_860 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_860
                i = i + 1
vwatch64_SKIP_860:::: 
            case "-v", "--verbose"
vwatch64_LABEL_862:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(862): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_862 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_862
                options.verbose = TRUE
vwatch64_SKIP_862:::: 
            case "-d", "--debug"
vwatch64_LABEL_864:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(864): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_864 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_864
                options.debug = TRUE
vwatch64_SKIP_864:::: 
            case "-i", "--immediate"
vwatch64_LABEL_866:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(866): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_866 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_866
                options.immediate_mode = TRUE
vwatch64_SKIP_866:::: 
            case else
vwatch64_LABEL_868:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(868): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_868 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_868
                if left$(arg$, 1) = "-" then fatalerror "Unknown option " + arg$
vwatch64_SKIP_868:::: 
vwatch64_LABEL_869:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(869): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_869 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_869
                if options.inputfile <> "" then fatalerror "Unexpected argument " + arg$
vwatch64_SKIP_869:::: 
vwatch64_LABEL_870:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(870): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_870 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_870
                options.inputfile = arg$
vwatch64_SKIP_870:::: 
        end select
vwatch64_LABEL_872:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(872): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_872 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_872
    next i
vwatch64_SKIP_872:::: 
vwatch64_LABEL_873:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(873): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_873
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 848: GOTO vwatch64_LABEL_848
    CASE 849: GOTO vwatch64_LABEL_849
    CASE 850: GOTO vwatch64_LABEL_850
    CASE 852: GOTO vwatch64_LABEL_852
    CASE 853: GOTO vwatch64_LABEL_853
    CASE 855: GOTO vwatch64_LABEL_855
    CASE 856: GOTO vwatch64_LABEL_856
    CASE 858: GOTO vwatch64_LABEL_858
    CASE 859: GOTO vwatch64_LABEL_859
    CASE 860: GOTO vwatch64_LABEL_860
    CASE 862: GOTO vwatch64_LABEL_862
    CASE 864: GOTO vwatch64_LABEL_864
    CASE 866: GOTO vwatch64_LABEL_866
    CASE 868: GOTO vwatch64_LABEL_868
    CASE 869: GOTO vwatch64_LABEL_869
    CASE 870: GOTO vwatch64_LABEL_870
    CASE 872: GOTO vwatch64_LABEL_872
    CASE 873: GOTO vwatch64_LABEL_873
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

'*INCLUDE file merged: 'type.bm'
function type_is_number(typ)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_877:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(877): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_877 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_877
    select case typ
vwatch64_SKIP_877:::: 
    case TYPE_INTEGER, TYPE_LONG, TYPE_INTEGER64, TYPE_SINGLE, TYPE_DOUBLE, TYPE_QUAD
vwatch64_LABEL_879:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(879): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_879 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_879
        type_is_number = TRUE
vwatch64_SKIP_879:::: 
    end select
vwatch64_LABEL_881:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(881): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_881
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 877: GOTO vwatch64_LABEL_877
    CASE 879: GOTO vwatch64_LABEL_879
    CASE 881: GOTO vwatch64_LABEL_881
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_of_expr(root)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_884:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(884): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_884 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_884
    select case ast_nodes(root).typ
vwatch64_SKIP_884:::: 
    case AST_CONSTANT
vwatch64_LABEL_886:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(886): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_886 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_886
        type_of_expr = type_of_constant(root)
vwatch64_SKIP_886:::: 
    case AST_CALL
vwatch64_LABEL_888:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(888): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_888 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_888
        type_of_expr = type_of_call(root)
vwatch64_SKIP_888:::: 
    case AST_VAR
vwatch64_LABEL_890:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(890): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_890 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_890
        type_of_expr = type_of_var(root)
vwatch64_SKIP_890:::: 
    case AST_CAST
vwatch64_LABEL_892:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(892): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_892 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_892
        type_of_expr = type_of_cast(root)
vwatch64_SKIP_892:::: 
    case else
vwatch64_LABEL_894:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(894): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_894 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_894
        fatalerror "Cannot determine type of expression " + str$(root)
vwatch64_SKIP_894:::: 
    end select
vwatch64_LABEL_896:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(896): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_896
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 884: GOTO vwatch64_LABEL_884
    CASE 886: GOTO vwatch64_LABEL_886
    CASE 888: GOTO vwatch64_LABEL_888
    CASE 890: GOTO vwatch64_LABEL_890
    CASE 892: GOTO vwatch64_LABEL_892
    CASE 894: GOTO vwatch64_LABEL_894
    CASE 896: GOTO vwatch64_LABEL_896
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_of_constant(node)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_899:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(899): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_899 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_899
    type_of_constant = ast_constant_types(ast_nodes(node).ref)
vwatch64_SKIP_899:::: 
vwatch64_LABEL_900:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(900): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_900
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 899: GOTO vwatch64_LABEL_899
    CASE 900: GOTO vwatch64_LABEL_900
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_of_call(node)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_903:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(903): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_903 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_903
    type_of_call = type_sig_return(ast_nodes(node).ref2)
vwatch64_SKIP_903:::: 
vwatch64_LABEL_904:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(904): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_904
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 903: GOTO vwatch64_LABEL_903
    CASE 904: GOTO vwatch64_LABEL_904
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_of_var(node)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_907:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(907): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_907 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_907
    type_of_var = htable_entries(ast_nodes(node).ref).v1
vwatch64_SKIP_907:::: 
vwatch64_LABEL_908:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(908): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_908
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 907: GOTO vwatch64_LABEL_907
    CASE 908: GOTO vwatch64_LABEL_908
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_of_cast(node)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_911:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(911): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_911 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_911
    type_of_cast = ast_nodes(node).ref
vwatch64_SKIP_911:::: 
vwatch64_LABEL_912:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(912): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_912
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 911: GOTO vwatch64_LABEL_911
    CASE 912: GOTO vwatch64_LABEL_912
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function
    
function type_can_cast(a, b)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_915:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(915): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_915 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_915
    type_can_cast = (type_is_number(a) and type_is_number(b)) or a = b
vwatch64_SKIP_915:::: 
vwatch64_LABEL_916:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(916): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_916
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 915: GOTO vwatch64_LABEL_915
    CASE 916: GOTO vwatch64_LABEL_916
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_can_safely_cast(a, b)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_919:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(919): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_919 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_919
    if a = b then
vwatch64_SKIP_919:::: 
vwatch64_LABEL_920:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(920): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_920 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_920
        type_can_safely_cast = TRUE
vwatch64_SKIP_920:::: 
vwatch64_LABEL_921:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(921): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_921 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_921
        vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: exit function
vwatch64_SKIP_921:::: 
vwatch64_LABEL_922:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(922): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_922 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_922
    end if
vwatch64_SKIP_922:::: 
vwatch64_LABEL_923:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(923): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_923 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_923
    if not type_can_cast(a, b) then vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: exit function
vwatch64_SKIP_923:::: 
vwatch64_LABEL_924:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(924): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_924 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_924
    select case a
vwatch64_SKIP_924:::: 
    case TYPE_INTEGER
vwatch64_LABEL_926:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(926): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_926 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_926
        type_can_safely_cast = TRUE
vwatch64_SKIP_926:::: 
    case TYPE_LONG
vwatch64_LABEL_928:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(928): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_928 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_928
        type_can_safely_cast = (b = TYPE_INTEGER64) or (b = TYPE_DOUBLE) or (b = TYPE_QUAD)
vwatch64_SKIP_928:::: 
    case TYPE_INTEGER64
vwatch64_LABEL_930:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(930): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_930 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_930
        type_can_safely_cast = b = TYPE_QUAD
vwatch64_SKIP_930:::: 
    case TYPE_SINGLE
vwatch64_LABEL_932:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(932): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_932 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_932
        type_can_safely_cast = (b = TYPE_DOUBLE) or (b = TYPE_QUAD)
vwatch64_SKIP_932:::: 
    case TYPE_DOUBLE
vwatch64_LABEL_934:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(934): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_934 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_934
        type_can_safely_cast = b = TYPE_QUAD
vwatch64_SKIP_934:::: 
    case TYPE_FLOAT
vwatch64_LABEL_936:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(936): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_936 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_936
        type_can_safely_cast = FALSE
vwatch64_SKIP_936:::: 
    end select
vwatch64_LABEL_938:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(938): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_938
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 919: GOTO vwatch64_LABEL_919
    CASE 920: GOTO vwatch64_LABEL_920
    CASE 921: GOTO vwatch64_LABEL_921
    CASE 922: GOTO vwatch64_LABEL_922
    CASE 923: GOTO vwatch64_LABEL_923
    CASE 924: GOTO vwatch64_LABEL_924
    CASE 926: GOTO vwatch64_LABEL_926
    CASE 928: GOTO vwatch64_LABEL_928
    CASE 930: GOTO vwatch64_LABEL_930
    CASE 932: GOTO vwatch64_LABEL_932
    CASE 934: GOTO vwatch64_LABEL_934
    CASE 936: GOTO vwatch64_LABEL_936
    CASE 938: GOTO vwatch64_LABEL_938
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_sig_return(sig_index)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_941:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(941): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_941 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_941
    type_sig_return = cvl(left$(type_signatures(sig_index).sig, 4))
vwatch64_SKIP_941:::: 
vwatch64_LABEL_942:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(942): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_942
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 941: GOTO vwatch64_LABEL_941
    CASE 942: GOTO vwatch64_LABEL_942
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_sig_numargs(sig_index)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_945:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(945): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_945 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_945
    type_sig_numargs = (len(type_signatures(sig_index).sig) - 4) / 8
vwatch64_SKIP_945:::: 
vwatch64_LABEL_946:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(946): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_946
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 945: GOTO vwatch64_LABEL_945
    CASE 946: GOTO vwatch64_LABEL_946
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_sig_argtype(sig_index, arg_index)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_949:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(949): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_949 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_949
    type_sig_argtype = cvl(mid$(type_signatures(sig_index).sig, arg_index * 8 - 3, 4))
vwatch64_SKIP_949:::: 
vwatch64_LABEL_950:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(950): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_950
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 949: GOTO vwatch64_LABEL_949
    CASE 950: GOTO vwatch64_LABEL_950
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_sig_argflags(sig_index, arg_index)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_953:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(953): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_953 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_953
    type_sig_argflags = cvl(mid$(type_signatures(sig_index).sig, arg_index * 8 + 1, 4))
vwatch64_SKIP_953:::: 
vwatch64_LABEL_954:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(954): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_954
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 953: GOTO vwatch64_LABEL_953
    CASE 954: GOTO vwatch64_LABEL_954
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_add_sig(previous, sig$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_957:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(957): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_957 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_957
    type_last_signature = type_last_signature + 1
vwatch64_SKIP_957:::: 
vwatch64_LABEL_958:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(958): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_958 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_958
    if ubound(type_signatures) = type_last_signature then
vwatch64_SKIP_958:::: 
        redim _preserve type_signatures(type_last_signature * 2) as type_signature_t
vwatch64_LABEL_960:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(960): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_960 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_960
    end if
vwatch64_SKIP_960:::: 
vwatch64_LABEL_961:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(961): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_961 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_961
    type_signatures(type_last_signature).sig = sig$
vwatch64_SKIP_961:::: 
vwatch64_LABEL_962:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(962): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_962 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_962
    if previous then type_signatures(previous).succ = type_last_signature
vwatch64_SKIP_962:::: 
vwatch64_LABEL_963:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(963): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_963 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_963
    type_add_sig = type_last_signature
vwatch64_SKIP_963:::: 
vwatch64_LABEL_964:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(964): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_964
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 957: GOTO vwatch64_LABEL_957
    CASE 958: GOTO vwatch64_LABEL_958
    CASE 960: GOTO vwatch64_LABEL_960
    CASE 961: GOTO vwatch64_LABEL_961
    CASE 962: GOTO vwatch64_LABEL_962
    CASE 963: GOTO vwatch64_LABEL_963
    CASE 964: GOTO vwatch64_LABEL_964
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

sub type_add_sig_arg(sig_index, typ, flags)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_967:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(967): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_967 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_967
    type_signatures(sig_index).sig = type_sig_add_arg$(type_signatures(sig_index).sig, typ, flags)
vwatch64_SKIP_967:::: 
vwatch64_LABEL_968:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(968): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_968
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 967: GOTO vwatch64_LABEL_967
    CASE 968: GOTO vwatch64_LABEL_968
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub
    
function type_sig_create$(return_type)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_971:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(971): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_971 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_971
    type_sig_create$ = mkl$(return_type)
vwatch64_SKIP_971:::: 
vwatch64_LABEL_972:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(972): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_972
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 971: GOTO vwatch64_LABEL_971
    CASE 972: GOTO vwatch64_LABEL_972
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_sig_add_arg$(old$, new_argtype, new_argflags)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_975:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(975): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_975 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_975
    type_sig_add_arg$ = old$ + mkl$(new_argtype) + mkl$(new_argflags)
vwatch64_SKIP_975:::: 
vwatch64_LABEL_976:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(976): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_976
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 975: GOTO vwatch64_LABEL_975
    CASE 976: GOTO vwatch64_LABEL_976
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_find_sig_match(func, candidate$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_979:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(979): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_979 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_979
    debuginfo "Function resolution candidate is " + type_human_sig$(mkl$(0) + candidate$)
vwatch64_SKIP_979:::: 
vwatch64_LABEL_980:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(980): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_980 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_980
    sig_index = htable_entries(func).v1
vwatch64_SKIP_980:::: 
vwatch64_LABEL_981:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(981): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_981 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_981
    while sig_index <> 0
vwatch64_SKIP_981:::: 
vwatch64_LABEL_982:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(982): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_982 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_982
        if type_sig_is_compatible(sig_index, candidate$, 0) then
vwatch64_SKIP_982:::: 
vwatch64_LABEL_983:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(983): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_983 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_983
            compatibles$ = compatibles$ + mkl$(sig_index)
vwatch64_SKIP_983:::: 
vwatch64_LABEL_984:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(984): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_984 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_984
        end if
vwatch64_SKIP_984:::: 
vwatch64_LABEL_985:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(985): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_985 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_985
        sig_index = type_signatures(sig_index).succ
vwatch64_SKIP_985:::: 
vwatch64_LABEL_986:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(986): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_986 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_986
    wend
vwatch64_SKIP_986:::: 
vwatch64_LABEL_987:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(987): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_987 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_987
    if len(compatibles$) = 0 then
vwatch64_SKIP_987:::: 
vwatch64_LABEL_988:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(988): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_988 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_988
        vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: exit function
vwatch64_SKIP_988:::: 
vwatch64_LABEL_989:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(989): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_989 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_989
    elseif len(compatibles$) = 4 then
vwatch64_SKIP_989:::: 
vwatch64_LABEL_990:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(990): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_990 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_990
        type_find_sig_match = cvl(compatibles$)
vwatch64_SKIP_990:::: 
vwatch64_LABEL_991:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(991): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_991 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_991
    else
vwatch64_SKIP_991:::: 
vwatch64_LABEL_992:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(992): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_992 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_992
        type_find_sig_match = type_pick_best_compatible_sig(compatibles$, candidate$)
vwatch64_SKIP_992:::: 
vwatch64_LABEL_993:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(993): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_993 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_993
    end if
vwatch64_SKIP_993:::: 
vwatch64_LABEL_994:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(994): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_994
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 979: GOTO vwatch64_LABEL_979
    CASE 980: GOTO vwatch64_LABEL_980
    CASE 981: GOTO vwatch64_LABEL_981
    CASE 982: GOTO vwatch64_LABEL_982
    CASE 983: GOTO vwatch64_LABEL_983
    CASE 984: GOTO vwatch64_LABEL_984
    CASE 985: GOTO vwatch64_LABEL_985
    CASE 986: GOTO vwatch64_LABEL_986
    CASE 987: GOTO vwatch64_LABEL_987
    CASE 988: GOTO vwatch64_LABEL_988
    CASE 989: GOTO vwatch64_LABEL_989
    CASE 990: GOTO vwatch64_LABEL_990
    CASE 991: GOTO vwatch64_LABEL_991
    CASE 992: GOTO vwatch64_LABEL_992
    CASE 993: GOTO vwatch64_LABEL_993
    CASE 994: GOTO vwatch64_LABEL_994
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_pick_best_compatible_sig(compatibles$, candidate$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    'Picks the first sig that has lossless casts, otherwise the last sig if
    'no lossless casts are available.
vwatch64_LABEL_999:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(999): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_999 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_999
    debuginfo "Looking for a safe cast option"
vwatch64_SKIP_999:::: 
vwatch64_LABEL_1000:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1000): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1000 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1000
    for i = 1 to len(compatibles$) / 4
vwatch64_SKIP_1000:::: 
vwatch64_LABEL_1001:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1001): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1001 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1001
        sig_index = cvl(mid$(compatibles$, i * 4 - 3, 4))
vwatch64_SKIP_1001:::: 
vwatch64_LABEL_1002:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1002): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1002 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1002
        if type_sig_is_compatible(sig_index, candidate$, 1) then
vwatch64_SKIP_1002:::: 
vwatch64_LABEL_1003:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1003): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1003 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1003
            type_pick_best_compatible_sig = sig_index
vwatch64_SKIP_1003:::: 
vwatch64_LABEL_1004:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1004): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1004 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1004
            debuginfo "Safe signature found."
vwatch64_SKIP_1004:::: 
vwatch64_LABEL_1005:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1005): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1005 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1005
            vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: exit function
vwatch64_SKIP_1005:::: 
vwatch64_LABEL_1006:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1006): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1006 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1006
        end if
vwatch64_SKIP_1006:::: 
vwatch64_LABEL_1007:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1007): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1007 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1007
    next i
vwatch64_SKIP_1007:::: 
vwatch64_LABEL_1008:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1008): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1008 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1008
    debuginfo "No safe signature found."
vwatch64_SKIP_1008:::: 
vwatch64_LABEL_1009:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1009): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1009 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1009
    type_pick_best_compatible_sig = cvl(right$(compatibles$, 4))
vwatch64_SKIP_1009:::: 
vwatch64_LABEL_1010:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1010): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1010
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 999: GOTO vwatch64_LABEL_999
    CASE 1000: GOTO vwatch64_LABEL_1000
    CASE 1001: GOTO vwatch64_LABEL_1001
    CASE 1002: GOTO vwatch64_LABEL_1002
    CASE 1003: GOTO vwatch64_LABEL_1003
    CASE 1004: GOTO vwatch64_LABEL_1004
    CASE 1005: GOTO vwatch64_LABEL_1005
    CASE 1006: GOTO vwatch64_LABEL_1006
    CASE 1007: GOTO vwatch64_LABEL_1007
    CASE 1008: GOTO vwatch64_LABEL_1008
    CASE 1009: GOTO vwatch64_LABEL_1009
    CASE 1010: GOTO vwatch64_LABEL_1010
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_sig_is_compatible(sig_index, candidate$, checkmode)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1013:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1013): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1013 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1013
    debuginfo "Comparing to " + type_human_sig$(type_signatures(sig_index).sig) + "..."
vwatch64_SKIP_1013:::: 
vwatch64_LABEL_1014:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1014): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1014 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1014
    s = 1
vwatch64_SKIP_1014:::: 
vwatch64_LABEL_1015:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1015): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1015 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1015
    c = 1
vwatch64_SKIP_1015:::: 
vwatch64_LABEL_1016:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1016): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1016 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1016
    do until c * 8 > len(candidate$)
vwatch64_SKIP_1016:::: 
vwatch64_LABEL_1017:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1017): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1017 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1017
        sig_arg = type_sig_argtype(sig_index, s)
vwatch64_SKIP_1017:::: 
vwatch64_LABEL_1018:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1018): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1018 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1018
        sig_flags = type_sig_argflags(sig_index, s)
vwatch64_SKIP_1018:::: 
vwatch64_LABEL_1019:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1019): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1019 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1019
        c_arg = cvl(mid$(candidate$, 8 * c - 7, 4))
vwatch64_SKIP_1019:::: 
vwatch64_LABEL_1020:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1020): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1020 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1020
        c_flags = cvl(mid$(candidate$, 8 * c - 3, 4))
vwatch64_SKIP_1020:::: 
vwatch64_LABEL_1021:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1021): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1021 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1021
        if not type_sig_compatible_arg(sig_arg, sig_flags, c_arg, c_flags, checkmode) then
vwatch64_SKIP_1021:::: 
vwatch64_LABEL_1022:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1022): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1022 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1022
            debuginfo "No, mismatch on arg" + str$(c) + " (candidate has " + type_human_readable$(c_arg) + ")"
vwatch64_SKIP_1022:::: 
vwatch64_LABEL_1023:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1023): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1023 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1023
            vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: exit function
vwatch64_SKIP_1023:::: 
vwatch64_LABEL_1024:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1024): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1024 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1024
        end if
vwatch64_SKIP_1024:::: 
vwatch64_LABEL_1025:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1025): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1025 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1025
        s = s + 1
vwatch64_SKIP_1025:::: 
vwatch64_LABEL_1026:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1026): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1026 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1026
        c = c + 1
vwatch64_SKIP_1026:::: 
vwatch64_LABEL_1027:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1027): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1027 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1027
    loop
vwatch64_SKIP_1027:::: 
vwatch64_LABEL_1028:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1028): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1028 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1028
    type_sig_is_compatible = TRUE
vwatch64_SKIP_1028:::: 
vwatch64_LABEL_1029:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1029): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1029 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1029
    debuginfo "Compatible"
vwatch64_SKIP_1029:::: 
vwatch64_LABEL_1030:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1030): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1030
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1013: GOTO vwatch64_LABEL_1013
    CASE 1014: GOTO vwatch64_LABEL_1014
    CASE 1015: GOTO vwatch64_LABEL_1015
    CASE 1016: GOTO vwatch64_LABEL_1016
    CASE 1017: GOTO vwatch64_LABEL_1017
    CASE 1018: GOTO vwatch64_LABEL_1018
    CASE 1019: GOTO vwatch64_LABEL_1019
    CASE 1020: GOTO vwatch64_LABEL_1020
    CASE 1021: GOTO vwatch64_LABEL_1021
    CASE 1022: GOTO vwatch64_LABEL_1022
    CASE 1023: GOTO vwatch64_LABEL_1023
    CASE 1024: GOTO vwatch64_LABEL_1024
    CASE 1025: GOTO vwatch64_LABEL_1025
    CASE 1026: GOTO vwatch64_LABEL_1026
    CASE 1027: GOTO vwatch64_LABEL_1027
    CASE 1028: GOTO vwatch64_LABEL_1028
    CASE 1029: GOTO vwatch64_LABEL_1029
    CASE 1030: GOTO vwatch64_LABEL_1030
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_sig_compatible_arg(sig_arg, sig_flags, c_arg, c_flags, checkmode)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
'checkmode = 0 for lossy casts, 1 for lossless casts only
vwatch64_LABEL_1034:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1034): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1034 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1034
    if sig_flags and TYPE_BYREF then
vwatch64_SKIP_1034:::: 
vwatch64_LABEL_1035:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1035): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1035 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1035
        result = (c_flags and TYPE_BYREF) > 0 and sig_arg = c_arg
vwatch64_SKIP_1035:::: 
vwatch64_LABEL_1036:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1036): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1036 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1036
    elseif checkmode = 0 then
vwatch64_SKIP_1036:::: 
vwatch64_LABEL_1037:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1037): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1037 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1037
        result = type_can_cast(c_arg, sig_arg)
vwatch64_SKIP_1037:::: 
vwatch64_LABEL_1038:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1038): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1038 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1038
    elseif checkmode = 1 then
vwatch64_SKIP_1038:::: 
vwatch64_LABEL_1039:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1039): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1039 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1039
        result = type_can_safely_cast(c_arg, sig_arg)
vwatch64_SKIP_1039:::: 
vwatch64_LABEL_1040:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1040): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1040 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1040
    end if
vwatch64_SKIP_1040:::: 
vwatch64_LABEL_1041:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1041): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1041 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1041
    type_sig_compatible_arg = result
vwatch64_SKIP_1041:::: 
vwatch64_LABEL_1042:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1042): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1042
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1034: GOTO vwatch64_LABEL_1034
    CASE 1035: GOTO vwatch64_LABEL_1035
    CASE 1036: GOTO vwatch64_LABEL_1036
    CASE 1037: GOTO vwatch64_LABEL_1037
    CASE 1038: GOTO vwatch64_LABEL_1038
    CASE 1039: GOTO vwatch64_LABEL_1039
    CASE 1040: GOTO vwatch64_LABEL_1040
    CASE 1041: GOTO vwatch64_LABEL_1041
    CASE 1042: GOTO vwatch64_LABEL_1042
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_sfx2type(sfx_token)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1045:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1045): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1045 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1045
    select case sfx_token
vwatch64_SKIP_1045:::: 
    case TOK_INTEGER_SFX
vwatch64_LABEL_1047:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1047): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1047 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1047
        type_sfx2type = TYPE_INTEGER
vwatch64_SKIP_1047:::: 
    case TOK_LONG_SFX
vwatch64_LABEL_1049:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1049): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1049 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1049
        type_sfx2type = TYPE_LONG
vwatch64_SKIP_1049:::: 
    case TOK_INTEGER64_SFX
vwatch64_LABEL_1051:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1051): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1051 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1051
        type_sfx2type = TYPE_INTEGER64
vwatch64_SKIP_1051:::: 
    case TOK_SINGLE_SFX
vwatch64_LABEL_1053:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1053): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1053 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1053
        type_sfx2type = TYPE_SINGLE
vwatch64_SKIP_1053:::: 
    case TOK_DOUBLE_SFX
vwatch64_LABEL_1055:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1055): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1055 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1055
        type_sfx2type = TYPE_DOUBLE
vwatch64_SKIP_1055:::: 
    case TOK_QUAD_SFX
vwatch64_LABEL_1057:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1057): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1057 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1057
        type_sfx2type = TYPE_QUAD
vwatch64_SKIP_1057:::: 
    case TOK_OFFSET_SFX
vwatch64_LABEL_1059:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1059): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1059 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1059
        type_sfx2type = TYPE_OFFSET
vwatch64_SKIP_1059:::: 
    case TOK_STRING_SFX
vwatch64_LABEL_1061:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1061): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1061 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1061
        type_sfx2type = TYPE_STRING
vwatch64_SKIP_1061:::: 
    case else
vwatch64_LABEL_1063:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1063): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1063 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1063
        type_sfx2type = 0
vwatch64_SKIP_1063:::: 
    end select
vwatch64_LABEL_1065:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1065): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1065
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1045: GOTO vwatch64_LABEL_1045
    CASE 1047: GOTO vwatch64_LABEL_1047
    CASE 1049: GOTO vwatch64_LABEL_1049
    CASE 1051: GOTO vwatch64_LABEL_1051
    CASE 1053: GOTO vwatch64_LABEL_1053
    CASE 1055: GOTO vwatch64_LABEL_1055
    CASE 1057: GOTO vwatch64_LABEL_1057
    CASE 1059: GOTO vwatch64_LABEL_1059
    CASE 1061: GOTO vwatch64_LABEL_1061
    CASE 1063: GOTO vwatch64_LABEL_1063
    CASE 1065: GOTO vwatch64_LABEL_1065
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_human_readable$(typ)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1068:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1068): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1068 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1068
    select case typ
vwatch64_SKIP_1068:::: 
    case TYPE_NONE
vwatch64_LABEL_1070:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1070): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1070 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1070
        type_human_readable$ = "NONE"
vwatch64_SKIP_1070:::: 
    case TYPE_INTEGER
vwatch64_LABEL_1072:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1072): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1072 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1072
        type_human_readable$ = "INTEGER"
vwatch64_SKIP_1072:::: 
    case TYPE_LONG
vwatch64_LABEL_1074:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1074): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1074 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1074
        type_human_readable$ = "LONG"
vwatch64_SKIP_1074:::: 
    case TYPE_INTEGER64
vwatch64_LABEL_1076:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1076): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1076 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1076
        type_human_readable$ = "INTEGER64"
vwatch64_SKIP_1076:::: 
    case TYPE_SINGLE
vwatch64_LABEL_1078:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1078): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1078 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1078
        type_human_readable$ = "SINGLE"
vwatch64_SKIP_1078:::: 
    case TYPE_DOUBLE
vwatch64_LABEL_1080:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1080): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1080 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1080
        type_human_readable$ = "DOUBLE"
vwatch64_SKIP_1080:::: 
    case TYPE_QUAD
vwatch64_LABEL_1082:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1082): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1082 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1082
        type_human_readable$ = "QUAD"
vwatch64_SKIP_1082:::: 
    case TYPE_STRING
vwatch64_LABEL_1084:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1084): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1084 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1084
        type_human_readable$ = "STRING"
vwatch64_SKIP_1084:::: 
    case else
vwatch64_LABEL_1086:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1086): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1086 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1086
        type_human_readable$ = "UNKNOWN"
vwatch64_SKIP_1086:::: 
    end select
vwatch64_LABEL_1088:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1088): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1088
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1068: GOTO vwatch64_LABEL_1068
    CASE 1070: GOTO vwatch64_LABEL_1070
    CASE 1072: GOTO vwatch64_LABEL_1072
    CASE 1074: GOTO vwatch64_LABEL_1074
    CASE 1076: GOTO vwatch64_LABEL_1076
    CASE 1078: GOTO vwatch64_LABEL_1078
    CASE 1080: GOTO vwatch64_LABEL_1080
    CASE 1082: GOTO vwatch64_LABEL_1082
    CASE 1084: GOTO vwatch64_LABEL_1084
    CASE 1086: GOTO vwatch64_LABEL_1086
    CASE 1088: GOTO vwatch64_LABEL_1088
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function type_human_sig$(sig$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1091:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1091): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1091 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1091
    o$ = type_human_readable$(cvl(left$(sig$, 4))) + "("
vwatch64_SKIP_1091:::: 
vwatch64_LABEL_1092:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1092): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1092 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1092
    for p = 1 to (len(sig$) - 4) / 8
vwatch64_SKIP_1092:::: 
vwatch64_LABEL_1093:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1093): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1093 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1093
        flags = cvl(mid$(sig$,p * 8 + 1, 4))
vwatch64_SKIP_1093:::: 
vwatch64_LABEL_1094:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1094): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1094 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1094
        if flags and TYPE_BYVAL then o$ = o$ + "BYVAL "
vwatch64_SKIP_1094:::: 
vwatch64_LABEL_1095:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1095): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1095 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1095
        if flags and TYPE_BYREF then o$ = o$ + "BYREF "
vwatch64_SKIP_1095:::: 
vwatch64_LABEL_1096:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1096): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1096 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1096
        if flags and TYPE_REQUIRED = 0 then o$ = o$ + "OPTION "
vwatch64_SKIP_1096:::: 
vwatch64_LABEL_1097:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1097): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1097 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1097
        o$ = o$ + type_human_readable$(cvl(mid$(sig$, p * 8 - 3, 4)))
vwatch64_SKIP_1097:::: 
vwatch64_LABEL_1098:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1098): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1098 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1098
        if p < (len(sig$) - 4) / 8 then o$ = o$ + ", "
vwatch64_SKIP_1098:::: 
vwatch64_LABEL_1099:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1099): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1099 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1099
    next p
vwatch64_SKIP_1099:::: 
vwatch64_LABEL_1100:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1100): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1100 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1100
    type_human_sig$ = o$ + ")"
vwatch64_SKIP_1100:::: 
vwatch64_LABEL_1101:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1101): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1101
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1091: GOTO vwatch64_LABEL_1091
    CASE 1092: GOTO vwatch64_LABEL_1092
    CASE 1093: GOTO vwatch64_LABEL_1093
    CASE 1094: GOTO vwatch64_LABEL_1094
    CASE 1095: GOTO vwatch64_LABEL_1095
    CASE 1096: GOTO vwatch64_LABEL_1096
    CASE 1097: GOTO vwatch64_LABEL_1097
    CASE 1098: GOTO vwatch64_LABEL_1098
    CASE 1099: GOTO vwatch64_LABEL_1099
    CASE 1100: GOTO vwatch64_LABEL_1100
    CASE 1101: GOTO vwatch64_LABEL_1101
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function
 
'This function is incorrect!
function type_detect_numint_type(content$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1105:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1105): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1105 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1105
    if len(content$) < 10 then
vwatch64_SKIP_1105:::: 
vwatch64_LABEL_1106:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1106): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1106 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1106
        type_detect_numint_type = TYPE_INTEGER
vwatch64_SKIP_1106:::: 
vwatch64_LABEL_1107:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1107): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1107 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1107
    elseif len(content$) > 10 then
vwatch64_SKIP_1107:::: 
vwatch64_LABEL_1108:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1108): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1108 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1108
        type_detect_numint_type = TYPE_LONG
vwatch64_SKIP_1108:::: 
vwatch64_LABEL_1109:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1109): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1109 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1109
    elseif _strcmp("2147483647", content$) = -1 then
vwatch64_SKIP_1109:::: 
vwatch64_LABEL_1110:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1110): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1110 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1110
        type_detect_numint_type = TYPE_LONG
vwatch64_SKIP_1110:::: 
vwatch64_LABEL_1111:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1111): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1111 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1111
    end if
vwatch64_SKIP_1111:::: 
vwatch64_LABEL_1112:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1112): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1112
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1105: GOTO vwatch64_LABEL_1105
    CASE 1106: GOTO vwatch64_LABEL_1106
    CASE 1107: GOTO vwatch64_LABEL_1107
    CASE 1108: GOTO vwatch64_LABEL_1108
    CASE 1109: GOTO vwatch64_LABEL_1109
    CASE 1110: GOTO vwatch64_LABEL_1110
    CASE 1111: GOTO vwatch64_LABEL_1111
    CASE 1112: GOTO vwatch64_LABEL_1112
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function
'*INCLUDE file merged: 'ast.bm'
deflng a-z

' Initialise a clean AST
sub ast_init
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1118:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1118): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1118 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1118
    ast_constants(AST_NONE) = "None"
vwatch64_SKIP_1118:::: 
vwatch64_LABEL_1119:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1119): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1119 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1119
    ast_constant_types(AST_NONE) = TYPE_ANY
vwatch64_SKIP_1119:::: 
vwatch64_LABEL_1120:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1120): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1120 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1120
    ast_constants(AST_FALSE) = "0"
vwatch64_SKIP_1120:::: 
vwatch64_LABEL_1121:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1121): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1121 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1121
    ast_constant_types(AST_FALSE) = TYPE_NUMERIC
vwatch64_SKIP_1121:::: 
vwatch64_LABEL_1122:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1122): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1122 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1122
    ast_constants(AST_TRUE) = "-1"
vwatch64_SKIP_1122:::: 
vwatch64_LABEL_1123:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1123): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1123 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1123
    ast_constant_types(AST_TRUE) = TYPE_NUMERIC
vwatch64_SKIP_1123:::: 
vwatch64_LABEL_1124:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1124): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1124 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1124
    ast_constants(AST_ONE) = "1"
vwatch64_SKIP_1124:::: 
vwatch64_LABEL_1125:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1125): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1125 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1125
    ast_constant_types(AST_ONE) = TYPE_NUMERIC
vwatch64_SKIP_1125:::: 
vwatch64_LABEL_1126:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1126): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1126 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1126
    ast_last_constant = 4
vwatch64_SKIP_1126:::: 
vwatch64_LABEL_1127:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1127): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1127
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1118: GOTO vwatch64_LABEL_1118
    CASE 1119: GOTO vwatch64_LABEL_1119
    CASE 1120: GOTO vwatch64_LABEL_1120
    CASE 1121: GOTO vwatch64_LABEL_1121
    CASE 1122: GOTO vwatch64_LABEL_1122
    CASE 1123: GOTO vwatch64_LABEL_1123
    CASE 1124: GOTO vwatch64_LABEL_1124
    CASE 1125: GOTO vwatch64_LABEL_1125
    CASE 1126: GOTO vwatch64_LABEL_1126
    CASE 1127: GOTO vwatch64_LABEL_1127
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

function ast_add_constant(token, content$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1130:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1130): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1130 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1130
    if ast_last_constant = ubound(ast_constants) then ast_expand_constants_array
vwatch64_SKIP_1130:::: 
vwatch64_LABEL_1131:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1131): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1131 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1131
    ast_last_constant = ast_last_constant + 1
vwatch64_SKIP_1131:::: 
vwatch64_LABEL_1132:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1132): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1132 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1132
    select case token
vwatch64_SKIP_1132:::: 
    case TOK_NUMINT
vwatch64_LABEL_1134:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1134): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1134 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1134
        ast_constants(ast_last_constant) = content$
vwatch64_SKIP_1134:::: 
vwatch64_LABEL_1135:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1135): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1135 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1135
        ast_constant_types(ast_last_constant) = type_detect_numint_type(content$)
vwatch64_SKIP_1135:::: 
    case TOK_NUMDEC
vwatch64_LABEL_1137:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1137): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1137 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1137
        ast_constants(ast_last_constant) = content$
vwatch64_SKIP_1137:::: 
vwatch64_LABEL_1138:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1138): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1138 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1138
        ast_constant_types(ast_last_constant) = TYPE_DOUBLE
vwatch64_SKIP_1138:::: 
    case TOK_NUMBASE
vwatch64_LABEL_1140:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1140): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1140 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1140
        ast_constants(ast_last_constant) = ltrim$(str$(val(content$)))
vwatch64_SKIP_1140:::: 
vwatch64_LABEL_1141:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1141): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1141 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1141
        ast_constant_types(ast_last_constant) = type_detect_numint_type(ast_constants(ast_last_constant))
vwatch64_SKIP_1141:::: 
    case TOK_NUMEXP
vwatch64_LABEL_1143:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1143): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1143 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1143
        fatalerror "No support for numbers with exponents"
vwatch64_SKIP_1143:::: 
    case TOK_STRING
        'Strip quotes
vwatch64_LABEL_1146:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1146): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1146 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1146
        ast_constants(ast_last_constant) = mid$(content$, 2, len(content$) - 2)
vwatch64_SKIP_1146:::: 
vwatch64_LABEL_1147:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1147): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1147 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1147
        ast_constant_types(ast_last_constant) = TYPE_STRING
vwatch64_SKIP_1147:::: 
    end select
vwatch64_LABEL_1149:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1149): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1149 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1149
    ast_add_constant = ast_last_constant
vwatch64_SKIP_1149:::: 
vwatch64_LABEL_1150:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1150): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1150
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1130: GOTO vwatch64_LABEL_1130
    CASE 1131: GOTO vwatch64_LABEL_1131
    CASE 1132: GOTO vwatch64_LABEL_1132
    CASE 1134: GOTO vwatch64_LABEL_1134
    CASE 1135: GOTO vwatch64_LABEL_1135
    CASE 1137: GOTO vwatch64_LABEL_1137
    CASE 1138: GOTO vwatch64_LABEL_1138
    CASE 1140: GOTO vwatch64_LABEL_1140
    CASE 1141: GOTO vwatch64_LABEL_1141
    CASE 1143: GOTO vwatch64_LABEL_1143
    CASE 1146: GOTO vwatch64_LABEL_1146
    CASE 1147: GOTO vwatch64_LABEL_1147
    CASE 1149: GOTO vwatch64_LABEL_1149
    CASE 1150: GOTO vwatch64_LABEL_1150
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function
    
function ast_add_node(typ)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1153:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1153): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1153 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1153
    if ast_last_node = ubound(ast_nodes) then ast_expand_nodes_arrays
vwatch64_SKIP_1153:::: 
vwatch64_LABEL_1154:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1154): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1154 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1154
    ast_last_node = ast_last_node + 1
vwatch64_SKIP_1154:::: 
vwatch64_LABEL_1155:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1155): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1155 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1155
    ast_nodes(ast_last_node).typ = typ
vwatch64_SKIP_1155:::: 
vwatch64_LABEL_1156:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1156): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1156 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1156
    ast_add_node = ast_last_node
vwatch64_SKIP_1156:::: 
vwatch64_LABEL_1157:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1157): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1157
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1153: GOTO vwatch64_LABEL_1153
    CASE 1154: GOTO vwatch64_LABEL_1154
    CASE 1155: GOTO vwatch64_LABEL_1155
    CASE 1156: GOTO vwatch64_LABEL_1156
    CASE 1157: GOTO vwatch64_LABEL_1157
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ast_add_cast(expr, vartyp)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1160:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1160): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1160 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1160
    if vartyp = type_of_expr(expr) then
vwatch64_SKIP_1160:::: 
vwatch64_LABEL_1161:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1161): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1161 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1161
        ast_add_cast = expr
vwatch64_SKIP_1161:::: 
vwatch64_LABEL_1162:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1162): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1162 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1162
        vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: exit function
vwatch64_SKIP_1162:::: 
vwatch64_LABEL_1163:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1163): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1163 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1163
    end if
vwatch64_SKIP_1163:::: 
vwatch64_LABEL_1164:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1164): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1164 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1164
    cast_node = ast_add_node(AST_CAST)
vwatch64_SKIP_1164:::: 
vwatch64_LABEL_1165:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1165): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1165 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1165
    ast_nodes(cast_node).ref = vartyp
vwatch64_SKIP_1165:::: 
vwatch64_LABEL_1166:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1166): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1166 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1166
    ast_attach cast_node, expr
vwatch64_SKIP_1166:::: 
vwatch64_LABEL_1167:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1167): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1167 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1167
    ast_add_cast = cast_node
vwatch64_SKIP_1167:::: 
vwatch64_LABEL_1168:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1168): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1168
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1160: GOTO vwatch64_LABEL_1160
    CASE 1161: GOTO vwatch64_LABEL_1161
    CASE 1162: GOTO vwatch64_LABEL_1162
    CASE 1163: GOTO vwatch64_LABEL_1163
    CASE 1164: GOTO vwatch64_LABEL_1164
    CASE 1165: GOTO vwatch64_LABEL_1165
    CASE 1166: GOTO vwatch64_LABEL_1166
    CASE 1167: GOTO vwatch64_LABEL_1167
    CASE 1168: GOTO vwatch64_LABEL_1168
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

sub ast_attach(parent, child)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1171:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1171): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1171 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1171
    ast_nodes(parent).num_children = ast_nodes(parent).num_children + 1
vwatch64_SKIP_1171:::: 
vwatch64_LABEL_1172:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1172): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1172 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1172
    ast_children(parent) = ast_children(parent) + mkl$(child)
vwatch64_SKIP_1172:::: 
vwatch64_LABEL_1173:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1173): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1173
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1171: GOTO vwatch64_LABEL_1171
    CASE 1172: GOTO vwatch64_LABEL_1172
    CASE 1173: GOTO vwatch64_LABEL_1173
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

'Why does this function exist when there's a .num_children field on the node?
function ast_num_children(node)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1177:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1177): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1177 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1177
    ast_num_children = len(ast_children(node)) / len(dummy&)
vwatch64_SKIP_1177:::: 
vwatch64_LABEL_1178:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1178): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1178
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1177: GOTO vwatch64_LABEL_1177
    CASE 1178: GOTO vwatch64_LABEL_1178
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ast_get_child(node, index)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1181:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1181): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1181 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1181
    ast_get_child = cvl(mid$(ast_children(node), len(dummy&) * (index - 1) + 1, len(dummy&)))
vwatch64_SKIP_1181:::: 
vwatch64_LABEL_1182:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1182): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1182
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1181: GOTO vwatch64_LABEL_1181
    CASE 1182: GOTO vwatch64_LABEL_1182
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

sub ast_replace_child(node, index, new_child)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1185:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1185): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1185 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1185
    mid$(ast_children(node), len(dummy&) * (index - 1) + 1, len(dummy&)) = mkl$(new_child)
vwatch64_SKIP_1185:::: 
vwatch64_LABEL_1186:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1186): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1186
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1185: GOTO vwatch64_LABEL_1185
    CASE 1186: GOTO vwatch64_LABEL_1186
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub ast_expand_nodes_arrays()
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1189:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1189): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1189 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1189
    new_size = ubound(ast_nodes) * 2
vwatch64_SKIP_1189:::: 
    redim _preserve ast_nodes(new_size) as ast_node_t
    redim _preserve ast_children(new_size) as string
vwatch64_LABEL_1192:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1192): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1192
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1189: GOTO vwatch64_LABEL_1189
    CASE 1192: GOTO vwatch64_LABEL_1192
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub ast_expand_constants_array()
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1195:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1195): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1195 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1195
    new_size = ubound(ast_constants) * 2
vwatch64_SKIP_1195:::: 
    redim _preserve ast_constants(new_size) as string
    redim _preserve ast_constant_types(new_size) as long
vwatch64_LABEL_1198:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1198): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1198
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1195: GOTO vwatch64_LABEL_1195
    CASE 1198: GOTO vwatch64_LABEL_1198
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub
'*INCLUDE file merged: 'htable.bm'
$CHECKING:OFF
DEFLNG A-Z

SUB htable_add_hentry (ckey$, he AS hentry_t)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    IF htable.elements = UBOUND(htable_entries) THEN
        REDIM _PRESERVE htable_entries(htable.elements * 2) AS hentry_t
        REDIM _PRESERVE htable_names(htable.elements * 2) AS STRING
    END IF
    he.id = htable.elements + 1 '+1 to avoid using 0
    htable_entries(he.id) = he
    htable_names(he.id) = ckey$
    htable_add_local htable, ckey$, he.id
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
END SUB

FUNCTION htable_get_id (ckey$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    htable_get_id = htable_get_local(htable, ckey$)
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
END FUNCTION

FUNCTION htable_last_id
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    htable_last_id = htable.elements
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
END FUNCTION

'Here ends externally callable functions. Those below are for internal use only.

SUB htable_create (ht AS htable_t, expected_elements)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    ht.table = _MEMNEW(HTABLE_ENTRY_SIZE * expected_elements)
    ht.buckets = expected_elements
    _MEMFILL ht.table, ht.table.OFFSET, HTABLE_ENTRY_SIZE * expected_elements, 0 AS LONG
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
END SUB

SUB htable_expand_if_needed (ht AS htable_t)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    CONST HTABLE_MAX_LOADING = 0.75
    CONST HTABLE_GROWTH_FACTOR = 2
    IF ht.elements / ht.buckets <= HTABLE_MAX_LOADING THEN vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: EXIT FUNCTION
    DIM newht AS htable_t, h~&, klen
    htable_create newht, ht.buckets * HTABLE_GROWTH_FACTOR + 1
    FOR h~& = 0 TO ht.buckets - 1
        klen = _MEMGET(ht.table, ht.table.OFFSET + h~& * HTABLE_ENTRY_SIZE + HTABLE_KEYLEN_OFFSET, LONG)
        IF klen > 0 THEN
            htable_add_memkey newht, _
                              _MEMGET(ht.table, ht.table.offset + h~& * HTABLE_ENTRY_SIZE + HTABLE_KEY_OFFSET, _OFFSET), _
                              klen, _
                              _MEMGET(ht.table, ht.table.OFFSET + h~& * HTABLE_ENTRY_SIZE + HTABLE_DATA_OFFSET, LONG)
        END IF
    NEXT h~&
    _MEMFREE ht.table
    ht = newht
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
END SUB

SUB htable_add_local (ht AS htable_t, ckey$, value)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    DIM m AS _MEM
    m = _MEMNEW(LEN(ckey$))
    _MEMPUT m, m.OFFSET, ckey$
    htable_add_memkey ht, m.OFFSET, LEN(ckey$), value
    htable_expand_if_needed ht
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
END SUB

SUB htable_add_memkey (ht AS htable_t, ckey%&, keylen, value)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    DIM h~&, coff%&
    h~& = htable_hash_memkey~&(ckey%&, keylen, ht.buckets)
    DO
        coff%& = _MEMGET(ht.table, ht.table.OFFSET + h~& * HTABLE_ENTRY_SIZE + HTABLE_KEY_OFFSET, _OFFSET)
        IF coff%& = 0 THEN EXIT DO
        h~& = (h~& + 1) MOD ht.buckets
    LOOP
    _MEMPUT ht.table, ht.table.OFFSET + h~& * HTABLE_ENTRY_SIZE + HTABLE_KEY_OFFSET, ckey%&
    _MEMPUT ht.table, ht.table.OFFSET + h~& * HTABLE_ENTRY_SIZE + HTABLE_KEYLEN_OFFSET, keylen AS LONG
    _MEMPUT ht.table, ht.table.OFFSET + h~& * HTABLE_ENTRY_SIZE + HTABLE_DATA_OFFSET, value
    ht.elements = ht.elements + 1
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
END SUB

FUNCTION htable_get_local (ht AS htable_t, key$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    DIM h~&, klen, kaddr%&, ckey$
    h~& = htable_hash~&(key$, ht.buckets)
    DO
        klen = _MEMGET(ht.table, ht.table.OFFSET + h~& * HTABLE_ENTRY_SIZE + HTABLE_KEYLEN_OFFSET, LONG)
        IF klen = 0 THEN
            htable_get_local = 0
            vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: EXIT FUNCTION
        END IF
        IF klen = LEN(key$) THEN 'this could be it
            kaddr%& = _MEMGET(ht.table, ht.table.OFFSET + h~& * HTABLE_ENTRY_SIZE + HTABLE_KEY_OFFSET, _OFFSET)
            ckey$ = SPACE$(klen)
            '$CHECKING:OFF
            _MEMGET ht.table, kaddr%&, ckey$ 'ht.table has no meaning here; we are dereferencing kaddr%&
            '$CHECKING:ON
            IF ckey$ = key$ THEN 'got it!
                htable_get_local = _MEMGET(ht.table, ht.table.OFFSET + h~& * HTABLE_ENTRY_SIZE + HTABLE_DATA_OFFSET, LONG)
                vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: EXIT FUNCTION
            END IF
        END IF
        h~& = (h~& + 1) MOD ht.buckets
    LOOP
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
END FUNCTION

'http://www.cse.yorku.ca/~oz/hash.html
FUNCTION htable_hash~& (s$, mod_size)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    DIM hash~&, i
    hash~& = 5381
    FOR i = 1 TO LEN(s$)
        hash~& = ((hash~& * 33) XOR ASC(s$, i)) MOD mod_size
    NEXT i
    htable_hash~& = hash~&
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
END FUNCTION

FUNCTION htable_hash_memkey~& (s AS _OFFSET, slen, mod_size)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    DIM hash~&, i, dummy AS _MEM
    hash~& = 5381
    FOR i = 0 TO slen - 1
        '$CHECKING:OFF
        hash~& = ((hash~& * 33) XOR _MEMGET(dummy, s + i, _UNSIGNED _BYTE)) MOD mod_size
        '$CHECKING:ON
    NEXT i
    htable_hash_memkey~& = hash~&
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
END SUB
$CHECKING:ON
'*INCLUDE file merged: 'parser/parser.bm'
sub ps_gobble(token)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1318:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1318): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1318 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1318
    do
vwatch64_SKIP_1318:::: 
vwatch64_LABEL_1319:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1319): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1319 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1319
        t = tok_next_token
vwatch64_SKIP_1319:::: 
vwatch64_LABEL_1320:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1320): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1320 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1320
    loop until t <> token or t = 0 '0 indicates EOF
vwatch64_SKIP_1320:::: 
vwatch64_LABEL_1321:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1321): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1321 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1321
    tok_please_repeat
vwatch64_SKIP_1321:::: 
vwatch64_LABEL_1322:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1322): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1322
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1318: GOTO vwatch64_LABEL_1318
    CASE 1319: GOTO vwatch64_LABEL_1319
    CASE 1320: GOTO vwatch64_LABEL_1320
    CASE 1321: GOTO vwatch64_LABEL_1321
    CASE 1322: GOTO vwatch64_LABEL_1322
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub
    
function ps_block
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1325:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1325): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1325 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1325
    debuginfo "Start block"
vwatch64_SKIP_1325:::: 
vwatch64_LABEL_1326:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1326): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1326 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1326
    root = ast_add_node(AST_BLOCK)
vwatch64_SKIP_1326:::: 
vwatch64_LABEL_1327:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1327): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1327 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1327
    do
vwatch64_SKIP_1327:::: 
vwatch64_LABEL_1328:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1328): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1328 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1328
        ps_gobble(TOK_NEWLINE)
vwatch64_SKIP_1328:::: 
vwatch64_LABEL_1329:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1329): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1329 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1329
        stmt = ps_stmt
vwatch64_SKIP_1329:::: 
vwatch64_LABEL_1330:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1330): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1330 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1330
        if stmt = 0 then exit do 'use 0 to signal the end of a block
vwatch64_SKIP_1330:::: 
vwatch64_LABEL_1331:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1331): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1331 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1331
        ast_attach root, stmt
vwatch64_SKIP_1331:::: 
vwatch64_LABEL_1332:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1332): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1332 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1332
    loop
vwatch64_SKIP_1332:::: 
vwatch64_LABEL_1333:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1333): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1333 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1333
    ps_block = root
vwatch64_SKIP_1333:::: 
vwatch64_LABEL_1334:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1334): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1334 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1334
    debuginfo "End block"
vwatch64_SKIP_1334:::: 
vwatch64_LABEL_1335:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1335): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1335
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1325: GOTO vwatch64_LABEL_1325
    CASE 1326: GOTO vwatch64_LABEL_1326
    CASE 1327: GOTO vwatch64_LABEL_1327
    CASE 1328: GOTO vwatch64_LABEL_1328
    CASE 1329: GOTO vwatch64_LABEL_1329
    CASE 1330: GOTO vwatch64_LABEL_1330
    CASE 1331: GOTO vwatch64_LABEL_1331
    CASE 1332: GOTO vwatch64_LABEL_1332
    CASE 1333: GOTO vwatch64_LABEL_1333
    CASE 1334: GOTO vwatch64_LABEL_1334
    CASE 1335: GOTO vwatch64_LABEL_1335
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_stmt
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    dim he as hentry_t
vwatch64_LABEL_1339:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1339): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1339 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1339
    debuginfo "Start statement"
vwatch64_SKIP_1339:::: 
vwatch64_LABEL_1340:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1340): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1340 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1340
    token = tok_next_token
vwatch64_SKIP_1340:::: 
vwatch64_LABEL_1341:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1341): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1341 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1341
    select case token
vwatch64_SKIP_1341:::: 
        case is < 0
vwatch64_LABEL_1343:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1343): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1343 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1343
            fatalerror "Unexpected literal " + tok_content$
vwatch64_SKIP_1343:::: 
        case TOK_IF
vwatch64_LABEL_1345:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1345): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1345 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1345
            ps_stmt = ps_if
vwatch64_SKIP_1345:::: 
        case TOK_DO
vwatch64_LABEL_1347:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1347): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1347 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1347
            ps_stmt = ps_do
vwatch64_SKIP_1347:::: 
        case TOK_WHILE
vwatch64_LABEL_1349:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1349): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1349 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1349
            ps_stmt = ps_while
vwatch64_SKIP_1349:::: 
        case TOK_FOR
vwatch64_LABEL_1351:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1351): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1351 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1351
            ps_stmt = ps_for
vwatch64_SKIP_1351:::: 
        case TOK_SELECT
vwatch64_LABEL_1353:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1353): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1353 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1353
            ps_stmt = ps_select
vwatch64_SKIP_1353:::: 
        case TOK_ELSE, TOK_LOOP, TOK_WEND, TOK_NEXT, TOK_CASE, TOK_EOF 
            'These all end a block in some fashion. Repeat so that the
            'block-specific code can assert the ending token
vwatch64_LABEL_1357:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1357): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1357 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1357
            ps_stmt = 0
vwatch64_SKIP_1357:::: 
vwatch64_LABEL_1358:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1358): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1358 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1358
            tok_please_repeat
vwatch64_SKIP_1358:::: 
        case TOK_END 'As in END IF, END SUB etc.
            'Like above, but no repeat so the block-specific ending token
            'can be asserted
vwatch64_LABEL_1362:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1362): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1362 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1362
            ps_stmt = 0
vwatch64_SKIP_1362:::: 
        case TOK_UNKNOWN
vwatch64_LABEL_1364:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1364): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1364 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1364
            ps_stmt = ps_assignment(ps_variable(token, tok_content$))
vwatch64_SKIP_1364:::: 
        case else
vwatch64_LABEL_1366:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1366): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1366 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1366
            he = htable_entries(token)
vwatch64_SKIP_1366:::: 
vwatch64_LABEL_1367:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1367): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1367 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1367
            select case he.typ
vwatch64_SKIP_1367:::: 
            case HE_VARIABLE
vwatch64_LABEL_1369:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1369): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1369 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1369
                ps_stmt = ps_assignment(ps_variable(token, tok_content$))
vwatch64_SKIP_1369:::: 
            case HE_FUNCTION
vwatch64_LABEL_1371:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1371): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1371 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1371
                tok_please_repeat
vwatch64_SKIP_1371:::: 
vwatch64_LABEL_1372:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1372): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1372 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1372
                ps_stmt = ps_stmtreg
vwatch64_SKIP_1372:::: 
            case else
vwatch64_LABEL_1374:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1374): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1374 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1374
                fatalerror tok_content$ + " doesn't belong here"
vwatch64_SKIP_1374:::: 
            end select
    end select
vwatch64_LABEL_1377:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1377): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1377 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1377
    debuginfo "Completed statement"
vwatch64_SKIP_1377:::: 
vwatch64_LABEL_1378:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1378): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1378
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1339: GOTO vwatch64_LABEL_1339
    CASE 1340: GOTO vwatch64_LABEL_1340
    CASE 1341: GOTO vwatch64_LABEL_1341
    CASE 1343: GOTO vwatch64_LABEL_1343
    CASE 1345: GOTO vwatch64_LABEL_1345
    CASE 1347: GOTO vwatch64_LABEL_1347
    CASE 1349: GOTO vwatch64_LABEL_1349
    CASE 1351: GOTO vwatch64_LABEL_1351
    CASE 1353: GOTO vwatch64_LABEL_1353
    CASE 1357: GOTO vwatch64_LABEL_1357
    CASE 1358: GOTO vwatch64_LABEL_1358
    CASE 1362: GOTO vwatch64_LABEL_1362
    CASE 1364: GOTO vwatch64_LABEL_1364
    CASE 1366: GOTO vwatch64_LABEL_1366
    CASE 1367: GOTO vwatch64_LABEL_1367
    CASE 1369: GOTO vwatch64_LABEL_1369
    CASE 1371: GOTO vwatch64_LABEL_1371
    CASE 1372: GOTO vwatch64_LABEL_1372
    CASE 1374: GOTO vwatch64_LABEL_1374
    CASE 1377: GOTO vwatch64_LABEL_1377
    CASE 1378: GOTO vwatch64_LABEL_1378
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_select
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1381:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1381): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1381 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1381
    debuginfo "Start SELECT block"
vwatch64_SKIP_1381:::: 
    dim he as hentry_t
vwatch64_LABEL_1383:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1383): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1383 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1383
    root = ast_add_node(AST_SELECT)
vwatch64_SKIP_1383:::: 
vwatch64_LABEL_1384:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1384): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1384 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1384
    ps_assert_token tok_next_token, TOK_CASE
vwatch64_SKIP_1384:::: 
vwatch64_LABEL_1385:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1385): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1385 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1385
    expr = ps_expr
vwatch64_SKIP_1385:::: 
vwatch64_LABEL_1386:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1386): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1386 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1386
    expr_type = type_of_expr(expr)
vwatch64_SKIP_1386:::: 
vwatch64_LABEL_1387:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1387): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1387 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1387
    ast_attach root, expr
vwatch64_SKIP_1387:::: 
vwatch64_LABEL_1388:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1388): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1388 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1388
    ps_assert_token tok_next_token, TOK_NEWLINE
vwatch64_SKIP_1388:::: 
vwatch64_LABEL_1389:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1389): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1389 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1389
    t = tok_next_token
vwatch64_SKIP_1389:::: 
vwatch64_LABEL_1390:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1390): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1390 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1390
    do
vwatch64_SKIP_1390:::: 
vwatch64_LABEL_1391:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1391): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1391 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1391
        ps_assert_token t, TOK_CASE
vwatch64_SKIP_1391:::: 
vwatch64_LABEL_1392:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1392): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1392 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1392
        guard = ps_expr
vwatch64_SKIP_1392:::: 
vwatch64_LABEL_1393:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1393): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1393 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1393
        guard_type = type_of_expr(guard)
vwatch64_SKIP_1393:::: 
vwatch64_LABEL_1394:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1394): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1394 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1394
        if not type_can_cast(expr_type, guard_type) then fatalerror "Type of CASE expression does not match"
vwatch64_SKIP_1394:::: 
vwatch64_LABEL_1395:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1395): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1395 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1395
        ast_attach root, ast_add_cast(guard, expr_type)
vwatch64_SKIP_1395:::: 
vwatch64_LABEL_1396:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1396): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1396 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1396
        ast_attach root, ps_block
vwatch64_SKIP_1396:::: 
vwatch64_LABEL_1397:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1397): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1397 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1397
        t = tok_next_token
vwatch64_SKIP_1397:::: 
vwatch64_LABEL_1398:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1398): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1398 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1398
    loop while t <> TOK_SELECT 'ps_block eats the END
vwatch64_SKIP_1398:::: 
vwatch64_LABEL_1399:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1399): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1399 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1399
    ps_select = root
vwatch64_SKIP_1399:::: 
vwatch64_LABEL_1400:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1400): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1400
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1381: GOTO vwatch64_LABEL_1381
    CASE 1383: GOTO vwatch64_LABEL_1383
    CASE 1384: GOTO vwatch64_LABEL_1384
    CASE 1385: GOTO vwatch64_LABEL_1385
    CASE 1386: GOTO vwatch64_LABEL_1386
    CASE 1387: GOTO vwatch64_LABEL_1387
    CASE 1388: GOTO vwatch64_LABEL_1388
    CASE 1389: GOTO vwatch64_LABEL_1389
    CASE 1390: GOTO vwatch64_LABEL_1390
    CASE 1391: GOTO vwatch64_LABEL_1391
    CASE 1392: GOTO vwatch64_LABEL_1392
    CASE 1393: GOTO vwatch64_LABEL_1393
    CASE 1394: GOTO vwatch64_LABEL_1394
    CASE 1395: GOTO vwatch64_LABEL_1395
    CASE 1396: GOTO vwatch64_LABEL_1396
    CASE 1397: GOTO vwatch64_LABEL_1397
    CASE 1398: GOTO vwatch64_LABEL_1398
    CASE 1399: GOTO vwatch64_LABEL_1399
    CASE 1400: GOTO vwatch64_LABEL_1400
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_for
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1403:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1403): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1403 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1403
    debuginfo "Start FOR block"
vwatch64_SKIP_1403:::: 
    dim he as hentry_t
vwatch64_LABEL_1405:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1405): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1405 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1405
    root = ast_add_node(AST_FOR)
vwatch64_SKIP_1405:::: 
vwatch64_LABEL_1406:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1406): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1406 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1406
    t = tok_next_token
vwatch64_SKIP_1406:::: 
vwatch64_LABEL_1407:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1407): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1407 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1407
    if t = TOK_UNKNOWN then
vwatch64_SKIP_1407:::: 
vwatch64_LABEL_1408:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1408): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1408 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1408
        iterator = ps_variable(t, tok_content$)
vwatch64_SKIP_1408:::: 
vwatch64_LABEL_1409:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1409): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1409 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1409
        iterator_type = htable_entries(iterator).v1
vwatch64_SKIP_1409:::: 
vwatch64_LABEL_1410:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1410): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1410 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1410
        if not type_is_number(iterator_type) then fatalerror "FOR must have a numeric variable"
vwatch64_SKIP_1410:::: 
vwatch64_LABEL_1411:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1411): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1411 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1411
    else
vwatch64_SKIP_1411:::: 
vwatch64_LABEL_1412:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1412): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1412 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1412
        fatalerror "Expected new variable as iterator"
vwatch64_SKIP_1412:::: 
vwatch64_LABEL_1413:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1413): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1413 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1413
    end if
vwatch64_SKIP_1413:::: 
vwatch64_LABEL_1414:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1414): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1414 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1414
    ps_assert_token tok_next_token, TOK_EQUALS
vwatch64_SKIP_1414:::: 

vwatch64_LABEL_1416:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1416): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1416 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1416
    start_val = ps_expr
vwatch64_SKIP_1416:::: 
vwatch64_LABEL_1417:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1417): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1417 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1417
    if not type_is_number(type_of_expr(start_val)) then fatalerror "FOR start value must be numeric"
vwatch64_SKIP_1417:::: 
vwatch64_LABEL_1418:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1418): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1418 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1418
    start_val = ast_add_cast(start_val, iterator_type)
vwatch64_SKIP_1418:::: 

vwatch64_LABEL_1420:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1420): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1420 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1420
    ps_assert_token tok_next_token, TOK_TO
vwatch64_SKIP_1420:::: 

vwatch64_LABEL_1422:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1422): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1422 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1422
    end_val = ps_expr
vwatch64_SKIP_1422:::: 
vwatch64_LABEL_1423:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1423): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1423 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1423
    if not type_is_number(type_of_expr(start_val)) then fatalerror "FOR end value must be numeric"
vwatch64_SKIP_1423:::: 
vwatch64_LABEL_1424:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1424): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1424 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1424
    end_val = ast_add_cast(end_val, iterator_type)
vwatch64_SKIP_1424:::: 

vwatch64_LABEL_1426:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1426): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1426 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1426
    t = tok_next_token
vwatch64_SKIP_1426:::: 
vwatch64_LABEL_1427:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1427): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1427 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1427
    if t = TOK_STEP then
vwatch64_SKIP_1427:::: 
vwatch64_LABEL_1428:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1428): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1428 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1428
        step_val = ps_expr
vwatch64_SKIP_1428:::: 
vwatch64_LABEL_1429:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1429): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1429 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1429
        if not type_is_number(type_of_expr(step_val)) then fatalerror "FOR STEP value must be numeric"
vwatch64_SKIP_1429:::: 
vwatch64_LABEL_1430:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1430): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1430 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1430
        ps_assert_token tok_next_token, TOK_NEWLINE
vwatch64_SKIP_1430:::: 
vwatch64_LABEL_1431:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1431): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1431 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1431
    elseif t = TOK_NEWLINE then
vwatch64_SKIP_1431:::: 
        'Default is STEP 1
vwatch64_LABEL_1433:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1433): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1433 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1433
        step_val = ast_add_node(AST_CONSTANT)
vwatch64_SKIP_1433:::: 
vwatch64_LABEL_1434:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1434): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1434 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1434
        ast_nodes(step_val).ref = AST_ONE
vwatch64_SKIP_1434:::: 
vwatch64_LABEL_1435:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1435): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1435 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1435
    else
vwatch64_SKIP_1435:::: 
vwatch64_LABEL_1436:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1436): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1436 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1436
        fatalerror "Unexpected " + tok_content$
vwatch64_SKIP_1436:::: 
vwatch64_LABEL_1437:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1437): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1437 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1437
    end if
vwatch64_SKIP_1437:::: 
vwatch64_LABEL_1438:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1438): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1438 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1438
    step_val = ast_add_cast(step_val, iterator_type)
vwatch64_SKIP_1438:::: 

vwatch64_LABEL_1440:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1440): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1440 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1440
    block = ps_block
vwatch64_SKIP_1440:::: 

    'Error checking
vwatch64_LABEL_1443:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1443): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1443 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1443
    ps_assert_token tok_next_token, TOK_NEXT
vwatch64_SKIP_1443:::: 
vwatch64_LABEL_1444:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1444): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1444 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1444
    t = tok_next_token
vwatch64_SKIP_1444:::: 
vwatch64_LABEL_1445:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1445): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1445 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1445
    if t < 0 then
vwatch64_SKIP_1445:::: 
vwatch64_LABEL_1446:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1446): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1446 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1446
        fatalerror "Expected variable reference, not a literal"
vwatch64_SKIP_1446:::: 
vwatch64_LABEL_1447:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1447): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1447 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1447
    elseif t = TOK_UNKNOWN then
vwatch64_SKIP_1447:::: 
vwatch64_LABEL_1448:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1448): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1448 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1448
        fatalerror "Unknown variable"
vwatch64_SKIP_1448:::: 
vwatch64_LABEL_1449:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1449): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1449 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1449
    end if
vwatch64_SKIP_1449:::: 
vwatch64_LABEL_1450:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1450): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1450 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1450
    he = htable_entries(t)
vwatch64_SKIP_1450:::: 
vwatch64_LABEL_1451:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1451): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1451 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1451
    if he.typ <> HE_VARIABLE then fatalerror "Unexpected " + tok_content$
vwatch64_SKIP_1451:::: 
vwatch64_LABEL_1452:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1452): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1452 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1452
    if iterator <> ps_variable(t, tok_content$) then fatalerror "Variable in NEXT does not match variable in FOR"
vwatch64_SKIP_1452:::: 
vwatch64_LABEL_1453:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1453): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1453 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1453
    ps_assert_token tok_next_token, TOK_NEWLINE
vwatch64_SKIP_1453:::: 

vwatch64_LABEL_1455:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1455): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1455 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1455
    ast_nodes(root).ref = iterator
vwatch64_SKIP_1455:::: 
vwatch64_LABEL_1456:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1456): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1456 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1456
    ast_attach root, start_val
vwatch64_SKIP_1456:::: 
vwatch64_LABEL_1457:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1457): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1457 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1457
    ast_attach root, end_val
vwatch64_SKIP_1457:::: 
vwatch64_LABEL_1458:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1458): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1458 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1458
    ast_attach root, step_val
vwatch64_SKIP_1458:::: 
vwatch64_LABEL_1459:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1459): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1459 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1459
    ast_attach root, block
vwatch64_SKIP_1459:::: 
vwatch64_LABEL_1460:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1460): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1460 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1460
    ps_for = root
vwatch64_SKIP_1460:::: 
vwatch64_LABEL_1461:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1461): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1461
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1403: GOTO vwatch64_LABEL_1403
    CASE 1405: GOTO vwatch64_LABEL_1405
    CASE 1406: GOTO vwatch64_LABEL_1406
    CASE 1407: GOTO vwatch64_LABEL_1407
    CASE 1408: GOTO vwatch64_LABEL_1408
    CASE 1409: GOTO vwatch64_LABEL_1409
    CASE 1410: GOTO vwatch64_LABEL_1410
    CASE 1411: GOTO vwatch64_LABEL_1411
    CASE 1412: GOTO vwatch64_LABEL_1412
    CASE 1413: GOTO vwatch64_LABEL_1413
    CASE 1414: GOTO vwatch64_LABEL_1414
    CASE 1416: GOTO vwatch64_LABEL_1416
    CASE 1417: GOTO vwatch64_LABEL_1417
    CASE 1418: GOTO vwatch64_LABEL_1418
    CASE 1420: GOTO vwatch64_LABEL_1420
    CASE 1422: GOTO vwatch64_LABEL_1422
    CASE 1423: GOTO vwatch64_LABEL_1423
    CASE 1424: GOTO vwatch64_LABEL_1424
    CASE 1426: GOTO vwatch64_LABEL_1426
    CASE 1427: GOTO vwatch64_LABEL_1427
    CASE 1428: GOTO vwatch64_LABEL_1428
    CASE 1429: GOTO vwatch64_LABEL_1429
    CASE 1430: GOTO vwatch64_LABEL_1430
    CASE 1431: GOTO vwatch64_LABEL_1431
    CASE 1433: GOTO vwatch64_LABEL_1433
    CASE 1434: GOTO vwatch64_LABEL_1434
    CASE 1435: GOTO vwatch64_LABEL_1435
    CASE 1436: GOTO vwatch64_LABEL_1436
    CASE 1437: GOTO vwatch64_LABEL_1437
    CASE 1438: GOTO vwatch64_LABEL_1438
    CASE 1440: GOTO vwatch64_LABEL_1440
    CASE 1443: GOTO vwatch64_LABEL_1443
    CASE 1444: GOTO vwatch64_LABEL_1444
    CASE 1445: GOTO vwatch64_LABEL_1445
    CASE 1446: GOTO vwatch64_LABEL_1446
    CASE 1447: GOTO vwatch64_LABEL_1447
    CASE 1448: GOTO vwatch64_LABEL_1448
    CASE 1449: GOTO vwatch64_LABEL_1449
    CASE 1450: GOTO vwatch64_LABEL_1450
    CASE 1451: GOTO vwatch64_LABEL_1451
    CASE 1452: GOTO vwatch64_LABEL_1452
    CASE 1453: GOTO vwatch64_LABEL_1453
    CASE 1455: GOTO vwatch64_LABEL_1455
    CASE 1456: GOTO vwatch64_LABEL_1456
    CASE 1457: GOTO vwatch64_LABEL_1457
    CASE 1458: GOTO vwatch64_LABEL_1458
    CASE 1459: GOTO vwatch64_LABEL_1459
    CASE 1460: GOTO vwatch64_LABEL_1460
    CASE 1461: GOTO vwatch64_LABEL_1461
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_while
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1464:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1464): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1464 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1464
    debuginfo "Start WHILE block"
vwatch64_SKIP_1464:::: 
vwatch64_LABEL_1465:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1465): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1465 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1465
    root = ast_add_node(AST_DO_PRE)
vwatch64_SKIP_1465:::: 
vwatch64_LABEL_1466:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1466): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1466 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1466
    ast_attach root, ps_expr
vwatch64_SKIP_1466:::: 
vwatch64_LABEL_1467:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1467): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1467 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1467
    ps_assert_token tok_next_token, TOK_NEWLINE
vwatch64_SKIP_1467:::: 
vwatch64_LABEL_1468:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1468): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1468 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1468
    ast_attach root, ps_block
vwatch64_SKIP_1468:::: 
vwatch64_LABEL_1469:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1469): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1469 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1469
    ps_assert_token tok_next_token, TOK_WEND
vwatch64_SKIP_1469:::: 
vwatch64_LABEL_1470:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1470): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1470 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1470
    ps_while = root
vwatch64_SKIP_1470:::: 
vwatch64_LABEL_1471:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1471): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1471
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1464: GOTO vwatch64_LABEL_1464
    CASE 1465: GOTO vwatch64_LABEL_1465
    CASE 1466: GOTO vwatch64_LABEL_1466
    CASE 1467: GOTO vwatch64_LABEL_1467
    CASE 1468: GOTO vwatch64_LABEL_1468
    CASE 1469: GOTO vwatch64_LABEL_1469
    CASE 1470: GOTO vwatch64_LABEL_1470
    CASE 1471: GOTO vwatch64_LABEL_1471
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_do
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1474:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1474): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1474 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1474
    debuginfo "Start DO block"
vwatch64_SKIP_1474:::: 
vwatch64_LABEL_1475:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1475): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1475 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1475
    check = tok_next_token
vwatch64_SKIP_1475:::: 
vwatch64_LABEL_1476:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1476): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1476 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1476
    if check = TOK_WHILE or check = TOK_UNTIL then
vwatch64_SKIP_1476:::: 
vwatch64_LABEL_1477:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1477): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1477 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1477
        ps_do = ps_do_pre(check)
vwatch64_SKIP_1477:::: 
vwatch64_LABEL_1478:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1478): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1478 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1478
    elseif check = TOK_NEWLINE then
vwatch64_SKIP_1478:::: 
vwatch64_LABEL_1479:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1479): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1479 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1479
        ps_do = ps_do_post
vwatch64_SKIP_1479:::: 
vwatch64_LABEL_1480:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1480): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1480 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1480
    else
vwatch64_SKIP_1480:::: 
vwatch64_LABEL_1481:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1481): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1481 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1481
        fatalerror "Unexpected " + tok_content$
vwatch64_SKIP_1481:::: 
vwatch64_LABEL_1482:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1482): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1482 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1482
    end if
vwatch64_SKIP_1482:::: 
vwatch64_LABEL_1483:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1483): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1483 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1483
    debuginfo "Completed DO block"
vwatch64_SKIP_1483:::: 
vwatch64_LABEL_1484:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1484): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1484
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1474: GOTO vwatch64_LABEL_1474
    CASE 1475: GOTO vwatch64_LABEL_1475
    CASE 1476: GOTO vwatch64_LABEL_1476
    CASE 1477: GOTO vwatch64_LABEL_1477
    CASE 1478: GOTO vwatch64_LABEL_1478
    CASE 1479: GOTO vwatch64_LABEL_1479
    CASE 1480: GOTO vwatch64_LABEL_1480
    CASE 1481: GOTO vwatch64_LABEL_1481
    CASE 1482: GOTO vwatch64_LABEL_1482
    CASE 1483: GOTO vwatch64_LABEL_1483
    CASE 1484: GOTO vwatch64_LABEL_1484
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_do_pre(check)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1487:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1487): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1487 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1487
    debuginfo "Start DO-PRE"
vwatch64_SKIP_1487:::: 
vwatch64_LABEL_1488:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1488): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1488 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1488
    root = ast_add_node(AST_DO_PRE)
vwatch64_SKIP_1488:::: 
vwatch64_LABEL_1489:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1489): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1489 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1489
    ast_attach root, ps_loop_guard_expr(check)
vwatch64_SKIP_1489:::: 
vwatch64_LABEL_1490:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1490): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1490 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1490
    ps_assert_token tok_next_token, TOK_NEWLINE
vwatch64_SKIP_1490:::: 
vwatch64_LABEL_1491:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1491): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1491 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1491
    ast_attach root, ps_block
vwatch64_SKIP_1491:::: 
vwatch64_LABEL_1492:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1492): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1492 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1492
    ps_assert_token tok_next_token, TOK_LOOP
vwatch64_SKIP_1492:::: 
vwatch64_LABEL_1493:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1493): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1493 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1493
    ps_do_pre = root
vwatch64_SKIP_1493:::: 
vwatch64_LABEL_1494:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1494): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1494 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1494
    debuginfo "Completed DO-PRE"
vwatch64_SKIP_1494:::: 
vwatch64_LABEL_1495:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1495): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1495
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1487: GOTO vwatch64_LABEL_1487
    CASE 1488: GOTO vwatch64_LABEL_1488
    CASE 1489: GOTO vwatch64_LABEL_1489
    CASE 1490: GOTO vwatch64_LABEL_1490
    CASE 1491: GOTO vwatch64_LABEL_1491
    CASE 1492: GOTO vwatch64_LABEL_1492
    CASE 1493: GOTO vwatch64_LABEL_1493
    CASE 1494: GOTO vwatch64_LABEL_1494
    CASE 1495: GOTO vwatch64_LABEL_1495
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_loop_guard_expr(check)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    'Condition is WHILE guard; UNTIL will need the guard to be negated
vwatch64_LABEL_1499:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1499): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1499 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1499
    raw_guard = ps_expr
vwatch64_SKIP_1499:::: 
vwatch64_LABEL_1500:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1500): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1500 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1500
    guard_type = type_of_expr(raw_guard)
vwatch64_SKIP_1500:::: 
vwatch64_LABEL_1501:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1501): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1501 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1501
    if not type_is_number(guard_type) then fatalerror "Loop guard must be a numeric expression"
vwatch64_SKIP_1501:::: 
vwatch64_LABEL_1502:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1502): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1502 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1502
    if check = TOK_UNTIL then
vwatch64_SKIP_1502:::: 
vwatch64_LABEL_1503:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1503): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1503 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1503
        guard = ast_add_node(AST_CALL)
vwatch64_SKIP_1503:::: 
vwatch64_LABEL_1504:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1504): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1504 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1504
        ast_nodes(guard).ref = TOK_EQUALS
vwatch64_SKIP_1504:::: 
vwatch64_LABEL_1505:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1505): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1505 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1505
        false_const = ast_add_node(AST_CONSTANT)
vwatch64_SKIP_1505:::: 
vwatch64_LABEL_1506:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1506): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1506 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1506
        false_const.ref = AST_FALSE
vwatch64_SKIP_1506:::: 
vwatch64_LABEL_1507:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1507): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1507 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1507
        ast_attach guard, ast_add_cast(false_const, guard_type)
vwatch64_SKIP_1507:::: 
vwatch64_LABEL_1508:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1508): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1508 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1508
        ast_attach guard, raw_guard
vwatch64_SKIP_1508:::: 
vwatch64_LABEL_1509:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1509): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1509 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1509
        sig$ = type_sig_add_arg$(type_sig_add_arg$("", guard_type, 0), guard_type, 0)
vwatch64_SKIP_1509:::: 
vwatch64_LABEL_1510:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1510): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1510 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1510
        ast_nodes(guard).ref2 = type_find_sig_match(TOK_EQUALS, sig$)
vwatch64_SKIP_1510:::: 
vwatch64_LABEL_1511:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1511): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1511 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1511
    elseif check = TOK_WHILE then
vwatch64_SKIP_1511:::: 
vwatch64_LABEL_1512:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1512): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1512 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1512
        guard = raw_guard
vwatch64_SKIP_1512:::: 
vwatch64_LABEL_1513:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1513): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1513 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1513
    else
vwatch64_SKIP_1513:::: 
vwatch64_LABEL_1514:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1514): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1514 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1514
        fatalerror "Unexpected " + tok_content$
vwatch64_SKIP_1514:::: 
vwatch64_LABEL_1515:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1515): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1515 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1515
    end if
vwatch64_SKIP_1515:::: 
vwatch64_LABEL_1516:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1516): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1516 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1516
    ps_loop_guard_expr = guard
vwatch64_SKIP_1516:::: 
vwatch64_LABEL_1517:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1517): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1517
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1499: GOTO vwatch64_LABEL_1499
    CASE 1500: GOTO vwatch64_LABEL_1500
    CASE 1501: GOTO vwatch64_LABEL_1501
    CASE 1502: GOTO vwatch64_LABEL_1502
    CASE 1503: GOTO vwatch64_LABEL_1503
    CASE 1504: GOTO vwatch64_LABEL_1504
    CASE 1505: GOTO vwatch64_LABEL_1505
    CASE 1506: GOTO vwatch64_LABEL_1506
    CASE 1507: GOTO vwatch64_LABEL_1507
    CASE 1508: GOTO vwatch64_LABEL_1508
    CASE 1509: GOTO vwatch64_LABEL_1509
    CASE 1510: GOTO vwatch64_LABEL_1510
    CASE 1511: GOTO vwatch64_LABEL_1511
    CASE 1512: GOTO vwatch64_LABEL_1512
    CASE 1513: GOTO vwatch64_LABEL_1513
    CASE 1514: GOTO vwatch64_LABEL_1514
    CASE 1515: GOTO vwatch64_LABEL_1515
    CASE 1516: GOTO vwatch64_LABEL_1516
    CASE 1517: GOTO vwatch64_LABEL_1517
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_do_post
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1520:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1520): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1520 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1520
    debuginfo "Start DO-POST"
vwatch64_SKIP_1520:::: 
vwatch64_LABEL_1521:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1521): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1521 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1521
    root = ast_add_node(AST_DO_POST)
vwatch64_SKIP_1521:::: 
vwatch64_LABEL_1522:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1522): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1522 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1522
    block = ps_block
vwatch64_SKIP_1522:::: 
vwatch64_LABEL_1523:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1523): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1523 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1523
    ps_assert_token tok_next_token, TOK_LOOP
vwatch64_SKIP_1523:::: 

vwatch64_LABEL_1525:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1525): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1525 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1525
    check = tok_next_token
vwatch64_SKIP_1525:::: 
vwatch64_LABEL_1526:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1526): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1526 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1526
    if check = TOK_NEWLINE then
vwatch64_SKIP_1526:::: 
        'Oh boy, infinite loop!
vwatch64_LABEL_1528:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1528): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1528 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1528
        guard = ast_add_node(AST_CONSTANT)
vwatch64_SKIP_1528:::: 
vwatch64_LABEL_1529:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1529): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1529 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1529
        ast_nodes(guard).ref = AST_TRUE
vwatch64_SKIP_1529:::: 
vwatch64_LABEL_1530:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1530): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1530 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1530
    else
vwatch64_SKIP_1530:::: 
vwatch64_LABEL_1531:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1531): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1531 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1531
        guard = ps_loop_guard_expr(check)
vwatch64_SKIP_1531:::: 
vwatch64_LABEL_1532:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1532): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1532 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1532
    end if
vwatch64_SKIP_1532:::: 
vwatch64_LABEL_1533:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1533): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1533 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1533
    ast_attach root, guard
vwatch64_SKIP_1533:::: 
vwatch64_LABEL_1534:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1534): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1534 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1534
    ast_attach root, block
vwatch64_SKIP_1534:::: 
vwatch64_LABEL_1535:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1535): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1535 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1535
    ps_do_post = root
vwatch64_SKIP_1535:::: 
vwatch64_LABEL_1536:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1536): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1536 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1536
    debuginfo "Completed DO-POST"
vwatch64_SKIP_1536:::: 
vwatch64_LABEL_1537:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1537): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1537
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1520: GOTO vwatch64_LABEL_1520
    CASE 1521: GOTO vwatch64_LABEL_1521
    CASE 1522: GOTO vwatch64_LABEL_1522
    CASE 1523: GOTO vwatch64_LABEL_1523
    CASE 1525: GOTO vwatch64_LABEL_1525
    CASE 1526: GOTO vwatch64_LABEL_1526
    CASE 1528: GOTO vwatch64_LABEL_1528
    CASE 1529: GOTO vwatch64_LABEL_1529
    CASE 1530: GOTO vwatch64_LABEL_1530
    CASE 1531: GOTO vwatch64_LABEL_1531
    CASE 1532: GOTO vwatch64_LABEL_1532
    CASE 1533: GOTO vwatch64_LABEL_1533
    CASE 1534: GOTO vwatch64_LABEL_1534
    CASE 1535: GOTO vwatch64_LABEL_1535
    CASE 1536: GOTO vwatch64_LABEL_1536
    CASE 1537: GOTO vwatch64_LABEL_1537
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_if
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1540:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1540): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1540 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1540
    debuginfo "Start conditional"
vwatch64_SKIP_1540:::: 
vwatch64_LABEL_1541:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1541): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1541 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1541
    root = ast_add_node(AST_IF)
vwatch64_SKIP_1541:::: 
vwatch64_LABEL_1542:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1542): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1542 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1542
    condition = ps_expr
vwatch64_SKIP_1542:::: 
vwatch64_LABEL_1543:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1543): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1543 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1543
    if not type_is_number(type_of_expr(condition)) then fatalerror "IF condition must be a numeric expression"
vwatch64_SKIP_1543:::: 
vwatch64_LABEL_1544:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1544): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1544 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1544
    ast_attach root, condition
vwatch64_SKIP_1544:::: 
vwatch64_LABEL_1545:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1545): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1545 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1545
    ps_assert_token tok_next_token, TOK_THEN
vwatch64_SKIP_1545:::: 

vwatch64_LABEL_1547:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1547): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1547 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1547
    token = tok_next_token
vwatch64_SKIP_1547:::: 
vwatch64_LABEL_1548:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1548): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1548 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1548
    if token = TOK_NEWLINE then 'Multi-line if
vwatch64_SKIP_1548:::: 
vwatch64_LABEL_1549:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1549): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1549 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1549
        ast_attach root, ps_block
vwatch64_SKIP_1549:::: 
vwatch64_LABEL_1550:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1550): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1550 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1550
        t = tok_next_token
vwatch64_SKIP_1550:::: 
vwatch64_LABEL_1551:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1551): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1551 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1551
        if t = TOK_ELSE then
vwatch64_SKIP_1551:::: 
vwatch64_LABEL_1552:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1552): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1552 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1552
            ps_assert_token tok_next_token, TOK_NEWLINE
vwatch64_SKIP_1552:::: 
vwatch64_LABEL_1553:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1553): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1553 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1553
            ast_attach root, ps_block
vwatch64_SKIP_1553:::: 
vwatch64_LABEL_1554:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1554): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1554 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1554
            t = tok_next_token
vwatch64_SKIP_1554:::: 
vwatch64_LABEL_1555:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1555): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1555 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1555
        end if
vwatch64_SKIP_1555:::: 
        'END IF, with the END being eaten by ps_block
vwatch64_LABEL_1557:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1557): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1557 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1557
        ps_assert_token t, TOK_IF
vwatch64_SKIP_1557:::: 
vwatch64_LABEL_1558:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1558): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1558 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1558
    else
vwatch64_SKIP_1558:::: 
vwatch64_LABEL_1559:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1559): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1559 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1559
        tok_please_repeat
vwatch64_SKIP_1559:::: 
vwatch64_LABEL_1560:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1560): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1560 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1560
        ast_attach root, ps_stmt
vwatch64_SKIP_1560:::: 
vwatch64_LABEL_1561:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1561): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1561 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1561
        ps_assert_token tok_next_token, TOK_NEWLINE
vwatch64_SKIP_1561:::: 
vwatch64_LABEL_1562:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1562): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1562 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1562
    end if
vwatch64_SKIP_1562:::: 
vwatch64_LABEL_1563:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1563): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1563 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1563
    ps_if = root
vwatch64_SKIP_1563:::: 
vwatch64_LABEL_1564:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1564): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1564 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1564
    debuginfo "Completed conditional"
vwatch64_SKIP_1564:::: 
vwatch64_LABEL_1565:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1565): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1565
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1540: GOTO vwatch64_LABEL_1540
    CASE 1541: GOTO vwatch64_LABEL_1541
    CASE 1542: GOTO vwatch64_LABEL_1542
    CASE 1543: GOTO vwatch64_LABEL_1543
    CASE 1544: GOTO vwatch64_LABEL_1544
    CASE 1545: GOTO vwatch64_LABEL_1545
    CASE 1547: GOTO vwatch64_LABEL_1547
    CASE 1548: GOTO vwatch64_LABEL_1548
    CASE 1549: GOTO vwatch64_LABEL_1549
    CASE 1550: GOTO vwatch64_LABEL_1550
    CASE 1551: GOTO vwatch64_LABEL_1551
    CASE 1552: GOTO vwatch64_LABEL_1552
    CASE 1553: GOTO vwatch64_LABEL_1553
    CASE 1554: GOTO vwatch64_LABEL_1554
    CASE 1555: GOTO vwatch64_LABEL_1555
    CASE 1557: GOTO vwatch64_LABEL_1557
    CASE 1558: GOTO vwatch64_LABEL_1558
    CASE 1559: GOTO vwatch64_LABEL_1559
    CASE 1560: GOTO vwatch64_LABEL_1560
    CASE 1561: GOTO vwatch64_LABEL_1561
    CASE 1562: GOTO vwatch64_LABEL_1562
    CASE 1563: GOTO vwatch64_LABEL_1563
    CASE 1564: GOTO vwatch64_LABEL_1564
    CASE 1565: GOTO vwatch64_LABEL_1565
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function
    
function ps_assignment(ref)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1568:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1568): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1568 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1568
    debuginfo "Start assignment"
vwatch64_SKIP_1568:::: 
vwatch64_LABEL_1569:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1569): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1569 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1569
    root = ast_add_node(AST_ASSIGN)
vwatch64_SKIP_1569:::: 
vwatch64_LABEL_1570:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1570): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1570 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1570
    ast_nodes(root).ref = ref
vwatch64_SKIP_1570:::: 
vwatch64_LABEL_1571:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1571): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1571 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1571
    ps_assert_token tok_next_token, TOK_EQUALS
vwatch64_SKIP_1571:::: 
vwatch64_LABEL_1572:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1572): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1572 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1572
    expr = ps_expr
vwatch64_SKIP_1572:::: 
vwatch64_LABEL_1573:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1573): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1573 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1573
    lvalue_type = htable_entries(ref).v1
vwatch64_SKIP_1573:::: 
vwatch64_LABEL_1574:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1574): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1574 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1574
    rvalue_type = type_of_expr(expr)
vwatch64_SKIP_1574:::: 
vwatch64_LABEL_1575:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1575): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1575 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1575
    if not type_can_cast(lvalue_type, rvalue_type) then fatalerror "Type of variable in assignment does not match value being assigned"
vwatch64_SKIP_1575:::: 
vwatch64_LABEL_1576:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1576): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1576 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1576
    expr = ast_add_cast(expr, lvalue_type)
vwatch64_SKIP_1576:::: 
vwatch64_LABEL_1577:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1577): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1577 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1577
    ast_attach root, expr
vwatch64_SKIP_1577:::: 
vwatch64_LABEL_1578:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1578): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1578 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1578
    ps_assignment = root
vwatch64_SKIP_1578:::: 
vwatch64_LABEL_1579:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1579): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1579 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1579
    ps_assert_token tok_next_token, TOK_NEWLINE
vwatch64_SKIP_1579:::: 
vwatch64_LABEL_1580:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1580): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1580 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1580
    debuginfo "Completed assignment"
vwatch64_SKIP_1580:::: 
vwatch64_LABEL_1581:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1581): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1581
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1568: GOTO vwatch64_LABEL_1568
    CASE 1569: GOTO vwatch64_LABEL_1569
    CASE 1570: GOTO vwatch64_LABEL_1570
    CASE 1571: GOTO vwatch64_LABEL_1571
    CASE 1572: GOTO vwatch64_LABEL_1572
    CASE 1573: GOTO vwatch64_LABEL_1573
    CASE 1574: GOTO vwatch64_LABEL_1574
    CASE 1575: GOTO vwatch64_LABEL_1575
    CASE 1576: GOTO vwatch64_LABEL_1576
    CASE 1577: GOTO vwatch64_LABEL_1577
    CASE 1578: GOTO vwatch64_LABEL_1578
    CASE 1579: GOTO vwatch64_LABEL_1579
    CASE 1580: GOTO vwatch64_LABEL_1580
    CASE 1581: GOTO vwatch64_LABEL_1581
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_expr
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1584:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1584): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1584 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1584
    debuginfo "Start expr"
vwatch64_SKIP_1584:::: 
vwatch64_LABEL_1585:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1585): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1585 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1585
    pt_token = tok_next_token
vwatch64_SKIP_1585:::: 
vwatch64_LABEL_1586:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1586): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1586 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1586
    pt_content$ = tok_content$
vwatch64_SKIP_1586:::: 
vwatch64_LABEL_1587:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1587): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1587 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1587
    ps_expr = pt_expr(0)
vwatch64_SKIP_1587:::: 
vwatch64_LABEL_1588:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1588): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1588 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1588
    tok_please_repeat
vwatch64_SKIP_1588:::: 
vwatch64_LABEL_1589:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1589): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1589 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1589
    debuginfo "Completed expr"
vwatch64_SKIP_1589:::: 
vwatch64_LABEL_1590:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1590): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1590
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1584: GOTO vwatch64_LABEL_1584
    CASE 1585: GOTO vwatch64_LABEL_1585
    CASE 1586: GOTO vwatch64_LABEL_1586
    CASE 1587: GOTO vwatch64_LABEL_1587
    CASE 1588: GOTO vwatch64_LABEL_1588
    CASE 1589: GOTO vwatch64_LABEL_1589
    CASE 1590: GOTO vwatch64_LABEL_1590
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function
        
function ps_stmtreg
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1593:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1593): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1593 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1593
    debuginfo "Start stmtreg"
vwatch64_SKIP_1593:::: 
vwatch64_LABEL_1594:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1594): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1594 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1594
    root = ast_add_node(AST_CALL)
vwatch64_SKIP_1594:::: 
vwatch64_LABEL_1595:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1595): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1595 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1595
    token = tok_next_token
vwatch64_SKIP_1595:::: 
vwatch64_LABEL_1596:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1596): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1596 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1596
    ast_nodes(root).ref = htable_entries(token).id
vwatch64_SKIP_1596:::: 

vwatch64_LABEL_1598:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1598): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1598 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1598
    ps_funcargs root
vwatch64_SKIP_1598:::: 

vwatch64_LABEL_1600:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1600): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1600 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1600
    ps_stmtreg = root
vwatch64_SKIP_1600:::: 
vwatch64_LABEL_1601:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1601): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1601 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1601
    debuginfo "Completed stmtreg"
vwatch64_SKIP_1601:::: 
vwatch64_LABEL_1602:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1602): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1602
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1593: GOTO vwatch64_LABEL_1593
    CASE 1594: GOTO vwatch64_LABEL_1594
    CASE 1595: GOTO vwatch64_LABEL_1595
    CASE 1596: GOTO vwatch64_LABEL_1596
    CASE 1598: GOTO vwatch64_LABEL_1598
    CASE 1600: GOTO vwatch64_LABEL_1600
    CASE 1601: GOTO vwatch64_LABEL_1601
    CASE 1602: GOTO vwatch64_LABEL_1602
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function ps_funccall(func)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1605:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1605): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1605 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1605
    debuginfo "Start function call"
vwatch64_SKIP_1605:::: 
vwatch64_LABEL_1606:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1606): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1606 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1606
    root = ast_add_node(AST_CALL)
vwatch64_SKIP_1606:::: 
vwatch64_LABEL_1607:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1607): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1607 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1607
    ast_nodes(root).ref = func
vwatch64_SKIP_1607:::: 
vwatch64_LABEL_1608:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1608): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1608 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1608
    sigil = ps_opt_sigil(0)
vwatch64_SKIP_1608:::: 
    'dummy = ps_opt_sigil(type_of_call(root))
vwatch64_LABEL_1610:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1610): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1610 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1610
    t = tok_next_token
vwatch64_SKIP_1610:::: 
vwatch64_LABEL_1611:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1611): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1611 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1611
    if t = TOK_OPAREN then
vwatch64_SKIP_1611:::: 
vwatch64_LABEL_1612:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1612): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1612 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1612
        ps_funcargs root
vwatch64_SKIP_1612:::: 
vwatch64_LABEL_1613:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1613): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1613 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1613
        ps_assert_token tok_next_token, TOK_CPAREN
vwatch64_SKIP_1613:::: 
vwatch64_LABEL_1614:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1614): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1614 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1614
    else
vwatch64_SKIP_1614:::: 
        'No arguments
vwatch64_LABEL_1616:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1616): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1616 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1616
        tok_please_repeat
vwatch64_SKIP_1616:::: 
vwatch64_LABEL_1617:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1617): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1617 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1617
    end if
vwatch64_SKIP_1617:::: 
vwatch64_LABEL_1618:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1618): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1618 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1618
    if sigil > 0 and sigil <> type_of_call(root) then fatalerror "Function must have correct type suffix if present"
vwatch64_SKIP_1618:::: 
vwatch64_LABEL_1619:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1619): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1619 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1619
    ps_funccall = root
vwatch64_SKIP_1619:::: 
vwatch64_LABEL_1620:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1620): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1620 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1620
    debuginfo "Completed function call"
vwatch64_SKIP_1620:::: 
vwatch64_LABEL_1621:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1621): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1621
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1605: GOTO vwatch64_LABEL_1605
    CASE 1606: GOTO vwatch64_LABEL_1606
    CASE 1607: GOTO vwatch64_LABEL_1607
    CASE 1608: GOTO vwatch64_LABEL_1608
    CASE 1610: GOTO vwatch64_LABEL_1610
    CASE 1611: GOTO vwatch64_LABEL_1611
    CASE 1612: GOTO vwatch64_LABEL_1612
    CASE 1613: GOTO vwatch64_LABEL_1613
    CASE 1614: GOTO vwatch64_LABEL_1614
    CASE 1616: GOTO vwatch64_LABEL_1616
    CASE 1617: GOTO vwatch64_LABEL_1617
    CASE 1618: GOTO vwatch64_LABEL_1618
    CASE 1619: GOTO vwatch64_LABEL_1619
    CASE 1620: GOTO vwatch64_LABEL_1620
    CASE 1621: GOTO vwatch64_LABEL_1621
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

sub ps_funcargs(root)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1624:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1624): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1624 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1624
    debuginfo "Start funcargs"
vwatch64_SKIP_1624:::: 
    'This code first builds a candidate type signature, then tries to match that against an instance signature.
vwatch64_LABEL_1626:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1626): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1626 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1626
    func = ast_nodes(root).ref
vwatch64_SKIP_1626:::: 
vwatch64_LABEL_1627:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1627): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1627 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1627
    do
vwatch64_SKIP_1627:::: 
vwatch64_LABEL_1628:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1628): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1628 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1628
        t = tok_next_token
vwatch64_SKIP_1628:::: 
vwatch64_LABEL_1629:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1629): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1629 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1629
        select case t
vwatch64_SKIP_1629:::: 
        case TOK_CPAREN, TOK_NEWLINE
            'End of the argument list
vwatch64_LABEL_1632:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1632): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1632 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1632
            tok_please_repeat
vwatch64_SKIP_1632:::: 
vwatch64_LABEL_1633:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1633): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1633 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1633
            exit do
vwatch64_SKIP_1633:::: 
        case else
vwatch64_LABEL_1635:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1635): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1635 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1635
            tok_please_repeat
vwatch64_SKIP_1635:::: 
vwatch64_LABEL_1636:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1636): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1636 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1636
            ps_funcarg root, candidate$
vwatch64_SKIP_1636:::: 
        end select
vwatch64_LABEL_1638:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1638): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1638 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1638
    loop
vwatch64_SKIP_1638:::: 
    'Now we need to find a signature of func that matches candidate$.
vwatch64_LABEL_1640:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1640): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1640 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1640
    matching_sig = type_find_sig_match(func, candidate$)
vwatch64_SKIP_1640:::: 
vwatch64_LABEL_1641:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1641): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1641 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1641
    if matching_sig = 0 then fatalerror "Cannot find matching type signature"
vwatch64_SKIP_1641:::: 
vwatch64_LABEL_1642:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1642): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1642 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1642
    ast_nodes(root).ref2 = matching_sig
vwatch64_SKIP_1642:::: 
    'Modify argument nodes to add in casts where needed
vwatch64_LABEL_1644:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1644): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1644 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1644
    for i = 1 to ast_num_children(root)
vwatch64_SKIP_1644:::: 
vwatch64_LABEL_1645:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1645): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1645 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1645
        expr = ast_get_child(root, i)
vwatch64_SKIP_1645:::: 
vwatch64_LABEL_1646:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1646): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1646 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1646
        expr_type = type_of_expr(expr)
vwatch64_SKIP_1646:::: 
vwatch64_LABEL_1647:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1647): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1647 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1647
        arg_type = type_sig_argtype(matching_sig, i)
vwatch64_SKIP_1647:::: 
vwatch64_LABEL_1648:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1648): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1648 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1648
        if expr_type <> arg_type then
vwatch64_SKIP_1648:::: 
vwatch64_LABEL_1649:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1649): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1649 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1649
            ast_replace_child root, i, ast_add_cast(expr, arg_type)
vwatch64_SKIP_1649:::: 
vwatch64_LABEL_1650:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1650): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1650 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1650
        end if
vwatch64_SKIP_1650:::: 
vwatch64_LABEL_1651:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1651): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1651 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1651
    next i
vwatch64_SKIP_1651:::: 
vwatch64_LABEL_1652:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1652): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1652 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1652
    debuginfo "Completed funcargs"
vwatch64_SKIP_1652:::: 
vwatch64_LABEL_1653:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1653): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1653
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1624: GOTO vwatch64_LABEL_1624
    CASE 1626: GOTO vwatch64_LABEL_1626
    CASE 1627: GOTO vwatch64_LABEL_1627
    CASE 1628: GOTO vwatch64_LABEL_1628
    CASE 1629: GOTO vwatch64_LABEL_1629
    CASE 1632: GOTO vwatch64_LABEL_1632
    CASE 1633: GOTO vwatch64_LABEL_1633
    CASE 1635: GOTO vwatch64_LABEL_1635
    CASE 1636: GOTO vwatch64_LABEL_1636
    CASE 1638: GOTO vwatch64_LABEL_1638
    CASE 1640: GOTO vwatch64_LABEL_1640
    CASE 1641: GOTO vwatch64_LABEL_1641
    CASE 1642: GOTO vwatch64_LABEL_1642
    CASE 1644: GOTO vwatch64_LABEL_1644
    CASE 1645: GOTO vwatch64_LABEL_1645
    CASE 1646: GOTO vwatch64_LABEL_1646
    CASE 1647: GOTO vwatch64_LABEL_1647
    CASE 1648: GOTO vwatch64_LABEL_1648
    CASE 1649: GOTO vwatch64_LABEL_1649
    CASE 1650: GOTO vwatch64_LABEL_1650
    CASE 1651: GOTO vwatch64_LABEL_1651
    CASE 1652: GOTO vwatch64_LABEL_1652
    CASE 1653: GOTO vwatch64_LABEL_1653
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub ps_funcarg(root, candidate$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1656:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1656): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1656 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1656
    debuginfo "Start funcarg"
vwatch64_SKIP_1656:::: 
vwatch64_LABEL_1657:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1657): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1657 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1657
    expr = ps_expr
vwatch64_SKIP_1657:::: 
    'Declare whether this expression would satisfy a BYREF argument
vwatch64_LABEL_1659:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1659): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1659 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1659
    if ast_nodes(expr).typ = AST_VAR then flags = TYPE_BYREF
vwatch64_SKIP_1659:::: 
vwatch64_LABEL_1660:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1660): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1660 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1660
    candidate$ = type_sig_add_arg$(candidate$, type_of_expr(expr), flags)
vwatch64_SKIP_1660:::: 
vwatch64_LABEL_1661:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1661): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1661 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1661
    ast_attach root, expr
vwatch64_SKIP_1661:::: 
vwatch64_LABEL_1662:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1662): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1662 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1662
    debuginfo "Completed funcarg"
vwatch64_SKIP_1662:::: 
vwatch64_LABEL_1663:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1663): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1663
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1656: GOTO vwatch64_LABEL_1656
    CASE 1657: GOTO vwatch64_LABEL_1657
    CASE 1659: GOTO vwatch64_LABEL_1659
    CASE 1660: GOTO vwatch64_LABEL_1660
    CASE 1661: GOTO vwatch64_LABEL_1661
    CASE 1662: GOTO vwatch64_LABEL_1662
    CASE 1663: GOTO vwatch64_LABEL_1663
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

'    dim sig as type_signature_t
'    func = ast_nodes(root).ref
'    type_return_sig func, sig
'    if type_next_sig(sig) then
'        arg_count = 1
'        do
'$if DEBUG then            
'            print "Argument"; arg_count; ":"
'$endif            
'            t = tok_next_token
'$if DEBUG then            
'            print ">>"; tok_human_readable$(t)
'$endif            
'            select case t
'            case TOK_CPAREN, TOK_NEWLINE
'                'Pack up folks, end of the arg list.
'                if arg_count > ast_num_children(root) then
'                    if sig.flags AND TYPE_REQUIRED then fatalerror "Argument cannot be omitted"
'                    arg = ast_add_node(AST_CONSTANT)
'                    ast_nodes(arg).ref = AST_NONE
'                    ast_attach root, arg
'                end if
'                tok_please_repeat
'                exit do
'            case TOK_COMMA
'                if arg_count > ast_num_children(root) then
'                    if sig.flags AND TYPE_REQUIRED then fatalerror "Argument cannot be omitted"
'                    arg = ast_add_node(AST_CONSTANT)
'                    ast_nodes(arg).ref = AST_NONE
'                    ast_attach root, arg
'                end if
'                arg_count = arg_count + 1
'                if type_next_sig(sig) = 0 then fatalerror "More arguments than expected"
'            case else
'                tok_please_repeat
'                ps_funcarg root, sig
'            end select
'        loop
'        'Fill in any extra arguments if they were omitted
'        while type_next_sig(sig)
'            if sig.flags AND TYPE_REQUIRED then fatalerror "A required argument was not supplied"
'            arg = ast_add_node(AST_CONSTANT)
'            ast_nodes(arg).ref = AST_NONE
'            ast_attach root, arg
'        wend
'    end if
'$if DEBUG then    
'    print "Completed funcargs"
'$endif    
'end sub

function ps_variable(token, content$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1717:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1717): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1717 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1717
    debuginfo "Start variable"
vwatch64_SKIP_1717:::: 
    dim he as hentry_t
    'Do array & udt element stuff here.
    'For now only support simple variables.
  
    'New variable?
vwatch64_LABEL_1723:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1723): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1723 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1723
    if token = TOK_UNKNOWN then
vwatch64_SKIP_1723:::: 
vwatch64_LABEL_1724:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1724): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1724 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1724
        he.typ = HE_VARIABLE
vwatch64_SKIP_1724:::: 
vwatch64_LABEL_1725:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1725): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1725 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1725
        htable_add_hentry ucase$(content$), he
vwatch64_SKIP_1725:::: 
vwatch64_LABEL_1726:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1726): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1726 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1726
        var = htable_last_id
vwatch64_SKIP_1726:::: 
vwatch64_LABEL_1727:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1727): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1727 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1727
        htable_entries(var).v1 = TYPE_SINGLE
vwatch64_SKIP_1727:::: 
vwatch64_LABEL_1728:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1728): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1728 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1728
        ps_last_var_index = ps_last_var_index + 1
vwatch64_SKIP_1728:::: 
vwatch64_LABEL_1729:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1729): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1729 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1729
        htable_entries(var).v2 = ps_last_var_index
vwatch64_SKIP_1729:::: 
vwatch64_LABEL_1730:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1730): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1730 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1730
    else
vwatch64_SKIP_1730:::: 
vwatch64_LABEL_1731:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1731): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1731 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1731
        var = token
vwatch64_SKIP_1731:::: 
vwatch64_LABEL_1732:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1732): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1732 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1732
    end if
vwatch64_SKIP_1732:::: 
    'Check for type sigil
vwatch64_LABEL_1734:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1734): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1734 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1734
    sigil = ps_opt_sigil(0)
vwatch64_SKIP_1734:::: 
vwatch64_LABEL_1735:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1735): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1735 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1735
    if sigil then
vwatch64_SKIP_1735:::: 
vwatch64_LABEL_1736:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1736): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1736 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1736
        if token <> TOK_UNKNOWN and sigil <> htable_entries(var).v1 then fatalerror "Type suffix does not match existing variable type"
vwatch64_SKIP_1736:::: 
        'Otherwise it's a new variable; set its type
vwatch64_LABEL_1738:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1738): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1738 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1738
        htable_entries(var).v1 = sigil
vwatch64_SKIP_1738:::: 
vwatch64_LABEL_1739:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1739): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1739 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1739
    end if
vwatch64_SKIP_1739:::: 
vwatch64_LABEL_1740:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1740): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1740 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1740
    ps_variable = var
vwatch64_SKIP_1740:::: 
vwatch64_LABEL_1741:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1741): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1741 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1741
    debuginfo "End variable"
vwatch64_SKIP_1741:::: 
vwatch64_LABEL_1742:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1742): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1742
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1717: GOTO vwatch64_LABEL_1717
    CASE 1723: GOTO vwatch64_LABEL_1723
    CASE 1724: GOTO vwatch64_LABEL_1724
    CASE 1725: GOTO vwatch64_LABEL_1725
    CASE 1726: GOTO vwatch64_LABEL_1726
    CASE 1727: GOTO vwatch64_LABEL_1727
    CASE 1728: GOTO vwatch64_LABEL_1728
    CASE 1729: GOTO vwatch64_LABEL_1729
    CASE 1730: GOTO vwatch64_LABEL_1730
    CASE 1731: GOTO vwatch64_LABEL_1731
    CASE 1732: GOTO vwatch64_LABEL_1732
    CASE 1734: GOTO vwatch64_LABEL_1734
    CASE 1735: GOTO vwatch64_LABEL_1735
    CASE 1736: GOTO vwatch64_LABEL_1736
    CASE 1738: GOTO vwatch64_LABEL_1738
    CASE 1739: GOTO vwatch64_LABEL_1739
    CASE 1740: GOTO vwatch64_LABEL_1740
    CASE 1741: GOTO vwatch64_LABEL_1741
    CASE 1742: GOTO vwatch64_LABEL_1742
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

sub ps_assert_token(actual, expected)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1745:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1745): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1745 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1745
    if actual <> expected then
vwatch64_SKIP_1745:::: 
vwatch64_LABEL_1746:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1746): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1746 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1746
        fatalerror "Syntax error: expected " + tok_human_readable(expected) + " got " + tok_human_readable(actual)
vwatch64_SKIP_1746:::: 
vwatch64_LABEL_1747:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1747): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1747 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1747
    else
vwatch64_SKIP_1747:::: 
vwatch64_LABEL_1748:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1748): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1748 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1748
        debuginfo "Assert " + tok_human_readable(expected)
vwatch64_SKIP_1748:::: 
vwatch64_LABEL_1749:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1749): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1749 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1749
    end if
vwatch64_SKIP_1749:::: 
vwatch64_LABEL_1750:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1750): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1750
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1745: GOTO vwatch64_LABEL_1745
    CASE 1746: GOTO vwatch64_LABEL_1746
    CASE 1747: GOTO vwatch64_LABEL_1747
    CASE 1748: GOTO vwatch64_LABEL_1748
    CASE 1749: GOTO vwatch64_LABEL_1749
    CASE 1750: GOTO vwatch64_LABEL_1750
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

function ps_opt_sigil(expected)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1753:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1753): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1753 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1753
    debuginfo "Start optional sigil"
vwatch64_SKIP_1753:::: 
    'if expected > 0 then it must match the type of the sigil
vwatch64_LABEL_1755:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1755): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1755 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1755
    typ = type_sfx2type(tok_next_token)
vwatch64_SKIP_1755:::: 
vwatch64_LABEL_1756:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1756): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1756 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1756
    if typ then
vwatch64_SKIP_1756:::: 
vwatch64_LABEL_1757:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1757): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1757 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1757
        ps_opt_sigil = typ
vwatch64_SKIP_1757:::: 
vwatch64_LABEL_1758:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1758): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1758 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1758
        if expected and typ <> expected then
vwatch64_SKIP_1758:::: 
vwatch64_LABEL_1759:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1759): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1759 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1759
            fatalerror "Type sigil is incorrect"
vwatch64_SKIP_1759:::: 
vwatch64_LABEL_1760:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1760): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1760 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1760
        end if
vwatch64_SKIP_1760:::: 
vwatch64_LABEL_1761:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1761): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1761 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1761
    else
vwatch64_SKIP_1761:::: 
vwatch64_LABEL_1762:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1762): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1762 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1762
        ps_opt_sigil = 0
vwatch64_SKIP_1762:::: 
vwatch64_LABEL_1763:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1763): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1763 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1763
        tok_please_repeat
vwatch64_SKIP_1763:::: 
vwatch64_LABEL_1764:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1764): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1764 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1764
    end if
vwatch64_SKIP_1764:::: 
vwatch64_LABEL_1765:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1765): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1765 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1765
    debuginfo "Completed optional sigil"
vwatch64_SKIP_1765:::: 
vwatch64_LABEL_1766:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1766): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1766
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1753: GOTO vwatch64_LABEL_1753
    CASE 1755: GOTO vwatch64_LABEL_1755
    CASE 1756: GOTO vwatch64_LABEL_1756
    CASE 1757: GOTO vwatch64_LABEL_1757
    CASE 1758: GOTO vwatch64_LABEL_1758
    CASE 1759: GOTO vwatch64_LABEL_1759
    CASE 1760: GOTO vwatch64_LABEL_1760
    CASE 1761: GOTO vwatch64_LABEL_1761
    CASE 1762: GOTO vwatch64_LABEL_1762
    CASE 1763: GOTO vwatch64_LABEL_1763
    CASE 1764: GOTO vwatch64_LABEL_1764
    CASE 1765: GOTO vwatch64_LABEL_1765
    CASE 1766: GOTO vwatch64_LABEL_1766
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

'*INCLUDE file merged: 'pratt.bm'
deflng a-z

function pt_expr(rbp)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1772:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1772): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1772 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1772
    t = pt_token
vwatch64_SKIP_1772:::: 
vwatch64_LABEL_1773:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1773): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1773 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1773
    content$ = pt_content$
vwatch64_SKIP_1773:::: 
vwatch64_LABEL_1774:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1774): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1774 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1774
    pt_refresh
vwatch64_SKIP_1774:::: 

vwatch64_LABEL_1776:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1776): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1776 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1776
    left_node = nud(t, content$)
vwatch64_SKIP_1776:::: 
vwatch64_LABEL_1777:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1777): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1777 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1777
    while rbp < lbp(pt_token, pt_content$)
vwatch64_SKIP_1777:::: 
vwatch64_LABEL_1778:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1778): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1778 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1778
        t = pt_token
vwatch64_SKIP_1778:::: 
vwatch64_LABEL_1779:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1779): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1779 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1779
        content$ = pt_content$
vwatch64_SKIP_1779:::: 
vwatch64_LABEL_1780:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1780): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1780 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1780
        pt_refresh
vwatch64_SKIP_1780:::: 
vwatch64_LABEL_1781:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1781): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1781 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1781
        left_node = led(t, content$, left_node)
vwatch64_SKIP_1781:::: 
vwatch64_LABEL_1782:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1782): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1782 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1782
    wend
vwatch64_SKIP_1782:::: 
vwatch64_LABEL_1783:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1783): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1783 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1783
    pt_expr = left_node
vwatch64_SKIP_1783:::: 
vwatch64_LABEL_1784:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1784): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1784
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1772: GOTO vwatch64_LABEL_1772
    CASE 1773: GOTO vwatch64_LABEL_1773
    CASE 1774: GOTO vwatch64_LABEL_1774
    CASE 1776: GOTO vwatch64_LABEL_1776
    CASE 1777: GOTO vwatch64_LABEL_1777
    CASE 1778: GOTO vwatch64_LABEL_1778
    CASE 1779: GOTO vwatch64_LABEL_1779
    CASE 1780: GOTO vwatch64_LABEL_1780
    CASE 1781: GOTO vwatch64_LABEL_1781
    CASE 1782: GOTO vwatch64_LABEL_1782
    CASE 1783: GOTO vwatch64_LABEL_1783
    CASE 1784: GOTO vwatch64_LABEL_1784
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

sub pt_refresh
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1787:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1787): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1787 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1787
    pt_token = tok_next_token
vwatch64_SKIP_1787:::: 
vwatch64_LABEL_1788:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1788): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1788 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1788
    pt_content$ = tok_content$
vwatch64_SKIP_1788:::: 
vwatch64_LABEL_1789:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1789): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1789
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1787: GOTO vwatch64_LABEL_1787
    CASE 1788: GOTO vwatch64_LABEL_1788
    CASE 1789: GOTO vwatch64_LABEL_1789
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

function nud(token, content$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1792:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1792): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1792 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1792
    select case token
vwatch64_SKIP_1792:::: 
    case TOK_NUMINT, TOK_NUMBASE, TOK_NUMDEC, TOK_NUMEXP, TOK_STRING
vwatch64_LABEL_1794:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1794): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1794 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1794
        node = ast_add_node(AST_CONSTANT)
vwatch64_SKIP_1794:::: 
vwatch64_LABEL_1795:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1795): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1795 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1795
        ast_nodes(node).ref = ast_add_constant(token, content$)
vwatch64_SKIP_1795:::: 
    case TOK_OPAREN
vwatch64_LABEL_1797:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1797): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1797 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1797
        node = pt_expr(0)
vwatch64_SKIP_1797:::: 
vwatch64_LABEL_1798:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1798): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1798 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1798
        ps_assert_token pt_token, TOK_CPAREN
vwatch64_SKIP_1798:::: 
vwatch64_LABEL_1799:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1799): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1799 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1799
        pt_refresh
vwatch64_SKIP_1799:::: 
    case TOK_DASH
        ' Hardcoded hack to change TOK_DASH into TOK_NEGATIVE
vwatch64_LABEL_1802:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1802): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1802 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1802
        node = ast_add_node(AST_CALL)
vwatch64_SKIP_1802:::: 
vwatch64_LABEL_1803:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1803): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1803 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1803
        ast_nodes(node).ref = TOK_NEGATIVE
vwatch64_SKIP_1803:::: 
vwatch64_LABEL_1804:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1804): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1804 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1804
        ast_attach node, pt_expr(htable_entries(TOK_NEGATIVE).v2)
vwatch64_SKIP_1804:::: 
    case TOK_UNKNOWN
        'Implicit variable definitions
vwatch64_LABEL_1807:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1807): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1807 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1807
        node = ast_add_node(AST_VAR)
vwatch64_SKIP_1807:::: 
vwatch64_LABEL_1808:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1808): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1808 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1808
        tok_please_repeat
vwatch64_SKIP_1808:::: 
vwatch64_LABEL_1809:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1809): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1809 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1809
        ast_nodes(node).ref = ps_variable(token, content$)
vwatch64_SKIP_1809:::: 
vwatch64_LABEL_1810:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1810): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1810 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1810
        pt_refresh
vwatch64_SKIP_1810:::: 
    case else
        dim he as hentry_t
vwatch64_LABEL_1813:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1813): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1813 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1813
        he = htable_entries(token)
vwatch64_SKIP_1813:::: 
vwatch64_LABEL_1814:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1814): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1814 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1814
        select case he.typ
vwatch64_SKIP_1814:::: 
        case HE_FUNCTION
vwatch64_LABEL_1816:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1816): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1816 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1816
            tok_please_repeat
vwatch64_SKIP_1816:::: 
vwatch64_LABEL_1817:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1817): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1817 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1817
            node = ps_funccall(token)
vwatch64_SKIP_1817:::: 
vwatch64_LABEL_1818:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1818): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1818 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1818
            pt_refresh
vwatch64_SKIP_1818:::: 
        case HE_VARIABLE
vwatch64_LABEL_1820:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1820): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1820 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1820
            node = ast_add_node(AST_VAR)
vwatch64_SKIP_1820:::: 
vwatch64_LABEL_1821:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1821): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1821 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1821
            tok_please_repeat
vwatch64_SKIP_1821:::: 
vwatch64_LABEL_1822:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1822): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1822 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1822
            ast_nodes(node).ref = ps_variable(token, content$)
vwatch64_SKIP_1822:::: 
vwatch64_LABEL_1823:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1823): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1823 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1823
            pt_refresh
vwatch64_SKIP_1823:::: 
        case HE_PREFIX
vwatch64_LABEL_1825:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1825): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1825 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1825
            node = ast_add_node(AST_CALL)
vwatch64_SKIP_1825:::: 
vwatch64_LABEL_1826:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1826): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1826 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1826
            ast_nodes(node).ref = token
vwatch64_SKIP_1826:::: 
vwatch64_LABEL_1827:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1827): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1827 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1827
            expr = pt_expr(he.v2)
vwatch64_SKIP_1827:::: 
vwatch64_LABEL_1828:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1828): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1828 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1828
            if ast_nodes(expr).typ = AST_VAR then candidate_flags = TYPE_BYREF
vwatch64_SKIP_1828:::: 
vwatch64_LABEL_1829:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1829): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1829 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1829
            candidate$ = type_sig_add_arg$("", type_of_expr(expr), flags)
vwatch64_SKIP_1829:::: 
vwatch64_LABEL_1830:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1830): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1830 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1830
            matching_sig = type_find_sig_match(token, candidate$)
vwatch64_SKIP_1830:::: 
vwatch64_LABEL_1831:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1831): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1831 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1831
            if matching_sig = 0 then fatalerror "Cannot find matching type signature"
vwatch64_SKIP_1831:::: 
vwatch64_LABEL_1832:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1832): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1832 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1832
            ast_attach node, ast_add_cast(expr, type_sig_argtype(matching_sig, 1))
vwatch64_SKIP_1832:::: 
vwatch64_LABEL_1833:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1833): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1833 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1833
            ast_nodes(node).ref2 = matching_sig
vwatch64_SKIP_1833:::: 
        case else
vwatch64_LABEL_1835:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1835): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1835 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1835
            fatalerror "Unexpected operator " + tok_human_readable$(token)
vwatch64_SKIP_1835:::: 
        end select
    end select
vwatch64_LABEL_1838:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1838): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1838 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1838
    nud = node
vwatch64_SKIP_1838:::: 
vwatch64_LABEL_1839:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1839): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1839
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1792: GOTO vwatch64_LABEL_1792
    CASE 1794: GOTO vwatch64_LABEL_1794
    CASE 1795: GOTO vwatch64_LABEL_1795
    CASE 1797: GOTO vwatch64_LABEL_1797
    CASE 1798: GOTO vwatch64_LABEL_1798
    CASE 1799: GOTO vwatch64_LABEL_1799
    CASE 1802: GOTO vwatch64_LABEL_1802
    CASE 1803: GOTO vwatch64_LABEL_1803
    CASE 1804: GOTO vwatch64_LABEL_1804
    CASE 1807: GOTO vwatch64_LABEL_1807
    CASE 1808: GOTO vwatch64_LABEL_1808
    CASE 1809: GOTO vwatch64_LABEL_1809
    CASE 1810: GOTO vwatch64_LABEL_1810
    CASE 1813: GOTO vwatch64_LABEL_1813
    CASE 1814: GOTO vwatch64_LABEL_1814
    CASE 1816: GOTO vwatch64_LABEL_1816
    CASE 1817: GOTO vwatch64_LABEL_1817
    CASE 1818: GOTO vwatch64_LABEL_1818
    CASE 1820: GOTO vwatch64_LABEL_1820
    CASE 1821: GOTO vwatch64_LABEL_1821
    CASE 1822: GOTO vwatch64_LABEL_1822
    CASE 1823: GOTO vwatch64_LABEL_1823
    CASE 1825: GOTO vwatch64_LABEL_1825
    CASE 1826: GOTO vwatch64_LABEL_1826
    CASE 1827: GOTO vwatch64_LABEL_1827
    CASE 1828: GOTO vwatch64_LABEL_1828
    CASE 1829: GOTO vwatch64_LABEL_1829
    CASE 1830: GOTO vwatch64_LABEL_1830
    CASE 1831: GOTO vwatch64_LABEL_1831
    CASE 1832: GOTO vwatch64_LABEL_1832
    CASE 1833: GOTO vwatch64_LABEL_1833
    CASE 1835: GOTO vwatch64_LABEL_1835
    CASE 1838: GOTO vwatch64_LABEL_1838
    CASE 1839: GOTO vwatch64_LABEL_1839
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function lbp(token, content$)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1842:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1842): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1842 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1842
    select case token
vwatch64_SKIP_1842:::: 
    case is < 0
vwatch64_LABEL_1844:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1844): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1844 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1844
        fatalerror "Unexpected literal " + content$
vwatch64_SKIP_1844:::: 
    case TOK_CPAREN
vwatch64_LABEL_1846:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1846): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1846 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1846
        lbp = 0
vwatch64_SKIP_1846:::: 
    case else
        dim he as hentry_t
vwatch64_LABEL_1849:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1849): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1849 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1849
        he = htable_entries(token)
vwatch64_SKIP_1849:::: 
vwatch64_LABEL_1850:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1850): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1850 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1850
        select case he.typ
vwatch64_SKIP_1850:::: 
        case HE_INFIX
vwatch64_LABEL_1852:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1852): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1852 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1852
            lbp = he.v2
vwatch64_SKIP_1852:::: 
        case else
vwatch64_LABEL_1854:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1854): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1854 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1854
            lbp = 0
vwatch64_SKIP_1854:::: 
        end select
    end select
vwatch64_LABEL_1857:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1857): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1857
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1842: GOTO vwatch64_LABEL_1842
    CASE 1844: GOTO vwatch64_LABEL_1844
    CASE 1846: GOTO vwatch64_LABEL_1846
    CASE 1849: GOTO vwatch64_LABEL_1849
    CASE 1850: GOTO vwatch64_LABEL_1850
    CASE 1852: GOTO vwatch64_LABEL_1852
    CASE 1854: GOTO vwatch64_LABEL_1854
    CASE 1857: GOTO vwatch64_LABEL_1857
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function led(token, content$, left_node)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    dim he as hentry_t
vwatch64_LABEL_1861:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1861): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1861 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1861
    he = htable_entries(token)
vwatch64_SKIP_1861:::: 
vwatch64_LABEL_1862:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1862): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1862 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1862
    node = ast_add_node(AST_CALL)
vwatch64_SKIP_1862:::: 
vwatch64_LABEL_1863:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1863): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1863 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1863
    ast_nodes(node).ref = token
vwatch64_SKIP_1863:::: 
vwatch64_LABEL_1864:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1864): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1864 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1864
    select case he.typ
vwatch64_SKIP_1864:::: 
    case HE_INFIX
vwatch64_LABEL_1866:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1866): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1866 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1866
        if he.v3 = 0 then 'Left-associative
vwatch64_SKIP_1866:::: 
vwatch64_LABEL_1867:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1867): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1867 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1867
            right_node = pt_expr(he.v2)
vwatch64_SKIP_1867:::: 
vwatch64_LABEL_1868:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1868): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1868 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1868
        else 'right-associative
vwatch64_SKIP_1868:::: 
vwatch64_LABEL_1869:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1869): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1869 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1869
            right_node = pt_expr(he.v2 - 1)
vwatch64_SKIP_1869:::: 
vwatch64_LABEL_1870:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1870): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1870 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1870
        end if
vwatch64_SKIP_1870:::: 
vwatch64_LABEL_1871:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1871): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1871 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1871
        if ast_nodes(left_node).typ = AST_VAR then candidate_flags = TYPE_BYREF
vwatch64_SKIP_1871:::: 
vwatch64_LABEL_1872:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1872): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1872 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1872
        candidate$ = type_sig_add_arg$("", type_of_expr(left_node), flags)
vwatch64_SKIP_1872:::: 
vwatch64_LABEL_1873:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1873): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1873 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1873
        if ast_nodes(right_node).typ = AST_VAR then candidate_flags = TYPE_BYREF
vwatch64_SKIP_1873:::: 
vwatch64_LABEL_1874:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1874): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1874 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1874
        candidate$ = type_sig_add_arg$(candidate$, type_of_expr(right_node), flags)
vwatch64_SKIP_1874:::: 
vwatch64_LABEL_1875:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1875): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1875 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1875
        matching_sig = type_find_sig_match(token, candidate$)
vwatch64_SKIP_1875:::: 
vwatch64_LABEL_1876:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1876): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1876 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1876
        if matching_sig = 0 then fatalerror "Cannot find matching type signature"
vwatch64_SKIP_1876:::: 
vwatch64_LABEL_1877:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1877): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1877 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1877
        ast_attach node, ast_add_cast(left_node, type_sig_argtype(matching_sig, 1))
vwatch64_SKIP_1877:::: 
vwatch64_LABEL_1878:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1878): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1878 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1878
        ast_attach node, ast_add_cast(right_node, type_sig_argtype(matching_sig, 2))
vwatch64_SKIP_1878:::: 
vwatch64_LABEL_1879:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1879): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1879 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1879
        ast_nodes(node).ref2 = matching_sig
vwatch64_SKIP_1879:::: 
    case else
vwatch64_LABEL_1881:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1881): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1881 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1881
        fatalerror "Unexpected led " + tok_human_readable$(token)
vwatch64_SKIP_1881:::: 
    end select
vwatch64_LABEL_1883:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1883): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1883 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1883
    led = node
vwatch64_SKIP_1883:::: 
vwatch64_LABEL_1884:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1884): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1884
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1861: GOTO vwatch64_LABEL_1861
    CASE 1862: GOTO vwatch64_LABEL_1862
    CASE 1863: GOTO vwatch64_LABEL_1863
    CASE 1864: GOTO vwatch64_LABEL_1864
    CASE 1866: GOTO vwatch64_LABEL_1866
    CASE 1867: GOTO vwatch64_LABEL_1867
    CASE 1868: GOTO vwatch64_LABEL_1868
    CASE 1869: GOTO vwatch64_LABEL_1869
    CASE 1870: GOTO vwatch64_LABEL_1870
    CASE 1871: GOTO vwatch64_LABEL_1871
    CASE 1872: GOTO vwatch64_LABEL_1872
    CASE 1873: GOTO vwatch64_LABEL_1873
    CASE 1874: GOTO vwatch64_LABEL_1874
    CASE 1875: GOTO vwatch64_LABEL_1875
    CASE 1876: GOTO vwatch64_LABEL_1876
    CASE 1877: GOTO vwatch64_LABEL_1877
    CASE 1878: GOTO vwatch64_LABEL_1878
    CASE 1879: GOTO vwatch64_LABEL_1879
    CASE 1881: GOTO vwatch64_LABEL_1881
    CASE 1883: GOTO vwatch64_LABEL_1883
    CASE 1884: GOTO vwatch64_LABEL_1884
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function
'*INCLUDE file merged: 'tokeng.bm'
deflng a-z
function tok_human_readable$(token)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1888:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1888): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1888 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1888
    if token > 0 then
vwatch64_SKIP_1888:::: 
vwatch64_LABEL_1889:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1889): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1889 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1889
        tok_human_readable$ = htable_names$(token)
vwatch64_SKIP_1889:::: 
vwatch64_LABEL_1890:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1890): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1890 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1890
    else
vwatch64_SKIP_1890:::: 
vwatch64_LABEL_1891:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1891): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1891 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1891
        tok_human_readable$ = "LITERAL_" + mid$(str$(token), 2)
vwatch64_SKIP_1891:::: 
vwatch64_LABEL_1892:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1892): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1892 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1892
    end if
vwatch64_SKIP_1892:::: 
vwatch64_LABEL_1893:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1893): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1893
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1888: GOTO vwatch64_LABEL_1888
    CASE 1889: GOTO vwatch64_LABEL_1889
    CASE 1890: GOTO vwatch64_LABEL_1890
    CASE 1891: GOTO vwatch64_LABEL_1891
    CASE 1892: GOTO vwatch64_LABEL_1892
    CASE 1893: GOTO vwatch64_LABEL_1893
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

sub tok_please_repeat
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1896:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1896): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1896 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1896
    tokeng_state.prefill = TRUE
vwatch64_SKIP_1896:::: 
vwatch64_LABEL_1897:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1897): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1897
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1896: GOTO vwatch64_LABEL_1896
    CASE 1897: GOTO vwatch64_LABEL_1897
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

function tok_content$
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    ' Despite the name, this variable does indeed hold the current token data
    ' (the idea being tok_next_token loads the token and then you call this function
    ' to get more detail on it).
vwatch64_LABEL_1903:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1903): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1903 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1903
    tok_content$ = tokeng_repeat_literal$
vwatch64_SKIP_1903:::: 
vwatch64_LABEL_1904:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1904): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1904
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1903: GOTO vwatch64_LABEL_1903
    CASE 1904: GOTO vwatch64_LABEL_1904
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

function tok_next_token
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1907:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1907): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1907 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1907
    if tokeng_state.prefill then
vwatch64_SKIP_1907:::: 
vwatch64_LABEL_1908:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1908): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1908 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1908
        tokeng_state.prefill = FALSE
vwatch64_SKIP_1908:::: 
vwatch64_LABEL_1909:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1909): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1909 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1909
        literal$ = tokeng_repeat_literal$
vwatch64_SKIP_1909:::: 
vwatch64_LABEL_1910:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1910): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1910 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1910
        tok_next_token = tokeng_repeat_token
vwatch64_SKIP_1910:::: 
vwatch64_LABEL_1911:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1911): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1911 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1911
        vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: exit function
vwatch64_SKIP_1911:::: 
vwatch64_LABEL_1912:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1912): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1912 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1912
    end if
vwatch64_SKIP_1912:::: 

    static in$

vwatch64_LABEL_1916:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1916): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1916 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1916
    if not tokeng_state.has_data then
vwatch64_SKIP_1916:::: 
vwatch64_LABEL_1917:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1917): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1917 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1917
        if eof(1) then
vwatch64_SKIP_1917:::: 
vwatch64_LABEL_1918:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1918): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1918 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1918
            tokeng_repeat_token = TOK_EOF
vwatch64_SKIP_1918:::: 
vwatch64_LABEL_1919:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1919): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1919 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1919
            tok_next_token = TOK_EOF
vwatch64_SKIP_1919:::: 
vwatch64_LABEL_1920:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1920): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1920 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1920
            vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: exit function
vwatch64_SKIP_1920:::: 
vwatch64_LABEL_1921:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1921): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1921 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1921
        end if
vwatch64_SKIP_1921:::: 
vwatch64_LABEL_1922:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1922): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1922 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1922
        tokeng_state.index = 1
vwatch64_SKIP_1922:::: 
vwatch64_LABEL_1923:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1923): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1923 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1923
        line input #1, in$
vwatch64_SKIP_1923:::: 
vwatch64_LABEL_1924:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1924): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1924 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1924
        debuginfo "Next Line: " + in$
vwatch64_SKIP_1924:::: 
vwatch64_LABEL_1925:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1925): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1925 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1925
        tokeng_state.has_data = TRUE
vwatch64_SKIP_1925:::: 
vwatch64_LABEL_1926:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1926): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1926 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1926
    end if
vwatch64_SKIP_1926:::: 

vwatch64_LABEL_1928:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1928): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1928 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1928
    ts_content$ = tok_next_ts$(in$ + chr$(10), ts_type)
vwatch64_SKIP_1928:::: 

vwatch64_LABEL_1930:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1930): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1930 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1930
    select case ts_type
vwatch64_SKIP_1930:::: 
        case 0 'Out of data (an error)
vwatch64_LABEL_1932:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1932): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1932 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1932
            fatalerror "Unexpected end of line"
vwatch64_SKIP_1932:::: 

        case TS_ID
vwatch64_LABEL_1935:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1935): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1935 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1935
            id = htable_get_id(ucase$(ts_content$))
vwatch64_SKIP_1935:::: 
vwatch64_LABEL_1936:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1936): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1936 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1936
            if id = 0 then
vwatch64_SKIP_1936:::: 
vwatch64_LABEL_1937:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1937): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1937 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1937
                token = TOK_UNKNOWN
vwatch64_SKIP_1937:::: 
vwatch64_LABEL_1938:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1938): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1938 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1938
            else
vwatch64_SKIP_1938:::: 
vwatch64_LABEL_1939:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1939): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1939 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1939
                token = id
vwatch64_SKIP_1939:::: 
vwatch64_LABEL_1940:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1940): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1940 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1940
            end if
vwatch64_SKIP_1940:::: 
vwatch64_LABEL_1941:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1941): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1941 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1941
            tokeng_state.linestart = FALSE
vwatch64_SKIP_1941:::: 

        case TS_NEWLINE
vwatch64_LABEL_1944:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1944): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1944 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1944
            tokeng_state.has_data = FALSE
vwatch64_SKIP_1944:::: 
vwatch64_LABEL_1945:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1945): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1945 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1945
            tokeng_state.linestart = TRUE
vwatch64_SKIP_1945:::: 
vwatch64_LABEL_1946:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1946): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1946 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1946
            token = TOK_NEWLINE
vwatch64_SKIP_1946:::: 

        case else
vwatch64_LABEL_1949:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1949): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1949 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1949
            if tok_direct(ts_type) then
vwatch64_SKIP_1949:::: 
vwatch64_LABEL_1950:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1950): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1950 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1950
                token = tok_direct(ts_type)
vwatch64_SKIP_1950:::: 
vwatch64_LABEL_1951:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1951): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1951 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1951
            else
vwatch64_SKIP_1951:::: 
vwatch64_LABEL_1952:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1952): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1952 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1952
                fatalerror "Unhandled TS" + str$(ts_type)
vwatch64_SKIP_1952:::: 
vwatch64_LABEL_1953:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1953): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1953 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1953
            end if
vwatch64_SKIP_1953:::: 
vwatch64_LABEL_1954:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1954): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1954 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1954
            tokeng_state.linestart = FALSE
vwatch64_SKIP_1954:::: 
    end select

vwatch64_LABEL_1957:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1957): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1957 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1957
    tokeng_repeat_token = token
vwatch64_SKIP_1957:::: 
vwatch64_LABEL_1958:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1958): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1958 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1958
    tokeng_repeat_literal$ = ts_content$
vwatch64_SKIP_1958:::: 
vwatch64_LABEL_1959:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1959): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1959 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1959
    tok_next_token = token
vwatch64_SKIP_1959:::: 
vwatch64_LABEL_1960:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1960): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1960 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1960
    debuginfo "tokeng: " + tok_human_readable$(token)
vwatch64_SKIP_1960:::: 
vwatch64_LABEL_1961:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1961): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1961
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1907: GOTO vwatch64_LABEL_1907
    CASE 1908: GOTO vwatch64_LABEL_1908
    CASE 1909: GOTO vwatch64_LABEL_1909
    CASE 1910: GOTO vwatch64_LABEL_1910
    CASE 1911: GOTO vwatch64_LABEL_1911
    CASE 1912: GOTO vwatch64_LABEL_1912
    CASE 1916: GOTO vwatch64_LABEL_1916
    CASE 1917: GOTO vwatch64_LABEL_1917
    CASE 1918: GOTO vwatch64_LABEL_1918
    CASE 1919: GOTO vwatch64_LABEL_1919
    CASE 1920: GOTO vwatch64_LABEL_1920
    CASE 1921: GOTO vwatch64_LABEL_1921
    CASE 1922: GOTO vwatch64_LABEL_1922
    CASE 1923: GOTO vwatch64_LABEL_1923
    CASE 1924: GOTO vwatch64_LABEL_1924
    CASE 1925: GOTO vwatch64_LABEL_1925
    CASE 1926: GOTO vwatch64_LABEL_1926
    CASE 1928: GOTO vwatch64_LABEL_1928
    CASE 1930: GOTO vwatch64_LABEL_1930
    CASE 1932: GOTO vwatch64_LABEL_1932
    CASE 1935: GOTO vwatch64_LABEL_1935
    CASE 1936: GOTO vwatch64_LABEL_1936
    CASE 1937: GOTO vwatch64_LABEL_1937
    CASE 1938: GOTO vwatch64_LABEL_1938
    CASE 1939: GOTO vwatch64_LABEL_1939
    CASE 1940: GOTO vwatch64_LABEL_1940
    CASE 1941: GOTO vwatch64_LABEL_1941
    CASE 1944: GOTO vwatch64_LABEL_1944
    CASE 1945: GOTO vwatch64_LABEL_1945
    CASE 1946: GOTO vwatch64_LABEL_1946
    CASE 1949: GOTO vwatch64_LABEL_1949
    CASE 1950: GOTO vwatch64_LABEL_1950
    CASE 1951: GOTO vwatch64_LABEL_1951
    CASE 1952: GOTO vwatch64_LABEL_1952
    CASE 1953: GOTO vwatch64_LABEL_1953
    CASE 1954: GOTO vwatch64_LABEL_1954
    CASE 1957: GOTO vwatch64_LABEL_1957
    CASE 1958: GOTO vwatch64_LABEL_1958
    CASE 1959: GOTO vwatch64_LABEL_1959
    CASE 1960: GOTO vwatch64_LABEL_1960
    CASE 1961: GOTO vwatch64_LABEL_1961
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

sub tok_init
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    'read in arrays and set default values for some control variables
vwatch64_LABEL_1965:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1965): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1965 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1965
    for s = 1 to ubound(t_states~%, 2)
vwatch64_SKIP_1965:::: 
vwatch64_LABEL_1966:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1966): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1966 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1966
        read t_statenames$(s)
vwatch64_SKIP_1966:::: 
vwatch64_LABEL_1967:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1967): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1967 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1967
        for b = 1 to 127
vwatch64_SKIP_1967:::: 
vwatch64_LABEL_1968:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1968): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1968 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1968
            read cmd
vwatch64_SKIP_1968:::: 
vwatch64_LABEL_1969:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1969): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1969 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1969
            t_states~%(b, s) = cmd
vwatch64_SKIP_1969:::: 
vwatch64_LABEL_1970:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1970): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1970 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1970
        next b
vwatch64_SKIP_1970:::: 
vwatch64_LABEL_1971:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1971): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1971 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1971
    next s
vwatch64_SKIP_1971:::: 
vwatch64_LABEL_1972:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1972): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1972 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1972
    tokeng_state.index = 1
vwatch64_SKIP_1972:::: 
vwatch64_LABEL_1973:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1973): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1973 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1973
    tokeng_state.curstate = 1
vwatch64_SKIP_1973:::: 
vwatch64_LABEL_1974:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1974): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1974 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1974
    tokeng_state.has_data = FALSE
vwatch64_SKIP_1974:::: 
vwatch64_LABEL_1975:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1975): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1975 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1975
    tokeng_state.linestart = TRUE
vwatch64_SKIP_1975:::: 
vwatch64_LABEL_1976:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1976): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1976 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1976
    tokeng_state.prefill = FALSE
vwatch64_SKIP_1976:::: 
vwatch64_LABEL_1977:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1977): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1977
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1965: GOTO vwatch64_LABEL_1965
    CASE 1966: GOTO vwatch64_LABEL_1966
    CASE 1967: GOTO vwatch64_LABEL_1967
    CASE 1968: GOTO vwatch64_LABEL_1968
    CASE 1969: GOTO vwatch64_LABEL_1969
    CASE 1970: GOTO vwatch64_LABEL_1970
    CASE 1971: GOTO vwatch64_LABEL_1971
    CASE 1972: GOTO vwatch64_LABEL_1972
    CASE 1973: GOTO vwatch64_LABEL_1973
    CASE 1974: GOTO vwatch64_LABEL_1974
    CASE 1975: GOTO vwatch64_LABEL_1975
    CASE 1976: GOTO vwatch64_LABEL_1976
    CASE 1977: GOTO vwatch64_LABEL_1977
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

function tok_next_ts$(text$, ts_type)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_1980:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1980): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1980 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1980
    if tokeng_state.index > len(text$) then
vwatch64_SKIP_1980:::: 
        'Out of data
vwatch64_LABEL_1982:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1982): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1982 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1982
        ts_type = 0
vwatch64_SKIP_1982:::: 
vwatch64_LABEL_1983:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1983): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1983 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1983
        vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: exit function
vwatch64_SKIP_1983:::: 
vwatch64_LABEL_1984:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1984): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1984 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1984
    end if
vwatch64_SKIP_1984:::: 
vwatch64_LABEL_1985:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1985): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1985 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1985
    for i = tokeng_state.index to len(text$)
vwatch64_SKIP_1985:::: 
vwatch64_LABEL_1986:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1986): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1986 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1986
        c = asc(text$, i)
vwatch64_SKIP_1986:::: 
        'No utf-8 support for now
vwatch64_LABEL_1988:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1988): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1988 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1988
        if c > 127 then fatalerror "Character outside character set (" + ltrim$(str$(c)) + ")"
vwatch64_SKIP_1988:::: 
vwatch64_LABEL_1989:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1989): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1989 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1989
        command = t_states~%(c, tokeng_state.curstate)
vwatch64_SKIP_1989:::: 
        'Rules of the form "A: B ~ Error" encode to 0
vwatch64_LABEL_1991:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1991): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1991 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1991
        if command = 0 then fatalerror chr$(34) + chr$(c) + chr$(34) + " from " + t_statenames$(tokeng_state.curstate) + " illegal"
vwatch64_SKIP_1991:::: 
        'High byte is next state, low byte is token, high bit of low byte is pushback flag
vwatch64_LABEL_1993:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1993): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1993 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1993
        ts_type_internal = command and 127
vwatch64_SKIP_1993:::: 
vwatch64_LABEL_1994:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1994): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1994 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1994
        pushback = command and 128
vwatch64_SKIP_1994:::: 
        'print t_statenames$(tokeng_state.curstate); ":"; c; "~ ";
vwatch64_LABEL_1996:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1996): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1996 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1996
        tokeng_state.curstate = command \ 2^8
vwatch64_SKIP_1996:::: 
        'print t_statenames$(tokeng_state.curstate)
vwatch64_LABEL_1998:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1998): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1998 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1998
        if ts_type_internal > 0 then
vwatch64_SKIP_1998:::: 
vwatch64_LABEL_1999:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(1999): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_1999 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_1999
            ts_type = ts_type_internal
vwatch64_SKIP_1999:::: 
vwatch64_LABEL_2000:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2000): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2000 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2000
            if pushback then
vwatch64_SKIP_2000:::: 
                'This doesn't include the current character, and uses it next time...
vwatch64_LABEL_2002:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2002): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2002 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2002
                if ts_type <> 1 then tok_next_ts$ = mid$(text$, tokeng_state.index, i - tokeng_state.index)
vwatch64_SKIP_2002:::: 
vwatch64_LABEL_2003:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2003): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2003 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2003
                tokeng_state.index = i
vwatch64_SKIP_2003:::: 
vwatch64_LABEL_2004:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2004): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2004 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2004
            else
vwatch64_SKIP_2004:::: 
                '...but this does include it, and starts from the next character next time.
vwatch64_LABEL_2006:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2006): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2006 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2006
                if ts_type <> 1 then tok_next_ts$ = mid$(text$, tokeng_state.index, i - tokeng_state.index + 1)
vwatch64_SKIP_2006:::: 
vwatch64_LABEL_2007:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2007): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2007 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2007
                tokeng_state.index = i + 1
vwatch64_SKIP_2007:::: 
vwatch64_LABEL_2008:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2008): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2008 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2008
            end if
vwatch64_SKIP_2008:::: 
vwatch64_LABEL_2009:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2009): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2009 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2009
            if ts_type <> TS_SKIP then vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1: exit function
vwatch64_SKIP_2009:::: 
vwatch64_LABEL_2010:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2010): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2010 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2010
        end if
vwatch64_SKIP_2010:::: 
vwatch64_LABEL_2011:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2011): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2011 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2011
    next i
vwatch64_SKIP_2011:::: 
vwatch64_LABEL_2012:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2012): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2012 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2012
    ts_type = 0
vwatch64_SKIP_2012:::: 
vwatch64_LABEL_2013:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2013): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2013
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 1980: GOTO vwatch64_LABEL_1980
    CASE 1982: GOTO vwatch64_LABEL_1982
    CASE 1983: GOTO vwatch64_LABEL_1983
    CASE 1984: GOTO vwatch64_LABEL_1984
    CASE 1985: GOTO vwatch64_LABEL_1985
    CASE 1986: GOTO vwatch64_LABEL_1986
    CASE 1988: GOTO vwatch64_LABEL_1988
    CASE 1989: GOTO vwatch64_LABEL_1989
    CASE 1991: GOTO vwatch64_LABEL_1991
    CASE 1993: GOTO vwatch64_LABEL_1993
    CASE 1994: GOTO vwatch64_LABEL_1994
    CASE 1996: GOTO vwatch64_LABEL_1996
    CASE 1998: GOTO vwatch64_LABEL_1998
    CASE 1999: GOTO vwatch64_LABEL_1999
    CASE 2000: GOTO vwatch64_LABEL_2000
    CASE 2002: GOTO vwatch64_LABEL_2002
    CASE 2003: GOTO vwatch64_LABEL_2003
    CASE 2004: GOTO vwatch64_LABEL_2004
    CASE 2006: GOTO vwatch64_LABEL_2006
    CASE 2007: GOTO vwatch64_LABEL_2007
    CASE 2008: GOTO vwatch64_LABEL_2008
    CASE 2009: GOTO vwatch64_LABEL_2009
    CASE 2010: GOTO vwatch64_LABEL_2010
    CASE 2011: GOTO vwatch64_LABEL_2011
    CASE 2012: GOTO vwatch64_LABEL_2012
    CASE 2013: GOTO vwatch64_LABEL_2013
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function 

'*INCLUDE file merged: '../../rules/ts_data.bm'
DATA "Begin",0,0,0,0,0,0,0,0,257,259,257,257,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,257,0,0,0,1280,0,0,1024,0,0,0,0,0,0,0,0,768,768,768,768,768,768,768,768,768,768,0,0,0,0,0,1538,0,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,0,0,0,0,512,0,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,0,0,0,0,0
DATA "Id",0,0,0,0,0,0,0,0,1666,386,1666,1666,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1666,1666,1666,1666,1666,1666,1666,1024,1666,1666,1666,1666,1666,1666,1666,1666,512,512,512,512,512,512,512,512,512,512,1543,1666,1666,1666,1666,1666,0,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,0,1666,0,1666,512,0,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,0,0,0,1666,0
DATA "Linenum",0,0,0,0,0,0,0,0,1668,388,1668,1668,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1668,0,0,0,0,0,0,1156,0,0,0,0,0,0,0,0,768,768,768,768,768,768,768,768,768,768,1540,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DATA "Comment",1024,1024,1024,1024,1024,1024,1024,1024,1024,259,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024
DATA "Metacmd1",0,0,0,0,0,0,0,0,1281,389,1281,1281,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1281,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1797,0,0,0,0,0,0,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,0,0,0,0,1280,0,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,1280,0,0,0,0,0
DATA "General",0,0,0,0,0,0,0,0,1537,259,1537,1537,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1537,1545,2048,2560,1546,2816,3072,1027,1549,1550,1548,1552,1557,1551,3840,1558,2304,2304,2304,2304,2304,2304,2304,2304,2304,2304,1555,1556,3328,1553,3584,1538,0,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,0,1554,0,1547,512,0,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,0,0,0,0,0
DATA "Metacmd2",1792,1792,1792,1792,1792,1792,1792,1792,1792,390,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792,1792
DATA "String",2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,1544,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048
DATA "Number",1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,4096,1687,2304,2304,2304,2304,2304,2304,2304,2304,2304,2304,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,4352,4352,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,4352,4352,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687,1687
DATA "HashPfx",1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1565,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692,1692
DATA "PercentPfx",1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1563,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690,1690
DATA "AmpersandPfx",1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1567,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,4864,1694,1694,1694,1694,1694,4864,1694,1694,1694,1694,1694,1694,4864,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,4864,1694,1694,1694,1694,1694,4864,1694,1694,1694,1694,1694,1694,4864,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694,1694
DATA "LtPfx",1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1570,1571,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697,1697
DATA "GtPfx",1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1573,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700,1700
DATA "Dot",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,4096,4096,4096,4096,4096,4096,4096,4096,0,0,0,0,0,0,0,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,0,0,0,0,1702,0,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,1702,0,0,0,0,0
DATA "NumDec",1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,4096,4096,4096,4096,4096,4096,4096,4096,4096,4096,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,4352,4352,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,4352,4352,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688,1688
DATA "NumExpSgn",1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,4608,1689,4608,1689,1689,4608,4608,4608,4608,4608,4608,4608,4608,4608,4608,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689
DATA "NumExp",1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,4608,4608,4608,4608,4608,4608,4608,4608,4608,4608,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689,1689
DATA "NumBase",1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,4864,4864,4864,4864,4864,4864,4864,4864,4864,4864,1696,1696,1696,1696,1696,1696,1696,4864,4864,4864,4864,4864,4864,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,4864,4864,4864,4864,4864,4864,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696,1696
'*INCLUDE file merged: 'emitters/dump/dump.bm'
sub dump_program(root)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_2037:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2037): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2037 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2037
    print #1, "Table of identifiers:"
vwatch64_SKIP_2037:::: 
vwatch64_LABEL_2038:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2038): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2038 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2038
    htable_dump
vwatch64_SKIP_2038:::: 
vwatch64_LABEL_2039:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2039): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2039 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2039
    print #1,
vwatch64_SKIP_2039:::: 
vwatch64_LABEL_2040:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2040): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2040 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2040
    print #1, "Function type signatures:"
vwatch64_SKIP_2040:::: 
vwatch64_LABEL_2041:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2041): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2041 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2041
    type_dump_functions
vwatch64_SKIP_2041:::: 
vwatch64_LABEL_2042:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2042): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2042 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2042
    print #1,
vwatch64_SKIP_2042:::: 
vwatch64_LABEL_2043:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2043): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2043 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2043
    print #1, "Table of constants:"
vwatch64_SKIP_2043:::: 
vwatch64_LABEL_2044:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2044): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2044 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2044
    ast_dump_constants
vwatch64_SKIP_2044:::: 
vwatch64_LABEL_2045:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2045): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2045 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2045
    print #1,
vwatch64_SKIP_2045:::: 
vwatch64_LABEL_2046:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2046): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2046 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2046
    print #1, "Program:"
vwatch64_SKIP_2046:::: 
vwatch64_LABEL_2047:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2047): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2047 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2047
    ast_dump_pretty root, 0
vwatch64_SKIP_2047:::: 
vwatch64_LABEL_2048:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2048): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2048
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2037: GOTO vwatch64_LABEL_2037
    CASE 2038: GOTO vwatch64_LABEL_2038
    CASE 2039: GOTO vwatch64_LABEL_2039
    CASE 2040: GOTO vwatch64_LABEL_2040
    CASE 2041: GOTO vwatch64_LABEL_2041
    CASE 2042: GOTO vwatch64_LABEL_2042
    CASE 2043: GOTO vwatch64_LABEL_2043
    CASE 2044: GOTO vwatch64_LABEL_2044
    CASE 2045: GOTO vwatch64_LABEL_2045
    CASE 2046: GOTO vwatch64_LABEL_2046
    CASE 2047: GOTO vwatch64_LABEL_2047
    CASE 2048: GOTO vwatch64_LABEL_2048
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub type_dump_functions
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_2051:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2051): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2051 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2051
    for i = 1 to htable.elements
vwatch64_SKIP_2051:::: 
vwatch64_LABEL_2052:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2052): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2052 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2052
        typ = htable_entries(i).typ
vwatch64_SKIP_2052:::: 
vwatch64_LABEL_2053:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2053): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2053 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2053
        if typ = HE_FUNCTION or typ = HE_INFIX or typ = HE_PREFIX then
vwatch64_SKIP_2053:::: 
vwatch64_LABEL_2054:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2054): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2054 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2054
            sig_index = htable_entries(i).v1
vwatch64_SKIP_2054:::: 
vwatch64_LABEL_2055:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2055): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2055 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2055
            do
vwatch64_SKIP_2055:::: 
vwatch64_LABEL_2056:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2056): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2056 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2056
                print #1, sig_index; htable_names(i); " "; type_human_sig$(type_signatures(sig_index).sig)
vwatch64_SKIP_2056:::: 
vwatch64_LABEL_2057:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2057): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2057 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2057
                sig_index = type_signatures(sig_index).succ
vwatch64_SKIP_2057:::: 
vwatch64_LABEL_2058:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2058): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2058 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2058
            loop while sig_index <> 0
vwatch64_SKIP_2058:::: 
vwatch64_LABEL_2059:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2059): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2059 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2059
        end if
vwatch64_SKIP_2059:::: 
vwatch64_LABEL_2060:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2060): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2060 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2060
    next i
vwatch64_SKIP_2060:::: 
vwatch64_LABEL_2061:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2061): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2061
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2051: GOTO vwatch64_LABEL_2051
    CASE 2052: GOTO vwatch64_LABEL_2052
    CASE 2053: GOTO vwatch64_LABEL_2053
    CASE 2054: GOTO vwatch64_LABEL_2054
    CASE 2055: GOTO vwatch64_LABEL_2055
    CASE 2056: GOTO vwatch64_LABEL_2056
    CASE 2057: GOTO vwatch64_LABEL_2057
    CASE 2058: GOTO vwatch64_LABEL_2058
    CASE 2059: GOTO vwatch64_LABEL_2059
    CASE 2060: GOTO vwatch64_LABEL_2060
    CASE 2061: GOTO vwatch64_LABEL_2061
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub htable_dump
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_2064:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2064): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2064 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2064
    print #1, " ID          Name     Typ     v1     v2     v3"
vwatch64_SKIP_2064:::: 
vwatch64_LABEL_2065:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2065): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2065 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2065
    for i = 1 to htable.elements
vwatch64_SKIP_2065:::: 
vwatch64_LABEL_2066:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2066): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2066 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2066
        print #1, using "###    \            \ ###    ###    ###    ###"; i; htable_names(i); htable_entries(i).typ,htable_entries(i).v1; htable_entries(i).v2; htable_entries(i).v3
vwatch64_SKIP_2066:::: 
vwatch64_LABEL_2067:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2067): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2067 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2067
    next i
vwatch64_SKIP_2067:::: 
vwatch64_LABEL_2068:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2068): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2068
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2064: GOTO vwatch64_LABEL_2064
    CASE 2065: GOTO vwatch64_LABEL_2065
    CASE 2066: GOTO vwatch64_LABEL_2066
    CASE 2067: GOTO vwatch64_LABEL_2067
    CASE 2068: GOTO vwatch64_LABEL_2068
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub ast_dump_pretty(root, indent_level)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_2071:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2071): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2071 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2071
    indent$ = space$(indent_level * 4)
vwatch64_SKIP_2071:::: 
vwatch64_LABEL_2072:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2072): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2072 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2072
    if ast_nodes(root).typ = 0 then
vwatch64_SKIP_2072:::: 
vwatch64_LABEL_2073:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2073): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2073 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2073
        fatalerror "Node" + str$(root) + " is invalid"
vwatch64_SKIP_2073:::: 
vwatch64_LABEL_2074:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2074): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2074 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2074
    end if
vwatch64_SKIP_2074:::: 
vwatch64_LABEL_2075:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2075): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2075 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2075
    select case ast_nodes(root).typ
vwatch64_SKIP_2075:::: 
    case AST_ASSIGN
vwatch64_LABEL_2077:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2077): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2077 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2077
        print #1, htable_names(ast_nodes(root).ref); " = ";
vwatch64_SKIP_2077:::: 
vwatch64_LABEL_2078:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2078): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2078 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2078
        ast_dump_pretty cvl(ast_children(root)), 0
vwatch64_SKIP_2078:::: 
    case AST_IF
vwatch64_LABEL_2080:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2080): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2080 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2080
        print #1, "IF ";
vwatch64_SKIP_2080:::: 
vwatch64_LABEL_2081:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2081): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2081 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2081
        ast_dump_pretty ast_get_child(root, 1), 0
vwatch64_SKIP_2081:::: 
vwatch64_LABEL_2082:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2082): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2082 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2082
        print #1, " THEN ";
vwatch64_SKIP_2082:::: 
vwatch64_LABEL_2083:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2083): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2083 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2083
        if ast_nodes(ast_get_child(root, 2)).typ = AST_BLOCK then
vwatch64_SKIP_2083:::: 
vwatch64_LABEL_2084:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2084): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2084 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2084
            print #1,
vwatch64_SKIP_2084:::: 
vwatch64_LABEL_2085:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2085): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2085 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2085
            ast_dump_pretty ast_get_child(root, 2), indent_level + 1
vwatch64_SKIP_2085:::: 
vwatch64_LABEL_2086:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2086): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2086 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2086
            if ast_num_children(root) > 2 then
vwatch64_SKIP_2086:::: 
vwatch64_LABEL_2087:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2087): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2087 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2087
                print #1, indent$; "ELSE"
vwatch64_SKIP_2087:::: 
vwatch64_LABEL_2088:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2088): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2088 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2088
                ast_dump_pretty ast_get_child(root, 3), indent_level + 1
vwatch64_SKIP_2088:::: 
vwatch64_LABEL_2089:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2089): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2089 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2089
            end if
vwatch64_SKIP_2089:::: 
vwatch64_LABEL_2090:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2090): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2090 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2090
            print #1, indent$; "END IF";
vwatch64_SKIP_2090:::: 
vwatch64_LABEL_2091:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2091): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2091 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2091
        else
vwatch64_SKIP_2091:::: 
vwatch64_LABEL_2092:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2092): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2092 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2092
            ast_dump_pretty ast_get_child(root, 2), 0
vwatch64_SKIP_2092:::: 
vwatch64_LABEL_2093:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2093): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2093 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2093
        end if
vwatch64_SKIP_2093:::: 
    case AST_DO_PRE
vwatch64_LABEL_2095:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2095): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2095 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2095
        print #1, indent$; "DO WHILE ";
vwatch64_SKIP_2095:::: 
vwatch64_LABEL_2096:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2096): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2096 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2096
        ast_dump_pretty ast_get_child(root, 1), 0
vwatch64_SKIP_2096:::: 
vwatch64_LABEL_2097:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2097): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2097 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2097
        print #1,
vwatch64_SKIP_2097:::: 
vwatch64_LABEL_2098:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2098): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2098 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2098
        ast_dump_pretty ast_get_child(root, 2), indent_level + 1
vwatch64_SKIP_2098:::: 
vwatch64_LABEL_2099:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2099): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2099 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2099
        print #1, indent$; "LOOP";
vwatch64_SKIP_2099:::: 
    case AST_DO_POST
vwatch64_LABEL_2101:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2101): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2101 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2101
        print #1, indent$; "DO"
vwatch64_SKIP_2101:::: 
vwatch64_LABEL_2102:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2102): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2102 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2102
        ast_dump_pretty ast_get_child(root, 2), indent_level + 1
vwatch64_SKIP_2102:::: 
vwatch64_LABEL_2103:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2103): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2103 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2103
        print #1, indent$; "LOOP WHILE ";
vwatch64_SKIP_2103:::: 
vwatch64_LABEL_2104:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2104): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2104 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2104
        ast_dump_pretty ast_get_child(root, 1), 0
vwatch64_SKIP_2104:::: 
    case AST_FOR
vwatch64_LABEL_2106:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2106): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2106 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2106
        print #1, "FOR ";
vwatch64_SKIP_2106:::: 
vwatch64_LABEL_2107:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2107): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2107 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2107
        print #1, htable_names(ast_nodes(root).ref); " = ";
vwatch64_SKIP_2107:::: 
vwatch64_LABEL_2108:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2108): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2108 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2108
        ast_dump_pretty ast_get_child(root, 1), 0
vwatch64_SKIP_2108:::: 
vwatch64_LABEL_2109:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2109): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2109 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2109
        print #1, " TO ";
vwatch64_SKIP_2109:::: 
vwatch64_LABEL_2110:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2110): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2110 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2110
        ast_dump_pretty ast_get_child(root, 2), 0
vwatch64_SKIP_2110:::: 
vwatch64_LABEL_2111:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2111): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2111 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2111
        print #1, " STEP ";
vwatch64_SKIP_2111:::: 
vwatch64_LABEL_2112:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2112): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2112 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2112
        ast_dump_pretty ast_get_child(root, 3), 0
vwatch64_SKIP_2112:::: 
vwatch64_LABEL_2113:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2113): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2113 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2113
        print #1,
vwatch64_SKIP_2113:::: 
vwatch64_LABEL_2114:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2114): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2114 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2114
        ast_dump_pretty ast_get_child(root,  4), indent_level + 1
vwatch64_SKIP_2114:::: 
vwatch64_LABEL_2115:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2115): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2115 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2115
        print #1, indent$; "NEXT "; htable_names(ast_nodes(root).ref);
vwatch64_SKIP_2115:::: 
    case AST_SELECT
vwatch64_LABEL_2117:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2117): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2117 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2117
        print #1, indent$; "SELECT CASE ";
vwatch64_SKIP_2117:::: 
vwatch64_LABEL_2118:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2118): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2118 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2118
        ast_dump_pretty ast_get_child(root, 1), 0
vwatch64_SKIP_2118:::: 
vwatch64_LABEL_2119:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2119): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2119 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2119
        print #1,
vwatch64_SKIP_2119:::: 
vwatch64_LABEL_2120:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2120): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2120 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2120
        for i = 2 to ast_num_children(root) step 2
vwatch64_SKIP_2120:::: 
vwatch64_LABEL_2121:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2121): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2121 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2121
            print #1, indent$; "CASE ";
vwatch64_SKIP_2121:::: 
vwatch64_LABEL_2122:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2122): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2122 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2122
            ast_dump_pretty ast_get_child(root, i), 0
vwatch64_SKIP_2122:::: 
vwatch64_LABEL_2123:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2123): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2123 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2123
            print #1,
vwatch64_SKIP_2123:::: 
vwatch64_LABEL_2124:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2124): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2124 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2124
            ast_dump_pretty ast_get_child(root, i + 1), indent_level + 1
vwatch64_SKIP_2124:::: 
vwatch64_LABEL_2125:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2125): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2125 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2125
        next i
vwatch64_SKIP_2125:::: 
vwatch64_LABEL_2126:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2126): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2126 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2126
        print #1, indent$; "END SELECT";
vwatch64_SKIP_2126:::: 
    case AST_CALL
vwatch64_LABEL_2128:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2128): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2128 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2128
        print #1, "call(";
vwatch64_SKIP_2128:::: 
vwatch64_LABEL_2129:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2129): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2129 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2129
        print #1, htable_names(ast_nodes(root).ref);
vwatch64_SKIP_2129:::: 
vwatch64_LABEL_2130:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2130): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2130 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2130
        print #1, " ["; type_human_sig$(type_signatures(ast_nodes(root).ref2).sig); "]";
vwatch64_SKIP_2130:::: 
vwatch64_LABEL_2131:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2131): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2131 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2131
        if len(ast_children(root)) then print #1, ", ";
vwatch64_SKIP_2131:::: 
vwatch64_LABEL_2132:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2132): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2132 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2132
        for i = 1 to ast_num_children(root)
vwatch64_SKIP_2132:::: 
vwatch64_LABEL_2133:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2133): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2133 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2133
            ast_dump_pretty ast_get_child(root, i), 0
vwatch64_SKIP_2133:::: 
vwatch64_LABEL_2134:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2134): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2134 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2134
            if i <> ast_num_children(root) then print #1, ", ";
vwatch64_SKIP_2134:::: 
vwatch64_LABEL_2135:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2135): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2135 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2135
        next i
vwatch64_SKIP_2135:::: 
vwatch64_LABEL_2136:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2136): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2136 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2136
        print #1, ")";
vwatch64_SKIP_2136:::: 
    case AST_CONSTANT
vwatch64_LABEL_2138:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2138): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2138 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2138
        if type_of_constant(root) = TYPE_STRING then
vwatch64_SKIP_2138:::: 
vwatch64_LABEL_2139:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2139): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2139 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2139
            print #1, chr$(34); ast_constants(ast_nodes(root).ref); chr$(34);
vwatch64_SKIP_2139:::: 
vwatch64_LABEL_2140:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2140): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2140 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2140
        else
vwatch64_SKIP_2140:::: 
vwatch64_LABEL_2141:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2141): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2141 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2141
            print #1, ast_constants(ast_nodes(root).ref);
vwatch64_SKIP_2141:::: 
vwatch64_LABEL_2142:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2142): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2142 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2142
        end if
vwatch64_SKIP_2142:::: 
    case AST_BLOCK
vwatch64_LABEL_2144:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2144): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2144 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2144
        for i = 1 to ast_num_children(root)
vwatch64_SKIP_2144:::: 
vwatch64_LABEL_2145:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2145): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2145 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2145
            print #1, indent$;
vwatch64_SKIP_2145:::: 
vwatch64_LABEL_2146:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2146): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2146 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2146
            ast_dump_pretty ast_get_child(root, i), indent_level
vwatch64_SKIP_2146:::: 
vwatch64_LABEL_2147:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2147): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2147 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2147
            print #1,
vwatch64_SKIP_2147:::: 
vwatch64_LABEL_2148:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2148): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2148 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2148
        next i
vwatch64_SKIP_2148:::: 
    case AST_VAR
vwatch64_LABEL_2150:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2150): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2150 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2150
        print #1, "var("; htable_names(ast_nodes(root).ref); ")";
vwatch64_SKIP_2150:::: 
    case AST_CAST
vwatch64_LABEL_2152:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2152): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2152 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2152
        print #1, "cast("; type_human_readable$(type_of_cast(root)); ", ";
vwatch64_SKIP_2152:::: 
vwatch64_LABEL_2153:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2153): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2153 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2153
        ast_dump_pretty ast_get_child(root, 1), 0
vwatch64_SKIP_2153:::: 
vwatch64_LABEL_2154:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2154): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2154 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2154
        print #1, ")";
vwatch64_SKIP_2154:::: 
    end select
vwatch64_LABEL_2156:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2156): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2156
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2071: GOTO vwatch64_LABEL_2071
    CASE 2072: GOTO vwatch64_LABEL_2072
    CASE 2073: GOTO vwatch64_LABEL_2073
    CASE 2074: GOTO vwatch64_LABEL_2074
    CASE 2075: GOTO vwatch64_LABEL_2075
    CASE 2077: GOTO vwatch64_LABEL_2077
    CASE 2078: GOTO vwatch64_LABEL_2078
    CASE 2080: GOTO vwatch64_LABEL_2080
    CASE 2081: GOTO vwatch64_LABEL_2081
    CASE 2082: GOTO vwatch64_LABEL_2082
    CASE 2083: GOTO vwatch64_LABEL_2083
    CASE 2084: GOTO vwatch64_LABEL_2084
    CASE 2085: GOTO vwatch64_LABEL_2085
    CASE 2086: GOTO vwatch64_LABEL_2086
    CASE 2087: GOTO vwatch64_LABEL_2087
    CASE 2088: GOTO vwatch64_LABEL_2088
    CASE 2089: GOTO vwatch64_LABEL_2089
    CASE 2090: GOTO vwatch64_LABEL_2090
    CASE 2091: GOTO vwatch64_LABEL_2091
    CASE 2092: GOTO vwatch64_LABEL_2092
    CASE 2093: GOTO vwatch64_LABEL_2093
    CASE 2095: GOTO vwatch64_LABEL_2095
    CASE 2096: GOTO vwatch64_LABEL_2096
    CASE 2097: GOTO vwatch64_LABEL_2097
    CASE 2098: GOTO vwatch64_LABEL_2098
    CASE 2099: GOTO vwatch64_LABEL_2099
    CASE 2101: GOTO vwatch64_LABEL_2101
    CASE 2102: GOTO vwatch64_LABEL_2102
    CASE 2103: GOTO vwatch64_LABEL_2103
    CASE 2104: GOTO vwatch64_LABEL_2104
    CASE 2106: GOTO vwatch64_LABEL_2106
    CASE 2107: GOTO vwatch64_LABEL_2107
    CASE 2108: GOTO vwatch64_LABEL_2108
    CASE 2109: GOTO vwatch64_LABEL_2109
    CASE 2110: GOTO vwatch64_LABEL_2110
    CASE 2111: GOTO vwatch64_LABEL_2111
    CASE 2112: GOTO vwatch64_LABEL_2112
    CASE 2113: GOTO vwatch64_LABEL_2113
    CASE 2114: GOTO vwatch64_LABEL_2114
    CASE 2115: GOTO vwatch64_LABEL_2115
    CASE 2117: GOTO vwatch64_LABEL_2117
    CASE 2118: GOTO vwatch64_LABEL_2118
    CASE 2119: GOTO vwatch64_LABEL_2119
    CASE 2120: GOTO vwatch64_LABEL_2120
    CASE 2121: GOTO vwatch64_LABEL_2121
    CASE 2122: GOTO vwatch64_LABEL_2122
    CASE 2123: GOTO vwatch64_LABEL_2123
    CASE 2124: GOTO vwatch64_LABEL_2124
    CASE 2125: GOTO vwatch64_LABEL_2125
    CASE 2126: GOTO vwatch64_LABEL_2126
    CASE 2128: GOTO vwatch64_LABEL_2128
    CASE 2129: GOTO vwatch64_LABEL_2129
    CASE 2130: GOTO vwatch64_LABEL_2130
    CASE 2131: GOTO vwatch64_LABEL_2131
    CASE 2132: GOTO vwatch64_LABEL_2132
    CASE 2133: GOTO vwatch64_LABEL_2133
    CASE 2134: GOTO vwatch64_LABEL_2134
    CASE 2135: GOTO vwatch64_LABEL_2135
    CASE 2136: GOTO vwatch64_LABEL_2136
    CASE 2138: GOTO vwatch64_LABEL_2138
    CASE 2139: GOTO vwatch64_LABEL_2139
    CASE 2140: GOTO vwatch64_LABEL_2140
    CASE 2141: GOTO vwatch64_LABEL_2141
    CASE 2142: GOTO vwatch64_LABEL_2142
    CASE 2144: GOTO vwatch64_LABEL_2144
    CASE 2145: GOTO vwatch64_LABEL_2145
    CASE 2146: GOTO vwatch64_LABEL_2146
    CASE 2147: GOTO vwatch64_LABEL_2147
    CASE 2148: GOTO vwatch64_LABEL_2148
    CASE 2150: GOTO vwatch64_LABEL_2150
    CASE 2152: GOTO vwatch64_LABEL_2152
    CASE 2153: GOTO vwatch64_LABEL_2153
    CASE 2154: GOTO vwatch64_LABEL_2154
    CASE 2156: GOTO vwatch64_LABEL_2156
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub ast_dump_constants
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_2159:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2159): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2159 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2159
    print #1, " ID    Type      Value"
vwatch64_SKIP_2159:::: 
vwatch64_LABEL_2160:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2160): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2160 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2160
    for i = 1 to ast_last_constant
vwatch64_SKIP_2160:::: 
vwatch64_LABEL_2161:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2161): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2161 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2161
        print #1, using "###    &    &"; i; type_human_readable(ast_constant_types(i)); ast_constants(i)
vwatch64_SKIP_2161:::: 
vwatch64_LABEL_2162:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2162): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2162 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2162
    next i
vwatch64_SKIP_2162:::: 
vwatch64_LABEL_2163:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2163): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2163
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2159: GOTO vwatch64_LABEL_2159
    CASE 2160: GOTO vwatch64_LABEL_2160
    CASE 2161: GOTO vwatch64_LABEL_2161
    CASE 2162: GOTO vwatch64_LABEL_2162
    CASE 2163: GOTO vwatch64_LABEL_2163
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub
'*INCLUDE file merged: 'emitters/immediate/immediate.bm'
sub imm_init
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    redim imm_stack(ps_last_var_index) as imm_value_t
vwatch64_LABEL_2167:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2167): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2167
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2167: GOTO vwatch64_LABEL_2167
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub imm_run(node)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    dim dummy_result as imm_value_t
vwatch64_LABEL_2171:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2171): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2171 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2171
    imm_eval node, dummy_result
vwatch64_SKIP_2171:::: 
vwatch64_LABEL_2172:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2172): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2172
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2171: GOTO vwatch64_LABEL_2171
    CASE 2172: GOTO vwatch64_LABEL_2172
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub imm_eval(node, result as imm_value_t)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_2175:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2175): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2175 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2175
    ref = ast_nodes(node).ref
vwatch64_SKIP_2175:::: 
vwatch64_LABEL_2176:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2176): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2176 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2176
    select case ast_nodes(node).typ
vwatch64_SKIP_2176:::: 
    case AST_ASSIGN
vwatch64_LABEL_2178:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2178): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2178 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2178
        imm_do_assign node
vwatch64_SKIP_2178:::: 
    case AST_IF
vwatch64_LABEL_2180:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2180): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2180 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2180
        imm_do_conditional node
vwatch64_SKIP_2180:::: 
    case AST_DO_PRE
vwatch64_LABEL_2182:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2182): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2182 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2182
        print "DO WHILE; executing once"
vwatch64_SKIP_2182:::: 
vwatch64_LABEL_2183:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2183): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2183 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2183
        imm_eval ast_get_child(node, 2), result
vwatch64_SKIP_2183:::: 
    case AST_DO_POST
vwatch64_LABEL_2185:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2185): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2185 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2185
        print "LOOP WHILE; executing once"
vwatch64_SKIP_2185:::: 
vwatch64_LABEL_2186:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2186): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2186 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2186
        imm_eval ast_get_child(node, 2), result
vwatch64_SKIP_2186:::: 
    case AST_FOR
vwatch64_LABEL_2188:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2188): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2188 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2188
        print "FOR; skipping"
vwatch64_SKIP_2188:::: 
    case AST_SELECT
vwatch64_LABEL_2190:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2190): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2190 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2190
        print "SELECT; skipping"
vwatch64_SKIP_2190:::: 
    case AST_CALL
vwatch64_LABEL_2192:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2192): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2192 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2192
        imm_do_call node, result
vwatch64_SKIP_2192:::: 
    case AST_CONSTANT
vwatch64_LABEL_2194:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2194): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2194 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2194
        result.t = ast_constant_types(ref)
vwatch64_SKIP_2194:::: 
vwatch64_LABEL_2195:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2195): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2195 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2195
        if result.t = TYPE_STRING then result.s = ast_constants(ref) else result.n = val(ast_constants(ref))
vwatch64_SKIP_2195:::: 
    case AST_BLOCK
vwatch64_LABEL_2197:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2197): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2197 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2197
        for i = 1 to ast_num_children(node)
vwatch64_SKIP_2197:::: 
vwatch64_LABEL_2198:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2198): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2198 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2198
            imm_eval ast_get_child(node, i), result
vwatch64_SKIP_2198:::: 
vwatch64_LABEL_2199:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2199): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2199 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2199
        next i
vwatch64_SKIP_2199:::: 
    case AST_VAR
vwatch64_LABEL_2201:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2201): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2201 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2201
        sp = imm_var_stack_pos(ref)
vwatch64_SKIP_2201:::: 
vwatch64_LABEL_2202:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2202): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2202 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2202
        result.s = imm_stack(sp).s
vwatch64_SKIP_2202:::: 
vwatch64_LABEL_2203:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2203): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2203 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2203
        result.n = imm_stack(sp).n
vwatch64_SKIP_2203:::: 
    case AST_CAST
vwatch64_LABEL_2205:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2205): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2205 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2205
        imm_do_cast node, result
vwatch64_SKIP_2205:::: 
    end select
vwatch64_LABEL_2207:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2207): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2207
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2175: GOTO vwatch64_LABEL_2175
    CASE 2176: GOTO vwatch64_LABEL_2176
    CASE 2178: GOTO vwatch64_LABEL_2178
    CASE 2180: GOTO vwatch64_LABEL_2180
    CASE 2182: GOTO vwatch64_LABEL_2182
    CASE 2183: GOTO vwatch64_LABEL_2183
    CASE 2185: GOTO vwatch64_LABEL_2185
    CASE 2186: GOTO vwatch64_LABEL_2186
    CASE 2188: GOTO vwatch64_LABEL_2188
    CASE 2190: GOTO vwatch64_LABEL_2190
    CASE 2192: GOTO vwatch64_LABEL_2192
    CASE 2194: GOTO vwatch64_LABEL_2194
    CASE 2195: GOTO vwatch64_LABEL_2195
    CASE 2197: GOTO vwatch64_LABEL_2197
    CASE 2198: GOTO vwatch64_LABEL_2198
    CASE 2199: GOTO vwatch64_LABEL_2199
    CASE 2201: GOTO vwatch64_LABEL_2201
    CASE 2202: GOTO vwatch64_LABEL_2202
    CASE 2203: GOTO vwatch64_LABEL_2203
    CASE 2205: GOTO vwatch64_LABEL_2205
    CASE 2207: GOTO vwatch64_LABEL_2207
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
    vwatch64_VARIABLEDATA(1).VALUE = STR$(ref)
    vwatch64_VARIABLEDATA(2).VALUE = STR$(result.t)
    vwatch64_VARIABLEDATA(3).VALUE = result.s
    vwatch64_VARIABLEDATA(4).VALUE = STR$(result.n)
    vwatch64_VARIABLEDATA(5).VALUE = STR$(i)
    vwatch64_VARIABLEDATA(6).VALUE = STR$(sp)
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
    CASE 1: ref = _CV(LONG, vwatch64_EXCHANGEDATA)
    CASE 2: result.t = _CV(LONG, vwatch64_EXCHANGEDATA)
    CASE 3: result.s = vwatch64_EXCHANGEDATA
    CASE 4: result.n = _CV(LONG, vwatch64_EXCHANGEDATA)
    CASE 5: i = _CV(LONG, vwatch64_EXCHANGEDATA)
    CASE 6: sp = _CV(LONG, vwatch64_EXCHANGEDATA)
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub imm_do_conditional(node)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    dim condition as imm_value_t
vwatch64_LABEL_2211:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2211): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2211 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2211
    imm_eval ast_get_child(node, 1), condition
vwatch64_SKIP_2211:::: 
vwatch64_LABEL_2212:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2212): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2212 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2212
    ?condition.n
vwatch64_SKIP_2212:::: 
vwatch64_LABEL_2213:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2213): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2213 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2213
    if condition.n then
vwatch64_SKIP_2213:::: 
vwatch64_LABEL_2214:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2214): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2214 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2214
        imm_run ast_get_child(node, 2)
vwatch64_SKIP_2214:::: 
vwatch64_LABEL_2215:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2215): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2215 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2215
    elseif ast_num_children(node) > 2 then
vwatch64_SKIP_2215:::: 
vwatch64_LABEL_2216:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2216): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2216 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2216
        imm_run ast_get_child(node, 3)
vwatch64_SKIP_2216:::: 
vwatch64_LABEL_2217:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2217): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2217 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2217
    end if
vwatch64_SKIP_2217:::: 
vwatch64_LABEL_2218:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2218): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2218
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2211: GOTO vwatch64_LABEL_2211
    CASE 2212: GOTO vwatch64_LABEL_2212
    CASE 2213: GOTO vwatch64_LABEL_2213
    CASE 2214: GOTO vwatch64_LABEL_2214
    CASE 2215: GOTO vwatch64_LABEL_2215
    CASE 2216: GOTO vwatch64_LABEL_2216
    CASE 2217: GOTO vwatch64_LABEL_2217
    CASE 2218: GOTO vwatch64_LABEL_2218
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub imm_do_cast(node, result as imm_value_t)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_2221:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2221): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2221 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2221
    imm_eval ast_get_child(node, 1), result
vwatch64_SKIP_2221:::: 
vwatch64_LABEL_2222:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2222): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2222 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2222
    result.t = ast_nodes(node).ref
vwatch64_SKIP_2222:::: 
vwatch64_LABEL_2223:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2223): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2223 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2223
    imm_enforce_type result
vwatch64_SKIP_2223:::: 
vwatch64_LABEL_2224:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2224): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2224
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2221: GOTO vwatch64_LABEL_2221
    CASE 2222: GOTO vwatch64_LABEL_2222
    CASE 2223: GOTO vwatch64_LABEL_2223
    CASE 2224: GOTO vwatch64_LABEL_2224
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
    vwatch64_VARIABLEDATA(7).VALUE = STR$(result.t)
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
    CASE 7: result.t = _CV(LONG, vwatch64_EXCHANGEDATA)
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub imm_do_assign(node)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    dim rvalue as imm_value_t
vwatch64_LABEL_2228:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2228): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2228 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2228
    imm_eval ast_get_child(node, 1), rvalue
vwatch64_SKIP_2228:::: 
vwatch64_LABEL_2229:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2229): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2229 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2229
    sp = imm_var_stack_pos(ast_nodes(node).ref)
vwatch64_SKIP_2229:::: 
vwatch64_LABEL_2230:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2230): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2230 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2230
    imm_stack(sp).t = type_of_var(node)
vwatch64_SKIP_2230:::: 
vwatch64_LABEL_2231:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2231): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2231 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2231
    if type_of_var(node) = TYPE_STRING then
vwatch64_SKIP_2231:::: 
vwatch64_LABEL_2232:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2232): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2232 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2232
        imm_stack(sp).s = rvalue.s
vwatch64_SKIP_2232:::: 
vwatch64_LABEL_2233:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2233): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2233 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2233
    else
vwatch64_SKIP_2233:::: 
vwatch64_LABEL_2234:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2234): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2234 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2234
        imm_stack(sp).n = rvalue.n
vwatch64_SKIP_2234:::: 
vwatch64_LABEL_2235:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2235): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2235 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2235
    end if
vwatch64_SKIP_2235:::: 
vwatch64_LABEL_2236:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2236): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2236
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2228: GOTO vwatch64_LABEL_2228
    CASE 2229: GOTO vwatch64_LABEL_2229
    CASE 2230: GOTO vwatch64_LABEL_2230
    CASE 2231: GOTO vwatch64_LABEL_2231
    CASE 2232: GOTO vwatch64_LABEL_2232
    CASE 2233: GOTO vwatch64_LABEL_2233
    CASE 2234: GOTO vwatch64_LABEL_2234
    CASE 2235: GOTO vwatch64_LABEL_2235
    CASE 2236: GOTO vwatch64_LABEL_2236
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
    vwatch64_VARIABLEDATA(8).VALUE = STR$(sp)
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
    CASE 8: sp = _CV(LONG, vwatch64_EXCHANGEDATA)
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

sub imm_enforce_type(result as imm_value_t)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_2239:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2239): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2239 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2239
    select case result.t
vwatch64_SKIP_2239:::: 
    case TYPE_INTEGER
vwatch64_LABEL_2241:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2241): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2241 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2241
        result.n = cint(result.n)
vwatch64_SKIP_2241:::: 
    case TYPE_LONG
vwatch64_LABEL_2243:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2243): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2243 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2243
        result.n = clng(result.n)
vwatch64_SKIP_2243:::: 
    case TYPE_INTEGER64
vwatch64_LABEL_2245:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2245): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2245 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2245
        result.n = _round(result.n)
vwatch64_SKIP_2245:::: 
    case TYPE_SINGLE
vwatch64_LABEL_2247:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2247): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2247 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2247
        result.n = csng(result.n)
vwatch64_SKIP_2247:::: 
    case TYPE_DOUBLE
vwatch64_LABEL_2249:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2249): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2249 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2249
        result.n = cdbl(result.n)
vwatch64_SKIP_2249:::: 
    case TYPE_QUAD, TYPE_STRING
        'Nothing to do here
    end select
vwatch64_LABEL_2253:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2253): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2253
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2239: GOTO vwatch64_LABEL_2239
    CASE 2241: GOTO vwatch64_LABEL_2241
    CASE 2243: GOTO vwatch64_LABEL_2243
    CASE 2245: GOTO vwatch64_LABEL_2245
    CASE 2247: GOTO vwatch64_LABEL_2247
    CASE 2249: GOTO vwatch64_LABEL_2249
    CASE 2253: GOTO vwatch64_LABEL_2253
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
    vwatch64_VARIABLEDATA(9).VALUE = STR$(result.n)
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
    CASE 9: result.n = _CV(LONG, vwatch64_EXCHANGEDATA)
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub

function imm_var_stack_pos(var)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
vwatch64_LABEL_2256:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2256): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2256 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2256
    imm_var_stack_pos = htable_entries(var).v2
vwatch64_SKIP_2256:::: 
vwatch64_LABEL_2257:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2257): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2257
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT FUNCTION
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2256: GOTO vwatch64_LABEL_2256
    CASE 2257: GOTO vwatch64_LABEL_2257
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end function

sub imm_do_call(node, result as imm_value_t)
    vwatch64_SUBLEVEL = vwatch64_SUBLEVEL + 1
    dim v1 as imm_value_t
    dim v2 as imm_value_t
vwatch64_LABEL_2262:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2262): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2262 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2262
    result.t = type_of_call(node)
vwatch64_SKIP_2262:::: 
vwatch64_LABEL_2263:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2263): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2263 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2263
    select case ast_nodes(node).ref
vwatch64_SKIP_2263:::: 
    case TOK_PRINT
vwatch64_LABEL_2265:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2265): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2265 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2265
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2265:::: 
vwatch64_LABEL_2266:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2266): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2266 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2266
        if v1.t = TYPE_STRING then print v1.s else print v1.n
vwatch64_SKIP_2266:::: 
    case TOK_PLUS
vwatch64_LABEL_2268:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2268): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2268 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2268
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2268:::: 
vwatch64_LABEL_2269:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2269): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2269 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2269
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2269:::: 
vwatch64_LABEL_2270:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2270): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2270 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2270
        if result.t = TYPE_STRING then result.s = v1.s + v2.s else result.n = v1.n + v2.n
vwatch64_SKIP_2270:::: 
    case TOK_DASH
vwatch64_LABEL_2272:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2272): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2272 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2272
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2272:::: 
vwatch64_LABEL_2273:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2273): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2273 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2273
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2273:::: 
vwatch64_LABEL_2274:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2274): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2274 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2274
        result.n = v1.n - v2.n
vwatch64_SKIP_2274:::: 
    case TOK_STAR
vwatch64_LABEL_2276:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2276): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2276 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2276
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2276:::: 
vwatch64_LABEL_2277:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2277): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2277 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2277
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2277:::: 
vwatch64_LABEL_2278:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2278): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2278 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2278
        result.n = v1.n * v2.n
vwatch64_SKIP_2278:::: 
    case TOK_SLASH
vwatch64_LABEL_2280:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2280): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2280 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2280
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2280:::: 
vwatch64_LABEL_2281:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2281): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2281 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2281
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2281:::: 
vwatch64_LABEL_2282:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2282): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2282 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2282
        result.n = v1.n / v2.n
vwatch64_SKIP_2282:::: 
    case TOK_POWER
vwatch64_LABEL_2284:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2284): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2284 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2284
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2284:::: 
vwatch64_LABEL_2285:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2285): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2285 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2285
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2285:::: 
vwatch64_LABEL_2286:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2286): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2286 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2286
        result.n = v1.n ^ v2.n
vwatch64_SKIP_2286:::: 
    case TOK_NOT
vwatch64_LABEL_2288:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2288): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2288 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2288
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2288:::: 
vwatch64_LABEL_2289:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2289): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2289 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2289
        result.n = not v1.n
vwatch64_SKIP_2289:::: 
    case TOK_AND
vwatch64_LABEL_2291:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2291): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2291 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2291
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2291:::: 
vwatch64_LABEL_2292:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2292): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2292 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2292
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2292:::: 
vwatch64_LABEL_2293:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2293): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2293 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2293
        result.n = v1.n and v2.n
vwatch64_SKIP_2293:::: 
    case TOK_OR
vwatch64_LABEL_2295:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2295): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2295 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2295
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2295:::: 
vwatch64_LABEL_2296:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2296): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2296 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2296
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2296:::: 
vwatch64_LABEL_2297:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2297): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2297 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2297
        result.n = v1.n or v2.n
vwatch64_SKIP_2297:::: 
    case TOK_XOR
vwatch64_LABEL_2299:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2299): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2299 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2299
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2299:::: 
vwatch64_LABEL_2300:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2300): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2300 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2300
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2300:::: 
vwatch64_LABEL_2301:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2301): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2301 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2301
        result.n = v1.n xor v2.n
vwatch64_SKIP_2301:::: 
    case TOK_EQV
vwatch64_LABEL_2303:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2303): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2303 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2303
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2303:::: 
vwatch64_LABEL_2304:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2304): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2304 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2304
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2304:::: 
vwatch64_LABEL_2305:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2305): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2305 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2305
        result.n = v1.n eqv v2.n
vwatch64_SKIP_2305:::: 
    case TOK_IMP
vwatch64_LABEL_2307:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2307): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2307 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2307
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2307:::: 
vwatch64_LABEL_2308:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2308): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2308 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2308
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2308:::: 
vwatch64_LABEL_2309:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2309): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2309 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2309
        result.n = v1.n imp v2.n
vwatch64_SKIP_2309:::: 
    case TOK_EQUALS
vwatch64_LABEL_2311:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2311): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2311 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2311
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2311:::: 
vwatch64_LABEL_2312:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2312): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2312 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2312
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2312:::: 
vwatch64_LABEL_2313:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2313): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2313 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2313
        if result.t = TYPE_STRING then result.n = v1.s = v2.s else result.n = v1.n = v2.n
vwatch64_SKIP_2313:::: 
    case TOK_CMP_LT
vwatch64_LABEL_2315:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2315): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2315 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2315
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2315:::: 
vwatch64_LABEL_2316:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2316): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2316 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2316
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2316:::: 
vwatch64_LABEL_2317:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2317): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2317 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2317
        result.n = v1.n < v2.n
vwatch64_SKIP_2317:::: 
    case TOK_CMP_GT
vwatch64_LABEL_2319:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2319): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2319 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2319
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2319:::: 
vwatch64_LABEL_2320:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2320): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2320 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2320
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2320:::: 
vwatch64_LABEL_2321:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2321): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2321 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2321
        result.n = v1.n > v2.n
vwatch64_SKIP_2321:::: 
    case TOK_CMP_LTEQ
vwatch64_LABEL_2323:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2323): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2323 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2323
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2323:::: 
vwatch64_LABEL_2324:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2324): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2324 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2324
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2324:::: 
vwatch64_LABEL_2325:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2325): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2325 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2325
        result.n = v1.n <= v2.n
vwatch64_SKIP_2325:::: 
    case TOK_CMP_GTEQ
vwatch64_LABEL_2327:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2327): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2327 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2327
        imm_eval ast_get_child(node, 1), v1
vwatch64_SKIP_2327:::: 
vwatch64_LABEL_2328:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2328): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2328 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2328
        imm_eval ast_get_child(node, 2), v2
vwatch64_SKIP_2328:::: 
vwatch64_LABEL_2329:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2329): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2329 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2329
        result.n = v1.n >= v2.n
vwatch64_SKIP_2329:::: 
    end select
vwatch64_LABEL_2331:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2331): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN GOTO vwatch64_SKIP_2331 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2331
    imm_enforce_type result
vwatch64_SKIP_2331:::: 
vwatch64_LABEL_2332:::: GOSUB vwatch64_VARIABLEWATCH: vwatch64_NEXTLINE = vwatch64_CHECKBREAKPOINT(2332): IF vwatch64_NEXTLINE > 0 THEN GOTO vwatch64_SETNEXTLINE ELSE IF vwatch64_NEXTLINE = -2 THEN vWATCH64_DUMMY%% = 0 ELSE IF vwatch64_NEXTLINE = -1 THEN GOSUB vwatch64_SETVARIABLE: GOTO vwatch64_LABEL_2332
vwatch64_SUBLEVEL = vwatch64_SUBLEVEL - 1
EXIT SUB
vwatch64_SETNEXTLINE:
SELECT CASE vwatch64_NEXTLINE
    CASE 2262: GOTO vwatch64_LABEL_2262
    CASE 2263: GOTO vwatch64_LABEL_2263
    CASE 2265: GOTO vwatch64_LABEL_2265
    CASE 2266: GOTO vwatch64_LABEL_2266
    CASE 2268: GOTO vwatch64_LABEL_2268
    CASE 2269: GOTO vwatch64_LABEL_2269
    CASE 2270: GOTO vwatch64_LABEL_2270
    CASE 2272: GOTO vwatch64_LABEL_2272
    CASE 2273: GOTO vwatch64_LABEL_2273
    CASE 2274: GOTO vwatch64_LABEL_2274
    CASE 2276: GOTO vwatch64_LABEL_2276
    CASE 2277: GOTO vwatch64_LABEL_2277
    CASE 2278: GOTO vwatch64_LABEL_2278
    CASE 2280: GOTO vwatch64_LABEL_2280
    CASE 2281: GOTO vwatch64_LABEL_2281
    CASE 2282: GOTO vwatch64_LABEL_2282
    CASE 2284: GOTO vwatch64_LABEL_2284
    CASE 2285: GOTO vwatch64_LABEL_2285
    CASE 2286: GOTO vwatch64_LABEL_2286
    CASE 2288: GOTO vwatch64_LABEL_2288
    CASE 2289: GOTO vwatch64_LABEL_2289
    CASE 2291: GOTO vwatch64_LABEL_2291
    CASE 2292: GOTO vwatch64_LABEL_2292
    CASE 2293: GOTO vwatch64_LABEL_2293
    CASE 2295: GOTO vwatch64_LABEL_2295
    CASE 2296: GOTO vwatch64_LABEL_2296
    CASE 2297: GOTO vwatch64_LABEL_2297
    CASE 2299: GOTO vwatch64_LABEL_2299
    CASE 2300: GOTO vwatch64_LABEL_2300
    CASE 2301: GOTO vwatch64_LABEL_2301
    CASE 2303: GOTO vwatch64_LABEL_2303
    CASE 2304: GOTO vwatch64_LABEL_2304
    CASE 2305: GOTO vwatch64_LABEL_2305
    CASE 2307: GOTO vwatch64_LABEL_2307
    CASE 2308: GOTO vwatch64_LABEL_2308
    CASE 2309: GOTO vwatch64_LABEL_2309
    CASE 2311: GOTO vwatch64_LABEL_2311
    CASE 2312: GOTO vwatch64_LABEL_2312
    CASE 2313: GOTO vwatch64_LABEL_2313
    CASE 2315: GOTO vwatch64_LABEL_2315
    CASE 2316: GOTO vwatch64_LABEL_2316
    CASE 2317: GOTO vwatch64_LABEL_2317
    CASE 2319: GOTO vwatch64_LABEL_2319
    CASE 2320: GOTO vwatch64_LABEL_2320
    CASE 2321: GOTO vwatch64_LABEL_2321
    CASE 2323: GOTO vwatch64_LABEL_2323
    CASE 2324: GOTO vwatch64_LABEL_2324
    CASE 2325: GOTO vwatch64_LABEL_2325
    CASE 2327: GOTO vwatch64_LABEL_2327
    CASE 2328: GOTO vwatch64_LABEL_2328
    CASE 2329: GOTO vwatch64_LABEL_2329
    CASE 2331: GOTO vwatch64_LABEL_2331
    CASE 2332: GOTO vwatch64_LABEL_2332
END SELECT

vwatch64_VARIABLEWATCH:
IF vwatch64_HEADER.CONNECTED = 0 THEN RETURN
ON ERROR GOTO vwatch64_FILEERROR
    vwatch64_VARIABLEDATA(10).VALUE = STR$(result.t)
    vwatch64_VARIABLEDATA(11).VALUE = result.s
    vwatch64_VARIABLEDATA(12).VALUE = STR$(result.n)
ON ERROR GOTO 0
RETURN


vwatch64_SETVARIABLE:
ON ERROR GOTO vwatch64_CLIENTFILEERROR
GET #vwatch64_CLIENTFILE, vwatch64_EXCHANGEBLOCK, vwatch64_EXCHANGEDATASIZE$4
vwatch64_TARGETVARINDEX = CVL(vwatch64_EXCHANGEDATASIZE$4)
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATASIZE$4
vwatch64_EXCHANGEDATA = SPACE$(CVL(vwatch64_EXCHANGEDATASIZE$4))
GET #vwatch64_CLIENTFILE, , vwatch64_EXCHANGEDATA
vwatch64_BREAKPOINT.ACTION = vwatch64_READY
PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
ON ERROR GOTO vwatch64_FILEERROR

SELECT CASE vwatch64_TARGETVARINDEX
    CASE 10: result.t = _CV(LONG, vwatch64_EXCHANGEDATA)
    CASE 11: result.s = vwatch64_EXCHANGEDATA
    CASE 12: result.n = _CV(LONG, vwatch64_EXCHANGEDATA)
END SELECT
GOSUB vwatch64_VARIABLEWATCH
ON ERROR GOTO 0
RETURN
end sub


'--------------------------------------------------------------------------------
'vWATCH64 procedures:
'--------------------------------------------------------------------------------
SUB vwatch64_CONNECTTOHOST
    DIM k AS LONG
    DIM Message1$, Message2$, NoGo%
    DIM FileIsOpen%, FileExists%

    vwatch64_CHECKFILE:
    IF _FILEEXISTS(vwatch64_FILENAME) = 0 THEN
        Message1$ = "vWATCH64 doesn't seem to be running."
        Message2$ = "(Checking for 'vwatch64.dat'; ESC to cancel...)"
        IF NOT _SCREENHIDE AND _DEST <> _CONSOLE THEN
            _TITLE "Connecting to vWATCH64..."
            _PRINTSTRING(_WIDTH \ 2 - LEN(Message1$) \ 2, _HEIGHT \ 2), Message1$
            _PRINTSTRING(_WIDTH \ 2 - LEN(Message2$) \ 2, _HEIGHT \ 2 + 1), Message2$
        ELSE
            _CONSOLETITLE "Connecting to vWATCH64..."
            PRINT Message1$: PRINT Message1$
        END IF
        DO: _LIMIT 30
            k = _KEYHIT
            IF k = -27 THEN SYSTEM
            IF _FILEEXISTS(vwatch64_FILENAME) THEN _KEYCLEAR: EXIT DO
        LOOP
    END IF

    vwatch64_CLIENTFILE = 20078
    OPEN vwatch64_FILENAME FOR BINARY AS vwatch64_CLIENTFILE

    'Check if a connection is already active
    IF LOF(vwatch64_CLIENTFILE) > 0 THEN
        'Check if the file can be deleted; if so, vWATCH64 is not running.
        CLOSE #vwatch64_CLIENTFILE
        NoGo% = 0
        FileIsOpen% = _SHELLHIDE("lsof vwatch64.dat")
        FileExists% = _FILEEXISTS(vwatch64_FILENAME)
        IF FileIsOpen% = 127 THEN 'command LSOF not found.
            FileIsOpen% = -1 'consider that vWATCH64 is running.
        ELSEIF FileIsOpen% = 0 THEN 'file is in use.
            FileIsOpen% = -1
        ELSEIF FileIsOpen% = 1 THEN 'file is not in use.
            FileIsOpen% = 0 'consider that vWATCH64 is NOT running.
        END IF
        IF FileExists% AND FileIsOpen% = 0 THEN
            ON ERROR GOTO vwatch64_FILEERROR
            KILL vwatch64_FILENAME
            ON ERROR GOTO 0
        ELSEIF FileExists% AND FileIsOpen% THEN
            NoGo% = -1
        END IF

        IF NoGo% THEN
            CLS
            Message1$ = "ERROR: vWATCH64 is already connected to another"
            Message2$ = "client/debuggee."
            IF NOT _SCREENHIDE AND _DEST <> _CONSOLE THEN
                _TITLE "FAILED!"
                _PRINTSTRING(_WIDTH \ 2 - LEN(Message1$) \ 2, _HEIGHT \ 2), Message1$
                _PRINTSTRING(_WIDTH \ 2 - LEN(Message2$) \ 2, _HEIGHT \ 2 + 1), Message2$
            ELSE
                _CONSOLETITLE "FAILED!"
                PRINT Message1$: PRINT Message1$
            END IF
            END
        END IF
        GOTO vwatch64_CHECKFILE
    ELSEIF LOF(vwatch64_CLIENTFILE) = 0 THEN
        'Check if the file can be deleted; if so, vWATCH64 is not running.
        CLOSE #vwatch64_CLIENTFILE
        FileIsOpen% = _SHELLHIDE("lsof vwatch64.dat")
        IF FileIsOpen% = 127 THEN 'command LSOF not found.
            FileIsOpen% = -1 'consider that vWATCH64 is running.
        ELSEIF FileIsOpen% = 0 THEN 'file is in use.
            FileIsOpen% = -1
        ELSEIF FileIsOpen% = 1 THEN 'file is not in use.
            FileIsOpen% = 0 'consider that vWATCH64 is NOT running.
        END IF
        IF FileIsOpen% = 0 THEN
            ON ERROR GOTO vwatch64_FILEERROR
            KILL vwatch64_FILENAME
            ON ERROR GOTO 0
            IF _FILEEXISTS(vwatch64_FILENAME) = 0 THEN GOTO vwatch64_CHECKFILE
        END IF
    END IF

    OPEN vwatch64_FILENAME FOR BINARY AS vwatch64_CLIENTFILE
    vwatch64_CLIENT.NAME = "../65/src/65.bas"
    vwatch64_CLIENT.CHECKSUM = vwatch64_CHECKSUM
    vwatch64_CLIENT.TOTALSOURCELINES = 2332
    vwatch64_CLIENT.TOTALVARIABLES = 12
    vwatch64_CLIENT.PID = vwatch64_GETPID&
    vwatch64_CLIENT.EXENAME = COMMAND$(0)

    'Send this client's version and connection request
    vwatch64_HEADER.CLIENT_ID = vwatch64_ID
    vwatch64_HEADER.VERSION = vwatch64_VERSION
    vwatch64_HEADER.CONNECTED = -1
    PUT #vwatch64_CLIENTFILE, 1, vwatch64_HEADER
    PUT #vwatch64_CLIENTFILE, vwatch64_DATAINFOBLOCK, vwatch64_VARIABLES()

    'Wait for authorization:
    CLS
    Message1$ = "Waiting for authorization; ESC to cancel..."
    IF NOT _SCREENHIDE AND _DEST <> _CONSOLE THEN
        _PRINTSTRING(_WIDTH \ 2 - LEN(Message1$) \ 2, _HEIGHT \ 2), Message1$
    ELSE
        PRINT Message1$
    END IF
    DO: _LIMIT 30
        GET #vwatch64_CLIENTFILE, vwatch64_HEADERBLOCK, vwatch64_HEADER
        k = _KEYHIT
        IF k = -27 THEN SYSTEM
     LOOP UNTIL vwatch64_HEADER.RESPONSE = -1 OR vwatch64_HEADER.CONNECTED = 0

    IF vwatch64_HEADER.CONNECTED = 0 THEN
        SYSTEM
    END IF

    CLS
    IF NOT _SCREENHIDE AND _DEST <> _CONSOLE THEN
        _TITLE "Untitled"
    ELSE
        _CONSOLETITLE "Untitled"
    END IF
    PUT #vwatch64_CLIENTFILE, vwatch64_CLIENTBLOCK, vwatch64_CLIENT
END SUB

SUB vwatch64_VARIABLEWATCH

    IF vwatch64_HEADER.CONNECTED = 0 THEN EXIT SUB
    ON ERROR GOTO vwatch64_FILEERROR
    ON ERROR GOTO vwatch64_CLIENTFILEERROR
    PUT #vwatch64_CLIENTFILE, vwatch64_DATABLOCK, vwatch64_VARIABLEDATA().VALUE
    ON ERROR GOTO 0
END SUB

FUNCTION vwatch64_CHECKBREAKPOINT&(LineNumber AS LONG)
    STATIC FirstRunDone AS _BYTE
    STATIC StepMode AS _BYTE
    STATIC StepAround AS _BYTE
    STATIC StartLevel AS INTEGER
    DIM k AS LONG
    DIM Message1$, Message2$

    IF FirstRunDone = 0 THEN
        IF vwatch64_HEADER.CONNECTED = 0 THEN
            _DELAY .5
            IF NOT _SCREENHIDE AND _DEST <> _CONSOLE THEN
                _TITLE "Untitled"
            ELSE
                _CONSOLETITLE "Untitled"
            END IF
            FirstRunDone = -1
            EXIT FUNCTION
        END IF
    ELSE
        IF vwatch64_HEADER.CONNECTED = 0 THEN EXIT FUNCTION
    END IF

    vwatch64_CLIENT.LINENUMBER = LineNumber
    ON ERROR GOTO vwatch64_CLIENTFILEERROR
    PUT #vwatch64_CLIENTFILE, vwatch64_CLIENTBLOCK, vwatch64_CLIENT

    'Check if step mode was initiated by the host:
    GET #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
    IF vwatch64_BREAKPOINT.ACTION = vwatch64_NEXTSTEP THEN StepMode = -1
    IF vwatch64_BREAKPOINT.ACTION = vwatch64_SKIPSUB THEN StartLevel = vwatch64_SUBLEVEL - 1: StepAround = -1

    GOSUB vwatch64_PING

    'Get the breakpoint list:
    vwatch64_BREAKPOINT.ACTION = vwatch64_READY
    PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
    GET #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTLISTBLOCK, vwatch64_BREAKPOINTLIST

    IF StepAround = -1 AND vwatch64_SUBLEVEL > StartLevel AND (ASC(vwatch64_BREAKPOINTLIST, LineNumber) <> 1) THEN EXIT FUNCTION
    IF StepAround = -1 AND vwatch64_SUBLEVEL = StartLevel THEN StepAround = 0

    vwatch64_VARIABLEWATCH
    IF vwatch64_CHECKWATCHPOINT = -1 THEN StepMode = -1

    'On the first time this procedure is called, execution is halted,
    'until the user presses F5 or F8 in vWATCH64
    IF FirstRunDone = 0 THEN
        Message1$ = "Hit F8 to run line by line or switch to vWATCH64 and hit F5 to run;"
        Message2$ = "(ESC to quit)"
        IF NOT _SCREENHIDE AND _DEST <> _CONSOLE THEN
            _TITLE Message1$
            _PRINTSTRING(_WIDTH \ 2 - LEN(Message1$) \ 2, _HEIGHT \ 2), Message1$
            _PRINTSTRING(_WIDTH \ 2 - LEN(Message2$) \ 2, _HEIGHT \ 2 + 1), Message2$
        ELSE
            _CONSOLETITLE "Switch to vWATCH64 and hit F5 to run or F8 to run line by line;"
        END IF
        VWATCH64_STOPTIMERS
        DO: _LIMIT 500
            GET #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
            IF vwatch64_BREAKPOINT.ACTION = vwatch64_SETNEXT THEN
                vwatch64_CHECKBREAKPOINT& = vwatch64_BREAKPOINT.LINENUMBER
                vwatch64_BREAKPOINT.ACTION = vwatch64_NEXTSTEP
                vwatch64_BREAKPOINT.LINENUMBER = 0
                PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
                IF NOT _SCREENHIDE AND _DEST <> _CONSOLE THEN
                    _TITLE "Untitled": CLS
                ELSE
                    _CONSOLETITLE "Untitled": CLS
                END IF
                FirstRunDone = -1
                ON ERROR GOTO 0
                EXIT FUNCTION
            END IF
            k = _KEYHIT
            IF k = 16896 THEN vwatch64_BREAKPOINT.ACTION = vwatch64_NEXTSTEP 'F8
            IF k = -27 THEN 'ESC
                CLOSE #vwatch64_CLIENTFILE
                SYSTEM
            END IF
            _KEYCLEAR
            GOSUB vwatch64_PING
        LOOP UNTIL vwatch64_BREAKPOINT.ACTION = vwatch64_CONTINUE OR vwatch64_BREAKPOINT.ACTION = vwatch64_NEXTSTEP OR vwatch64_BREAKPOINT.ACTION = vwatch64_SETVAR OR vwatch64_BREAKPOINT.ACTION = vwatch64_SKIPSUB
        IF vwatch64_BREAKPOINT.ACTION = vwatch64_NEXTSTEP THEN StepMode = -1: StepAround = 0
        IF vwatch64_BREAKPOINT.ACTION = vwatch64_SKIPSUB THEN StartLevel = vwatch64_SUBLEVEL - 1: StepAround = -1: StepMode = -1
        IF vwatch64_BREAKPOINT.ACTION = vwatch64_SETVAR THEN
            vwatch64_CHECKBREAKPOINT& = -1
            StepMode = -1
        END IF
        IF NOT _SCREENHIDE AND _DEST <> _CONSOLE THEN
            _TITLE "Untitled": CLS
        ELSE
            _CONSOLETITLE "Untitled": CLS
        END IF
        FirstRunDone = -1
        ON ERROR GOTO 0
        VWATCH64_STARTTIMERS
        EXIT FUNCTION
    END IF

    IF (ASC(vwatch64_BREAKPOINTLIST, LineNumber) = 2) THEN
            vwatch64_CHECKBREAKPOINT& = -2
            EXIT FUNCTION
    END IF

    IF (ASC(vwatch64_BREAKPOINTLIST, LineNumber) = 1) OR (StepMode = -1) THEN
        VWATCH64_STOPTIMERS
        StepMode = -1
        DO: _LIMIT 500
            GET #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
            IF vwatch64_BREAKPOINT.ACTION = vwatch64_SETNEXT THEN
                vwatch64_CHECKBREAKPOINT& = vwatch64_BREAKPOINT.LINENUMBER
                vwatch64_BREAKPOINT.ACTION = vwatch64_NEXTSTEP
                vwatch64_BREAKPOINT.LINENUMBER = 0
                StepMode = -1
                PUT #vwatch64_CLIENTFILE, vwatch64_BREAKPOINTBLOCK, vwatch64_BREAKPOINT
                ON ERROR GOTO 0
                EXIT FUNCTION
            END IF
            k = _KEYHIT
            IF k = 16896 THEN vwatch64_BREAKPOINT.ACTION = vwatch64_NEXTSTEP 'F8
            _KEYCLEAR
            GOSUB vwatch64_PING
        LOOP UNTIL vwatch64_BREAKPOINT.ACTION = vwatch64_CONTINUE OR vwatch64_BREAKPOINT.ACTION = vwatch64_NEXTSTEP OR vwatch64_BREAKPOINT.ACTION = vwatch64_SETVAR OR vwatch64_BREAKPOINT.ACTION = vwatch64_SKIPSUB
        IF vwatch64_BREAKPOINT.ACTION = vwatch64_CONTINUE THEN StepMode = 0: StepAround = 0
        IF vwatch64_BREAKPOINT.ACTION = vwatch64_NEXTSTEP THEN StepAround = 0: StepMode = -1
        IF vwatch64_BREAKPOINT.ACTION = vwatch64_SKIPSUB THEN StartLevel = vwatch64_SUBLEVEL - 1: StepAround = -1: StepMode = -1
        IF vwatch64_BREAKPOINT.ACTION = vwatch64_SETVAR THEN
            vwatch64_CHECKBREAKPOINT& = -1
            StepMode = -1
        END IF
        VWATCH64_STARTTIMERS
    END IF

    ON ERROR GOTO 0
    EXIT FUNCTION
    vwatch64_PING:
    'Check if connection is still alive on host's end
    GET #vwatch64_CLIENTFILE, vwatch64_HEADERBLOCK, vwatch64_HEADER
    IF vwatch64_HEADER.CONNECTED = 0 THEN
        CLOSE vwatch64_CLIENTFILE
        IF FirstRunDone = 0 THEN FirstRunDone = -1: CLS: _TITLE "Untitled"
        VWATCH64_STARTTIMERS
        EXIT FUNCTION
    END IF
    RETURN
END SUB


FUNCTION vwatch64_CHECKWATCHPOINT
    DIM i AS LONG, DataType$
    GET #vwatch64_CLIENTFILE, vwatch64_WATCHPOINTLISTBLOCK, vwatch64_WATCHPOINTLIST
    FOR i = 1 TO 12
        IF ASC(vwatch64_WATCHPOINTLIST, i) = 1 THEN
            GET #vwatch64_CLIENTFILE, vwatch64_WATCHPOINTEXPBLOCK, vwatch64_WATCHPOINT()
            DataType$ = UCASE$(RTRIM$(vwatch64_VARIABLES(i).DATATYPE))
            IF INSTR(DataType$, "STRING") THEN DataType$ = "STRING"
            IF LEFT$(vwatch64_WATCHPOINT(i).VALUE, 1) = "=" THEN
                SELECT CASE DataType$
                    CASE "STRING"
                       IF RTRIM$(vwatch64_VARIABLEDATA(i).VALUE) = RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 2)) THEN
                            GOTO WatchpointStop
                        END IF
                    CASE ELSE
                       IF VAL(RTRIM$(vwatch64_VARIABLEDATA(i).VALUE)) = VAL(RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 2))) THEN
                           GOTO WatchpointStop
                        END IF
                END SELECT
            ELSEIF LEFT$(vwatch64_WATCHPOINT(i).VALUE, 2) = "<=" THEN
                SELECT CASE DataType$
                    CASE "STRING"
                        IF RTRIM$(vwatch64_VARIABLEDATA(i).VALUE) <= RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 3)) THEN
                            GOTO WatchpointStop
                        END IF
                    CASE ELSE
                        IF VAL(RTRIM$(vwatch64_VARIABLEDATA(i).VALUE)) <= VAL(RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 3))) THEN
                            GOTO WatchpointStop
                        END IF
                END SELECT
            ELSEIF LEFT$(vwatch64_WATCHPOINT(i).VALUE, 2) = ">=" THEN
                SELECT CASE DataType$
                    CASE "STRING"
                        IF RTRIM$(vwatch64_VARIABLEDATA(i).VALUE) >= RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 3)) THEN
                            GOTO WatchpointStop
                        END IF
                    CASE ELSE
                        IF VAL(RTRIM$(vwatch64_VARIABLEDATA(i).VALUE)) >= VAL(RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 3))) THEN
                            GOTO WatchpointStop
                        END IF
                END SELECT
            ELSEIF LEFT$(vwatch64_WATCHPOINT(i).VALUE, 2) = "<>" THEN
                SELECT CASE DataType$
                    CASE "STRING"
                        IF RTRIM$(vwatch64_VARIABLEDATA(i).VALUE) <> RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 3)) THEN
                            GOTO WatchpointStop
                        END IF
                    CASE ELSE
                        IF VAL(RTRIM$(vwatch64_VARIABLEDATA(i).VALUE)) <> VAL(RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 3))) THEN
                            GOTO WatchpointStop
                        END IF
                END SELECT
            ELSEIF LEFT$(vwatch64_WATCHPOINT(i).VALUE, 1) = "<" THEN
                SELECT CASE DataType$
                    CASE "STRING"
                        IF RTRIM$(vwatch64_VARIABLEDATA(i).VALUE) < RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 2)) THEN
                            GOTO WatchpointStop
                        END IF
                    CASE ELSE
                        IF VAL(RTRIM$(vwatch64_VARIABLEDATA(i).VALUE)) < VAL(RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 2))) THEN
                            GOTO WatchpointStop
                        END IF
                END SELECT
            ELSEIF LEFT$(vwatch64_WATCHPOINT(i).VALUE, 1) = ">" THEN
                SELECT CASE DataType$
                    CASE "STRING"
                        IF RTRIM$(vwatch64_VARIABLEDATA(i).VALUE) > RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 2)) THEN
                            GOTO WatchpointStop
                        END IF
                    CASE ELSE
                        IF VAL(RTRIM$(vwatch64_VARIABLEDATA(i).VALUE)) > VAL(RTRIM$(MID$(vwatch64_WATCHPOINT(i).VALUE, 2))) THEN
                            GOTO WatchpointStop
                        END IF
                END SELECT
            END IF
        END IF
    NEXT i

    EXIT FUNCTION

   WatchpointStop:
   vwatch64_WATCHPOINTCOMMAND.ACTION = vwatch64_NEXTSTEP
   vwatch64_WATCHPOINTCOMMAND.LINENUMBER = i
   PUT #vwatch64_CLIENTFILE, vwatch64_WATCHPOINTCOMMANDBLOCK, vwatch64_WATCHPOINTCOMMAND
   vwatch64_CHECKWATCHPOINT = -1
END FUNCTION
'--------------------------------------------------------------------------------
'End of vWATCH64 procedures.
'--------------------------------------------------------------------------------
