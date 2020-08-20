#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

activateStage1Compiler

extractSource musl
cd musl-*

patch -p1 < "${SERPENT_PATCHES_DIR}/musl/0001-ldso-dynlink-Prefer-usr-lib-over-lib.patch"

printInfo "Configuring musl"
./configure --prefix=/usr \
    --target="${SERPENT_TRIPLET}" \
    --build="${SERPENT_TRIPLET}" \
    --enable-optimize=auto \
    --enable-visibility \
    --libdir=/usr/lib \
    --syslibdir=/usr/lib \
    --sysconfdir=/etc

printInfo "Building musl"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing musl"
make -j "${SERPENT_BUILD_JOBS}" install DESTDIR="${SERPENT_INSTALL_DIR}"

printInfo "Installing ldd"
ln -sv ../lib/libc.so "${SERPENT_INSTALL_DIR}/usr/bin/ldd"
