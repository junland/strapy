#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

printInfo "Extracting llvm-bolt"
extractSource llvm-bolt

mkdir -p  BOLT-be94db47a9d82fc82d6e0f2fca3609ba4cdb2cb8/llvm/build
serpentChrootCd BOLT-be94db47a9d82fc82d6e0f2fca3609ba4cdb2cb8/llvm/build

unset CFLAGS CXXFLAGS

export llvmopts="
    -DLLVM_ENABLE_PROJECTS='bolt;clang;lld' \
    -DLLVM_TARGETS_TO_BUILD='X86'"

serpentChroot cmake -G Ninja ../ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    ${llvmopts}

printInfo "Building toolchain"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -v install-llvm-bolt install-perf2bolt install-merge-fdata install-bolt_rt
