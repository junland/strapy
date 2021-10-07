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
fi

pushd llvm-project-${TOOLCHAIN_VERSION}.src/llvm

mkdir build && pushd build

export CFLAGS="-fPIC -O2 -pipe"

# GNU toolchain may cause -moutline-atomics on aarch64, so disable until stage2.
if [[ "${STRAPY_TARGET_LLVM_BACKEND}" == "AArch64" ]]; then
	export CFLAGS="${CFLAGS} -mno-outline-atomics"
fi

export CXXFLAGS="${CFLAGS}"

export llvmopts="
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DLLVM_ENABLE_PROJECTS='clang;compiler-rt;libcxx;libcxxabi;libunwind;lld;llvm' \
    -DDEFAULT_SYSROOT="${STRAPY_INSTALL_DIR}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_LIBXML2=OFF \
    -DLLVM_TARGET_ARCH="${STRAPY_TARGET_ARCH}" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="${STRAPY_TRIPLET}" \
    -DLLVM_TARGETS_TO_BUILD="${STRAPY_TARGET_LLVM_BACKEND}" \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_LINKER=lld \
    -DCLANG_DEFAULT_OBJCOPY=llvm-objcopy \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
    -DLLVM_INSTALL_CCTOOLS_SYMLINKS=ON
    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=OFF \
    -DLLVM_STATIC_LINK_CXX_STDLIB=ON \
    -DLIBCXX_INSTALL_SUPPORT_HEADERS=ON \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=OFF \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_INSTALL_LIBRARY=ON \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_BUILTINS=ON \
    -DLLVM_USE_SANITIZER=OFF \
    -DLLVM_ENABLE_UNWIND_TABLES=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_UTILS=OFF \
    -DCLANG_DEFAULT_UNWINDLIB="libunwind" \
    -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DLLVM_BUILD_TOOLS=OFF \
    -DCLANG_BUILD_TOOLS=OFF"

cmake -G Ninja ../ \
    ${llvmopts} \
    -DLLVM_BUILD_LLVM_DYLIB=ON \
    -DLLVM_LINK_LLVM_DYLIB=ON

ninja -j "${STRAPY_BUILD_JOBS}" -v
ninja -j "${STRAPY_BUILD_JOBS}" -v llvm-config

printInfo "Installing toolchain"
DESTDIR="${STRAPY_INSTALL_DIR}" ninja install -j "${STRAPY_BUILD_JOBS}" -v

cmake -G Ninja ../ \
    ${llvmopts} \
    -DLLVM_BUILD_LLVM_DYLIB=OFF \
    -DLLVM_LINK_LLVM_DYLIB=OFF \
    -DCLANG_LINK_CLANG_DYLIB=OFF
ninja -j "${STRAPY_BUILD_JOBS}" -v lld clang
cp "${STRAPY_BUILD_DIR}"/llvm-project-${TOOLCHAIN_VERSION}.src/llvm/build/bin/* "${STRAPY_INSTALL_DIR}/usr/bin/"

# Only install if binutils ld not already present
if [ ! -f "${STRAPY_INSTALL_DIR}/usr/bin/ld" ]; then
    printInfo "Setting ld.lld as default ld"
    ln -svf ld.lld "${STRAPY_INSTALL_DIR}/usr/bin/ld"
fi
