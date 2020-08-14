#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

# Provide native builds of extra LLVM components to the /lib directory of the
# sysroot when cross-compiling.
#
# Currently this is just libunwind and should be sufficient to get onto stage2.

if [[ "${SERPENT_TARGET_ARCH}" == "${SERPENT_HOST}" ]]; then
    printInfo "Skipping compiler-rt on native architecture"
    exit 0
fi

printInfo "Building libunwind for cross-compilation"

export PATH="${SERPENT_INSTALL_DIR}/usr/bin:$PATH"
export CC="clang"
export CXX="clang++"

export CFLAGS="${SERPENT_TARGET_CFLAGS}"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS}"
export AR="llvm-ar"
export RANLIB="llvm-ranlib"
export STRIP="llvm-strip"

extractSource libunwind
pushd libunwind*

mkdir build && pushd build
cmake .. -G Ninja  \
    -DCMAKE_C_COMPILER_TARGET="${SERPENT_TRIPLET}" \
    -DCMAKE_ASM_COMPILER_TARGET="${SERPENT_TRIPLET}" \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_ASM_FLAGS="${CFLAGS}" \
    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
    -DLLVM_CONFIG_PATH="${SERPENT_INSTALL_DIR}/usr/bin/llvm-config" \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_AR="${SERPENT_INSTALL_DIR}/usr/bin/ar" \
    -DCMAKE_NM="${SERPENT_INSTALL_DIR}/usr/bin/llvm-nm" \
    -DCMAKE_RANLIB="${SERPENT_INSTALL_DIR}/usr/bin/llvm-ranlib" \
    -DLIBUNWIND_TARGET_TRIPLE="${SERPENT_TRIPLET}" \
    -DLIBUNWIND_USE_COMPILER_RT=ON

ninja -j "${SERPENT_BUILD_JOBS}"


printInfo "Installing libunwind"
install -D -d -m 00755 "${SERPENT_INSTALL_DIR}/lib/"
install -v -m 00644 lib/*.a "${SERPENT_INSTALL_DIR}/lib/."
install -v -m 00644 lib/*.so* "${SERPENT_INSTALL_DIR}/lib/."
popd
