'Copyright Luke Ceddia
'SPDX-License-Identifier: Apache-2.0
'llvm_bindings.bi - Bindings for LLVM C API functions, declarations

declare dynamic library "./llvm/bin/libLLVM-14"
    sub      llvm_initialize_x86_target alias LLVMInitializeX86Target
    sub      llvm_initialize_x86_asm_printer alias LLVMInitializeX86AsmPrinter
    sub      llvm_initialize_x86_target_mc alias LLVMInitializeX86TargetMC
    sub      llvm_initialize_x86_target_info alias LLVMInitializeX86TargetInfo
    function LLVMGetDefaultTargetTriple%&
    function LLVMGetTargetFromTriple&(Triple$, Target%&, ErrorMessage%&)
    function LLVMCreateTargetMachine%&(byval T%&, Triple$, CPU$, Features$, byval Level&, byval Reloc&, byval CodeModel&)
    function llvm_create_target_data_layout%& alias LLVMCreateTargetDataLayout(byval T%&)
    sub      llvm_module_set_data_layout alias LLVMSetModuleDataLayout(byval M%&, byval DL%&)
    function llvm_get_module_data_layout%& alias LLVMGetModuleDataLayout(byval M%&)
    function LLVMTargetMachineEmitToFile&(byval T%&, byval M%&, Filename$, byval codegen&, ErrorMessage%&)
    function LLVMTargetMachineEmitToMemoryBuffer&(byval T%&, byval M%&, byval codegen&, ErrorMessage%&, OutMemBuf%&)
    function llvm_offset_of_element& alias LLVMOffsetOfElement(byval TD%&, byval StructTy%&, byval Element~&)
    function LLVMWriteBitcodeToFile&(byval M%&, Path$)
    function LLVMVerifyModule&(byval M%&, byval Action&, OutMessage%&)
    function llvm_verify_function& alias LLVMVerifyFunction(byval Fn%&, byval Action&)
    function LLVMCreateBinary%&(byval MemBuf%&, byval Context%&, ErrorMessage%&)
    function llvm_binary_get_type& alias LLVMBinaryGetType(byval BR%&)
    sub      llvm_dispose_binary alias LLVMDisposeBinary(byval BR%&)
    function LLVMModuleCreateWithName%&(ModuleID$)
    sub      llvm_dispose_module alias LLVMDisposeModule(byval M%&)
    sub      LLVMSetTarget(byval M%&, Triple$)
    function llvm_int1_type%& alias LLVMInt1Type
    function llvm_int8_type%& alias LLVMInt8Type
    function llvm_int16_type%& alias LLVMInt16Type
    function llvm_int32_type%& alias LLVMInt32Type
    function llvm_int64_type%& alias LLVMInt64Type
    function llvm_float_type%& alias LLVMFloatType
    function llvm_double_type%& alias LLVMDoubleType
    function llvm_fp128_type%& alias LLVMFP128Type
    function llvm_pointer_type%& alias LLVMPointerType(byval ElementType%&, byval AddressSpace~&)
    function llvm_array_type%& alias LLVMArrayType(byval ElementType%&, byval ElementCount~&)
    function llvm_void_type%& alias LLVMVoidType
    function llvm_const_pointer_null%& alias LLVMConstPointerNull(byval Ty%&)
    function LLVMFunctionType%&(byval ReturnType%&, byval ParamTypes%&, byval ParamCount~&, byval IsVarArg&)
    function LLVMAddFunction%&(byval M%&, Name$, byval FunctionTy%&)
    function LLVMAppendBasicBlock%&(byval Fn%&, Name$)
    function llvm_create_builder%& alias LLVMCreateBuilder
    sub      llvm_position_builder_before alias LLVMPositionBuilderBefore(byval Builder%&, byval Instruction%&)
    sub      llvm_position_builder_at_end alias LLVMPositionBuilderAtEnd(byval Builder%&, byval Block%&)
    function llvm_get_basic_block_terminator%& alias LLVMGetBasicBlockTerminator(byval BB%&)
    function llvm_build_ret%& alias LLVMBuildRet(byval B%&, byval V%&)
    function llvm_build_ret_void%& alias LLVMBuildRetVoid(byval B%&)
    function llvm_get_param%& alias LLVMGetParam(byval Fn%&, byval index~&)
    sub      LLVMDisposeMessage(byval Message%&)
    sub      LLVMSetValueName2(byval Value%&, Name$, byval NameLen&)
    sub      llvm_dispose_builder alias LLVMDisposeBuilder(byval Builder%&)
    function LLVMBuildAlloca%&(byval B%&, byval Ty%&, Name$)
    function LLVMBuildCall%&(byval B%&, byval Fn%&, byval Args%&, byval NumArgs~&, Name$)
    function llvm_const_int%& alias LLVMConstInt(byval IntTy%&, byval N~&&, byval SignExtend&)
    function llvm_const_real%& alias LLVMConstReal(byval RealTy%&, byval N#)
    function LLVMConstIntOfStringAndSize%&(byval Ty%&, Text$, byval SLen~&, byval Radix~%%)
    function LLVMConstInBoundsGEP%&(byval ConstantVal%&, byval ConstantIndices%&, byval NumIndices~&)
    function LLVMBuildLoad%&(byval B%&, byval PointerVal%&, Name$)
    function llvm_build_store%& alias LLVMBuildStore(byval B%&, byval Val%&, byval Ptr%&)
    function LLVMBuildCast%&(byval B%&, byval Op&, byval Value%&, byval DestTy%&, Name$)
    function LLVMBuildAdd%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildFAdd%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildSub%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildFSub%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildICmp%&(byval B%&, byval Op&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildFCmp%&(byval B%&, byval Op&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildMul%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildFMul%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildSDiv%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function LLVMBuildFDiv%&(byval B%&, byval LHS%&, byval RHS%&, Name$)
    function llvm_get_insert_block%& alias LLVMGetInsertBlock(byval B%&)
    function llvm_get_basic_block_parent%& alias LLVMGetBasicBlockParent(byval BB%&)
    function llvm_get_global_context%& alias LLVMGetGlobalContext
    function llvm_get_entry_basic_block%& alias LLVMGetEntryBasicBlock(byval Fn%&)
    function LLVMCreateBasicBlockInContext%&(byval C%&, Name$)
    function llvm_build_cond_br%& alias LLVMBuildCondBr(byval B%&, byval Cond%&, byval ThenBr%&, byval ElseBr%&)
    function llvm_build_br%& alias LLVMBuildBr(byval B%&, byval Dest%&)
    sub      llvm_append_existing_basic_block alias LLVMAppendExistingBasicBlock(byval Fn%&, byval BB%&)
    sub      llvm_set_linkage alias LLVMSetLinkage(byval Global%&, byval Linkage&)
    function llvm_get_buffer_start%& alias LLVMGetBufferStart(byval MemBuf%&)
    function llvm_get_buffer_size&& alias LLVMGetBufferSize(byval MemBuf%&)
    sub      llvm_dispose_memory_buffer alias LLVMDisposeMemoryBuffer(byval MemBuf%&)
    function llvm_const_string%& alias LLVMConstString(s$, byval length~&, byval DontNullTerminate&)
    sub      llvm_dump_type alias LLVMDumpType(byval Value%&)
    function LLVMAddGlobal%&(byval M%&, byval Ty%&, Name$)
    sub      llvm_set_initializer alias LLVMSetInitializer(byval GlobalVar%&, byval ConstantVal%&)
    function llvm_type_of%& alias LLVMTypeOf(byval V%&)
    sub      llvm_set_global_constant alias LLVMSetGlobalConstant(byval GlobalVar%&, byval IsConstant&)
    sub      llvm_set_unnamed_address alias LLVMSetUnnamedAddress(byval Global%&, byval UnnamedAddr&)
    function LLVMStructType%&(byval ElementTypes%&, byval ElementCount~&, byval Packed&)
    function llvm_get_type_kind& alias LLVMGetTypeKind(byval Ty%&)
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

const LLVMRealPredicateFalse = 0 'Always false (always folded)
const LLVMRealOEQ = 1 'True if ordered and equal
const LLVMRealOGT = 2 'True if ordered and greater than
const LLVMRealOGE = 3 'True if ordered and greater than or equal
const LLVMRealOLT = 4 'True if ordered and less than
const LLVMRealOLE = 5 'True if ordered and less than or equal
const LLVMRealONE = 6 'True if ordered and operands are unequal
const LLVMRealORD = 7 'True if ordered (no nans)
const LLVMRealUNO = 8 'True if unordered: isnan(X) | isnan(Y)
const LLVMRealUEQ = 9 'True if unordered or equal
const LLVMRealUGT = 10 'True if unordered or greater than
const LLVMRealUGE = 11 'True if unordered, greater than, or equal
const LLVMRealULT = 12 'True if unordered or less than
const LLVMRealULE = 13 'True if unordered, less than, or equal
const LLVMRealUNE = 14 'True if unordered or not equal
const LLVMRealPredicateTrue = 15 'Always true (always folded)

const LLVMExternalLinkage = 0 'Externally visible function
const LLVMAvailableExternallyLinkage = 1
const LLVMLinkOnceAnyLinkage = 2 'Keep one copy of function when linking (inline)*/
const LLVMLinkOnceODRLinkage = 3 'Same, but only replaced by something equivalent.
const LLVMLinkOnceODRAutoHideLinkage = 4 'Obsolete
const LLVMWeakAnyLinkage = 5 'Keep one copy of function when linking (weak)
const LLVMWeakODRLinkage = 6 'Same, but only replaced by something equivalent.
const LLVMAppendingLinkage = 7 'Special purpose, only applies to global arrays
const LLVMInternalLinkage = 8 'Rename collisions when linking (static functions)
const LLVMPrivateLinkage = 9 'Like Internal, but omit from symbol table
const LLVMDLLImportLinkage = 10 'Obsolete
const LLVMDLLExportLinkage = 11 'Obsolete
const LLVMExternalWeakLinkage = 12 'ExternalWeak linkage description
const LLVMGhostLinkage = 13 'Obsolete
const LLVMCommonLinkage = 14 'Tentative definitions
const LLVMLinkerPrivateLinkage = 15 'Like Private, but linker removes.
const LLVMLinkerPrivateWeakLinkage = 16 'Like LinkerPrivate, but is weak.

const LLVMCodeGenLevelNone = 0
const LLVMCodeGenLevelLess = 1
const LLVMCodeGenLevelDefault = 2
const LLVMCodeGenLevelAggressive = 3

const LLVMRelocDefault = 0
const LLVMRelocStatic = 1
const LLVMRelocPIC = 2
const LLVMRelocDynamicNoPic = 3
const LLVMRelocROPI = 4
const LLVMRelocRWPI = 5
const LLVMRelocROPI_RWPI = 6

const LLVMCodeModelDefault = 0
const LLVMCodeModelJITDefault = 1
const LLVMCodeModelTiny = 2
const LLVMCodeModelSmall = 3
const LLVMCodeModelKernel = 4
const LLVMCodeModelMedium = 5
const LLVMCodeModelLarge = 6

const LLVMAssemblyFile = 0
const LLVMObjectFile = 1

const LLVMNoUnnamedAddr = 0 'Address of the GV is significant.
const LLVMLocalUnnamedAddr = 1 'Address of the GV is locally insignificant.
const LLVMGlobalUnnamedAddr = 2 'Address of the GV is globally insignificant.

const LLVMVoidTypeKind = 0 'type with no size
const LLVMHalfTypeKind = 1 '16 bit floating point type
const LLVMFloatTypeKind = 2 '32 bit floating point type
const LLVMDoubleTypeKind = 3 '64 bit floating point type
const LLVMX86_FP80TypeKind = 4 '80 bit floating point type (X87)
const LLVMFP128TypeKind = 5 '128 bit floating point type (112-bit mantissa)
const LLVMPPC_FP128TypeKind = 6'128 bit floating point type (two 64-bits)
const LLVMLabelTypeKind = 7 'Labels
const LLVMIntegerTypeKind = 8 'Arbitrary bit width integers
const LLVMFunctionTypeKind = 9 'Functions
const LLVMStructTypeKind = 10 'Structures
const LLVMArrayTypeKind = 11 'Arrays
const LLVMPointerTypeKind = 12 'Pointers
const LLVMVectorTypeKind = 13 'Fixed width SIMD vector type
const LLVMMetadataTypeKind = 14 'Metadata
const LLVMX86_MMXTypeKind = 15 'X86 MMX
const LLVMTokenTypeKind = 16 'Tokens
const LLVMScalableVectorTypeKind = 17 'Scalable SIMD vector type
const LLVMBFloatTypeKind = 18 '16 bit brain floating point type
const LLVMX86_AMXTypeKind = 19 'X86 AMX

