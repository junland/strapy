#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${STRAPY_LIBC}" != "glibc" ]]; then
    printInfo "Skipping gcc with non-glibc libc"
    exit 0
fi

extractSource gcc
pushd gcc-*

# Add default toolchain patches into S3
patch -p1 < "${STRAPY_PATCHES_DIR}/gcc/0001-Use-modern-linker-locations-for-Serpent-OS.patch"

printInfo "Extracting gcc requirements"
extractSource mpfr
extractSource mpc
extractSource gmp
#extractSource isl

ln -sv "mpfr-4.1.0" mpfr
ln -sv "mpc-1.2.1" mpc
ln -sv "gmp-6.2.1" gmp
#ln -sv "isl-0.24" isl
export GCC_VERS="11.2.0"

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
export CC="gcc -B/usr/lib -isystem /usr/include -isystem /strapy/usr/include"
export CXX="g++ -B/usr/lib -isystem /usr/include -isystem /usr/include -isystem /strapy/usr/include/c++/${GCC_VERS} -isystem /strapy/usr/include/c++/${GCC_VERS}/x86_64-linux-gnu"

ln -svf /strapy/usr/bin/cpp "${STRAPY_INSTALL_DIR}/lib/cpp"

export LDFLAGS="-L/usr/lib -L/strapy/usr/lib -B/usr/lib -B/strapy/usr/lib -isystem /usr/include -isystem /strapy/usr/include"
export CFLAGS="${CFLAGS} ${LDFLAGS}"
export CPPFLAGS="${CFLAGS} ${LDFLAGS}"
export CXXFLAGS="${CXXFLAGS} ${LDFLAGS} -isystem /strapy/usr/include/c++/${GCC_VERS} -isystem /strapy/usr/include/c++/${GCC_VERS}/x86_64-linux-gnu"
export PATH="/usr/binutils/bin:${PATH}"
export COMPILER_PATH="/usr/binutils/bin:/usr/bin:/strapy/usr/bin"
export LIBRARY_PATH="/usr/lib"

strapyChrootCd gcc-*/build

printInfo "Configuring gcc"
strapyChroot ../configure --prefix=/usr \
    --bindir=/usr/bin \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --includedir=/usr/include \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --disable-bootstrap \
    --enable-shared \
    --enable-static \
    --enable-threads \
    --disable-multilib \
    --disable-werror \
    --with-gcc-major-version-only \
    --enable-gnu-indirect-function \
    --enable-plugin \
    --enable-ld=default \
    --enable-clocale=gnu \
    --with-linker-hash-style=both \
    --with-gnu-ld \
    --enable-languages=c,c++ \
    PATH="/usr/binutils/bin:/strapy/usr/bin:/strapy/usr/sbin:/usr/bin:/usr/sbin"

printInfo "Building gcc"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing gcc"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
ln -svf /usr/bin/cpp "${STRAPY_INSTALL_DIR}/lib/cpp"

stashBinutils gnu-binutils
stashGcc gnu-gcc
