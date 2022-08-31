'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'llvm.bi - Declarations for LLVM compilation target

$include: 'llvm_bindings.bi'

type llvm_cg_state_t
    target_machine as _offset
    module as _offset 'Current LLVM module
    builder as _offset 'Current instruction builder
    retvar as _offset 'The variable whose value will be loaded & returned
end type

dim shared ll_cg_state as llvm_cg_state_t
