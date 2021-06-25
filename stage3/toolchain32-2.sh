#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

export TOOLCHAIN_VERSION="12.0.0"

printInfo "Extracting toolchain requirements"
extractSource llvmorg

mkdir -p  llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build
serpentChrootCd llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build

unset CFLAGS CXXFLAGS
export CC="clang"
export CXX="clang++"

echo "cmake -G Ninja ../ \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DLLVM_ENABLE_PROJECTS='libcxx;libcxxabi;libunwind' \
    -DLLVM_LIBDIR_SUFFIX= \
    -DLIBCXX_LIBDIR_SUFFIX=32 \
    -DLIBCXXABI_LIBDIR_SUFFIX=32 \
    -DLIBUNWIND_LIBDIR_SUFFIX=32 \
    -DLLVM_BUILD_32_BITS=ON \
    -DLIBCXX_INSTALL_SUPPORT_HEADERS=ON \
    -DLLVM_USE_SANITIZER=OFF \
    -DLLVM_ENABLE_UNWIND_TABLES=ON \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_UTILS=OFF \
    -DLLVM_BUILD_TOOLS=OFF \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=OFF \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_INSTALL_LIBRARY=OFF \
    -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
    -DLIBUNWIND_ENABLE_SHARED=ON \
    -DLIBUNWIND_ENABLE_STATIC=ON \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DLIBUNWIND_INSTALL_LIBRARY=ON" > llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build/build.sh
chmod +x llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build/build.sh
serpentChroot ./build.sh 


printInfo "Building toolchain"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -v cxx cxxabi unwind

printInfo "Installing toolchain"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -v install-cxx install-unwind
