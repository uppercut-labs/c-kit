#!/usr/bin/env bash
# The kit's full check on macOS and Linux (Bash or zsh): for every package under packages/, configure, build and run its
# tests, then build the example consumer project against the package's own source. Needs CMake, Ninja, a C compiler,
# SDL3 and Python 3.
#
#   ./tools/check.sh [SDL3 install prefix]
#
# Build output goes to build/<package>/ in this checkout.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
prefix="${1:-}"
extra=()
[ -n "$prefix" ] && extra+=("-DCMAKE_PREFIX_PATH=$prefix")
for pkg in "$root"/packages/*/; do
  name="$(basename "$pkg")"
  echo "== $name"
  cmake -S "$pkg" -B "$root/build/$name" -G Ninja -DCMAKE_BUILD_TYPE=Release ${extra[@]+"${extra[@]}"}
  cmake --build "$root/build/$name"
  ctest --test-dir "$root/build/$name" --output-on-failure
  if [ -f "$pkg/examples/consumer/CMakeLists.txt" ]; then
    echo "== $name: the example consumer"
    cmake -S "$pkg/examples/consumer" -B "$root/build/$name-consumer" -G Ninja -DCMAKE_BUILD_TYPE=Release \
      "-DFETCHCONTENT_SOURCE_DIR_PORT_INPUT_HARNESS=$root" ${extra[@]+"${extra[@]}"}
    cmake --build "$root/build/$name-consumer"
    ctest --test-dir "$root/build/$name-consumer" --output-on-failure
  fi
done
echo "check: all packages passed"
