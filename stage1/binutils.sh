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
    --libdir=/usr/lib \
    --disable-multilib \
    --enable-deterministic-archives \
    --disable-plugins \
    --enable-ld=default \
    --enable-secureplt \
    --enable-64-bit-bfd

printInfo "Building binutils"
make -j "${SERPENT_BUILD_JOBS}" tooldir=/usr

printInfo "Installing binutils"
make -j "${SERPENT_BUILD_JOBS}" tooldir=/usr install DESTDIR="${SERPENT_INSTALL_DIR}"

printInfo "Setting bfd as default ld"
ln -svf "${SERPENT_TRIPLET}-ld" "${SERPENT_INSTALL_DIR}/usr/bin/ld"
