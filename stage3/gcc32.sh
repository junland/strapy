#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" != "glibc" ]]; then
    printInfo "Skipping gcc with non-glibc libc"
    exit 0
fi

extractSource gcc
pushd gcc-*

printInfo "Extracting gcc requirements"
extractSource mpfr
extractSource mpc
extractSource gmp

ln -sv "mpfr-4.1.0" mpfr
ln -sv "mpc-1.2.1" mpc
ln -sv "gmp-6.2.1" gmp
export GCC_VERS="11.1.0"

mkdir -p build
popd

unset CONFIG_SITE
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

export LDFLAGS="${LDFLAGS} -I/usr/lib"
export CFLAGS="${CFLAGS} ${LDFLAGS}"
export CPPFLAGS="${CFLAGS} ${LDFLAGS}"
export CXXFLAGS="${CXXFLAGS} ${LDFLAGS}"
export PATH="/usr/bin:${PATH}"
export COMPILER_PATH="/usr/bin"
export LIBRARY_PATH="/usr/lib"

serpentChrootCd gcc-*/build

printInfo "Configuring gcc"
serpentChroot ../configure \
    --host="${SERPENT_TRIPLET}" \
    --target="${SERPENT_TRIPLET}" \
    --prefix=/usr \
    --bindir=/usr/bin \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --includedir=/usr/include \
    --with-newlib \
    --without-headers \
    --enable-initfini-array \
    --disable-nls \
    --disable-shared \
    --enable-multilib \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-libstdcxx \
    --with-gcc-major-version-only \
    --enable-languages=c,c++ \
    --disable-werror \
    PATH="/usr/bin:/usr/sbin"

printInfo "Building gcc"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing gcc"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
