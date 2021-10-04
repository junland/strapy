#!/bin/true

. $(dirname $(realpath -s $0))/../lib/base.sh

# This profile is intended for all CPUs made in last 10 years

export SERPENT_TARGET_CFLAGS="-march=x86-64-v2 -mtune=ivybridge -O2 -fPIC -pipe"
export SERPENT_TARGET_CXXFLAGS="${SERPENT_TARGET_CFLAGS}"
export SERPENT_TARGET_LDFLAGS=""
export SERPENT_TRIPLET="x86_64-serpent-linux"
export SERPENT_TRIPLET32="i686-serpent-linux"

if [[ "${SERPENT_LIBC}" == "musl" ]]; then
    export SERPENT_TRIPLET="${SERPENT_TRIPLET}-musl"
fi

export SERPENT_TARGET_LLVM_BACKEND="X86"
export SERPENT_TARGET_ARCH="x86_64"

# The inlude directory in musl
export SERPENT_TARGET_MUSL="${SERPENT_TARGET_ARCH}"
