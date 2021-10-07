#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${STRAPY_LIBC}" != "glibc" ]]; then
    printInfo "Skipping binutils with non-glibc libc"
    exit 0
fi

extractSource binutils
pushd binutils-*
mkdir build
popd
strapyChrootCd binutils-*/build

export CFLAGS="${STRAPY_TARGET_CFLAGS}"
export CXXFLAGS="${STRAPY_TARGET_CXXFLAGS}"

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
export CPP="clang-cpp"
export CXX="g++"

export LDFLAGS="-L/usr/lib -L/strapy/usr/lib -B/usr/lib -B/strapy/usr/lib -isystem /usr/include -isystem /strapy/usr/include"
export CFLAGS="${CFLAGS} ${LDFLAGS}"
export CXXFLAGS="${CXXFLAGS} ${LDFLAGS}"
export PATH="/strapy/usr/binutils/bin:/strapy/usr/bin:/usr/bin"

printInfo "Configuring binutils"
strapyChroot ../configure --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --with-lib-path="/usr/lib:/usr/lib32" \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --includedir=/usr/include \
    --enable-multilib \
    --enable-deterministic-archives \
    --enable-plugins \
    --without-debuginfod \
    --disable-shared \
    --disable-gdb \
    --enable-static \
    --enable-lto \
    --enable-threads \
    --enable-ld=default \
    --enable-secureplt \
    --enable-64-bit-bfd \
    PATH="/strapy/usr/binutils/bin:/strapy/usr/bin:/strapy/usr/sbin:/usr/bin:/usr/sbin"

printInfo "Building binutils"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" tooldir=/usr

printInfo "Installing binutils"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" tooldir=/usr install

strapyChroot install -Dm00644 ../include/libiberty.h /usr/include/libiberty.h
strapyChroot install -Dm00644 libiberty/libiberty.a /usr/lib/libiberty.a
