#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${STRAPY_LIBC}" == "musl" ]]; then
    printInfo "Skipping gcc with musl libc"
    exit 0
fi

extractSource gcc
cd gcc-*

# Add include dirs to libgcc
sed -i "s|^LIBGCC2_INCLUDES =|LIBGCC2_INCLUDES = -B${STRAPY_INSTALL_DIR}/usr/lib|" libgcc/Makefile.in


printInfo "Extracting gcc requirements"
extractSource mpfr
extractSource mpc
extractSource gmp

ln -sv "mpfr-4.1.0" mpfr
ln -sv "mpc-1.2.1" mpc
ln -sv "gmp-6.2.1" gmp
export GCC_VERS="11.2.0"

export LD="ld.bfd"
export AR="ar"
export RANLIB="ranlib"
export AS="as"
export NM="nm"
export OBJDUMP="objdump"
export READELF="readelf"
export STRIP="strip"
export CC="gcc"
export CXX="g++"

export STRAPY_STAGE1_TREE=$(getInstallDir "1")
export PATH="${STRAPY_STAGE1_TREE}/usr/binutils/bin:${PATH}"

export CFLAGS="-O2 -fPIC"
export CXXFLAGS="-O2 -fPIC"

printInfo "Configuring libstdc++"
mkdir buildcxx && pushd buildcxx
../libstdc++-v3/configure --prefix=/usr \
    --libdir=/usr/lib \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --disable-multilib

printInfo "Building libstdcxx"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing libstdcxx"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"
popd

export CXXFLAGS="-O2 -fPIC -I${STRAPY_INSTALL_DIR}/usr/include -L${STRAPY_INSTALL_DIR}/usr/lib -L${STRAPY_INSTALL_DIR}/usr/lib64 -I${STRAPY_INSTALL_DIR}/usr/include/c++/${GCC_VERS} -I${STRAPY_INSTALL_DIR}/usr/include/c++/${GCC_VERS}/x86_64-linux-gnu"
printInfo "Configuring gcc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --disable-bootstrap \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libstdcxx \
    --disable-libssp \
    --disable-libvtv \
    --disable-multilib \
    --disable-multiarch \
    --enable-lto \
    --with-gcc-major-version-only \
    --enable-languages=c,c++

printInfo "Building gcc compiler only"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing gcc"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"

printInfo "Installing default compiler links"
for i in "gcc" "g++" ; do
    ln -svf "${STRAPY_TRIPLET}-${i}" "${STRAPY_INSTALL_DIR}/usr/bin/${i}"
done
