'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'llvm_bindings.bi - Bindings for LLVM C API functions, declarations

declare dynamic library "/usr/local/lib/LLVM"
    function LLVMModuleCreateWithName%&(ModuleID$)
    sub      llvm_dispose_module alias LLVMDisposeModule(byval M%&)
    sub      LLVMSetTarget(byval M%&, Triple$)
    function llvm_int1_type%& alias LLVMInt1Type
    function llvm_int16_type%& alias LLVMInt16Type
    function llvm_int32_type%& alias LLVMInt32Type
    function llvm_int64_type%& alias LLVMInt64Type
    function llvm_pointer_type%& alias LLVMPointerType(byval ElementType%&, byval AddressSpace~&)
    function llvm_void_type%& alias LLVMVoidType
    function LLVMFunctionType%&(byval ReturnType%&, byval ParamTypes%&, byval ParamCount~&, byval IsVarArg&)
    function LLVMAddFunction%&(byval M%&, Name$, byval FunctionTy%&)
    function LLVMAppendBasicBlock%&(byval Fn%&, Name$)
    function llvm_create_builder%& alias LLVMCreateBuilder
    sub      llvm_position_builder_at_end alias LLVMPositionBuilderAtEnd(byval Builder%&, byval Block%&)
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
    function llvm_const_int%& alias LLVMConstInt(byval IntTy%&, byval N~&&, byval SignExtend&)
    function LLVMConstIntOfStringAndSize%&(byval Ty%&, Text$, byval SLen~&, byval Radix~%%)
    function LLVMBuildLoad%&(byval B%&, byval PointerVal%&, Name$)
    function llvm_build_store%& alias LLVMBuildStore(byval B%&, byval Val%&, byval Ptr%&)
    function LLVMBuildCast%&(byval B%&, byval Op&, byval Value%&, byval DestTy%&, Name$)
    function LLVMBuildAdd%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildSub%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildICmp%&(byval B%&, byval Op&, byval LHS%&, byval RHS%&, Name$)
    function llvm_get_insert_block%& alias LLVMGetInsertBlock(byval B%&)
    function llvm_get_basic_block_parent%& alias LLVMGetBasicBlockParent(byval BB%&)
    function llvm_get_global_context%& alias LLVMGetGlobalContext
    function LLVMCreateBasicBlockInContext%&(byval C%&, Name$)
    function llvm_build_cond_br%& alias LLVMBuildCondBr(byval B%&, byval Cond%&, byval ThenBr%&, byval ElseBr%&)
    function llvm_build_br%& alias LLVMBuildBr(byval B%&, byval Dest%&)
    sub llvm_append_existing_basic_block alias LLVMAppendExistingBasicBlock(byval Fn%&, byval BB%&)
end declare

const LLVMAbortProcessAction = 0
const LLVMPrintMessageAction = 1
const LLVMReturnStatusAction = 2

const LLVMTrunc = 30
const LLVMZExt = 31
const LLVMSExt = 32
const LLVMFPToUI = 33
const LLVMFPToSI = 34
const LLVMUIToFP = 35
const LLVMSIToFP = 36
const LLVMFPTrunc = 37
const LLVMFPExt = 38
const LLVMPtrToInt = 39
const LLVMIntToPtr = 40
const LLVMBitCast = 41
const LLVMAddrSpaceCast  = 60


'When upgrading LLVM, be sure to verify these enums are still correct
const LLVMIntEQ = 32 'equal
const LLVMIntNE = 33 'not equal
const LLVMIntUGT = 34 'unsigned greater than
const LLVMIntUGE = 35 'unsigned greater or equal
const LLVMIntULT = 36 'unsigned less than
const LLVMIntULE = 37 'unsigned less or equal
const LLVMIntSGT = 38 'signed greater than
const LLVMIntSGE = 39 'signed greater or equal
const LLVMIntSLT = 40 'signed less than
const LLVMIntSLE = 41 'signed less or equal
