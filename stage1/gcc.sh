#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${STRAPY_LIBC}" != "glibc" ]]; then
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
ln -sv "mpc-1.2.1" mpc
ln -sv "gmp-6.2.1" gmp
ln -sv "isl-0.24" isl

export PATH="${STRAPY_INSTALL_DIR}/usr/binutils/bin:$PATH"
export CC="gcc"
export CXX="g++"

export CFLAGS="-O2"
export CXXFLAGS="-O2"

printInfo "Configuring gcc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --with-sysroot="${STRAPY_INSTALL_DIR}" \
    --with-build-sysroot="${STRAPY_INSTALL_DIR}" \
    --target="${STRAPY_TRIPLET}" \
    --disable-multilib \
    --disable-bootstrap \
    --with-newlib \
    --disable-shared \
    --enable-lto \
    --disable-threads \
    --enable-initfini-array \
    --with-gcc-major-version-only \
    --enable-languages=c,c++ \
    LD="ld.bfd"

printInfo "Building gcc compiler only"
make -j "${STRAPY_BUILD_JOBS}" all-gcc

printInfo "Installing gcc"
make -j "${STRAPY_BUILD_JOBS}" install-gcc DESTDIR="${STRAPY_INSTALL_DIR}"

printInfo "Building target libgcc"
make -j "${STRAPY_BUILD_JOBS}" all-target-libgcc

printInfo "Installing target libgcc"
make -j "${STRAPY_BUILD_JOBS}" install-target-libgcc DESTDIR="${STRAPY_INSTALL_DIR}"

printInfo "Installing default compiler links"
for i in "gcc" "g++" ; do
    ln -sv "${STRAPY_TRIPLET}-${i}" "${STRAPY_INSTALL_DIR}/usr/bin/${i}"
done
