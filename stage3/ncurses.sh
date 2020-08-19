#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource ncurses

printInfo "Configuring ncurses"
serpentChrootCd ncurses*
serpentChroot ./configure \
    --host="${SERPENT_TRIPLET}" \
    --build="${SERPENT_TRIPLET}" \
    --prefix=/usr \
    --libdir=/usr/lib \
    --without-debug \
    --disable-rpath \
    --with-shared \
    --without-ada \
    --enable-widec \
    --enable-largefile \
    --enable-db-install \
    --enable-symlinks \
    --with-pkg-config-libdir=/usr/lib/pkgconfig \
    --with-cxx-binding \
    PKG_CONFIG_LIBDIR=/usr/lib/pkgconfig

printInfo "Building ncurses"
serpentChroot make -j${SERPENT_BUILD_JOBS}
serpentChroot make -j${SERPENT_BUILD_JOBS} install
