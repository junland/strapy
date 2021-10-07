#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${STRAPY_LIBC}" != "glibc" ]]; then
    printInfo "Skipping bash with non-glibc libc"
    exit 0
fi

extractSource bash
cd bash-*

printInfo "Configuring bash"
 ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --without-bash-malloc \
    --enable-nls

printInfo "Building bash"
make -j3

printInfo "Installing bash"
make -j3 install DESTDIR="${STRAPY_INSTALL_DIR}"
ln -svf bash "${STRAPY_INSTALL_DIR}/usr/bin/sh"
