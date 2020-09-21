#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" == "musl" ]]; then
    printInfo "Skipping gcc with musl libc"
    exit 0
fi

extractSource gcc
cd gcc-*

printInfo "Extracting gcc requirements"
extractSource mpfr
extractSource mpc
extractSource gmp
extractSource isl

ln -sv "mpfr-4.1.0" mpfr
ln -sv "mpc-1.2.0" mpc
ln -sv "gmp-6.2.0" gmp
ln -sv "isl-0.21" isl

export PATH="${SERPENT_INSTALL_DIR}/usr/bin:$PATH"
export CC="gcc"
export CXX="g++"

export CFLAGS="${SERPENT_TARGET_CFLAGS}"
export CXXFLAGS="${SERPENT_TARGET_CXXFLAGS}"

printInfo "Configuring libgcc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --with-sysroot="${SERPENT_INSTALL_DIR}" \
    --target="${SERPENT_TRIPLET}" \
    --disable-bootstrap \
    --disable-multilib \
    --disable-shared \
    --with-gcc-major-version-only \
    --enable-languages=c,c++

printInfo "Building libgcc"
make -j "${SERPENT_BUILD_JOBS}" all-target-libgcc

printInfo "Installing libgcc"
make -j "${SERPENT_BUILD_JOBS}" install-target-libgcc DESTDIR="${SERPENT_INSTALL_DIR}"
