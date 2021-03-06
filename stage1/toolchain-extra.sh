#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

# Provide native builds of extra LLVM components to the /lib directory of the
# sysroot when cross-compiling.
#
# Currently this is just libunwind and should be sufficient to get onto stage2.

if [[ "${STRAPY_TARGET_ARCH}" == "${STRAPY_ARCH}" ]]; then
    printInfo "Skipping toolchain-extra on native architecture"
    exit 0
fi

printInfo "Building libunwind for cross-compilation"

export PATH="${STRAPY_INSTALL_DIR}/usr/bin:$PATH"
export CC="clang"
export CXX="clang++"

export CFLAGS="${STRAPY_TARGET_CFLAGS} -L${STRAPY_INSTALL_DIR}/lib -L${STRAPY_INSTALL_DIR}/usr/lib ${STRAPY_LIBC_FLAGS} -Wno-error -Wno-macro-redefined -Wno-unused-command-line-argument"
export CXXFLAGS="${STRAPY_TARGET_CXXFLAGS} -L${STRAPY_INSTALL_DIR}/lib -L${STRAPY_INSTALL_DIR}/usr/lib ${STRAPY_LIBC_FLAGS} -Wno-error -Wno-macro-redefined -Wno-unused-command-line-argument"
export AR="llvm-ar"
export RANLIB="llvm-ranlib"
export STRIP="llvm-strip"

export TOOLCHAIN_VERSION="13.0.0"

extractSource llvmorg

# Stop using glibc functionality through failed test
# Prevents HAVE___CXA_THREAD_ATEXIT_IMPL being defined and the ensuing linking errors
if [[ "${STRAPY_LIBC}" == "musl" ]]; then
    pushd llvm-project-${TOOLCHAIN_VERSION}.src/libcxxabi
    patch -p1 < "${STRAPY_PATCHES_DIR}/libcxxabi_musl_exit.patch"
    popd
    export TOOLCHAIN_EXTRA_FLAGS="-DLIBCXX_HAS_MUSL_LIBC=ON"
fi

pushd llvm-project-${TOOLCHAIN_VERSION}.src/llvm


mkdir build && pushd build
cmake .. -G Ninja  \
    -DCMAKE_C_COMPILER_TARGET="${STRAPY_TRIPLET}" \
    -DCMAKE_ASM_COMPILER_TARGET="${STRAPY_TRIPLET}" \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_ASM_FLAGS="${CFLAGS}" \
    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
    -DLLVM_CONFIG_PATH="${STRAPY_INSTALL_DIR}/usr/bin/llvm-config" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="${STRAPY_TRIPLET}" \
    -DLLVM_ENABLE_PROJECTS='libunwind;libcxxabi;libcxx' \
    -DLLVM_TARGETS_TO_BUILD="${STRAPY_TARGET_LLVM_BACKEND}" \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_AR="${STRAPY_INSTALL_DIR}/usr/bin/ar" \
    -DCMAKE_NM="${STRAPY_INSTALL_DIR}/usr/bin/llvm-nm" \
    -DCMAKE_RANLIB="${STRAPY_INSTALL_DIR}/usr/bin/llvm-ranlib" \
    "${TOOLCHAIN_EXTRA_FLAGS}" \
    -DLIBCXX_TARGET_TRIPLE="${STRAPY_TRIPLET}" \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -DLIBCXXABI_TARGET_TRIPLE="${STRAPY_TRIPLET}" \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBUNWIND_TARGET_TRIPLE="${STRAPY_TRIPLET}" \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DCMAKE_CROSSCOMPILING=ON

ninja -j "${STRAPY_BUILD_JOBS}" cxx cxxabi unwind

printInfo "Installing libunwind"
install -D -d -m 00755 "${STRAPY_INSTALL_DIR}/lib/"
install -v -m 00644 lib/*.a "${STRAPY_INSTALL_DIR}/lib/."
install -v -m 00644 lib/*.so* "${STRAPY_INSTALL_DIR}/lib/."
popd
