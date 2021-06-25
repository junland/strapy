#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" != "glibc" ]]; then
    printInfo "Skipping gcc with non-glibc libc"
    exit 0
fi

unset CONFIG_SITE
export LD="ld.bfd"
export AS="as"
export AR="ar"
export RANLIB="ranlib"
export NM="nm"
export OBJDUMP="objdump"
export READELF="readelf"
export STRIP="strip"

unset LDFLAGS CFLAGS CXXFLAGS
export CFLAGS="-O2 -L/usr/lib/gcc/x86_64-serpent-linux/11/32"
export CXXFLAGS="-O2 -L/usr/lib/gcc/x86_64-serpent-linux/11/32"
export PATH="/usr/bin:${PATH}"
export COMPILER_PATH="/usr/bin"
export LIBRARY_PATH="/usr/lib"


extractSource glibc
pushd glibc-*
mkdir build
mkdir build32
echo "slibdir=/usr/lib32" >> build32/configparms
echo "rtlddir=/usr/lib32" >> build32/configparms
echo "slibdir=/usr/lib" >> build/configparms
echo "rtlddir=/usr/lib" >> build/configparms

popd

serpentChrootCd glibc-*/build32

export CC="gcc -m32"
export CXX="g++ -m32"

printInfo "Configuring glibc 32bit"
serpentChroot ../configure --prefix=/usr \
    --host="${SERPENT_TRIPLET32}" \
    --target="${SERPENT_TRIPLET32}" \
    --libdir=/usr/lib32 \
    --libexecdir=/usr/lib32/glibc \
    --sysconfdir=/etc \
    --enable-threads=posix \
    --enable-gnu-indirect-function \
    --enable-multi-arch \
    --enable-plugin \
    --enable-ld=default \
    --enable-clocale=gnu \
    --enable-lto \
    --with-gnu-ld \
    libc_cv_forced_unwind=yes \
    libc_cv_include_x86_isa_level=no

printInfo "Building glibc 32bit"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing glibc 32bit"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install



serpentChrootCd glibc-*/build

export CC="gcc"
export CXX="g++"

printInfo "Configuring glibc"
serpentChroot ../configure --prefix=/usr \
    --host="${SERPENT_TRIPLET}" \
    --target="${SERPENT_TRIPLET}" \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/glibc \
    --sysconfdir=/etc \
    --enable-threads=posix \
    --enable-gnu-indirect-function \
    --enable-multi-arch \
    --enable-plugin \
    --enable-ld=default \
    --enable-clocale=gnu \
    --enable-lto \
    --with-gnu-ld \
    libc_cv_forced_unwind=yes \
    libc_cv_include_x86_isa_level=no

printInfo "Building glibc"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing glibc"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
