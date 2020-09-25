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

ln -sv "mpfr-4.1.0" mpfr
ln -sv "mpc-1.2.0" mpc
ln -sv "gmp-6.2.0" gmp

export LD="ld.bfd"
export AR="ar"
export RANLIB="ranlib"
export AS="as"
export NM="nm"
export CC="gcc"
export CPP="clang-cpp"
export CXX="g++"

export SERPENT_STAGE1_TREE=$(getInstallDir "1")
export PATH="${SERPENT_STAGE1_TREE}/usr/binutils/bin:${PATH}"

export CFLAGS="-O2 -fPIC"
export CXXFLAGS="-O2 -fPIC"

printInfo "Configuring libstdc++"
mkdir buildcxx && pushd buildcxx
../libstdc++-v3/configure --prefix=/usr \
    --libdir=/usr/lib \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --disable-shared \
    --disable-multilib \
    --disable-libstdcxx-pch

printInfo "Building libstdcxx"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing libstdcxx"
make -j "${SERPENT_BUILD_JOBS}" install DESTDIR="${SERPENT_INSTALL_DIR}"
popd

export CXXFLAGS="-I${SERPENT_INSTALL_DIR}/usr/include -L${SERPENT_INSTALL_DIR}/usr/lib -L${SERPENT_INSTALL_DIR}/usr/lib64 -I${SERPENT_INSTALL_DIR}/usr/include/c++/10.2.0 -I${SERPENT_INSTALL_DIR}/usr/include/c++/10.2.0/x86_64-linux-gnu"
printInfo "Configuring gcc"
mkdir build && pushd build
../configure --prefix=/usr \
    --libdir=/usr/lib \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --disable-bootstrap \
    --disable-shared \
    --disable-threads \
    --disable-multilib \
    --disable-multiarch \
    --with-gcc-major-version-only \
    --enable-languages=c

printInfo "Building gcc compiler only"
make -j "${SERPENT_BUILD_JOBS}" all-gcc

printInfo "Installing gcc"
make -j "${SERPENT_BUILD_JOBS}" install-gcc DESTDIR="${SERPENT_INSTALL_DIR}"

printInfo "Building target libgcc"
make -j "${SERPENT_BUILD_JOBS}" all-target-libgcc

printInfo "Installing target libgcc"
make -j "${SERPENT_BUILD_JOBS}" install-target-libgcc DESTDIR="${SERPENT_INSTALL_DIR}"

printInfo "Installing default compiler links"
for i in "gcc" "g++" ; do
    ln -sv "${SERPENT_TRIPLET}-${i}" "${SERPENT_INSTALL_DIR}/usr/bin/${i}"
done
