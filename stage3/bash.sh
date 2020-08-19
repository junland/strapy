#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource bash
serpentChrootCd bash-*

printInfo "Configuring bash"
serpentChroot ./configure \
    --prefix=/usr \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --without-bash-malloc \
    --enable-nls

printInfo "Building bash"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

serpentChroot make -j "${SERPENT_BUILD_JOBS}" install

printInfo "Making bash the default /bin/sh"
ln -svf bash "${SERPENT_INSTALL_DIR}/usr/bin/sh"
