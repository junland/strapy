#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

export TOOLCHAIN_VERSION="13.0.0"

printInfo "Extracting toolchain requirements"
extractSource llvmorg

if [[ "${STRAPY_LIBC}" == "musl" ]]; then
    pushd llvm-project-${TOOLCHAIN_VERSION}.src/clang
    patch -p1 < "${STRAPY_PATCHES_DIR}/clang/0001-ToolChains-Linux-Use-correct-musl-path-on-Serpent-OS.patch"
    popd
    export TOOLCHAIN_FLAGS="-DLIBCXX_HAS_MUSL_LIBC=ON"
    export SYMLINKS="-DLLVM_INSTALL_CCTOOLS_SYMLINKS=ON"
fi

mkdir -p  llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build
strapyChrootCd llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build

# Add default toolchain patches into S3
pushd llvm-project-${TOOLCHAIN_VERSION}.src
patch -p1 < "${STRAPY_PATCHES_DIR}/llvm/0001-Make-gnu-hash-the-default-for-lld-and-clang.patch"
patch -p1 < "${STRAPY_PATCHES_DIR}/llvm/0001-Use-correct-Serpent-OS-multilib-paths-for-ld.patch"
popd

unset CFLAGS CXXFLAGS

# Last two options deliberately remove sanitizer support. We actually do need this
# in future, so we should follow: https://reviews.llvm.org/D63785
export llvmopts="
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DLLVM_ENABLE_PROJECTS='clang;compiler-rt;libcxx;libcxxabi;libunwind;lld;llvm;polly' \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_TARGET_ARCH="${STRAPY_TARGET_ARCH}" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="${STRAPY_TRIPLET}" \
    -DLLVM_TARGETS_TO_BUILD="${STRAPY_TARGET_LLVM_BACKEND}" \
    -DLLVM_ENABLE_LIBXML2=OFF \
    -DLLVM_ENABLE_FFI=OFF \
    -DENABLE_EXPERIMENTAL_NEW_PASS_MANAGER=ON \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_LINKER=lld \
    -DCLANG_DEFAULT_OBJCOPY=llvm-objcopy \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
    ${SYMLINKS} \
    -DCOMPILER_RT_HAS_ATOMIC_KEYWORD=ON \
    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
    -DCOMPILER_RT_USE_LIBCXX=ON \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DSANITIZER_CXX_ABI=libc++ \
    ${TOOLCHAIN_FLAGS} \
    -DLIBCXX_INSTALL_SUPPORT_HEADERS=ON \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=OFF \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_ENABLE_SHARED=ON \
    -DLIBCXXABI_ENABLE_STATIC=OFF \
    -DLIBCXXABI_INSTALL_LIBRARY=ON \
    -DLIBUNWIND_ENABLE_SHARED=ON \
    -DLIBUNWIND_ENABLE_STATIC=ON \
    -DLIBUNWIND_TARGET_TRIPLE="${STRAPY_TRIPLET}" \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DLLVM_USE_SANITIZER=OFF \
    -DLLVM_ENABLE_UNWIND_TABLES=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_UTILS=ON \
    -DCLANG_DEFAULT_UNWINDLIB="libunwind" \
    -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DLLVM_BUILD_TOOLS=ON \
    -DCLANG_BUILD_TOOLS=OFF"

strapyChroot cmake -G Ninja ../ \
    ${llvmopts} \
    -DLLVM_BUILD_LLVM_DYLIB=ON \
    -DLLVM_LINK_LLVM_DYLIB=ON

printInfo "Building toolchain"
strapyChroot ninja -j "${STRAPY_BUILD_JOBS}" -v
strapyChroot ninja -j "${STRAPY_BUILD_JOBS}" -v llvm-config

printInfo "Installing toolchain"
strapyChroot ninja install -j "${STRAPY_BUILD_JOBS}" -v

strapyChroot cmake -G Ninja ../ \
    ${llvmopts} \
    -DLLVM_BUILD_LLVM_DYLIB=OFF \
    -DLLVM_LINK_LLVM_DYLIB=OFF \
    -DCLANG_LINK_CLANG_DYLIB=OFF
strapyChroot ninja -j "${STRAPY_BUILD_JOBS}" -v lld clang
cp "${STRAPY_BUILD_DIR}/llvm-project-${TOOLCHAIN_VERSION}.src"/llvm/build/bin/* "${STRAPY_INSTALL_DIR}/usr/bin/"

# Only install if binutils ld not already present
if [ ! -f "${STRAPY_INSTALL_DIR}/usr/bin/ld" ]; then
    printInfo "Setting ld.lld as default ld"
    ln -svf ld.lld "${STRAPY_INSTALL_DIR}/usr/bin/ld"
fi

stashBinutils llvm-llvm
stashGcc llvm-llvm
restoreBinutils llvm-llvm
restoreGcc llvm-llvm
