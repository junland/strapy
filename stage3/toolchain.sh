#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

export TOOLCHAIN_VERSION="10.0.1"

printInfo "Extracting toolchain requirements"
extractSource clang
extractSource compiler-rt
extractSource libcxx
extractSource libcxxabi
extractSource libunwind
extractSource lld
extractSource llvm

ln -sv "clang-${TOOLCHAIN_VERSION}.src" clang
ln -sv "compiler-rt-${TOOLCHAIN_VERSION}.src" compiler-rt
ln -sv "libcxx-${TOOLCHAIN_VERSION}.src" libcxx
ln -sv "libcxxabi-${TOOLCHAIN_VERSION}.src" libcxxabi
ln -sv "libunwind-${TOOLCHAIN_VERSION}.src" libunwind
ln -sv "lld-${TOOLCHAIN_VERSION}.src" lld
ln -sv "llvm-${TOOLCHAIN_VERSION}.src" llvm

pushd clang
patch -p1 < "${SERPENT_PATCHES_DIR}/clang/0001-ToolChains-Linux-Use-correct-musl-path-on-Serpent-OS.patch"
popd

mkdir -p llvm/build
serpentChrootCd llvm/build

unset CFLAGS CXXFLAGS

# Last two options deliberately remove sanitizer support. We actually do need this
# in future, so we should follow: https://reviews.llvm.org/D63785
serpentChroot cmake -G Ninja ../ \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DLLVM_ENABLE_PROJECTS="clang\;compiler-rt\;libcxx\;libcxxabi\;libunwind\;lld\;llvm" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_TARGET_ARCH="${SERPENT_TARGET_ARCH}" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="${SERPENT_TRIPLET}" \
    -DLLVM_TARGETS_TO_BUILD="${SERPENT_TARGET_LLVM_BACKEND}" \
    -DLLVM_ENABLE_LIBXML2=OFF \
    -DLLVM_ENABLE_FFI=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_LINKER=lld \
    -DCLANG_DEFAULT_OBJCOPY=llvm-objcopy \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
    -DLLVM_INSTALL_CCTOOLS_SYMLINKS=ON \
    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
    -DCOMPILER_RT_USE_LIBCXX=ON \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DSANITIZER_CXX_ABI=libc++ \
    -DLIBCXX_HAS_MUSL_LIBC=ON \
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
    -DLIBUNWIND_TARGET_TRIPLE="${SERPENT_TRIPLET}" \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DLLVM_USE_SANITIZER=OFF \
    -DLLVM_ENABLE_UNWIND_TABLES=OFF \
    -DLLVM_INCLUDE_UTILS=OFF \
    -DCLANG_DEFAULT_UNWINDLIB="libunwind" \
    -DLLVM_PARALLEL_LINK_JOBS="${SERPENT_BUILD_JOBS}" \
    -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DLLVM_USE_LINKER=ld.lld
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
    -DDLLVM_USE_SPLIT_DWARF=ON

printInfo "Building toolchain"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -v

printInfo "Installing toolchain"
serpentChroot ninja install -j "${SERPENT_BUILD_JOBS}" -v

printInfo "Setting ld.lld as default ld"
ln -svf ld.lld "${SERPENT_INSTALL_DIR}/usr/bin/ld"
