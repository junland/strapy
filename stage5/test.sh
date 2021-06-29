#!/usr/bin/env bash

build/benchmarking-tools/run-benchmark.sh cmake ${1}
build/benchmarking-tools/run-benchmark.sh compile-time-llvm ${1}
build/benchmarking-tools/run-benchmark.sh configure ${1}
build/benchmarking-tools/run-benchmark.sh pybench ${1}
build/benchmarking-tools/run-benchmark.sh xz ${1}
build/benchmarking-tools/run-benchmark.sh zlib ${1}
build/benchmarking-tools/run-benchmark.sh zstd ${1}
