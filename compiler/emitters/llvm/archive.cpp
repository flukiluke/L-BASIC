#include <llvm/Object/Archive.h>
#include <llvm/Support/MemoryBuffer.h>

using namespace llvm;
using namespace object;

constexpr StringLiteral IndexName("LBINDEX");

extern "C" {

LLVMMemoryBufferRef LLGetArchiveLBIndex(LLVMBinaryRef BR) {
  auto InBuf = unwrap(BR)->getMemoryBufferRef();
  auto ArchiveOrErr = Archive::create(InBuf);
  if (!ArchiveOrErr) {
    return nullptr;
  }
  auto Ar = std::move(*ArchiveOrErr);

  Error Err = Error::success();
  for (auto &C: Ar->children(Err)) {
    auto NameOrErr = C.getName();
    if (!NameOrErr) {
      continue;
    }
    StringRef Name = std::move(*NameOrErr);
    if (Name.equals(IndexName)) {
      auto BufOrErr = C.getMemoryBufferRef();
      if (!BufOrErr) {
        return nullptr;
      }
      auto Buf = std::move(*BufOrErr);
      return wrap(MemoryBuffer::getMemBuffer(Buf.getBuffer(),
                                             Buf.getBufferIdentifier(),
                                             false).release());
    }
  }
  return nullptr;
}

}
