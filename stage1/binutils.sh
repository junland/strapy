#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${STRAPY_LIBC}" != "glibc" ]]; then
    printInfo "Skipping binutils with musl libc"
    exit 0
fi

extractSource binutils
cd binutils-*

export PATH="${STRAPY_INSTALL_DIR}/usr/bin:$PATH"
export CC="gcc"
export CXX="g++"

export CFLAGS="-O2"
export CXXFLAGS="-O2"

printInfo "Configuring binutils"
mkdir build && pushd build
../configure --prefix=/usr/binutils \
    --target="${STRAPY_TRIPLET}" \
    --with-sysroot="${STRAPY_INSTALL_DIR}" \
    --libdir=/usr/lib \
    --includedir=/usr/include \
    --disable-multilib \
    --enable-deterministic-archives \
    --enable-plugins \
    --enable-lto \
    --disable-shared \
    --enable-static \
    --enable-ld=default \
    --enable-secureplt \
    --enable-64-bit-bfd

printInfo "Building binutils"
make -j "${STRAPY_BUILD_JOBS}" tooldir=/usr/binutils

printInfo "Installing binutils"
make -j "${STRAPY_BUILD_JOBS}" tooldir=/usr/binutils install DESTDIR="${STRAPY_INSTALL_DIR}"
