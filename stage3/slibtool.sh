#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource slibtool
serpentChrootCd slibtool-*


printInfo "Configuring slibtool"

serpentChroot ./configure --prefix=/usr \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --all-static


printInfo "Building slibtool"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing slibtool"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install

# Use slibtool for all libtool purposes
ln -svf slibtool "${SERPENT_INSTALL_DIR}/usr/bin/libtool"
