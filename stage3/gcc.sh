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
extractSource isl

ln -sv "mpfr-4.1.0" mpfr
ln -sv "mpc-1.2.0" mpc
ln -sv "gmp-6.2.0" gmp
ln -sv "isl-0.21" isl

mkdir build
popd

serpentChrootCd gcc-*/build

unset CONFIG_SITE
export LD="ld"
export AR="ar"
export RANLIB="ranlib"
export AS="as"
export NM="nm"
export CC="gcc"
export CPP="clang-cpp"
export CXX="g++"
export LDFLAGS="-B/usr/lib -B/serpent/usr/lib"
export CFLAGS="-fuse-ld=bfd -I/usr/include"
# Due to gcc wonkiness with-build-sysroot
export COMPILER_PATH="/usr/binutils/bin:/usr/bin:/usr/sbin:/serpent/usr/bin:/serpent/usr/sbin"
export LIBRARY_PATH="/usr/lib:/serpent/usr/lib"

printInfo "Configuring gcc"
serpentChroot ../configure --prefix=/usr \
    --bindir=/usr/bin \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --includedir=/usr/include \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --disable-bootstrap \
    --enable-shared \
    --enable-static \
    --enable-threads \
    --disable-multilib \
    --disable-multiarch \
    --with-gcc-major-version-only \
    --enable-languages=c,c++

printInfo "Building gcc"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing gcc"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
