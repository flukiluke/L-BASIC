'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'llvm_bindings.bi - Bindings for LLVM C API functions, declarations

declare dynamic library "/usr/local/lib/LLVM"
    function LLVMModuleCreateWithName%&(ModuleID$)
    sub      llvm_dispose_module alias LLVMDisposeModule(byval M%&)
    sub      LLVMSetTarget(byval M%&, Triple$)
    function llvm_int16_type%& alias LLVMInt16Type
    function llvm_int32_type%& alias LLVMInt32Type
    function llvm_int64_type%& alias LLVMInt64Type
    function llvm_void_type%& alias LLVMVoidType
    function LLVMFunctionType%&(byval ReturnType%&, byval ParamTypes%&, byval ParamCount~&, byval IsVarArg&)
    function LLVMAddFunction%&(byval M%&, Name$, byval FunctionTy%&)
    function LLVMAppendBasicBlock%&(byval Fn%&, Name$)
    function llvm_create_builder%& alias LLVMCreateBuilder
    sub      llvm_position_builder_at_end alias LLVMPositionBuilderAtEnd(byval Builder%&, byval Block%&)
    function LLVMBuildAdd%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function llvm_build_ret%& alias LLVMBuildRet(byval B%&, byval V%&)
    function llvm_build_ret_void%& alias LLVMBuildRetVoid(byval B%&)
    function llvm_get_param%& alias LLVMGetParam(byval Fn%&, byval index~&)
    function LLVMVerifyModule&(byval M%&, byval Action&, OutMessage%&)
    function llvm_verify_function& alias LLVMVerifyFunction(byval Fn%&, byval Action&)
    sub      LLVMDisposeMessage(byval Message%&)
    function LLVMWriteBitcodeToFile&(byval M%&, Path$)
    sub      LLVMSetValueName2(byval Value%&, Name$, byval NameLen&)
    sub      llvm_dispose_builder alias LLVMDisposeBuilder(byval Builder%&)
    function LLVMBuildAlloca%&(byval B%&, byval Ty%&, Name$)
    function LLVMBuildCall%&(byval B%&, byval Fn%&, byval Args%&, byval NumArgs~&, Name$)
    function LLVMConstIntOfStringAndSize%&(byval Ty%&, Text$, byval SLen~&, byval Radix~%%)
    function LLVMBuildLoad%&(byval B%&, byval PointerVal%&, Name$)
end declare

const LLVMAbortProcessAction = 0
const LLVMPrintMessageAction = 1
const LLVMReturnStatusAction = 2
