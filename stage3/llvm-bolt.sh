#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

printInfo "Extracting llvm-bolt"
extractSource llvm-bolt

mkdir -p  BOLT-37e51a3d450f371b811bf4ee5c0575d5e7c97e9c/llvm/build
serpentChrootCd BOLT-37e51a3d450f371b811bf4ee5c0575d5e7c97e9c/llvm/build

unset CFLAGS CXXFLAGS

serpentChroot cmake -G Ninja ../ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_PROJECTS='bolt' \
    -DLLVM_TARGETS_TO_BUILD=X86

printInfo "Building toolchain"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -v install-llvm-bolt install-perf2bolt install-merge-fdata
