#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource libarchive
strapyChrootCd libarchive-*


printInfo "Configuring libarchive"

# TODO: Fix static linking!
strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --disable-hardlink \
    --disable-rpath \
    --enable-bsdcpio=static \
    --enable-bsdtar=static \
    --enable-shared \
    --enable-static


printInfo "Building libarchive"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing libarchive"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install

printInfo "Making libarchive default provider of cpio + tar"
ln -svf bsdtar "${STRAPY_INSTALL_DIR}/usr/bin/tar"
ln -svf bsdcpio "${STRAPY_INSTALL_DIR}/usr/bin/cpio"
