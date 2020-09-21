#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" == "musl" ]]; then
    printInfo "Skipping gcc with musl libc"
    exit 0
fi

extractSource gcc
cd gcc-*

export CC="gcc"
export CXX="g++"

printInfo "Configuring gcc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --disable-bootstrap \
    --disable-multilib \
    --with-gcc-major-version-only \
    --enable-languages=c,c++

printInfo "Building gcc"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing gcc"
make -j "${SERPENT_BUILD_JOBS}" DESTDIR="${SERPENT_INSTALL_DIR}"
