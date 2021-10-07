#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${STRAPY_LIBC}" == "musl" ]]; then
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

export CC="gcc"
export CXX="g++"

export STRAPY_STAGE1_TREE=$(getInstallDir "1")
export PATH="${STRAPY_STAGE1_TREE}/usr/binutils/bin:${PATH}"

unset CFLAGS LDFLAGS
export LDFLAGS="-I${STRAPY_INSTALL_DIR}/usr/include -L${STRAPY_INSTALL_DIR}/usr/lib -L${STRAPY_INSTALL_DIR}/usr/lib64 -I${STRAPY_INSTALL_DIR}/usr/include/c++/10.2.0 -I${STRAPY_INSTALL_DIR}/usr/include/c++/10.2.0/x86_64-linux-gnu"
export CXXFLAGS="-I${STRAPY_INSTALL_DIR}/usr/include -L${STRAPY_INSTALL_DIR}/usr/lib -L${STRAPY_INSTALL_DIR}/usr/lib64 -I${STRAPY_INSTALL_DIR}/usr/include/c++/10.2.0 -I${STRAPY_INSTALL_DIR}/usr/include/c++/10.2.0/x86_64-linux-gnu"

printInfo "Configuring gcc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --disable-bootstrap \
    --disable-shared \
    --disable-threads \
    --disable-multilib \
    --with-gcc-major-version-only \
    --enable-languages=c,c++

printInfo "Building gcc"
make -j "${STRAPY_BUILD_JOBS}" all-target-libgcc

printInfo "Installing gcc"
make -j "${STRAPY_BUILD_JOBS}" install-target-libgcc DESTDIR="${STRAPY_INSTALL_DIR}"
