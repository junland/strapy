#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" == "musl" ]]; then
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
../configure --prefix=/usr \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --libdir=/usr/lib \
    --without-cvs \
    --without-gd \
    --without-selinux \
    --disable-multilib \
    --disable-profile \
    --disable-debug \
    --disable-silent-rules \
    --disable-dependency-tracking

printInfo "Building gas and ld"
make -j "${SERPENT_BUILD_JOBS}" maybe-all-gas maybe-all-ld

printInfo "Installing gas and ld"
make -j "${SERPENT_BUILD_JOBS}" maybe-install-gas maybe-install-ld DESTDIR="${SERPENT_INSTALL_DIR}"
