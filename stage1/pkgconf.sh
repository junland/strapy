#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource pkgconf
cd pkgconf-*

# Build pkgconf as a host-native executable, which will be used for
# further stages in bootstrap, i.e. we need to be able to execute it.
printInfo "Configuring pkgconf"
./configure --prefix=/usr \
    --build="${STRAPY_HOST}" \
    --host="${STRAPY_HOST}" \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --with-system-libdir=/usr/lib \
    --with-system-includedir=/usr/include \
    --includedir=/usr/include \
    --enable-static \
    --disable-shared

printInfo "Building pkgconf"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing pkgconf"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"

printInfo "Setting pkgconf as default pkg-config"
ln -svf pkgconf "${STRAPY_INSTALL_DIR}/usr/bin/pkg-config"
