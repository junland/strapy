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
echo "slibdir=/usr/lib32" >> build/configparms
echo "rtlddir=/usr/lib32" >> build/configparms

# Workaround binutils version check failing
sed -i 's/test -n "$critic_missing/test -n "$zcritic_missing/' configure
popd

serpentChrootCd glibc-*/build

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
    ac_cv_prog_LD=ld.bfd \
    ac_cv_prog_AR=${SERPENT_TRIPLET}-ar \
    ac_cv_prog_RANLIB=${SERPENT_TRIPLET}-ranlib \
    ac_cv_prog_AS=${SERPENT_TRIPLET}-as \
    ac_cv_prog_NM=${SERPENT_TRIPLET}-nm \
    libc_cv_forced_unwind=yes \
    libc_cv_include_x86_isa_level=no

printInfo "Building glibc 32bit"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing glibc 32bit"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
