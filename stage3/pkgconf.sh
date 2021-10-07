#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource pkgconf
strapyChrootCd pkgconf-*

printInfo "Configuring pkgconf"
strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --with-system-libdir=/usr/lib \
    --with-system-includedir=/usr/include \
    --includedir=/usr/include \
    --enable-static \
    --disable-shared

printInfo "Building pkgconf"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

strapyChroot make -j "${STRAPY_BUILD_JOBS}" install

printInfo "Setting pkgconf as default pkg-config"
ln -svf pkgconf "${STRAPY_INSTALL_DIR}/usr/bin/pkg-config"
