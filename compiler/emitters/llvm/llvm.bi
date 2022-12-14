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

type ll_arg_t
    lp as _offset 'LLVM value
    is_byval as long 'false if this is a reference
    omitted as long 'true if this value is an optional omitted argument
end type

dim shared ll_cg_str_queued_transients(1) as ll_arg_t
dim shared ll_cg_str_last_queued_transient as long
