#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource musl
cd musl-*

patch -p1 < "${STRAPY_PATCHES_DIR}/musl/0001-ldso-dynlink-Prefer-usr-lib-over-lib.patch"

printInfo "Configuring musl"
./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --build="${STRAPY_TRIPLET}" \
    --enable-optimize=yes \
    --enable-visibility \
    --libdir=/usr/lib \
    --syslibdir=/usr/lib

printInfo "Building musl"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing musl"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"

printInfo "Installing ldd"
ln -sv ../lib/libc.so "${STRAPY_INSTALL_DIR}/usr/bin/ldd"
