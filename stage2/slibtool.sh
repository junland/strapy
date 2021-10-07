#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource slibtool
cd slibtool-*


printInfo "Configuring slibtool"
./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --all-shared


printInfo "Building slibtool"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing slibtool"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"

# Attempt to use slibtool for all libtool purposes
ln -svf slibtool "${STRAPY_INSTALL_DIR}/usr/bin/libtool"
