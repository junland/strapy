#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource libffi
cd libffi-*

export PATH="${STRAPY_INSTALL_DIR}/usr/bin:$PATH"
export CC="clang"
export CXX="clang++"
export LD="ld.lld"

export CFLAGS="${STRAPY_TARGET_CFLAGS} -L${STRAPY_INSTALL_DIR}/lib -L${STRAPY_INSTALL_DIR}/lib64"
export CXXFLAGS="${STRAPY_TARGET_CXXFLAGS} -L${STRAPY_INSTALL_DIR}/lib -L${STRAPY_INSTALL_DIR}/lib64"

printInfo "Configuring libffi"
./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    AR="llvm-ar" \
    RANLIB="llvm-ranlib" \
    STRIP="llvm-strip"


printInfo "Building libffi"
make -j "${STRAPY_BUILD_JOBS}" AR="llvm-ar" RANLIB="llvm-ranlib" STRIP="llvm-strip"

printInfo "Installing libffi"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}" AR="llvm-ar" RANLIB="llvm-ranlib" STRIP="llvm-strip"
