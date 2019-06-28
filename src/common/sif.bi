'SIF is the file format used as an intermediate between the parser and
'the various target programs.
'The format is a header followed by:
' - ast_constants
' - ast_constant_types
' - ast_nodes
' - ast_children
' - htable data, structured as multiple instances of:
'     - a string from htable_names
'     - an object from htable_entries
' - type_signatures
'in that order. Each of these are essentially a dump of the relevant structures, with the exception
'that strings a prefixed with a LONG to indicate the length.

type sif_header_t
    version as long
    num_constants as long
    num_ast_nodes as long
    root_node as long 'The AST node that is the root of the tree
    num_hentries as long 'As in htable entries
    num_signatures as long
end type

const SIF_VERSION = 2
