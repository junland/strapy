#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource libarchive
serpentChrootCd libarchive-*


printInfo "Configuring libarchive"

# TODO: Fix static linking!
serpentChroot ./configure --prefix=/usr \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --libdir=/usr/lib \
    --disable-hardlink \
    --disable-rpath \
    --bindir=/usr/bin \
    --enable-bsdcpio=static \
    --enable-bsdtar=static \
    --enable-shared \
    --enable-static


printInfo "Building libarchive"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing libarchive"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install

printInfo "Making libarchive default provider of cpio + tar"
ln -svf bsdtar "${SERPENT_INSTALL_DIR}/usr/bin/tar"
ln -svf bsdcpio "${SERPENT_INSTALL_DIR}/usr/bin/cpio"
