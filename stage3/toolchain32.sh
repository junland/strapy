#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

export TOOLCHAIN_VERSION="12.0.0"

printInfo "Extracting toolchain requirements"
extractSource llvmorg

mkdir -p  llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build
serpentChrootCd llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build

# Add default toolchain patches into S3
pushd llvm-project-${TOOLCHAIN_VERSION}.src
patch -p1 < "${SERPENT_PATCHES_DIR}/llvm/0001-Make-gnu-hash-the-default-for-lld-and-clang.patch"
patch -p1 < "${SERPENT_PATCHES_DIR}/llvm/0001-Use-correct-Serpent-OS-multilib-paths-for-ld.patch"
popd

unset CFLAGS CXXFLAGS
export CC="gcc"
export CXX="g++"

echo "cmake -G Ninja ../ \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DLLVM_ENABLE_PROJECTS='compiler-rt;libcxx;libcxxabi;libunwind' \
    -DLLVM_LIBDIR_SUFFIX= \
    -DLIBCXX_LIBDIR_SUFFIX=32 \
    -DLIBCXXABI_LIBDIR_SUFFIX=32 \
    -DLIBUNWIND_LIBDIR_SUFFIX=32 \
    -DLLVM_BUILD_32_BITS=ON \
    -DLIBCXX_INSTALL_SUPPORT_HEADERS=ON \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DLLVM_USE_SANITIZER=OFF \
    -DLLVM_ENABLE_UNWIND_TABLES=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_UTILS=OFF \
    -DLLVM_BUILD_TOOLS=OFF \
    -DCOMPILER_RT_HAS_ATOMIC_KEYWORD=ON \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=OFF \
    -DLIBCXX_USE_COMPILER_RT=OFF \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
    -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
    -DLIBCXXABI_USE_COMPILER_RT=OFF \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_INSTALL_LIBRARY=OFF \
    -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_SHARED_LIBRARY=ON \
    -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
    -DLIBUNWIND_ENABLE_SHARED=OFF \
    -DLIBUNWIND_ENABLE_STATIC=ON \
    -DLIBUNWIND_USE_COMPILER_RT=OFF \
    -DLIBUNWIND_INSTALL_LIBRARY=ON" > llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build/build.sh
chmod +x llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build/build.sh
serpentChroot ./build.sh 


printInfo "Building toolchain"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -v compiler-rt cxx cxxabi unwind

printInfo "Installing toolchain"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -v install-compiler-rt install-cxx install-unwind
