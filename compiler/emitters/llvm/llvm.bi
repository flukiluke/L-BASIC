'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'llvm.bi - Declarations for LLVM compilation target

$include: 'llvm_bindings.bi'

type ll_cg_state_t
    target_machine as _offset
    module as _offset 'Current LLVM module
    builder as _offset 'Current instruction builder
    retvar as _offset 'The variable whose value will be loaded & returned
end type

dim shared ll_cg_state as ll_cg_state_t

'Pure convenience so we don't have to look up these functions
'every time we want to emit a call to them.
type ll_cg_funcs_t
    string_maybe_free as _offset
    string_assign as _offset
end type

dim shared ll_cg_funcs as ll_cg_funcs_t

dim shared ll_cg_str_queued_transients(1) as _offset
dim shared ll_cg_str_last_queued_transient as long
