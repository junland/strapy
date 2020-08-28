#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource musl
cd musl-*

export PATH="${SERPENT_INSTALL_DIR}/usr/bin:$PATH"
export CC="clang"
export CXX="clang++"

export CFLAGS="${SERPENT_TARGET_CFLAGS}"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS}"

patch -p1 < "${SERPENT_PATCHES_DIR}/musl/0001-ldso-dynlink-Prefer-usr-lib-over-lib.patch"

printInfo "Configuring musl"
./configure --prefix=/usr \
    --target="${SERPENT_TRIPLET}" \
    --build="${SERPENT_TRIPLET}" \
    --enable-optimize=yes \
    --enable-visibility \
    --libdir=/usr/lib \
    --syslibdir=/usr/lib \
    AR="llvm-ar" \
    RANLIB="llvm-ranlib" \
    STRIP="llvm-strip"

printInfo "Building musl"
make -j "${SERPENT_BUILD_JOBS}" AR="llvm-ar" RANLIB="llvm-ranlib" STRIP="llvm-strip"

printInfo "Installing musl"
make -j "${SERPENT_BUILD_JOBS}" AR="llvm-ar" RANLIB="llvm-ranlib" STRIP="llvm-strip" install DESTDIR="${SERPENT_INSTALL_DIR}"
