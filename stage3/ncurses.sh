#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource ncurses
unset CONFIG_SITE

printInfo "Configuring ncurses"
strapyChrootCd ncurses*
strapyChroot ./configure \
    --host="${STRAPY_TRIPLET}" \
    --build="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --without-debug \
    --disable-rpath \
    --disable-stripping \
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
strapyChroot make -j${STRAPY_BUILD_JOBS}
strapyChroot make -j${STRAPY_BUILD_JOBS} install

echo "INPUT(-lncursesw)" > "${STRAPY_INSTALL_DIR}/usr/lib/libncurses.so"
echo "INPUT(-lncursesw)" > "${STRAPY_INSTALL_DIR}/usr/lib/libcurses.so"
