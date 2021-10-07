#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource slibtool
strapyChrootCd slibtool-*


printInfo "Configuring slibtool"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --all-shared


printInfo "Building slibtool"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing slibtool"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install

# Use slibtool for all libtool purposes
ln -svf slibtool "${STRAPY_INSTALL_DIR}/usr/bin/libtool"
