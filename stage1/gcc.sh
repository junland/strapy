#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" == "musl" ]]; then
    printInfo "Skipping gcc with musl libc"
    exit 0
fi

extractSource gcc
cd gcc-*

export PATH="${SERPENT_INSTALL_DIR}/usr/bin:$PATH"
export CC="gcc"
export CXX="g++"

export CFLAGS="${SERPENT_TARGET_CFLAGS}"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS}"

printInfo "Configuring gcc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --build="${SERPENT_HOST}" \
    --target="${SERPENT_TRIPLET}" \
    --with-sysroot="${SERPENT_INSTALL_DIR}" \
    --disable-bootstrap \
    --disable-multilib \
    --disable-libstdcxx \
    --enable-shared \
    --enable-threads=posix \
    --enable-gnu-indirect-function \
    --enable-__cxa_atexit \
    --enable-ld=default \
    --enable-clocale=gnu \
    --with-gcc-major-version-only \
    --enable-linker-build-id  \
    --with-linker-hash-style=gnu \
    --with-gnu-ld \
    --enable-languages=c

printInfo "Building gcc"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing gcc"
make -j "${SERPENT_BUILD_JOBS}" install DESTDIR="${SERPENT_INSTALL_DIR}"
