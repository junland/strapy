#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" != "glibc" ]]; then
    printInfo "Skipping binutils with musl libc"
    exit 0
fi

extractSource binutils
cd binutils-*

export PATH="${SERPENT_INSTALL_DIR}/usr/bin:$PATH"
export CC="gcc"
export CXX="g++"

export CFLAGS="${SERPENT_TARGET_CFLAGS}"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS}"

printInfo "Configuring binutils"
mkdir build && pushd build
../configure --prefix=/usr/binutils \
    --target="${SERPENT_TRIPLET}" \
    --with-sysroot="${SERPENT_INSTALL_DIR}" \
    --libdir=/usr/lib \
    --with-lib-path="/usr/lib:/usr/lib32" \
    --includedir=/usr/include \
    --enable-multilib \
    --enable-deterministic-archives \
    --disable-plugins \
    --disable-shared \
    --enable-static \
    --enable-ld=default \
    --enable-secureplt \
    --enable-64-bit-bfd

printInfo "Building binutils"
make -j "${SERPENT_BUILD_JOBS}" tooldir=/usr/binutils

printInfo "Installing binutils"
make -j "${SERPENT_BUILD_JOBS}" tooldir=/usr/binutils install DESTDIR="${SERPENT_INSTALL_DIR}"
