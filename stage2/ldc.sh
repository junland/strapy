#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

export LDC_VERSION="1.23.0"

printInfo "Extracting ldc"
extractSource ldc
extractSource ldc-static

pushd ldc-*


printInfo "Build bootstrap ldc compiler"
mkdir ldc-runtime && pushd ldc-runtime
cmake -G "Ninja" ../runtime \
    -DLDC_EXE_FULL="${SERPENT_BUILD_DIR}/ldc2-${LDC_VERSION}-linux-x86_64/bin/ldc2" \
    -DBUILD_SHARED_LIBS=OFF \
    -DD_VERSION=2 \
    -DDMDFE_MINOR_VERSION=0 \
    -DDMDFE_PATCH_VERSION=93 \
    -DD_EXTRA_FLAGS="-mtriple=x86_64-serpent-linux-musl"
ninja -j "${SERPENT_BUILD_JOBS}" -v

# Install musl ldc runtime for use to compile D programs
rm -rf ${SERPENT_BUILD_DIR}/ldc2-${LDC_VERSION}-linux-x86_64/lib/*
cp lib/* ${SERPENT_BUILD_DIR}/ldc2-${LDC_VERSION}-linux-x86_64/lib/
popd


mkdir ldc-build && pushd ldc-build
cmake -G "Ninja" .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_SHARED_LIBS=OFF \
    -DD_COMPILER="${SERPENT_BUILD_DIR}/ldc2-${LDC_VERSION}-linux-x86_64/bin/ldmd2" \
    -DLDC_DYNAMIC_COMPILE=OFF \
    -DLDC_WITH_LLD=OFF \
    -DD_EXTRA_FLAGS="-mtriple=x86_64-serpent-linux-musl"

printInfo "Building ldc"
ninja -j "${SERPENT_BUILD_JOBS}" -v

printInfo "Installing ldc"
DESTDIR="${SERPENT_INSTALL_DIR}" ninja install -j "${SERPENT_BUILD_JOBS}" -v
